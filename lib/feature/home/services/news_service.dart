import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_item.dart';
import '../repositories/ai_repository.dart';

/// ニュース取得サービス
class NewsService {
  final GeminiRepository _geminiRepository;

  // URL検証の設定
  static const int _urlValidationTimeout = 3; // 秒
  static const int _maxRetries = 3; // 最大試行回数
  static const int _fetchCountPerRequest = 5; // 1回のリクエストで取得する数

  NewsService(this._geminiRepository);

  /// トピックに関連するニュースを取得（URL検証付き）
  Future<List<NewsItem>> getRelatedNews(String topic, {int count = 3}) async {
    final List<NewsItem> validNews = [];
    int retryCount = 0;

    try {
      // 必要な数が集まるまで、または最大試行回数に達するまで繰り返す
      while (validNews.length < count && retryCount < _maxRetries) {
        retryCount++;
        print('ニュース取得試行 $retryCount/$_maxRetries (現在: ${validNews.length}/$count件)');

        final prompt = _buildNewsPrompt(topic, _fetchCountPerRequest);

        final response = await _geminiRepository.generateTextWithSearch(
          prompt: prompt,
          temperature: 0.3,
          maxTokens: 5000,
        );

        final candidateNews = _parseNewsFromResponse(
          response['text'] as String,
          response['groundingChunks'] as List<dynamic>,
        );

        print('取得したニュース候補: ${candidateNews.length}件');

        // URL検証を実行
        final validatedNews = await _validateUrls(candidateNews);
        print('有効なURL: ${validatedNews.length}件');

        // 重複を避けて追加
        for (final news in validatedNews) {
          if (validNews.length >= count) break;

          // 既に同じURLが存在しないかチェック
          final isDuplicate = validNews.any((existing) => existing.url == news.url);
          if (!isDuplicate) {
            validNews.add(news);
          }
        }

        print('累計有効ニュース: ${validNews.length}件');
      }

      // 必要な数だけ返す
      return validNews.take(count).toList();
    } catch (e) {
      print('Error getting related news: $e');
      // エラー時は取得できた分だけ返す
      return validNews;
    }
  }

  /// ニュース取得用のプロンプトを構築
  String _buildNewsPrompt(String topic, int count) {
    return '''
トピック: "$topic"

このトピックに関連する最新のニュース記事を${count}つ検索し、以下のJSON形式で返してください。
必ず最新の情報を検索してください。

以下の条件を満たすニュースを選んでください：
- トピックに直接関連する内容であること
- できるだけ新しい記事であること（過去1ヶ月以内が望ましい）
- 信頼できる情報源からの記事であること
- 日本語の記事であること

出力形式（必ずこの形式のJSONのみを返してください）：
{
  "news": [
    {
      "title": "ニュースのタイトル",
      "summary": "ニュースの要約（100文字程度で簡潔に）",
      "url": "記事のURL",
      "source": "情報源（例: NHK、朝日新聞、など）",
      "publishedAt": "公開日時（ISO 8601形式、例: 2025-01-15T10:00:00Z）"
    }
  ]
}

重要: 上記のJSON形式のみを返し、他の説明や前置きは一切含めないでください。
''';
  }

  /// レスポンスからニュースをパース
  /// groundingChunksから実際の検索結果のURLを使用
  List<NewsItem> _parseNewsFromResponse(
    String response,
    List<dynamic> groundingChunks,
  ) {
    try {
      // AIが生成したテキストからニュース情報を抽出（要約などの詳細情報用）
      Map<String, dynamic>? aiGeneratedData;
      try {
        // JSONの前後の不要なテキストを削除
        String jsonString = response.trim();

        // マークダウンのコードブロックを削除
        if (jsonString.startsWith('```json')) {
          jsonString = jsonString.substring(7);
        } else if (jsonString.startsWith('```')) {
          jsonString = jsonString.substring(3);
        }

        if (jsonString.endsWith('```')) {
          jsonString = jsonString.substring(0, jsonString.length - 3);
        }

        jsonString = jsonString.trim();

        final Map<String, dynamic> data = jsonDecode(jsonString);
        aiGeneratedData = data;
      } catch (e) {
        print('Warning: Could not parse AI response as JSON: $e');
        // JSONパースに失敗してもgroundingChunksから生成を試みる
      }

      // groundingChunksから実際の検索結果のURLを使用してNewsItemを作成
      final List<NewsItem> newsItems = [];

      for (int i = 0; i < groundingChunks.length; i++) {
        final chunk = groundingChunks[i] as Map<String, dynamic>;
        final uri = chunk['uri'] as String?;
        final title = chunk['title'] as String?;

        if (uri == null || uri.isEmpty) continue;

        // AIが生成したJSONから対応する情報を取得（可能な場合）
        String newsTitle = title ?? 'ニュース記事';
        String summary = '';
        String? source;
        DateTime? publishedAt;

        if (aiGeneratedData != null && aiGeneratedData['news'] != null) {
          final newsArray = aiGeneratedData['news'] as List<dynamic>;
          if (i < newsArray.length) {
            final newsData = newsArray[i] as Map<String, dynamic>;
            newsTitle = newsData['title'] as String? ?? title ?? 'ニュース記事';
            summary = newsData['summary'] as String? ?? '';
            source = newsData['source'] as String?;

            // publishedAtをパース
            if (newsData['publishedAt'] != null) {
              try {
                publishedAt = DateTime.parse(newsData['publishedAt'] as String);
              } catch (e) {
                print('Error parsing date: $e');
              }
            }
          }
        }

        newsItems.add(NewsItem(
          title: newsTitle,
          summary: summary,
          url: uri, // ★重要: groundingChunksから取得した実際のURLを使用
          source: source,
          publishedAt: publishedAt,
        ));
      }

      return newsItems;
    } catch (e) {
      print('Error parsing news response: $e');
      print('Response: $response');
      print('GroundingChunks: $groundingChunks');
      return [];
    }
  }

  /// トピックのカテゴリに基づいてニュースを取得
  Future<List<NewsItem>> getNewsByCategory(String topic, String category, {int count = 3}) async {
    final categoryKeywords = {
      '日常系': '生活 暮らし',
      '社会問題系': '社会 政治 経済',
      '価値観系': '文化 思想 哲学',
    };

    final additionalKeywords = categoryKeywords[category] ?? '';
    final enhancedTopic = '$topic $additionalKeywords';

    return getRelatedNews(enhancedTopic, count: count);
  }

  /// URLの有効性を検証（複数のニュースアイテムを並列処理）
  Future<List<NewsItem>> _validateUrls(List<NewsItem> newsItems) async {
    final results = await Future.wait(
      newsItems.map((news) => _validateUrl(news)),
    );

    // 有効なニュースアイテムのみを返す
    return results.where((news) => news != null).cast<NewsItem>().toList();
  }

  /// 単一のURLの有効性を検証
  Future<NewsItem?> _validateUrl(NewsItem newsItem) async {
    if (newsItem.url == null || newsItem.url!.isEmpty) {
      print('URLなし: ${newsItem.title}');
      return null;
    }

    try {
      final uri = Uri.parse(newsItem.url!);

      // HEADリクエストで軽量にチェック
      final response = await http.head(uri).timeout(
        Duration(seconds: _urlValidationTimeout),
      );

      // ステータスコード200番台または300番台（リダイレクト）なら有効
      if (response.statusCode >= 200 && response.statusCode < 400) {
        print('✓ 有効なURL: ${newsItem.url}');
        return newsItem;
      } else {
        print('✗ 無効なステータス ${response.statusCode}: ${newsItem.url}');
        return null;
      }
    } catch (e) {
      print('✗ URL検証エラー: ${newsItem.url} - $e');
      return null;
    }
  }
}

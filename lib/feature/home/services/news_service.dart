import 'dart:convert';
import '../models/news_item.dart';
import '../repositories/ai_repository.dart';

/// ニュース取得サービス
class NewsService {
  final GeminiRepository _geminiRepository;

  NewsService(this._geminiRepository);

  /// トピックに関連するニュースを取得
  Future<List<NewsItem>> getRelatedNews(String topic, {int count = 3}) async {
    try {
      final prompt = _buildNewsPrompt(topic, count);

      final response = await _geminiRepository.generateTextWithSearch(
        prompt: prompt,
        temperature: 0.3, // 事実に基づく情報なので低めに設定
        maxTokens: 5000, // Google Search Groundingは検索メタデータで大量のトークンを消費するため十分大きく設定
      );

      final news = _parseNewsFromResponse(response);
      return news;
    } catch (e) {
      // エラー時は空のリストを返す
      return [];
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
  List<NewsItem> _parseNewsFromResponse(String response) {
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
      final List<dynamic> newsArray = data['news'] as List<dynamic>;

      return newsArray.map((item) {
        final newsMap = item as Map<String, dynamic>;

        // publishedAtをパース
        DateTime? publishedAt;
        if (newsMap['publishedAt'] != null) {
          try {
            publishedAt = DateTime.parse(newsMap['publishedAt'] as String);
          } catch (e) {
            print('Error parsing date: $e');
          }
        }

        return NewsItem(
          title: newsMap['title'] as String? ?? '',
          summary: newsMap['summary'] as String? ?? '',
          url: newsMap['url'] as String?,
          source: newsMap['source'] as String?,
          publishedAt: publishedAt,
        );
      }).toList();
    } catch (e) {
      print('Error parsing news response: $e');
      print('Response: $response');
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
}

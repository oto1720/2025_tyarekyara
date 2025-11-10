# ニュース表示のトラブルシューティング

## 問題: ニュースが表示されない

### 原因

`daily_topic_provider.dart`の`generateNewTopic()`メソッドで、ニュース取得の処理が統合されていませんでした。

### 修正内容

1. **NewsServiceのインポートを追加** (`lib/feature/home/providers/daily_topic_provider.dart`)
   ```dart
   import '../services/news_service.dart';
   ```

2. **GeminiRepositoryとNewsServiceのプロバイダーを追加**
   ```dart
   /// Geminiリポジトリプロバイダー（ニュース取得用）
   final geminiRepositoryProviderForDaily = Provider<GeminiRepository>((ref) {
     return GeminiRepository();
   });

   /// ニュースサービスプロバイダー
   final newsServiceProviderForDaily = Provider<NewsService>((ref) {
     final geminiRepository = ref.watch(geminiRepositoryProviderForDaily);
     return NewsService(geminiRepository);
   });
   ```

3. **generateNewTopic()メソッドにニュース取得処理を追加**
   ```dart
   // 関連ニュースを取得
   final newsService = ref.read(newsServiceProviderForDaily);
   final relatedNews = await newsService.getNewsByCategory(
     topicText.trim(),
     selection.category.displayName,
     count: 3,
   );

   // Topicオブジェクトを作成
   final newTopic = Topic(
     // ... 他のフィールド
     relatedNews: relatedNews, // ← 追加
   );
   ```

## 既存のトピックについて

### 重要な注意点

**既存のFirestoreに保存されているトピックには`relatedNews`フィールドが含まれていません。**

そのため、以下のいずれかの操作が必要です：

### 解決方法1: 新しいトピックを生成する（推奨）

アプリのリフレッシュボタン（AppBarの更新アイコン）をタップして、新しいトピックを生成してください。

1. アプリを起動
2. 右上のリフレッシュボタン（🔄）をタップ
3. 新しいトピックが生成されると、関連ニュースも一緒に取得されます

### 解決方法2: 既存のトピックにニュースを追加するスクリプト

既存のトピックにもニュースを追加したい場合は、以下のようなマイグレーションスクリプトを実行できます：

```dart
// lib/scripts/migrate_topics_with_news.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../feature/home/repositories/daily_topic_repository.dart';
import '../feature/home/services/news_service.dart';
import '../feature/home/repositories/ai_repository.dart';

Future<void> migrateTopicsWithNews(WidgetRef ref) async {
  final repository = ref.read(dailyTopicRepositoryProvider);
  final newsService = NewsService(GeminiRepository());

  // 今日のトピックを取得
  final topic = await repository.getTodayTopic();

  if (topic != null && topic.relatedNews.isEmpty) {
    // ニュースを取得
    final relatedNews = await newsService.getNewsByCategory(
      topic.text,
      topic.category.displayName,
      count: 3,
    );

    // トピックを更新
    final updatedTopic = topic.copyWith(relatedNews: relatedNews);
    await repository.saveTodayTopic(updatedTopic);

    print('トピックにニュースを追加しました: ${relatedNews.length}件');
  }
}
```

## デバッグ方法

### 1. ニュース取得のログを確認

`lib/feature/home/services/news_service.dart`の`getRelatedNews`メソッドに以下を追加：

```dart
Future<List<NewsItem>> getRelatedNews(String topic, {int count = 3}) async {
  try {
    print('ニュース取得開始: トピック=$topic, 件数=$count'); // ← 追加
    final prompt = _buildNewsPrompt(topic, count);
    final response = await _geminiRepository.generateTextWithSearch(
      prompt: prompt,
      temperature: 0.3,
      maxTokens: 1500,
    );

    print('Gemini APIレスポンス: $response'); // ← 追加

    final news = _parseNewsFromResponse(response);
    print('パースされたニュース件数: ${news.length}'); // ← 追加

    return news;
  } catch (e) {
    print('ニュース取得エラー: $e'); // ← 追加
    return [];
  }
}
```

### 2. Gemini APIキーの確認

`.env`ファイルを確認：

```env
GEMINI_API_KEY=your_actual_api_key_here
```

### 3. APIキーが正しく読み込まれているか確認

`lib/feature/home/repositories/ai_repository.dart`の`GeminiRepository`コンストラクタに追加：

```dart
GeminiRepository({String? apiKey})
    : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '' {
  print('Gemini API Key loaded: ${_apiKey.isNotEmpty ? "有効" : "無効"}'); // ← 追加
}
```

### 4. ネットワークエラーの確認

トピック生成時のエラーメッセージを確認：

```dart
} catch (e) {
  print('詳細エラー: $e'); // エラーの詳細を出力
  state = state.copyWith(
    isGenerating: false,
    isLoading: false,
    error: 'トピックの生成に失敗しました: $e',
  );
}
```

## よくある問題

### 問題1: APIキーが設定されていない

**エラー**: `Gemini API key is not configured`

**解決方法**:
1. `.env`ファイルに`GEMINI_API_KEY`を追加
2. [Google AI Studio](https://makersuite.google.com/app/apikey)でAPIキーを取得
3. アプリを再起動

### 問題2: ニュースのパースエラー

**エラー**: `Error parsing news response`

**解決方法**:
1. Gemini APIのレスポンスをログで確認
2. JSON形式が正しいか確認
3. プロンプトを調整してより明確な指示を出す

### 問題3: ネットワーク接続エラー

**エラー**: `SocketException` または `TimeoutException`

**解決方法**:
1. インターネット接続を確認
2. ファイアウォールやプロキシの設定を確認
3. Gemini APIの利用制限に達していないか確認

### 問題4: Firestoreへの保存エラー

**エラー**: `relatedNews`フィールドの保存に失敗

**解決方法**:
1. Firestoreのセキュリティルールを確認
2. `NewsItem`モデルが正しくシリアライズされているか確認
3. freezedのコード生成を再実行:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## 確認チェックリスト

新しいトピックを生成する前に、以下を確認してください：

- [ ] `.env`ファイルに`GEMINI_API_KEY`が設定されている
- [ ] `flutter pub get`を実行済み
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs`を実行済み
- [ ] アプリを再起動している
- [ ] インターネット接続が正常
- [ ] Gemini APIの利用制限内である

## テスト手順

1. アプリを起動
2. ホーム画面の右上のリフレッシュボタンをタップ
3. 新しいトピックが生成されるまで待つ（10-20秒程度）
4. トピックカードの下に「関連ニュース」セクションが表示されることを確認
5. ニュースセクションをタップして展開/折りたたみが動作することを確認
6. 個別のニュースカードをタップしてブラウザでURLが開くことを確認

## サポート

問題が解決しない場合は、以下の情報を含めてissueを作成してください：

1. エラーメッセージの全文
2. コンソールログ（ニュース取得のログを含む）
3. Gemini APIキーが設定されているか（値は含めない）
4. Flutter、Dartのバージョン
5. 実行環境（iOS/Android/Web）

# ニュース機能ドキュメント

## 📰 概要

日別トピックに関連する最新ニュースを自動取得して表示する機能です。
Gemini 2.5 FlashのGoogle Search Grounding機能を使用して、トピックに関連する実在するニュースを取得します。

## 🎯 機能

- トピック生成時に関連ニュースを自動取得（最大3件）
- ニュースカードとして美しく表示
- タップでブラウザでニュース記事を開く
- Firestoreに保存して永続化

## 🏗️ アーキテクチャ

### ディレクトリ構成

```
lib/feature/home/
├── models/
│   ├── news_item.dart              # ニュースアイテムモデル
│   ├── news_item.freezed.dart      # freezed生成ファイル
│   └── news_item.g.dart            # json_serializable生成ファイル
├── repositories/
│   └── ai_repository.dart          # Gemini API連携（Google Search対応）
├── services/
│   └── news_service.dart           # ニュース取得ロジック
├── presentation/
│   └── widgets/
│       ├── news_card.dart          # ニュースカード（単体）
│       ├── news_list.dart          # ニュースリスト
│       └── related_news_section.dart  # 関連ニュースセクション
└── providers/
    └── daily_topic_provider.dart   # トピック生成時にニュース取得
```

### データフロー

```
1. トピック生成
   └→ DailyTopicNotifier.generateNewTopic()

2. ニュース取得
   └→ NewsService.getNewsByCategory()
      └→ GeminiRepository.generateTextWithSearch()
         └→ Gemini 2.5 Flash API (Google Search Grounding)

3. レスポンスパース
   └→ NewsService._parseNewsFromResponse()
      └→ JSON → List<NewsItem>

4. Topicに追加
   └→ Topic(relatedNews: [...])

5. Firestore保存
   └→ DailyTopicRepository.saveTodayTopic()
      └→ NewsItem.toJson() で手動変換

6. UI表示
   └→ RelatedNewsSection
      └→ NewsList
         └→ NewsCard (タップで url_launcher)
```

## 📦 モデル定義

### NewsItem

```dart
@freezed
class NewsItem with _$NewsItem {
  const factory NewsItem({
    required String title,      // ニュースのタイトル
    required String summary,    // ニュースの要約
    String? url,                // ニュースのURL
    String? source,             // 情報源
    DateTime? publishedAt,      // 公開日時
    String? imageUrl,           // サムネイル画像のURL
  }) = _NewsItem;

  factory NewsItem.fromJson(Map<String, dynamic> json)
    => _$NewsItemFromJson(json);
}
```

### Topic (拡張)

```dart
@freezed
class Topic with _$Topic {
  const factory Topic({
    // ... 既存フィールド
    @Default([]) List<NewsItem> relatedNews, // ★追加
  }) = _Topic;
}
```

## 🔧 実装詳細

### 1. Gemini API設定

**ai_repository.dart** - Google Search Grounding対応

```dart
class GeminiRepository implements AIRepository {
  final String _apiKey;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  Future<String> generateTextWithSearch({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 5000,  // Google Search Groundingは大量のトークンを消費
  }) async {
    final requestBody = {
      'contents': [...],
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
      },
      'tools': [
        {
          'google_search': {}  // Google Search Grounding
        }
      ],
    };
    // ...
  }
}
```

**重要な設定：**
- **モデル**: `gemini-2.5-flash` (最新)
- **API version**: `v1beta` (Google Search対応)
- **maxTokens**: `5000` (検索メタデータで大量消費するため)
- **tools**: `google_search` (最新形式、`googleSearchRetrieval`は非推奨)

### 2. ニュース取得サービス

**news_service.dart**

```dart
class NewsService {
  final GeminiRepository _geminiRepository;

  Future<List<NewsItem>> getNewsByCategory(
    String topic,
    String category,
    {int count = 3}
  ) async {
    final prompt = _buildNewsPrompt(topic, count);
    final response = await _geminiRepository.generateTextWithSearch(
      prompt: prompt,
      temperature: 0.3,  // 事実ベースなので低め
      maxTokens: 5000,
    );
    return _parseNewsFromResponse(response);
  }
}
```

### 3. Firestore保存の重要なポイント

**daily_topic_repository.dart**

```dart
Future<void> saveTodayTopic(Topic topic) async {
  final jsonData = topic.toJson();

  // ★重要: relatedNewsを手動でJSON配列に変換
  if (topic.relatedNews.isNotEmpty) {
    jsonData['relatedNews'] = topic.relatedNews
        .map((newsItem) => newsItem.toJson())
        .toList();
  }

  await _firestore.collection(_collectionName).doc(dateKey).set(jsonData);
}
```

**なぜ手動変換が必要？**
- freezedの`toJson()`では、ネストしたオブジェクトが完全にシリアライズされない場合がある
- Firestoreは`Map<String, dynamic>`の配列のみサポート
- `_$NewsItemImpl`オブジェクトのままだとエラーになる

## ⚙️ 設定

### 1. Gemini APIキーの設定

`.env`ファイルに追加：

```env
GEMINI_API_KEY=your_api_key_here
```

### 2. 依存パッケージ

`pubspec.yaml`に以下が必要：

```yaml
dependencies:
  http: ^1.2.2
  flutter_dotenv: ^5.2.1
  url_launcher: ^6.3.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  freezed: ^2.5.7
  build_runner: ^2.4.13
  json_serializable: ^6.8.0
```

### 3. コード生成

freezedとjson_serializableのコード生成：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. url_launcherの設定

**iOS**: `ios/Runner/Info.plist`に追加
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>https</string>
  <string>http</string>
</array>
```

**Android**: `android/app/src/main/AndroidManifest.xml`に追加
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
</queries>
```

## 🔍 トラブルシューティング

### ニュースが0件になる

**原因:**
- APIキーが未設定または無効
- ネットワークエラー
- Gemini APIの利用制限
- レスポンスのパースエラー

**確認方法:**
1. `.env`ファイルの`GEMINI_API_KEY`を確認
2. ネットワーク接続を確認
3. Gemini APIの利用状況を確認

### Firestoreへの保存エラー

**エラーメッセージ:**
```
Unsupported field value: a custom _$NewsItemImpl object
```

**解決方法:**
- `daily_topic_repository.dart`の`saveTodayTopic()`で手動変換を確認
- コード生成を再実行: `flutter pub run build_runner build --delete-conflicting-outputs`

### トークン制限エラー

**エラーメッセージ:**
```
トークン制限に達しました。maxTokensを増やす必要があります。
```

**解決方法:**
- `ai_repository.dart`と`news_service.dart`の`maxTokens`を増やす（現在5000）
- 最大値: Gemini 2.5 Flashは8192トークンまでサポート

## 📊 API利用について

### Gemini API制限

**無料枠（2025年1月時点）:**
- リクエスト数: 60 requests/分
- トークン数: 1,500 requests/日

**推奨される使い方:**
- トピック生成は1日1回のみ（アプリの仕様上自然に制限される）
- エラー時はリトライしない（空のリストを返す）

### コスト最適化

1. **温度設定を低めに**: `temperature: 0.3` (事実ベースなので)
2. **maxTokensを適切に**: 必要最小限（現在5000）
3. **キャッシュ活用**: Firestoreに保存して再利用

## 🎨 UI/UXの考慮点

### ニュース表示の条件

```dart
if (topic.relatedNews.isNotEmpty)
  RelatedNewsSection(
    newsList: topic.relatedNews,
    topicText: topic.text,
  ),
```

- ニュースが0件の場合は何も表示しない（エラー表示なし）
- ユーザーに違和感を与えないための配慮

### カードデザイン

- タイトル: 太字、16px
- 要約: 通常、14px、灰色
- 情報源と日付: 12px、薄い灰色
- タップ時のフィードバック: InkWellでリップルエフェクト

## 🚀 今後の拡張案

### 機能追加

1. **ニュース数の変更**: 設定で3件/5件/10件を選択可能に
2. **カテゴリフィルター**: 特定カテゴリのニュースのみ表示
3. **ブックマーク機能**: 気になるニュースを保存
4. **共有機能**: SNSにニュースを共有
5. **画像表示**: `imageUrl`を使ってサムネイル表示

### パフォーマンス改善

1. **キャッシュ戦略**: 同じトピックのニュースを再利用
2. **並列取得**: トピック生成とニュース取得を並列化
3. **遅延ローディング**: ニュースを後から非同期取得

## 📝 参考リンク

- [Gemini API - Grounding](https://ai.google.dev/gemini-api/docs/grounding)
- [url_launcher パッケージ](https://pub.dev/packages/url_launcher)
- [freezed パッケージ](https://pub.dev/packages/freezed)
- [json_serializable](https://pub.dev/packages/json_serializable)

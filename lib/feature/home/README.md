# Home機能 - AIトピック生成とディスカッション

AIを活用した1日1回のトピック自動生成とディスカッション機能を提供するモジュールです。

## 目次

1. [機能概要](#機能概要)
2. [日別トピック機能（新規）](#日別トピック機能新規)
3. [AIトピック生成機能](#aiトピック生成機能)
4. [ディレクトリ構成](#ディレクトリ構成)
5. [セットアップ](#セットアップ)
6. [使い方](#使い方)
7. [アーキテクチャ](#アーキテクチャ)
8. [トラブルシューティング](#トラブルシューティング)

---

## 機能概要

### 日別トピック機能（新規）

**メインのホーム画面機能** - 1日1回AIによって自動生成されるトピックをユーザーに提示し、意見投稿を促す機能

#### 特徴
- ✅ **1日1回の自動生成**: 毎日新しいトピックがAIによって生成される
- ✅ **Firestoreでキャッシュ**: 同じ日は同じトピックを表示（API コスト削減）
- ✅ **ランダムな特性**: カテゴリーと難易度が確率的に決定される
- ✅ **意見投稿機能**: 賛成/反対/中立の立場で100〜3000文字の意見を投稿

#### カテゴリー分布（確率的選択）
| カテゴリー | 確率 | 説明 |
|----------|------|------|
| 日常系 | 40% | 日常生活や身近なテーマについての話題 |
| 社会問題系 | 35% | 社会問題や時事的なテーマについての話題 |
| 価値観系 | 25% | 価値観や人生観についての深いテーマ |

#### 難易度分布（確率的選択）
| 難易度 | 確率 | 説明 |
|--------|------|------|
| 簡単 | 45% | 気軽に答えられる話題 |
| 中程度 | 35% | 少し考える必要がある話題 |
| 難しい | 20% | 深い思考が必要な話題 |

---

### AIトピック生成機能

**開発・テスト用の生成画面** - 様々な条件でトピックを生成・テストできる機能

#### 主な機能
1. **トピック生成**
   - LLM統合: OpenAI GPT-4 または Anthropic Claude を使用
   - プロンプトエンジニアリング: 高品質なトピックを生成
   - カテゴリ別生成: 日常系・社会問題系・価値観系から選択可能

2. **トピック分類器**
   - 自動分類: 生成されたトピックを自動的にカテゴリと難易度に分類
   - タグ抽出: トピックに関連するキーワードを自動抽出
   - ルールベースのフォールバック: AI分類に失敗した場合の簡易分類

3. **重複検出**
   - 類似度計算: レーベンシュタイン距離とJaccard係数を使用
   - 重複防止: 既存トピックとの類似度をチェック
   - 類似度スコア表示: 開発用に類似度を可視化

4. **難易度調整**
   - ユーザー層に応じた調整: 初心者・中級者・上級者向けの難易度配分
   - フィードバック学習: ユーザーの反応に基づいた難易度の自動調整
   - バランスチェック: トピックセット全体の難易度バランスを評価

---

## ディレクトリ構成

```
lib/feature/home/
├── README.md                              # このファイル
│
├── models/                                # データモデル
│   ├── topic.dart                         # トピックモデル（Freezed）
│   ├── topic.freezed.dart
│   ├── topic.g.dart
│   └── opiniton.dart                      # 意見モデル
│
├── repositories/                          # データ永続化・外部API
│   ├── ai_repository.dart                 # AI API（OpenAI/Claude）
│   └── daily_topic_repository.dart        # 【新規】日別トピック Firestore リポジトリ
│
├── services/                              # ビジネスロジック
│   ├── topic_generation_service.dart      # トピック生成サービス
│   ├── topic_classifier_service.dart      # トピック分類サービス
│   ├── topic_difficulty_adjuster.dart     # 難易度調整サービス
│   └── topic_duplicate_detector.dart      # 重複検出サービス
│
├── providers/                             # 状態管理（Riverpod）
│   ├── daily_topic_provider.dart          # 【新規】日別トピック状態管理
│   ├── daily_topic_provider.freezed.dart
│   ├── topic_generation_provider.dart     # トピック生成プロバイダー
│   ├── topic_generation_state.dart        # トピック生成状態
│   └── topic_generation_state.freezed.dart
│
├── utils/                                 # ユーティリティ
│   └── random_topic_selector.dart         # 【新規】ランダムセレクター
│
└── presentation/                          # UI
    ├── pages/
    │   ├── daily_topic_home.dart          # 【新規】メインホーム画面
    │   ├── home_aitopic.dart              # AI トピック生成画面（開発用）
    │   ├── home_topic.dart                # トピック表示画面（旧）
    │   ├── home.dart                      # ホーム画面（旧）
    │   └── home_answer.dart               # 回答画面（旧）
    └── widgets/
        └── topic_card.dart                # 【新規】トピックカードウィジェット
```

---

## セットアップ

### 1. APIキーの設定

`.env`ファイルを作成し、APIキーを設定してください：

```bash
# .envファイル（プロジェクトルート）
OPENAI_API_KEY=sk-your-openai-api-key-here
ANTHROPIC_API_KEY=sk-ant-your-anthropic-api-key-here
```

**注意**: `.env`ファイルは`.gitignore`に含まれているため、Gitにコミットされません。

### 2. APIキーの取得方法

#### OpenAI API
1. [OpenAI Platform](https://platform.openai.com/)にアクセス
2. アカウントを作成（または既存アカウントでログイン）
3. [API Keys](https://platform.openai.com/api-keys)ページで新しいAPIキーを作成
4. キーをコピーして`.env`ファイルに設定

#### Anthropic API (Claude)
1. [Anthropic Console](https://console.anthropic.com/)にアクセス
2. アカウントを作成（または既存アカウントでログイン）
3. API Keysセクションで新しいAPIキーを作成
4. キーをコピーして`.env`ファイルに設定

### 3. パッケージのインストール

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Firebaseセキュリティルール設定

`firestore.rules`に以下を追加:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 日別トピック
    match /daily_topics/{date} {
      // 認証済みユーザーは読み取り可能
      allow read: if request.auth != null;

      // 認証済みユーザーは書き込み可能（アプリが自動生成するため）
      allow write: if request.auth != null;

      // 管理者のみ書き込み可能にする場合（オプション）
      // allow write: if request.auth != null &&
      //                 get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

---

## 使い方

### メインホーム画面（日別トピック）

#### 基本的な流れ
1. アプリを起動すると自動的に今日のトピックが読み込まれる
2. トピックが存在しない場合、AIが自動生成
3. トピックを読んで賛成/反対/中立を選択
4. 100〜3000文字で理由を記述
5. 「意見を投稿する」ボタンで投稿

#### 手動リロード
- アプリバーの更新ボタンで今日のトピックを再読み込み
- 既に今日のトピックがある場合は同じものが表示される

#### 強制再生成（開発・管理者用）
```dart
// プロバイダーから再生成
await ref.read(dailyTopicProvider.notifier).regenerateTopic();
```

### AI トピック生成画面（開発用）

#### ランダム生成
1. 「ランダムに生成」ボタンをタップ
2. AIが自動的にトピックを生成
3. カテゴリと難易度は自動判定

#### カテゴリ指定生成
1. 日常系・社会問題系・価値観系のボタンから選択
2. 選択したカテゴリに適したトピックが生成

#### AIプロバイダーの切り替え
- 右上の設定アイコンから OpenAI または Claude を選択
- それぞれの特性に応じたトピック生成が可能

---

## アーキテクチャ

### データフロー（日別トピック）

```
1. アプリ起動
   ↓
2. DailyTopicNotifier 初期化
   ↓
3. loadTodayTopic() 実行
   ↓
4. DailyTopicRepository.getTodayTopic()
   ├── トピックが存在 → 表示
   └── トピックが存在しない
       ↓
       5. RandomTopicSelector でカテゴリー・難易度を決定
       ↓
       6. TopicGenerationService で AI にトピック生成を依頼
       ↓
       7. Topic オブジェクト作成
       ↓
       8. DailyTopicRepository.saveTodayTopic() で Firestore に保存
       ↓
       9. 状態更新 → 画面表示
```

### 主要クラス

#### DailyTopicRepository
日別トピックのFirestore操作を管理

**主なメソッド:**
```dart
Future<Topic?> getTodayTopic()              // 今日のトピックを取得
Future<void> saveTodayTopic(Topic topic)    // 今日のトピックを保存
Future<bool> hasTodayTopic()                // 今日のトピックが存在するか確認
Future<List<Topic>> getRecentTopics()       // 過去のトピック履歴を取得
```

**Firestoreコレクション構造:**
```
daily_topics/
  └── {YYYY-MM-DD}/
      ├── id: string
      ├── text: string
      ├── category: string ('daily' | 'social' | 'value')
      ├── difficulty: string ('easy' | 'medium' | 'hard')
      ├── createdAt: timestamp
      ├── source: string ('ai' | 'manual')
      ├── tags: array<string>
      └── description: string? (オプション)
```

#### RandomTopicSelector
カテゴリーと難易度をランダムに選択

**確率分布のカスタマイズ:**
```dart
final selector = RandomTopicSelector();

// デフォルトの確率で選択
final selection = selector.selectRandom();
// -> category: TopicCategory, difficulty: TopicDifficulty

// カスタム確率で選択
final category = selector.selectCategoryWithWeights([0.5, 0.3, 0.2]);
final difficulty = selector.selectDifficultyWithWeights([0.3, 0.4, 0.3]);
```

#### DailyTopicNotifier
日別トピックの状態管理

**状態:**
```dart
class DailyTopicState {
  Topic? currentTopic;     // 現在のトピック
  bool isLoading;          // 読み込み中
  bool isGenerating;       // 生成中
  String? error;           // エラーメッセージ
}
```

**主なメソッド:**
```dart
Future<void> loadTodayTopic()      // 今日のトピックを読み込み
Future<void> generateNewTopic()    // 新しいトピックを強制生成
Future<void> regenerateTopic()     // トピックを再生成
void clearError()                  // エラーをクリア
```

#### TopicCard
トピックを表示する再利用可能なウィジェット

**使用例:**
```dart
TopicCard(
  topic: myTopic,
  dateText: '今日のトピック', // オプション
)
```

**特徴:**
- カテゴリーごとに異なる色（緑=日常系、青=社会問題系、オレンジ=価値観系）
- 難易度バッジ表示（青緑=簡単、黄色=中程度、赤=難しい）
- AI生成バッジ表示
- タグ表示
- カスタマイズ可能な日付テキスト

### 使用技術

- **状態管理**: Riverpod 3.0
- **不変データ**: Freezed
- **HTTP通信**: http パッケージ
- **環境変数**: flutter_dotenv
- **UUID生成**: uuid
- **データベース**: Cloud Firestore
- **ルーティング**: go_router

---

## トラブルシューティング

### トピックが生成されない

1. `.env`ファイルにAPIキーが正しく設定されているか確認
2. APIキーが有効か確認（課金設定など）
3. Firebaseプロジェクトの設定を確認
4. インターネット接続を確認
5. API利用制限（レート制限）に達していないか確認
6. コンソールでエラーログを確認

### 同じトピックが何度も表示される

**これは正常な動作です！**
- 1日1回のみ新しいトピックが生成されます
- 日付が変わるまで同じトピックが表示されます
- 強制的に再生成したい場合は、アプリバーのリフレッシュボタンを使用

### APIエラーが発生する場合

1. APIキーの有効性を確認
2. APIの利用制限を確認
3. リクエストレート制限を確認
4. ネットワークエラーの場合は接続を確認

### ビルドエラーが発生する場合

```bash
# キャッシュをクリアして再ビルド
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firestore接続エラー

1. Firebaseプロジェクトの設定を確認
2. `google-services.json`（Android）と`GoogleService-Info.plist`（iOS）が正しく配置されているか確認
3. Firestoreのセキュリティルールを確認
4. Firebase Consoleでプロジェクトが有効化されているか確認

### 重複検出が正しく動作しない場合

類似度の閾値を調整: `TopicDuplicateDetector`の`isDuplicate`メソッドの`threshold`パラメータ（デフォルト0.8）

---

## コード例

### 日別トピックの取得

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyarekyara/feature/home/providers/daily_topic_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyTopicProvider);
    final notifier = ref.read(dailyTopicProvider.notifier);

    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    if (state.error != null) {
      return Text('エラー: ${state.error}');
    }

    if (state.currentTopic != null) {
      return TopicCard(topic: state.currentTopic!);
    }

    return ElevatedButton(
      onPressed: () => notifier.generateNewTopic(),
      child: Text('トピックを生成'),
    );
  }
}
```

### 過去のトピックを取得

```dart
final repository = ref.read(dailyTopicRepositoryProvider);
final recentTopics = await repository.getRecentTopics(limit: 30);

for (final topic in recentTopics) {
  print('${topic.createdAt}: ${topic.text}');
}
```

### AIプロバイダーの切り替え

`daily_topic_provider.dart`の44行目:
```dart
// OpenAI を使用
final aiRepository = AIRepositoryFactory.create(AIProvider.openai);

// または Claude を使用
final aiRepository = AIRepositoryFactory.create(AIProvider.claude);
```

---

## 今後の拡張予定

### 日別トピック機能
- [ ] トピックのお気に入り機能
- [ ] ユーザーがトピックをリクエストできる機能
- [ ] トピックの共有機能（SNS連携）
- [ ] 過去のトピック一覧表示
- [ ] トピックに対する意見の集計・分析
- [ ] プッシュ通知での新トピック通知（朝9時など）
- [ ] トピックの難易度フィルター
- [ ] カテゴリー別のトピック表示

### AI生成機能
- [ ] カスタムプロンプト機能
- [ ] バッチ生成機能（複数トピックを一括生成）
- [ ] 多言語対応
- [ ] トピック生成履歴の永続化
- [ ] ユーザー設定の永続化
- [ ] A/Bテスト用の複数トピック生成

---

## 参考リンク

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod ドキュメント](https://riverpod.dev/)
- [Freezed ドキュメント](https://pub.dev/packages/freezed)
- [Cloud Firestore ドキュメント](https://firebase.google.com/docs/firestore)
- [Go Router ドキュメント](https://pub.dev/packages/go_router)
- [OpenAI API ドキュメント](https://platform.openai.com/docs/)
- [Anthropic API ドキュメント](https://docs.anthropic.com/)

---

## ライセンス

このプロジェクトの一部です。

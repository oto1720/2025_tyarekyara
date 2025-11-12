# Home機能 - AIトピック生成とディスカッション

AIを活用した1日1回のトピック自動生成とディスカッション機能を提供するモジュールです。

## 目次

1. [機能概要](#機能概要)
2. [日別トピック機能（新規）](#日別トピック機能新規)
3. [意見投稿・一覧機能（新規）](#意見投稿一覧機能新規)
4. [AIトピック生成機能](#aiトピック生成機能)
5. [ディレクトリ構成](#ディレクトリ構成)
6. [セットアップ](#セットアップ)
7. [使い方](#使い方)
8. [アーキテクチャ](#アーキテクチャ)
9. [トラブルシューティング](#トラブルシューティング)

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

### 意見投稿・一覧機能（新規）

**トピックに対する意見の投稿・閲覧・編集機能** - ユーザーが各トピックに対して自分の意見を投稿し、他のユーザーの意見を閲覧できる機能

#### 特徴
- ✅ **1トピック1投稿制限**: 各ユーザーは1つのトピックに対して1回のみ意見を投稿可能
- ✅ **立場表明**: 賛成/反対/中立の3つの立場から選択
- ✅ **自動遷移**: 投稿完了後、自動的に意見一覧画面に遷移
- ✅ **統計表示**: 立場別の意見数と割合をリアルタイムで表示
- ✅ **編集機能**: 自分の投稿を後から編集可能
- ✅ **Firestore連携**: 全ての意見はFirestoreにリアルタイムで保存

#### 意見の投稿フロー
1. **トピック表示**: 今日のトピックを確認
2. **立場選択**: 賛成/反対/中立から選択
3. **意見入力**: 100〜500文字で意見を記述
4. **投稿確認**: ダイアログで確認
5. **自動遷移**: 投稿完了後、意見一覧画面へ自動遷移

#### 意見一覧画面の機能
- **トピック情報**: トップにトピックカードを表示
- **統計情報**: 賛成/反対/中立の数と割合を可視化
- **意見カード**: 各意見を立場別の色分けで表示
- **自分の投稿リンク**: 右上アイコンから自分の投稿詳細へアクセス
- **リフレッシュ**: 最新の意見を取得
- **日付選択機能**: 過去の日付のトピックと意見を閲覧可能（下記参照）

#### 意見編集機能
- **閲覧モード**: 自分の投稿内容を確認
- **編集モード**: 立場と意見内容を変更可能
- **リアルタイム更新**: 編集後すぐに意見一覧に反映

#### 日付選択機能（履歴閲覧）
意見一覧画面で過去の日付のトピックと意見を閲覧できる機能

##### 特徴
- ✅ **過去のトピック閲覧**: 過去に生成されたトピックを日付指定で閲覧
- ✅ **過去の意見閲覧**: その日のトピックに投稿された全ての意見を表示
- ✅ **直感的なUI**: 前日/翌日ボタンとカレンダーピッカーで簡単操作
- ✅ **今日への制限**: 未来の日付には移動できない
- ✅ **エラーハンドリング**: トピックが存在しない日は適切なメッセージを表示

##### 操作方法
1. **前日へ移動**: AppBarの「←」ボタンをタップ
2. **翌日へ移動**: AppBarの「→」ボタンをタップ（今日より先には進めない）
3. **カレンダーで選択**: AppBarの日付表示（例: 11/12 (火)）をタップしてDatePickerを開く
4. **日付を選択**: カレンダーから任意の日付を選択（2020年1月1日〜今日まで）

##### UI構成
```
AppBar
┌────────────────────────────────────────┐
│ [←] 11/12 (火) 📅 [→]     [更新]     │
└────────────────────────────────────────┘
     ↑       ↑      ↑     ↑
     |       |      |     |
  前の日  日付表示  次の日  リフレッシュ
         (タップで
         カレンダー)
```

##### 表示される内容
- **トピックカード**: 選択した日のトピック情報
- **統計情報**: その日のトピックへの意見の統計（賛成/反対/中立）
- **意見一覧**: その日のトピックに投稿された全ての意見
- **空の状態**: トピックが存在しない日は「この日のトピックはまだ作成されていません」と表示

##### 技術的な詳細
| コンポーネント | 説明 |
|--------------|------|
| selectedDateProvider | 現在選択中の日付を管理するNotifierProvider |
| topicByDateProvider | 指定した日付のトピックを取得するFutureProvider.family |
| SelectedDateNotifier | 日付の状態を管理し、setDate()メソッドで更新 |
| DateFormat | intlパッケージを使用した日付フォーマット（M/d (E)形式） |

##### 日付の制限
- **最古の日付**: 2020年1月1日（変更可能）
- **最新の日付**: 今日（動的に変更）
- **未来の日付**: 選択不可（DatePickerとボタンで制御）

#### データ構造
| フィールド | 型 | 説明 |
|-----------|------|------|
| id | String | 意見の一意なID（UUID） |
| topicId | String | 関連するトピックのID |
| topicText | String | トピックの本文 |
| userId | String | 投稿者のユーザーID |
| userName | String | 投稿者の表示名 |
| stance | OpinionStance | 立場（agree/disagree/neutral） |
| content | String | 意見の内容（100〜500文字） |
| createdAt | DateTime | 投稿日時 |
| likeCount | int | いいね数（デフォルト0） |
| isDeleted | bool | 論理削除フラグ |

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
│   ├── opinion.dart                       # 【新規】意見モデル（Freezed）
│   ├── opinion.freezed.dart
│   └── opinion.g.dart
│
├── repositories/                          # データ永続化・外部API
│   ├── ai_repository.dart                 # AI API（OpenAI/Claude）
│   ├── daily_topic_repository.dart        # 【新規】日別トピック Firestore リポジトリ
│   └── opinion_repository.dart            # 【新規】意見 Firestore リポジトリ
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
│   ├── opinion_provider.dart              # 【新規】意見投稿・一覧状態管理
│   ├── opinion_provider.freezed.dart
│   ├── topic_generation_provider.dart     # トピック生成プロバイダー
│   ├── topic_generation_state.dart        # トピック生成状態
│   └── topic_generation_state.freezed.dart
│
├── utils/                                 # ユーティリティ
│   └── random_topic_selector.dart         # 【新規】ランダムセレクター
│
└── presentation/                          # UI
    ├── pages/
    │   ├── daily_topic_home.dart          # 【新規】メインホーム画面（意見投稿機能含む）
    │   ├── home_answer.dart               # 【新規】意見一覧画面（日付選択機能含む）
    │   ├── my_opinion_detail.dart         # 【新規】自分の投稿詳細・編集画面
    │   ├── home_aitopic.dart              # AI トピック生成画面（開発用）
    │   ├── home_topic.dart                # トピック表示画面（旧）
    │   └── home.dart                      # ホーム画面（旧）
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

    // 意見（Opinion）
    match /opinions/{opinionId} {
      // 認証済みユーザーは全ての意見を読み取り可能
      allow read: if request.auth != null;

      // 新規作成: 認証済みユーザーのみ可能
      allow create: if request.auth != null &&
                       request.resource.data.userId == request.auth.uid &&
                       request.resource.data.keys().hasAll(['id', 'topicId', 'topicText', 'userId', 'userName', 'stance', 'content', 'createdAt', 'likeCount', 'isDeleted']);

      // 更新: 自分の投稿のみ可能（stance と content のみ変更可能）
      allow update: if request.auth != null &&
                       resource.data.userId == request.auth.uid &&
                       request.resource.data.userId == resource.data.userId &&
                       request.resource.data.id == resource.data.id &&
                       request.resource.data.topicId == resource.data.topicId;

      // 削除: 自分の投稿のみ論理削除可能
      allow delete: if request.auth != null &&
                       resource.data.userId == request.auth.uid;
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

### 意見投稿機能

#### 意見を投稿する
1. **ホーム画面でトピックを確認**: 今日のトピックが自動的に表示される
2. **立場を選択**: 賛成/反対/中立から1つを選択
3. **意見を入力**: テキストフィールドに100〜500文字で意見を記述
4. **投稿ボタンをタップ**: 確認ダイアログが表示される
5. **確認**: 「投稿する」をタップ
6. **自動遷移**: 投稿完了後、自動的に意見一覧画面に移動

#### 意見一覧を見る
- **自動遷移**: 投稿完了後に自動的に意見一覧画面が開く
- **手動アクセス**: ホーム画面から「みんなの意見を見る」ボタンをタップ
- **統計確認**: 賛成/反対/中立の数と割合を確認
- **意見閲覧**: 他のユーザーの意見をスクロールして閲覧
- **リフレッシュ**: 右上の更新ボタンで最新の意見を取得

#### 過去の意見を見る（日付選択機能）
1. **意見一覧画面を開く**: 投稿後の自動遷移、またはホーム画面から手動でアクセス
2. **前日へ移動**: AppBarの左矢印「←」ボタンをタップして前日のトピックと意見を表示
3. **翌日へ移動**: AppBarの右矢印「→」ボタンをタップして翌日のトピックと意見を表示
   - 今日より先には進めない（ボタンが無効化される）
4. **カレンダーで選択**:
   - AppBarの日付表示（例: 11/12 (火)）をタップ
   - カレンダーピッカーが開く
   - 任意の日付を選択（2020年1月1日〜今日まで）
   - 選択した日のトピックと意見が表示される
5. **今日に戻る**: 右矢印を連続でタップ、またはカレンダーから今日を選択

#### 自分の意見を編集する
1. **意見一覧画面を開く**: 投稿後に自動遷移、または手動でアクセス
2. **自分の投稿アイコンをタップ**: 右上のノートアイコン（投稿済みの場合のみ表示）
3. **編集ボタンをタップ**: 右上の「編集」ボタン
4. **内容を変更**: 立場や意見内容を修正
5. **更新ボタンをタップ**: 確認後、変更が保存される
6. **自動反映**: 意見一覧に即座に反映される

#### 制限事項
- **1トピック1投稿**: 各トピックに対して1回のみ投稿可能
- **編集は何度でも可能**: 投稿後も自由に編集できる
- **文字数制限**: 100〜500文字（空白は除く）

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

### データフロー（意見投稿）

```
1. ユーザーが意見を入力
   ↓
2. 「投稿する」ボタンをタップ
   ↓
3. OpinionPostNotifier.postOpinion() 実行
   ↓
4. Opinion オブジェクト作成（UUID生成）
   ↓
5. OpinionRepository.postOpinion() で Firestore に保存
   ├── コレクション: opinions/{opinionId}
   └── フィールド: id, topicId, userId, stance, content, etc.
   ↓
6. hasPosted フラグを true に更新
   ↓
7. WidgetsBinding で画面遷移を実行
   ↓
8. 意見一覧画面（/opinions/:topicId）に自動遷移
   ↓
9. OpinionListNotifier.loadOpinions() で全意見を取得
   ↓
10. 統計情報を計算（立場別カウント）
   ↓
11. 画面に表示
```

### 主要クラス

#### OpinionRepository
意見のFirestore操作を管理

**主なメソッド:**
```dart
Future<void> postOpinion(Opinion opinion)                    // 意見を投稿
Future<List<Opinion>> getOpinionsByTopic(String topicId)     // トピックの全意見を取得
Future<Map<OpinionStance, int>> getOpinionCountsByStance()   // 立場別カウント取得
Future<Opinion?> getUserOpinion(String topicId, String uid)  // ユーザーの意見を取得
Future<bool> hasUserPostedOpinion(String topicId, String uid)// 投稿済みか確認
Future<void> updateOpinion(String id, stance, content)       // 意見を更新
Future<void> deleteOpinion(String opinionId)                 // 意見を削除（論理削除）
Stream<List<Opinion>> watchOpinionsByTopic(String topicId)   // リアルタイム取得
```

**Firestoreコレクション構造:**
```
opinions/
  └── {opinionId}/
      ├── id: string (UUID)
      ├── topicId: string
      ├── topicText: string
      ├── userId: string
      ├── userName: string
      ├── stance: string ('agree' | 'disagree' | 'neutral')
      ├── content: string
      ├── createdAt: timestamp
      ├── likeCount: number (デフォルト: 0)
      └── isDeleted: boolean (デフォルト: false)
```

#### OpinionPostNotifier
意見投稿の状態管理

**状態:**
```dart
class OpinionPostState {
  bool isPosting;          // 投稿中
  bool hasPosted;          // 投稿済みフラグ
  String? error;           // エラーメッセージ
  Opinion? userOpinion;    // ユーザーが投稿した意見
}
```

**主なメソッド:**
```dart
Future<void> checkUserOpinion()              // ユーザーの投稿を確認
Future<bool> postOpinion(...)                // 意見を投稿
Future<bool> updateOpinion(stance, content)  // 意見を更新
void clearError()                            // エラーをクリア
```

#### OpinionListNotifier
意見一覧の状態管理

**状態:**
```dart
class OpinionListState {
  List<Opinion> opinions;                   // 意見一覧
  bool isLoading;                          // 読み込み中
  String? error;                           // エラーメッセージ
  Map<OpinionStance, int> stanceCounts;    // 立場別カウント
}
```

**主なメソッド:**
```dart
Future<void> loadOpinions()    // 意見一覧を読み込み
Future<void> refresh()         // リフレッシュ
void clearError()              // エラーをクリア
```

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

#### SelectedDateNotifier
日付選択の状態管理（意見一覧画面での履歴閲覧用）

**状態:**
```dart
DateTime  // 現在選択中の日付（初期値: 今日）
```

**主なメソッド:**
```dart
void setDate(DateTime date)  // 日付を設定
```

**関連プロバイダー:**
```dart
// 選択中の日付を管理
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

// 指定した日付のトピックを取得
final topicByDateProvider = FutureProvider.family<Topic?, DateTime>((ref, date) async {
  final repository = ref.watch(dailyTopicRepositoryProvider);
  return await repository.getTopicByDate(date);
});
```

**使用例:**
```dart
// 日付を取得
final selectedDate = ref.watch(selectedDateProvider);

// 日付を変更
ref.read(selectedDateProvider.notifier).setDate(DateTime(2024, 11, 12));

// 選択した日付のトピックを取得
final topicAsync = ref.watch(topicByDateProvider(selectedDate));
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
- **UUID生成**: uuid（意見IDの生成に使用）
- **データベース**: Cloud Firestore
- **ルーティング**: go_router
- **認証**: Firebase Authentication
- **日付フォーマット**: intl パッケージ（日付選択機能で使用）

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

### 意見が投稿できない場合

1. **認証状態を確認**: ユーザーがログインしているか確認
2. **Firestoreのセキュリティルール**: `opinions`コレクションのルールが正しく設定されているか確認
3. **ネットワーク接続**: インターネット接続を確認
4. **エラーメッセージ**: コンソールで詳細なエラーログを確認
5. **投稿済みフラグ**: 既に投稿済みの場合は再投稿できない（編集機能を使用）

### 意見一覧が表示されない場合

1. **トピックID**: 正しいトピックIDが渡されているか確認
2. **Firestore接続**: Firestoreに正しく接続されているか確認
3. **データ存在確認**: Firebase Consoleで`opinions`コレクションにデータが存在するか確認
4. **セキュリティルール**: 読み取り権限が正しく設定されているか確認

### 意見が編集できない場合

1. **所有権確認**: 自分の投稿のみ編集可能
2. **hasPostedフラグ**: `hasPosted`が`true`であることを確認
3. **userOpinion**: `postState.userOpinion`が`null`でないことを確認
4. **セキュリティルール**: 更新権限が正しく設定されているか確認

### 自動遷移が動作しない場合

1. **ルーティング設定**: `/opinions/:topicId`のルートが正しく設定されているか確認
2. **go_router**: `go_router`パッケージが正しくインストールされているか確認
3. **hasPosted**: 投稿後に`hasPosted`が`true`に更新されているか確認
4. **context.go()**: `WidgetsBinding.instance.addPostFrameCallback`が正しく呼ばれているか確認

### 日付選択機能が動作しない場合

1. **DatePicker エラー**:
   - `MaterialLocalizations`エラーが発生した場合は、`showDatePicker`の`locale`パラメータを削除
   - アプリ全体のローカライゼーション設定を確認

2. **日付が変更されない**:
   - `selectedDateProvider.notifier.setDate()`が正しく呼ばれているか確認
   - Riverpod DevToolsで状態の変更を確認

3. **過去のトピックが表示されない**:
   - `topicByDateProvider`が正しく動作しているか確認
   - Firestoreの`daily_topics`コレクションにデータが存在するか確認（日付キー: YYYY-MM-DD形式）
   - `DailyTopicRepository.getTopicByDate()`メソッドが正しく実装されているか確認

4. **カレンダーが開かない**:
   - `showDatePicker`が正しく呼ばれているか確認
   - `context`が有効か確認
   - エラーログを確認

5. **日付フォーマットが表示されない**:
   - `intl`パッケージがインストールされているか確認: `flutter pub get`
   - `DateFormat`のインポートが正しいか確認: `import 'package:intl/intl.dart';`

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

### 意見を投稿する

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyarekyara/feature/home/providers/opinion_provider.dart';
import 'package:tyarekyara/feature/home/models/opinion.dart';

class OpinionFormWidget extends ConsumerWidget {
  final String topicId;
  final String topicText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(opinionPostProvider(topicId));
    final postNotifier = ref.read(opinionPostProvider(topicId).notifier);

    return ElevatedButton(
      onPressed: postState.isPosting ? null : () async {
        final success = await postNotifier.postOpinion(
          topicText: topicText,
          stance: OpinionStance.agree,
          content: 'これは私の意見です...',
        );

        if (success) {
          // 投稿成功 - 自動的に意見一覧画面に遷移
          print('投稿完了！');
        } else {
          // エラー処理
          print('エラー: ${postState.error}');
        }
      },
      child: Text(postState.isPosting ? '投稿中...' : '意見を投稿'),
    );
  }
}
```

### 意見一覧を表示する

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyarekyara/feature/home/providers/opinion_provider.dart';

class OpinionListWidget extends ConsumerWidget {
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(opinionListProvider(topicId));

    if (listState.isLoading) {
      return CircularProgressIndicator();
    }

    if (listState.error != null) {
      return Text('エラー: ${listState.error}');
    }

    return ListView.builder(
      itemCount: listState.opinions.length,
      itemBuilder: (context, index) {
        final opinion = listState.opinions[index];
        return ListTile(
          title: Text(opinion.userName),
          subtitle: Text(opinion.content),
          leading: Icon(
            opinion.stance == OpinionStance.agree
                ? Icons.thumb_up
                : opinion.stance == OpinionStance.disagree
                    ? Icons.thumb_down
                    : Icons.horizontal_rule,
          ),
        );
      },
    );
  }
}
```

### 意見を編集する

```dart
final postNotifier = ref.read(opinionPostProvider(topicId).notifier);

final success = await postNotifier.updateOpinion(
  stance: OpinionStance.neutral,
  content: '意見を変更しました...',
);

if (success) {
  print('更新完了！');
  // 意見一覧を更新
  ref.read(opinionListProvider(topicId).notifier).refresh();
}
```

### 投稿済みかチェックする

```dart
final postState = ref.watch(opinionPostProvider(topicId));

if (postState.hasPosted) {
  print('既に投稿済みです');
  print('あなたの立場: ${postState.userOpinion?.stance.displayName}');
} else {
  print('まだ投稿していません');
}
```

### 日付選択機能を使用する

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tyarekyara/feature/home/providers/daily_topic_provider.dart';

class DateSelectorWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final topicAsync = ref.watch(topicByDateProvider(selectedDate));

    return Column(
      children: [
        // 日付表示
        Text(
          DateFormat('M/d (E)', 'ja').format(selectedDate),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        // 前日へ移動
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            final previousDay = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day - 1,
            );
            ref.read(selectedDateProvider.notifier).setDate(previousDay);
          },
        ),

        // トピック表示
        topicAsync.when(
          data: (topic) {
            if (topic == null) {
              return Text('この日のトピックはありません');
            }
            return TopicCard(topic: topic);
          },
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => Text('エラー: $error'),
        ),
      ],
    );
  }
}
```

### カレンダーピッカーで日付を選択する

```dart
Future<void> _showDatePicker(BuildContext context, WidgetRef ref) async {
  final currentDate = ref.read(selectedDateProvider);
  final today = DateTime.now();

  final selectedDate = await showDatePicker(
    context: context,
    initialDate: currentDate,
    firstDate: DateTime(2020, 1, 1),
    lastDate: today,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue.shade600,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      );
    },
  );

  if (selectedDate != null) {
    ref.read(selectedDateProvider.notifier).setDate(selectedDate);
  }
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
- [ ] プッシュ通知での新トピック通知（朝9時など）
- [ ] トピックの難易度フィルター
- [ ] カテゴリー別のトピック表示

### 意見投稿・一覧機能
- [x] 日付選択機能（過去の意見閲覧） - **完成**
- [ ] いいね機能の実装（現在はモデルのみ）
- [ ] コメント機能（意見に対する返信）
- [ ] 意見の検索・フィルター機能
- [ ] 立場別の意見ソート
- [ ] 人気の意見ランキング
- [ ] 意見の共有機能（SNS連携）
- [ ] 通知機能（自分の意見にいいねが付いた時など）
- [ ] ブックマーク機能
- [ ] レポート機能（不適切な投稿の報告）
- [ ] 意見の履歴表示（自分の過去の投稿一覧）
- [ ] AIによる意見分析・要約機能
- [ ] 議論の可視化（立場の分布グラフなど）
- [ ] 日付選択機能の拡張（月別カレンダービュー）
- [ ] 日付選択機能の拡張（週別ビュー）

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

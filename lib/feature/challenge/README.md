# Challenge Feature（視点交換チャレンジ）

## 概要

Challenge機能は、自分とは反対の立場で意見を考えることで多角的な思考力を養うトレーニング機能です。

**ユーザーが過去にホーム画面で投稿した意見**とは反対の立場から新たな意見を考えるチャレンジを提供し、以下のスキルを育成します：

- 多角的な視点での物事の捉え方
- 論理的思考力
- 共感力と理解力
- 説得力のある文章作成能力

### 重要な変更点（2025-11-08）

従来のダミーデータではなく、**ユーザーが実際にホーム画面で投稿した意見**をチャレンジのデータソースとして使用するようになりました。これにより、自分自身の意見に対して反対の立場で考える、より実践的なトレーニングが可能になります。

## ディレクトリ構造

```
lib/feature/challenge/
├── README.md                               # このファイル
├── REFACTORING_GUIDE.md                    # リファクタリングガイド
├── models/
│   ├── challenge_model.dart                # チャレンジデータモデル（Freezed）
│   ├── challenge_model.freezed.dart        # Freezed生成ファイル
│   ├── challenge_model.g.dart              # json_serializable生成ファイル
│   ├── challenge_state.dart                # 状態モデル（Freezed）
│   └── challenge_state.freezed.dart        # Freezed生成ファイル
├── providers/
│   └── challenge_provider.dart             # 状態管理（Riverpod）
├── repositories/
│   └── challenge_repositories.dart         # データアクセス層（Firestore）
├── services/
│   └── feedback_service.dart               # AIフィードバック生成サービス
└── presentaion/
    ├── pages/
    │   ├── challenge.dart                  # チャレンジ一覧画面
    │   ├── challenge_detail.dart           # チャレンジ詳細・回答画面
    │   └── challenge_feedback_page.dart    # フィードバック表示画面
    └── widgets/
        ├── challenge_card.dart             # 挑戦可能チャレンジカード
        ├── completed_challenge_card.dart   # 完了済みチャレンジカード
        └── difficultry_budge.dart          # 難易度バッジ
```

## アーキテクチャ

### レイヤー構成

```
┌─────────────────────────────────────────┐
│  Presentation Layer (UI)                │
│  - pages/: 画面                          │
│  - widgets/: 再利用可能なUIコンポーネント  │
└──────────────┬──────────────────────────┘
               │ 参照
┌──────────────▼──────────────────────────┐
│  Provider Layer (状態管理)               │
│  - challenge_provider.dart              │
│  - ChallengeNotifier                    │
│  - フィルタ・ポイント管理プロバイダー      │
└──────────────┬──────────────────────────┘
               │ 使用
┌──────────────▼──────────────────────────┐
│  Repository Layer (データアクセス)        │
│  - challenge_repositories.dart          │
│  - ChallengeRepository                  │
└──────────────┬──────────────────────────┘
               │ アクセス
┌──────────────▼──────────────────────────┐
│  Data Layer                             │
│  - Firestore (userChallenges)           │
│  - OpinionRepository (home feature)     │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Service Layer                          │
│  - feedback_service.dart                │
│  - AIRepository (home feature)          │
└─────────────────────────────────────────┘
```

### 依存関係グラフ

```
[Presentation Layer]
  challenge.dart ──────────┐
  challenge_detail.dart ───┼────> challengeProvider
  challenge_feedback_page.dart ──> (FeedbackService)
           │
           ▼
  challenge_card.dart
  completed_challenge_card.dart
  difficultry_budge.dart

[Provider Layer]
  challengeProvider ────────> ChallengeNotifier
      │                           │
      │                           ├──> challengeRepositoryProvider
      │                           │         │
      ▼                           │         ▼
  filteredChallengesProvider      │    ChallengeRepository
      │                           │         │
      ├──> challengeFilterProvider│         ├──> FirebaseFirestore
      └──> challengeProvider      │         └──> OpinionRepository (home)
                                  │
                                  ▼
                            currentPointsProvider
                                  │
                                  └──> CurrentPointsNotifier

[Service Layer]
  ChallengeFeedbackService ───> AIRepository (home feature)
```

## 主要なクラスとその役割

### 1. Models (データモデル)

#### Challenge (`lib/feature/challenge/models/challenge_model.dart`)

**責務**: チャレンジデータを表すイミュータブルなモデルクラス

**使用技術**: Freezed + json_serializable

**主要フィールド**:

```dart
@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required String id,                    // チャレンジID
    required String title,                 // チャレンジタイトル
    required Stance stance,                // 元の立場（pro/con）
    required ChallengeDifficulty difficulty, // 難易度
    required ChallengeStatus status,       // ステータス
    required String originalOpinionText,   // 元の意見
    String? oppositeOpinionText,           // 反対意見（完了時に入力）
    required String userId,                // ユーザーID
    DateTime? completedAt,                 // 完了日時
    int? earnedPoints,                     // 獲得ポイント
    String? opinionId,                     // 元の意見ID（ホーム機能との紐付け）
    String? feedbackText,                  // AIフィードバックテキスト
    int? feedbackScore,                    // フィードバックスコア（0-100）
    DateTime? feedbackGeneratedAt,         // フィードバック生成日時
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);
  factory Challenge.fromFirestore(DocumentSnapshot doc) { ... }
}
```

**ゲッターメソッド**:
- `isCompleted`: チャレンジが完了済みか判定
- `isAvailable`: チャレンジが挑戦可能か判定

**メソッド**:
- `toFirestore()`: FirestoreのMap形式に変換

**Enum定義**:

```dart
enum Stance {
  pro,  // 賛成
  con,  // 反対
}

enum ChallengeStatus {
  available,  // 挑戦可能
  completed,  // 完了済み
}

// ChallengeDifficultyはchallenge_provider.dartで拡張enumとして定義
```

#### ChallengeState (`lib/feature/challenge/models/challenge_state.dart`)

**責務**: チャレンジ一覧の状態を管理するStateクラス

**使用技術**: Freezed

```dart
@freezed
class ChallengeState with _$ChallengeState {
  const factory ChallengeState({
    @Default([]) List<Challenge> challenges,  // チャレンジ一覧
    @Default(false) bool isLoading,           // ローディング状態
    String? errorMessage,                     // エラーメッセージ
  }) = _ChallengeState;
}
```

### 2. Providers (状態管理)

**場所**: `lib/feature/challenge/providers/challenge_provider.dart`

#### challengeRepositoryProvider

```dart
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});
```

**責務**: ChallengeRepositoryのインスタンスを提供するDIコンテナ

#### ChallengeFilterNotifier & challengeFilterProvider

```dart
enum ChallengeFilter {
  available,  // 挑戦可能なチャレンジ
  completed,  // 完了済みチャレンジ
}

class ChallengeFilterNotifier extends Notifier<ChallengeFilter> {
  @override
  ChallengeFilter build() => ChallengeFilter.available;

  void setFilter(ChallengeFilter filter) {
    state = filter;
  }
}

final challengeFilterProvider = NotifierProvider<ChallengeFilterNotifier, ChallengeFilter>(() {
  return ChallengeFilterNotifier();
});
```

**責務**: チャレンジ一覧のフィルタ状態を管理（挑戦可能/完了済み）

#### CurrentPointsNotifier & currentPointsProvider

```dart
class CurrentPointsNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPoints(int points) {
    state = points;
  }

  void addPoints(int points) {
    state += points;
  }
}

final currentPointsProvider = NotifierProvider<CurrentPointsNotifier, int>(() {
  return CurrentPointsNotifier();
});
```

**責務**: ユーザーの累計獲得ポイントを管理

#### filteredChallengesProvider

```dart
final filteredChallengesProvider = Provider<List<Challenge>>((ref) {
  final state = ref.watch(challengeProvider);
  final filter = ref.watch(challengeFilterProvider);

  return state.challenges.where((challenge) {
    return filter == ChallengeFilter.available
        ? challenge.status == ChallengeStatus.available
        : challenge.status == ChallengeStatus.completed;
  }).toList();
});
```

**責務**: フィルタ状態に応じたチャレンジリストを提供
**依存**: `challengeProvider`, `challengeFilterProvider`

#### ChallengeNotifier & challengeProvider

```dart
class ChallengeNotifier extends AsyncNotifier<ChallengeState> {
  late final ChallengeRepository repository;

  @override
  Future<ChallengeState> build() async { ... }

  Future<void> _loadChallenges() async { ... }
  List<Challenge> _mergeChallenges(List<Challenge> baseChallenges, List<Challenge> completedChallenges) { ... }
  void setFilter(ChallengeFilter filter) { ... }
  Future<void> completeChallenge(String challengeId, String oppositeOpinion, int earnedPoints, ...) async { ... }
  Future<void> refresh() async { ... }
}

final challengeProvider = AsyncNotifierProvider<ChallengeNotifier, ChallengeState>(() {
  return ChallengeNotifier();
});
```

**責務**: チャレンジ機能のメイン状態管理クラス

**主要メソッド**:

1. **`build()`**: 初期化処理
   - ユーザーログイン確認
   - チャレンジデータの読み込み（`_loadChallenges()`呼び出し）

2. **`_loadChallenges()`**: チャレンジデータの取得とマージ
   ```
   Flow:
   1. repository.getChallengesFromUserOpinions(userId)
      → OpinionRepository経由でユーザーの意見を取得
      → 意見をチャレンジに変換（反対の立場）

   2. repository.getUserChallenges(userId)
      → Firestoreから完了済みチャレンジを取得

   3. _mergeChallenges(baseChallenges, completedChallenges)
      → ベースチャレンジと完了データをマージ（O(n+m)アルゴリズム）

   4. repository.getTotalEarnedPoints(userId)
      → 累計ポイントを計算
      → currentPointsProviderに反映

   5. ChallengeState(challenges: mergedList)を返却
   ```

3. **`_mergeChallenges()`**: チャレンジデータのマージ処理
   ```dart
   // 完了チャレンジをMapに変換（O(1)ルックアップ）
   final completedMap = <String, Challenge>{
     for (var c in completedChallenges) c.id: c
   };

   // ベースチャレンジと照合
   return baseChallenges.map((challenge) {
     final completed = completedMap[challenge.id];
     return completed ?? challenge;  // 完了データがあれば置き換え
   }).toList();
   ```

4. **`completeChallenge()`**: チャレンジ完了処理
   ```
   Flow:
   1. 現在の状態から該当チャレンジを検索
   2. 完了データで更新（楽観的UI更新）
      - status: completed
      - oppositeOpinionText: ユーザー入力
      - completedAt: 現在時刻
      - earnedPoints: ポイント
      - feedbackText, feedbackScore (オプション)
   3. ローカル状態を即座に更新
   4. currentPointsProviderにポイント加算
   5. Firestoreへ非同期保存（repository.saveUserChallenge）
   6. エラー時はロールバック
   ```

5. **`refresh()`**: データの再読み込み

**依存関係**:
- `ChallengeRepository`: データ取得・保存
- `currentPointsProvider`: ポイント管理

### 3. Repository Layer (データアクセス)

#### ChallengeRepository (`lib/feature/challenge/repositories/challenge_repositories.dart`)

**責務**: Firestoreとのデータ通信、およびOpinionRepositoryとの連携

**依存関係**:
- `cloud_firestore`: Firestoreアクセス
- `OpinionRepository` (home feature): ユーザーの投稿意見を取得

**主要メソッド**:

1. **`saveUserChallenge(Challenge challenge)`**
   - チャレンジデータをFirestoreに保存
   - ドキュメントID: `{userId}_{challengeId}`

2. **`getUserChallenges(String userId)`**
   - ユーザーのチャレンジ一覧を取得
   - 戻り値: `Future<List<Challenge>>`

3. **`getUserChallenge(String userId, String challengeId)`**
   - 特定のチャレンジを取得
   - 戻り値: `Future<Challenge?>`

4. **`updateChallengeStatus(...)`**
   - チャレンジのステータスを更新
   - パラメータ: userId, challengeId, status, oppositeOpinionText, earnedPoints

5. **`watchUserChallenges(String userId)`**
   - チャレンジ一覧をリアルタイム監視
   - 戻り値: `Stream<List<Challenge>>`

6. **`getCompletedChallengeCount(String userId)`**
   - 完了済みチャレンジ数を取得
   - 戻り値: `Future<int>`

7. **`getTotalEarnedPoints(String userId)`**
   - 累計獲得ポイントを取得
   - 戻り値: `Future<int>`

8. **`getChallengesFromUserOpinions(String userId)`** ⭐️ 重要
   - **ユーザーの投稿意見からチャレンジを生成**
   - OpinionRepository経由でopinionsコレクションから意見を取得
   - 各意見を反対の立場のチャレンジに変換
   - 戻り値: `Future<List<Challenge>>`

   ```
   Flow:
   1. _opinionRepository.getOpinionsByUser(userId)
      → ユーザーの投稿意見を全て取得

   2. 各意見に対して_opinionToChallenge()を呼び出し
      → OpinionオブジェクトをChallengeに変換

   3. チャレンジリストを返却
   ```

9. **`_opinionToChallenge(Opinion opinion)`**: 意見→チャレンジ変換
   - 意見の文字数から難易度を計算（`_calculateDifficulty`）
   - 元の立場とは反対の立場を設定（`_getOppositeStance`）
   - チャレンジIDを生成（opinionId + difficulty）

10. **`_calculateDifficulty(int textLength)`**: 難易度計算
    ```dart
    if (textLength < 100) return ChallengeDifficulty.easy;
    if (textLength < 200) return ChallengeDifficulty.normal;
    return ChallengeDifficulty.hard;
    ```

11. **`_getOppositeStance(OpinionStance stance)`**: 反対の立場を取得
    ```dart
    switch (stance) {
      case OpinionStance.agree:
        return Stance.con;  // 賛成 → 反対
      case OpinionStance.disagree:
        return Stance.pro;  // 反対 → 賛成
      case OpinionStance.neutral:
        return Stance.pro;  // 中立 → 賛成
    }
    ```

### 4. Service Layer

#### ChallengeFeedbackService (`lib/feature/challenge/services/feedback_service.dart`)

**責務**: AIを使ってチャレンジ回答に対するフィードバックを生成

**依存関係**:
- `AIRepository` (home feature): Gemini APIとの通信

**主要クラス**:

```dart
class FeedbackResult {
  final String feedbackText;  // フィードバックテキスト
  final int score;            // スコア（0-100）
}

class ChallengeFeedbackService {
  final AIRepository _aiRepository;

  Future<FeedbackResult> generateFeedback({
    required String topicTitle,
    required String originalOpinion,
    required Stance originalStance,
    required String challengeAnswer,
  }) async { ... }
}
```

**処理フロー**:

```
1. _buildPrompt()
   → AIに送信するプロンプトを構築
   → テーマ、元の意見、チャレンジ回答を含める
   → JSON形式で回答するように指示

2. _aiRepository.generateText()
   → Gemini APIにリクエスト送信
   → temperature: 0.7, maxTokens: 1000

3. _parseResponse()
   → AIの応答をパース
   → JSON形式を抽出（```json ... ``` 対応）
   → score, goodPoints, improvements, adviceを取得
   → FeedbackResultに整形して返却
   → パース失敗時は生レスポンスを返す（score: 50）
```

**フィードバック観点**:
1. 反対意見としての妥当性
2. 説得力（根拠・具体例）
3. 論理性

**スコアリング基準**:
- 80以上: 優秀
- 60-79: 良好
- 40-59: 普通
- 40未満: 要改善

### 5. Presentation Layer (UI)

**使用技術**: `HookConsumerWidget` + `flutter_hooks`
- すべてのページで状態管理にhooksを使用
- 自動リソース管理により`dispose()`メソッド不要
- 宣言的で簡潔なコード記述

#### ChallengePage (`lib/feature/challenge/presentaion/pages/challenge.dart`)

**責務**: チャレンジ一覧画面

**ウィジェットタイプ**: `HookConsumerWidget`

**主要機能**:
- タブ切り替え（挑戦可能/完了済み）
- 累計ポイント表示
- チャレンジカードのリスト表示
- 詳細画面への遷移

**使用プロバイダー**:
- `challengeProvider`: チャレンジデータ
- `filteredChallengesProvider`: フィルタ済みリスト
- `currentPointsProvider`: 累計ポイント
- `challengeFilterProvider`: フィルタ状態

**使用Hooks**:
- `useMemoized`: ShowcaseWidget用のGlobalKeyをメモ化

#### ChallengeDetailPage (`lib/feature/challenge/presentaion/pages/challenge_detail.dart`)

**責務**: チャレンジ詳細・回答画面

**ウィジェットタイプ**: `HookConsumerWidget`

**主要機能**:
- 元の意見表示
- 反対意見入力フォーム
- 文字数バリデーション（100文字以上）
- ヒント表示
- ゲストモード対応
- フィードバック生成オプション
- 完了処理

**使用Hooks**:
- `useMemoized`: FormのGlobalKeyをメモ化
- `useTextEditingController`: 入力フォームのコントローラー管理

**処理フロー**:
```
1. ユーザーが反対意見を入力（100文字以上必須）
2. 「完了」ボタン押下
3. （オプション）ChallengeFeedbackService.generateFeedback()
   → AIフィードバック生成
4. result = {
     'opinion': oppositeOpinionText,
     'points': difficulty.points,
     'feedbackText': feedbackText?,
     'feedbackScore': feedbackScore?,
   }
5. context.pop(result)
6. 呼び出し元でchallengeProvider.completeChallenge()
```

#### ChallengeFeedbackPage (`lib/feature/challenge/presentaion/pages/challenge_feedback_page.dart`)

**責務**: フィードバック表示画面

**ウィジェットタイプ**: `HookConsumerWidget`

**主要機能**:
- AIフィードバックの自動生成と表示
- スコア表示（0-100点）
- フィードバックテキスト表示
- チャレンジポイント表示
- 元の意見と回答の表示
- ローディング・エラー状態の管理

**使用Hooks**:
- `useState`: ローディング状態、フィードバックテキスト、スコア、エラーメッセージの管理
- `useEffect`: マウント時のフィードバック自動生成

**状態管理**:
```dart
final isLoading = useState(true);
final feedbackText = useState<String?>(null);
final feedbackScore = useState<int?>(null);
final errorMessage = useState<String?>(null);
```

#### Widgets

**ChallengeCard** (`challenge_card.dart`)
- 挑戦可能なチャレンジを表示
- 難易度バッジ、ポイント、タイトル、元の立場を表示
- タップで詳細画面へ遷移

**CompletedChallengeCard** (`completed_challenge_card.dart`)
- 完了済みチャレンジを表示
- 獲得ポイント、完了アイコン、回答テキストを表示
- 緑色の背景で視覚的に区別

**DifficultyBadge** (`difficultry_budge.dart`)
- 難易度を視覚的に表示
- 色分け: easy（緑）、normal（黄）、hard（赤）

## Firestoreデータ構造

### userChallenges コレクション

```
/userChallenges/{userId}_{challengeId}
  ├─ id: string                      // チャレンジID
  ├─ userId: string                  // ユーザーID
  ├─ title: string                   // チャレンジタイトル
  ├─ stance: string                  // 元の立場（pro/con）
  ├─ difficulty: string              // 難易度（easy/normal/hard）
  ├─ status: string                  // ステータス（available/completed）
  ├─ originalOpinionText: string     // 元の意見
  ├─ oppositeOpinionText: string?    // 反対意見（完了時のみ）
  ├─ earnedPoints: int?              // 獲得ポイント（完了時のみ）
  ├─ completedAt: Timestamp?         // 完了日時（完了時のみ）
  ├─ opinionId: string?              // 元の意見ID
  ├─ feedbackText: string?           // フィードバックテキスト
  ├─ feedbackScore: int?             // フィードバックスコア
  └─ feedbackGeneratedAt: Timestamp? // フィードバック生成日時
```

**ドキュメントID命名規則**: `{userId}_{challengeId}`
- ユーザーごとのクエリを効率化
- チャレンジIDで一意に識別

## 他のFeatureとの連携

### 1. Home Feature との連携

**依存関係**:
```
ChallengeRepository
  ├─> OpinionRepository (lib/feature/home/repositories/opinion_repository.dart)
  │     └─> getOpinionsByUser(userId)
  │           → ユーザーの投稿意見を全て取得
  │
  └─> AIRepository (lib/feature/home/repositories/ai_repository.dart)
        └─> ChallengeFeedbackServiceが使用
              → Gemini APIでフィードバック生成
```

**連携フロー**:

```
[チャレンジ生成]
1. ChallengePage表示
2. challengeProvider.build()
3. repository.getChallengesFromUserOpinions(userId)
4. OpinionRepository.getOpinionsByUser(userId)
   → Firestore: opinions コレクションから意見を取得
5. 各Opinionを_opinionToChallenge()でChallengeに変換
   - 意見の文字数から難易度を自動設定
   - 元の立場とは反対の立場でチャレンジを生成
6. チャレンジリストとして返却

[フィードバック生成]
1. ChallengeDetailPageで回答完了
2. ChallengeFeedbackService.generateFeedback()
3. AIRepository.generateText()
   → Gemini APIにプロンプト送信
4. AIの応答をパースしてFeedbackResultを返却
5. ChallengeFeedbackPageで表示
```

**データマッピング**:

| Opinion (home) | Challenge (challenge) |
|----------------|----------------------|
| id | opinionId |
| text | originalOpinionText |
| stance (agree) | stance (con) ← 反対 |
| stance (disagree) | stance (pro) ← 反対 |
| stance (neutral) | stance (pro) ← デフォルト |
| text.length | difficulty (自動計算) |

### 2. Statistics Feature との連携

**依存関係**:
```
StatisticsProvider (lib/feature/statistics/providers/statistics_provider.dart)
  └─> ChallengeRepository
        ├─> getCompletedChallengeCount(userId)
        │     → 完了済みチャレンジ数を取得
        └─> getTotalEarnedPoints(userId)
              → 累計獲得ポイントを取得
```

**連携フロー**:
```
[統計画面での表示]
1. StatisticsPage表示
2. statisticsProvider
3. ChallengeRepository.getCompletedChallengeCount()
   → 完了数を集計
4. ChallengeRepository.getTotalEarnedPoints()
   → 全チャレンジのearnedPointsを合計
5. 統計情報として表示
   - 完了チャレンジ数
   - 累計獲得ポイント
   - 達成率など
```

## データフロー詳細

### 1. アプリ起動時のデータ読み込み

```
[User]
  ↓ アプリ起動
[ChallengePage] (build)
  ↓ ref.watch(challengeProvider)
[ChallengeNotifier.build()]
  ↓ _loadChallenges()
[ChallengeRepository]
  ├─> getChallengesFromUserOpinions(userId)
  │     ↓ OpinionRepository.getOpinionsByUser()
  │     ↓ Firestore: opinions コレクション
  │     ↓ 各OpinionをChallengeに変換
  │     └─> List<Challenge> (ベースチャレンジ)
  │
  └─> getUserChallenges(userId)
        ↓ Firestore: userChallenges コレクション
        └─> List<Challenge> (完了チャレンジ)

[ChallengeNotifier._mergeChallenges()]
  ↓ ベースと完了データをマージ
  └─> List<Challenge> (マージ済み)

[ChallengeRepository.getTotalEarnedPoints()]
  ↓ 累計ポイント計算
[CurrentPointsNotifier.setPoints()]

[ChallengeState] 更新
  ↓
[UI] 反映
```

### 2. チャレンジ完了時のデータフロー

```
[User]
  ↓ チャレンジ選択
[ChallengeDetailPage]
  ↓ 反対意見を入力（100文字以上）
  ↓ 「完了」ボタン押下
  ↓ (オプション) ChallengeFeedbackService.generateFeedback()
  │   ↓ AIRepository.generateText()
  │   ↓ Gemini API
  │   └─> FeedbackResult
  ↓ context.pop(result)

[ChallengePage]
  ↓ result受け取り
  ↓ challengeProvider.notifier.completeChallenge()

[ChallengeNotifier]
  ├─> 楽観的UI更新（即座に状態変更）
  │   - status: completed
  │   - oppositeOpinionText: ユーザー入力
  │   - completedAt: now
  │   - earnedPoints: points
  │   - feedbackText, feedbackScore
  │
  ├─> currentPointsProvider.addPoints()
  │
  └─> repository.saveUserChallenge()
        ↓ Firestore: userChallenges/{userId}_{challengeId}
        └─> 保存完了

[UI] 即座に反映（楽観的更新）
```

### 3. フィルタ切り替え時のデータフロー

```
[User]
  ↓ タブ切り替え（挑戦可能 ⇔ 完了済み）
[ChallengePage]
  ↓ challengeFilterProvider.setFilter()
[ChallengeFilterNotifier]
  ↓ state更新
[filteredChallengesProvider]
  ↓ 再計算（challengeProvider, challengeFilterProviderを監視）
  ↓ challenges.where(filter条件)
  └─> List<Challenge> (フィルタ済み)
[UI] 反映
```

## 使用方法とコード例

### 1. チャレンジ一覧の表示

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final challengeState = ref.watch(challengeProvider);
  final challenges = ref.watch(filteredChallengesProvider);
  final currentPoints = ref.watch(currentPointsProvider);

  return challengeState.when(
    data: (_) => Column(
      children: [
        Text('累計ポイント: $currentPoints'),
        Expanded(
          child: ListView.builder(
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return challenge.isAvailable
                  ? ChallengeCard(challenge: challenge)
                  : CompletedChallengeCard(challenge: challenge);
            },
          ),
        ),
      ],
    ),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => Text('エラー: $error'),
  );
}
```

### 2. チャレンジ完了処理

```dart
Future<void> _handleCompleteChallenge(Challenge challenge, String oppositeOpinion) async {
  // フィードバック生成（オプション）
  FeedbackResult? feedback;
  try {
    final feedbackService = ChallengeFeedbackService();
    feedback = await feedbackService.generateFeedback(
      topicTitle: challenge.title,
      originalOpinion: challenge.originalOpinionText,
      originalStance: challenge.stance,
      challengeAnswer: oppositeOpinion,
    );
  } catch (e) {
    // フィードバック生成失敗時は続行
    print('フィードバック生成エラー: $e');
  }

  // チャレンジ完了
  await ref.read(challengeProvider.notifier).completeChallenge(
    challenge.id,
    oppositeOpinion,
    challenge.difficulty.points,
    feedbackText: feedback?.feedbackText,
    feedbackScore: feedback?.score,
  );

  // フィードバック画面へ遷移（フィードバックがある場合）
  if (feedback != null) {
    context.push('/challenge/${challenge.id}/feedback', extra: {
      'challenge': challenge,
      'feedback': feedback,
    });
  }
}
```

### 3. フィルタ切り替え

```dart
void _onTabChanged(int index) {
  final filter = index == 0
      ? ChallengeFilter.available
      : ChallengeFilter.completed;

  ref.read(challengeFilterProvider.notifier).setFilter(filter);
}
```

### 4. チャレンジデータの手動リフレッシュ

```dart
Future<void> _refreshChallenges() async {
  await ref.read(challengeProvider.notifier).refresh();
}
```

## ポイントシステム

### ポイント設定

難易度ごとにポイントが設定されています（`ChallengeDifficulty` enumで定義）:

```dart
enum ChallengeDifficulty {
  easy('簡単', Colors.green, 30),    // 30ポイント
  normal('普通', Colors.amber, 50),  // 50ポイント
  hard('難しい', Colors.red, 100);   // 100ポイント

  final String label;
  final Color color;
  final int points;
}
```

### 難易度の自動設定

ユーザーの投稿意見の文字数に応じて自動設定:

```dart
ChallengeDifficulty _calculateDifficulty(int textLength) {
  if (textLength < 100) return ChallengeDifficulty.easy;
  if (textLength < 200) return ChallengeDifficulty.normal;
  return ChallengeDifficulty.hard;
}
```

### ポイント管理

- **加算**: チャレンジ完了時に`CurrentPointsNotifier.addPoints()`
- **取得**: Firestore内の全完了チャレンジの`earnedPoints`を合計
- **表示**: `currentPointsProvider`を監視して表示

## エラーハンドリング

### 1. Firestoreエラー

```dart
try {
  await repository.saveUserChallenge(challenge);
} catch (e) {
  // ロールバック処理
  state = AsyncValue.data(previousState);
  currentPointsProvider.setPoints(previousPoints);

  // エラー通知
  state = AsyncValue.error(e, StackTrace.current);
}
```

### 2. AIフィードバック生成エラー

```dart
try {
  final feedback = await feedbackService.generateFeedback(...);
} catch (e) {
  // フィードバックなしで続行（エラーログのみ）
  print('フィードバック生成エラー: $e');
}
```

### 3. ログイン状態エラー

```dart
final currentUser = FirebaseAuth.instance.currentUser;
if (currentUser == null) {
  // ダミーデータを返却
  return ChallengeState(challenges: _createDummyData());
}
```

## 技術的な特徴

### 1. Freezedの使用

**メリット**:
- イミュータブルなデータクラス
- `copyWith()`メソッドの自動生成
- `==`と`hashCode`の自動実装
- Union型のサポート

**使用例**:
```dart
final updatedChallenge = challenge.copyWith(
  status: ChallengeStatus.completed,
  oppositeOpinionText: userInput,
  completedAt: DateTime.now(),
);
```

### 2. 楽観的UI更新

チャレンジ完了時、Firestoreへの保存を待たずにUIを即座に更新:

```dart
// 1. ローカル状態を即座に更新
state = AsyncValue.data(updatedState);

// 2. 非同期でFirestoreに保存
try {
  await repository.saveUserChallenge(completedChallenge);
} catch (e) {
  // 3. エラー時はロールバック
  state = AsyncValue.data(previousState);
}
```

**メリット**: ユーザー体験の向上（レスポンシブなUI）

### 3. 効率的なデータマージ

O(n+m)アルゴリズムでベースチャレンジと完了データをマージ:

```dart
final completedMap = <String, Challenge>{
  for (var c in completedChallenges) c.id: c
};

return baseChallenges.map((challenge) {
  return completedMap[challenge.id] ?? challenge;
}).toList();
```

**メリット**: 大量のチャレンジでもパフォーマンス維持

### 4. Provider依存関係の最適化

`filteredChallengesProvider`は必要なプロバイダーのみを監視:

```dart
final filteredChallengesProvider = Provider<List<Challenge>>((ref) {
  final state = ref.watch(challengeProvider);    // チャレンジデータ
  final filter = ref.watch(challengeFilterProvider); // フィルタ状態

  // どちらかが変更されたときのみ再計算
  return state.challenges.where(...).toList();
});
```

## ナビゲーション

### ルート定義

```
/challenge                          - チャレンジ一覧
/challenge/:challengeId             - チャレンジ詳細
/challenge/:challengeId/feedback    - フィードバック表示
```

### ボトムナビゲーション

- タブ: 「チャレンジ」
- パス: `/challenge`
- 同列タブ: ホーム、ディベート、統計

## テストガイド

### ユニットテスト例

```dart
// ChallengeNotifierのテスト
test('completeChallenge updates state correctly', () async {
  final notifier = ChallengeNotifier();
  await notifier.completeChallenge('id1', 'opposite opinion', 30);

  final challenge = notifier.state.value!.challenges
      .firstWhere((c) => c.id == 'id1');

  expect(challenge.status, ChallengeStatus.completed);
  expect(challenge.oppositeOpinionText, 'opposite opinion');
  expect(challenge.earnedPoints, 30);
});
```

## トラブルシューティング

### チャレンジが生成されない

**原因**: ユーザーがホーム画面で意見を投稿していない

**解決策**:
1. ホーム画面で意見を投稿
2. チャレンジページをリフレッシュ
3. ダミーデータが表示される場合は正常動作

### データが保存されない

**確認項目**:
1. Firebase設定（`google-services.json`/`GoogleService-Info.plist`）
2. Firestoreセキュリティルール
3. ユーザーログイン状態
4. ネットワーク接続

### フィードバックが生成されない

**確認項目**:
1. AIRepositoryの設定
2. Gemini APIキー
3. ネットワーク接続
4. API利用制限

## 今後の拡張予定

- [x] ホーム画面で投稿した意見をチャレンジのデータソースとして使用（2025-11-08実装済み）
- [x] AIフィードバック機能（実装済み）
- [ ] ホーム画面の意見一覧で、完了したチャレンジの回答を表示
- [ ] チャレンジの自動生成（AIを使った意見生成）
- [ ] ユーザー同士でチャレンジを評価し合う機能
- [ ] ランキング機能（週間・月間ランキング）
- [ ] バッジシステムの拡充（連続達成、高得点など）
- [ ] チャレンジ履歴の詳細表示
- [ ] チャレンジのカテゴリ分類（政治、経済、社会など）
- [ ] 達成度に応じた報酬システム
- [ ] チャレンジの共有機能（SNS連携）

## 更新履歴

### 2025-12-28 (最新)
- **Flutter Hooks へのリファクタリング**
  - すべてのプレゼンテーション層のページを `HookConsumerWidget` に変更
    - `challenge.dart`: `ConsumerStatefulWidget` → `HookConsumerWidget`
    - `challenge_detail.dart`: `StatefulWidget` → `HookConsumerWidget`
    - `challenge_feedback_page.dart`: `ConsumerStatefulWidget` → `HookConsumerWidget`
  - `flutter_hooks` と `hooks_riverpod` の導入
  - 状態管理の改善
    - `useState` による状態変数の宣言的管理
    - `useTextEditingController` による自動リソース管理
    - `useMemoized` による値のメモ化
    - `useEffect` による副作用処理（initStateの置き換え）
  - `dispose()` メソッドの削除（自動クリーンアップによりメモリリーク防止）
  - コードの簡潔化と保守性の向上
    - Stateクラスの削除により定型文が減少
    - ヘルパーメソッドの純粋関数化
    - `.value` による明示的な状態更新

### 2025-11-08
- **ホーム画面の意見との連携実装**
  - `challenge_model.dart`に`opinionId`、`feedbackText`、`feedbackScore`、`feedbackGeneratedAt`フィールドを追加
  - `challenge_repositories.dart`に`getChallengesFromUserOpinions()`メソッドを追加
  - `challenge_provider.dart`で実際のユーザー投稿意見をチャレンジのデータソースとして使用
  - 意見の文字数に応じた難易度の自動設定を実装
  - OpinionStanceからChallengeのStanceへの変換ロジックを実装
  - ダミーデータは投稿意見がない場合のフォールバックとして維持

- **AIフィードバック機能追加**
  - `services/feedback_service.dart`を新規作成
  - `ChallengeFeedbackService`クラスでGemini APIを使用したフィードバック生成
  - `challenge_feedback_page.dart`でフィードバック表示画面を実装
  - スコアリング機能（0-100点）とアドバイス機能を実装

- **Firebase連携実装**
  - `challenge_model.dart`にtoJson/fromJsonメソッド追加
  - `challenge_repositories.dart`でFirestore操作を実装
  - `challenge_provider.dart`でデータ読み込み・保存機能を追加
  - チャレンジ進行状況の永続化を実現
  - 複数端末での同期に対応

## 参考資料

- [Riverpod公式ドキュメント](https://riverpod.dev/)
- [Freezed公式ドキュメント](https://pub.dev/packages/freezed)
- [Cloud Firestore公式ドキュメント](https://firebase.google.com/docs/firestore)
- [プロジェクトREFACTORING_GUIDE.md](./REFACTORING_GUIDE.md)

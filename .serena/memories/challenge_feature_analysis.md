# チャレンジ機能の実装詳細

## 1. チャレンジ機能の概要

### 目的
自分とは反対の立場で意見を考えるトレーニング機能。ユーザーが投稿した意見から自動的にチャレンジを生成し、反対意見を書くことでポイント獲得。

### 保存場所
- **Firestore**: `userChallenges/{userId}_{challengeId}`
- **Firestore**: `opinions` → チャレンジ生成元の意見データ

## 2. チャレンジモデル

### Challenge データモデル
```dart
class Challenge {
  String id;                          // チャレンジID
  String title;                       // チャレンジのタイトル
  Stance stance;                      // 元の立場（pro/con）
  ChallengeDifficulty difficulty;    // 難易度（easy/normal/hard）
  String originalOpinionText;        // 元の意見
  String? oppositeOpinionText;       // 反対意見（完了時に入力）
  ChallengeStatus status;            // ステータス（available/completed）
  String userId;                      // ユーザーID
  DateTime? completedAt;             // 完了日時
  int? earnedPoints;                 // 獲得ポイント
  String? feedbackText;              // AI生成フィードバック
  int? feedbackScore;                // フィードバックスコア
  DateTime? feedbackGeneratedAt;     // フィードバック生成日時
}

// Stance: pro（賛成）/ con（反対）
// ChallengeDifficulty: easy / normal / hard
// ChallengeStatus: available / completed
```

## 3. チャレンジプロバイダー

### 主要プロバイダー

#### challengeRepositoryProvider
```
Provider<ChallengeRepository>
  - Firestoreへのアクセスを担当
```

#### challengeProvider
```
AsyncNotifierProvider<ChallengeNotifier, ChallengeState>
  
  状態: ChallengeState {
    challenges: List<Challenge>,
    isLoading: bool,
    errorMessage: string?
  }
```

#### filteredChallengesProvider
```
Provider<List<Challenge>>
  
  依存: challengeProvider, challengeFilterProvider
  フィルタリング:
  - ChallengeFilter.available → status == available
  - ChallengeFilter.completed → status == completed
```

#### currentPointsProvider
```
NotifierProvider<CurrentPointsNotifier, int>
  
  状態: 現在の合計ポイント
  更新: チャレンジ完了時に加算
```

#### challengeFilterProvider
```
NotifierProvider<ChallengeFilterNotifier, ChallengeFilter>
  
  状態: ChallengeFilter（available / completed）
```

## 4. チャレンジデータの読み込みフロー

### ChallengeNotifier.build()（初期化）

```
1. ユーザーログイン確認
   - FirebaseAuth.instance.currentUser が null か確認
   - null の場合: ダミーデータのみ返却

2. ユーザーの投稿意見からチャレンジ生成
   repository.getChallengesFromUserOpinions(userId)
   → opinions コレクションから該当ユーザーの意見を取得
   → 各意見に対してチャレンジを生成
   
3. Firestoreから完了チャレンジデータ取得
   repository.getUserChallenges(userId)
   → userChallenges/{userId}_* からユーザーの完了情報を取得
   
4. 獲得ポイント合計を計算
   repository.getTotalEarnedPoints(userId)
   → すべての完了チャレンジの earnedPoints を集計
   → currentPointsProvider に反映
   
5. データマージ処理（効率化版）
   _mergeChallenges(baseChallenges, completedChallenges)
   → Map ベースのO(n+m)処理
   → ベースチャレンジから完了状態を検索・更新
   
6. 最終状態を返却
   ChallengeState(challenges: mergedChallenges)
```

### マージ処理の詳細
```dart
// 完了チャレンジを Map に変換（O(1)ルックアップ）
final completedMap = <String, Challenge>{
  for (var c in completedChallenges) c.id: c
};

// ベースチャレンジと照合
final merged = baseChallenges.map((challenge) {
  final completed = completedMap[challenge.id];
  if (completed != null) {
    return completed;  // 完了データで置き換え
  } else {
    return challenge;  // 未完了のまま
  }
}).toList();
```

## 5. チャレンジ完了フロー

### completeChallenge()メソッド

```
入力:
- challengeId: 完了するチャレンジID
- oppositeOpinion: ユーザーが入力した反対意見
- earnedPoints: 獲得ポイント
- feedbackText?: AIフィードバック
- feedbackScore?: フィードバックスコア

処理:
1. ユーザーログイン確認

2. 楽観的UI更新
   - 現在の状態を取得（state.value）
   - 該当チャレンジを見つける（indexWhere）
   -新しい Challenge オブジェクト生成
     {
       status: completed,
       oppositeOpinionText: 入力値,
       completedAt: now,
       earnedPoints: ポイント,
       feedbackText: フィードバック,
       ...
     }
   - ローカル状態を即座に更新
   - currentPointsProvider に加算

3. Firestoreへ非同期保存
   repository.saveUserChallenge(completedChallenge)
   → Firestore: userChallenges/{userId}_{challengeId}
   
4. エラーハンドリング
   - 失敗時は元の状態にロールバック
   - currentPointsProvider も復元
```

## 6. Firestoreスキーマ

### userChallenges コレクション
```
userChallenges/{userId}_{challengeId}
  ├── id: string (チャレンジID)
  ├── userId: string
  ├── title: string
  ├── stance: string (pro/con)
  ├── difficulty: string (easy/normal/hard)
  ├── status: string (available/completed)
  ├── originalOpinionText: string
  ├── oppositeOpinionText: string (完了時のみ)
  ├── earnedPoints: int (完了時のみ)
  ├── completedAt: Timestamp (完了時のみ)
  ├── feedbackText: string (フィードバック時のみ)
  ├── feedbackScore: int (フィードバック時のみ)
  └── feedbackGeneratedAt: Timestamp (フィードバック時のみ)
```

## 7. ダミーデータ

### _createDummyData() 関数
チャレンジが生成されない場合、以下のダミーデータを表示:
```
1. 週休3日制は導入すべきか？（easy, con→pro）
2. 今日のご飯なに？（normal, pro→con）
3. は？（hard, con→pro）
4. SNSは社会に有益か？（normal, pro→con）
```

## 8. フィードバック機能

### ChallengeFeedbackPage
```
path: /challenge/:challengeId/feedback

入力:
- challenge: Challenge オブジェクト
- challengeAnswer: ユーザーの反対意見

表示:
- AI生成フィードバック（feedbackText）
- スコア表示（feedbackScore）
- チャレンジポイント表示
```

### フィードバック生成
- フィードバックサービス: `lib/feature/challenge/services/feedback_service.dart`
- AI（CloudFunctions等）が自動生成

## 9. ナビゲーション

### チャレンジ関連ページ
```
/challenge                         - チャレンジ一覧
/challenge/:challengeId            - チャレンジ詳細
/challenge/:challengeId/feedback   - フィードバック表示
```

### ボトムナビゲーション
- 「チャレンジ」タブ: `/challenge`（ホーム、ディベート、統計と同じレベル）

## 10. ポイント管理

### ポイント取得
- チャレンジ完了時に earnedPoints を獲得
- 難易度別ポイント:
  - easy: 10点程度
  - normal: 20点程度
  - hard: 30点程度（推定）

### ポイント合計計算
```
getTotalEarnedPoints(userId)
  → userChallenges/{userId}_* をすべて取得
  → earnedPoints を合計
  → currentPointsProvider で管理
```

### ポイント表示
- チャレンジ一覧画面上部に「現在のポイント」表示
- currentPointsProvider から取得

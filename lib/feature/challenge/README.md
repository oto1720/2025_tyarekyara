# Challenge機能（視点交換チャレンジ）

自分とは反対の立場で意見を考えることで、多角的な思考力を養うトレーニング機能です。

## 概要

Challenge機能では、**ユーザーが過去にホーム画面で投稿した意見**とは反対の立場から新たな意見を考えるチャレンジを提供します。これにより、以下のスキルを育成します：

- 多角的な視点での物事の捉え方
- 論理的思考力
- 共感力と理解力
- 説得力のある文章作成能力

### 重要な変更点（2025-11-08）

従来のダミーデータではなく、**ユーザーが実際にホーム画面で投稿した意見**をチャレンジのデータソースとして使用するようになりました。これにより、自分自身の意見に対して反対の立場で考える、より実践的なトレーニングが可能になります。

## 機能詳細

### 1. チャレンジ一覧
- 挑戦可能なチャレンジと完了済みチャレンジをタブで切り替え表示
- 難易度別（簡単・普通・難しい）のチャレンジ
- 各チャレンジの獲得ポイントを表示

### 2. チャレンジ詳細
- 元の自分の意見を確認
- 反対の立場から100文字以上の意見を記述
- バリデーション機能付きテキスト入力フォーム

### 3. ポイントシステム
- 難易度に応じたポイント獲得
  - 簡単: 30ポイント
  - 普通: 50ポイント
  - 難しい: 100ポイント
- 累計ポイントの表示
- プログレスバーによる視覚化

### 4. Firebase連携（永続化）
- チャレンジの進行状況をFirestoreに保存
- アプリ再起動後もデータを復元
- 複数端末での同期対応

### 5. ホーム画面の意見との連携
- ホーム画面で投稿した意見を自動的にチャレンジとして生成
- 意見の文字数に応じて難易度を自動設定（100文字未満：簡単、200文字未満：普通、200文字以上：難しい）
- 元の立場とは反対の立場でチャレンジを設定
  - 賛成 → 反対の立場で考える
  - 反対 → 賛成の立場で考える
  - 中立 → 賛成の立場で考える

## アーキテクチャ

### ディレクトリ構造

```
lib/feature/challenge/
├── models/
│   └── challenge_model.dart          # チャレンジデータモデル
├── providers/
│   └── challenge_provider.dart       # 状態管理（Riverpod）
├── repositories/
│   └── challenge_repositories.dart   # Firestoreアクセス層
└── presentaion/
    ├── pages/
    │   ├── challenge.dart            # チャレンジ一覧画面
    │   └── challenge_detail.dart     # チャレンジ詳細画面
    └── widgets/
        ├── challenge_card.dart           # 挑戦可能カード
        ├── CompletedChallenge_card.dart  # 完了済みカード
        └── difficultry_budge.dart        # 難易度バッジ
```

## データモデル

### Challenge クラス

```dart
class Challenge {
  final String id;                    // チャレンジID
  final String title;                 // チャレンジタイトル
  final Stance stance;                // 元の立場（pro/con）
  final ChallengeDifficulty difficulty; // 難易度
  ChallengeStatus status;             // ステータス
  final String originalOpinionText;   // 元の意見
  String? oppositeOpinionText;        // 反対意見
  final String userId;                // ユーザーID
  final DateTime? completedAt;        // 完了日時
  final int? earnedPoints;            // 獲得ポイント
  final String? opinionId;            // 元の意見ID（ホームで投稿した意見との紐付け）
}
```

### Enum定義

```dart
enum Stance {
  pro,  // 賛成
  con,  // 反対
}

enum ChallengeStatus {
  available,  // 挑戦可能
  completed,  // 完了済み
}

enum ChallengeDifficulty {
  easy('簡単', Colors.green, 30),
  normal('普通', Colors.amber, 50),
  hard('難しい', Colors.red, 100);

  final String label;
  final Color color;
  final int points;
}
```

## Firestoreデータ構造

### userChallenges コレクション

```
userChallenges/{userId}_{challengeId}/
├── id: string                   # チャレンジID
├── userId: string               # ユーザーID
├── title: string                # チャレンジタイトル
├── stance: string               # 元の立場（pro/con）
├── difficulty: string           # 難易度（easy/normal/hard）
├── status: string               # ステータス（available/completed）
├── originalOpinionText: string  # 元の意見
├── oppositeOpinionText: string  # チャレンジで書いた反対意見
├── earnedPoints: int            # 獲得ポイント
└── completedAt: Timestamp       # 完了日時
```

## 状態管理（Riverpod）

### ChallengeProvider

```dart
final challengeProvider = NotifierProvider<ChallengeNotifier, ChallengeState>(() {
  return ChallengeNotifier();
});
```

### 主要なメソッド

#### `loadChallenges()`
- **ユーザーがホーム画面で投稿した意見を取得**
- 意見をチャレンジに変換（反対の立場で考えるチャレンジを生成）
- Firestoreからユーザーのチャレンジ完了状況を読み込み
- 意見ベースのチャレンジとFirestoreデータをマージして表示
- アプリ起動時に自動実行
- 投稿意見がない場合はダミーデータを使用

#### `completeChallenge(String challengeId, String oppositeOpinion, int earnedPoints)`
- チャレンジを完了状態に更新
- Firestoreに保存
- 楽観的UI更新で即座に反映

#### `setFilter(ChallengeFilter filter)`
- 表示フィルタを変更（挑戦可能/完了済み）

## Repository層

### ChallengeRepository

Firestoreとのデータやり取りを担当

#### 主要メソッド

```dart
// チャレンジ保存
Future<void> saveUserChallenge(Challenge challenge)

// ユーザーのチャレンジ一覧取得
Future<List<Challenge>> getUserChallenges(String userId)

// 特定チャレンジ取得
Future<Challenge?> getUserChallenge(String userId, String challengeId)

// ステータス更新
Future<void> updateChallengeStatus({
  required String userId,
  required String challengeId,
  required ChallengeStatus status,
  String? oppositeOpinionText,
  int? earnedPoints,
})

// 完了数取得
Future<int> getCompletedChallengeCount(String userId)

// 獲得ポイント合計取得
Future<int> getTotalEarnedPoints(String userId)

// リアルタイム監視（Stream）
Stream<List<Challenge>> watchUserChallenges(String userId)

// **新規追加**: ユーザーの投稿意見からチャレンジを生成
Future<List<Challenge>> getChallengesFromUserOpinions(String userId)
```

## 使用方法

### 1. チャレンジ一覧の表示

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final challengeState = ref.watch(challengeProvider);
  final challenges = challengeState.filteredChallenges;

  return ListView.builder(
    itemCount: challenges.length,
    itemBuilder: (context, index) {
      final challenge = challenges[index];
      return ChallengeCard(
        challenge: challenge,
        onChallengePressed: () => _handleChallenge(challenge),
      );
    },
  );
}
```

### 2. チャレンジ完了処理

```dart
Future<void> _handleChallenge(Challenge challenge) async {
  final result = await context.push<Map<String, dynamic>>(
    '/challenge/${challenge.id}',
    extra: challenge,
  );

  if (result != null) {
    ref.read(challengeProvider.notifier).completeChallenge(
      challenge.id,
      result['opinion'],
      result['points'],
    );
  }
}
```

## UI実装

### チャレンジカード

#### 挑戦可能カード（ChallengeCard）
- 難易度バッジとポイント表示
- 元の立場と挑戦する立場の表示
- 「チャレンジする」ボタン

#### 完了済みカード（CompletedCard）
- 完了アイコンと獲得ポイント表示
- 自分が書いた反対意見を表示
- 緑色の背景で視覚的に区別

### チャレンジ詳細画面

- 元の意見の表示エリア
- 反対意見入力フォーム（100文字以上のバリデーション）
- ヒントカード
- キャンセル/完了ボタン

## データフロー

1. **アプリ起動時**
   ```
   ChallengePage
   → challengeProvider.build()
   → loadChallenges()
   → repository.getChallengesFromUserOpinions() // ホームで投稿した意見を取得
   → OpinionRepository.getOpinionsByUser() // Firestoreから意見取得
   → 意見をChallengeに変換
   → repository.getUserChallenges() // 完了済みチャレンジを取得
   → データマージ
   → 状態更新
   → UI反映
   ```

2. **チャレンジ完了時**
   ```
   ChallengeDetailPage
   → ユーザー入力（100文字以上）
   → バリデーション
   → 完了ボタン押下
   → pop(result)
   → challengeProvider.completeChallenge()
   → 楽観的UI更新（即座に反映）
   → repository.saveUserChallenge()
   → Firestoreに保存
   → （エラー時）データ再読み込み
   ```

## 今後の拡張案

- [x] ホーム画面で投稿した意見をチャレンジのデータソースとして使用（2025-11-08実装済み）
- [ ] ホーム画面の意見一覧で、完了したチャレンジの回答を表示
- [ ] チャレンジの自動生成（AIを使った意見生成）
- [ ] ユーザー同士でチャレンジを評価し合う機能
- [ ] ランキング機能
- [ ] バッジシステムの拡充
- [ ] チャレンジ履歴の詳細表示
- [ ] チャレンジのカテゴリ分類
- [ ] 達成度に応じた報酬システム

## トラブルシューティング

### データが保存されない
- Firebaseの設定を確認
- Firestoreセキュリティルールを確認
- ユーザーがログインしているか確認

### 完了済みチャレンジが表示されない
- `loadChallenges()`が正常に実行されているか確認
- Firestoreのデータ構造が正しいか確認

## 更新履歴

### 2025-11-08 (最新)
- **ホーム画面の意見との連携実装**
  - `challenge_model.dart`に`opinionId`フィールドを追加
  - `challenge_repositories.dart`に`getChallengesFromUserOpinions()`メソッドを追加
  - `challenge_provider.dart`で実際のユーザー投稿意見をチャレンジのデータソースとして使用
  - 意見の文字数に応じた難易度の自動設定を実装
  - OpinionStanceからChallengeのStanceへの変換ロジックを実装
  - ダミーデータは投稿意見がない場合のフォールバックとして維持

### 2025-11-08
- **Firebase連携実装**
  - `challenge_model.dart`にtoJson/fromJsonメソッド追加
  - `challenge_repositories.dart`でFirestore操作を実装
  - `challenge_provider.dart`でデータ読み込み・保存機能を追加
  - チャレンジ進行状況の永続化を実現
  - 複数端末での同期に対応

# ディベート機能の完全フローガイド

## 全体の流れ

```
1. エントリー
   ↓
2. 待機画面（マッチング待ち）
   ↓
3. マッチング成立 → マッチ詳細画面
   ↓
4. イベント開催時刻 → ディベート画面
   ↓
5. ディベートフェーズ進行
   ↓
6. AI判定
   ↓
7. 結果表示
```

## ディベートフェーズの詳細

### フェーズ一覧

ディベートは以下のフェーズで進行します：

#### 5分モード（short）
1. **準備時間（preparation）** - 30秒
2. **立論・賛成（openingPro）** - 60秒
3. **立論・反対（openingCon）** - 60秒
4. **反論・賛成（rebuttalPro）** - 45秒
5. **反論・反対（rebuttalCon）** - 45秒
6. **最終主張・賛成（closingPro）** - 30秒
7. **最終主張・反対（closingCon）** - 30秒
8. **AI判定（judgment）** - 15秒
9. **結果表示（result）**
10. **完了（completed）**

#### 10分モード（medium）
1. **準備時間（preparation）** - 60秒
2. **立論・賛成（openingPro）** - 90秒
3. **立論・反対（openingCon）** - 90秒
4. **質疑応答・賛成へ（questionPro）** - 30秒
5. **質疑応答・反対へ（questionCon）** - 30秒
6. **反論・賛成（rebuttalPro）** - 60秒
7. **反論・反対（rebuttalCon）** - 60秒
8. **最終主張・賛成（closingPro）** - 45秒
9. **最終主張・反対（closingCon）** - 45秒
10. **AI判定（judgment）** - 20秒
11. **結果表示（result）**
12. **完了（completed）**

## 現在の実装状況

### ✅ 実装済み

1. **データモデル**
   - `DebateRoom`: ルーム情報
   - `DebatePhase`: フェーズ定義
   - `DebateMessage`: メッセージ
   - `JudgmentResult`: AI判定結果

2. **画面**
   - イベント一覧画面
   - イベント詳細画面
   - エントリー画面
   - 待機画面
   - マッチ詳細画面
   - ディベート画面
   - AI判定待機画面
   - 結果表示画面

3. **Firestore連携**
   - リアルタイム監視
   - エントリー作成
   - マッチ作成
   - ルーム作成

4. **Cloud Functions**
   - イベントステータス自動更新
   - マッチング処理
   - ルーム作成・アクティブ化

### ❌ 未実装・動作していない部分

#### 1. フェーズ自動進行機能

**現状の問題:**
- 準備時間が終わってもフェーズが進まない
- タイマーは動くが、次のフェーズに移動しない

**必要な実装:**

##### A. クライアント側（Flutter）でのフェーズ進行
```dart
// lib/feature/debate/presentation/pages/debate_room_page.dart
// タイマーが0になったら次のフェーズに進める処理
void _onPhaseTimeEnd() {
  final nextPhase = _getNextPhase(currentPhase);
  if (nextPhase != null) {
    _updatePhase(nextPhase);
  }
}
```

##### B. サーバー側（Cloud Functions）でのフェーズ進行

より確実な方法として、Cloud Functionsでフェーズを自動進行：

```typescript
// functions/src/services/debatePhaseService.ts
export async function progressPhase(roomId: string): Promise<void> {
  const room = await getRoomById(roomId);
  const nextPhase = getNextPhase(room.currentPhase, room.duration);

  if (nextPhase) {
    await updateRoomPhase(roomId, nextPhase);
  } else {
    // 全フェーズ完了 → AI判定へ
    await triggerAIJudgment(roomId);
  }
}
```

**どちらを選ぶべきか:**
- **クライアント側**: 実装が簡単、即座に反応
- **サーバー側**: より確実、不正防止になる

**推奨**: 両方実装
- クライアント側で即座にフェーズ切り替え
- サーバー側で定期的に検証（ずれを修正）

#### 2. AI判定機能

**必要な実装:**

##### A. Cloud Functionsで判定処理を実装

```typescript
// functions/src/services/aiJudgmentService.ts
export async function executeAIJudgment(matchId: string): Promise<void> {
  // 1. ディベートメッセージを全て取得
  const messages = await getAllDebateMessages(matchId);

  // 2. OpenAI APIに送信
  const judgmentResult = await callOpenAI({
    topic: room.topic,
    proArguments: filterMessages(messages, 'pro'),
    conArguments: filterMessages(messages, 'con'),
  });

  // 3. 判定結果を保存
  await saveJudgment({
    matchId,
    winner: judgmentResult.winner,
    scores: judgmentResult.scores,
    reasoning: judgmentResult.reasoning,
  });

  // 4. ルームステータスを結果表示に変更
  await updateRoomPhase(roomId, 'result');
}
```

##### B. OpenAI APIの設定

```typescript
import { OpenAI } from 'openai';

const openai = new OpenAI({
  apiKey: functions.config().openai.key,
});

const response = await openai.chat.completions.create({
  model: 'gpt-4',
  messages: [
    {
      role: 'system',
      content: 'あなたはディベートの審査員です。以下の議論を評価してください。',
    },
    {
      role: 'user',
      content: `トピック: ${topic}\n\n賛成側:\n${proArguments}\n\n反対側:\n${conArguments}`,
    },
  ],
});
```

#### 3. タイマー同期機能

**現状の問題:**
- 各ユーザーのタイマーがバラバラに動く可能性

**解決策:**

##### A. Firestoreのタイムスタンプを使用

```typescript
// ルームに保存
{
  currentPhase: 'preparation',
  phaseStartedAt: Timestamp.now(), // フェーズ開始時刻
  phaseDuration: 30, // このフェーズの秒数
}
```

##### B. クライアント側で計算

```dart
int getRemainingTime() {
  final startTime = room.phaseStartedAt.toDate();
  final elapsed = DateTime.now().difference(startTime).inSeconds;
  final remaining = room.phaseDuration - elapsed;
  return max(0, remaining);
}
```

## 実装の優先順位

### 優先度1（最重要）: フェーズ自動進行

フェーズが進まないと何も始まらないので、まずこれを実装します。

**実装場所:**
- `lib/feature/debate/presentation/pages/debate_room_page.dart`
- または `functions/src/services/debatePhaseService.ts`

### 優先度2: タイマー同期

ユーザー間でタイマーがずれないようにします。

**実装場所:**
- `lib/feature/debate/repositories/debate_room_repository.dart`
- `lib/feature/debate/presentation/pages/debate_room_page.dart`

### 優先度3: AI判定機能

ディベート終了後に勝敗を判定します。

**実装場所:**
- `functions/src/services/aiJudgmentService.ts`（新規作成）
- OpenAI APIキーの設定

## 次に実装すべきこと

### ステップ1: フェーズ進行の実装方法を選択

**質問:**
1. クライアント側（Flutter）で実装しますか？
2. サーバー側（Cloud Functions）で実装しますか？
3. 両方実装しますか？

### ステップ2: AI判定の準備

**必要な設定:**
1. OpenAI APIキーの取得
2. Firebase Functionsの環境変数に設定
3. 判定ロジックの実装

## 参考: 既存ファイル

### フェーズ定義
- `lib/feature/debate/models/debate_room.dart:8-96`

### ディベート画面
- `lib/feature/debate/presentation/pages/debate_room_page.dart`

### AI判定待機画面
- `lib/feature/debate/presentation/pages/debate_judgment_waiting_page.dart`

### 結果表示画面
- `lib/feature/debate/presentation/pages/debate_result_page.dart`

### リポジトリ
- `lib/feature/debate/repositories/debate_room_repository.dart`
- `functions/src/services/debateRoomService.ts`

## まとめ

現在、画面遷移は動作していますが、以下が未実装です：

1. ✅ **画面遷移** - 完了！
2. ❌ **フェーズ自動進行** - 次に実装すべき
3. ❌ **タイマー同期** - フェーズ進行と一緒に実装
4. ❌ **AI判定** - その後に実装

**次の質問:**
フェーズ自動進行を実装しますか？クライアント側、サーバー側、どちらで実装したいですか？

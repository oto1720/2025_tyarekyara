# ディベート機能 Firestore スキーマ設計

## コレクション構造

```
/debate_events/{eventId}
/debate_entries/{entryId}
/debate_matches/{matchId}
/debate_rooms/{roomId}
  └─ /messages/{messageId}
/debate_judgments/{judgmentId}
/user_debate_stats/{userId}
/debate_rankings/{rankingType}/{userId}
```

---

## 1. debate_events コレクション

イベント情報を管理

### ドキュメント構造

```typescript
{
  id: string,
  title: string,
  topic: string,
  description: string,
  status: 'scheduled' | 'accepting' | 'matching' | 'inProgress' | 'completed' | 'cancelled',
  scheduledAt: Timestamp,
  entryDeadline: Timestamp,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  availableDurations: ['short', 'medium', 'long'],
  availableFormats: ['oneVsOne', 'twoVsTwo'],
  currentParticipants: number,
  maxParticipants: number,
  imageUrl?: string,
  metadata?: object
}
```

### インデックス

- `status` (ASC) + `scheduledAt` (ASC)
- `status` (ASC) + `createdAt` (DESC)

### セキュリティルール例

```javascript
match /debate_events/{eventId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null &&
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}
```

---

## 2. debate_entries コレクション

エントリー情報を管理

### ドキュメント構造

```typescript
{
  userId: string,
  eventId: string,
  preferredDuration: 'short' | 'medium' | 'long',
  preferredFormat: 'oneVsOne' | 'twoVsTwo',
  preferredStance: 'pro' | 'con' | 'any',
  enteredAt: Timestamp,
  status: 'waiting' | 'matched' | 'inProgress' | 'completed' | 'cancelled',
  matchId?: string
}
```

### インデックス

- `eventId` (ASC) + `status` (ASC) + `enteredAt` (ASC)
- `userId` (ASC) + `status` (ASC)
- `eventId` (ASC) + `preferredDuration` (ASC) + `status` (ASC)

### セキュリティルール例

```javascript
match /debate_entries/{entryId} {
  allow read: if request.auth != null &&
    request.auth.uid == resource.data.userId;
  allow create: if request.auth != null &&
    request.auth.uid == request.resource.data.userId;
  allow update: if request.auth != null &&
    request.auth.uid == resource.data.userId;
}
```

---

## 3. debate_matches コレクション

マッチング情報を管理

### ドキュメント構造

```typescript
{
  id: string,
  eventId: string,
  format: 'oneVsOne' | 'twoVsTwo',
  duration: 'short' | 'medium' | 'long',
  proTeam: {
    stance: 'pro',
    memberIds: string[],
    score: number,
    mvpUserId?: string
  },
  conTeam: {
    stance: 'con',
    memberIds: string[],
    score: number,
    mvpUserId?: string
  },
  status: 'waiting' | 'matched' | 'inProgress' | 'completed' | 'cancelled',
  matchedAt: Timestamp,
  createdAt: Timestamp,
  startedAt?: Timestamp,
  completedAt?: Timestamp,
  roomId?: string,
  winningSide?: string,
  metadata?: object
}
```

### インデックス

- `eventId` (ASC) + `status` (ASC)
- `status` (ASC) + `matchedAt` (DESC)

### クエリ例

```dart
// 自分のマッチを取得
firestore
  .collection('debate_matches')
  .where('proTeam.memberIds', arrayContains: userId)
  .where('status', isEqualTo: 'matched')
  .get()

// または
firestore
  .collection('debate_matches')
  .where('conTeam.memberIds', arrayContains: userId)
  .where('status', isEqualTo: 'matched')
  .get()
```

### セキュリティルール例

```javascript
match /debate_matches/{matchId} {
  allow read: if request.auth != null && (
    request.auth.uid in resource.data.proTeam.memberIds ||
    request.auth.uid in resource.data.conTeam.memberIds
  );
  allow write: if false; // Cloud Functionsのみ
}
```

---

## 4. debate_rooms コレクション

ディベートルーム情報を管理

### ドキュメント構造

```typescript
{
  id: string,
  eventId: string,
  matchId: string,
  participantIds: string[],
  participantStances: {
    [userId: string]: 'pro' | 'con'
  },
  status: 'waiting' | 'inProgress' | 'judging' | 'completed' | 'abandoned',
  currentPhase: 'preparation' | 'openingPro' | 'openingCon' | ... | 'completed',
  createdAt: Timestamp,
  updatedAt: Timestamp,
  startedAt?: Timestamp,
  completedAt?: Timestamp,
  phaseStartedAt?: Timestamp,
  phaseTimeRemaining: number,
  messageCount: {
    [userId: string]: number
  },
  warningCount: {
    [userId: string]: number
  },
  judgmentId?: string,
  metadata?: object
}
```

### サブコレクション: messages

```typescript
{
  id: string,
  roomId: string,
  userId: string,
  content: string,
  type: 'public' | 'team' | 'system',
  phase: DebatePhase,
  createdAt: Timestamp,
  status: 'sent' | 'flagged' | 'deleted',
  userNickname?: string,
  senderStance?: 'pro' | 'con',
  isWarning?: boolean,
  flagReason?: string,
  metadata?: object
}
```

### インデックス

**rooms:**
- `matchId` (ASC)
- `status` (ASC) + `createdAt` (DESC)

**messages:**
- `roomId` (ASC) + `createdAt` (ASC)
- `userId` (ASC) + `createdAt` (DESC)
- `type` (ASC) + `createdAt` (ASC)

### セキュリティルール例

```javascript
match /debate_rooms/{roomId} {
  allow read: if request.auth != null &&
    request.auth.uid in resource.data.participantIds;
  allow write: if false; // Cloud Functionsのみ

  match /messages/{messageId} {
    allow read: if request.auth != null &&
      request.auth.uid in get(/databases/$(database)/documents/debate_rooms/$(roomId)).data.participantIds;
    allow create: if request.auth != null &&
      request.auth.uid == request.resource.data.userId &&
      request.auth.uid in get(/databases/$(database)/documents/debate_rooms/$(roomId)).data.participantIds;
    allow update, delete: if false;
  }
}
```

---

## 5. debate_judgments コレクション

AI判定結果を管理

### ドキュメント構造

```typescript
{
  id: string,
  roomId: string,
  matchId: string,
  proTeamScore: {
    stance: 'pro',
    logic: number,
    evidence: number,
    rebuttal: number,
    persuasiveness: number,
    manner: number,
    total: number,
    feedback?: string
  },
  conTeamScore: {
    stance: 'con',
    logic: number,
    evidence: number,
    rebuttal: number,
    persuasiveness: number,
    manner: number,
    total: number,
    feedback?: string
  },
  winningSide: 'pro' | 'con',
  summary: string,
  judgedAt: Timestamp,
  createdAt: Timestamp,
  individualEvaluations: [
    {
      userId: string,
      userNickname: string,
      stance: 'pro' | 'con',
      contributionScore: number,
      strengths: string[],
      improvements: string[],
      isMvp: boolean
    }
  ],
  mvpUserId?: string,
  keyMoment?: string,
  aiMetadata?: object
}
```

### インデックス

- `matchId` (ASC)
- `roomId` (ASC)

### セキュリティルール例

```javascript
match /debate_judgments/{judgmentId} {
  allow read: if request.auth != null;
  allow write: if false; // Cloud Functionsのみ
}
```

---

## 6. user_debate_stats コレクション

ユーザーごとのディベート統計

### ドキュメント構造

```typescript
{
  userId: string,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  totalDebates: number,
  wins: number,
  losses: number,
  draws: number,
  winRate: number,
  totalPoints: number,
  currentMonthPoints: number,
  experiencePoints: number,
  level: number,
  mvpCount: number,
  mannerAwardCount: number,
  currentWinStreak: number,
  maxWinStreak: number,
  proWins: number,
  conWins: number,
  badges: ['rookie', 'debater', ...],
  lastDebateAt?: Timestamp,
  lastMonthlyReset?: Timestamp,
  avgLogicScore: number,
  avgEvidenceScore: number,
  avgRebuttalScore: number,
  avgPersuasivenessScore: number,
  avgMannerScore: number,
  metadata?: object
}
```

### インデックス

- `userId` (ASC)
- `totalPoints` (DESC)
- `winRate` (DESC)
- `currentMonthPoints` (DESC)

### セキュリティルール例

```javascript
match /user_debate_stats/{userId} {
  allow read: if request.auth != null;
  allow write: if false; // Cloud Functionsのみ
}
```

---

## 7. debate_rankings コレクション

ランキング情報（月次更新）

### ドキュメント構造

```
/debate_rankings/monthly_points/{userId}
/debate_rankings/total_wins/{userId}
/debate_rankings/mvp_count/{userId}
```

```typescript
{
  userId: string,
  userNickname: string,
  rank: number,
  value: number,
  userIconUrl?: string,
  updatedAt: Timestamp
}
```

### インデックス

- `value` (DESC) + `updatedAt` (ASC)

### セキュリティルール例

```javascript
match /debate_rankings/{rankingType}/{userId} {
  allow read: if request.auth != null;
  allow write: if false; // Cloud Functionsのみ
}
```

---

## データフロー例

### 1. イベントエントリー

```
User → debate_entries (create)
Cloud Function → debate_events (update currentParticipants)
```

### 2. マッチング

```
Cloud Scheduler → Cloud Function (matching logic)
Cloud Function → debate_entries (update status, matchId)
Cloud Function → debate_matches (create)
Cloud Function → FCM (send notification)
```

### 3. ディベート開始

```
User → Cloud Function (start debate)
Cloud Function → debate_rooms (create)
Cloud Function → debate_matches (update status, roomId)
```

### 4. メッセージ送信

```
User → debate_rooms/{roomId}/messages (create)
Cloud Function → AI moderation check
Cloud Function → debate_rooms (update messageCount/warningCount)
```

### 5. AI判定

```
Cloud Function → AI API (GPT-4/Gemini)
Cloud Function → debate_judgments (create)
Cloud Function → debate_matches (update scores)
Cloud Function → user_debate_stats (update)
Cloud Function → debate_rankings (update)
Cloud Function → FCM (send result notification)
```

---

## Cloud Functions トリガー

### onCreate Triggers

```javascript
// マッチング成立時の通知
exports.onMatchCreated = functions.firestore
  .document('debate_matches/{matchId}')
  .onCreate(async (snap, context) => {
    // 参加者に通知を送信
  });

// メッセージ作成時のチェック
exports.onMessageCreated = functions.firestore
  .document('debate_rooms/{roomId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    // AIモデレーションチェック
    // スパム検出
  });
```

### onUpdate Triggers

```javascript
// ルームステータス更新時
exports.onRoomStatusUpdated = functions.firestore
  .document('debate_rooms/{roomId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (after.status === 'judging' && before.status !== 'judging') {
      // AI判定を実行
    }
  });
```

### Scheduled Functions

```javascript
// マッチング処理（1分ごと）
exports.scheduledMatching = functions.pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    // 待機中のエントリーをマッチング
  });

// 月次ランキング更新（毎月1日）
exports.monthlyRankingUpdate = functions.pubsub
  .schedule('0 0 1 * *')
  .onRun(async (context) => {
    // ランキングをリセット
  });
```

---

## パフォーマンス最適化

### 1. 複合インデックスの活用

必要な複合インデックスはFirebase Consoleで自動提案されます。

### 2. キャッシング戦略

```dart
// Riverpodでキャッシュ
final eventListProvider = FutureProvider.autoDispose((ref) async {
  return await debateRepository.getEvents();
});
```

### 3. ページネーション

```dart
Query query = firestore
  .collection('debate_events')
  .orderBy('scheduledAt', descending: false)
  .limit(20);
```

### 4. リアルタイムリスナーの最小化

必要な画面でのみリスナーを設定し、離脱時に確実に解除する。

---

## セキュリティベストプラクティス

1. **読み取り制限**: 参加者のみがアクセス可能
2. **書き込み制限**: Cloud Functionsのみが変更可能
3. **検証**: クライアント側とサーバー側の両方で検証
4. **レート制限**: メッセージ送信頻度の制限
5. **コンテンツモデレーション**: AIによる不適切コンテンツ検出

---

## 今後の拡張

- **音声ディベート**: 音声ファイルのStorage保存
- **観客モード**: 観戦専用ユーザーの追加
- **トーナメント**: 複数ラウンドの管理
- **チーム機能**: 固定チームの作成

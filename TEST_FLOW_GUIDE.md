# ディベート機能 完全フローテストガイド

## 準備

### 必要なもの
- 2つのユーザーアカウント（または1つのアカウント + テストエントリー）
- デバッグページへのアクセス

## テスト手順

### ステップ1: イベント作成（現在時刻から3分後のイベント）

1. Firestore Consoleを開く
   - https://console.firebase.google.com/project/tyarekyara-85659/firestore

2. `debate_events` コレクションに新しいドキュメントを作成
   - ドキュメントID: 自動生成

3. 以下のフィールドを設定:

```javascript
{
  "id": "test-event-001",  // 自動生成されたIDと同じ値
  "title": "テストイベント",
  "topic": "AIは人間の仕事を奪うか",
  "description": "フルフローテスト用イベント",
  "status": "accepting",  // エントリー受付中
  "scheduledAt": Timestamp(現在時刻 + 3分),  // 例: 10:03なら10:06
  "entryDeadline": Timestamp(現在時刻 + 1分),  // 例: 10:03なら10:04
  "createdAt": Timestamp(現在時刻),
  "updatedAt": Timestamp(現在時刻),
  "availableDurations": ["short"],
  "availableFormats": ["oneVsOne"],
  "currentParticipants": 0,
  "maxParticipants": 100,
  "imageUrl": null,
  "metadata": {}
}
```

**重要な時刻設定:**
- `entryDeadline`: **現在時刻 + 1分** （締切）
- `scheduledAt`: **現在時刻 + 3分** （開催）

### ステップ2: エントリー作成（2人分）

#### 方法A: デバッグページを使用

1. アプリでデバッグページを開く
2. 「テストイベント作成」ボタンを押す（イベントが既にある場合はスキップ）
3. 「2人エントリー（1vs1・短）」ボタンを押す
   - これで自動的に2人分のエントリーが作成されます

#### 方法B: 手動でFirestoreに作成

1. `debate_entries` コレクションに2つのドキュメントを作成

**エントリー1:**
```javascript
{
  "userId": "test-user-1",
  "eventId": "test-event-001",
  "preferredDuration": "short",
  "preferredFormat": "oneVsOne",
  "preferredStance": "pro",
  "enteredAt": Timestamp(現在時刻),
  "status": "waiting",
  "matchId": null
}
```

**エントリー2:**
```javascript
{
  "userId": "test-user-2",
  "eventId": "test-event-001",
  "preferredDuration": "short",
  "preferredFormat": "oneVsOne",
  "preferredStance": "con",
  "enteredAt": Timestamp(現在時刻),
  "status": "waiting",
  "matchId": null
}
```

### ステップ3: フローの自動実行を観察

#### タイムライン（現在時刻を10:00として）

**10:00 - エントリー作成完了**
- 2人のユーザーが待機中
- イベントステータス: `accepting`
- エントリーステータス: `waiting`

**10:01 - エントリー締切**
- 5分以内に自動的に以下が実行される:
  - ✅ イベントステータス: `accepting` → `matching`
  - ✅ ディベートルーム作成（`debate_rooms` コレクション）
  - ✅ ルームステータス: `waiting`

**10:01-10:02 - マッチング処理**
- 1分以内に自動的に以下が実行される:
  - ✅ マッチ作成（`debate_matches` コレクション）
  - ✅ マッチステータス: `matched`
  - ✅ エントリーステータス: `waiting` → `matched`
  - ✅ エントリーに`matchId`が設定される
  - ✅ マッチに`roomId`が設定される

**10:02 - ユーザー画面の変化**
- ✅ 待機画面 → マッチ詳細画面へ自動遷移
- 「マッチング成立」が表示される
- 対戦相手の情報が表示される
- 「ディベート開始」ボタンが表示される（まだ押せない状態）

**10:03 - イベント開催時刻**
- 5分以内に自動的に以下が実行される:
  - ✅ イベントステータス: `matching` → `inProgress`
  - ✅ ルームステータス: `waiting` → `inProgress`
  - ✅ マッチステータス: `matched` → `inProgress`
  - ✅ ルームに`startedAt`が設定される
  - ✅ ルームの`phaseTimeRemaining`が設定される

**10:03+ - ディベート画面へ自動遷移**
- ✅ マッチ詳細画面 → ディベート画面へ自動遷移
- ディベートルームが表示される
- チャットが使用可能になる
- タイマーが動き始める

## 確認ポイント

### Firestoreで確認すべきこと

#### 1. `debate_events` コレクション
```
status: "accepting" → "matching" → "inProgress"
```

#### 2. `debate_entries` コレクション
```
status: "waiting" → "matched"
matchId: null → "match-xxx"
```

#### 3. `debate_matches` コレクション（新規作成される）
```javascript
{
  "id": "match-xxx",
  "eventId": "test-event-001",
  "format": "oneVsOne",
  "duration": "short",
  "proTeam": {
    "stance": "pro",
    "memberIds": ["test-user-1"],
    "score": 0
  },
  "conTeam": {
    "stance": "con",
    "memberIds": ["test-user-2"],
    "score": 0
  },
  "status": "matched" → "inProgress",
  "matchedAt": Timestamp,
  "roomId": "room-xxx",  // ルームIDが設定される
  "startedAt": Timestamp  // 開催時刻になると設定される
}
```

#### 4. `debate_rooms` コレクション（新規作成される）
```javascript
{
  "id": "room-xxx",
  "eventId": "test-event-001",
  "matchId": "match-xxx",
  "participantIds": ["test-user-1", "test-user-2"],
  "participantStances": {
    "test-user-1": "pro",
    "test-user-2": "con"
  },
  "status": "waiting" → "inProgress",
  "currentPhase": "preparation",
  "phaseTimeRemaining": 30,  // 開催時刻になると設定される
  "startedAt": null → Timestamp  // 開催時刻になると設定される
}
```

### アプリ画面で確認すべきこと

#### エントリー後（10:00）
- [ ] 待機画面が表示される
- [ ] 「マッチング中」と表示される
- [ ] 待機時間カウンターが動いている

#### マッチング成立後（10:01-10:02）
- [ ] 自動的にマッチ詳細画面に遷移
- [ ] 「マッチングが成立しました！」と表示
- [ ] 対戦相手のチーム情報が表示される
- [ ] 自分のチーム（賛成 or 反対）が表示される

#### イベント開催後（10:03+）
- [ ] 自動的にディベート画面に遷移
- [ ] ディベートルームが表示される
- [ ] タイマーが動き始める
- [ ] チャットが使用可能

## トラブルシューティング

### ケース1: 締切後もイベントステータスが変わらない

**原因:** Cloud Functionsの実行待ち（最大5分）

**対処法:**
1. Firebase Consoleでログを確認
2. または手動実行:
```dart
// デバッグページに手動実行ボタンを追加
FirebaseFunctions.instance
  .httpsCallable('manualEventStatusUpdate')
  .call();
```

### ケース2: マッチング処理が実行されない

**原因:** マッチング条件が合わない

**確認:**
- 両方のエントリーの`preferredDuration`が同じか
- 両方のエントリーの`preferredFormat`が同じか
- 両方のエントリーの`status`が`waiting`か

### ケース3: ルームが作成されない

**原因:** マッチが作成されていない

**確認:**
1. `debate_matches`コレクションを確認
2. Cloud Functionsのログを確認:
   - Firebase Console → Functions → Logs
   - `scheduledMatching`のログを見る

### ケース4: 画面が自動遷移しない

**原因:** Providerが更新を検知していない

**対処法:**
1. アプリを再起動
2. または画面をリロード（戻る→再度開く）

## ログの確認方法

### Firebase Console
```
Firebase Console → Functions → Logs
```

確認すべきログ:
- `scheduledEventStatusUpdate`: イベントステータス更新
- `scheduledMatching`: マッチング処理
- `Creating room for match`: ルーム作成
- `Activated X rooms for event`: ルームアクティブ化

### コマンドライン
```bash
firebase functions:log
```

## クイックテスト（即座にテスト）

時間を待ちたくない場合:

### 方法1: 手動実行関数を使う

デバッグページに以下のボタンを追加:

```dart
ElevatedButton(
  onPressed: () async {
    await FirebaseFunctions.instance
      .httpsCallable('manualEventStatusUpdate')
      .call();
  },
  child: Text('イベントステータス更新'),
)
```

### 方法2: Firestoreで直接操作

1. イベントステータスを手動で変更:
   - `accepting` → `matching`
2. 手動マッチング実行:
   - デバッグページの「手動マッチング実行」ボタン
3. ルームを手動でアクティブ化:
   - `debate_rooms`の`status`を`inProgress`に変更

## 成功の判定基準

✅ 以下がすべて自動的に実行されれば成功:

1. エントリー締切後、イベントステータスが`matching`になる
2. ディベートルームが作成される
3. マッチングが実行され、マッチが作成される
4. 待機画面からマッチ詳細画面へ遷移する
5. 開催時刻後、ルームがアクティブになる
6. マッチ詳細画面からディベート画面へ遷移する
7. ディベートが開始できる状態になる

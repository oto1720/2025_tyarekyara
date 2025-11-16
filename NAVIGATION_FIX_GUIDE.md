# 画面遷移問題の修正ガイド

## 問題の概要

マッチングは成功していて`debate_matches`コレクションにデータも追加されているが、画面遷移が全く動作していない問題が発生していました。

### 症状
1. マッチング成立後、マッチ詳細画面に遷移しない
2. 待機画面から移動しない
3. ボトムナビゲーションのディベートタブを押しても反応しない

## 根本原因

### 原因1: `debateRoomByMatchProvider`がFutureProviderだった

**問題のコード（修正前）:**
```dart
// lib/feature/debate/providers/debate_room_provider.dart
final debateRoomByMatchProvider = FutureProvider.autoDispose.family<DebateRoom?, String>(
  (ref, matchId) async {
    final repository = ref.watch(debateRoomRepositoryProvider);
    return await repository.getRoomByMatchId(matchId);
  },
);
```

**問題点:**
- `FutureProvider`は一度だけデータを取得する（リアルタイム更新なし）
- 待機画面表示時点ではルームがまだ作成されていない → `null`を返す
- 後でCloud Functionsがルームを作成しても、Providerは更新を検知しない
- 結果として、画面遷移のトリガーが発火しない

### 原因2: 待機画面の複雑なネスト構造

**問題のコード（修正前）:**
```dart
// lib/feature/debate/presentation/pages/debate_waiting_room_page.dart
if (entry.status == MatchStatus.matched && entry.matchId != null) {
  final roomAsync = ref.watch(debateRoomByMatchProvider(entry.matchId!));

  return roomAsync.when(
    data: (room) {
      if (room != null && room.status == RoomStatus.inProgress) {
        // ルームがアクティブ → ディベート画面へ
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ... 画面遷移
        });
      } else {
        // ルームは作成済みだが待機中 → マッチ詳細画面へ
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ... 画面遷移
        });
      }
    },
    loading: () { /* ... */ },
    error: (_, __) { /* ... */ },
  );
}
```

**問題点:**
- FutureProviderなので、最初に`null`を返すと、その後更新されない
- ネストが深く、デバッグが困難
- 責務が混在している（待機画面がルーム状態まで監視）

## 修正内容

### 修正1: リポジトリに`watchRoomByMatchId`メソッドを追加

**ファイル:** `lib/feature/debate/repositories/debate_room_repository.dart`

```dart
/// マッチIDからルームをリアルタイム監視
Stream<DebateRoom?> watchRoomByMatchId(String matchId) {
  return _firestore
      .collection(_roomsCollectionName)
      .where('matchId', isEqualTo: matchId)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    return DebateRoom.fromJson(snapshot.docs.first.data());
  });
}
```

**効果:**
- Firestoreの変更をリアルタイムで監視
- ルームが作成されたら即座に検知できる

### 修正2: `debateRoomByMatchProvider`をStreamProviderに変更

**ファイル:** `lib/feature/debate/providers/debate_room_provider.dart`

```dart
/// マッチIDからルーム取得 Provider（リアルタイム監視）
final debateRoomByMatchProvider = StreamProvider.autoDispose.family<DebateRoom?, String>(
  (ref, matchId) {
    final repository = ref.watch(debateRoomRepositoryProvider);
    return repository.watchRoomByMatchId(matchId);
  },
);
```

**効果:**
- リアルタイムでデータ更新を受け取れる
- ルームが作成されると自動的にProviderが更新される

### 修正3: 待機画面のロジックを簡素化

**ファイル:** `lib/feature/debate/presentation/pages/debate_waiting_room_page.dart`

**修正前（複雑）:**
```dart
if (entry.status == MatchStatus.matched && entry.matchId != null) {
  final roomAsync = ref.watch(debateRoomByMatchProvider(entry.matchId!));
  return roomAsync.when(
    data: (room) {
      if (room != null && room.status == RoomStatus.inProgress) {
        // ディベート画面へ
      } else {
        // マッチ詳細画面へ
      }
    },
    // ... loading, error
  );
}
```

**修正後（シンプル）:**
```dart
// マッチング成立チェック - マッチ詳細画面へ
if (entry.status == MatchStatus.matched && entry.matchId != null) {
  // マッチング成立したらマッチ詳細画面へ遷移
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        '/debate/match/${entry.matchId}',
      );
    }
  });
  return const Center(child: CircularProgressIndicator());
}
```

**変更点:**
- 待機画面はルーム状態を監視しない
- マッチング成立 = マッチ詳細画面へ遷移（シンプル）
- ルーム監視はマッチ詳細画面の責務

### 修正4: 不要なインポートを削除

**ファイル:** `lib/feature/debate/presentation/pages/debate_waiting_room_page.dart`

```dart
// 削除したインポート
// import '../../models/debate_room.dart';
// import '../../providers/debate_room_provider.dart';
```

**理由:** 待機画面でルーム監視をやめたため不要になった

## 画面遷移フロー（修正後）

### 正しいフロー

```
1. ユーザーがエントリー
   ↓
2. 待機画面表示
   ↓ (エントリーステータスをリアルタイム監視)
3. マッチング成立（entry.status = "matched"）
   ↓ (自動遷移)
4. マッチ詳細画面へ
   ↓ (ルームステータスをリアルタイム監視)
5. ルームがアクティブ化（room.status = "inProgress"）
   ↓ (自動遷移)
6. ディベート画面へ
   ↓
7. ディベート開始
```

### 各画面の責務

**待機画面（DebateWaitingRoomPage）:**
- ✅ エントリーステータスを監視
- ✅ マッチング成立を検知
- ✅ マッチ詳細画面への遷移
- ❌ ルーム状態は監視しない

**マッチ詳細画面（DebateMatchDetailPage）:**
- ✅ マッチ情報を表示
- ✅ ルームステータスを監視
- ✅ ルームアクティブ化を検知
- ✅ ディベート画面への遷移

**ディベート画面（DebateRoomPage）:**
- ✅ ディベート実施
- ✅ メッセージ送受信

## テスト方法

### 1. マッチング → 画面遷移のテスト

```bash
# 1. イベントを作成（Firestoreまたはデバッグページ）
# 2. 2人分のエントリーを作成
# 3. デバッグページで手動マッチング実行
```

**期待される動作:**
1. マッチング成功メッセージが表示される
2. 即座にマッチ詳細画面に遷移する
3. 対戦相手の情報が表示される

### 2. ルームアクティブ化 → ディベート開始のテスト

```bash
# 1. マッチ詳細画面まで進む
# 2. イベント開催時刻を待つ（または手動でルームステータスを変更）
```

**期待される動作:**
1. イベント開催時刻になる
2. Cloud Functionsがルームを`inProgress`に変更
3. 自動的にディベート画面に遷移する

### 3. ボトムナビゲーションのテスト

```bash
# 1. アプリのどの画面からでもOK
# 2. ボトムナビゲーションの「ディベート」タブをタップ
```

**期待される動作:**
1. ディベートイベント一覧画面（DebateEventListPage）に遷移する

## デバッグ方法

### Providerの更新を確認する

```dart
// 待機画面でエントリーステータスをログ出力
final entryAsync = ref.watch(userEntryProvider((widget.eventId, userId)));
entryAsync.whenData((entry) {
  print('Entry status: ${entry?.status}, matchId: ${entry?.matchId}');
});

// マッチ詳細画面でルームステータスをログ出力
final roomAsync = ref.watch(roomDetailProvider(match.roomId!));
roomAsync.whenData((room) {
  print('Room status: ${room?.status}');
});
```

### Firestoreの状態を確認する

**Firebase Console → Firestore:**

1. `debate_entries` コレクション
   - `status`が`"matched"`になっているか
   - `matchId`が設定されているか

2. `debate_matches` コレクション
   - マッチが作成されているか
   - `roomId`が設定されているか

3. `debate_rooms` コレクション
   - ルームが作成されているか
   - `matchId`が正しく設定されているか
   - `status`が適切に変更されているか

## 解決した問題

✅ マッチング成立後、自動的にマッチ詳細画面に遷移するようになった
✅ イベント開催時刻になると、自動的にディベート画面に遷移するようになった
✅ リアルタイム更新により、即座に画面遷移が発火する
✅ コードがシンプルになり、デバッグしやすくなった
✅ 各画面の責務が明確になった

## まだ残っている課題

### 課題1: ルームが作成されない問題

**状況:**
- イベントステータスが`accepting` → `inProgress`に直接遷移
- `matching`ステータスをスキップしたため、ルーム作成処理が実行されない

**対処法:**
1. テストイベントのステータスを手動で`matching`に戻す
2. デバッグページで「イベントステータス更新」を実行
3. または既存マッチに対してルームを作成する関数を追加

### 課題2: 既存マッチへのルーム作成

現状、ルーム作成は以下のタイミングで実行される:
- イベントステータスが`accepting` → `matching`に変更されたとき

既にマッチが作成済みでルームがない場合:
1. Firestoreで直接ルームを作成
2. または専用の関数を追加する必要がある

## まとめ

今回の修正により、画面遷移の基本的な仕組みは正常に動作するようになりました。

**キーポイント:**
1. `StreamProvider`を使うことでリアルタイム更新を実現
2. 各画面の責務を明確に分離
3. シンプルな遷移ロジックでデバッグしやすく

次のステップは、Cloud Functionsによる自動ルーム作成が正しく動作することを確認することです。

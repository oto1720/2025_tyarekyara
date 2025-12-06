# Block Feature

## 概要

Block機能は、ユーザーが他のユーザーをブロック・ブロック解除するための機能を提供します。ブロックされたユーザーの意見や投稿を非表示にすることで、ユーザーエクスペリエンスを向上させます。

## ディレクトリ構成

```
lib/feature/block/
├── README.md                    # このファイル
├── providers/
│   └── block_providers.dart     # Riverpodプロバイダーの定義
└── repositories/
    └── block_repository.dart    # Firebaseとのデータ通信層
```

## 主要なクラスとその役割

### BlockRepository

**場所**: `lib/feature/block/repositories/block_repository.dart`

**責務**: Firebaseとの通信を担当し、ユーザーのブロック/ブロック解除に関するデータ操作を行います。

**主要メソッド**:

- `blockUser(String blockedUserId)`: 指定したユーザーをブロックする
  - 自分自身のブロックは禁止
  - ログインが必須
  - Firestoreにブロック情報を保存

- `unblockUser(String blockedUserId)`: 指定したユーザーのブロックを解除する

- `isBlocked(String userId)`: 特定のユーザーがブロックされているかを確認する
  - 戻り値: `Future<bool>`

- `getBlockedUserIds()`: ブロックしたユーザーのIDリストを一度だけ取得する
  - 戻り値: `Future<List<String>>`

- `watchBlockedUserIds()`: ブロックしたユーザーのIDリストをリアルタイムで監視する
  - 戻り値: `Stream<List<String>>`

**依存関係**:
- `cloud_firestore`: Firestoreデータベースとの通信
- `firebase_auth`: 現在ログイン中のユーザー情報の取得

### Providers

**場所**: `lib/feature/block/providers/block_providers.dart`

**責務**: Riverpodを使用した状態管理とDI（依存性注入）を提供します。

#### blockRepositoryProvider

```dart
final blockRepositoryProvider = Provider<BlockRepository>((ref) {
  return BlockRepository();
});
```

BlockRepositoryのインスタンスを提供するプロバイダー。

#### blockedUserIdsProvider

```dart
final blockedUserIdsProvider = StreamProvider<List<String>>((ref) {
  final repository = ref.watch(blockRepositoryProvider);
  return repository.watchBlockedUserIds();
});
```

ブロック済みユーザーIDリストをリアルタイムで監視するストリームプロバイダー。
Firestoreの変更を自動的にUIに反映します。

#### isUserBlockedProvider

```dart
final isUserBlockedProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.watch(blockRepositoryProvider);
  return await repository.isBlocked(userId);
});
```

特定のユーザーがブロックされているかをチェックするファミリープロバイダー。
userIdをパラメータとして受け取り、ブロック状態を返します。

#### BlockNotifier & blockNotifierProvider

```dart
class BlockNotifier extends AsyncNotifier<void> {
  Future<void> blockUser(String userId) async { ... }
  Future<void> unblockUser(String userId) async { ... }
}

final blockNotifierProvider = AsyncNotifierProvider<BlockNotifier, void>(() {
  return BlockNotifier();
});
```

ブロック/ブロック解除の操作を管理するNotifier。
AsyncNotifierを使用することで、ローディング状態やエラー状態を適切に管理します。

**依存関係**:
- `flutter_riverpod`: 状態管理とDI
- `../repositories/block_repository.dart`: BlockRepositoryクラス

## Firestoreデータ構造

```
/users/{currentUserId}/blockedUsers/{blockedUserId}
  └─ blockedAt: Timestamp  // ブロックした日時
```

**コレクション階層**:
- ユーザーごとにブロックリストをサブコレクションとして管理
- ドキュメントIDはブロックされたユーザーのUID
- `blockedAt`フィールドでブロックした日時を記録

## 使用方法

### 1. ユーザーをブロックする

```dart
// UIから呼び出す例
ref.read(blockNotifierProvider.notifier).blockUser(targetUserId);
```

### 2. ユーザーのブロックを解除する

```dart
ref.read(blockNotifierProvider.notifier).unblockUser(targetUserId);
```

### 3. 特定のユーザーがブロックされているか確認する

```dart
final isBlocked = ref.watch(isUserBlockedProvider(targetUserId));

isBlocked.when(
  data: (blocked) => Text(blocked ? 'ブロック済み' : 'ブロックしていません'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('エラー: $error'),
);
```

### 4. ブロック済みユーザーIDリストを取得する

```dart
final blockedIds = ref.watch(blockedUserIdsProvider);

blockedIds.when(
  data: (ids) => Text('${ids.length}人をブロック中'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('エラー: $error'),
);
```

## 他のFeatureとの関連

### homeフィーチャーとの連携

Block機能は主に`home`フィーチャーで使用されています。

**使用箇所**:

1. **lib/feature/home/presentation/pages/home_answer.dart**
   - `block_providers.dart`をインポート
   - 意見一覧画面でブロックされたユーザーの意見をフィルタリング

2. **lib/feature/home/providers/opinion_provider.dart**
   - `BlockRepository`をインポート
   - 意見を取得する際にブロックされたユーザーの意見を除外

**連携の流れ**:
```
[UI Layer] home_answer.dart
    ↓ 使用
[Provider Layer] opinion_provider.dart
    ↓ 使用
[Repository Layer] block_repository.dart
    ↓ アクセス
[Data Layer] Firestore
```

## エラーハンドリング

BlockRepositoryは以下のエラーを投げる可能性があります:

1. **ログインが必要です**: ユーザーが未ログイン状態でブロック操作を試みた場合
2. **自分自身をブロックすることはできません**: 自身のUserIdでblockUser()を呼び出した場合

AsyncNotifierを使用しているため、プロバイダー経由で操作を行う場合は、
`AsyncValue`の`error`状態でエラーを受け取ることができます。

## 注意事項

- ブロック機能はFirebase Authenticationの認証状態に依存しています
- ログアウト状態では、ブロック済みユーザーリストは空として扱われます
- ブロック情報はユーザーごとに独立しており、相互ブロックの場合でも各ユーザーが個別に管理します
- リアルタイム更新が必要な場合は`watchBlockedUserIds()`を、一度だけ取得する場合は`getBlockedUserIds()`を使用してください

## 今後の拡張予定

- ブロックされたユーザーの詳細情報（名前、アイコンなど）の取得
- ブロックリストのページネーション対応
- ブロック理由の記録機能
- 相互ブロックの検出機能

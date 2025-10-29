# 認証機能 (Auth Feature)

このディレクトリには、アプリケーションの認証機能に関するすべてのコードが含まれています。

## 目次

- [概要](#概要)
- [ディレクトリー構造](#ディレクトリー構造)
- [主要コンポーネント](#主要コンポーネント)
- [認証フロー](#認証フロー)
- [状態管理アーキテクチャ](#状態管理アーキテクチャ)
- [使用方法](#使用方法)
- [エラーハンドリング](#エラーハンドリング)
- [セキュリティ](#セキュリティ)
- [今後の拡張](#今後の拡張)

---

## 概要

この認証機能は、以下の機能を提供します：

- **ユーザー登録**: メールアドレスとパスワードによる新規アカウント作成
- **ログイン**: 既存アカウントでのログイン
- **ログアウト**: セッションの終了
- **プロフィール設定**: ユーザーのプロフィール情報（アイコン、ニックネーム、年齢、地域）の登録・更新
- **画像アップロード**: Firebase Storageへのプロフィール画像のアップロード

### 技術スタック

- **認証**: Firebase Authentication (Email/Password)
- **データベース**: Cloud Firestore
- **ストレージ**: Firebase Storage
- **状態管理**: Riverpod (NotifierProvider)
- **不変性**: Freezed
- **ルーティング**: GoRouter

---

## ディレクトリー構造

```
lib/feature/auth/
├── models/                          # データモデル
│   └── user/
│       ├── user_model.dart          # ユーザーモデル定義
│       ├── user_model.freezed.dart  # 自動生成（Freezed）
│       └── user_model.g.dart        # 自動生成（JSON）
│
├── providers/                       # 状態管理
│   ├── auth_provider.dart           # 認証のメインProvider
│   ├── auth_state.dart              # 認証状態の定義
│   ├── auth_state.freezed.dart      # 自動生成
│   ├── profile_setup_provider.dart  # プロフィール設定Provider
│   ├── profile_setup_state.dart     # プロフィール設定状態
│   ├── profile_setup_state.freezed.dart
│   └── storage_service_provider.dart # StorageサービスProvider
│
├── repositories/                    # 抽象インターフェース
│   └── auth_repository.dart         # 認証リポジトリの抽象定義
│
├── services/                        # ビジネスロジック実装
│   ├── auth_service.dart            # Firebase認証の実装
│   └── storage_service.dart         # Firebase Storageの実装
│
└── presentaion/                     # UI
    └── pages/
        ├── login.dart               # ログイン画面
        ├── signup_page.dart         # 新規登録画面
        └── profile_setup_page.dart  # プロフィール設定画面
```

---

## 主要コンポーネント

### 1. Models（データモデル）

#### UserModel

**ファイル**: `models/user/user_model.dart`

ユーザー情報を表す不変データクラス。

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,              // Firebase UID
    required String nickname,        // ニックネーム (2-20文字)
    required String email,           // メールアドレス
    @Default('') String ageRange,    // 年齢範囲 (例: "20代")
    @Default('') String region,      // 地域 (都道府県)
    @Default('assets/images/default_avatar.png') String iconUrl,
    required DateTime createdAt,     // 作成日時
    required DateTime updatedAt,     // 更新日時
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
    _$UserModelFromJson(json);
}
```

**特徴**:
- Freezedによる不変性の保証
- JSON シリアライゼーション対応
- デフォルト値の設定

---

### 2. Providers（状態管理）

#### AuthController & AuthState

**ファイル**: `providers/auth_provider.dart`, `providers/auth_state.dart`

認証全般の状態管理を担当。

**AuthState**（5つの状態）:
```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;        // 初期状態
  const factory AuthState.loading() = _Loading;        // 処理中
  const factory AuthState.authenticated(UserModel user) = _Authenticated; // 認証済み
  const factory AuthState.unauthenticated() = _Unauthenticated; // 未認証
  const factory AuthState.error(String message) = _Error; // エラー
}
```

**AuthController**の主要メソッド:

| メソッド | 説明 | パラメータ |
|---------|------|-----------|
| `signUpWithEmail()` | 新規登録 | email, password, nickname |
| `signInWithEmail()` | ログイン | email, password |
| `signOut()` | ログアウト | なし |
| `updateProfile()` | プロフィール更新 | userId, nickname, ageRange, region, iconUrl |
| `fetchUserData()` | ユーザーデータ取得 | userId |

**Providers**:

```dart
// AuthServiceのProvider
final authServiceProvider = Provider<AuthRepository>((ref) {
  return AuthService();
});

// Firebase認証状態のStream
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// 現在ログイン中のユーザー
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = authService.getCurrentUser();
  if (user == null) return null;
  return await authService.getUserData(user.uid);
});

// メインのAuthController
final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
```

#### ProfileSetupNotifier & ProfileSetupState

**ファイル**: `providers/profile_setup_provider.dart`, `providers/profile_setup_state.dart`

プロフィール設定画面専用の状態管理。

**ProfileSetupState**:
```dart
@freezed
class ProfileSetupState with _$ProfileSetupState {
  const factory ProfileSetupState({
    File? selectedImage,           // 選択された画像
    String? selectedAgeRange,      // 選択された年齢範囲
    String? selectedRegion,        // 選択された地域
    @Default(false) bool isUploading, // アップロード中フラグ
    String? errorMessage,          // エラーメッセージ
  }) = _ProfileSetupState;
}
```

**ProfileSetupNotifier**の主要メソッド:

| メソッド | 説明 | 戻り値 |
|---------|------|--------|
| `pickImage()` | ギャラリーから画像を選択 | Future<void> |
| `setAgeRange()` | 年齢範囲を設定 | void |
| `setRegion()` | 地域を設定 | void |
| `saveProfile()` | プロフィールを保存 | Future<bool> |
| `initializeFromUser()` | 既存データで初期化 | void |
| `clearError()` | エラーをクリア | void |
| `reset()` | 状態をリセット | void |

---

### 3. Repositories（抽象インターフェース）

#### AuthRepository

**ファイル**: `repositories/auth_repository.dart`

認証機能の抽象インターフェース。実装の詳細を隠蔽し、テスト可能性を向上。

```dart
abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  });
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  });
  Future<void> signOut();
  User? getCurrentUser();
  Future<void> saveUserData(UserModel user);
  Future<UserModel?> getUserData(String userId);
  Future<void> updateUserData(UserModel user);
}
```

**メリット**:
- 依存性の逆転（DIコンテナで実装を切り替え可能）
- Mockを使った単体テストが容易
- 将来的に別の認証プロバイダーへの移行が容易

---

### 4. Services（ビジネスロジック実装）

#### AuthService

**ファイル**: `services/auth_service.dart`

Firebase AuthenticationとFirestoreを使用した`AuthRepository`の実装。

**主要機能**:
- Firebase Authentication（Email/Password）
- Firestoreへのユーザーデータ保存（`users`コレクション）
- エラーハンドリング（日本語メッセージ）

**Firestoreデータ構造**:
```
users/
  └── {userId}/
      ├── id: string
      ├── nickname: string
      ├── email: string
      ├── ageRange: string
      ├── region: string
      ├── iconUrl: string
      ├── createdAt: timestamp
      └── updatedAt: timestamp
```

**エラーコードと日本語メッセージのマッピング**:

| Firebaseエラーコード | 日本語メッセージ |
|---------------------|--------------|
| `weak-password` | パスワードが弱すぎます（6文字以上） |
| `email-already-in-use` | このメールアドレスは既に使用されています |
| `user-not-found` | ユーザーが見つかりません |
| `wrong-password` | パスワードが間違っています |
| `invalid-email` | 無効なメールアドレスです |
| `user-disabled` | このアカウントは無効化されています |

#### StorageService

**ファイル**: `services/storage_service.dart`

Firebase Storageへの画像アップロード機能。

**主要機能**:
```dart
class StorageService {
  // プロフィール画像をアップロード
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  });

  // プロフィール画像を削除
  Future<void> deleteProfileImage(String imageUrl);
}
```

**ストレージパス**: `profile_images/{userId}.{拡張子}`

**画像仕様**:
- 最大サイズ: 1024x1024
- 画質: 85%
- サポート形式: jpg, png, webp など

---

### 5. Presentation（UI）

#### LoginPage

**ファイル**: `presentaion/pages/login.dart`

**機能**:
- メールアドレス・パスワード入力
- バリデーション
  - メールアドレス: 正規表現による形式チェック
  - パスワード: 必須
- ログインボタン（ローディング表示対応）
- 新規登録へのリンク
- 「パスワードを忘れた場合」（TODO）

**使用Widget**:
- `CustomTextField`: 共通テキストフィールド
- `CustomButton`: 共通ボタン

**状態監視**:
```dart
ref.listen<AuthState>(authControllerProvider, (previous, next) {
  next.when(
    authenticated: (user) => context.go('/'),  // ホーム画面へ
    error: (message) => showSnackBar(message),
    // ...
  );
});
```

#### SignUpPage

**ファイル**: `presentaion/pages/signup_page.dart`

**機能**:
- ニックネーム、メールアドレス、パスワード、パスワード確認の入力
- バリデーション
  - ニックネーム: 2-20文字
  - メールアドレス: 正規表現による形式チェック
  - パスワード: 6文字以上
  - パスワード確認: パスワードと一致
- パスワードの表示/非表示切り替え
- 登録成功後、プロフィール設定画面へ遷移

**フロー**:
1. フォーム入力
2. バリデーション
3. Firebase Authenticationでアカウント作成
4. Firestoreにユーザーデータ保存
5. `/profile-setup` へ遷移

#### ProfileSetupPage

**ファイル**: `presentaion/pages/profile_setup_page.dart`

**機能**:
- プロフィール画像選択（ギャラリーから）
- ニックネーム入力（2-20文字）
- 年齢選択（ドロップダウン: 10歳未満〜90代）
- 地域選択（ドロップダウン: 47都道府県）

**特徴**:
- **setStateを使用しない**: すべての状態はProviderで管理
- **リアクティブUI**: Providerの状態変更で自動リビルド
- **エラーハンドリング**: SnackBarでユーザーフレンドリーな通知

**状態管理の例**:
```dart
// 画像選択（setStateなし）
ref.read(profileSetupProvider.notifier).pickImage();

// 年齢範囲設定
ref.read(profileSetupProvider.notifier).setAgeRange('20代');

// 状態の監視
final profileState = ref.watch(profileSetupProvider);
```

**保存フロー**:
1. フォームバリデーション
2. 必須項目チェック（年齢、地域）
3. 画像が選択されている場合、Firebase Storageにアップロード
4. ダウンロードURLを取得
5. Firestoreのユーザーデータを更新
6. 成功時、ホーム画面へ遷移

---

## 認証フロー

### 1. 新規登録フロー

```
[SignUpPage]
    ↓ ユーザー入力
    ↓ (nickname, email, password)
    ↓
[AuthController.signUpWithEmail()]
    ↓
[AuthService.signUpWithEmail()]
    ↓ Firebase Authentication
    ↓ アカウント作成
    ↓
[AuthService.saveUserData()]
    ↓ Firestore
    ↓ users/{userId}に保存
    ↓
[AuthState.authenticated(user)]
    ↓
[ProfileSetupPage]
    ↓ プロフィール入力
    ↓ (icon, ageRange, region)
    ↓
[ProfileSetupNotifier.saveProfile()]
    ↓
[StorageService.uploadProfileImage()] (画像が選択されている場合)
    ↓ Firebase Storage
    ↓ profile_images/{userId}
    ↓ ダウンロードURL取得
    ↓
[AuthController.updateProfile()]
    ↓ Firestore更新
    ↓
[HomeScreen]
```

### 2. ログインフロー

```
[LoginPage]
    ↓ ユーザー入力
    ↓ (email, password)
    ↓
[AuthController.signInWithEmail()]
    ↓
[AuthService.signInWithEmail()]
    ↓ Firebase Authentication
    ↓ 認証
    ↓
[AuthService.getUserData()]
    ↓ Firestore
    ↓ users/{userId}取得
    ↓
[AuthState.authenticated(user)]
    ↓
[HomeScreen]
```

### 3. ログアウトフロー

```
[任意の画面]
    ↓
[AuthController.signOut()]
    ↓
[AuthService.signOut()]
    ↓ Firebase Authentication
    ↓ サインアウト
    ↓
[AuthState.unauthenticated()]
    ↓
[LoginPage]
```

### 4. 認証状態の監視

```dart
// アプリ起動時、Firebase認証状態をStreamで監視
authStateChangesProvider
    ↓
Firebase.authStateChanges (Stream<User?>)
    ↓
currentUserProvider (ユーザーがいればFirestoreからデータ取得)
    ↓
画面のリビルド
```

---

## 状態管理アーキテクチャ

このプロジェクトでは、Riverpodを使用した状態管理を採用しています。

### 設計原則

1. **単一責任の原則**: 各Providerは1つの責務のみを持つ
2. **不変性**: Freezedを使用して状態を不変に保つ
3. **宣言的UI**: UIはProviderの状態を監視し、自動的にリビルド
4. **ビジネスロジックとUIの分離**: Notifierでロジックをカプセル化

### Provider の種類と使い分け

#### 1. Provider（不変）

サービスやリポジトリのシングルトンインスタンスを提供。

```dart
final authServiceProvider = Provider<AuthRepository>((ref) {
  return AuthService();
});
```

**用途**: DI（依存性注入）

#### 2. StreamProvider（リアクティブ）

Firebase認証状態などのStreamを監視。

```dart
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
```

**用途**: リアルタイム更新が必要なデータ

#### 3. FutureProvider（非同期）

非同期でデータを取得。

```dart
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  // ユーザーデータを非同期取得
});
```

**用途**: 初回ロード時のデータ取得

#### 4. NotifierProvider（状態管理）

ミュータブルな状態とロジックを管理。

```dart
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
```

**用途**: 複雑な状態管理とビジネスロジック

### ref の使い分け

#### ref.watch()
- **用途**: 値の監視（値が変わると自動リビルド）
- **使用場所**: buildメソッド内

```dart
final authState = ref.watch(authControllerProvider);
```

#### ref.listen()
- **用途**: 副作用の実行（SnackBar表示、画面遷移など）
- **使用場所**: buildメソッド内

```dart
ref.listen<AuthState>(authControllerProvider, (previous, next) {
  next.when(
    authenticated: (user) => context.go('/'),
    error: (message) => showSnackBar(message),
    // ...
  );
});
```

#### ref.read()
- **用途**: 一度だけ値を読む、メソッドを呼び出す
- **使用場所**: イベントハンドラ内

```dart
onPressed: () {
  ref.read(authControllerProvider.notifier).signOut();
}
```

---

## 使用方法

### 新しい画面から認証機能を使う

#### 1. 現在のユーザー情報を取得

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user == null) {
          return Text('ログインしていません');
        }
        return Text('こんにちは、${user.nickname}さん');
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('エラー: $error'),
    );
  }
}
```

#### 2. ログアウト機能を追加

```dart
ElevatedButton(
  onPressed: () {
    ref.read(authControllerProvider.notifier).signOut();
  },
  child: Text('ログアウト'),
)
```

#### 3. プロフィール更新

```dart
Future<void> updateNickname(String newNickname) async {
  final user = ref.read(currentUserProvider).value;
  if (user == null) return;

  await ref.read(authControllerProvider.notifier).updateProfile(
    userId: user.id,
    nickname: newNickname,
    ageRange: user.ageRange,
    region: user.region,
    iconUrl: user.iconUrl,
  );
}
```

#### 4. 認証状態に応じて画面を切り替える

```dart
// app_router.dart での例
final authStateAsync = ref.watch(authStateChangesProvider);

authStateAsync.when(
  data: (user) {
    if (user == null) {
      return '/login';  // 未認証 → ログイン画面
    }
    return '/';  // 認証済み → ホーム画面
  },
  loading: () => '/splash',
  error: (_, __) => '/error',
);
```

### 新しいプロバイダーを作成する場合

例: プロフィール編集画面用のProvider

```dart
// 1. 状態を定義（Freezed）
@freezed
class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState({
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _ProfileEditState;
}

// 2. Notifierを作成
class ProfileEditNotifier extends Notifier<ProfileEditState> {
  @override
  ProfileEditState build() => const ProfileEditState();

  Future<void> save({required String nickname}) async {
    state = state.copyWith(isSaving: true);
    try {
      // 保存処理
      await ref.read(authControllerProvider.notifier).updateProfile(...);
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// 3. Providerを公開
final profileEditProvider =
    NotifierProvider<ProfileEditNotifier, ProfileEditState>(() {
  return ProfileEditNotifier();
});
```

---

## エラーハンドリング

### エラーの種類

1. **Firebase Authenticationエラー**
   - 弱いパスワード
   - メールアドレス重複
   - 認証情報の誤り

2. **Firestoreエラー**
   - 権限エラー
   - ネットワークエラー
   - データ不整合

3. **Firebase Storageエラー**
   - アップロード失敗
   - 容量制限
   - 権限エラー

4. **バリデーションエラー**
   - 必須項目の未入力
   - 形式不正（メール、パスワードなど）

### エラー表示方法

#### 1. AuthStateのerror状態

```dart
ref.listen<AuthState>(authControllerProvider, (previous, next) {
  next.when(
    error: (message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    },
    // ...
  );
});
```

#### 2. ProfileSetupStateのerrorMessage

```dart
ref.listen(profileSetupProvider, (previous, next) {
  if (next.errorMessage != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next.errorMessage!)),
    );
  }
});
```

#### 3. FormValidation

```dart
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'メールアドレスは必須です';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return '有効なメールアドレスを入力してください';
  }
  return null;
}
```

### エラーハンドリングのベストプラクティス

1. **ユーザーフレンドリーなメッセージ**: 技術的な詳細を隠し、わかりやすい日本語で表示
2. **色分け**: エラーレベルに応じた色（赤=エラー、オレンジ=警告）
3. **自動クリア**: エラー表示後、状態をクリアしてUI更新を防ぐ
4. **ロギング**: 本番環境ではエラーログを記録（Firebase Crashlyticsなど）

---

## セキュリティ

### 実装されているセキュリティ対策

1. **パスワード**
   - 最低6文字（Firebase Authenticationの制約）
   - クライアント側でハッシュ化せず、Firebase側で管理
   - パスワード確認による誤入力防止

2. **メールアドレス**
   - 形式検証（正規表現）
   - Firebase Authenticationによる重複チェック

3. **Firestore Security Rules**（要設定）
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // ユーザーは自分のデータのみ読み書き可能
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

4. **Firebase Storage Security Rules**（要設定）
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       // ユーザーは自分のプロフィール画像のみアップロード可能
       match /profile_images/{userId}.{ext} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

### セキュリティチェックリスト

- [ ] Firestore Security Rulesを設定済み
- [ ] Firebase Storage Security Rulesを設定済み
- [ ] パスワードをログに出力していない
- [ ] APIキーを環境変数で管理（`firebase_options.dart`）
- [ ] HTTPS通信のみ使用
- [ ] 画像サイズ・形式の検証

### 今後実装すべきセキュリティ機能

- [ ] メール認証（Email Verification）
- [ ] パスワードリセット
- [ ] 2段階認証
- [ ] レート制限（ログイン試行回数制限）
- [ ] セッションタイムアウト
- [ ] 機密情報のマスキング

---

## 今後の拡張

### 予定されている機能

1. **パスワードリセット**
   - メールによるパスワードリセットリンク送信
   - 新しいパスワードの設定画面

2. **メール認証**
   - 新規登録時に認証メール送信
   - メール認証完了後のみログイン可能

3. **ソーシャルログイン**
   - Google認証
   - Apple認証

4. **プロフィール編集**
   - ログイン後にプロフィールを編集可能
   - 画像のトリミング機能

5. **アカウント削除**
   - ユーザー自身によるアカウント削除
   - 関連データの完全削除

6. **セッション管理**
   - 自動ログアウト
   - リフレッシュトークン

### 拡張時の注意点

1. **Provider の追加**
   - 新しいProviderを追加する際は、責務を明確に分離
   - 既存のProviderとの依存関係を最小限に

2. **状態の設計**
   - Freezedを使用して不変性を保つ
   - sealed classによるパターンマッチングを活用

3. **テスト**
   - 単体テストを必ず作成
   - Mockを使用してProviderをテスト

4. **ドキュメント更新**
   - 新機能追加時は必ずこのREADMEを更新
   - コード内のコメントも充実

---

## トラブルシューティング

### よくある問題

#### 1. ログイン後に画面が遷移しない

**原因**: `authStateChangesProvider`が正しく監視されていない

**解決策**:
```dart
// app_router.dartでリダイレクト設定を確認
redirect: (context, state) {
  final authStateAsync = ref.watch(authStateChangesProvider);
  // ...
}
```

#### 2. プロフィール画像がアップロードできない

**原因**: Firebase Storage Security Rulesが設定されていない

**解決策**: Firebaseコンソールで適切なルールを設定

#### 3. Freezedファイルが生成されない

**原因**: build_runnerが実行されていない

**解決策**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 4. 画像選択時にクラッシュ（iOS）

**原因**: `Info.plist`に権限の記述がない

**解決策**: `ios/Runner/Info.plist`に以下を追加
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>プロフィール画像を設定するために写真ライブラリへのアクセスが必要です</string>
```

#### 5. Android で画像選択時にクラッシュ

**原因**: `AndroidManifest.xml`に権限の記述がない

**解決策**: `android/app/src/main/AndroidManifest.xml`に追加
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

## 参考資料

### 公式ドキュメント

- [Firebase Authentication - Flutter](https://firebase.google.com/docs/auth/flutter/start)
- [Cloud Firestore - Flutter](https://firebase.google.com/docs/firestore/quickstart?hl=ja#flutter)
- [Firebase Storage - Flutter](https://firebase.google.com/docs/storage/flutter/start)
- [Riverpod](https://riverpod.dev/)
- [Freezed](https://pub.dev/packages/freezed)
- [GoRouter](https://pub.dev/packages/go_router)

### コーディング規約

- Dartの命名規則に従う（lowerCamelCase, UpperCamelCase）
- 1ファイル1クラスを原則とする
- コメントは日本語でわかりやすく記述
- Providerの命名: `{機能名}Provider`（例: `authControllerProvider`）
- Stateの命名: `{機能名}State`（例: `ProfileSetupState`）

---

## 変更履歴

### v1.0.0 (2025-01-XX)

- 初版リリース
- 基本的な認証機能（登録、ログイン、ログアウト）
- プロフィール設定機能
- 画像アップロード機能
- Riverpodによる状態管理のリファクタリング

---

## 貢献

新しい機能を追加した場合は、以下を必ず実施してください：

1. このREADMEを更新
2. テストコードを追加
3. コードレビューを受ける

---

## ライセンス

このプロジェクトのライセンスについては、プロジェクトルートの`LICENSE`ファイルを参照してください。

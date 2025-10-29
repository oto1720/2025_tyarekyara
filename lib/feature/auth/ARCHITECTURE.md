# 認証機能 アーキテクチャ設計書

## 概要

このドキュメントでは、認証機能のアーキテクチャ設計について詳細に説明します。

---

## アーキテクチャの全体像

```
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  LoginPage   │  │ SignUpPage   │  │ProfileSetup  │         │
│  │              │  │              │  │    Page      │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                  │                  │                  │
│         └──────────────────┼──────────────────┘                  │
│                            │                                     │
└────────────────────────────┼─────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────────┐
│                    Provider Layer (Riverpod)                     │
│                            │                                     │
│  ┌─────────────────────────▼────────────────────────┐           │
│  │        authControllerProvider                     │           │
│  │    (NotifierProvider<AuthController, AuthState>)  │           │
│  └─────────────────────────┬────────────────────────┘           │
│                            │                                     │
│  ┌─────────────────────────▼────────────────────────┐           │
│  │        profileSetupProvider                       │           │
│  │ (NotifierProvider<ProfileSetupNotifier, ...>)     │           │
│  └─────────────────────────┬────────────────────────┘           │
│                            │                                     │
└────────────────────────────┼─────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────────┐
│                    Repository Layer                              │
│                            │                                     │
│  ┌─────────────────────────▼────────────────────────┐           │
│  │           AuthRepository (Interface)              │           │
│  │  • signUpWithEmail()                              │           │
│  │  • signInWithEmail()                              │           │
│  │  • signOut()                                      │           │
│  │  • saveUserData()                                 │           │
│  │  • getUserData()                                  │           │
│  └─────────────────────────┬────────────────────────┘           │
│                            │                                     │
└────────────────────────────┼─────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────────┐
│                      Service Layer                               │
│                            │                                     │
│  ┌─────────────────────────▼────────────────────────┐           │
│  │          AuthService (Implementation)             │           │
│  │  • Firebase Authentication                        │           │
│  │  • Cloud Firestore                                │           │
│  └───────────────────────────────────────────────────┘           │
│                                                                  │
│  ┌───────────────────────────────────────────────────┐          │
│  │          StorageService                            │          │
│  │  • Firebase Storage                                │          │
│  │  • 画像アップロード/削除                              │          │
│  └───────────────────────────────────────────────────┘          │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────────┐
│                    Firebase Services                             │
│                            │                                     │
│  ┌──────────────┐  ┌──────▼───────┐  ┌──────────────┐         │
│  │   Firebase   │  │    Cloud     │  │   Firebase   │         │
│  │     Auth     │  │  Firestore   │  │   Storage    │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## レイヤー別の責務

### 1. Presentation Layer（プレゼンテーション層）

**責務**: ユーザーインターフェースの表示と、ユーザー入力の受付

#### 特徴
- Providerの状態を`ref.watch()`で監視
- ユーザーアクションを`ref.read()`でProviderに委譲
- ビジネスロジックを含まない（UIロジックのみ）
- `setState()`を使用しない（Riverpodで状態管理）

#### コンポーネント
- **LoginPage**: ログインフォーム
- **SignUpPage**: 新規登録フォーム
- **ProfileSetupPage**: プロフィール設定フォーム

---

### 2. Provider Layer（状態管理層）

**責務**: アプリケーション状態の管理と、ビジネスロジックの調整

#### AuthController & AuthState

```
AuthState（Sealed Class）
├─ initial()          初期状態
├─ loading()          処理中
├─ authenticated()    認証済み（ユーザー情報を保持）
├─ unauthenticated()  未認証
└─ error()            エラー（エラーメッセージを保持）
```

**状態遷移図**:
```
    initial
       │
       ├─ signUpWithEmail() ─→ loading ─→ authenticated / error
       ├─ signInWithEmail() ─→ loading ─→ authenticated / error
       ├─ signOut()         ─→ loading ─→ unauthenticated / error
       └─ updateProfile()   ─→ loading ─→ authenticated / error
```

#### ProfileSetupNotifier & ProfileSetupState

プロフィール設定画面専用の状態管理。

```
ProfileSetupState（Freezed）
├─ selectedImage      選択された画像ファイル（File?）
├─ selectedAgeRange   選択された年齢範囲（String?）
├─ selectedRegion     選択された地域（String?）
├─ isUploading        アップロード中フラグ（bool）
└─ errorMessage       エラーメッセージ（String?）
```

**メソッド**:
- `pickImage()`: 画像ピッカーを起動
- `setAgeRange()`: 年齢範囲を設定
- `setRegion()`: 地域を設定
- `saveProfile()`: プロフィールを保存（画像アップロード + Firestore更新）

---

### 3. Repository Layer（リポジトリ層）

**責務**: データソースの抽象化と、ドメインロジックの定義

#### AuthRepository（抽象インターフェース）

```dart
abstract class AuthRepository {
  // 認証状態のStream
  Stream<User?> get authStateChanges;

  // 認証操作
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  });
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  });
  Future<void> signOut();

  // ユーザー取得
  User? getCurrentUser();

  // ユーザーデータ操作
  Future<void> saveUserData(UserModel user);
  Future<UserModel?> getUserData(String userId);
  Future<void> updateUserData(UserModel user);
}
```

**メリット**:
1. **依存性の逆転**: 上位層が下位層の実装に依存しない
2. **テスト容易性**: Mockを使った単体テストが簡単
3. **実装の差し替え**: Firebase以外の認証サービスへの移行が容易

---

### 4. Service Layer（サービス層）

**責務**: 外部サービス（Firebase）との通信と、データ変換

#### AuthService（AuthRepositoryの実装）

```
AuthService
├─ Firebase Authentication
│  ├─ createUserWithEmailAndPassword()
│  ├─ signInWithEmailAndPassword()
│  └─ signOut()
│
└─ Cloud Firestore
   ├─ users/{userId}.set()
   ├─ users/{userId}.get()
   └─ users/{userId}.update()
```

**エラーハンドリング**:
- Firebaseのエラーコードを日本語メッセージに変換
- 適切な例外を上位層にスロー

#### StorageService

```
StorageService
└─ Firebase Storage
   ├─ profile_images/{userId}.{ext}
   │  ├─ uploadProfileImage()
   │  └─ deleteProfileImage()
   └─ エラーハンドリング
```

---

## データフロー

### 1. 新規登録のデータフロー

```
[User Input]
    ↓
┌───────────────────────────────────┐
│ SignUpPage                        │
│  - nickname: "太郎"                │
│  - email: "taro@example.com"      │
│  - password: "password123"        │
└───────────────┬───────────────────┘
                ↓ onPressed()
┌───────────────▼───────────────────┐
│ AuthController.signUpWithEmail()  │
│  - バリデーション                  │
│  - state = loading                │
└───────────────┬───────────────────┘
                ↓
┌───────────────▼───────────────────┐
│ AuthService.signUpWithEmail()     │
│  - Firebase Auth認証               │
│  - UserCredential取得              │
└───────────────┬───────────────────┘
                ↓ uid取得
┌───────────────▼───────────────────┐
│ UserModel作成                      │
│  {                                 │
│    id: "firebase_uid",             │
│    nickname: "太郎",               │
│    email: "taro@example.com",     │
│    ageRange: "",                   │
│    region: "",                     │
│    iconUrl: "default.png",        │
│    createdAt: DateTime.now(),     │
│    updatedAt: DateTime.now()      │
│  }                                 │
└───────────────┬───────────────────┘
                ↓
┌───────────────▼───────────────────┐
│ AuthService.saveUserData()        │
│  - Firestore: users/{uid}に保存    │
└───────────────┬───────────────────┘
                ↓
┌───────────────▼───────────────────┐
│ state = authenticated(user)       │
└───────────────┬───────────────────┘
                ↓
┌───────────────▼───────────────────┐
│ ProfileSetupPage                  │
│  - プロフィール設定画面に遷移        │
└───────────────────────────────────┘
```

### 2. プロフィール設定のデータフロー

```
[User Input]
    ↓
┌───────────────────────────────────┐
│ ProfileSetupPage                  │
│  - 画像選択ボタン押下                │
└───────────────┬───────────────────┘
                ↓
┌───────────────▼───────────────────┐
│ ProfileSetupNotifier.pickImage()  │
│  - ImagePicker起動                 │
│  - File取得                        │
│  - state.selectedImage = file     │
└───────────────────────────────────┘
                ↓ 画像プレビュー更新

[User Input]
    ↓ 年齢・地域選択、保存ボタン押下
┌───────────────▼───────────────────┐
│ ProfileSetupNotifier.saveProfile()│
│  - バリデーション                  │
│  - state.isUploading = true       │
└───────────────┬───────────────────┘
                ↓
┌───────────────▼───────────────────┐
│ StorageService.uploadProfileImage()│
│  - Firebase Storageにアップロード   │
│  - ダウンロードURL取得              │
└───────────────┬───────────────────┘
                ↓ iconUrl
┌───────────────▼───────────────────┐
│ AuthController.updateProfile()    │
│  - ユーザーデータ取得               │
│  - copyWith()で更新データ作成       │
└───────────────┬───────────────────┘
                ↓
┌───────────────▼───────────────────┐
│ AuthService.updateUserData()      │
│  - Firestore: users/{uid}を更新    │
└───────────────┬───────────────────┘
                ↓
┌───────────────▼───────────────────┐
│ state = authenticated(updatedUser)│
└───────────────┬───────────────────┘
                ↓
┌───────────────▼───────────────────┐
│ HomeScreen                        │
│  - ホーム画面に遷移                 │
└───────────────────────────────────┘
```

---

## 状態管理の詳細

### Riverpod の Providerタイプ

| Providerタイプ | 用途 | 例 |
|---------------|------|-----|
| `Provider` | 不変の値やシングルトン | `authServiceProvider` |
| `StreamProvider` | リアクティブなStream | `authStateChangesProvider` |
| `FutureProvider` | 非同期データ取得 | `currentUserProvider` |
| `NotifierProvider` | 状態 + ロジック | `authControllerProvider` |

### ref のメソッド

| メソッド | 用途 | 使用場所 |
|---------|------|---------|
| `ref.watch()` | 値を監視（自動リビルド） | `build()`メソッド内 |
| `ref.listen()` | 副作用を実行 | `build()`メソッド内 |
| `ref.read()` | 一度だけ値を読む | イベントハンドラ内 |

### 状態の不変性（Freezed）

```dart
// ❌ NG: 直接変更（ミュータブル）
state.isUploading = true;

// ✅ OK: copyWithで新しい状態を作成（イミュータブル）
state = state.copyWith(isUploading: true);
```

**メリット**:
- 予期しない副作用を防ぐ
- 状態の履歴を追跡可能
- タイムトラベルデバッグが可能

---

## エラーハンドリング戦略

### エラーの伝播

```
Service Layer (例外スロー)
    ↓ try-catch
Provider Layer (状態に変換)
    ↓ ref.listen()
Presentation Layer (UI表示)
```

### エラーの種類と対処

| エラーレベル | 対処方法 | 例 |
|------------|---------|-----|
| **Fatal** | アプリ再起動 | Firebase初期化失敗 |
| **Error** | SnackBar（赤） + ログ | 認証失敗 |
| **Warning** | SnackBar（オレンジ） | 必須項目未入力 |
| **Info** | SnackBar（青） | 保存成功 |

### ログ戦略

```dart
// 開発環境
if (kDebugMode) {
  print('Error: $e');
  print('StackTrace: $stackTrace');
}

// 本番環境（TODO）
// FirebaseCrashlytics.instance.recordError(e, stackTrace);
```

---

## セキュリティアーキテクチャ

### 多層防御

```
┌─────────────────────────────────────┐
│  Client Side Validation              │  ← 1層目
│  (Flutter Form Validation)           │
└───────────────┬─────────────────────┘
                ↓
┌───────────────▼─────────────────────┐
│  Firebase Authentication             │  ← 2層目
│  (Email/Password認証)                 │
└───────────────┬─────────────────────┘
                ↓
┌───────────────▼─────────────────────┐
│  Firestore Security Rules            │  ← 3層目
│  (読み書き権限の制御)                   │
└───────────────┬─────────────────────┘
                ↓
┌───────────────▼─────────────────────┐
│  Storage Security Rules              │  ← 4層目
│  (ファイルアクセス制御)                  │
└─────────────────────────────────────┘
```

### 認証フロー

```
User
 ↓ (1) ログイン
Firebase Authentication
 ↓ (2) IDトークン発行
 ↓ (3) 自動的に各リクエストに添付
Firestore / Storage
 ↓ (4) Security Rulesで検証
 ↓ (5) request.auth.uid をチェック
許可 / 拒否
```

---

## パフォーマンス最適化

### 1. Riverpodの自動最適化

- **細かい粒度のProvider**: 必要な部分だけリビルド
- **select()による部分監視**: 特定のフィールドのみ監視

```dart
// ❌ 全体を監視（不要なリビルド）
final state = ref.watch(profileSetupProvider);

// ✅ 必要な部分のみ監視
final isUploading = ref.watch(
  profileSetupProvider.select((s) => s.isUploading)
);
```

### 2. Firestoreのキャッシュ

- オフライン時もキャッシュから読み取り可能
- ネットワーク負荷の削減

### 3. 画像の最適化

- アップロード前にリサイズ（1024x1024）
- 画質調整（85%）
- 不要な画像は削除

---

## テスト戦略

### 1. 単体テスト（Unit Tests）

**対象**: Provider、Service

```dart
test('signUpWithEmail creates user and saves data', () async {
  // Arrange
  final mockAuthService = MockAuthService();
  when(mockAuthService.signUpWithEmail(...))
    .thenAnswer((_) async => mockUserCredential);

  // Act
  final result = await authController.signUpWithEmail(...);

  // Assert
  expect(result, isTrue);
  verify(mockAuthService.saveUserData(any)).called(1);
});
```

### 2. ウィジェットテスト（Widget Tests）

**対象**: 画面、Widget

```dart
testWidgets('LoginPage shows error on invalid credentials', (tester) async {
  await tester.pumpWidget(ProviderScope(child: LoginPage()));
  await tester.enterText(find.byType(TextField).first, 'invalid');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  expect(find.text('ログインに失敗しました'), findsOneWidget);
});
```

### 3. 結合テスト（Integration Tests）

**対象**: エンドツーエンドのフロー

```dart
testWidgets('User can sign up and set profile', (tester) async {
  // 1. サインアップ
  // 2. プロフィール設定
  // 3. ホーム画面に遷移
});
```

---

## 今後の拡張ポイント

### 1. Repository Patternの拡張

```dart
// 複数の認証プロバイダー
abstract class AuthRepository {
  // ...
}

class FirebaseAuthRepository implements AuthRepository { }
class SupabaseAuthRepository implements AuthRepository { }
class MockAuthRepository implements AuthRepository { } // テスト用
```

### 2. ドメイン層の追加

```
Presentation → Provider → UseCase → Repository → Service
```

- UseCaseでビジネスルールをカプセル化
- より複雑なロジックに対応

### 3. イベントソーシング

- ユーザーアクションをイベントとして記録
- 状態の履歴を管理
- アナリティクスに活用

---

## まとめ

このアーキテクチャの特徴：

1. ✅ **レイヤー分離**: 各層の責務が明確
2. ✅ **テスト可能**: Mockを使った単体テストが容易
3. ✅ **保守性**: 変更の影響範囲が限定的
4. ✅ **拡張性**: 新機能の追加が容易
5. ✅ **型安全**: Freezedによる不変性の保証
6. ✅ **セキュア**: 多層防御による堅牢性

---

## 参考資料

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Architecture](https://riverpod.dev/docs/concepts/about_code_generation)
- [Flutter App Architecture](https://docs.flutter.dev/data-and-backend/state-mgmt/options)
- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/basics)

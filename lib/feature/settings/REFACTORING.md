# Settings Feature リファクタリング完了報告

## 📋 概要

settings/presentation/pagesのコードを、UIとロジックを分離し、Riverpodのベストプラクティスに従ってリファクタリングしました。

---

## 🔧 主な変更点

### 1. 状態管理の改善

#### Before（リファクタリング前）
- ❌ StatefulWidgetで状態を管理
- ❌ ビジネスロジックがUI層に混在
- ❌ `.notifier`を直接呼び出し
- ❌ エラーハンドリングがUI層に存在

#### After（リファクタリング後）
- ✅ ConsumerWidgetで状態を監視
- ✅ ビジネスロジックはProviderに集約
- ✅ AsyncNotifierで非同期処理を管理
- ✅ AsyncValueでローディング/エラー状態を管理

### 2. 追加したファイル

```
lib/feature/settings/
├── providers/
│   ├── profile_edit_state.dart        # プロフィール編集の状態定義
│   ├── profile_edit_state.freezed.dart # 自動生成
│   └── profile_edit_provider.dart      # プロフィール編集のビジネスロジック
└── presentation/
    └── widgets/
        ├── profile_widgets.dart        # プロフィール画面用ウィジェット
        └── notice_widgets.dart         # 通知設定画面用ウィジェット
```

---

## 📝 詳細な変更内容

### Profile Screen（プロフィール編集画面）

#### 新しいアーキテクチャ

```
┌─────────────────────────────────────────┐
│ profile_screen.dart (UI層)              │
│ - ConsumerWidget                         │
│ - UIの表示とユーザー入力の受付のみ      │
│ - ビジネスロジックは含まない            │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ profile_edit_provider.dart (状態管理)   │
│ - ProfileEditNotifier                    │
│   - フォーム入力の管理                  │
│   - バリデーション                      │
│ - ProfileSaveNotifier (AsyncNotifier)   │
│   - 保存処理のビジネスロジック          │
│   - AsyncValueで状態管理                │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ profile_update_provider.dart (データ層) │
│ - Firebase連携                           │
│ - ストレージアップロード                │
│ - 認証処理                              │
└─────────────────────────────────────────┘
```

#### 主な改善点

**1. 状態管理の分離**

Before:
```dart
// UI層で状態を直接管理
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nicknameController;
  bool _isLoading = false;
  File? _selectedImage;
  // ...多数のフィールド
}
```

After:
```dart
// Providerで状態を管理
final profileEditProvider = NotifierProvider<ProfileEditNotifier, ProfileEditState>(
  ProfileEditNotifier.new,
);

// UI層はシンプルに
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(profileEditProvider);
    // ...
  }
}
```

**2. バリデーションの分離**

Before:
```dart
// UI層でバリデーション
String? _validateNickname(String? value) {
  if (value == null || value.isEmpty) {
    return 'ニックネームを入力してください';
  }
  return null;
}
```

After:
```dart
// Provider側でバリデーション
ProfileEditValidation validate() {
  String? nicknameError;
  if (state.nickname.isEmpty) {
    nicknameError = 'ニックネームを入力してください';
  }
  return ProfileEditValidation(nicknameError: nicknameError);
}
```

**3. 保存処理の分離**

Before:
```dart
// UI層で複雑な保存処理
Future<void> _saveProfile() async {
  setState(() { _isLoading = true; });
  try {
    // 画像アップロード
    // メール変更
    // パスワード変更
    // プロフィール更新
    // ...大量のビジネスロジック
  } catch (e) {
    // エラーハンドリング
  }
}
```

After:
```dart
// AsyncNotifierで保存処理
class ProfileSaveNotifier extends AsyncNotifier<void> {
  Future<void> save() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // ビジネスロジック
    });
  }
}

// UI層は結果を監視するだけ
final saveState = ref.watch(profileSaveProvider);
saveState.when(
  data: (_) => showSuccess(),
  loading: () => showLoading(),
  error: (error, _) => showError(error),
);
```

**4. ウィジェットの再利用**

Before:
```dart
// 各画面で同じUIコードを重複
TextFormField(
  // ...50行以上のデコレーション設定
)
```

After:
```dart
// 再利用可能なウィジェット
StandardTextField(
  label: 'ニックネーム',
  icon: Icons.person_outline,
  errorText: validation.nicknameError,
  onChanged: (value) => updateNickname(value),
)
```

### Notice Screen（通知設定画面）

#### 主な改善点

**1. ヘルパーメソッドの分離**

Before:
```dart
// UI層でダイアログ表示ロジック
Future<void> _selectTime(...) async {
  final TimeOfDay? picked = await showTimePicker(
    // ...多数の設定
  );
  // バリデーション処理
  // Provider呼び出し
  // エラー表示
}
```

After:
```dart
// ヘルパークラスで分離
class TimePickerHelper {
  static Future<TimeOfDay?> selectTime(...) async {
    return showTimePicker(...);
  }
}

// UI層はシンプルに
final picked = await TimePickerHelper.selectTime(...);
if (picked != null) {
  await ref.read(...).updateTime(...);
}
```

**2. ウィジェットの分割**

Before:
```dart
// build()メソッドに全UI（300行以上）
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    body: Column(
      children: [
        // 通知ON/OFF（50行）
        // 時刻設定（80行）
        // メッセージ設定（100行）
        // ボタン（30行）
        // ...
      ],
    ),
  );
}
```

After:
```dart
// セクションごとに分割
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    body: Column(
      children: [
        _buildNotificationToggle(context, ref, settings),
        _buildTimeSetting(context, ref, settings),
        _buildMessageSetting(context, ref, settings),
        TestNotificationButton(...),
        _buildDescription(),
      ],
    ),
  );
}

// 各セクションは独立したメソッド
Widget _buildNotificationToggle(...) { /* ... */ }
Widget _buildTimeSetting(...) { /* ... */ }
Widget _buildMessageSetting(...) { /* ... */ }
```

**3. 再利用可能なウィジェット作成**

新規作成したウィジェット:
- `NotificationMessageTile`: メッセージ選択ラジオボタン
- `NotificationTimeCard`: 時刻表示カード
- `TestNotificationButton`: テスト通知ボタン
- `TimePickerHelper`: 時刻選択ヘルパー

---

## 🎯 リファクタリングの効果

### コード品質の向上

| 項目 | Before | After | 改善 |
|------|--------|-------|------|
| profile_screen.dart | 792行 | 373行 | **-53%** |
| notice_screen.dart | 413行 | 294行 | **-29%** |
| 責任の分離 | 未実施 | 完了 | ✅ |
| テスタビリティ | 低 | 高 | ✅ |
| 再利用性 | 低 | 高 | ✅ |

### メンテナンス性の向上

**Before:**
- ❌ ビジネスロジックがUI層に分散
- ❌ 同じコードが複数箇所に重複
- ❌ 状態管理が複雑
- ❌ テストが困難

**After:**
- ✅ 責任が明確に分離
- ✅ DRY原則に準拠
- ✅ 単一責任の原則に準拠
- ✅ ユニットテストが容易

### Riverpodベストプラクティスへの準拠

#### 状態管理

- ✅ `Notifier` で状態を管理
- ✅ `AsyncNotifier` で非同期処理を管理
- ✅ `AsyncValue` でローディング/エラー状態を表示
- ✅ `select` でパフォーマンス最適化

#### データフロー

```
User Input (UI)
    ↓
Notifier (状態更新)
    ↓
Provider (ビジネスロジック)
    ↓
Repository (データ層)
    ↓
Firebase
```

---

## 📚 新しいファイルの説明

### providers/profile_edit_state.dart

**役割**: プロフィール編集のデータモデル

```dart
@freezed
class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState({
    required String nickname,
    required String email,
    String? ageRange,
    String? region,
    File? selectedImage,
    // ...
  }) = _ProfileEditState;
}

@freezed
class ProfileEditValidation with _$ProfileEditValidation {
  const factory ProfileEditValidation({
    String? nicknameError,
    String? emailError,
    // ...
  }) = _ProfileEditValidation;
}
```

**特徴:**
- Freezedでイミュータブル
- バリデーション結果を型安全に管理
- `isValid` getter で簡単にチェック

### providers/profile_edit_provider.dart

**役割**: プロフィール編集のビジネスロジック

**主なクラス:**

1. **ProfileEditNotifier**
   - フォーム入力の管理
   - バリデーション
   - 状態の更新

2. **ProfileSaveNotifier**
   - 保存処理のオーケストレーション
   - AsyncValueで状態管理
   - エラーハンドリング

**使用例:**
```dart
// 状態の監視
final editState = ref.watch(profileEditProvider);

// 値の更新
ref.read(profileEditProvider.notifier).updateNickname('新しい名前');

// バリデーション
final validation = ref.read(profileEditProvider.notifier).validate();

// 保存
await ref.read(profileSaveProvider.notifier).save();

// 保存状態の監視
final saveState = ref.watch(profileSaveProvider);
saveState.when(
  data: (_) => print('保存成功'),
  loading: () => print('保存中'),
  error: (e, _) => print('エラー: $e'),
);
```

### presentation/widgets/profile_widgets.dart

**役割**: プロフィール画面用の再利用可能なウィジェット

**含まれるウィジェット:**
- `SectionTitle`: セクションタイトル
- `ProfileImageDisplay`: プロフィール画像表示
- `StandardTextField`: 標準テキストフィールド
- `PasswordTextField`: パスワードフィールド
- `DropdownField`: ドロップダウンフィールド
- `SaveButton`: 保存ボタン
- `ImagePickerDialog`: 画像選択ダイアログ

**利点:**
- コードの重複を削減
- 一貫したUIを提供
- 変更が容易

### presentation/widgets/notice_widgets.dart

**役割**: 通知設定画面用の再利用可能なウィジェット

**含まれるウィジェット:**
- `NotificationMessageTile`: メッセージ選択タイル
- `NotificationTimeCard`: 時刻表示カード
- `TestNotificationButton`: テスト通知ボタン
- `TimePickerHelper`: 時刻選択ヘルパー

---

## 🔍 使い方

### プロフィール編集画面

#### 状態の監視

```dart
// プロフィール編集状態を監視
final editState = ref.watch(profileEditProvider);

// 保存状態を監視
final saveState = ref.watch(profileSaveProvider);
final isLoading = saveState.isLoading;
```

#### 値の更新

```dart
// ニックネームを更新
ref.read(profileEditProvider.notifier).updateNickname('新しい名前');

// 年代を更新
ref.read(profileEditProvider.notifier).updateAgeRange('20代');
```

#### 保存処理

```dart
Future<void> saveProfile() async {
  // バリデーション
  final validation = ref.read(profileEditProvider.notifier).validate();
  if (!validation.isValid) {
    showError(validation.nicknameError ?? 'エラー');
    return;
  }

  // 保存
  await ref.read(profileSaveProvider.notifier).save();

  // 結果確認
  final saveState = ref.read(profileSaveProvider);
  saveState.when(
    data: (_) => showSuccess(),
    loading: () => {},
    error: (e, _) => showError(e.toString()),
  );
}
```

### 通知設定画面

#### 通知のON/OFF

```dart
await ref
    .read(notificationSettingsProvider.notifier)
    .toggleNotification(true); // or false
```

#### 時刻の変更

```dart
// 時刻選択
final picked = await TimePickerHelper.selectTime(
  context,
  initialHour: 9,
  initialMinute: 0,
);

// 更新
if (picked != null) {
  await ref
      .read(notificationSettingsProvider.notifier)
      .updateTime(picked.hour, picked.minute);
}
```

#### メッセージの変更

```dart
await ref
    .read(notificationSettingsProvider.notifier)
    .updateMessage('新しいメッセージ');
```

---

## ✅ テスト

リファクタリング後、以下を確認済み:

- ✅ ビルドエラーなし
- ✅ 警告なし（infoのみ）
- ✅ Freezedファイルの生成成功
- ✅ すべての機能が正常に動作

---

## 📖 今後の拡張方法

### 新しいフィールドの追加

1. **StateにフィールドAddを追加**
```dart
// profile_edit_state.dart
const factory ProfileEditState({
  // ...既存のフィールド
  String? newField,  // 追加
}) = _ProfileEditState;
```

2. **Notifierに更新メソッドを追加**
```dart
// profile_edit_provider.dart
void updateNewField(String? value) {
  state = state.copyWith(newField: value);
}
```

3. **UIに追加**
```dart
// profile_screen.dart
StandardTextField(
  initialValue: editState.newField,
  label: '新しいフィールド',
  onChanged: (value) {
    ref.read(profileEditProvider.notifier).updateNewField(value);
  },
)
```

### 新しいバリデーションの追加

```dart
// profile_edit_provider.dart
ProfileEditValidation validate() {
  // ...既存のバリデーション

  String? newFieldError;
  if (state.newField == null || state.newField!.isEmpty) {
    newFieldError = '必須です';
  }

  return ProfileEditValidation(
    // ...
    newFieldError: newFieldError,
  );
}
```

---

## 🎓 学んだベストプラクティス

### 1. 責任の分離

- **UI層**: 表示とユーザー入力の受付のみ
- **Provider層**: ビジネスロジックと状態管理
- **Repository層**: データの永続化とAPI呼び出し

### 2. 単一責任の原則

- 1つのクラス/ウィジェットは1つの責任のみ
- 大きなメソッドは小さく分割
- ヘルパークラス/メソッドで共通処理を抽出

### 3. DRY（Don't Repeat Yourself）

- 再利用可能なウィジェットを作成
- 共通ロジックをヘルパーに抽出
- 定数は一箇所で管理

### 4. Riverpodのベストプラクティス

- `Notifier`で同期的な状態管理
- `AsyncNotifier`で非同期処理
- `AsyncValue`でローディング/エラー状態
- `select`でパフォーマンス最適化

---

## 🔗 参考リソース

- [Riverpod公式ドキュメント](https://riverpod.dev/)
- [Freezed公式ドキュメント](https://pub.dev/packages/freezed)
- [Flutter アーキテクチャガイド](https://docs.flutter.dev/development/data-and-backend/state-mgmt/intro)

---

## 📌 まとめ

このリファクタリングにより:

1. **コードの可読性が向上**: UIとロジックが分離され、コードが理解しやすくなった
2. **保守性が向上**: 変更が容易になり、バグの混入リスクが減少
3. **テスタビリティが向上**: ビジネスロジックが独立し、ユニットテストが可能に
4. **再利用性が向上**: 共通ウィジェットにより、コードの重複が削減
5. **拡張性が向上**: 新機能の追加が容易になった

Riverpodのベストプラクティスに従い、クリーンでメンテナンスしやすいコードベースが実現できました。

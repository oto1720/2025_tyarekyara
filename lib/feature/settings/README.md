# Settings Feature (設定機能)

## 📋 目次
- [概要](#概要)
- [ディレクトリ構造](#ディレクトリ構造)
- [画面一覧](#画面一覧)
- [各ファイルの詳細説明](#各ファイルの詳細説明)
- [カスタマイズ方法](#カスタマイズ方法)
- [新しい設定項目の追加方法](#新しい設定項目の追加方法)
- [トラブルシューティング](#トラブルシューティング)

---

## 概要

このディレクトリは、アプリの設定機能全体を管理しています。ユーザープロフィールの編集、通知設定、その他のアプリケーション設定を含みます。

### 主な機能
- ✅ プロフィール編集（ニックネーム、メールアドレス、パスワード、年代、地域、アイコン）
- ✅ 通知設定（ON/OFF、時刻選択、メッセージカスタマイズ）
- ✅ その他の設定項目の拡張可能な構造

---

## ディレクトリ構造

```
lib/feature/settings/
├── README.md                          # このファイル
├── models/                            # データモデル
│   ├── notification_settings.dart     # 通知設定モデル
│   ├── notification_settings.freezed.dart  # 自動生成（編集不要）
│   └── notification_settings.g.dart   # 自動生成（編集不要）
├── presentation/                      # UI層
│   ├── pages/                         # 画面
│   │   ├── settings_screen.dart       # メイン設定画面
│   │   ├── profile_screen.dart        # プロフィール編集画面
│   │   └── notice_screen.dart         # 通知設定画面
│   └── widgets/                       # ウィジェット
│       └── setting_item.dart          # 設定項目用ウィジェット
├── providers/                         # 状態管理
│   ├── profile_update_provider.dart   # プロフィール更新ロジック
│   └── notification_provider.dart     # 通知設定ロジック
└── services/                          # ビジネスロジック
    └── notification_service.dart      # 通知サービス（flutter_local_notifications）
```

---

## 画面一覧

### 1. 設定画面（settings_screen.dart）
**パス**: `/settings`
**説明**: アプリの全設定項目を一覧表示するメイン画面

**セクション構成**:
- **アカウント**: プロフィール編集
- **アプリ設定**: 通知、表示、その他
- **サポート**: ヘルプ、基本情報
- **アカウント操作**: ログアウト

### 2. プロフィール編集画面（profile_screen.dart）
**パス**: `/profile`（設定画面 → プロフィールから遷移）
**説明**: ユーザー情報を編集する画面

**編集可能な項目**:
- プロフィール画像（ギャラリー/カメラ）
- ニックネーム
- メールアドレス
- 年代（10歳未満〜90代）
- 地域（47都道府県）
- パスワード（現在のパスワードで再認証が必要）

### 3. 通知設定画面（notice_screen.dart）
**パス**: `/notice`（設定画面 → 通知から遷移）
**説明**: プッシュ通知の設定を行う画面

**設定項目**:
- 通知のON/OFF
- 通知時刻（6:00〜23:00）
- 通知メッセージ（5種類のプリセット）
- テスト通知送信

---

## 各ファイルの詳細説明

### 📱 Presentation層（UI）

#### `presentation/pages/settings_screen.dart`
**役割**: 設定のメイン画面

**主なコンポーネント**:
- `SettingSection`: セクションヘッダー（カテゴリ名を表示）
- `SettingItem`: 通常の設定項目
- `DangerSettingItem`: 危険な操作用（ログアウトなど）

**カスタマイズポイント**:
```dart
// 新しい設定項目を追加する場合
SettingItem(
  icon: Icons.your_icon,          // アイコン
  title: '設定項目名',
  subtitle: '説明文',
  iconColor: Colors.blue,          // アイコンの色
  onTap: () {
    context.push('/your-route');   // 遷移先
  },
),
```

#### `presentation/pages/profile_screen.dart`
**役割**: プロフィール編集画面

**主な機能**:
1. **画像選択**: `_pickImage(ImageSource source)`
   - ギャラリーまたはカメラから画像を選択
   - 選択した画像をプレビュー表示

2. **プロフィール保存**: `_saveProfile()`
   - 画像をFirebase Storageにアップロード
   - ユーザー情報をFirestoreに保存
   - メールアドレス変更時は再認証
   - パスワード変更時も再認証

**カスタマイズポイント**:
```dart
// 年代・地域の選択肢を変更
final List<String> _ageRanges = [
  '10歳未満',
  '10代',
  // ... 追加/編集
];

final List<String> _regions = [
  '北海道',
  // ... 追加/編集
];
```

#### `presentation/pages/notice_screen.dart`
**役割**: 通知設定画面

**主な機能**:
1. **通知ON/OFF**: `SwitchListTile`で切り替え
2. **時刻選択**: `TimePickerDialog`で時刻を選択
   - 6:00〜23:00の範囲制限あり
3. **メッセージ選択**: ラジオボタンで選択
4. **テスト通知**: 即座に通知を送信

**カスタマイズポイント**:
```dart
// notification_settings.dartで通知メッセージを追加/編集
class NotificationMessages {
  static const List<String> messages = [
    'トピックが届いています',
    '今日のトピックをチェックしましょう',
    // ... 新しいメッセージを追加
  ];
}
```

#### `presentation/widgets/setting_item.dart`
**役割**: 設定項目の再利用可能なウィジェット

**3つのウィジェット**:
1. `SettingItem`: 通常の設定項目
2. `SettingSection`: セクションヘッダー
3. `DangerSettingItem`: 危険な操作用（赤色）

---

### 🔧 Providers層（状態管理）

#### `providers/profile_update_provider.dart`
**役割**: プロフィール更新のビジネスロジック

**主なメソッド**:
```dart
// プロフィール情報を更新
Future<void> updateProfile({
  required String userId,
  required String nickname,
  String? iconUrl,
  String? ageRange,
  String? region,
})

// プロフィール画像をアップロード
Future<String> updateProfileImage({
  required String userId,
  required File imageFile,
})

// メールアドレスを更新（再認証必要）
Future<void> updateEmail({
  required String userId,
  required String newEmail,
  required String currentPassword,
})

// パスワードを更新（再認証必要）
Future<void> updatePassword({
  required String currentPassword,
  required String newPassword,
})
```

**使用例**:
```dart
final profileUpdate = ref.read(profileUpdateProvider);
await profileUpdate.updateProfile(
  userId: user.id,
  nickname: 'New Nickname',
  ageRange: '20代',
  region: '東京都',
);
```

#### `providers/notification_provider.dart`
**役割**: 通知設定の状態管理とスケジューリング

**主なメソッド**:
```dart
// 通知のON/OFF切り替え
Future<void> toggleNotification(bool isEnabled)

// 通知時刻を変更
Future<void> updateTime(int hour, int minute)

// 通知メッセージを変更
Future<void> updateMessage(String message)

// テスト通知を送信
Future<void> sendTestNotification()
```

**設定の永続化**:
- SharedPreferencesを使用
- アプリ再起動後も設定を保持
- 設定変更時に自動で通知を再スケジュール

---

### 📦 Models層（データモデル）

#### `models/notification_settings.dart`
**役割**: 通知設定のデータ構造

**フィールド**:
```dart
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool isEnabled,       // 通知のON/OFF
    @Default(9) int hour,                // 通知時刻（時）
    @Default(0) int minute,              // 通知時刻（分）
    @Default('トピックが届いています') String message,  // 通知メッセージ
  }) = _NotificationSettings;
}
```

**デフォルト値の変更**:
```dart
// デフォルトの通知時刻を変更したい場合
@Default(8) int hour,  // 朝8時に変更
```

---

### 🛠️ Services層（ビジネスロジック）

#### `services/notification_service.dart`
**役割**: flutter_local_notificationsを使った通知機能

**主なメソッド**:
```dart
// 通知サービスを初期化
Future<void> initialize()

// 通知権限をリクエスト
Future<bool> requestPermission()

// 毎日の通知をスケジュール
Future<void> scheduleDailyNotification(NotificationSettings settings)

// すべての通知をキャンセル
Future<void> cancelAllNotifications()

// テスト通知を即座に表示
Future<void> showTestNotification(String message)
```

**通知のカスタマイズ**:
```dart
// AndroidNotificationDetailsを編集
AndroidNotificationDetails(
  'daily_notification',           // チャンネルID
  '毎日の通知',                    // チャンネル名
  channelDescription: '毎日決まった時間に通知を受け取ります',
  importance: Importance.high,    // 重要度
  priority: Priority.high,        // 優先度
  icon: '@mipmap/ic_launcher',    // アイコン
)
```

---

## カスタマイズ方法

### 1. 通知時刻の範囲を変更

**ファイル**: `presentation/pages/notice_screen.dart`

```dart
// 現在: 6:00〜23:00
if (picked.hour >= 6 && picked.hour <= 23) {
  // OK
}

// 変更例: 0:00〜23:59（24時間対応）
if (picked.hour >= 0 && picked.hour <= 23) {
  // OK
}
```

### 2. 通知メッセージの追加

**ファイル**: `models/notification_settings.dart`

```dart
class NotificationMessages {
  static const List<String> messages = [
    'トピックが届いています',
    '今日のトピックをチェックしましょう',
    '新しいお題に挑戦してみませんか',
    'みんなの意見を見てみよう',
    'あなたの意見を聞かせてください',
    // ここに新しいメッセージを追加
    '今すぐチェック！',
    '新着通知です',
  ];
}
```

### 3. プロフィール項目の追加

**ファイル**: `presentation/pages/profile_screen.dart`

**手順**:
1. UIに新しいフィールドを追加
2. `_saveProfile()`メソッドで保存処理を追加
3. `UserModel`に新しいフィールドを追加（`auth/models/user/user_model.dart`）
4. `profile_update_provider.dart`の`updateProfile`メソッドを更新

**例**: 電話番号を追加
```dart
// 1. UIに追加
_buildTextField(
  controller: _phoneController,
  label: '電話番号',
  icon: Icons.phone,
  keyboardType: TextInputType.phone,
),

// 2. 保存処理に追加
await profileUpdateNotifier.updateProfile(
  userId: user.id,
  nickname: newNickname,
  phone: _phoneController.text,  // 追加
);
```

### 4. 設定画面に新しいセクションを追加

**ファイル**: `presentation/pages/settings_screen.dart`

```dart
// 新しいセクションを追加
const SettingSection(title: '新しいセクション'),
SettingItem(
  icon: Icons.new_icon,
  title: '新しい設定項目',
  subtitle: '説明文',
  iconColor: Colors.green,
  onTap: () {
    context.push('/new-route');
  },
),
```

---

## 新しい設定項目の追加方法

### 例: 言語設定機能を追加

#### ステップ1: モデルを作成
```dart
// models/language_settings.dart
@freezed
class LanguageSettings with _$LanguageSettings {
  const factory LanguageSettings({
    @Default('ja') String language,
  }) = _LanguageSettings;

  factory LanguageSettings.fromJson(Map<String, dynamic> json) =>
      _$LanguageSettingsFromJson(json);
}
```

#### ステップ2: プロバイダーを作成
```dart
// providers/language_provider.dart
final languageProvider = StateNotifierProvider<LanguageNotifier, String>(
  (ref) => LanguageNotifier(),
);

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('ja');

  void changeLanguage(String newLanguage) {
    state = newLanguage;
    // SharedPreferencesに保存
  }
}
```

#### ステップ3: 画面を作成
```dart
// presentation/pages/language_screen.dart
class LanguageScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 言語選択UIを実装
  }
}
```

#### ステップ4: ルーティングを追加
```dart
// core/route/app_router.dart
GoRoute(
  path: '/language',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: LanguageScreen(),
  ),
),
```

#### ステップ5: 設定画面に追加
```dart
// presentation/pages/settings_screen.dart
SettingItem(
  icon: Icons.language,
  title: '言語設定',
  subtitle: '表示言語を変更',
  iconColor: Colors.purple,
  onTap: () {
    context.push('/language');
  },
),
```

---

## トラブルシューティング

### 通知が届かない場合

1. **通知権限を確認**
   ```dart
   // notification_service.dartでリクエストしているか確認
   await requestPermission();
   ```

2. **通知がスケジュールされているか確認**
   ```dart
   final pending = await _notificationService.getPendingNotifications();
   print('Pending notifications: ${pending.length}');
   ```

3. **デバイス設定を確認**
   - Android: 設定 → アプリ → 通知 → アプリ名
   - iOS: 設定 → 通知 → アプリ名

### プロフィール更新が失敗する場合

1. **エラーメッセージを確認**
   ```dart
   try {
     await profileUpdateNotifier.updateProfile(...);
   } catch (e) {
     print('Error: $e');  // エラー内容を確認
   }
   ```

2. **Firebase権限を確認**
   - Firestore Rulesで書き込み権限があるか
   - Storage Rulesでアップロード権限があるか

3. **ネットワーク接続を確認**

### Freezedの再生成が必要な場合

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 依存パッケージ

```yaml
dependencies:
  flutter_riverpod: ^3.0.0       # 状態管理
  freezed_annotation: ^2.4.1     # イミュータブルモデル
  shared_preferences: ^2.2.2     # ローカルストレージ
  image_picker: 最新版            # 画像選択
  flutter_local_notifications: ^18.0.1  # ローカル通知
  timezone: ^0.9.2               # タイムゾーン管理
  firebase_auth: 最新版           # 認証
  cloud_firestore: 最新版         # データベース
  firebase_storage: 最新版        # ストレージ
```

---

## 参考リンク

- [Flutter Riverpod公式ドキュメント](https://riverpod.dev/)
- [Freezed公式ドキュメント](https://pub.dev/packages/freezed)
- [flutter_local_notifications公式ドキュメント](https://pub.dev/packages/flutter_local_notifications)
- [SharedPreferences公式ドキュメント](https://pub.dev/packages/shared_preferences)

---

## 更新履歴

- **2025-10-30**: 初版作成
  - プロフィール編集機能の追加
  - 通知設定機能の追加
  - 年代・地域選択機能の追加

---

## 貢献者向け

新しい機能を追加する場合は、以下のガイドラインに従ってください：

1. **命名規則**: `feature_screen.dart`のようにスネークケースを使用
2. **状態管理**: Riverpodを使用
3. **データモデル**: Freezedを使用してイミュータブルに
4. **ファイル配置**: 適切なディレクトリ（models/providers/presentation）に配置
5. **ドキュメント**: このREADME.mdを更新

---

## ライセンス

このプロジェクトの一部として、同じライセンスが適用されます。

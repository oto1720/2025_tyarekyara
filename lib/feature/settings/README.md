# Settings Feature (設定機能)

## 📋 目次
- [概要](#概要)
- [アーキテクチャ](#アーキテクチャ)
- [依存関係](#依存関係)
- [クラス図と関係性](#クラス図と関係性)
- [データフロー](#データフロー)
- [ディレクトリ構造](#ディレクトリ構造)
- [各ファイルの詳細説明](#各ファイルの詳細説明)
- [画面一覧](#画面一覧)
- [カスタマイズ方法](#カスタマイズ方法)
- [新しい設定項目の追加方法](#新しい設定項目の追加方法)
- [トラブルシューティング](#トラブルシューティング)

---

## 概要

このディレクトリは、アプリの設定機能全体を管理しています。ユーザープロフィールの編集、通知設定、その他のアプリケーション設定を含みます。

### 主な機能
- ✅ プロフィール編集（ニックネーム、メールアドレス、パスワード、年代、地域、アイコン）
- ✅ 通知設定（ON/OFF、時刻選択、メッセージカスタマイズ）
- ✅ FCM（Firebase Cloud Messaging）による通知管理
- ✅ マッチング通知の表示
- ✅ その他の設定項目の拡張可能な構造

---

## アーキテクチャ

このフィーチャーは、以下のレイヤーに分かれています：

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation層                         │
│  (pages/, widgets/)                                      │
│  - UI表示とユーザーインタラクション                        │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                   Providers層                            │
│  (providers/)                                            │
│  - 状態管理とビジネスロジック                              │
│  - Riverpod Notifierを使用                                │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                Services層 / Repositories層               │
│  (services/)                                             │
│  - 外部APIとの通信                                        │
│  - Firebase / ローカルストレージとの連携                   │
└─────────────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                   Models層                               │
│  (models/)                                               │
│  - データモデルの定義                                      │
│  - Freezedによるイミュータブルクラス                        │
└─────────────────────────────────────────────────────────┘
```

---

## 依存関係

### 外部依存（他フィーチャー）

```
settings/
  ├── → auth/
  │     ├── authServiceProvider (認証サービス)
  │     ├── currentUserProvider (現在のユーザー情報)
  │     └── storageServiceProvider (画像アップロード)
  │
  └── → core/
        └── router (画面遷移)
```

### 内部依存（settings内）

```
presentation/
  ├── settings_screen.dart
  │     └── → auth/currentUserProvider
  │
  ├── profile_screen.dart
  │     ├── → providers/profile_edit_provider
  │     ├── → providers/profile_update_provider
  │     └── → auth/currentUserProvider
  │
  └── notice_screen.dart
        └── → providers/notification_provider

providers/
  ├── profile_edit_provider.dart
  │     └── → models/profile_edit_state
  │
  ├── profile_update_provider.dart
  │     ├── → auth/authServiceProvider
  │     ├── → auth/storageServiceProvider
  │     └── → auth/currentUserProvider
  │
  └── notification_provider.dart
        ├── → services/notification_service
        ├── → models/notification_settings
        └── → shared_preferences (永続化)

services/
  └── notification_service.dart
        ├── → flutter_local_notifications
        ├── → firebase_messaging
        ├── → cloud_firestore
        └── → models/notification_settings
```

### パッケージ依存

```yaml
dependencies:
  # 状態管理
  flutter_riverpod: ^3.0.0

  # データモデル
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # ローカルストレージ
  shared_preferences: ^2.2.2

  # 画像選択
  image_picker: 最新版

  # 通知
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.2

  # Firebase
  firebase_auth: 最新版
  firebase_messaging: 最新版
  cloud_firestore: 最新版
  firebase_storage: 最新版

dev_dependencies:
  # コード生成
  build_runner: ^2.4.6
  freezed: ^2.4.5
  json_serializable: ^6.7.1
```

---

## クラス図と関係性

### プロフィール編集機能の関係図

```
ProfileScreen (画面)
    │
    ├─ 読み取り → currentUserProvider (ユーザー情報)
    │                 ↓
    │              authServiceProvider
    │
    ├─ 状態管理 → ProfileEditNotifier
    │                 ↓
    │              ProfileEditState (状態クラス)
    │                 - nickname: String
    │                 - ageRange: String?
    │                 - region: String?
    │                 - selectedImage: File?
    │                 - isEditingPassword: bool
    │                 - currentPassword: String
    │                 - newPassword: String
    │                 - confirmPassword: String
    │                 - validation: ProfileEditValidation
    │
    └─ 更新処理 → ProfileUpdateNotifier
                      ↓
                   ┌──────────────┬─────────────────┐
                   ▼              ▼                 ▼
            authServiceProvider  storageServiceProvider  currentUserProvider
                   ↓              ↓                 ↓
              (Firestore更新)  (画像アップロード)  (状態リフレッシュ)
```

**クラスの役割**:
- `ProfileScreen`: UIとユーザーインタラクション
- `ProfileEditNotifier`: フォームの状態管理とバリデーション
- `ProfileUpdateNotifier`: プロフィール更新のビジネスロジック
- `authServiceProvider`: Firebase Authenticationとの連携
- `storageServiceProvider`: Firebase Storageへの画像アップロード

### 通知設定機能の関係図

```
NoticeScreen (画面)
    │
    └─ 状態管理・操作 → NotificationSettingsNotifier
                            ↓
                         ┌────────────────┬─────────────────┐
                         ▼                ▼                 ▼
                  NotificationService  SharedPreferences  NotificationSettings
                         ↓                ↓                 (モデル)
                   ┌─────┴────┬──────────┤
                   ▼          ▼          ▼
      FlutterLocalNotifications  FirebaseMessaging  Firestore
           (ローカル通知)       (FCM)         (トークン保存)
```

**クラスの役割**:
- `NoticeScreen`: UIとユーザーインタラクション
- `NotificationSettingsNotifier`: 通知設定の状態管理
- `NotificationService`: 通知機能の実装（シングルトン）
- `NotificationSettings`: 通知設定のデータモデル
- `SharedPreferences`: 通知設定の永続化

### 設定画面の構造

```
SettingsScreen (メイン画面)
    │
    ├─ Widget → SettingSection (セクションヘッダー)
    ├─ Widget → SettingItem (通常の設定項目)
    └─ Widget → DangerSettingItem (危険な操作用)
    │
    └─ 画面遷移 ┬→ ProfileScreen (/profile)
                ├→ NoticeScreen (/notice)
                └→ その他の設定画面
```

---

## データフロー

### プロフィール更新のフロー

```
1. ユーザーがProfileScreenでプロフィールを編集
   ↓
2. ProfileEditNotifierで状態を管理
   - バリデーション実行
   - フォームの状態を保持
   ↓
3. 保存ボタンタップ
   ↓
4. ProfileUpdateNotifierの各メソッドを呼び出し
   - updateProfile(): 基本情報更新
   - updateProfileImage(): 画像アップロード
   - updateEmail(): メールアドレス更新（再認証必要）
   - updatePassword(): パスワード更新（再認証必要）
   ↓
5. authServiceProviderを通じてFirebaseに保存
   - Firestore: ユーザー情報
   - Storage: プロフィール画像
   - Auth: メール/パスワード
   ↓
6. currentUserProviderを無効化してUIを更新
   ↓
7. 成功メッセージ表示と画面を戻る
```

### 通知設定のフロー

```
1. アプリ起動時
   ↓
2. NotificationService初期化
   - flutter_local_notificationsの初期化
   - FCMの初期化と権限リクエスト
   - FCMトークンの取得
   ↓
3. NotificationSettingsNotifier初期化
   - SharedPreferencesから設定読み込み
   - NotificationServiceに設定を反映
   ↓
4. ユーザーがNoticeScreenで設定変更
   ↓
5. NotificationSettingsNotifierで状態更新
   - toggleNotification(): ON/OFF切り替え
   - updateTime(): 通知時刻変更
   - updateMessage(): メッセージ変更
   ↓
6. SharedPreferencesに保存
   ↓
7. NotificationServiceで通知をスケジュール
   - scheduleDailyNotification(): 毎日の通知設定
   - 既存の通知をキャンセルして新規作成
   ↓
8. 通知が指定時刻に配信される
```

### マッチング通知のフロー（FCM）

```
1. サーバーからFCMメッセージ送信
   - 宛先: ユーザーのFCMトークン
   - ペイロード: { matchId: "xxx" }
   ↓
2. NotificationServiceで受信
   - フォアグラウンド: _handleForegroundMessage()
   - バックグラウンド: firebaseMessagingBackgroundHandler()
   - 通知タップ: _handleMessageOpenedApp()
   ↓
3. ローカル通知を表示
   - showMatchNotification()
   ↓
4. ユーザーが通知をタップ
   ↓
5. onMatchNotificationTapped コールバック実行
   - matchIdを使って適切な画面に遷移
```

---

## ディレクトリ構造

```
lib/feature/settings/
├── README.md                          # このファイル
├── REFACTORING.md                     # リファクタリング履歴
│
├── models/                            # データモデル
│   ├── notification_settings.dart     # 通知設定モデル
│   ├── notification_settings.freezed.dart  # 自動生成（編集不要）
│   └── notification_settings.g.dart   # 自動生成（編集不要）
│
├── presentation/                      # UI層
│   ├── pages/                         # 画面
│   │   ├── settings_screen.dart       # メイン設定画面
│   │   ├── profile_screen.dart        # プロフィール編集画面
│   │   └── notice_screen.dart         # 通知設定画面
│   │
│   └── widgets/                       # ウィジェット
│       ├── setting_item.dart          # 設定項目用ウィジェット
│       ├── profile_widgets.dart       # プロフィール画面用ウィジェット
│       └── notice_widgets.dart        # 通知画面用ウィジェット
│
├── providers/                         # 状態管理
│   ├── profile_edit_provider.dart     # プロフィール編集の状態管理
│   ├── profile_edit_state.dart        # プロフィール編集の状態定義
│   ├── profile_edit_state.freezed.dart # 自動生成（編集不要）
│   ├── profile_update_provider.dart   # プロフィール更新ロジック
│   └── notification_provider.dart     # 通知設定ロジック
│
├── repositories/                      # リポジトリ（現在は空）
│
└── services/                          # ビジネスロジック
    └── notification_service.dart      # 通知サービス
```

---

## 各ファイルの詳細説明

### 📱 Presentation層（UI）

#### `presentation/pages/settings_screen.dart`
**役割**: 設定のメイン画面

**主なコンポーネント**:
- `SettingSection`: セクションヘッダー（カテゴリ名を表示）
- `SettingItem`: 通常の設定項目
- `DangerSettingItem`: 危険な操作用（ログアウトなど）

**使用しているプロバイダー**:
```dart
// lib/feature/settings/presentation/pages/settings_screen.dart:XX
ref.watch(currentUserProvider)  // ユーザー情報の取得
ref.read(authServiceProvider)   // ログアウト処理
```

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

---

#### `presentation/pages/profile_screen.dart`
**役割**: プロフィール編集画面

**使用しているプロバイダー**:
```dart
// lib/feature/settings/presentation/pages/profile_screen.dart:XX
ref.watch(currentUserProvider)           // 現在のユーザー情報
ref.watch(profileEditProvider)           // 編集中の状態
ref.read(profileSaveProvider.notifier)   // 保存処理
```

**主な機能**:
1. **画像選択**: `_pickImage(ImageSource source)`
   - ギャラリーまたはカメラから画像を選択
   - 選択した画像をプレビュー表示

2. **プロフィール保存**: `_saveProfile()`
   - ProfileSaveNotifierを呼び出し
   - 画像をFirebase Storageにアップロード
   - ユーザー情報をFirestoreに保存
   - メールアドレス変更時は再認証
   - パスワード変更時も再認証

**状態フロー**:
```
ProfileEditState (編集中の状態)
  ↓
ProfileSaveNotifier.save() (保存処理)
  ↓
ProfileUpdateNotifier (各種更新メソッド)
  ↓
authServiceProvider / storageServiceProvider
```

**カスタマイズポイント**:
```dart
// lib/feature/settings/presentation/pages/profile_screen.dart:XX
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

---

#### `presentation/pages/notice_screen.dart`
**役割**: 通知設定画面

**使用しているプロバイダー**:
```dart
// lib/feature/settings/presentation/pages/notice_screen.dart:XX
ref.watch(notificationSettingsProvider)  // 通知設定の状態
ref.read(notificationSettingsProvider.notifier)  // 通知設定の操作
```

**主な機能**:
1. **通知ON/OFF**: `SwitchListTile`で切り替え
2. **時刻選択**: `TimePickerDialog`で時刻を選択
   - 6:00〜23:00の範囲制限あり
3. **メッセージ選択**: ラジオボタンで選択
4. **テスト通知**: 即座に通知を送信

**カスタマイズポイント**:
```dart
// lib/feature/settings/models/notification_settings.dart:XX
// 通知メッセージを追加/編集
class NotificationMessages {
  static const List<String> messages = [
    'トピックが届いています',
    '今日のトピックをチェックしましょう',
    // ... 新しいメッセージを追加
  ];
}
```

---

#### `presentation/widgets/setting_item.dart`
**役割**: 設定項目の再利用可能なウィジェット

**提供しているウィジェット**:
1. `SettingItem`: 通常の設定項目
   ```dart
   SettingItem(
     icon: Icons.notifications,
     title: '通知',
     subtitle: '通知設定を変更',
     iconColor: Colors.orange,
     onTap: () => context.push('/notice'),
   )
   ```

2. `SettingSection`: セクションヘッダー
   ```dart
   SettingSection(title: 'アプリ設定')
   ```

3. `DangerSettingItem`: 危険な操作用（赤色）
   ```dart
   DangerSettingItem(
     icon: Icons.logout,
     title: 'ログアウト',
     onTap: _logout,
   )
   ```

---

### 🔧 Providers層（状態管理）

#### `providers/profile_edit_provider.dart`
**役割**: プロフィール編集フォームの状態管理

**クラス**:
1. `ProfileEditNotifier extends Notifier<ProfileEditState>`
   - フォームの状態を管理
   - バリデーションを実行
   - パスワード編集の切り替え

2. `ProfileSaveNotifier extends Notifier<AsyncValue<void>>`
   - 保存処理の実行
   - ProfileUpdateNotifierを呼び出し

**主なメソッド**:
```dart
// lib/feature/settings/providers/profile_edit_provider.dart:XX
class ProfileEditNotifier {
  void updateNickname(String nickname)      // ニックネーム更新
  void updateAgeRange(String? ageRange)     // 年代更新
  void updateRegion(String? region)         // 地域更新
  void updateSelectedImage(File? image)     // 画像更新
  void togglePasswordEditing()              // パスワード編集切り替え
  void updateCurrentPassword(String password)  // 現在のパスワード
  void updateNewPassword(String password)   // 新しいパスワード
  void updateConfirmPassword(String password)  // 確認用パスワード
  ProfileEditValidation validate()          // バリデーション
  void clearPasswordFields()                // パスワードフィールドクリア
}
```

**依存関係**:
- `ProfileEditState`: 状態を保持するFreezedクラス
- `ProfileUpdateNotifier`: 実際の更新処理を実行

---

#### `providers/profile_update_provider.dart`
**役割**: プロフィール更新のビジネスロジック

**クラス**: `ProfileUpdateNotifier`

**主なメソッド**:
```dart
// lib/feature/settings/providers/profile_update_provider.dart:13
Future<void> updateProfile({
  required String userId,
  required String nickname,
  String? iconUrl,
  String? ageRange,
  String? region,
})

// lib/feature/settings/providers/profile_update_provider.dart:42
Future<String> updateProfileImage({
  required String userId,
  required File imageFile,
})

// lib/feature/settings/providers/profile_update_provider.dart:59
Future<void> updateEmail({
  required String userId,
  required String newEmail,
  required String currentPassword,
})

// lib/feature/settings/providers/profile_update_provider.dart:90
Future<void> updatePassword({
  required String currentPassword,
  required String newPassword,
})
```

**依存している他フィーチャーのプロバイダー**:
```dart
// lib/feature/settings/providers/profile_update_provider.dart:20,64,94
ref.read(authServiceProvider)      // 認証サービス

// lib/feature/settings/providers/profile_update_provider.dart:47
ref.read(storageServiceProvider)   // ストレージサービス

// lib/feature/settings/providers/profile_update_provider.dart:38,86
ref.invalidate(currentUserProvider) // ユーザー情報の更新
```

**処理フロー**:
1. authServiceProviderから現在のユーザー情報を取得
2. UserModelのcopyWithで新しい情報を作成
3. authServiceProviderで更新
4. currentUserProviderを無効化してUIに反映

---

#### `providers/notification_provider.dart`
**役割**: 通知設定の状態管理とスケジューリング

**クラス**: `NotificationSettingsNotifier extends Notifier<NotificationSettings>`

**主なメソッド**:
```dart
// lib/feature/settings/providers/notification_provider.dart:XX
Future<void> toggleNotification(bool isEnabled)  // ON/OFF切り替え
Future<void> updateTime(int hour, int minute)    // 時刻変更
Future<void> updateMessage(String message)       // メッセージ変更
Future<void> sendTestNotification()              // テスト通知
Future<List<PendingNotificationRequest>> getPendingNotifications()  // スケジュール確認
```

**依存関係**:
```dart
// lib/feature/settings/providers/notification_provider.dart:XX
final notificationService = ref.read(notificationServiceProvider)
// SharedPreferencesを使用（_loadSettings, _saveSettings）
```

**設定の永続化**:
- SharedPreferencesを使用
- アプリ再起動後も設定を保持
- 設定変更時に自動で通知を再スケジュール

**初期化フロー**:
```
1. build()で初期設定を読み込み
   ↓
2. _initializeNotificationService()でNotificationServiceを初期化
   ↓
3. _loadSettings()でSharedPreferencesから設定を読み込み
   ↓
4. 通知が有効なら自動でスケジュール
```

---

#### `providers/profile_edit_state.dart`
**役割**: プロフィール編集の状態定義

**クラス**:
```dart
// lib/feature/settings/providers/profile_edit_state.dart:XX
@freezed
class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState({
    required String nickname,
    String? ageRange,
    String? region,
    File? selectedImage,
    @Default(false) bool isEditingPassword,
    @Default('') String currentPassword,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    @Default(ProfileEditValidation.valid()) ProfileEditValidation validation,
  }) = _ProfileEditState;

  factory ProfileEditState.fromUser(UserModel user) = ...;
}

@freezed
class ProfileEditValidation with _$ProfileEditValidation {
  const factory ProfileEditValidation({
    String? nicknameError,
    String? passwordError,
  }) = _ProfileEditValidation;

  const factory ProfileEditValidation.valid() = ...;
}
```

**バリデーションロジック**:
- ニックネームの長さチェック
- パスワードの一致確認
- パスワードの強度チェック

---

### 🛠️ Services層（ビジネスロジック）

#### `services/notification_service.dart`
**役割**: flutter_local_notificationsとFCMを使った通知機能（シングルトン）

**クラス**: `NotificationService`（シングルトンパターン）

**主なメソッド**:
```dart
// lib/feature/settings/services/notification_service.dart:33
Future<void> initialize()  // 通知サービスを初期化

// lib/feature/settings/services/notification_service.dart:216
Future<bool> requestPermission()  // 通知権限をリクエスト

// lib/feature/settings/services/notification_service.dart:243
Future<void> scheduleDailyNotification(NotificationSettings settings)  // 毎日の通知

// lib/feature/settings/services/notification_service.dart:294
Future<void> cancelAllNotifications()  // すべての通知をキャンセル

// lib/feature/settings/services/notification_service.dart:299
Future<void> showTestNotification(String message)  // テスト通知

// lib/feature/settings/services/notification_service.dart:177
Future<void> showMatchNotification({...})  // マッチング通知

// lib/feature/settings/services/notification_service.dart:138
Future<void> saveFcmToken(String userId)  // FCMトークン保存

// lib/feature/settings/services/notification_service.dart:167
Future<void> removeFcmToken(String userId)  // FCMトークン削除

// lib/feature/settings/services/notification_service.dart:323
Future<List<PendingNotificationRequest>> getPendingNotifications()  // スケジュール確認
```

**依存するパッケージ**:
```dart
// lib/feature/settings/services/notification_service.dart:1-5
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
```

**通知の種類**:
1. **ローカル通知（毎日）**
   - 通知ID: 0
   - チャンネル: 'daily_notification'
   - スケジュール: 毎日指定時刻

2. **マッチング通知（FCM）**
   - 通知ID: 100
   - チャンネル: 'match_notification'
   - ペイロード: matchId

3. **テスト通知**
   - 通知ID: 999
   - チャンネル: 'test_notification'
   - 即座に表示

**FCMの処理フロー**:
```
1. initialize()でFCMを初期化
   ↓
2. requestPermission()で権限取得
   ↓
3. getToken()でFCMトークン取得
   ↓
4. saveFcmToken()でFirestoreに保存
   ↓
5. メッセージ受信時:
   - フォアグラウンド: _handleForegroundMessage()
   - バックグラウンド: firebaseMessagingBackgroundHandler()
   - 通知タップ: _handleMessageOpenedApp()
```

**通知のカスタマイズ**:
```dart
// lib/feature/settings/services/notification_service.dart:273
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

### 📦 Models層（データモデル）

#### `models/notification_settings.dart`
**役割**: 通知設定のデータ構造

**フィールド**:
```dart
// lib/feature/settings/models/notification_settings.dart:XX
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool isEnabled,       // 通知のON/OFF
    @Default(9) int hour,                // 通知時刻（時）
    @Default(0) int minute,              // 通知時刻（分）
    @Default('トピックが届いています') String message,  // 通知メッセージ
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}
```

**NotificationMessages（定数）**:
```dart
// lib/feature/settings/models/notification_settings.dart:XX
class NotificationMessages {
  static const List<String> messages = [
    'トピックが届いています',
    '今日のトピックをチェックしましょう',
    '新しいお題に挑戦してみませんか',
    'みんなの意見を見てみよう',
    'あなたの意見を聞かせてください',
  ];
}
```

**デフォルト値の変更**:
```dart
// デフォルトの通知時刻を変更したい場合
@Default(8) int hour,  // 朝8時に変更
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
- **アカウント操作**: ログアウト、アカウント削除

**主な機能**:
- プロフィール画像の表示
- 各種設定項目への遷移
- ログアウト/アカウント削除の確認ダイアログ

---

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

**バリデーション**:
- ニックネーム: 1文字以上必須
- パスワード: 新しいパスワードと確認用パスワードが一致
- メール変更: 現在のパスワードで再認証

---

### 3. 通知設定画面（notice_screen.dart）
**パス**: `/notice`（設定画面 → 通知から遷移）
**説明**: プッシュ通知の設定を行う画面

**設定項目**:
- 通知のON/OFF
- 通知時刻（6:00〜23:00）
- 通知メッセージ（5種類のプリセット）
- テスト通知送信

**動作**:
- 設定変更時にリアルタイムで保存
- 通知スケジュールの自動更新
- テスト通知で動作確認可能

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

---

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

---

### 3. プロフィール項目の追加

**ファイル**: `presentation/pages/profile_screen.dart`

**手順**:
1. UIに新しいフィールドを追加
2. `ProfileEditState`に新しいフィールドを追加
3. `ProfileEditNotifier`に更新メソッドを追加
4. `ProfileUpdateNotifier`の`updateProfile`メソッドを更新
5. `UserModel`に新しいフィールドを追加（`auth/models/user/user_model.dart`）

**例**: 電話番号を追加
```dart
// 1. ProfileEditStateに追加
@freezed
class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState({
    required String nickname,
    String? phone,  // 追加
    // ...
  }) = _ProfileEditState;
}

// 2. UIに追加
_buildTextField(
  controller: _phoneController,
  label: '電話番号',
  icon: Icons.phone,
  keyboardType: TextInputType.phone,
),

// 3. 保存処理に追加
await profileUpdateNotifier.updateProfile(
  userId: user.id,
  nickname: newNickname,
  phone: state.phone,  // 追加
);
```

---

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

// ターミナルで実行
flutter pub run build_runner build --delete-conflicting-outputs
```

#### ステップ2: プロバイダーを作成
```dart
// providers/language_provider.dart
final languageProvider = StateNotifierProvider<LanguageNotifier, String>(
  (ref) => LanguageNotifier(),
);

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('ja') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('language') ?? 'ja';
  }

  Future<void> changeLanguage(String newLanguage) async {
    state = newLanguage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLanguage);
  }
}
```

#### ステップ3: 画面を作成
```dart
// presentation/pages/language_screen.dart
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('言語設定')),
      body: ListView(
        children: [
          RadioListTile<String>(
            title: const Text('日本語'),
            value: 'ja',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                ref.read(languageProvider.notifier).changeLanguage(value);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                ref.read(languageProvider.notifier).changeLanguage(value);
              }
            },
          ),
        ],
      ),
    );
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

4. **タイムゾーン設定を確認**
   - `notification_service.dart`で`Asia/Tokyo`に設定されているか確認

---

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

4. **再認証が必要な操作を確認**
   - メールアドレス変更
   - パスワード変更

---

### Freezedの再生成が必要な場合

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**自動生成されるファイル**:
- `*.freezed.dart`
- `*.g.dart`

---

### FCMトークンが取得できない場合（iOS）

**原因**: APNSトークンがまだ準備できていない

**解決方法**:
- エラーは無視してOK
- `onTokenRefresh`リスナーで後で自動的に取得される
- アプリを再起動すると取得されることが多い

```dart
// lib/feature/settings/services/notification_service.dart:80-92
try {
  _fcmToken = await _messaging.getToken();
} on FirebaseException catch (e) {
  if (e.code == 'apns-token-not-set') {
    // これは正常な動作
    debugPrint('APNSトークンがまだ準備できていません');
  }
}
```

---

## 依存パッケージの詳細

```yaml
dependencies:
  # 状態管理
  flutter_riverpod: ^3.0.0       # Riverpod状態管理

  # データモデル
  freezed_annotation: ^2.4.1     # Freezedアノテーション
  json_annotation: ^4.8.1        # JSON変換

  # ローカルストレージ
  shared_preferences: ^2.2.2     # キー/バリューストレージ

  # 画像選択
  image_picker: 最新版            # ギャラリー/カメラから画像選択

  # 通知
  flutter_local_notifications: ^18.0.1  # ローカル通知
  timezone: ^0.9.2               # タイムゾーン管理

  # Firebase
  firebase_auth: 最新版           # 認証
  firebase_messaging: 最新版      # FCM
  cloud_firestore: 最新版         # データベース
  firebase_storage: 最新版        # ストレージ

dev_dependencies:
  # コード生成
  build_runner: ^2.4.6           # ビルドランナー
  freezed: ^2.4.5                # Freezedコード生成
  json_serializable: ^6.7.1      # JSON変換コード生成
```

---

## 参考リンク

- [Flutter Riverpod公式ドキュメント](https://riverpod.dev/)
- [Freezed公式ドキュメント](https://pub.dev/packages/freezed)
- [flutter_local_notifications公式ドキュメント](https://pub.dev/packages/flutter_local_notifications)
- [SharedPreferences公式ドキュメント](https://pub.dev/packages/shared_preferences)
- [Firebase Messaging公式ドキュメント](https://firebase.google.com/docs/cloud-messaging)

---

## 更新履歴

- **2025-12-05**: READMEの大幅更新
  - 依存関係の詳細を追加
  - クラス図と関係性を追加
  - データフローの説明を追加
  - 各ファイルの行番号参照を追加
  - FCM機能の説明を追加

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
4. **ファイル配置**: 適切なディレクトリ（models/providers/presentation/services）に配置
5. **依存関係**: 必要最小限に抑え、循環参照を避ける
6. **ドキュメント**: このREADME.mdを更新
7. **テスト**: 可能な限りユニットテストを追加

### コーディング規約
- プロバイダーは常にRiverpodを使用
- 外部APIとの通信はServicesレイヤーで実装
- UIとビジネスロジックを分離
- エラーハンドリングを適切に行う

---

## ライセンス

このプロジェクトの一部として、同じライセンスが適用されます。

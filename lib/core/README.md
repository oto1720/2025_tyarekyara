# lib/core

このディレクトリには、アプリケーション全体で使用される共通機能とコア機能が含まれています。

## 📁 ディレクトリ構成

```
lib/core/
├── route/                 # ルーティング設定
│   └── app_router.dart
├── constants/             # アプリ全体の定数
│   └── app_colors.dart
├── providers/             # グローバルプロバイダー
│   ├── debate_event_unlock_provider.dart
│   └── theme_provider.dart
└── utils/                 # ユーティリティクラス
    └── timestamp_converter.dart
```

---

## 🎯 主要コンポーネント

### 1. route/ - ルーティング設定

#### `app_router.dart`

アプリケーション全体のナビゲーションを管理するGoRouterの設定ファイル。

**主要機能:**
- アプリ全体のルーティング定義
- 認証状態に基づくリダイレクト処理
- ゲストモードとチュートリアル完了状態の管理
- ShellRouteによるボトムナビゲーション実装

**主要な変数:**
- `router: GoRouter` - アプリケーションのルーター

**リダイレクトロジック:**
```dart
redirect: (context, state) async {
  // SharedPreferencesで状態確認
  - 認証状態 (FirebaseAuth)
  - ゲストモード ('is_guest_mode')
  - チュートリアル完了 ('tutorial_completed')

  // 状態に基づいてリダイレクト先を決定
}
```

**ルート構成:**
- **認証関連**: `/login`, `/signup`, `/profile-setup`, `/forgot-password` など
- **メインアプリ (ShellRoute)**: `/` (ホーム), `/challenge`, `/debate`, `/statistics`
- **ディベート関連**: `/debate/event/:eventId`, `/debate/room/:matchId` など
- **チャレンジ関連**: `/challenge/:challengeId`, `/challenge/:challengeId/feedback`

**依存関係:**
- `go_router` - Flutter用ルーティングパッケージ
- `shared_preferences` - ローカルストレージ
- `firebase_auth` - Firebase認証
- `cloud_firestore` - Firestore
- 各feature配下のページコンポーネント
- `widgets/bottom_navigation.dart` - ボトムナビゲーションバー

**使用例:**
```dart
// main.dartで使用
MaterialApp.router(
  routerConfig: router,
  // ...
)
```

---

### 2. constants/ - 定数定義

#### `app_colors.dart`

アプリケーション全体で使用するカラーパレット。

**主要機能:**
- ライトモード/ダークモードの色定義
- テーマに応じた動的カラー取得
- 意見の立場別カラー（賛成/中立/反対）
- カテゴリ別カラー
- 難易度別カラー
- その他UIカラー（成功/警告/エラーなど）

**主要なクラス:**
- `AppColors` - アプリ全体のカラーパレットを提供する静的クラス

**主要なメソッド:**
```dart
// テーマ対応の動的カラー取得
static Color getBackground(Brightness brightness)
static Color getSurface(Brightness brightness)
static Color getPrimary(Brightness brightness)
static Color getTextPrimary(Brightness brightness)
// その他のゲッターメソッド
```

**主要な定数:**
```dart
// ライトモード
static const primary = Color(0xFF2C3E50)
static const background = Color(0xFFFAFAFA)
static const textPrimary = Color(0xFF1A1A1A)

// ダークモード
static const darkPrimary = Color(0xFFECF0F1)
static const darkBackground = Color(0xFF121212)
static const darkTextPrimary = Color(0xFFE8E8E8)

// 意見の立場別カラー
static const agree = Color(0xFF4CAF50)      // 賛成（緑）
static const neutral = Color(0xFF9E9E9E)    // 中立（グレー）
static const disagree = Color(0xFFF44336)   // 反対（赤）

// カテゴリ別カラー
static const categorySocial = Color(0xFF2196F3)   // 社会
static const categoryValue = Color(0xFF9C27B0)    // 価値観
static const categoryDaily = Color(0xFFFF9800)    // 日常

// 難易度別カラー
static const difficultyEasy = Color(0xFF4CAF50)
static const difficultyNormal = Color(0xFFFF9800)
static const difficultyHard = Color(0xFFF44336)
```

**依存関係:**
- `flutter/material.dart`

**使用例:**
```dart
// Brightnessを使った動的カラー取得
Container(
  color: AppColors.getBackground(Theme.of(context).brightness),
)

// 直接カラー使用
Text('賛成', style: TextStyle(color: AppColors.agree))
```

---

### 3. providers/ - グローバルプロバイダー

#### `theme_provider.dart`

アプリのテーマモード（ライト/ダーク/システム）を管理。

**主要機能:**
- テーマモードの状態管理
- SharedPreferencesへの永続化
- アプリ起動時のテーマ設定読み込み

**主要なクラス:**
- `ThemeModeNotifier extends Notifier<ThemeMode>` - テーマモードの状態管理

**主要なメソッド:**
```dart
ThemeMode build()                          // 初期値（system）を返し、非同期で保存値を読み込み
Future<void> _loadThemeMode()              // SharedPreferencesから設定を読み込み
Future<void> setThemeMode(ThemeMode mode)  // テーマモードを設定して保存
```

**プロバイダー:**
```dart
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>
```

**SharedPreferencesキー:**
- `'theme_mode'` - テーマモードのインデックス (0: system, 1: light, 2: dark)

**依存関係:**
- `flutter/material.dart` - ThemeModeクラス
- `flutter_riverpod` - 状態管理
- `shared_preferences` - ローカルストレージ

**使用例:**
```dart
// テーマモードの読み取り
final themeMode = ref.watch(themeModeProvider);

// テーマモードの変更
ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
```

#### `debate_event_unlock_provider.dart`

ディベート機能のアンロック状態を管理。日次トピックへの回答完了を条件に、ディベート機能へのアクセスを制御。

**主要機能:**
- 今日のディベートイベントの解放状態チェック
- 特定イベントの解放状態チェック
- トピック回答状況とディベート機能の連携

**プロバイダー:**
```dart
// 今日のディベートイベントが解放されているかチェック
final isTodayDebateUnlockedProvider = FutureProvider.autoDispose<bool>

// 特定のイベントIDが解放されているかチェック
final isDebateEventUnlockedProvider = FutureProvider.autoDispose.family<bool, String>
```

**解放ロジック:**
1. Firebase認証状態を確認（未認証 → false）
2. 今日のトピックを取得（トピックなし → false）
3. ユーザーの意見が存在するかチェック（意見あり → true）

**特定イベントの解放ロジック:**
- 今日のイベント → トピック回答必須
- 過去のイベント → 常に解放

**依存関係:**
- `flutter/foundation.dart`
- `flutter_riverpod`
- `feature/home/providers/daily_topic_provider.dart` - 日次トピック取得
- `feature/home/providers/opinion_provider.dart` - 意見データ取得
- `feature/debate/providers/today_debate_event_provider.dart` - 今日のイベント判定
- `feature/auth/providers/auth_provider.dart` - 認証状態

**使用例:**
```dart
// 今日のディベートが解放されているかチェック
final isUnlocked = await ref.watch(isTodayDebateUnlockedProvider.future);

// 特定のイベントが解放されているかチェック
final eventUnlocked = await ref.watch(
  isDebateEventUnlockedProvider(eventId).future
);
```

---

### 4. utils/ - ユーティリティ

#### `timestamp_converter.dart`

Firebase TimestampとDartのDateTimeの相互変換を行うコンバーター。

**主要機能:**
- `Timestamp` → `DateTime` の変換
- `DateTime` → `Timestamp` の変換
- freezed/json_serializableとの統合

**主要なクラス:**
```dart
class TimestampConverter implements JsonConverter<DateTime, dynamic>
```

**主要なメソッド:**
```dart
DateTime fromJson(dynamic json)  // Timestamp → DateTime
dynamic toJson(DateTime object)  // DateTime → Timestamp
```

**依存関係:**
- `cloud_firestore` - Timestampクラス
- `freezed_annotation` - JsonConverterインターフェース

**使用例:**
```dart
@freezed
class ExampleModel with _$ExampleModel {
  const factory ExampleModel({
    @TimestampConverter() required DateTime createdAt,
  }) = _ExampleModel;

  factory ExampleModel.fromJson(Map<String, dynamic> json)
    => _$ExampleModelFromJson(json);
}
```

---

## 🔗 依存関係マップ

### 外部パッケージ依存

```
route/app_router.dart
  ├─ go_router
  ├─ shared_preferences
  ├─ firebase_auth
  └─ cloud_firestore

constants/app_colors.dart
  └─ flutter/material.dart

providers/theme_provider.dart
  ├─ flutter/material.dart
  ├─ flutter_riverpod
  └─ shared_preferences

providers/debate_event_unlock_provider.dart
  ├─ flutter/foundation.dart
  └─ flutter_riverpod

utils/timestamp_converter.dart
  ├─ cloud_firestore
  └─ freezed_annotation
```

### プロジェクト内部依存

```
route/app_router.dart
  ├─ widgets/bottom_navigation.dart
  ├─ feature/auth/presentaion/pages/*
  ├─ feature/home/presentation/pages/*
  ├─ feature/challenge/presentaion/pages/*
  ├─ feature/debate/presentation/pages/*
  ├─ feature/statistics/presentation/pages/*
  ├─ feature/settings/presentation/pages/*
  ├─ feature/guide/presentaion/pages/*
  └─ feature/terms/presentation/pages/*

providers/debate_event_unlock_provider.dart
  ├─ feature/home/providers/daily_topic_provider.dart
  ├─ feature/home/providers/opinion_provider.dart
  ├─ feature/debate/providers/today_debate_event_provider.dart
  └─ feature/auth/providers/auth_provider.dart
```

---

## 📝 使用上の注意

### app_router.dart
- 新しいルートを追加する場合は、適切なShellRoute内またはトップレベルに配置
- リダイレクトロジックを変更する際は、無限ループに注意
- ボトムナビゲーションを表示したいページはShellRoute内に配置

### app_colors.dart
- 新しい色を追加する際は、ライトモードとダークモードの両方を定義
- `Brightness`を引数に取るゲッターメソッドの追加を検討

### theme_provider.dart
- テーマ変更は`setThemeMode`メソッドを使用（状態とストレージの両方が更新される）
- 直接`state`を変更しない

### debate_event_unlock_provider.dart
- `autoDispose`が設定されているため、画面遷移時にキャッシュがクリアされる
- 解放条件の変更時は、両プロバイダーのロジックを確認

### timestamp_converter.dart
- freezedモデルで日時フィールドを使う際は必ず`@TimestampConverter()`アノテーションを追加
- Firestore保存時に自動的にTimestamp型に変換される

---

## 🚀 開発ガイドライン

### 新しいルート追加手順
1. `lib/feature/`配下に画面ファイルを作成
2. `lib/core/route/app_router.dart`にルート定義を追加
3. 必要に応じて`lib/widgets/bottom_navigation.dart`を更新

### 新しいグローバルプロバイダー追加手順
1. `lib/core/providers/`配下に新しいプロバイダーファイルを作成
2. `NotifierProvider`または適切なプロバイダータイプを使用
3. 必要に応じてSharedPreferencesで状態を永続化

### カラー追加手順
1. `app_colors.dart`にライト/ダークの両方の色定数を追加
2. 必要に応じて動的カラー取得メソッドを追加
3. セマンティックな名前を使用（例: `success`, `warning`）

---

## 🔄 状態管理パターン

### テーマ状態
```
SharedPreferences ←→ ThemeModeNotifier ←→ UI
     (永続化)            (状態管理)       (表示)
```

### ディベート解放状態
```
Firestore (意見データ)
    ↓
OpinionRepository
    ↓
debate_event_unlock_provider
    ↓
UI (ディベートボタンの有効/無効)
```

### ルーティング状態
```
SharedPreferences (is_guest_mode, tutorial_completed)
    +
FirebaseAuth (認証状態)
    ↓
app_router redirect ロジック
    ↓
適切な画面へ遷移
```

---

## 📚 関連ドキュメント

- [Go Router公式ドキュメント](https://pub.dev/packages/go_router)
- [Riverpod公式ドキュメント](https://riverpod.dev/)
- [Flutter Theming](https://docs.flutter.dev/cookbook/design/themes)
- [プロジェクトメモリ: navigation_and_user_state](../../docs/navigation_and_user_state.md)

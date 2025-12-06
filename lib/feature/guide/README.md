# Guide機能 (チュートリアル・ガイドシステム)

このディレクトリには、アプリのオンボーディングおよび操作ガイド機能が含まれています。

## 目次

- [概要](#概要)
- [システムアーキテクチャ](#システムアーキテクチャ)
- [ディレクトリ構造](#ディレクトリ構造)
- [2つのチュートリアルシステム](#2つのチュートリアルシステム)
  - [1. 初回チュートリアル](#1-初回チュートリアル)
  - [2. ページ内チュートリアル](#2-ページ内チュートリアル)
- [主要コンポーネント詳細](#主要コンポーネント詳細)
- [依存関係](#依存関係)
- [他機能との関係](#他機能との関係)
- [使用例](#使用例)
- [拡張方法](#拡張方法)
- [トラブルシューティング](#トラブルシューティング)

---

## 概要

Guide機能は、ユーザーがアプリを効果的に利用できるようサポートする、2つの異なるチュートリアルシステムを提供します。

### 目的

1. **新規ユーザーへのオンボーディング**: アプリの全体像と主要機能の紹介
2. **画面ごとの操作ガイド**: 各機能の詳細な使い方を説明

### 特徴

- ✨ **2つの独立したチュートリアルシステム**
  - 初回チュートリアル: スライド形式の全体説明
  - ページ内チュートリアル: 各画面での操作ガイド
- 💾 **永続化**: SharedPreferencesで表示状態を管理
- 🎨 **視覚的デザイン**: グラデーション、画像、アニメーション
- ⏭️ **スキップ可能**: ユーザーの選択を尊重
- 📱 **レスポンシブ**: タブレット・スマートフォン対応

---

## システムアーキテクチャ

```
Guide機能
├── 初回チュートリアル
│   ├── FirstPage (ウェルカム画面)
│   └── TutorialPage (スライド式説明)
│
└── ページ内チュートリアル
    ├── ShowcaseView (UI要素ハイライト)
    └── TutorialBottomSheet (操作ガイド表示)
```

### データフロー

```
起動
 ├─→ 初回起動？
 │    ├─ Yes → FirstPage → TutorialPage → Home
 │    └─ No  → Home
 │
 └─→ 各画面遷移時
      └─→ 初回表示？
           ├─ Yes → ShowcaseView表示 & TutorialBottomSheet利用可能
           └─ No  → 通常表示
```

---

## ディレクトリ構造

```
lib/feature/guide/
├── models/
│   ├── tutorial_item.dart           # 初回チュートリアルのデータモデル
│   └── page_tutorial_data.dart      # ページ内チュートリアルのデータモデル
│
├── providers/
│   ├── tutorial_provider.dart       # 初回チュートリアルの状態管理
│   └── page_tutorial_provider.dart  # ページ内チュートリアルの状態管理
│
├── presentaion/
│   ├── pages/
│   │   ├── first_page.dart          # アプリ起動時の最初のページ
│   │   └── tutorial_page.dart       # スライド式チュートリアル
│   │
│   └── widgets/
│       ├── tutorial_card.dart               # チュートリアルカードWidget
│       ├── tutorial_dialog.dart             # 操作ガイドボトムシート
│       └── tutorial_showcase_wrapper.dart   # ShowcaseView管理Wrapper
│
└── README.md
```

**注意**: `presentaion` ディレクトリはスペルミスですが、既存コードとの整合性のためそのままにしています。

---

## 2つのチュートリアルシステム

### 1. 初回チュートリアル

新規ユーザーに対して、アプリ全体の使い方を説明するワンタイム表示のチュートリアル。

#### 構成

##### FirstPage (`presentaion/pages/first_page.dart`)

- **役割**: アプリ起動時の最初の画面
- **表示タイミング**: 未ログイン & チュートリアル未完了時
- **主要機能**:
  - アプリ名とロゴの表示
  - レスポンシブデザイン（画面サイズに応じた自動調整）
  - 「始める」ボタン → `/tutorial` へ遷移
  - 「ログイン」リンク → `/login` へ遷移

```dart
// 遷移例
context.go('/tutorial');  // チュートリアルへ
context.go('/login');      // ログインへ
```

##### TutorialPage (`presentaion/pages/tutorial_page.dart`)

- **役割**: PageView形式のスライドチュートリアル
- **ページ数**: 9ページ（TutorialData.itemsで定義）
- **主要機能**:
  - スワイプでページ移動
  - ページインジケーター
  - スキップボタン
  - 完了後にSharedPreferencesへ保存

**UI構成**:
```
┌─────────────────────────────────────┐
│  AppBar                              │
│    右上: [スキップ] ボタン            │
├─────────────────────────────────────┤
│                                     │
│  PageView (スワイプ可能)              │
│    ┌─────────────────────┐         │
│    │   TutorialCard      │         │
│    │   - グラデーション    │         │
│    │   - アイコン         │         │
│    │   - タイトル         │         │
│    │   - 説明文          │         │
│    │   - 画像 (オプション) │         │
│    └─────────────────────┘         │
│                                     │
├─────────────────────────────────────┤
│  ●●○○○  (PageIndicator)            │
│                                     │
│  [戻る]           [次へ / 始める]    │
└─────────────────────────────────────┘
```

#### データモデル

##### TutorialItem (`models/tutorial_item.dart`)

```dart
class TutorialItem {
  final String title;              // タイトル
  final String description;        // 説明文
  final IconData icon;             // アイコン
  final String? imagePath;         // 画像パス (オプション)
  final Color primaryColor;        // グラデーション開始色
  final Color secondaryColor;      // グラデーション終了色
  final String? subtitle;          // サブタイトル (オプション)
  final List<String>? bulletPoints; // 箇条書きリスト (オプション)
  final bool showImage;            // 画像表示フラグ (デフォルト: true)
}
```

##### TutorialData (`models/tutorial_item.dart`)

```dart
class TutorialData {
  static const List<TutorialItem> items = [
    // 9ページのチュートリアル定義
    // 1. エコチェンバー現象の説明
    // 2. Criticaの目的
    // 3. 機能一覧
    // 4. 意見を投稿
    // 5. 他の人の意見を見る
    // 6. チャレンジ機能
    // 7. ディベートを始める
    // 8. 統計情報を見る
    // 9. 始めましょう！
  ];
}
```

#### 状態管理

##### TutorialProvider (`providers/tutorial_provider.dart`)

```dart
// チュートリアル完了状態の取得
final tutorialCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('tutorial_completed') ?? false;
});

// ページ遷移の管理
final tutorialNotifierProvider = NotifierProvider<TutorialNotifier, int>(() {
  return TutorialNotifier();
});

class TutorialNotifier extends Notifier<int> {
  int build() => 0;  // 初期ページ: 0

  void nextPage()      // 次のページへ
  void previousPage()  // 前のページへ
  void goToPage(int)   // 指定ページへ
  Future<void> completeTutorial()  // チュートリアル完了
  Future<void> resetTutorial()     // リセット (デバッグ用)
}
```

**SharedPreferencesキー**:
- `tutorial_completed`: boolean - チュートリアル完了フラグ

---

### 2. ページ内チュートリアル

各画面で、その画面固有の操作方法を説明するチュートリアル。

#### 構成

##### TutorialShowcaseWrapper (`presentaion/widgets/tutorial_showcase_wrapper.dart`)

- **役割**: ShowCaseViewパッケージを使った、UI要素のハイライト表示管理
- **表示タイミング**: 各画面の初回表示時
- **依存パッケージ**: `showcaseview: ^3.0.0`

```dart
// 使用例
TutorialShowcaseWrapper(
  pageKey: 'home',           // ページ識別子
  showcaseKey: _showcaseKey, // ハイライト対象のGlobalKey
  child: YourWidget(),
)
```

**動作フロー**:
```
1. initState()
   ↓
2. hasShownTutorial()で表示済みかチェック
   ↓
3. 未表示の場合
   ↓
4. WidgetsBinding.instance.addPostFrameCallback()
   ↓
5. ShowCaseWidget.of(context).startShowCase([showcaseKey])
   ↓
6. markTutorialShown()で表示済みフラグを保存
```

##### TutorialBottomSheet (`presentaion/widgets/tutorial_dialog.dart`)

- **役割**: 各画面の操作手順を詳細に説明するボトムシート
- **表示方法**: ヘルプボタンなどから手動で呼び出し

```dart
// 使用例
TutorialBottomSheet.show(context, 'home');
```

**UI構成**:
```
┌─────────────────────────────┐
│  ハンドルバー                 │
│  ┌─────────────────────┐    │
│  │ 📖 操作ガイド    [×] │    │
│  └─────────────────────┘    │
│  ─────────────────────────  │
│                             │
│  1. トピックを確認           │
│  [画像]                     │
│  トピックを確認し...         │
│                             │
│  2. 意見を投稿              │
│  [画像]                     │
│  賛成・反対・中立...         │
│                             │
│  ...                        │
│                             │
│  [閉じる]                   │
└─────────────────────────────┘
```

#### データモデル

##### TutorialStep (`models/page_tutorial_data.dart`)

```dart
class TutorialStep {
  final String title;        // ステップタイトル
  final String description;  // ステップ説明
  final String? imagePath;   // 説明画像パス (オプション)
}
```

##### PageTutorialData (`models/page_tutorial_data.dart`)

```dart
class PageTutorialData {
  static const Map<String, List<TutorialStep>> tutorials = {
    'home': [/* ホーム画面のチュートリアルステップ */],
    'statistics': [/* 統計画面のチュートリアルステップ */],
    'challenge': [/* チャレンジ画面のチュートリアルステップ */],
    'debate': [/* ディベート画面のチュートリアルステップ */],
  };
}
```

**定義済みページ**:
- `home`: 5ステップ（トピック確認、意見投稿、意見閲覧、チャレンジ、ディベート）
- `statistics`: 3ステップ（参加統計、多様性スコア、バッジ）
- `challenge`: 4ステップ（選択、意見考案、フィードバック、ポイント獲得）
- `debate`: 5ステップ（選択、エントリー、待機、ディベート、AI判定）

#### 状態管理

##### PageTutorialProvider (`providers/page_tutorial_provider.dart`)

```dart
final pageTutorialProvider =
    NotifierProvider<PageTutorialNotifier, Map<String, bool>>(() {
  return PageTutorialNotifier();
});

class PageTutorialNotifier extends Notifier<Map<String, bool>> {
  Future<bool> hasShownTutorial(String pageKey)        // 表示済みチェック
  Future<void> markTutorialShown(String pageKey)       // 表示済みマーク
  Future<void> resetTutorial(String pageKey)           // リセット
  Future<void> resetAllTutorials()                     // 全リセット
}
```

**SharedPreferencesキー**:
- `tutorial_shown_{pageKey}`: boolean - 各ページのチュートリアル表示済みフラグ
  - 例: `tutorial_shown_home`, `tutorial_shown_statistics`

---

## 主要コンポーネント詳細

### TutorialCard (`presentaion/widgets/tutorial_card.dart`)

初回チュートリアルで使用されるカードWidget。

**プロパティ**:
- `item`: TutorialItem - 表示するチュートリアルデータ

**デザイン仕様**:
- カード幅: 最大400px (レスポンシブ)
- カード高さ: 最大500px (コンテンツに応じて調整)
- カード角丸: 24px
- elevation: 8 (浮遊感)
- グラデーション: LinearGradient (primaryColor → secondaryColor)

**表示要素**:
1. アイコン (円形、グラデーション背景)
2. サブタイトル (オプション)
3. タイトル (32px、太字)
4. 説明文 (18px、行間1.6)
5. 箇条書きリスト (オプション)
6. 画像 (オプション、showImage=trueの場合)

---

## 依存関係

### 外部パッケージ

| パッケージ | バージョン | 用途 |
|-----------|-----------|------|
| `flutter_riverpod` | ^3.0.0 | 状態管理 |
| `go_router` | ^16.0.2 | ルーティング |
| `shared_preferences` | ^2.2.2 | ローカルストレージ（表示状態の永続化） |
| `showcaseview` | ^3.0.0 | UI要素のハイライト表示 |

### アプリ内依存

```dart
// core
import 'package:tyarekyara/core/constants/app_colors.dart';

// ルーティング設定
import 'package:tyarekyara/core/route/app_router.dart';
```

**app_colors.dart**:
- `AppColors.primary`: プライマリカラー
- `AppColors.primaryLight`: プライマリライトカラー
- `AppColors.background`: 背景色
- `AppColors.textSecondary`: セカンダリテキストカラー
- `AppColors.textOnPrimary`: プライマリ上のテキストカラー

### ルーティング設定 (`lib/core/route/app_router.dart`)

```dart
// 初回起動画面
GoRoute(
  path: '/first',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: FirstPage(),
  ),
),

// チュートリアル画面
GoRoute(
  path: '/tutorial',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: TutorialPage(),
  ),
),
```

**リダイレクトロジック**:
```dart
redirect: (context, state) async {
  final tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;
  final isAuthenticated = FirebaseAuth.instance.currentUser != null;

  // 未ログイン & チュートリアル未完了 → /first へ
  if (!isAuthenticated && !tutorialCompleted) {
    return '/first';
  }

  // ログイン済み & チュートリアル未完了 → /tutorial へ
  if (isAuthenticated && !tutorialCompleted) {
    return '/tutorial';
  }

  // チュートリアル完了済み → / (ホーム) へ
  return null;
}
```

---

## 他機能との関係

Guide機能は、以下の4つのfeatureで使用されています。

### 1. Home機能 (`lib/feature/home/`)

**使用箇所**: `presentation/pages/daily_topic_home.dart`

```dart
import 'package:tyarekyara/feature/guide/presentaion/widgets/tutorial_showcase_wrapper.dart';
import 'package:tyarekyara/feature/guide/presentaion/widgets/tutorial_dialog.dart';

// ShowcaseViewでUI要素をハイライト
TutorialShowcaseWrapper(
  pageKey: 'home',
  showcaseKey: _showcaseKey,
  child: SomeWidget(),
);

// ヘルプボタンからボトムシート表示
IconButton(
  icon: Icon(Icons.help_outline),
  onPressed: () => TutorialBottomSheet.show(context, 'home'),
);
```

### 2. Statistics機能 (`lib/feature/statistics/`)

**使用箇所**: `presentation/pages/statistic.dart`

```dart
// 統計画面のチュートリアル
TutorialShowcaseWrapper(
  pageKey: 'statistics',
  showcaseKey: _showcaseKey,
  child: StatisticsContent(),
);

TutorialBottomSheet.show(context, 'statistics');
```

### 3. Challenge機能 (`lib/feature/challenge/`)

**使用箇所**: `presentaion/pages/challenge.dart`

```dart
// チャレンジ画面のチュートリアル
TutorialShowcaseWrapper(
  pageKey: 'challenge',
  showcaseKey: _showcaseKey,
  child: ChallengeContent(),
);

TutorialBottomSheet.show(context, 'challenge');
```

### 4. Debate機能 (`lib/feature/debate/`)

**使用箇所**: `presentation/pages/debate_event_list_page.dart`

```dart
// ディベート画面のチュートリアル
TutorialShowcaseWrapper(
  pageKey: 'debate',
  showcaseKey: _showcaseKey,
  child: DebateContent(),
);

TutorialBottomSheet.show(context, 'debate');
```

---

## 使用例

### 初回チュートリアルの完了チェック

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyarekyara/feature/guide/providers/tutorial_provider.dart';

class SomeWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialCompleted = ref.watch(tutorialCompletedProvider);

    return tutorialCompleted.when(
      data: (completed) {
        if (completed) {
          return HomeScreen();
        } else {
          return TutorialPage();
        }
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

### ページ内チュートリアルの実装

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tyarekyara/feature/guide/presentaion/widgets/tutorial_showcase_wrapper.dart';
import 'package:tyarekyara/feature/guide/presentaion/widgets/tutorial_dialog.dart';

class NewFeaturePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<NewFeaturePage> createState() => _NewFeaturePageState();
}

class _NewFeaturePageState extends ConsumerState<NewFeaturePage> {
  final GlobalKey _showcaseKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('新機能'),
          actions: [
            // ヘルプボタン
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                TutorialBottomSheet.show(context, 'new_feature');
              },
            ),
          ],
        ),
        body: TutorialShowcaseWrapper(
          pageKey: 'new_feature',
          showcaseKey: _showcaseKey,
          child: YourContent(
            child: Showcase(
              key: _showcaseKey,
              title: '重要な機能',
              description: 'この機能を使うと○○ができます',
              child: ElevatedButton(
                onPressed: () {},
                child: Text('アクション'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 新しいページのチュートリアルデータ追加

**1. `models/page_tutorial_data.dart` にデータ追加**:

```dart
class PageTutorialData {
  static const Map<String, List<TutorialStep>> tutorials = {
    // 既存のチュートリアル...

    // 新しいページのチュートリアル
    'new_feature': [
      TutorialStep(
        title: '1. 機能の選択',
        description: 'まず使いたい機能を選択します',
        imagePath: 'assets/images/tutorial/new_feature/step1.png',
      ),
      TutorialStep(
        title: '2. 設定の調整',
        description: '必要に応じて設定を調整できます',
        imagePath: 'assets/images/tutorial/new_feature/step2.png',
      ),
    ],
  };
}
```

**2. 画面で使用**:

```dart
TutorialBottomSheet.show(context, 'new_feature');
```

---

## 拡張方法

### 1. 初回チュートリアルにページを追加

**難易度**: ⭐ (簡単)

`models/tutorial_item.dart` の `TutorialData.items` に追加:

```dart
class TutorialData {
  static const List<TutorialItem> items = [
    // 既存のアイテム...

    // 新規追加
    TutorialItem(
      title: '新機能',
      subtitle: '新しく追加された機能',
      description: 'この新機能を使うと○○ができます',
      icon: Icons.new_releases,
      primaryColor: Color(0xFF00BCD4),
      secondaryColor: Color(0xFF0097A7),
      bulletPoints: [
        '機能1の説明',
        '機能2の説明',
        '機能3の説明',
      ],
      imagePath: 'assets/images/onboarding/new_feature.png',
      showImage: true,
    ),
  ];
}
```

**自動的に**:
- ページが追加される
- PageIndicatorが更新される
- スワイプナビゲーションが動作する

### 2. ページ内チュートリアルのカスタマイズ

**難易度**: ⭐⭐ (中級)

**ShowcaseViewのカスタマイズ**:

```dart
Showcase(
  key: _showcaseKey,
  title: 'カスタムタイトル',
  description: 'カスタム説明文',
  targetShapeBorder: CircleBorder(),  // ハイライト形状
  tooltipBackgroundColor: Colors.blue,
  textColor: Colors.white,
  targetBorderRadius: BorderRadius.circular(16),
  child: YourWidget(),
)
```

**複数の要素をハイライト**:

```dart
final _showcaseKeys = [
  GlobalKey(),
  GlobalKey(),
  GlobalKey(),
];

// 表示開始
ShowCaseWidget.of(context).startShowCase(_showcaseKeys);
```

### 3. チュートリアル完了後のアクション

**難易度**: ⭐⭐ (中級)

```dart
class TutorialNotifier extends Notifier<int> {
  Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);

    // カスタムアクション
    // 例: 初回ボーナスポイントを付与
    await _grantWelcomeBonus();

    // 例: アナリティクスイベント送信
    await _trackTutorialCompletion();

    ref.invalidate(tutorialCompletedProvider);
  }

  Future<void> _grantWelcomeBonus() async {
    // ボーナスポイント付与処理
  }

  Future<void> _trackTutorialCompletion() async {
    // アナリティクス送信処理
  }
}
```

### 4. バージョン管理によるチュートリアル再表示

**難易度**: ⭐⭐⭐ (上級)

アプリ更新時に新機能のチュートリアルを表示する:

```dart
class TutorialNotifier extends Notifier<int> {
  static const String currentVersion = '2.0.0';

  Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('tutorial_completed') ?? false;
    final lastVersion = prefs.getString('tutorial_version') ?? '0.0.0';

    // 未完了、またはバージョンが古い場合
    return !completed || lastVersion != currentVersion;
  }

  Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    await prefs.setString('tutorial_version', currentVersion);
    ref.invalidate(tutorialCompletedProvider);
  }
}
```

---

## トラブルシューティング

### Q1: チュートリアルが表示されない

**原因1**: ルーティングの問題

**解決策**:
```dart
// app_router.dart を確認
GoRoute(
  path: '/first',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: FirstPage(),
  ),
),
GoRoute(
  path: '/tutorial',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: TutorialPage(),
  ),
),
```

**原因2**: 既に完了済み

**解決策**:
```dart
// チュートリアルをリセット
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('tutorial_completed', false);

// または
await ref.read(tutorialNotifierProvider.notifier).resetTutorial();
```

---

### Q2: ShowcaseViewが表示されない

**原因**: ShowCaseWidgetでラップされていない

**解決策**:
```dart
// ページ全体をShowCaseWidgetでラップ
ShowCaseWidget(
  builder: (context) => YourPage(),
)
```

**原因**: GlobalKeyが重複している

**解決策**:
```dart
// 各Showcaseに固有のGlobalKeyを使用
final _showcaseKey1 = GlobalKey();
final _showcaseKey2 = GlobalKey();
final _showcaseKey3 = GlobalKey();
```

---

### Q3: 画像が表示されない

**原因**: assets の登録忘れ

**解決策**:
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/onboarding/
    - assets/images/tutorial/home/
    - assets/images/tutorial/statistics/
    - assets/images/tutorial/challenge/
    - assets/images/tutorial/debate/
```

**原因**: パスの間違い

**解決策**:
```dart
// 正しいパス
imagePath: 'assets/images/onboarding/icon.png',

// 間違い
imagePath: '/assets/images/onboarding/icon.png',  // 先頭の / は不要
imagePath: 'assets/images/onboarding/icon',       // 拡張子が必要
```

---

### Q4: ページ内チュートリアルが毎回表示される

**原因**: markTutorialShownが呼ばれていない

**解決策**:
```dart
// TutorialShowcaseWrapperを使用（自動でマークされる）
TutorialShowcaseWrapper(
  pageKey: 'your_page',
  showcaseKey: _showcaseKey,
  child: YourContent(),
);

// 手動でマークする場合
ref.read(pageTutorialProvider.notifier).markTutorialShown('your_page');
```

---

### Q5: リセット方法（開発・デバッグ用）

**初回チュートリアルのリセット**:
```dart
// Provider経由
await ref.read(tutorialNotifierProvider.notifier).resetTutorial();

// SharedPreferences直接操作
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('tutorial_completed', false);
```

**ページ内チュートリアルのリセット**:
```dart
// 特定のページ
await ref.read(pageTutorialProvider.notifier).resetTutorial('home');

// 全ページ
await ref.read(pageTutorialProvider.notifier).resetAllTutorials();

// SharedPreferences直接操作
final prefs = await SharedPreferences.getInstance();
await prefs.remove('tutorial_shown_home');
```

**アプリデータの完全リセット**:
- iOS: アプリを削除して再インストール
- Android: 設定 > アプリ > データを削除

---

## ベストプラクティス

### 1. チュートリアルの長さ

**初回チュートリアル**:
- 推奨: 5-7ページ
- 最大: 10ページまで
- 各ページ: 30秒以内で読める量

**ページ内チュートリアル**:
- 推奨: 3-5ステップ
- 最大: 7ステップまで

### 2. テキストの簡潔さ

❌ 悪い例:
```dart
description: 'このアプリケーションでは、様々な機能を利用することができます。'
             'まず最初に、プロフィールを設定する必要があります。'
             'プロフィールには、ニックネーム、年齢、地域などの情報を入力します。'
```

✅ 良い例:
```dart
description: 'プロフィールを設定して\nアプリを始めましょう！'
```

### 3. 視覚的階層

```dart
// タイトル: 大きく太字
fontSize: 32,
fontWeight: FontWeight.bold,

// サブタイトル: 中程度
fontSize: 20,
fontWeight: FontWeight.w600,

// 説明文: 標準
fontSize: 18,
height: 1.6,

// 補足: 小さめ
fontSize: 14,
color: Colors.grey[600],
```

### 4. アクセシビリティ

```dart
// コントラスト比を確保
primaryColor: Color(0xFF1976D2),  // 十分な濃さ
textColor: Colors.white,          // 背景とのコントラスト

// 読みやすいフォントサイズ
fontSize: 18,  // 最小でも16px以上推奨

// タップ領域を十分に確保
minWidth: 48,
minHeight: 48,
```

### 5. パフォーマンス最適化

**画像の最適化**:
- サイズ: 最大1024x1024
- 形式: WebP推奨（軽量）
- 圧縮: 品質80-90%

**アニメーション**:
```dart
// 適度な速さ
duration: const Duration(milliseconds: 300),
curve: Curves.easeInOut,
```

---

## 参考資料

- [Material Design - Onboarding](https://material.io/design/communication/onboarding.html)
- [Flutter PageView](https://api.flutter.dev/flutter/widgets/PageView-class.html)
- [Riverpod Documentation](https://riverpod.dev/)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [ShowcaseView](https://pub.dev/packages/showcaseview)

---

## 変更履歴

### v2.0.0 (2025-01-XX)
- ページ内チュートリアル機能を追加
- ShowcaseView統合
- TutorialBottomSheet追加
- PageTutorialDataモデル追加
- 4つの機能画面（home, statistics, challenge, debate）で使用開始

### v1.0.0 (2025-01-XX)
- 初版リリース
- 基本的なチュートリアル機能
- FirstPage追加
- TutorialPage実装
- 9ページのチュートリアルコンテンツ
- SharedPreferencesによる永続化

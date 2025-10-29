# チュートリアル機能 (Guide Feature)

このディレクトリには、初回登録後に表示されるチュートリアル機能が含まれています。

## 目次

- [概要](#概要)
- [ディレクトリー構造](#ディレクトリー構造)
- [主要コンポーネント](#主要コンポーネント)
- [機能フロー](#機能フロー)
- [拡張方法](#拡張方法)
- [カスタマイズガイド](#カスタマイズガイド)
- [実装の詳細](#実装の詳細)
- [トラブルシューティング](#トラブルシューティング)

---

## 概要

チュートリアル機能は、新規登録したユーザーに対して、アプリの使い方を視覚的に説明するためのオンボーディング機能です。

### 特徴

- ✨ **視覚的に魅力的**: グラデーション付きのフローティングカード
- 👆 **直感的な操作**: スワイプまたはボタンでページ移動
- 🎨 **カスタマイズ可能**: 色、アイコン、テキストを簡単に変更
- 💾 **永続化**: SharedPreferencesで完了状態を保存
- ⏭️ **スキップ可能**: ユーザーの選択を尊重

### デザインコンセプト

- **白背景**: 清潔感と視認性
- **フローティングカード**: 浮遊感のあるデザイン
- **グラデーション**: 各ページで異なる色使い
- **アニメーション**: スムーズな遷移とインジケーター

---

## ディレクトリー構造

```
lib/feature/guide/
├── models/
│   └── tutorial_item.dart          # チュートリアルデータモデル
├── providers/
│   └── tutorial_provider.dart      # 状態管理（Riverpod）
├── presentaion/
│   ├── pages/
│   │   └── tutorial_page.dart      # メイン画面
│   └── widgets/
│       └── tutorial_card.dart      # カードWidget
└── README.md                        # このファイル
```

---

## 主要コンポーネント

### 1. TutorialItem モデル

**ファイル**: `models/tutorial_item.dart`

チュートリアルの各ページを表すデータモデル。

```dart
class TutorialItem {
  final String title;            // ページのタイトル
  final String description;      // 説明文
  final IconData icon;           // 表示するアイコン
  final Color primaryColor;      // グラデーションの主色
  final Color secondaryColor;    // グラデーションの副色
}
```

#### フィールド詳細

| フィールド | 型 | 説明 | 例 |
|-----------|-----|------|-----|
| `title` | String | ページのタイトル（太字・大きめ） | "ようこそ！" |
| `description` | String | 説明文（改行可能） | "このアプリでは..." |
| `icon` | IconData | Material Icons | `Icons.waving_hand` |
| `primaryColor` | Color | グラデーション開始色 | `Color(0xFF6366F1)` |
| `secondaryColor` | Color | グラデーション終了色 | `Color(0xFF8B5CF6)` |

#### TutorialData クラス

チュートリアルのコンテンツを管理する静的クラス。

```dart
class TutorialData {
  static const List<TutorialItem> items = [
    // チュートリアルページのリスト
  ];
}
```

**現在のコンテンツ（5ページ）**:
1. ようこそ！
2. 意見を投稿
3. 他の人の意見を見る
4. プロフィール設定
5. さあ、始めましょう！

---

### 2. TutorialProvider

**ファイル**: `providers/tutorial_provider.dart`

Riverpodを使用した状態管理。

#### 提供されるProvider

##### 2.1 tutorialCompletedProvider

```dart
final tutorialCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('tutorial_completed') ?? false;
});
```

- **型**: `FutureProvider<bool>`
- **役割**: チュートリアルが完了しているかを取得
- **保存先**: SharedPreferences
- **キー**: `tutorial_completed`

##### 2.2 tutorialNotifierProvider

```dart
final tutorialNotifierProvider = NotifierProvider<TutorialNotifier, int>(() {
  return TutorialNotifier();
});
```

- **型**: `NotifierProvider<TutorialNotifier, int>`
- **状態**: 現在のページインデックス（0から始まる）
- **役割**: ページ遷移とチュートリアル完了の管理

#### TutorialNotifier クラス

| メソッド | 説明 | 戻り値 |
|---------|------|--------|
| `nextPage()` | 次のページへ移動 | void |
| `previousPage()` | 前のページへ移動 | void |
| `goToPage(int page)` | 特定のページへ移動 | void |
| `completeTutorial()` | チュートリアルを完了としてマーク | Future<void> |
| `resetTutorial()` | チュートリアルをリセット（デバッグ用） | Future<void> |

**使用例**:
```dart
// 次のページへ
ref.read(tutorialNotifierProvider.notifier).nextPage();

// チュートリアル完了
await ref.read(tutorialNotifierProvider.notifier).completeTutorial();
```

---

### 3. TutorialCard Widget

**ファイル**: `presentaion/widgets/tutorial_card.dart`

フローティングカードの見た目を担当するWidget。

#### 構造

```
┌─────────────────────────────────┐
│  Card (elevation: 8)             │
│  ┌───────────────────────────┐  │
│  │ Container (グラデーション)  │  │
│  │  ┌─────────────────────┐  │  │
│  │  │  円形アイコン          │  │  │
│  │  │  (グラデーション背景)  │  │  │
│  │  └─────────────────────┘  │  │
│  │                            │  │
│  │  タイトル（大きく太字）      │  │
│  │                            │  │
│  │  説明文（グレー）           │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

#### デザイン仕様

| 要素 | 値 | 説明 |
|------|-----|------|
| カード幅 | 最大400px | レスポンシブ対応 |
| カード高さ | 最大500px | コンテンツに応じて調整 |
| カード角丸 | 24px | 柔らかい印象 |
| カード影 | elevation: 8 | 浮遊感を演出 |
| アイコンサイズ | 120x120 | 円形 |
| アイコン内アイコン | 60px | Material Icon |
| タイトルサイズ | 32px | 太字 |
| 説明文サイズ | 18px | 行間1.6 |

#### PageIndicator Widget

ページ位置を示すドットインジケーター。

```dart
PageIndicator(
  currentPage: 2,           // 現在のページ（0から開始）
  totalPages: 5,            // 総ページ数
  activeColor: Colors.blue, // アクティブなドットの色
  inactiveColor: Colors.grey, // 非アクティブなドットの色
)
```

**アニメーション**:
- アクティブなドット: 幅24px
- 非アクティブなドット: 幅8px
- トランジション: 300ms（ease-in-out）

---

### 4. TutorialPage

**ファイル**: `presentaion/pages/tutorial_page.dart`

チュートリアルのメイン画面。

#### UI構成

```
┌─────────────────────────────────────┐
│  AppBar (透明)                       │
│    右上: [スキップ] ボタン            │
├─────────────────────────────────────┤
│                                     │
│  PageView (スワイプ可能)              │
│    ┌─────────────────────┐         │
│    │   TutorialCard      │         │
│    │                     │         │
│    └─────────────────────┘         │
│                                     │
├─────────────────────────────────────┤
│  ●●○○○  (PageIndicator)            │
│                                     │
│  [戻る]           [次へ / 始める]    │
└─────────────────────────────────────┘
```

#### 主要機能

1. **スワイプナビゲーション**
   - PageViewを使用
   - 左右スワイプでページ移動
   - アニメーション: 300ms

2. **ボタンナビゲーション**
   - 「戻る」ボタン: 2ページ目以降に表示
   - 「次へ」ボタン: 最終ページ以外
   - 「始める」ボタン: 最終ページのみ

3. **スキップ機能**
   - 右上の「スキップ」ボタン
   - 最終ページでは非表示
   - タップで即座にチュートリアル完了

#### 状態管理の流れ

```
1. PageView.onPageChanged
   ↓
2. TutorialNotifier.goToPage(index)
   ↓
3. state = index (Providerが更新)
   ↓
4. UI自動リビルド
   - PageIndicator更新
   - ボタンテキスト更新
```

#### 完了時の処理

```dart
Future<void> _completeTutorial() async {
  // 1. SharedPreferencesに保存
  await ref.read(tutorialNotifierProvider.notifier).completeTutorial();

  // 2. ホーム画面に遷移
  if (mounted) {
    context.go('/');
  }
}
```

---

## 機能フロー

### 初回登録時のフロー

```
新規登録
    ↓
メールアドレス・パスワード入力
    ↓
SignUpPage
    ↓ Firebase Authentication
    ↓
ProfileSetupPage
    ↓ プロフィール情報入力
    ↓ 保存成功
    ↓
TutorialPage ← ここ
    ↓ 5ページのチュートリアル
    ↓ 「始める」ボタン押下
    ↓
SharedPreferencesに保存
  - tutorial_completed: true
    ↓
HomeScreen
```

### 2回目以降のログイン

```
ログイン
    ↓
LoginPage
    ↓ 認証成功
    ↓
チュートリアル完了チェック
    ↓
tutorial_completed == true
    ↓
HomeScreen (チュートリアルスキップ)
```

---

## 拡張方法

### 1. 新しいチュートリアルページを追加

**難易度**: ⭐️ (簡単)

`models/tutorial_item.dart` を編集：

```dart
class TutorialData {
  static const List<TutorialItem> items = [
    // 既存のアイテム...

    // 新規追加（最後に追加するだけ）
    TutorialItem(
      title: '新機能の説明',
      description: 'この機能を使うと○○ができます。\n簡単に始められます！',
      icon: Icons.lightbulb,
      primaryColor: Color(0xFFFFAA00),
      secondaryColor: Color(0xFFFF6B00),
    ),
  ];
}
```

**これだけで**:
- ✅ 自動的にページが追加される
- ✅ PageIndicatorが自動更新される
- ✅ スワイプナビゲーションが動作する

---

### 2. 既存ページの内容を変更

**難易度**: ⭐️ (簡単)

`models/tutorial_item.dart` の該当項目を編集：

```dart
TutorialItem(
  title: '新しいタイトル',              // タイトル変更
  description: '変更した説明文',        // 説明文変更
  icon: Icons.star,                    // アイコン変更
  primaryColor: Color(0xFFFF0000),     // 色変更
  secondaryColor: Color(0xFFFF6666),
),
```

**変更可能な要素**:
- タイトル（制限なし）
- 説明文（改行は`\n`で挿入）
- アイコン（[Material Icons](https://fonts.google.com/icons)）
- 色（HEXカラーコード）

---

### 3. カスタムウィジェットを追加

**難易度**: ⭐️⭐️ (中級)

`TutorialCard` をカスタマイズして、画像やボタンを追加。

**ステップ**:

1. `TutorialItem` に新しいフィールドを追加：

```dart
class TutorialItem {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String? imageUrl;  // 追加

  const TutorialItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    this.imageUrl,  // 追加
  });
}
```

2. `TutorialCard` で画像を表示：

```dart
// tutorial_card.dart の build メソッド内
if (item.imageUrl != null)
  Image.network(
    item.imageUrl!,
    height: 200,
    fit: BoxFit.cover,
  ),
```

3. データに画像URLを追加：

```dart
TutorialItem(
  title: '画像付きページ',
  description: '画像で説明します',
  icon: Icons.image,
  primaryColor: Color(0xFF00AA00),
  secondaryColor: Color(0xFF00FF00),
  imageUrl: 'https://example.com/image.png',
),
```

---

### 4. チュートリアルのバージョン管理

**難易度**: ⭐️⭐️⭐️ (上級)

アプリ更新時に新機能のチュートリアルを表示する。

**実装方法**:

1. バージョン番号を保存：

```dart
// tutorial_provider.dart に追加
Future<void> completeTutorial({String version = '1.0.0'}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('tutorial_completed', true);
  await prefs.setString('tutorial_version', version);
}

Future<bool> shouldShowTutorial(String currentVersion) async {
  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool('tutorial_completed') ?? false;
  final savedVersion = prefs.getString('tutorial_version') ?? '0.0.0';

  // 完了していない、またはバージョンが古い場合に表示
  return !completed || savedVersion != currentVersion;
}
```

2. アプリ起動時にチェック：

```dart
final currentVersion = '1.1.0';
final shouldShow = await ref.read(tutorialNotifierProvider.notifier)
    .shouldShowTutorial(currentVersion);

if (shouldShow) {
  context.go('/tutorial');
}
```

---

### 5. 条件分岐によるチュートリアル切り替え

**難易度**: ⭐️⭐️⭐️ (上級)

ユーザーの属性（年齢、地域など）に応じて異なるチュートリアルを表示。

**実装例**:

```dart
class TutorialData {
  // 一般ユーザー向け
  static const List<TutorialItem> standardItems = [...];

  // 高齢者向け（大きな文字）
  static const List<TutorialItem> seniorItems = [...];

  // ユーザーに応じて適切なチュートリアルを返す
  static List<TutorialItem> getItemsForUser(UserModel user) {
    if (user.ageRange == '60代' || user.ageRange == '70代') {
      return seniorItems;
    }
    return standardItems;
  }
}
```

```dart
// tutorial_page.dart で使用
final currentUser = ref.watch(currentUserProvider).value;
final tutorialItems = currentUser != null
    ? TutorialData.getItemsForUser(currentUser)
    : TutorialData.standardItems;
```

---

## カスタマイズガイド

### 色の変更

Material Design のカラーパレットを参考に：

```dart
// 青系
primaryColor: Color(0xFF2196F3),
secondaryColor: Color(0xFF64B5F6),

// 緑系
primaryColor: Color(0xFF4CAF50),
secondaryColor: Color(0xFF81C784),

// 赤系
primaryColor: Color(0xFFF44336),
secondaryColor: Color(0xFFE57373),

// 紫系
primaryColor: Color(0xFF9C27B0),
secondaryColor: Color(0xFFBA68C8),
```

### アイコンの選び方

よく使われるMaterial Icons:

| カテゴリ | アイコン | 用途 |
|---------|---------|------|
| 挨拶 | `Icons.waving_hand` | ようこそ |
| 作成 | `Icons.create`, `Icons.edit` | 投稿機能 |
| コミュニティ | `Icons.people`, `Icons.groups` | ソーシャル機能 |
| 設定 | `Icons.settings`, `Icons.tune` | 設定画面 |
| 完了 | `Icons.check_circle`, `Icons.done` | 完了画面 |
| スタート | `Icons.rocket_launch`, `Icons.play_arrow` | 開始 |

### レイアウトの調整

`tutorial_card.dart` でサイズを調整：

```dart
Container(
  constraints: const BoxConstraints(
    maxWidth: 400,   // カード最大幅（変更可能）
    maxHeight: 500,  // カード最大高さ（変更可能）
  ),
  // ...
)
```

```dart
// アイコンサイズ
Container(
  width: 120,   // 変更可能
  height: 120,  // 変更可能
  child: Icon(
    item.icon,
    size: 60,    // 変更可能
  ),
)
```

```dart
// フォントサイズ
Text(
  item.title,
  style: TextStyle(
    fontSize: 32,  // タイトルサイズ（変更可能）
    fontWeight: FontWeight.bold,
  ),
)

Text(
  item.description,
  style: TextStyle(
    fontSize: 18,  // 説明文サイズ（変更可能）
    height: 1.6,   // 行間（変更可能）
  ),
)
```

---

## 実装の詳細

### SharedPreferences の使用

チュートリアル完了フラグは端末に永続化されます。

**保存先**: アプリのローカルストレージ
**キー**: `tutorial_completed`
**値**: `true` (完了) / `false` (未完了)

```dart
// 保存
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('tutorial_completed', true);

// 取得
final completed = prefs.getBool('tutorial_completed') ?? false;

// 削除（リセット）
await prefs.remove('tutorial_completed');
```

### Riverpod との統合

```dart
// 1. Provider定義
final tutorialNotifierProvider = NotifierProvider<TutorialNotifier, int>(...);

// 2. 読み取り（監視）
final currentPage = ref.watch(tutorialNotifierProvider);

// 3. 書き込み
ref.read(tutorialNotifierProvider.notifier).nextPage();

// 4. リスニング（副作用）
ref.listen(tutorialNotifierProvider, (previous, next) {
  print('ページが変更されました: $previous → $next');
});
```

### PageView の制御

```dart
final _pageController = PageController();

// プログラムでページ移動
_pageController.nextPage(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);

_pageController.previousPage(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);

// ユーザーのスワイプを検知
PageView(
  controller: _pageController,
  onPageChanged: (index) {
    ref.read(tutorialNotifierProvider.notifier).goToPage(index);
  },
  // ...
)
```

---

## トラブルシューティング

### Q1: チュートリアルが表示されない

**原因**: ルーティングが正しく設定されていない

**解決策**:
1. `app_router.dart` に `/tutorial` ルートが存在するか確認
2. `profile_setup_page.dart` で `context.go('/tutorial')` が呼ばれているか確認

```dart
// app_router.dart
GoRoute(
  path: '/tutorial',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: TutorialPage(),
  ),
),
```

---

### Q2: チュートリアルを再表示したい（デバッグ用）

**方法1**: Providerのメソッドを使用

```dart
await ref.read(tutorialNotifierProvider.notifier).resetTutorial();
```

**方法2**: SharedPreferencesを直接操作

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('tutorial_completed');
```

**方法3**: アプリデータを削除（最終手段）
- iOS: アプリを削除して再インストール
- Android: 設定 > アプリ > データを削除

---

### Q3: ページインジケーターの色が変わらない

**原因**: `activeColor` が正しく渡されていない

**解決策**:

```dart
PageIndicator(
  currentPage: currentPage,
  totalPages: _tutorialItems.length,
  activeColor: _tutorialItems[currentPage].primaryColor,  // ← 現在のページの色
  inactiveColor: Colors.grey[300]!,
)
```

---

### Q4: 画像を追加したい

**現在のTutorialItemモデルでは画像フィールドがありません。**

**解決策**: [拡張方法 #3](#3-カスタムウィジェットを追加) を参照

---

### Q5: ページ数が多すぎる場合の対処

**推奨**: 5-7ページ程度に抑える

**多い場合の対策**:
1. **グループ化**: 関連する機能をまとめる
2. **省略**: 重要な機能に絞る
3. **分割**: 基本チュートリアルと詳細チュートリアルに分ける

```dart
// 基本チュートリアル（必須）
static const List<TutorialItem> basicItems = [
  // 3-5ページ
];

// 詳細チュートリアル（オプション）
static const List<TutorialItem> advancedItems = [
  // 追加の説明
];
```

---

## ベストプラクティス

### 1. テキストは簡潔に

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

### 2. 1ページに1つのコンセプト

各ページは1つの機能や概念に集中させる。

### 3. 視覚的な階層

- **タイトル**: 大きく太字（32px）
- **説明文**: 中程度（18px）
- **補足**: 小さく（14px）

### 4. 色使いのガイドライン

- **暖色系**（赤・オレンジ）: アクション、重要な機能
- **寒色系**（青・緑）: 情報、安全な操作
- **紫系**: 特別な機能、プレミアム
- **黄色系**: 注意、新機能

### 5. アクセシビリティ

```dart
// コントラスト比を確保
primaryColor: Color(0xFF1976D2),  // 十分な濃さ
textColor: Colors.white,           // 背景とのコントラスト

// 読みやすいフォントサイズ
fontSize: 18,  // 最小でも16px以上推奨
```

---

## パフォーマンス最適化

### 1. 画像の最適化

もし画像を追加する場合:
- サイズ: 最大1024x1024
- 形式: WebP推奨（軽量）
- 圧縮: 品質80-90%

### 2. アニメーションの軽量化

```dart
// 過度なアニメーションは避ける
duration: const Duration(milliseconds: 300),  // 適度な速さ
```

### 3. 遅延読み込み

必要に応じて画像を遅延読み込み:

```dart
FadeInImage.memoryNetwork(
  placeholder: kTransparentImage,
  image: imageUrl,
)
```

---

## テスト

### 単体テスト例

```dart
void main() {
  test('TutorialNotifier starts at page 0', () {
    final container = ProviderContainer();
    final notifier = container.read(tutorialNotifierProvider);
    expect(notifier, 0);
  });

  test('nextPage increments page', () {
    final container = ProviderContainer();
    container.read(tutorialNotifierProvider.notifier).nextPage();
    final page = container.read(tutorialNotifierProvider);
    expect(page, 1);
  });
}
```

### ウィジェットテスト例

```dart
testWidgets('TutorialCard displays title and description', (tester) async {
  const item = TutorialItem(
    title: 'Test Title',
    description: 'Test Description',
    icon: Icons.star,
    primaryColor: Colors.blue,
    secondaryColor: Colors.lightBlue,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TutorialCard(item: item),
      ),
    ),
  );

  expect(find.text('Test Title'), findsOneWidget);
  expect(find.text('Test Description'), findsOneWidget);
});
```

---

## まとめ

### チュートリアル機能の拡張は簡単

1. **新しいページを追加**: `TutorialData.items` にアイテムを追加するだけ
2. **内容を変更**: 既存のアイテムを編集するだけ
3. **色を変更**: `primaryColor`と`secondaryColor`を変更するだけ

### 推奨される拡張順序

1. まず内容を決定（テキスト、アイコン）
2. 次に色を決定（ブランドカラーに合わせる）
3. 必要に応じてカスタムウィジェットを追加
4. ユーザーテストを実施
5. フィードバックに基づいて改善

---

## 参考資料

- [Material Design - Onboarding](https://material.io/design/communication/onboarding.html)
- [Flutter PageView](https://api.flutter.dev/flutter/widgets/PageView-class.html)
- [Riverpod Documentation](https://riverpod.dev/)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)

---

## 変更履歴

### v1.0.0 (2025-01-XX)

- 初版リリース
- 基本的なチュートリアル機能
- 5ページのモックコンテンツ
- SharedPreferencesによる永続化

# Tutorial Images

このディレクトリには、TutorialPage（チュートリアル画面）で使用する画像を配置します。

## 使用される画像（各ページ用）

- `welcome.png` - ページ1「ようこそ！」
- `post.png` - ページ2「意見を投稿」
- `people.png` - ページ3「他の人の意見を見る」
- `profile.png` - ページ4「プロフィール設定」
- `start.png` - ページ5「さあ、始めましょう！」

## 推奨サイズ

- 正方形: 800px × 800px（丸くトリミングされます）
- 形式: PNG, JPG

## 画像の追加方法

1. このディレクトリに画像ファイルを配置
2. `lib/feature/guide/models/tutorial_item.dart`の各TutorialItemに`imagePath`を追加

例：
```dart
TutorialItem(
  title: 'ようこそ！',
  description: '...',
  icon: Icons.waving_hand,
  imagePath: 'assets/images/tutorial/welcome.png', // この行を追加
  primaryColor: Color(0xFF6366F1),
  secondaryColor: Color(0xFF8B5CF6),
),
```

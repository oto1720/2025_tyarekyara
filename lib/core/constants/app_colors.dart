import 'package:flutter/material.dart';

/// アプリ全体で使用するカラーパレット
/// ロゴの白黒をベースにしたデザイン
class AppColors {
  AppColors._();

  // ========== テーマ対応の動的カラー取得メソッド ==========
  /// 現在のBrightnessに応じた背景色を取得
  static Color getBackground(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : background;
  }

  /// 現在のBrightnessに応じたサーフェス色を取得
  static Color getSurface(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurface : surface;
  }

  /// 現在のBrightnessに応じたサーフェスバリアント色を取得
  static Color getSurfaceVariant(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurfaceVariant : surfaceVariant;
  }

  /// 現在のBrightnessに応じたプライマリカラーを取得
  static Color getPrimary(Brightness brightness) {
    return brightness == Brightness.dark ? darkPrimary : primary;
  }

  /// 現在のBrightnessに応じたテキストプライマリカラーを取得
  static Color getTextPrimary(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextPrimary : textPrimary;
  }

  /// 現在のBrightnessに応じたテキストセカンダリカラーを取得
  static Color getTextSecondary(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextSecondary : textSecondary;
  }

  /// 現在のBrightnessに応じたボーダーカラーを取得
  static Color getBorder(Brightness brightness) {
    return brightness == Brightness.dark ? darkBorder : border;
  }

  /// 現在のBrightnessに応じたディバイダーカラーを取得
  static Color getDivider(Brightness brightness) {
    return brightness == Brightness.dark ? darkDivider : divider;
  }

  // ========== ライトモード: プライマリカラー（黒系）==========
  static const Color primary = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF333333);
  static const Color primaryDark = Color(0xFF000000);

  // ========== ライトモード: 背景色（白系）==========
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // ========== ライトモード: テキストカラー ==========
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ========== ライトモード: ボーダー・区切り線 ==========
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // ========== ダークモード: プライマリカラー（白系）==========
  static const Color darkPrimary = Color(0xFFFFFFFF);
  static const Color darkPrimaryLight = Color(0xFFE0E0E0);
  static const Color darkPrimaryDark = Color(0xFFF5F5F5);

  // ========== ダークモード: 背景色（黒系）==========
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  // ========== ダークモード: テキストカラー ==========
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);
  static const Color darkTextOnPrimary = Color(0xFF000000);

  // ========== ダークモード: ボーダー・区切り線 ==========
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkDivider = Color(0xFF2A2A2A);

  // ========== 機能色（意見・スタンス）==========
  static const Color agree = Color(0xFF10B981); // 賛成：緑
  static const Color neutral = Color(0xFF60A5FA); // 中立：青
  static const Color disagree = Color(0xFFFB7185); // 反対：赤

  // ========== カテゴリ色 ==========
  static const Color categorySocial = Color(0xFF3B82F6); // 社会：青
  static const Color categoryValue = Color(0xFFF97316); // 価値観：オレンジ
  static const Color categoryDaily = Color(0xFF22C55E); // 日常：緑

  // ========== 難易度色 ==========
  static const Color difficultyEasy = Color(0xFF14B8A6); // 簡単：ティール
  static const Color difficultyNormal = Color(0xFFF59E0B); // 普通：アンバー
  static const Color difficultyHard = Color(0xFFEF4444); // 難しい：赤

  // ========== ステータス色 ==========
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ========== その他 ==========
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1A000000);
  static const Color aiGenerated = Color(0xFF8B5CF6); // AI生成バッジ：紫

  // ========== ダークモード: その他 ==========
  static const Color darkDisabled = Color(0xFF5A5A5A);
  static const Color darkShadow = Color(0x4D000000);

  // ========== ライトモード: グラデーション ==========
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== ダークモード: グラデーション ==========
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [darkPrimary, darkPrimaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== チャート用カラー ==========
  static const Color chartLine = Color(0xFF6366F1);
  static const Color chartGrid = Color(0xFFEBEEF2);
  static const Color chartTooltip = Color(0xFF6366F1);

  // ========== バッジ背景色 ==========
  static const Color badgeEarned = Color(0xFFFFFBEB);
  static const Color badgeUnearned = Color(0xFFF3F4F6);
  static const Color badgeBorder = Color(0xFFFDE68A);
}

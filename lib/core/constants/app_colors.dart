import 'package:flutter/material.dart';

/// アプリ全体で使用するカラーパレット
/// ロゴの白黒をベースにしたデザイン
class AppColors {
  AppColors._();

  // ========== プライマリカラー（黒系）==========
  static const Color primary = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF333333);
  static const Color primaryDark = Color(0xFF000000);

  // ========== 背景色（白系）==========
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // ========== テキストカラー ==========
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ========== ボーダー・区切り線 ==========
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

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

  // ========== グラデーション ==========
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
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

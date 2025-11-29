import 'package:flutter/material.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';

/// チュートリアルアイテムモデル
class TutorialItem {
  /// タイトル
  final String title;

  /// 説明文
  final String description;

  /// アイコン
  final IconData icon;

  /// 画像パス（オプション）
  final String? imagePath;

  /// カラー（グラデーション用）
  final Color primaryColor;
  final Color secondaryColor;

  /// サブタイトル（オプション）
  final String? subtitle;

  /// 箇条書きリスト（オプション）
  final List<String>? bulletPoints;

  /// 画像を表示するかどうか（デフォルト: true）
  final bool showImage;

  const TutorialItem({
    required this.title,
    required this.description,
    required this.icon,
    this.imagePath,
    required this.primaryColor,
    required this.secondaryColor,
    this.subtitle,
    this.bulletPoints,
    this.showImage = true,
  });
}

/// チュートリアルコンテンツのモックデータ
class TutorialData {
  static const List<TutorialItem> items = [
    // エコチェンバー効果の説明
    TutorialItem(
      title: 'エコチェンバー\n現象',
      subtitle: '同じ意見ばかりに触れる危険性',
      description:
          'SNSやインターネットでは、\n自分と似た意見ばかりに触れてしまう\n「エコチェンバー効果」が\n起きやすくなっています。',
      bulletPoints: [
        '視野が狭くなり、偏った判断をしてしまう',
        '新しい発見や学びの機会が減る',
        '多様な価値観に触れることが難しくなる',
      ],
      icon: Icons.warning_amber_rounded,
      primaryColor: Color(0xFFEF4444),
      secondaryColor: Color(0xFFDC2626),
      showImage: false, // 画像を表示しない
    ),

    // アプリの目的
    TutorialItem(
      title: 'Criticaの目的',
      subtitle: '多角的な思考を育む',
      description: 'このアプリは、様々な立場の意見に触れることで\n多角的な思考力を育むことを目指しています。',
      bulletPoints: [
        '賛成・反対・中立の様々な意見を見る',
        '自分とは違う視点に触れて視野を広げる',
        'チャレンジ機能で反対の立場を考える',
      ],
      icon: Icons.lightbulb_outline,
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.primaryLight,
      showImage: false, // 画像を表示しない
    ),
    TutorialItem(
      title: '機能一覧',
      description: '使用できる機能を見てみましょう',
      icon: Icons.waving_hand,
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.primaryLight,
      showImage: false,
    ),
    TutorialItem(
      title: '意見を投稿',
      description: 'トピックに対して\nあなたの意見を投稿できます。',
      icon: Icons.create,
      imagePath: 'assets/images/onboarding/topic.png',
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFFF43F5E),
    ),
    TutorialItem(
      title: '他の人の意見を見る',
      description: '他の人の意見を\n見て、新しい発見をしましょう。',
      icon: Icons.people,
      imagePath: 'assets/images/onboarding/iken.png',
      primaryColor: Color(0xFF14B8A6),
      secondaryColor: Color(0xFF10B981),
    ),
    TutorialItem(
      title: 'チャレンジ機能',
      description: 'あなたが答えた立場の\n反対の立場で意見を投稿し\nAIが判定してくれます。',
      icon: Icons.waving_hand,
      imagePath: 'assets/images/onboarding/ibento.png',
      primaryColor: Color(0xFF6366F1),
      secondaryColor: Color(0xFF8B5CF6),
    ),
    TutorialItem(
      title: 'ディベートを始める',
      description: 'ディベートを始めて、\nあなたの意見を共有したり、\n他の人の意見を見ることができます。',
      icon: Icons.waving_hand,
      imagePath: 'assets/images/onboarding/ibento.png',
      primaryColor: Color(0xFF6366F1),
      secondaryColor: Color(0xFF8B5CF6),
    ),
    TutorialItem(
      title: '統計情報を見る',
      description: '統計情報を見て、\nあなたの意見の影響力を確認できます。',
      icon: Icons.person,
      imagePath: 'assets/images/onboarding/profile.png',
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFF97316),
    ),
    TutorialItem(
      title: '始めましょう！',
      description: 'それでは、アプリを\n楽しんでください！',
      icon: Icons.rocket_launch,
      imagePath: 'assets/images/onboarding/icon2.png',
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.primaryLight,
    ),
  ];
}

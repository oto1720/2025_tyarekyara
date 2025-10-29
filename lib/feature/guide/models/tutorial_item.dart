import 'package:flutter/material.dart';

/// チュートリアルアイテムモデル
class TutorialItem {
  /// タイトル
  final String title;

  /// 説明文
  final String description;

  /// アイコン
  final IconData icon;

  /// カラー（グラデーション用）
  final Color primaryColor;
  final Color secondaryColor;

  const TutorialItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

/// チュートリアルコンテンツのモックデータ
class TutorialData {
  static const List<TutorialItem> items = [
    TutorialItem(
      title: 'ようこそ！',
      description: 'このアプリでは、あなたの意見を共有したり、\n他の人の意見を見ることができます。',
      icon: Icons.waving_hand,
      primaryColor: Color(0xFF6366F1),
      secondaryColor: Color(0xFF8B5CF6),
    ),
    TutorialItem(
      title: '意見を投稿',
      description: '気になるトピックについて\nあなたの意見を自由に投稿できます。',
      icon: Icons.create,
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFFF43F5E),
    ),
    TutorialItem(
      title: '他の人の意見を見る',
      description: '同じ地域や年代の人の意見を\n見て、新しい発見をしましょう。',
      icon: Icons.people,
      primaryColor: Color(0xFF14B8A6),
      secondaryColor: Color(0xFF10B981),
    ),
    TutorialItem(
      title: 'プロフィール設定',
      description: 'プロフィール画面で\nいつでも情報を変更できます。',
      icon: Icons.person,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFF97316),
    ),
    TutorialItem(
      title: 'さあ、始めましょう！',
      description: 'それでは、アプリを\n楽しんでください！',
      icon: Icons.rocket_launch,
      primaryColor: Color(0xFF3B82F6),
      secondaryColor: Color(0xFF2563EB),
    ),
  ];
}

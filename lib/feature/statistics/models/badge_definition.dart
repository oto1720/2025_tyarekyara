import 'package:flutter/material.dart';

/// バッジの定義（マスターデータ）
class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// すべてのバッジ定義
class BadgeDefinitions {
  static const List<BadgeDefinition> all = [
    // 投稿数系
    BadgeDefinition(
      id: 'first_post',
      name: '初投稿',
      description: '初めて意見を投稿しました',
      icon: Icons.edit,
      color: Color(0xFF6366F1),
    ),
    BadgeDefinition(
      id: 'ten_posts',
      name: '10投稿達成',
      description: '10回意見を投稿しました',
      icon: Icons.star,
      color: Color(0xFFF59E0B),
    ),
    BadgeDefinition(
      id: 'fifty_posts',
      name: '50投稿達成',
      description: '50回意見を投稿しました',
      icon: Icons.stars,
      color: Color(0xFFEC4899),
    ),
    BadgeDefinition(
      id: 'hundred_posts',
      name: '100投稿達成',
      description: '100回意見を投稿しました',
      icon: Icons.workspace_premium,
      color: Color(0xFF8B5CF6),
    ),

    // 連続参加系
    BadgeDefinition(
      id: 'seven_days_streak',
      name: '7日連続参加',
      description: '7日連続で参加しました',
      icon: Icons.local_fire_department,
      color: Color(0xFFEF4444),
    ),
    BadgeDefinition(
      id: 'thirty_days_streak',
      name: '30日連続参加',
      description: '30日連続で参加しました',
      icon: Icons.local_fire_department,
      color: Color(0xFFDC2626),
    ),

    // 参加日数系
    BadgeDefinition(
      id: 'thirty_days_total',
      name: '30日間参加',
      description: '累計30日間参加しました',
      icon: Icons.calendar_month,
      color: Color(0xFF10B981),
    ),
    BadgeDefinition(
      id: 'hundred_days_total',
      name: '100日間参加',
      description: '累計100日間参加しました',
      icon: Icons.event_available,
      color: Color(0xFF059669),
    ),

    // 多様性系
    BadgeDefinition(
      id: 'diverse_thinker',
      name: '多様な思考',
      description: '多様性スコアが80以上になりました',
      icon: Icons.psychology,
      color: Color(0xFF06B6D4),
    ),
    BadgeDefinition(
      id: 'balanced_opinions',
      name: 'バランス型',
      description: '賛成・中立・反対すべてに投稿しました',
      icon: Icons.balance,
      color: Color(0xFF14B8A6),
    ),

    // 視点交換チャレンジ系
    BadgeDefinition(
      id: 'first_challenge',
      name: '視点交換入門',
      description: '初めてチャレンジをクリアしました',
      icon: Icons.swap_horiz,
      color: Color(0xFF3B82F6),
    ),
    BadgeDefinition(
      id: 'challenge_enthusiast',
      name: 'チャレンジ好き',
      description: '5回チャレンジをクリアしました',
      icon: Icons.trending_up,
      color: Color(0xFF8B5CF6),
    ),
    BadgeDefinition(
      id: 'challenge_expert',
      name: 'チャレンジ達人',
      description: '10回チャレンジをクリアしました',
      icon: Icons.emoji_events,
      color: Color(0xFFF59E0B),
    ),
    BadgeDefinition(
      id: 'challenge_master',
      name: 'チャレンジマスター',
      description: '累計獲得ポイント500P達成',
      icon: Icons.military_tech,
      color: Color(0xFFDC2626),
    ),
  ];

  /// IDからバッジ定義を取得
  static BadgeDefinition? getById(String id) {
    try {
      return all.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }
}

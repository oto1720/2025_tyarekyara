import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_debate_stats.freezed.dart';
part 'user_debate_stats.g.dart';

/// バッジタイプ
enum BadgeType {
  firstDebate,      // 初参加
  tenDebates,       // 10回参加
  firstWin,         // 初勝利
  tenWins,          // 10勝達成
  winStreak,        // 連勝記録
  perfectScore,     // 完璧な論理
  mvp,              // MVP獲得
  participation,    // 皆勤賞
}

/// 称号（後方互換性のため残す）
enum DebateBadge {
  rookie,           // 新人ディベーター
  debater,          // 論客（10回勝利）
  calmDebater,      // 冷静沈着（マナー賞5回）
  mvpCollector,     // MVP常連（MVP 3回）
  winStreak,        // 連勝記録保持者（5連勝以上）
  veteran,          // ベテラン（50回参加）
  master,           // マスター（100回勝利）
  legend,           // レジェンド（500回参加）
}

extension DebateBadgeExtension on DebateBadge {
  String get displayName {
    switch (this) {
      case DebateBadge.rookie:
        return '新人ディベーター';
      case DebateBadge.debater:
        return '論客';
      case DebateBadge.calmDebater:
        return '冷静沈着';
      case DebateBadge.mvpCollector:
        return 'MVP常連';
      case DebateBadge.winStreak:
        return '連勝記録保持者';
      case DebateBadge.veteran:
        return 'ベテラン';
      case DebateBadge.master:
        return 'マスター';
      case DebateBadge.legend:
        return 'レジェンド';
    }
  }

  String get description {
    switch (this) {
      case DebateBadge.rookie:
        return '初めてディベートに参加';
      case DebateBadge.debater:
        return '10回勝利を達成';
      case DebateBadge.calmDebater:
        return 'マナー賞を5回獲得';
      case DebateBadge.mvpCollector:
        return 'MVPを3回獲得';
      case DebateBadge.winStreak:
        return '5連勝以上を記録';
      case DebateBadge.veteran:
        return '50回参加を達成';
      case DebateBadge.master:
        return '100回勝利を達成';
      case DebateBadge.legend:
        return '500回参加を達成';
    }
  }

  String get iconEmoji {
    switch (this) {
      case DebateBadge.rookie:
        return '🌱';
      case DebateBadge.debater:
        return '💬';
      case DebateBadge.calmDebater:
        return '😌';
      case DebateBadge.mvpCollector:
        return '🏆';
      case DebateBadge.winStreak:
        return '🔥';
      case DebateBadge.veteran:
        return '⭐';
      case DebateBadge.master:
        return '👑';
      case DebateBadge.legend:
        return '🌟';
    }
  }
}

/// 獲得バッジ
@freezed
class EarnedBadge with _$EarnedBadge {
  const factory EarnedBadge({
    required BadgeType type,
    required DateTime earnedAt,
  }) = _EarnedBadge;

  factory EarnedBadge.fromJson(Map<String, dynamic> json) =>
      _$EarnedBadgeFromJson(json);
}

/// ユーザーディベート統計
@freezed
class UserDebateStats with _$UserDebateStats {
  const factory UserDebateStats({
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    // 基本統計
    @Default(0) int totalDebates,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int draws,
    @Default(0.0) double winRate,
    // ポイント・経験値
    @Default(0) int totalPoints,
    @Default(0) int currentMonthPoints,
    @Default(0) int experiencePoints,
    @Default(1) int level,
    @Default(0) int currentLevelPoints,
    @Default(100) int pointsToNextLevel,
    // MVP・特別賞
    @Default(0) int mvpCount,
    @Default(0) int mannerAwardCount,
    // 連勝記録
    @Default(0) int currentWinStreak,
    @Default(0) int maxWinStreak,
    // 立場別統計
    @Default(0) int proWins,
    @Default(0) int conWins,
    // 獲得バッジ
    @Default([]) List<DebateBadge> badges,
    @Default([]) List<EarnedBadge> earnedBadges,
    DateTime? lastDebateAt,
    DateTime? lastMonthlyReset,
    // 平均スコア
    @Default(0.0) double avgLogicScore,
    @Default(0.0) double avgEvidenceScore,
    @Default(0.0) double avgRebuttalScore,
    @Default(0.0) double avgPersuasivenessScore,
    @Default(0.0) double avgMannerScore,
    Map<String, dynamic>? metadata,
  }) = _UserDebateStats;

  factory UserDebateStats.fromJson(Map<String, dynamic> json) {
    return UserDebateStats(
      userId: json['userId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      totalDebates: json['totalDebates'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      currentMonthPoints: json['currentMonthPoints'] as int? ?? 0,
      experiencePoints: json['experiencePoints'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentLevelPoints: json['currentLevelPoints'] as int? ?? 0,
      pointsToNextLevel: json['pointsToNextLevel'] as int? ?? 100,
      mvpCount: json['mvpCount'] as int? ?? 0,
      mannerAwardCount: json['mannerAwardCount'] as int? ?? 0,
      currentWinStreak: json['currentWinStreak'] as int? ?? 0,
      maxWinStreak: json['maxWinStreak'] as int? ?? 0,
      proWins: json['proWins'] as int? ?? 0,
      conWins: json['conWins'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => DebateBadge.values.firstWhere(
                    (b) => b.name == e,
                    orElse: () => DebateBadge.rookie,
                  ))
              .toList() ??
          [],
      earnedBadges: (json['earnedBadges'] as List<dynamic>?)
              ?.map((e) => EarnedBadge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastDebateAt: json['lastDebateAt'] != null
          ? (json['lastDebateAt'] as Timestamp).toDate()
          : null,
      lastMonthlyReset: json['lastMonthlyReset'] != null
          ? (json['lastMonthlyReset'] as Timestamp).toDate()
          : null,
      avgLogicScore: (json['avgLogicScore'] as num?)?.toDouble() ?? 0.0,
      avgEvidenceScore: (json['avgEvidenceScore'] as num?)?.toDouble() ?? 0.0,
      avgRebuttalScore: (json['avgRebuttalScore'] as num?)?.toDouble() ?? 0.0,
      avgPersuasivenessScore:
          (json['avgPersuasivenessScore'] as num?)?.toDouble() ?? 0.0,
      avgMannerScore: (json['avgMannerScore'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static Map<String, dynamic> toFirestore(UserDebateStats stats) {
    return {
      'userId': stats.userId,
      'createdAt': Timestamp.fromDate(stats.createdAt),
      'updatedAt': Timestamp.fromDate(stats.updatedAt),
      'totalDebates': stats.totalDebates,
      'wins': stats.wins,
      'losses': stats.losses,
      'draws': stats.draws,
      'winRate': stats.winRate,
      'totalPoints': stats.totalPoints,
      'currentMonthPoints': stats.currentMonthPoints,
      'experiencePoints': stats.experiencePoints,
      'level': stats.level,
      'currentLevelPoints': stats.currentLevelPoints,
      'pointsToNextLevel': stats.pointsToNextLevel,
      'mvpCount': stats.mvpCount,
      'mannerAwardCount': stats.mannerAwardCount,
      'currentWinStreak': stats.currentWinStreak,
      'maxWinStreak': stats.maxWinStreak,
      'proWins': stats.proWins,
      'conWins': stats.conWins,
      'badges': stats.badges.map((b) => b.name).toList(),
      'earnedBadges': stats.earnedBadges.map((b) => {
        'type': b.type.name,
        'earnedAt': Timestamp.fromDate(b.earnedAt),
      }).toList(),
      'lastDebateAt': stats.lastDebateAt != null
          ? Timestamp.fromDate(stats.lastDebateAt!)
          : null,
      'lastMonthlyReset': stats.lastMonthlyReset != null
          ? Timestamp.fromDate(stats.lastMonthlyReset!)
          : null,
      'avgLogicScore': stats.avgLogicScore,
      'avgEvidenceScore': stats.avgEvidenceScore,
      'avgRebuttalScore': stats.avgRebuttalScore,
      'avgPersuasivenessScore': stats.avgPersuasivenessScore,
      'avgMannerScore': stats.avgMannerScore,
      'metadata': stats.metadata,
    };
  }
}

/// ランキングエントリー
@freezed
class RankingEntry with _$RankingEntry {
  const factory RankingEntry({
    required String userId,
    String? userName,
    String? userNickname,
    @Default(0) int rank,
    @Default(0) int value,
    @Default(0) int totalPoints,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int totalDebates,
    @Default(1) int level,
    String? userIconUrl,
    DateTime? updatedAt,
  }) = _RankingEntry;

  factory RankingEntry.fromJson(Map<String, dynamic> json) =>
      _$RankingEntryFromJson(json);
}

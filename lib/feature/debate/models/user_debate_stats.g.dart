// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_debate_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EarnedBadgeImpl _$$EarnedBadgeImplFromJson(Map<String, dynamic> json) =>
    _$EarnedBadgeImpl(
      type: $enumDecode(_$BadgeTypeEnumMap, json['type']),
      earnedAt: DateTime.parse(json['earnedAt'] as String),
    );

Map<String, dynamic> _$$EarnedBadgeImplToJson(_$EarnedBadgeImpl instance) =>
    <String, dynamic>{
      'type': _$BadgeTypeEnumMap[instance.type]!,
      'earnedAt': instance.earnedAt.toIso8601String(),
    };

const _$BadgeTypeEnumMap = {
  BadgeType.firstDebate: 'firstDebate',
  BadgeType.tenDebates: 'tenDebates',
  BadgeType.firstWin: 'firstWin',
  BadgeType.tenWins: 'tenWins',
  BadgeType.winStreak: 'winStreak',
  BadgeType.perfectScore: 'perfectScore',
  BadgeType.mvp: 'mvp',
  BadgeType.participation: 'participation',
};

_$RankingEntryImpl _$$RankingEntryImplFromJson(Map<String, dynamic> json) =>
    _$RankingEntryImpl(
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userNickname: json['userNickname'] as String?,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      totalDebates: (json['totalDebates'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      userIconUrl: json['userIconUrl'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RankingEntryImplToJson(_$RankingEntryImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'userNickname': instance.userNickname,
      'rank': instance.rank,
      'value': instance.value,
      'totalPoints': instance.totalPoints,
      'wins': instance.wins,
      'losses': instance.losses,
      'totalDebates': instance.totalDebates,
      'level': instance.level,
      'userIconUrl': instance.userIconUrl,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

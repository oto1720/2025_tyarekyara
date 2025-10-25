// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatsModelImpl _$$UserStatsModelImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsModelImpl(
      userId: json['userId'] as String,
      totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
      ranking: (json['ranking'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserStatsModelImplToJson(
  _$UserStatsModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'totalMatches': instance.totalMatches,
  'wins': instance.wins,
  'losses': instance.losses,
  'draws': instance.draws,
  'winRate': instance.winRate,
  'ranking': instance.ranking,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

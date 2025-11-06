// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatisticsImpl _$$UserStatisticsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatisticsImpl(
      userId: json['userId'] as String,
      participationDays: (json['participationDays'] as num).toInt(),
      totalOpinions: (json['totalOpinions'] as num).toInt(),
      consecutiveDays: (json['consecutiveDays'] as num).toInt(),
      lastParticipation: DateTime.parse(json['lastParticipation'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserStatisticsImplToJson(
  _$UserStatisticsImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'participationDays': instance.participationDays,
  'totalOpinions': instance.totalOpinions,
  'consecutiveDays': instance.consecutiveDays,
  'lastParticipation': instance.lastParticipation.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

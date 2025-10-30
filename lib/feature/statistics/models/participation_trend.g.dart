// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participation_trend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParticipationPointImpl _$$ParticipationPointImplFromJson(
  Map<String, dynamic> json,
) => _$ParticipationPointImpl(
  date: DateTime.parse(json['date'] as String),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$$ParticipationPointImplToJson(
  _$ParticipationPointImpl instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'count': instance.count,
};

_$ParticipationTrendImpl _$$ParticipationTrendImplFromJson(
  Map<String, dynamic> json,
) => _$ParticipationTrendImpl(
  userId: json['userId'] as String,
  points: (json['points'] as List<dynamic>)
      .map((e) => ParticipationPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ParticipationTrendImplToJson(
  _$ParticipationTrendImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'points': instance.points,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

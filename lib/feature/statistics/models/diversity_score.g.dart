// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diversity_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiversityScoreImpl _$$DiversityScoreImplFromJson(Map<String, dynamic> json) =>
    _$DiversityScoreImpl(
      userId: json['userId'] as String,
      score: (json['score'] as num).toDouble(),
      breakdown: (json['breakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DiversityScoreImplToJson(
  _$DiversityScoreImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'score': instance.score,
  'breakdown': instance.breakdown,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

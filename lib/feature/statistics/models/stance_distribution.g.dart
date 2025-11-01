// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stance_distribution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StanceDistributionImpl _$$StanceDistributionImplFromJson(
  Map<String, dynamic> json,
) => _$StanceDistributionImpl(
  userId: json['userId'] as String,
  counts: Map<String, int>.from(json['counts'] as Map),
  total: (json['total'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$StanceDistributionImplToJson(
  _$StanceDistributionImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'counts': instance.counts,
  'total': instance.total,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

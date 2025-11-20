// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earned_badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EarnedBadgeImpl _$$EarnedBadgeImplFromJson(Map<String, dynamic> json) =>
    _$EarnedBadgeImpl(
      badgeId: json['badgeId'] as String,
      earnedAt: const TimestampConverter().fromJson(json['earnedAt']),
      awardedBy: json['awardedBy'] as String?,
    );

Map<String, dynamic> _$$EarnedBadgeImplToJson(_$EarnedBadgeImpl instance) =>
    <String, dynamic>{
      'badgeId': instance.badgeId,
      'earnedAt': const TimestampConverter().toJson(instance.earnedAt),
      'awardedBy': instance.awardedBy,
    };

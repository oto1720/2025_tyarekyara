// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportImpl _$$ReportImplFromJson(Map<String, dynamic> json) => _$ReportImpl(
  id: json['id'] as String,
  reporterId: json['reporterId'] as String,
  reportedUserId: json['reportedUserId'] as String,
  type: $enumDecode(_$ReportTypeEnumMap, json['type']),
  contentId: json['contentId'] as String,
  reason: $enumDecode(_$ReportReasonEnumMap, json['reason']),
  details: json['details'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isResolved: json['isResolved'] as bool? ?? false,
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  resolvedBy: json['resolvedBy'] as String?,
);

Map<String, dynamic> _$$ReportImplToJson(_$ReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporterId': instance.reporterId,
      'reportedUserId': instance.reportedUserId,
      'type': _$ReportTypeEnumMap[instance.type]!,
      'contentId': instance.contentId,
      'reason': _$ReportReasonEnumMap[instance.reason]!,
      'details': instance.details,
      'createdAt': instance.createdAt.toIso8601String(),
      'isResolved': instance.isResolved,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
    };

const _$ReportTypeEnumMap = {
  ReportType.opinion: 'opinion',
  ReportType.debateMessage: 'debateMessage',
};

const _$ReportReasonEnumMap = {
  ReportReason.spam: 'spam',
  ReportReason.inappropriate: 'inappropriate',
  ReportReason.harassment: 'harassment',
  ReportReason.hateSpeech: 'hateSpeech',
  ReportReason.violence: 'violence',
  ReportReason.other: 'other',
};

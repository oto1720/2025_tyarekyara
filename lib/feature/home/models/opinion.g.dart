// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opinion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OpinionImpl _$$OpinionImplFromJson(Map<String, dynamic> json) =>
    _$OpinionImpl(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      topicText: json['topicText'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      stance: $enumDecode(_$OpinionStanceEnumMap, json['stance']),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
      reactionCounts:
          (json['reactionCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {'empathy': 0, 'thoughtful': 0, 'newPerspective': 0},
      reactedUsers:
          (json['reactedUsers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          const {'empathy': [], 'thoughtful': [], 'newPerspective': []},
    );

Map<String, dynamic> _$$OpinionImplToJson(_$OpinionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topicId': instance.topicId,
      'topicText': instance.topicText,
      'userId': instance.userId,
      'userName': instance.userName,
      'stance': _$OpinionStanceEnumMap[instance.stance]!,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'likeCount': instance.likeCount,
      'isDeleted': instance.isDeleted,
      'reactionCounts': instance.reactionCounts,
      'reactedUsers': instance.reactedUsers,
    };

const _$OpinionStanceEnumMap = {
  OpinionStance.agree: 'agree',
  OpinionStance.disagree: 'disagree',
  OpinionStance.neutral: 'neutral',
};

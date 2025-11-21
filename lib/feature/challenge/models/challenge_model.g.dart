// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeImpl _$$ChallengeImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      stance: $enumDecode(_$StanceEnumMap, json['stance']),
      originalStance: $enumDecodeNullable(
        _$StanceEnumMap,
        json['originalStance'],
      ),
      difficulty: $enumDecode(_$ChallengeDifficultyEnumMap, json['difficulty']),
      status:
          $enumDecodeNullable(_$ChallengeStatusEnumMap, json['status']) ??
          ChallengeStatus.available,
      originalOpinionText: json['originalOpinionText'] as String,
      oppositeOpinionText: json['oppositeOpinionText'] as String?,
      userId: json['userId'] as String,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      earnedPoints: (json['earnedPoints'] as num?)?.toInt(),
      opinionId: json['opinionId'] as String?,
      feedbackText: json['feedbackText'] as String?,
      feedbackScore: (json['feedbackScore'] as num?)?.toInt(),
      feedbackGeneratedAt: json['feedbackGeneratedAt'] == null
          ? null
          : DateTime.parse(json['feedbackGeneratedAt'] as String),
    );

Map<String, dynamic> _$$ChallengeImplToJson(_$ChallengeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'stance': _$StanceEnumMap[instance.stance]!,
      'originalStance': _$StanceEnumMap[instance.originalStance],
      'difficulty': _$ChallengeDifficultyEnumMap[instance.difficulty]!,
      'status': _$ChallengeStatusEnumMap[instance.status]!,
      'originalOpinionText': instance.originalOpinionText,
      'oppositeOpinionText': instance.oppositeOpinionText,
      'userId': instance.userId,
      'completedAt': instance.completedAt?.toIso8601String(),
      'earnedPoints': instance.earnedPoints,
      'opinionId': instance.opinionId,
      'feedbackText': instance.feedbackText,
      'feedbackScore': instance.feedbackScore,
      'feedbackGeneratedAt': instance.feedbackGeneratedAt?.toIso8601String(),
    };

const _$StanceEnumMap = {Stance.pro: 'pro', Stance.con: 'con'};

const _$ChallengeDifficultyEnumMap = {
  ChallengeDifficulty.easy: 'easy',
  ChallengeDifficulty.normal: 'normal',
  ChallengeDifficulty.hard: 'hard',
};

const _$ChallengeStatusEnumMap = {
  ChallengeStatus.available: 'available',
  ChallengeStatus.completed: 'completed',
};

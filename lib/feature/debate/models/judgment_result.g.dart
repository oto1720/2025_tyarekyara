// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'judgment_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamScoreImpl _$$TeamScoreImplFromJson(Map<String, dynamic> json) =>
    _$TeamScoreImpl(
      stance: $enumDecode(_$DebateStanceEnumMap, json['stance']),
      logic: (json['logic'] as num?)?.toInt() ?? 0,
      evidence: (json['evidence'] as num?)?.toInt() ?? 0,
      rebuttal: (json['rebuttal'] as num?)?.toInt() ?? 0,
      persuasiveness: (json['persuasiveness'] as num?)?.toInt() ?? 0,
      manner: (json['manner'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      logicScore: (json['logicScore'] as num?)?.toInt() ?? 0,
      evidenceScore: (json['evidenceScore'] as num?)?.toInt() ?? 0,
      rebuttalScore: (json['rebuttalScore'] as num?)?.toInt() ?? 0,
      persuasivenessScore: (json['persuasivenessScore'] as num?)?.toInt() ?? 0,
      mannerScore: (json['mannerScore'] as num?)?.toInt() ?? 0,
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      feedback: json['feedback'] as String?,
    );

Map<String, dynamic> _$$TeamScoreImplToJson(_$TeamScoreImpl instance) =>
    <String, dynamic>{
      'stance': _$DebateStanceEnumMap[instance.stance]!,
      'logic': instance.logic,
      'evidence': instance.evidence,
      'rebuttal': instance.rebuttal,
      'persuasiveness': instance.persuasiveness,
      'manner': instance.manner,
      'total': instance.total,
      'logicScore': instance.logicScore,
      'evidenceScore': instance.evidenceScore,
      'rebuttalScore': instance.rebuttalScore,
      'persuasivenessScore': instance.persuasivenessScore,
      'mannerScore': instance.mannerScore,
      'totalScore': instance.totalScore,
      'feedback': instance.feedback,
    };

const _$DebateStanceEnumMap = {
  DebateStance.pro: 'pro',
  DebateStance.con: 'con',
  DebateStance.any: 'any',
};

_$IndividualEvaluationImpl _$$IndividualEvaluationImplFromJson(
  Map<String, dynamic> json,
) => _$IndividualEvaluationImpl(
  userId: json['userId'] as String,
  userNickname: json['userNickname'] as String,
  stance: $enumDecode(_$DebateStanceEnumMap, json['stance']),
  contributionScore: (json['contributionScore'] as num?)?.toInt() ?? 0,
  strengths:
      (json['strengths'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  improvements:
      (json['improvements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isMvp: json['isMvp'] as bool? ?? false,
);

Map<String, dynamic> _$$IndividualEvaluationImplToJson(
  _$IndividualEvaluationImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userNickname': instance.userNickname,
  'stance': _$DebateStanceEnumMap[instance.stance]!,
  'contributionScore': instance.contributionScore,
  'strengths': instance.strengths,
  'improvements': instance.improvements,
  'isMvp': instance.isMvp,
};

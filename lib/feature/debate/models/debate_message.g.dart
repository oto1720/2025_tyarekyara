// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debate_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageLimitsImpl _$$MessageLimitsImplFromJson(Map<String, dynamic> json) =>
    _$MessageLimitsImpl(
      maxCharacters: (json['maxCharacters'] as num?)?.toInt() ?? 200,
      maxMessagesPerPhase:
          (json['maxMessagesPerPhase'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$DebatePhaseEnumMap, k),
              (e as num).toInt(),
            ),
          ) ??
          const {},
      maxWarnings: (json['maxWarnings'] as num?)?.toInt() ?? 3,
      cooldownSeconds: (json['cooldownSeconds'] as num?)?.toInt() ?? 30,
    );

Map<String, dynamic> _$$MessageLimitsImplToJson(_$MessageLimitsImpl instance) =>
    <String, dynamic>{
      'maxCharacters': instance.maxCharacters,
      'maxMessagesPerPhase': instance.maxMessagesPerPhase.map(
        (k, e) => MapEntry(_$DebatePhaseEnumMap[k]!, e),
      ),
      'maxWarnings': instance.maxWarnings,
      'cooldownSeconds': instance.cooldownSeconds,
    };

const _$DebatePhaseEnumMap = {
  DebatePhase.preparation: 'preparation',
  DebatePhase.openingPro: 'openingPro',
  DebatePhase.openingCon: 'openingCon',
  DebatePhase.questionPro: 'questionPro',
  DebatePhase.questionCon: 'questionCon',
  DebatePhase.rebuttalPro: 'rebuttalPro',
  DebatePhase.rebuttalCon: 'rebuttalCon',
  DebatePhase.closingPro: 'closingPro',
  DebatePhase.closingCon: 'closingCon',
  DebatePhase.judgment: 'judgment',
  DebatePhase.result: 'result',
  DebatePhase.completed: 'completed',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debate_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DebateTeamImpl _$$DebateTeamImplFromJson(Map<String, dynamic> json) =>
    _$DebateTeamImpl(
      stance: $enumDecode(_$DebateStanceEnumMap, json['stance']),
      memberIds: (json['memberIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      mvpUserId: json['mvpUserId'] as String?,
    );

Map<String, dynamic> _$$DebateTeamImplToJson(_$DebateTeamImpl instance) =>
    <String, dynamic>{
      'stance': _$DebateStanceEnumMap[instance.stance]!,
      'memberIds': instance.memberIds,
      'score': instance.score,
      'mvpUserId': instance.mvpUserId,
    };

const _$DebateStanceEnumMap = {
  DebateStance.pro: 'pro',
  DebateStance.con: 'con',
  DebateStance.any: 'any',
};

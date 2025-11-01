// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicImpl _$$TopicImplFromJson(Map<String, dynamic> json) => _$TopicImpl(
  id: json['id'] as String,
  text: json['text'] as String,
  category: $enumDecode(_$TopicCategoryEnumMap, json['category']),
  difficulty: $enumDecode(_$TopicDifficultyEnumMap, json['difficulty']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  source:
      $enumDecodeNullable(_$TopicSourceEnumMap, json['source']) ??
      TopicSource.ai,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  description: json['description'] as String?,
  similarityScore: (json['similarityScore'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$TopicImplToJson(_$TopicImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'category': _$TopicCategoryEnumMap[instance.category]!,
      'difficulty': _$TopicDifficultyEnumMap[instance.difficulty]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'source': _$TopicSourceEnumMap[instance.source]!,
      'tags': instance.tags,
      'description': instance.description,
      'similarityScore': instance.similarityScore,
    };

const _$TopicCategoryEnumMap = {
  TopicCategory.daily: 'daily',
  TopicCategory.social: 'social',
  TopicCategory.value: 'value',
};

const _$TopicDifficultyEnumMap = {
  TopicDifficulty.easy: 'easy',
  TopicDifficulty.medium: 'medium',
  TopicDifficulty.hard: 'hard',
};

const _$TopicSourceEnumMap = {
  TopicSource.ai: 'ai',
  TopicSource.manual: 'manual',
};

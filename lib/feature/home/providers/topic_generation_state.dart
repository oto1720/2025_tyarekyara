import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/topic.dart';

part 'topic_generation_state.freezed.dart';

/// トピック生成の状態
@freezed
class TopicGenerationState with _$TopicGenerationState {
  const factory TopicGenerationState({
    @Default(false) bool isGenerating,
    @Default([]) List<Topic> generatedTopics,
    @Default([]) List<Topic> allTopics, // 過去に生成された全トピック
    String? error,
    Topic? currentTopic, // 現在表示中のトピック
  }) = _TopicGenerationState;
}

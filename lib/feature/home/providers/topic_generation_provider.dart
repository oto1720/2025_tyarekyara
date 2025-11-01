import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic.dart';
import '../repositories/ai_repository.dart';
import '../services/topic_generation_service.dart';
import '../services/topic_classifier_service.dart';
import '../services/topic_duplicate_detector.dart';
import '../services/topic_difficulty_adjuster.dart';
import 'topic_generation_state.dart';

/// AI プロバイダーの選択
class AIProviderNotifier extends Notifier<AIProvider> {
  @override
  AIProvider build() => AIProvider.openai;

  void update(AIProvider provider) {
    state = provider;
  }
}

final aiProviderProvider = NotifierProvider<AIProviderNotifier, AIProvider>(
  AIProviderNotifier.new,
);

/// AI リポジトリプロバイダー
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final provider = ref.watch(aiProviderProvider);
  return AIRepositoryFactory.create(provider);
});

/// トピック生成サービスプロバイダー
final topicGenerationServiceProvider = Provider<TopicGenerationService>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return TopicGenerationService(repository);
});

/// トピック分類サービスプロバイダー
final topicClassifierServiceProvider = Provider<TopicClassifierService>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return TopicClassifierService(repository);
});

/// 重複検出サービスプロバイダー
final topicDuplicateDetectorProvider = Provider<TopicDuplicateDetector>((ref) {
  return TopicDuplicateDetector();
});

/// 難易度調整サービスプロバイダー
final topicDifficultyAdjusterProvider =
    Provider<TopicDifficultyAdjuster>((ref) {
  return TopicDifficultyAdjuster();
});

/// ユーザーレベルプロバイダー（将来的にはユーザー設定から取得）
class UserLevelNotifier extends Notifier<UserLevel> {
  @override
  UserLevel build() => UserLevel.intermediate;
}

final userLevelProvider = NotifierProvider<UserLevelNotifier, UserLevel>(
  UserLevelNotifier.new,
);

/// トピック生成Notifier
class TopicGenerationNotifier extends Notifier<TopicGenerationState> {
  @override
  TopicGenerationState build() => const TopicGenerationState();

  /// トピックを生成（完全自動）
  Future<void> generateTopic({
    TopicCategory? category,
    TopicDifficulty? difficulty,
  }) async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      // ユーザーレベルに基づいて難易度を決定（指定がない場合）
      final userLevel = ref.read(userLevelProvider);
      final targetDifficulty = difficulty ??
          ref.read(topicDifficultyAdjusterProvider).selectDifficulty(userLevel);

      // トピックテキストを生成
      final generationService = ref.read(topicGenerationServiceProvider);
      final topicText = await generationService.generateTopic(
        category: category,
        difficulty: targetDifficulty,
      );

      // 重複チェック
      final duplicateDetector = ref.read(topicDuplicateDetectorProvider);
      final similarity =
          duplicateDetector.findMaxSimilarity(topicText, state.allTopics);

      // 分類（カテゴリが指定されていない場合）
      TopicCategory finalCategory = category ?? TopicCategory.daily;
      TopicDifficulty finalDifficulty = targetDifficulty;
      List<String> tags = [];

      if (category == null) {
        try {
          final classifier = ref.read(topicClassifierServiceProvider);
          final classification = await classifier.classifyTopic(topicText);
          finalCategory = classification.category;
          finalDifficulty = classification.difficulty;
          tags = classification.tags;
        } catch (e) {
          // 分類に失敗した場合はルールベースで分類
          final classifier = ref.read(topicClassifierServiceProvider);
          final classification = classifier.classifyTopicByRules(topicText);
          finalCategory = classification.category;
          finalDifficulty = classification.difficulty;
          tags = classification.tags;
        }
      }

      // Topicオブジェクトを作成
      final topic = Topic(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: topicText,
        category: finalCategory,
        difficulty: finalDifficulty,
        createdAt: DateTime.now(),
        source: TopicSource.ai,
        tags: tags,
        similarityScore: similarity,
      );

      // 状態を更新
      state = state.copyWith(
        isGenerating: false,
        currentTopic: topic,
        generatedTopics: [...state.generatedTopics, topic],
        allTopics: [...state.allTopics, topic],
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
    }
  }

  /// 複数のトピックを一括生成
  Future<void> generateMultipleTopics({
    required int count,
    TopicCategory? category,
    TopicDifficulty? difficulty,
  }) async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      final generatedTopics = <Topic>[];

      for (int i = 0; i < count; i++) {
        await generateTopic(category: category, difficulty: difficulty);
        if (state.currentTopic != null) {
          generatedTopics.add(state.currentTopic!);
        }

        // レート制限を考慮して少し待つ
        if (i < count - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      state = state.copyWith(isGenerating: false);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
    }
  }

  /// カテゴリ別にトピックを生成
  Future<void> generateByCategories({
    required int countPerCategory,
    TopicDifficulty? difficulty,
  }) async {
    for (final category in TopicCategory.values) {
      await generateMultipleTopics(
        count: countPerCategory,
        category: category,
        difficulty: difficulty,
      );
    }
  }

  /// 生成されたトピックをクリア
  void clearGeneratedTopics() {
    state = state.copyWith(generatedTopics: []);
  }

  /// エラーをクリア
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 現在のトピックを設定
  void setCurrentTopic(Topic? topic) {
    state = state.copyWith(currentTopic: topic);
  }
}

/// トピック生成状態プロバイダー
final topicGenerationProvider =
    NotifierProvider<TopicGenerationNotifier, TopicGenerationState>(
  TopicGenerationNotifier.new,
);

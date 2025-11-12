import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/topic.dart';
import '../repositories/daily_topic_repository.dart';
import '../repositories/ai_repository.dart';
import '../services/topic_generation_service.dart';
import '../services/news_service.dart';
import '../utils/random_topic_selector.dart';

part 'daily_topic_provider.freezed.dart';

/// 日別トピックの状態
@freezed
class DailyTopicState with _$DailyTopicState {
  const factory DailyTopicState({
    Topic? currentTopic,
    @Default(false) bool isLoading,
    @Default(false) bool isGenerating,
    String? error,
  }) = _DailyTopicState;
}

/// 日別トピックリポジトリプロバイダー
final dailyTopicRepositoryProvider = Provider<DailyTopicRepository>((ref) {
  return DailyTopicRepository();
});

/// ランダムセレクタープロバイダー
final randomTopicSelectorProvider = Provider<RandomTopicSelector>((ref) {
  return RandomTopicSelector();
});

/// Geminiリポジトリプロバイダー（ニュース取得用）
final geminiRepositoryProviderForDaily = Provider<GeminiRepository>((ref) {
  return GeminiRepository();
});

/// ニュースサービスプロバイダー
final newsServiceProviderForDaily = Provider<NewsService>((ref) {
  final geminiRepository = ref.watch(geminiRepositoryProviderForDaily);
  return NewsService(geminiRepository);
});

/// 日別トピック管理ノーティファイア
class DailyTopicNotifier extends Notifier<DailyTopicState> {
  @override
  DailyTopicState build() {
    // 初期化時に今日のトピックを読み込む
    Future.microtask(() => loadTodayTopic());
    return const DailyTopicState();
  }

  DailyTopicRepository get repository => ref.read(dailyTopicRepositoryProvider);
  TopicGenerationService get topicService {
    final aiRepository = AIRepositoryFactory.create(AIProvider.openai);
    return TopicGenerationService(aiRepository);
  }

  RandomTopicSelector get randomSelector =>
      ref.read(randomTopicSelectorProvider);

  /// 今日のトピックを読み込む（存在しない場合は生成）
  Future<void> loadTodayTopic() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Firestoreから今日のトピックを取得
      final existingTopic = await repository.getTodayTopic();

      if (existingTopic != null) {
        // 既存のトピックがある場合はそれを使用
        state = state.copyWith(
          currentTopic: existingTopic,
          isLoading: false,
        );
      } else {
        // 存在しない場合は新規生成
        await generateNewTopic();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'トピックの読み込みに失敗しました: $e',
      );
    }
  }

  /// 新しいトピックを生成してFirestoreに保存
  Future<void> generateNewTopic() async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      // カテゴリーと難易度をランダムに選択
      final selection = randomSelector.selectRandom();

      // AIでトピックテキストを生成
      final topicText = await topicService.generateTopic(
        category: selection.category,
        difficulty: selection.difficulty,
      );

      // 関連ニュースを取得
      final newsService = ref.read(newsServiceProviderForDaily);
      final relatedNews = await newsService.getNewsByCategory(
        topicText.trim(),
        selection.category.displayName,
        count: 3,
      );

      // Topicオブジェクトを作成
      final newTopic = Topic(
        id: const Uuid().v4(),
        text: topicText.trim(),
        category: selection.category,
        difficulty: selection.difficulty,
        createdAt: DateTime.now(),
        source: TopicSource.ai,
        tags: _generateTags(selection.category),
        relatedNews: relatedNews,
      );

      // Firestoreに保存
      await repository.saveTodayTopic(newTopic);

      // 状態を更新
      state = state.copyWith(
        currentTopic: newTopic,
        isGenerating: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        isLoading: false,
        error: 'トピックの生成に失敗しました: $e',
      );
    }
  }

  /// 手動でトピックを再生成（管理者用）
  Future<void> regenerateTopic() async {
    await generateNewTopic();
  }

  /// エラーをクリア
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// カテゴリーに基づいてタグを生成
  List<String> _generateTags(TopicCategory category) {
    switch (category) {
      case TopicCategory.daily:
        return ['日常', '身近な話題'];
      case TopicCategory.social:
        return ['社会', '時事'];
      case TopicCategory.value:
        return ['価値観', '人生'];
    }
  }
}

/// 日別トピックプロバイダー
final dailyTopicProvider =
    NotifierProvider<DailyTopicNotifier, DailyTopicState>(
  DailyTopicNotifier.new,
);

/// 選択中の日付を管理するNotifier
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime.now(); // 初期値は今日
  }

  /// 日付を設定
  void setDate(DateTime date) {
    state = date;
  }
}

/// 選択中の日付プロバイダー（意見一覧画面用）
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

/// 選択した日付のトピックを取得するプロバイダー
final topicByDateProvider = FutureProvider.family<Topic?, DateTime>((ref, date) async {
  final repository = ref.watch(dailyTopicRepositoryProvider);
  return await repository.getTopicByDate(date);
});

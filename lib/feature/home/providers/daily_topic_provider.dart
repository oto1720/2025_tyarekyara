import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/topic.dart';
import '../repositories/daily_topic_repository.dart';
import '../repositories/ai_repository.dart';
import '../services/topic_generation_service.dart';
import '../services/news_service.dart';
import '../utils/random_topic_selector.dart';
import '../../debate/repositories/debate_event_repository.dart';
import '../../debate/models/debate_event.dart';

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

/// DebateEventRepositoryプロバイダー
final debateEventRepositoryProviderForDaily = Provider<DebateEventRepository>((ref) {
  return DebateEventRepository();
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

  DebateEventRepository get debateEventRepository =>
      ref.read(debateEventRepositoryProviderForDaily);

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

      // debateイベントも自動作成
      await _createDebateEventFromTopic(newTopic);

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

  /// TopicからDebateEventを作成
  Future<void> _createDebateEventFromTopic(Topic topic) async {
    final now = DateTime.now();
    
    // 既に今日のイベントが存在するか確認
    try {
      final existingEvents = await debateEventRepository.getUpcomingEvents(limit: 10);
      final hasTodayEvent = existingEvents.any(
        (e) => e.scheduledAt.year == now.year &&
              e.scheduledAt.month == now.month &&
              e.scheduledAt.day == now.day,
      );

      // 既に存在する場合はスキップ
      if (hasTodayEvent) {
        print('今日のdebateイベントは既に存在します');
        return;
      }
    } catch (e) {
      // エラーが発生しても作成を続行
      print('既存イベント確認中にエラー: $e');
    }

    try {
      // 今日の20:00に開催予定
      final scheduledAt = DateTime(now.year, now.month, now.day, 20, 0);
      // 今日の18:00がエントリー締切
      final entryDeadline = DateTime(now.year, now.month, now.day, 18, 0);

      final debateEvent = DebateEvent(
        id: 'daily-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        title: '今日のディベート',
        topic: topic.text,
        description: topic.description ?? '${topic.category.displayName}に関するディベートです。',
        status: EventStatus.accepting,
        scheduledAt: scheduledAt,
        entryDeadline: entryDeadline,
        createdAt: now,
        updatedAt: now,
        availableDurations: [
          DebateDuration.short,
          DebateDuration.medium,
          DebateDuration.long,
        ],
        availableFormats: [
          DebateFormat.oneVsOne,
          DebateFormat.twoVsTwo,
        ],
        currentParticipants: 0,
        maxParticipants: 100,
        metadata: {
          'topicId': topic.id,
          'category': topic.category.name,
          'difficulty': topic.difficulty.name,
        },
      );

      await debateEventRepository.createEvent(debateEvent);
      print('✅ debateイベントを作成しました: ${debateEvent.id}');
    } catch (e) {
      print('⚠️ debateイベントの作成に失敗しました: $e');
      // エラーが発生してもトピック生成は続行
    }
  }
}

/// 日別トピックプロバイダー
final dailyTopicProvider =
    NotifierProvider<DailyTopicNotifier, DailyTopicState>(
  DailyTopicNotifier.new,
);

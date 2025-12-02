import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feature/home/providers/daily_topic_provider.dart';
import '../../feature/home/providers/opinion_provider.dart';
import '../../feature/debate/providers/today_debate_event_provider.dart';
import '../../feature/auth/providers/auth_provider.dart';

/// 今日のディベートイベントが解放されているかチェック
/// autoDisposeを使用して、画面遷移時にキャッシュをクリア
final isTodayDebateUnlockedProvider = FutureProvider.autoDispose<bool>((ref) async {
  print('[DebateUnlock] プロバイダーが評価されました');

  // 1. Firebase Authenticationの状態を直接取得
  // authControllerProviderではなくauthStateChangesProviderを使用することで、
  // 初期化タイミングの問題を回避
  final authStateAsync = ref.watch(authStateChangesProvider);
  final user = authStateAsync.value;

  print('[DebateUnlock] Firebase Auth User: ${user?.uid ?? "null"}');

  // 認証されていない場合は解放しない
  if (user == null) {
    print('[DebateUnlock] ユーザーがnull - 解放しない');
    return false;
  }
  print('[DebateUnlock] ユーザーID: ${user.uid}');

  // 2. 今日のトピックを取得
  final dailyTopicState = ref.watch(dailyTopicProvider);
  final dailyTopic = dailyTopicState.currentTopic;
  if (dailyTopic == null) {
    print('[DebateUnlock] トピックがnull - 解放しない');
    return false;
  }
  print('[DebateUnlock] トピックID: ${dailyTopic.id}');

  // 3. OpinionRepositoryを直接使用してFirestoreから意見の存在を確認
  // これにより、opinionPostProviderの初期化タイミングに依存しなくなる
  final opinionRepository = ref.read(opinionRepositoryProvider);
  final userOpinion = await opinionRepository.getUserOpinion(dailyTopic.id, user.uid);

  print('[DebateUnlock] ユーザーの意見: ${userOpinion != null ? "存在する" : "存在しない"}');
  final result = userOpinion != null;
  print('[DebateUnlock] 最終結果: ${result ? "解放" : "ロック"}');

  return result;
});

/// 特定のイベントIDが解放されているかチェック
/// autoDisposeを使用して、画面遷移時にキャッシュをクリア
final isDebateEventUnlockedProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, eventId) async {
    // 今日のイベントかチェック
    final isTodayEvent = ref.watch(isTodayEventProvider(eventId));

    if (!isTodayEvent) {
      // 今日のイベントでない場合は常に解放（過去のイベント参照可能）
      return true;
    }

    // 今日のイベントの場合はトピック回答をチェック
    return await ref.watch(isTodayDebateUnlockedProvider.future);
  },
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feature/home/providers/daily_topic_provider.dart';
import '../../feature/home/providers/opinion_provider.dart';
import '../../feature/debate/providers/today_debate_event_provider.dart';
import '../../feature/auth/providers/auth_provider.dart';

/// 今日のディベートイベントが解放されているかチェック
final isTodayDebateUnlockedProvider = FutureProvider<bool>((ref) async {
  // 1. 認証状態を取得
  final authState = ref.watch(authControllerProvider);

  // 認証されていない場合は解放しない
  final user = authState.whenOrNull(authenticated: (user) => user);
  if (user == null) return false;

  // 2. 今日のトピックを取得
  final dailyTopicState = ref.watch(dailyTopicProvider);
  final dailyTopic = dailyTopicState.currentTopic;
  if (dailyTopic == null) return false;

  // 3. ユーザーが今日のトピックに回答したかチェック
  final opinionState = ref.watch(opinionPostProvider(dailyTopic.id));

  return opinionState.hasPosted;
});

/// 特定のイベントIDが解放されているかチェック
final isDebateEventUnlockedProvider = FutureProvider.family<bool, String>(
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

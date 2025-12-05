import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/debate_event.dart';
import 'debate_event_provider.dart';

/// 今日のディベートイベントを取得
final todayDebateEventProvider = FutureProvider<DebateEvent?>((ref) async {
  final repository = ref.watch(debateEventRepositoryProvider);

  // 今日の日付（YYYY-MM-DD形式）
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // イベントIDのパターン: event_{date}_*
  final eventIdPrefix = 'event_$today';

  try {
    // 開催予定のイベントを取得
    final upcomingEvents = await repository.getUpcomingEvents(limit: 50);

    // 今日のイベントを見つける
    final todayEvent = upcomingEvents.firstWhere(
      (event) => event.id.startsWith(eventIdPrefix),
      orElse: () => throw Exception('Today\'s event not found'),
    );

    return todayEvent;
  } catch (e) {
    debugPrint('Error fetching today\'s debate event: $e');
    return null;
  }
});

/// 特定のイベントが今日のイベントかどうかをチェック
final isTodayEventProvider = Provider.family<bool, String>((ref, eventId) {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return eventId.startsWith('event_$today');
});

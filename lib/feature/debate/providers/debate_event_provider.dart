import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/debate_event.dart';
import '../models/debate_match.dart';
import '../repositories/debate_event_repository.dart';
import 'debate_match_provider.dart'; // debateMatchRepositoryProviderをインポート

/// DebateEventRepository Provider
final debateEventRepositoryProvider = Provider<DebateEventRepository>((ref) {
  return DebateEventRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// 開催予定イベント一覧 Provider（ユーザーのマッチが完了したイベントを除外）
final upcomingEventsProvider = StreamProvider.autoDispose<List<DebateEvent>>((ref) async* {
  final eventRepository = ref.watch(debateEventRepositoryProvider);
  final matchRepository = ref.watch(debateMatchRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;

  await for (final events in eventRepository.watchUpcomingEvents(limit: 20)) {
    if (user == null) {
      // ユーザーがログインしていない場合は全イベントを表示
      yield events;
      continue;
    }

    // ユーザーのマッチが完了したイベントを除外
    final filteredEvents = <DebateEvent>[];
    for (final event in events) {
      final match = await matchRepository.getUserMatchByEvent(event.id, user.uid);

      // マッチが存在しない、またはマッチが完了していない場合は表示
      if (match == null || match.status != MatchStatus.completed) {
        filteredEvents.add(event);
      }
    }

    yield filteredEvents;
  }
});

/// 特定イベント詳細 Provider
final eventDetailProvider = StreamProvider.autoDispose.family<DebateEvent?, String>(
  (ref, eventId) {
    final repository = ref.watch(debateEventRepositoryProvider);
    return repository.watchEvent(eventId);
  },
);

/// イベント一覧取得 FutureProvider
final eventListProvider = FutureProvider.autoDispose<List<DebateEvent>>((ref) async {
  final repository = ref.watch(debateEventRepositoryProvider);
  return await repository.getUpcomingEvents(limit: 20);
});

/// 過去のイベント一覧 Provider
final completedEventsProvider = FutureProvider.autoDispose<List<DebateEvent>>((ref) async {
  final repository = ref.watch(debateEventRepositoryProvider);
  return await repository.getCompletedEvents(limit: 20);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debate_event.dart';
import '../repositories/debate_event_repository.dart';

/// DebateEventRepository Provider
final debateEventRepositoryProvider = Provider<DebateEventRepository>((ref) {
  return DebateEventRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// 開催予定イベント一覧 Provider
final upcomingEventsProvider = StreamProvider.autoDispose<List<DebateEvent>>((ref) {
  final repository = ref.watch(debateEventRepositoryProvider);
  return repository.watchUpcomingEvents(limit: 20);
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

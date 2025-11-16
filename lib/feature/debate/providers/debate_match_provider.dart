import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debate_match.dart';
import '../repositories/debate_match_repository.dart';

/// DebateMatchRepository Provider
final debateMatchRepositoryProvider = Provider<DebateMatchRepository>((ref) {
  return DebateMatchRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// ユーザーのエントリー状態 Provider
final userEntryProvider = StreamProvider.autoDispose.family<DebateEntry?, (String, String)>(
  (ref, params) {
    final (eventId, userId) = params;
    final repository = ref.watch(debateMatchRepositoryProvider);
    return repository.watchUserEntry(eventId, userId);
  },
);

/// ユーザーの現在のマッチ Provider
final currentMatchProvider = FutureProvider.autoDispose.family<DebateMatch?, String>(
  (ref, userId) async {
    final repository = ref.watch(debateMatchRepositoryProvider);
    return await repository.getCurrentMatch(userId);
  },
);

/// マッチ詳細 Provider
final matchDetailProvider = StreamProvider.autoDispose.family<DebateMatch?, String>(
  (ref, matchId) {
    final repository = ref.watch(debateMatchRepositoryProvider);
    return repository.watchMatch(matchId);
  },
);

/// ユーザーのマッチ履歴 Provider
final matchHistoryProvider = FutureProvider.autoDispose.family<List<DebateMatch>, String>(
  (ref, userId) async {
    final repository = ref.watch(debateMatchRepositoryProvider);
    return await repository.getUserMatchHistory(userId, limit: 20);
  },
);

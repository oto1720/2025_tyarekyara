import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_debate_stats.dart';
import '../repositories/user_debate_stats_repository.dart';

/// UserDebateStatsRepository Provider
final userDebateStatsRepositoryProvider = Provider<UserDebateStatsRepository>((ref) {
  return UserDebateStatsRepository(
    firestore: FirebaseFirestore.instance,
  );
});

/// ユーザー統計 Provider
final userStatsProvider = StreamProvider.autoDispose.family<UserDebateStats?, String>(
  (ref, userId) {
    final repository = ref.watch(userDebateStatsRepositoryProvider);
    return repository.watchUserStats(userId);
  },
);

/// ユーザーディベート統計 Provider (エイリアス)
final userDebateStatsProvider = FutureProvider.autoDispose.family<UserDebateStats?, String>(
  (ref, userId) async {
    final repository = ref.watch(userDebateStatsRepositoryProvider);
    return await repository.getUserStats(userId);
  },
);

/// 月間ポイントランキング Provider
final monthlyPointsRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>((ref) async {
  final repository = ref.watch(userDebateStatsRepositoryProvider);
  return await repository.getMonthlyPointsRanking(limit: 100);
});

/// 通算勝利数ランキング Provider
final totalWinsRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>((ref) async {
  final repository = ref.watch(userDebateStatsRepositoryProvider);
  return await repository.getTotalWinsRanking(limit: 100);
});

/// MVP獲得数ランキング Provider
final mvpCountRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>((ref) async {
  final repository = ref.watch(userDebateStatsRepositoryProvider);
  return await repository.getMvpCountRanking(limit: 100);
});

/// ユーザーランク位置 Provider
final userRankProvider = FutureProvider.autoDispose.family<int?, (String, String)>(
  (ref, params) async {
    final (rankingType, userId) = params;
    final repository = ref.watch(userDebateStatsRepositoryProvider);
    return await repository.getUserRank(rankingType, userId);
  },
);

/// 総ポイントランキング Provider
final pointsRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>((ref) async {
  final repository = ref.watch(userDebateStatsRepositoryProvider);
  return await repository.getTotalPointsRanking(limit: 100);
});

/// 勝率ランキング Provider
final winRateRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>((ref) async {
  final repository = ref.watch(userDebateStatsRepositoryProvider);
  return await repository.getWinRateRanking(limit: 100);
});

/// 参加数ランキング Provider
final participationRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>((ref) async {
  final repository = ref.watch(userDebateStatsRepositoryProvider);
  return await repository.getParticipationRanking(limit: 100);
});

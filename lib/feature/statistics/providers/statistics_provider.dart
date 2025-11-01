import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'statistics_state.dart';
import '../models/user_statistics.dart';
import '../models/diversity_score.dart';
import '../models/stance_distribution.dart';
import '../models/participation_trend.dart';
import '../models/badge.dart';

/// StatisticsNotifier は統計データの読み込みを担当する簡易の Notifier
class StatisticsNotifier extends Notifier<StatisticsState> {
  @override
  StatisticsState build() {
    return const StatisticsState();
  }

  Future<void> loadUserStatistics(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: repository/service 経由で実データを取得
      await Future.delayed(const Duration(milliseconds: 200));
      // 仮のダミーデータ (実装時に置き換え)
      final now = DateTime.now().toUtc();
      final userStats = UserStatistics(
        userId: userId,
        participationDays: 10,
        totalOpinions: 42,
        consecutiveDays: 3,
        lastParticipation: DateTime.now().toUtc(),
        createdAt: now,
        updatedAt: now,
      );
      final diversity = DiversityScore(
        userId: userId,
        score: 78.0,
        breakdown: {'議論の幅': 40.0, '情報源の多様性': 38.0},
        createdAt: now,
        updatedAt: now,
      );

      final stance = StanceDistribution(
        userId: userId,
        counts: {'賛成': 16, '中立': 8, '反対': 12},
        total: 36,
        createdAt: now,
        updatedAt: now,
      );

      final trend = ParticipationTrend(
        userId: userId,
        points: [
          ParticipationPoint(
            date: now.subtract(const Duration(days: 6)),
            count: 2,
          ),
          ParticipationPoint(
            date: now.subtract(const Duration(days: 5)),
            count: 3,
          ),
          ParticipationPoint(
            date: now.subtract(const Duration(days: 4)),
            count: 4,
          ),
          ParticipationPoint(
            date: now.subtract(const Duration(days: 3)),
            count: 2,
          ),
          ParticipationPoint(
            date: now.subtract(const Duration(days: 2)),
            count: 5,
          ),
          ParticipationPoint(
            date: now.subtract(const Duration(days: 1)),
            count: 3,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      final badges = [
        Badge(
          id: 'b1',
          name: '初投稿',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ),
        Badge(id: 'b2', name: '7日連続参加', createdAt: now, updatedAt: now),
      ];
      state = state.copyWith(
        userStatistics: userStats,
        diversityScore: diversity,
        stanceDistribution: stance,
        participationTrend: trend,
        earnedBadges: badges,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final statisticsNotifierProvider =
    NotifierProvider<StatisticsNotifier, StatisticsState>(() {
      return StatisticsNotifier();
    });

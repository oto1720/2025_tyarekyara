import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'statistics_state.dart';
import '../models/user_statistics.dart';
import '../models/diversity_score.dart';
import '../models/stance_distribution.dart';
import '../models/participation_trend.dart';
import '../models/badge.dart';
import '../repositories/local_statistics_repository.dart';
import '../repositories/firestore_statistics_repository.dart';
import '../../challenge/repositories/challenge_repositories.dart';

/// StatisticsNotifier は統計データの読み込みを担当する簡易の Notifier
class StatisticsNotifier extends Notifier<StatisticsState> {
  @override
  StatisticsState build() {
    final now = DateTime.now();
    return StatisticsState(
      selectedYear: now.year,
      selectedMonth: now.month,
    );
  }

  /// 表示する月を変更
  void changeMonth(int year, int month) {
    state = state.copyWith(
      selectedYear: year,
      selectedMonth: month,
    );
  }

  /// 前月に移動
  void goToPreviousMonth() {
    final currentYear = state.selectedYear ?? DateTime.now().year;
    final currentMonth = state.selectedMonth ?? DateTime.now().month;

    if (currentMonth == 1) {
      changeMonth(currentYear - 1, 12);
    } else {
      changeMonth(currentYear, currentMonth - 1);
    }
  }

  /// 次月に移動
  void goToNextMonth() {
    final currentYear = state.selectedYear ?? DateTime.now().year;
    final currentMonth = state.selectedMonth ?? DateTime.now().month;

    if (currentMonth == 12) {
      changeMonth(currentYear + 1, 1);
    } else {
      changeMonth(currentYear, currentMonth + 1);
    }
  }

  Future<void> loadUserStatistics(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    // ゲストモードの場合は直接モックデータを使用
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('is_guest_mode') ?? false;

    if (isGuest || userId.isEmpty) {
      print('👤 ゲストモード: モックデータを使用');
      // ダミーデータを直接設定
      await Future.delayed(const Duration(milliseconds: 200));
      final now = DateTime.now().toUtc();
      final userStats = UserStatistics(
        userId: 'guest',
        participationDays: 10,
        totalOpinions: 42,
        consecutiveDays: 3,
        lastParticipation: DateTime.now().toUtc(),
        createdAt: now,
        updatedAt: now,
      );
      final diversity = DiversityScore(
        userId: 'guest',
        score: 78.0,
        breakdown: {'議論の幅': 40.0, '情報源の多様性': 38.0},
        createdAt: now,
        updatedAt: now,
      );

      final stance = StanceDistribution(
        userId: 'guest',
        counts: {'賛成': 16, '中立': 8, '反対': 12},
        total: 36,
        createdAt: now,
        updatedAt: now,
      );

      final trend = ParticipationTrend(
        userId: 'guest',
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
      return;
    }

    try {
      print('📊 統計データ取得開始: userId=$userId');
      // Firestoreから実データを取得
      final firestoreRepo = FirestoreStatisticsRepository();
      final u = await firestoreRepo.fetchUserStatistics(userId);
      print('📊 UserStatistics取得: totalOpinions=${u.totalOpinions}, consecutiveDays=${u.consecutiveDays}, participationDays=${u.participationDays}');
      final d = await firestoreRepo.fetchDiversityScore(userId);
      print('📊 DiversityScore取得: ${d?.score}');
      final s = await firestoreRepo.fetchStanceDistribution(userId);
      print('📊 StanceDistribution取得: ${s?.counts}');

      // 選択された年月でParticipationTrendを取得
      final selectedYear = state.selectedYear ?? DateTime.now().year;
      final selectedMonth = state.selectedMonth ?? DateTime.now().month;
      final t = await firestoreRepo.fetchParticipationTrend(userId, year: selectedYear, month: selectedMonth);
      print('📊 ParticipationTrend取得 ($selectedYear年$selectedMonth月): ${t?.points.length}個のポイント');

      // ローカルにも保存（全てのデータが揃っている場合のみ）
      if (d != null && s != null && t != null) {
        final localRepo = LocalStatisticsRepository();
        await localRepo.saveAll(
          userStatistics: u,
          diversityScore: d,
          stanceDistribution: s,
          participationTrend: t,
        );
      }

      // チャレンジ完了数とポイントを取得
      final challengeRepo = ChallengeRepository();
      final completedChallengeCount = await challengeRepo.getCompletedChallengeCount(userId);
      final totalChallengePoints = await challengeRepo.getTotalEarnedPoints(userId);
      print('📊 完了チャレンジ数取得: $completedChallengeCount');
      print('📊 累計チャレンジポイント取得: $totalChallengePoints');

      final badges = <Badge>[];
      final now = DateTime.now();

      // バッジの判定
      // 投稿数系
      if (u.totalOpinions >= 1) {
        badges.add(Badge(
          id: 'first_post',
          name: '初投稿',
          description: '初めて意見を投稿しました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }
      if (u.totalOpinions >= 10) {
        badges.add(Badge(
          id: 'ten_posts',
          name: '10投稿達成',
          description: '10回意見を投稿しました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }
      if (u.totalOpinions >= 50) {
        badges.add(Badge(
          id: 'fifty_posts',
          name: '50投稿達成',
          description: '50回意見を投稿しました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }
      if (u.totalOpinions >= 100) {
        badges.add(Badge(
          id: 'hundred_posts',
          name: '100投稿達成',
          description: '100回意見を投稿しました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }

      // 連続参加系
      if (u.consecutiveDays >= 7) {
        badges.add(Badge(
          id: 'seven_days_streak',
          name: '7日連続参加',
          description: '7日連続で参加しました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }
      if (u.consecutiveDays >= 30) {
        badges.add(Badge(
          id: 'thirty_days_streak',
          name: '30日連続参加',
          description: '30日連続で参加しました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }

      // 参加日数系
      if (u.participationDays >= 30) {
        badges.add(Badge(
          id: 'thirty_days_total',
          name: '30日間参加',
          description: '累計30日間参加しました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }
      if (u.participationDays >= 100) {
        badges.add(Badge(
          id: 'hundred_days_total',
          name: '100日間参加',
          description: '累計100日間参加しました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }

      // 多様性系
      if (d != null && d.score >= 80) {
        badges.add(Badge(
          id: 'diverse_thinker',
          name: '多様な思考',
          description: '多様性スコアが80以上になりました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }
      if (s != null && s.counts['賛成']! > 0 && s.counts['中立']! > 0 && s.counts['反対']! > 0) {
        badges.add(Badge(
          id: 'balanced_opinions',
          name: 'バランス型',
          description: '賛成・中立・反対すべてに投稿しました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }

      // 視点交換チャレンジ系
      if (completedChallengeCount >= 1) {
        badges.add(Badge(
          id: 'first_challenge',
          name: '視点交換入門',
          description: '初めてチャレンジをクリアしました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }
      if (completedChallengeCount >= 5) {
        badges.add(Badge(
          id: 'challenge_enthusiast',
          name: 'チャレンジ好き',
          description: '5回チャレンジをクリアしました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }
      if (completedChallengeCount >= 10) {
        badges.add(Badge(
          id: 'challenge_expert',
          name: 'チャレンジ達人',
          description: '10回チャレンジをクリアしました',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }
      if (totalChallengePoints >= 500) {
        badges.add(Badge(
          id: 'challenge_master',
          name: 'チャレンジマスター',
          description: '累計獲得ポイント500P達成',
          createdAt: now,
          updatedAt: now,
          earnedAt: now,
        ));
      }

      state = state.copyWith(
        userStatistics: u,
        diversityScore: d,
        stanceDistribution: s,
        participationTrend: t,
        earnedBadges: badges,
        isLoading: false,
      );
    } catch (e) {
      // エラー時はローカルデータまたはダミーデータを使用
      final localRepo = LocalStatisticsRepository();
      final u = await localRepo.fetchUserStatistics(userId);
      final d = await localRepo.fetchDiversityScore(userId);
      final s = await localRepo.fetchStanceDistribution(userId);
      final selectedYear = state.selectedYear ?? DateTime.now().year;
      final selectedMonth = state.selectedMonth ?? DateTime.now().month;
      final t = await localRepo.fetchParticipationTrend(userId, year: selectedYear, month: selectedMonth);

      if (u != null && d != null && s != null && t != null) {
        // All data present locally
        state = state.copyWith(
          userStatistics: u,
          diversityScore: d,
          stanceDistribution: s,
          participationTrend: t,
          isLoading: false,
        );
      } else {
        // Fallback: create initial dummy data and persist it locally
        await Future.delayed(const Duration(milliseconds: 200));
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

        // Save to local repository for future loads
        await localRepo.saveAll(
          userStatistics: userStats,
          diversityScore: diversity,
          stanceDistribution: stance,
          participationTrend: trend,
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
      }
    }
  }
}

final statisticsNotifierProvider =
    NotifierProvider<StatisticsNotifier, StatisticsState>(() {
      return StatisticsNotifier();
    });

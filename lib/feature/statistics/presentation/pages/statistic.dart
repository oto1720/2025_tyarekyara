import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/thinking_profile_card.dart';
import '../widgets/diversity_score_card.dart';
import '../widgets/stance_distribution_card.dart';
import '../widgets/participation_trend_card.dart';
import '../widgets/earned_badges_card.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/badge_provider.dart';

class StatisticPage extends ConsumerStatefulWidget {
  const StatisticPage({super.key});

  @override
  ConsumerState<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends ConsumerState<StatisticPage> {
  @override
  void initState() {
    super.initState();
    // 初回レンダーで非同期ロードをトリガー
    Future.microtask(() {
      // 仮の userId を使っています。実処理では認証ユーザ ID を使ってください。
      const demoUserId = 'demo_user';
      ref
          .read(statisticsNotifierProvider.notifier)
          .loadUserStatistics(demoUserId);
      ref.read(badgeNotifierProvider.notifier).loadEarnedBadges(demoUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsNotifierProvider);
    // badgeState is currently unused here; individual widgets can independently read badge provider if needed.

    return Scaffold(
      // pagesample.css を参考にしたグラデ背景
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Header / Thinking profile
                ThinkingProfileCardImpl(userStatistics: state.userStatistics),
                const SizedBox(height: 16),

                // Diversity score
                DiversityScoreCardImpl(diversity: state.diversityScore),
                const SizedBox(height: 12),

                // Stance distribution
                StanceDistributionCardImpl(stance: state.stanceDistribution),
                const SizedBox(height: 12),

                // Participation trend
                ParticipationTrendCardImpl(trend: state.participationTrend),
                const SizedBox(height: 12),

                // Earned badges
                EarnedBadgesCardImpl(earnedBadges: state.earnedBadges),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

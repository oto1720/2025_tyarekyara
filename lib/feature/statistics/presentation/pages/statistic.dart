import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/thinking_profile_card.dart';
import '../widgets/diversity_score_card.dart';
import '../widgets/stance_distribution_card.dart';
import '../widgets/participation_trend_card.dart';
import '../widgets/earned_badges_card.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/badge_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class StatisticPage extends ConsumerStatefulWidget {
  const StatisticPage({super.key});

  @override
  ConsumerState<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends ConsumerState<StatisticPage> {
  String? _loadedUserId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsNotifierProvider);

    // Firebaseの認証状態を直接監視
    final authStateAsync = ref.watch(authStateChangesProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    // 認証状態とユーザーデータの両方をチェック
    authStateAsync.whenData((firebaseUser) {
      if (firebaseUser != null) {
        currentUserAsync.whenData((userData) {
          if (userData != null && _loadedUserId != userData.id) {
            _loadedUserId = userData.id;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print('🔐 認証済みユーザー: userId=${userData.id}');
              ref.read(statisticsNotifierProvider.notifier).loadUserStatistics(userData.id);
              ref.read(badgeNotifierProvider.notifier).loadEarnedBadges(userData.id);
            });
          }
        });
      }
    });
    // badgeState is currently unused here; individual widgets can independently read badge provider if needed.

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surface,
        ),
        child: SafeArea(
          child: state.isLoading && state.userStatistics == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '統計データを読み込み中...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
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
                      const SizedBox(height: 95), // BottomNavigationBar分の余白
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

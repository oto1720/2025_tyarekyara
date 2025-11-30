import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/thinking_profile_card.dart';
import '../widgets/diversity_score_card.dart';
import '../widgets/stance_distribution_card.dart';
import '../widgets/participation_trend_card.dart';
import '../widgets/earned_badges_card.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/badge_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../guide/presentaion/widgets/tutorial_showcase_wrapper.dart';
import '../../../guide/presentaion/widgets/tutorial_dialog.dart' show TutorialBottomSheet;

class StatisticPage extends ConsumerStatefulWidget {
  const StatisticPage({super.key});

  @override
  ConsumerState<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends ConsumerState<StatisticPage> {
  String? _loadedUserId;
  final GlobalKey _helpButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsNotifierProvider);

    return ShowCaseWidget(
      builder: (context) => TutorialShowcaseWrapper(
        pageKey: 'statistics',
        showcaseKey: _helpButtonKey,
        child: FutureBuilder<bool>(
      future: SharedPreferences.getInstance().then((prefs) => prefs.getBool('is_guest_mode') ?? false),
      builder: (context, snapshot) {
        final isGuest = snapshot.data ?? false;

        // ゲストモードの場合、モックデータを表示
        if (isGuest) {
          // ゲストモード用：プロバイダーが自動的にモックデータを使用
          if (_loadedUserId != 'guest') {
            _loadedUserId = 'guest';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print('👤 ゲストモード: モックデータを表示');
              ref.read(statisticsNotifierProvider.notifier).loadUserStatistics('guest');
            });
          }

          return Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              title: const Text(
                '統計',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                Showcase(
                  key: _helpButtonKey,
                  title: '操作ガイド',
                  description: '詳細はここにあります。確認しましょう',
                  child: IconButton(
                    icon: const Icon(Icons.help_outline, color: AppColors.textPrimary),
                    onPressed: () {
                      TutorialBottomSheet.show(context, 'statistics');
                    },
                    tooltip: '操作ガイド',
                  ),
                ),
              ],
            ),
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
                              'モックデータを読み込み中...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ゲストモードバナー
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'これはモックデータです',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[900],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ログインすると実際のデータを確認できます',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => context.push('/login'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange[700],
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('ログイン / 新規登録'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

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

        // 通常モード（ログインユーザー）
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

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text(
              '統計',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Showcase(
                key: _helpButtonKey,
                title: '操作ガイド',
                description: '詳細はここにあります。確認しましょう',
                child: IconButton(
                  icon: const Icon(Icons.help_outline, color: AppColors.textPrimary),
                  onPressed: () {
                    TutorialBottomSheet.show(context, 'statistics');
                  },
                  tooltip: '操作ガイド',
                ),
              ),
            ],
          ),
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
      },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/user_debate_stats.dart';
import '../../providers/user_debate_stats_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/badge_display_widget.dart';
import '../widgets/level_progress_widget.dart';

/// ディベート統計画面
class DebateStatsPage extends ConsumerWidget {
  const DebateStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => null,
    );

    if (userId == null) {
      return _buildNotAuthenticated();
    }

    final statsAsync = ref.watch(userDebateStatsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ディベート統計'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(userDebateStatsProvider(userId));
            },
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats == null) {
            return _buildNoStats();
          }
          return _buildStatsContent(context, stats);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(error),
      ),
    );
  }

  /// 統計コンテンツ
  Widget _buildStatsContent(BuildContext context, UserDebateStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LevelProgressWidget(
            level: stats.level,
            currentPoints: stats.currentLevelPoints,
            pointsToNextLevel: stats.pointsToNextLevel,
          ),
          const SizedBox(height: 24),
          _buildOverallStats(stats),
          const SizedBox(height: 24),
          _buildWinRateChart(stats),
          const SizedBox(height: 24),
          _buildPointsBreakdown(stats),
          const SizedBox(height: 24),
          _buildBadgesSection(stats),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// 総合統計
  Widget _buildOverallStats(UserDebateStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '総合統計',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '参加回数',
                    '${stats.totalDebates}',
                    Icons.groups,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '勝利数',
                    '${stats.wins}',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '敗北数',
                    '${stats.losses}',
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '引き分け',
                    '${stats.draws}',
                    Icons.handshake,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '総ポイント',
                    '${stats.totalPoints}',
                    Icons.stars,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'MVP獲得',
                    '${stats.mvpCount}',
                    Icons.workspace_premium,
                    Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 統計カード
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 勝率チャート
  Widget _buildWinRateChart(UserDebateStats stats) {
    final totalMatches = stats.wins + stats.losses + stats.draws;
    if (totalMatches == 0) {
      return const SizedBox.shrink();
    }

    final winRate = stats.wins / totalMatches;
    final lossRate = stats.losses / totalMatches;
    final drawRate = stats.draws / totalMatches;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '勝敗分布',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      value: stats.wins.toDouble(),
                      title: '${(winRate * 100).toStringAsFixed(1)}%',
                      color: Colors.amber,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: stats.losses.toDouble(),
                      title: '${(lossRate * 100).toStringAsFixed(1)}%',
                      color: Colors.red,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (stats.draws > 0)
                      PieChartSectionData(
                        value: stats.draws.toDouble(),
                        title: '${(drawRate * 100).toStringAsFixed(1)}%',
                        color: Colors.grey,
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('勝利', Colors.amber, stats.wins),
                _buildLegendItem('敗北', Colors.red, stats.losses),
                if (stats.draws > 0)
                  _buildLegendItem('引分', Colors.grey, stats.draws),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 凡例アイテム
  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// ポイント内訳
  Widget _buildPointsBreakdown(UserDebateStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ポイント内訳',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPointRow(
              '参加ポイント',
              stats.totalDebates * 10, // 仮定: 1回10pt
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildPointRow(
              '勝利ボーナス',
              stats.wins * 30, // 仮定: 勝利30pt
              Colors.amber,
            ),
            const SizedBox(height: 8),
            _buildPointRow(
              'MVPボーナス',
              stats.mvpCount * 50, // 仮定: MVP50pt
              Colors.pink,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '合計',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${stats.totalPoints} pt',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ポイント行
  Widget _buildPointRow(String label, int points, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        Text(
          '$points pt',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  /// バッジセクション
  Widget _buildBadgesSection(UserDebateStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '獲得バッジ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${stats.earnedBadges.length}/${BadgeType.values.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BadgeGridWidget(
              earnedBadges: stats.earnedBadges,
              onBadgeTap: (badgeType) {
                // バッジ詳細を表示
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 未認証
  Widget _buildNotAuthenticated() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('ログインが必要です'),
          ],
        ),
      ),
    );
  }

  /// 統計なし
  Widget _buildNoStats() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'まだディベート統計がありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ディベートに参加して統計を蓄積しましょう！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// エラー
  Widget _buildError(Object error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('エラー: $error'),
          ],
        ),
      ),
    );
  }
}

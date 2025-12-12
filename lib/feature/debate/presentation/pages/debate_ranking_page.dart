import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_debate_stats.dart';
import '../../providers/user_debate_stats_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/level_progress_widget.dart';
import '../../../../core/constants/app_colors.dart';

/// ディベートランキング画面
class DebateRankingPage extends ConsumerStatefulWidget {
  const DebateRankingPage({super.key});

  @override
  ConsumerState<DebateRankingPage> createState() => _DebateRankingPageState();
}

class _DebateRankingPageState extends ConsumerState<DebateRankingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateChangesProvider);
    final user = authStateAsync.value;
    final userId = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ポイント'),
            Tab(text: '勝率'),
            Tab(text: '参加数'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPointsRanking(userId),
          _buildWinRateRanking(userId),
          _buildParticipationRanking(userId),
        ],
      ),
    );
  }

  /// ポイントランキング
  Widget _buildPointsRanking(String? userId) {
    final rankingAsync = ref.watch(pointsRankingProvider);

    return rankingAsync.when(
      data: (rankings) => _buildRankingList(
        rankings,
        userId,
        (entry) => '${entry.totalPoints} pt',
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildError(error),
    );
  }

  /// 勝率ランキング
  Widget _buildWinRateRanking(String? userId) {
    final rankingAsync = ref.watch(winRateRankingProvider);

    return rankingAsync.when(
      data: (rankings) => _buildRankingList(
        rankings,
        userId,
        (entry) {
          final totalMatches = entry.wins + entry.losses;
          if (totalMatches == 0) return '0.0%';
          final winRate = (entry.wins / totalMatches * 100);
          return '${winRate.toStringAsFixed(1)}%';
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildError(error),
    );
  }

  /// 参加数ランキング
  Widget _buildParticipationRanking(String? userId) {
    final rankingAsync = ref.watch(participationRankingProvider);

    return rankingAsync.when(
      data: (rankings) => _buildRankingList(
        rankings,
        userId,
        (entry) => '${entry.totalDebates}回',
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildError(error),
    );
  }

  /// ランキングリスト
  Widget _buildRankingList(
    List<RankingEntry> rankings,
    String? userId,
    String Function(RankingEntry) valueFormatter,
  ) {
    if (rankings.isEmpty) {
      return _buildEmpty();
    }

    // 自分のランキングを探す
    final myRank = userId != null
        ? rankings.indexWhere((e) => e.userId == userId) + 1
        : 0;

    return Column(
      children: [
        if (myRank > 0) _buildMyRankCard(rankings[myRank - 1], myRank),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pointsRankingProvider);
              ref.invalidate(winRateRankingProvider);
              ref.invalidate(participationRankingProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final entry = rankings[index];
                final rank = index + 1;
                final isMyRank = userId != null && entry.userId == userId;

                return _buildRankingCard(
                  entry,
                  rank,
                  valueFormatter(entry),
                  isMyRank,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 自分のランクカード
  Widget _buildMyRankCard(RankingEntry entry, int rank) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'あなたの順位',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.userName ?? 'ユーザー',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          CompactLevelWidget(level: entry.level, size: 48),
        ],
      ),
    );
  }

  /// ランキングカード
  Widget _buildRankingCard(
    RankingEntry entry,
    int rank,
    String value,
    bool isMyRank,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMyRank ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMyRank ? AppColors.primary : AppColors.border,
          width: isMyRank ? 2 : 1,
        ),
        boxShadow: [
          if (rank <= 3)
            BoxShadow(
              color: _getRankColor(rank).withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        leading: _buildRankBadge(rank),
        title: Text(
          entry.userName ?? 'ユーザー',
          style: TextStyle(
            fontWeight: isMyRank ? FontWeight.bold : FontWeight.normal,
            color: isMyRank ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isMyRank ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: CompactLevelWidget(level: entry.level),
      ),
    );
  }

  /// ランクバッジ
  Widget _buildRankBadge(int rank) {
    if (rank <= 3) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getRankColor(rank),
              _getRankColor(rank).withValues(alpha: 0.7),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getRankColor(rank).withValues(alpha: 0.3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            rank == 1
                ? Icons.emoji_events
                : rank == 2
                    ? Icons.military_tech
                    : Icons.star,
            color: Colors.white,
            size: 28,
          ),
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.border,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// ランク色取得
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // 金
      case 2:
        return Colors.grey[400]!; // 銀
      case 3:
        return Colors.brown[400]!; // 銅
      default:
        return Colors.grey;
    }
  }

  /// 空表示
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 80, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'まだランキングがありません',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// エラー表示
  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'エラー: $error',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

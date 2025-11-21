import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/judgment_result.dart';
import '../../models/debate_match.dart';
import '../../providers/debate_room_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/judgment_score_widget.dart';
import '../widgets/judgment_chart_widget.dart';

/// 判定結果画面
class DebateResultPage extends ConsumerWidget {
  final String matchId;

  const DebateResultPage({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final judgmentAsync = ref.watch(judgmentResultProvider(matchId));
    final matchAsync = ref.watch(matchDetailProvider(matchId));
    final authState = ref.watch(authControllerProvider);

    final userId = authState.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => null,
    );

    return Scaffold(
      body: judgmentAsync.when(
        data: (judgment) {
          if (judgment == null) {
            return _buildNotFound(context);
          }

          return matchAsync.when(
            data: (match) {
              if (match == null) {
                return _buildNotFound(context);
              }
              return _buildResultContent(context, judgment, match, userId);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildError(context, error),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  /// 結果コンテンツ
  Widget _buildResultContent(
    BuildContext context,
    JudgmentResult judgment,
    DebateMatch match,
    String? userId,
  ) {
    final isProWinner = judgment.winningSide == DebateStance.pro;
    final isConWinner = judgment.winningSide == DebateStance.con;
    final isDraw = judgment.winningSide == null;

    final isUserOnProTeam = userId != null &&
        match.proTeam.memberIds.contains(userId);
    final isUserOnConTeam = userId != null &&
        match.conTeam.memberIds.contains(userId);
    final isUserWinner = (isProWinner && isUserOnProTeam) ||
        (isConWinner && isUserOnConTeam);

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, judgment, isUserWinner, isDraw),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultCard(judgment, isDraw),
                const SizedBox(height: 24),
                _buildScoreComparison(judgment, match),
                const SizedBox(height: 24),
                _buildRadarChart(judgment),
                const SizedBox(height: 24),
                _buildBarChart(judgment),
                const SizedBox(height: 24),
                if (judgment.mvpUserId != null) ...[
                  _buildMVPSection(judgment, match),
                  const SizedBox(height: 24),
                ],
                _buildComments(judgment),
                const SizedBox(height: 24),
                _buildActionButtons(context, isUserWinner),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// AppBar
  Widget _buildAppBar(
    BuildContext context,
    JudgmentResult judgment,
    bool isUserWinner,
    bool isDraw,
  ) {
    final Color appBarColor = isDraw
        ? AppColors.textSecondary
        : isUserWinner
            ? AppColors.success
            : AppColors.warning;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: appBarColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          isDraw ? '引き分け' : isUserWinner ? '勝利！' : '結果発表',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDraw
                  ? [AppColors.textTertiary, AppColors.textSecondary]
                  : isUserWinner
                      ? [AppColors.success, AppColors.info]
                      : [AppColors.warning, AppColors.error],
            ),
          ),
          child: Center(
            child: Icon(
              isDraw
                  ? Icons.handshake
                  : isUserWinner
                      ? Icons.emoji_events
                      : Icons.assessment,
              size: 80,
              color: AppColors.textOnPrimary.withValues(alpha: 0.54),
            ),
          ),
        ),
      ),
    );
  }

  /// 結果カード
  Widget _buildResultCard(JudgmentResult judgment, bool isDraw) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDraw
                ? [AppColors.surfaceVariant, AppColors.surface]
                : judgment.winningSide == DebateStance.pro
                    ? [AppColors.agree.withValues(alpha: 0.1), AppColors.agree.withValues(alpha: 0.2)]
                    : [AppColors.disagree.withValues(alpha: 0.1), AppColors.disagree.withValues(alpha: 0.2)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              isDraw ? Icons.handshake : Icons.star,
              size: 64,
              color: isDraw
                  ? AppColors.textSecondary
                  : judgment.winningSide == DebateStance.pro
                      ? AppColors.agree
                      : AppColors.disagree,
            ),
            const SizedBox(height: 16),
            Text(
              isDraw ? '引き分け' : '勝者',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            if (!isDraw)
              Text(
                judgment.winningSide == DebateStance.pro ? '賛成チーム' : '反対チーム',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: judgment.winningSide == DebateStance.pro
                      ? AppColors.agree
                      : AppColors.disagree,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreBadge(
                  judgment.proTeamScore.totalScore,
                  '賛成',
                  AppColors.agree,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'vs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                _buildScoreBadge(
                  judgment.conTeamScore.totalScore,
                  '反対',
                  AppColors.disagree,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// スコアバッジ
  Widget _buildScoreBadge(int score, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$score',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// スコア比較
  Widget _buildScoreComparison(JudgmentResult judgment, DebateMatch match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '詳細スコア',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        JudgmentScoreWidget(
          teamScore: judgment.proTeamScore,
          teamLabel: '賛成チーム',
          teamColor: AppColors.agree,
          isWinner: judgment.winningSide == DebateStance.pro,
        ),
        const SizedBox(height: 16),
        JudgmentScoreWidget(
          teamScore: judgment.conTeamScore,
          teamLabel: '反対チーム',
          teamColor: AppColors.disagree,
          isWinner: judgment.winningSide == DebateStance.con,
        ),
      ],
    );
  }

  /// レーダーチャート
  Widget _buildRadarChart(JudgmentResult judgment) {
    return JudgmentRadarChartWidget(
      proScore: judgment.proTeamScore,
      conScore: judgment.conTeamScore,
    );
  }

  /// 棒グラフ
  Widget _buildBarChart(JudgmentResult judgment) {
    return JudgmentBarChartWidget(
      proScore: judgment.proTeamScore,
      conScore: judgment.conTeamScore,
    );
  }

  /// MVPセクション
  Widget _buildMVPSection(JudgmentResult judgment, DebateMatch match) {
    final mvpTeamColor = match.proTeam.memberIds.contains(judgment.mvpUserId)
        ? AppColors.agree
        : AppColors.disagree;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MVP',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        MVPDisplayWidget(
          userId: judgment.mvpUserId!,
          userName: judgment.mvpUserId, // TODO: 実際のユーザー名を取得
          teamColor: mvpTeamColor,
        ),
      ],
    );
  }

  /// コメント
  Widget _buildComments(JudgmentResult judgment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI評価コメント',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (judgment.overallComment != null)
          JudgmentCommentWidget(
            comment: judgment.overallComment!,
            title: '総合評価',
            icon: Icons.assessment,
            color: AppColors.aiGenerated,
          ),
        const SizedBox(height: 12),
        if (judgment.proTeamComment != null)
          JudgmentCommentWidget(
            comment: judgment.proTeamComment!,
            title: '賛成チームへのフィードバック',
            icon: Icons.thumb_up,
            color: AppColors.agree,
          ),
        const SizedBox(height: 12),
        if (judgment.conTeamComment != null)
          JudgmentCommentWidget(
            comment: judgment.conTeamComment!,
            title: '反対チームへのフィードバック',
            icon: Icons.thumb_down,
            color: AppColors.disagree,
          ),
      ],
    );
  }

  /// アクションボタン
  Widget _buildActionButtons(BuildContext context, bool isUserWinner) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              // ホームに戻る
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text(
              'ホームに戻る',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: シェア機能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('シェア機能は準備中です')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text(
              '結果をシェア',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 見つからない
  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エラー'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text('判定結果が見つかりません'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }

  /// エラー
  Widget _buildError(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エラー'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 16),
            Text('エラー: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

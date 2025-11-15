import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        ? Colors.grey
        : isUserWinner
            ? Colors.green
            : Colors.orange;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: appBarColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          isDraw ? '引き分け' : isUserWinner ? '勝利！' : '結果発表',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
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
                  ? [Colors.grey[400]!, Colors.grey[600]!]
                  : isUserWinner
                      ? [Colors.green[400]!, Colors.blue[400]!]
                      : [Colors.orange[400]!, Colors.red[400]!],
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
              color: Colors.white54,
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
                ? [Colors.grey[100]!, Colors.grey[50]!]
                : judgment.winningSide == DebateStance.pro
                    ? [Colors.blue[50]!, Colors.blue[100]!]
                    : [Colors.red[50]!, Colors.red[100]!],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              isDraw ? Icons.handshake : Icons.star,
              size: 64,
              color: isDraw
                  ? Colors.grey
                  : judgment.winningSide == DebateStance.pro
                      ? Colors.blue
                      : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isDraw ? '引き分け' : '勝者',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
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
                      ? Colors.blue
                      : Colors.red,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreBadge(
                  judgment.proTeamScore.totalScore,
                  '賛成',
                  Colors.blue,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'vs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                _buildScoreBadge(
                  judgment.conTeamScore.totalScore,
                  '反対',
                  Colors.red,
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
              color: Colors.white,
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
          teamColor: Colors.blue,
          isWinner: judgment.winningSide == DebateStance.pro,
        ),
        const SizedBox(height: 16),
        JudgmentScoreWidget(
          teamScore: judgment.conTeamScore,
          teamLabel: '反対チーム',
          teamColor: Colors.red,
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
        ? Colors.blue
        : Colors.red;

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
            color: Colors.purple,
          ),
        const SizedBox(height: 12),
        if (judgment.proTeamComment != null)
          JudgmentCommentWidget(
            comment: judgment.proTeamComment!,
            title: '賛成チームへのフィードバック',
            icon: Icons.thumb_up,
            color: Colors.blue,
          ),
        const SizedBox(height: 12),
        if (judgment.conTeamComment != null)
          JudgmentCommentWidget(
            comment: judgment.conTeamComment!,
            title: '反対チームへのフィードバック',
            icon: Icons.thumb_down,
            color: Colors.red,
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
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
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
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue, width: 2),
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
      appBar: AppBar(title: const Text('エラー')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('判定結果が見つかりません'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
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
      appBar: AppBar(title: const Text('エラー')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('エラー: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

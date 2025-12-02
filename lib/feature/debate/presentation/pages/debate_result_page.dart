import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/judgment_result.dart';
import '../../models/debate_match.dart';
import '../../providers/debate_room_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/judgment_score_widget.dart';
import '../widgets/judgment_chart_widget.dart';
import '../../../../core/constants/app_colors.dart';

/// 判定結果画面
class DebateResultPage extends ConsumerWidget {
  final String matchId;

  const DebateResultPage({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ゲストモックマッチの場合
    if (matchId == 'guest_mock_match') {
      return FutureBuilder<bool>(
        future: SharedPreferences.getInstance()
            .then((prefs) => prefs.getBool('is_guest_mode') ?? false),
        builder: (context, snapshot) {
          final isGuest = snapshot.data ?? false;
          if (!isGuest) {
            return _buildNotFound(context);
          }
          return _buildGuestMockResult(context);
        },
      );
    }

    final judgmentAsync = ref.watch(judgmentResultProvider(matchId));
    final matchAsync = ref.watch(matchDetailProvider(matchId));
    final authState = ref.watch(authControllerProvider);

    final userId = authState.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
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

  /// ゲスト用のモック結果画面
  Widget _buildGuestMockResult(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ディベート終了'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 32),
              const Text(
                'お疲れ様でした！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ディベート体験は終了です',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.blue[700],
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI審査について',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AI審査機能はログインユーザーのみ利用可能です。\n\n'
                      'アカウントを作成すると、以下の機能が利用できます：',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[800],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      Icons.psychology,
                      'AIによる詳細な議論分析',
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.people,
                      '他のユーザーとのリアルタイム対戦',
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.emoji_events,
                      'ポイント獲得とランキング参加',
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.trending_up,
                      '議論スキルの成長追跡',
                      Colors.blue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ログイン / 新規登録',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  'ホームに戻る',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color.withValues(red: 0.3, green: 0.5, blue: 0.9),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: color.withValues(red: 0.2, green: 0.4, blue: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 1,
      title: Text(
        isDraw ? '引き分け' : isUserWinner ? '勝利！' : '結果発表',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// 結果カード
  Widget _buildResultCard(JudgmentResult judgment, bool isDraw) {
    return Card(
      elevation: 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDraw
              ? AppColors.surface
              : judgment.winningSide == DebateStance.pro
                  ? Colors.blue.withValues(alpha: 0.05)
                  : Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              isDraw ? Icons.handshake : Icons.star,
              size: 64,
              color: isDraw
                  ? AppColors.textTertiary
                  : judgment.winningSide == DebateStance.pro
                      ? Colors.blue
                      : Colors.red,
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
                      color: AppColors.textSecondary,
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
        Text(
          '詳細スコア',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
        Text(
          'MVP',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
        Text(
          'AI評価コメント',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (judgment.overallComment != null)
          JudgmentCommentWidget(
            comment: judgment.overallComment!,
            title: '総合評価',
            icon: Icons.assessment,
            color: AppColors.primary,
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
              backgroundColor: AppColors.primary,
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
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: 2),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('エラー')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              '判定結果が見つかりません',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('エラー')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'エラー: $error',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

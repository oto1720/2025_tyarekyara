import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/debate_event.dart';
import '../../models/debate_match.dart';
import '../../models/debate_room.dart';
import '../../providers/debate_match_provider.dart';
import '../../providers/debate_room_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/matching_status_widget.dart';
import '../../../../core/constants/app_colors.dart';

/// マッチ詳細画面（マッチング成立後）
class DebateMatchDetailPage extends ConsumerWidget {
  final String matchId;

  const DebateMatchDetailPage({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchDetailProvider(matchId));
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: matchAsync.when(
          data: (match) {
            if (match == null) {
              return _buildNotFound(context);
            }

            final userId = authState.maybeWhen(
              authenticated: (user) => user.id,
              orElse: () => null,
            );

            return _buildMatchDetail(context, ref, match, userId);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(context, error),
        ),
      ),
    );
  }

  /// マッチ詳細表示
  Widget _buildMatchDetail(
    BuildContext context,
    WidgetRef ref,
    DebateMatch match,
    String? userId,
  ) {
    // ルーム状態を監視してアクティブになったら自動遷移
    if (match.roomId != null) {
      final roomAsync = ref.watch(roomDetailProvider(match.roomId!));

      roomAsync.whenData((room) {
        if (room != null && room.status == RoomStatus.inProgress) {
          // ルームがアクティブ → ディベート画面へ自動遷移
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed(
                '/debate/room/${match.id}',
              );
            }
          });
        }
      });
    }

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, match),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuccessCard(),
                const SizedBox(height: 24),
                _buildMatchInfo(match),
                const SizedBox(height: 24),
                _buildTeamsDisplay(match, userId),
                const SizedBox(height: 24),
                _buildMatchSettings(match),
                const SizedBox(height: 24),
                _buildReadyButton(context, match),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// AppBar
  Widget _buildAppBar(BuildContext context, DebateMatch match) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 1,
      title: Text(
        'マッチング成立',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// 成功カード
  Widget _buildSuccessCard() {
    return Card(
      color: AppColors.success.withValues(alpha: 0.1),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.success, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            Text(
              'マッチングが成立しました！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '対戦相手が見つかりました\n準備ができたらディベートを開始しましょう',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// マッチ情報
  Widget _buildMatchInfo(DebateMatch match) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ja_JP');

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'マッチ情報',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.schedule,
              label: 'マッチング成立時刻',
              value: dateFormat.format(match.matchedAt),
              color: Colors.blue,
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: MatchingStatusWidget(
                    status: match.status,
                    showLabel: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// チーム表示
  Widget _buildTeamsDisplay(DebateMatch match, String? userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '対戦カード',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTeamCard(
                match.proTeam,
                '賛成チーム',
                Colors.blue,
                userId,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Icon(Icons.compare_arrows, size: 32, color: AppColors.textSecondary),
                  const SizedBox(height: 4),
                  Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildTeamCard(
                match.conTeam,
                '反対チーム',
                Colors.red,
                userId,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// チームカード
  Widget _buildTeamCard(
    DebateTeam team,
    String title,
    Color color,
    String? userId,
  ) {
    final isMyTeam = userId != null && team.memberIds.contains(userId);

    return Card(
      color: isMyTeam ? color.withOpacity(0.1) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isMyTeam ? color : AppColors.border,
          width: isMyTeam ? 3 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isMyTeam)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'あなたのチーム',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isMyTeam) const SizedBox(height: 8),
            Icon(
              team.stance == DebateStance.pro
                  ? Icons.thumb_up
                  : Icons.thumb_down,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${team.memberIds.length}人',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// マッチ設定
  Widget _buildMatchSettings(DebateMatch match) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ディベート設定',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.timer,
              label: 'ディベート時間',
              value: match.duration.displayName,
              color: Colors.orange,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.people,
              label: 'ディベート形式',
              value: match.format.displayName,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  /// 情報行
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 準備完了ボタン
  Widget _buildReadyButton(BuildContext context, DebateMatch match) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _startDebate(context, match),
        icon: const Icon(Icons.play_arrow, size: 28),
        label: const Text(
          'ディベート開始',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// ディベート開始
  void _startDebate(BuildContext context, DebateMatch match) {
    context.push('/debate/room/${match.id}');
  }

  /// 見つからない表示
  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'マッチが見つかりません',
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
    );
  }

  /// エラー表示
  Widget _buildError(BuildContext context, Object error) {
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
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/debate_event.dart';
import '../../models/debate_match.dart';
import '../../models/debate_room.dart';
import '../../providers/debate_event_provider.dart';
import '../../providers/debate_match_provider.dart';
import '../../providers/debate_room_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/matching_status_widget.dart';
import '../../../../core/constants/app_colors.dart';

/// マッチ詳細画面（マッチング成立後）
class DebateMatchDetailPage extends ConsumerStatefulWidget {
  final String matchId;

  const DebateMatchDetailPage({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<DebateMatchDetailPage> createState() =>
      _DebateMatchDetailPageState();
}

class _DebateMatchDetailPageState extends ConsumerState<DebateMatchDetailPage> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // 毎秒カウントダウンを更新
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));
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

            return _buildMatchDetail(context, match, userId);
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

    // イベント情報を取得（開始時刻を確認するため）
    final eventAsync = ref.watch(eventDetailProvider(match.eventId));

    return eventAsync.when(
      data: (event) {
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
                    _buildReadyStatus(match, userId),
                    const SizedBox(height: 24),
                    _buildReadyButton(context, match, event, userId),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) {
        // エラー時はイベント情報なしでボタンを有効化
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
                    _buildReadyStatus(match, userId),
                    const SizedBox(height: 24),
                    _buildReadyButton(context, match, null, userId),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
      color: isMyTeam ? color.withValues(alpha: 0.1) : AppColors.surface,
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

  /// 準備完了状態表示
  Widget _buildReadyStatus(DebateMatch match, String? userId) {
    // 全参加者のIDリスト
    final allParticipants = [
      ...match.proTeam.memberIds,
      ...match.conTeam.memberIds,
    ];

    // 準備完了済みの参加者数
    final readyCount = match.readyUsers.length;
    final totalCount = allParticipants.length;

    // 自分が所属するチームを判定
    final isInProTeam = match.proTeam.memberIds.contains(userId);
    final myTeam = isInProTeam ? match.proTeam : match.conTeam;
    final opponentTeam = isInProTeam ? match.conTeam : match.proTeam;

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_alt, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '準備状況',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$readyCount / $totalCount 人準備完了',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: readyCount == totalCount
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 自分のチーム
            Text(
              '自分のチーム（${myTeam.stance == DebateStance.pro ? '賛成' : '反対'}）',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...myTeam.memberIds.map((participantId) {
              final isReady = match.readyUsers.contains(participantId);
              final isMe = participantId == userId;

              return _buildParticipantRow(isReady, isMe);
            }).toList(),
            const SizedBox(height: 12),
            // 相手チーム
            Text(
              '相手チーム（${opponentTeam.stance == DebateStance.pro ? '賛成' : '反対'}）',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...opponentTeam.memberIds.map((participantId) {
              final isReady = match.readyUsers.contains(participantId);

              return _buildParticipantRow(isReady, false);
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// 参加者の準備状態行
  Widget _buildParticipantRow(bool isReady, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isReady ? AppColors.success : AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMe ? 'あなた' : '参加者',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isReady)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success,
                  width: 1,
                ),
              ),
              child: Text(
                '準備完了',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
        ],
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
  Widget _buildReadyButton(
    BuildContext context,
    DebateMatch match,
    DebateEvent? event,
    String? userId,
  ) {
    if (userId == null) {
      return const SizedBox.shrink();
    }

    // 開始時刻チェック（イベント情報がある場合）
    final now = DateTime.now();
    final canStart = event == null ||
        now.isAfter(event.scheduledAt) ||
        now.isAtSameMomentAs(event.scheduledAt);

    // 開始時刻前の場合はカウントダウン表示
    if (!canStart && event != null) {
      final timeUntilStart = event.scheduledAt.difference(now);
      final hours = timeUntilStart.inHours;
      final minutes = timeUntilStart.inMinutes.remainder(60);
      final seconds = timeUntilStart.inSeconds.remainder(60);

      return Column(
        children: [
          Card(
            color: AppColors.warning.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'ディベート開始時刻まで',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hours > 0
                        ? '$hours時間${minutes.toString().padLeft(2, '0')}分${seconds.toString().padLeft(2, '0')}秒'
                        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '開始時刻: ${DateFormat('HH:mm', 'ja_JP').format(event.scheduledAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.lock, size: 28),
              label: const Text(
                '開始時刻待機中',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textTertiary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.textTertiary,
                disabledForegroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 全参加者のIDリスト
    final allParticipants = [
      ...match.proTeam.memberIds,
      ...match.conTeam.memberIds,
    ];

    // 準備完了状態をチェック
    final isReady = match.readyUsers.contains(userId);
    final allReady = allParticipants.every((id) => match.readyUsers.contains(id));

    // 全員準備完了の場合、自動的にディベート開始
    if (allReady && match.roomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.push('/debate/room/${match.id}');
        }
      });
      return Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '全員準備完了！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ディベート画面へ遷移中...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // 自分が準備完了している場合
    if (isReady) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle, size: 28),
          label: const Text(
            '準備完了（相手の準備待ち）',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.success,
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // 準備完了ボタン
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _markAsReady(match.id, userId),
        icon: const Icon(Icons.done_all, size: 28),
        label: const Text(
          '準備完了',
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
    );
  }

  /// 準備完了をマーク
  Future<void> _markAsReady(String matchId, String userId) async {
    try {
      final repository = ref.read(debateMatchRepositoryProvider);
      await repository.markUserAsReady(matchId, userId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('準備完了の登録に失敗しました: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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

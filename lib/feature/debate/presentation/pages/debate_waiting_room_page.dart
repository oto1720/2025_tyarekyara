import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../models/debate_event.dart';
import '../../models/debate_match.dart';
import '../../providers/debate_match_provider.dart';
import '../../../auth/providers/auth_provider.dart';

/// ウェイティングルーム画面
class DebateWaitingRoomPage extends ConsumerStatefulWidget {
  final String eventId;

  const DebateWaitingRoomPage({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<DebateWaitingRoomPage> createState() =>
      _DebateWaitingRoomPageState();
}

class _DebateWaitingRoomPageState extends ConsumerState<DebateWaitingRoomPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _waitingTimeTimer;
  int _waitingSeconds = 0;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 待機時間カウンター
    _waitingTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _waitingSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _waitingTimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => null,
    );

    if (userId == null) {
      return _buildNotAuthenticated(context);
    }

    final entryAsync = ref.watch(userEntryProvider((widget.eventId, userId)));

    return Scaffold(
      body: SafeArea(
        child: entryAsync.when(
          data: (entry) {
            if (entry == null) {
              // エントリーが見つからない場合
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
              return const Center(child: CircularProgressIndicator());
            }

            // マッチング成立チェック
            if (entry.status == MatchStatus.matched && entry.matchId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed(
                    '/debate/match/${entry.matchId}',
                  );
                }
              });
              return const Center(child: CircularProgressIndicator());
            }

            return _buildWaitingRoom(context, entry, userId);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(context, error),
        ),
      ),
    );
  }

  /// ウェイティングルーム表示
  Widget _buildWaitingRoom(
    BuildContext context,
    DebateEntry entry,
    String userId,
  ) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildMatchingAnimation(),
                const SizedBox(height: 40),
                _buildStatusCard(entry),
                const SizedBox(height: 24),
                _buildWaitingTime(),
                const SizedBox(height: 24),
                _buildEntryInfo(entry),
                const SizedBox(height: 32),
                _buildTips(),
                const SizedBox(height: 32),
                _buildCancelButton(entry, userId),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ヘッダー
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.blue[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final confirm = await _showCancelConfirmDialog(context);
              if (confirm == true && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          const Expanded(
            child: Text(
              'マッチング待機中',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // IconButtonと同じ幅
        ],
      ),
    );
  }

  /// マッチングアニメーション
  Widget _buildMatchingAnimation() {
    return RotationTransition(
      turns: _animationController,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.blue[400]!,
              Colors.purple[400]!,
            ],
          ),
        ),
        child: const Icon(
          Icons.people,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  /// ステータスカード
  Widget _buildStatusCard(DebateEntry entry) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text(
                  'マッチング中',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '他の参加者を探しています\nしばらくお待ちください',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
            ),
          ],
        ),
      ),
    );
  }

  /// 待機時間表示
  Widget _buildWaitingTime() {
    final minutes = _waitingSeconds ~/ 60;
    final seconds = _waitingSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, color: Colors.orange[700]),
          const SizedBox(width: 12),
          Text(
            '待機時間: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
            ),
          ),
        ],
      ),
    );
  }

  /// エントリー情報
  Widget _buildEntryInfo(DebateEntry entry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'あなたの設定',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.timer,
              label: 'ディベート時間',
              value: entry.preferredDuration.displayName,
              color: Colors.orange,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.people,
              label: 'ディベート形式',
              value: entry.preferredFormat.displayName,
              color: Colors.purple,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.psychology,
              label: '希望する立場',
              value: entry.preferredStance.displayName,
              color: Colors.blue,
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
            style: const TextStyle(fontSize: 14, color: Colors.grey),
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

  /// Tips表示
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'マッチングのヒント',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('「どちらでも可」はマッチング率が高くなります'),
          _buildTipItem('イベント開始直前は参加者が増えます'),
          _buildTipItem('人気の時間帯は10分・2vs2形式です'),
        ],
      ),
    );
  }

  /// Tipアイテム
  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// キャンセルボタン
  Widget _buildCancelButton(DebateEntry entry, String userId) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _isCancelling
            ? null
            : () => _cancelEntry(context, entry, userId),
        icon: const Icon(Icons.cancel),
        label: const Text(
          'エントリーをキャンセル',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// キャンセル確認ダイアログ
  Future<bool?> _showCancelConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
        title: const Text('エントリーをキャンセルしますか？'),
        content: const Text(
          'マッチング待機をキャンセルしてイベント一覧に戻ります。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('戻る'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('キャンセルする'),
          ),
        ],
      ),
    );
  }

  /// エントリーキャンセル処理
  Future<void> _cancelEntry(
    BuildContext context,
    DebateEntry entry,
    String userId,
  ) async {
    final confirm = await _showCancelConfirmDialog(context);
    if (confirm != true) return;

    if (_isCancelling) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      final repository = ref.read(debateMatchRepositoryProvider);
      await repository.cancelEntry(widget.eventId, userId);

      if (!context.mounted) return;

      // 成功: イベント一覧に戻る
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;

      // エラー表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('キャンセルに失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  /// 未認証表示
  Widget _buildNotAuthenticated(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('ログインが必要です'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
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
    );
  }
}

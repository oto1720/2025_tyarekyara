import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../models/debate_match.dart';
import '../../providers/debate_match_provider.dart';
import '../../providers/debate_room_provider.dart';

/// AI判定待機画面
class DebateJudgmentWaitingPage extends ConsumerStatefulWidget {
  final String matchId;

  const DebateJudgmentWaitingPage({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<DebateJudgmentWaitingPage> createState() =>
      _DebateJudgmentWaitingPageState();
}

class _DebateJudgmentWaitingPageState
    extends ConsumerState<DebateJudgmentWaitingPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  Timer? _checkTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // 想定判定時間
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // 経過時間カウント
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });

    // 判定結果の監視
    _watchJudgmentResult();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _checkTimer?.cancel();
    super.dispose();
  }

  /// 判定結果を監視
  void _watchJudgmentResult() {
    // 定期的に判定結果をチェック
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      ref.read(judgmentResultProvider(widget.matchId)).whenData((judgment) {
        if (judgment != null) {
          timer.cancel();
          // 判定結果画面へ遷移
          Navigator.of(context).pushReplacementNamed(
            '/debate/result/${widget.matchId}',
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[400]!,
              Colors.purple[600]!,
            ],
          ),
        ),
        child: SafeArea(
          child: matchAsync.when(
            data: (match) {
              if (match == null) {
                return _buildError('マッチが見つかりません');
              }
              return _buildWaitingContent(match);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildError('エラー: $error'),
          ),
        ),
      ),
    );
  }

  /// 待機コンテンツ
  Widget _buildWaitingContent(DebateMatch match) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAIIcon(),
            const SizedBox(height: 40),
            _buildTitle(),
            const SizedBox(height: 24),
            _buildProgressIndicator(),
            const SizedBox(height: 40),
            _buildStatusCards(),
            const SizedBox(height: 40),
            _buildElapsedTime(),
            const SizedBox(height: 24),
            _buildTips(),
          ],
        ),
      ),
    );
  }

  /// AIアイコン
  Widget _buildAIIcon() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.1).animate(_pulseController),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.psychology,
          size: 70,
          color: Colors.white,
        ),
      ),
    );
  }

  /// タイトル
  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'AI判定中',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'ディベート内容を分析しています...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// プログレスインジケーター
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 回転する円形プログレス
              RotationTransition(
                turns: _progressController,
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              // 中央のパーセンテージ
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '分析中',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ステータスカード
  Widget _buildStatusCards() {
    final statuses = [
      {'icon': Icons.chat_bubble, 'label': 'メッセージ収集', 'done': true},
      {'icon': Icons.analytics, 'label': '内容分析', 'done': true},
      {'icon': Icons.assessment, 'label': '評価生成', 'done': false},
      {'icon': Icons.star, 'label': '結果確定', 'done': false},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: statuses.map((status) {
        return _buildStatusCard(
          status['icon'] as IconData,
          status['label'] as String,
          status['done'] as bool,
        );
      }).toList(),
    );
  }

  /// ステータスカード（個別）
  Widget _buildStatusCard(IconData icon, String label, bool done) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: done
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle : icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 経過時間
  Widget _buildElapsedTime() {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '経過時間: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// ヒント
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.yellow[300],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '判定について',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('AIが5つの基準で公平に評価します'),
          _buildTipItem('通常10〜20秒で判定が完了します'),
          _buildTipItem('各チームの詳細なフィードバックも提供されます'),
        ],
      ),
    );
  }

  /// ヒントアイテム
  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// エラー表示
  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }
}

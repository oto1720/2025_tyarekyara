import 'package:flutter/material.dart';
import '../../models/debate_match.dart';

/// マッチングステータス表示Widget
class MatchingStatusWidget extends StatelessWidget {
  final MatchStatus status;
  final bool showLabel;
  final double iconSize;

  const MatchingStatusWidget({
    super.key,
    required this.status,
    this.showLabel = true,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    if (showLabel) {
      return _buildWithLabel(statusInfo);
    } else {
      return _buildIconOnly(statusInfo);
    }
  }

  /// ラベル付き表示
  Widget _buildWithLabel(_StatusInfo info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: info.color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, color: info.color, size: iconSize),
          const SizedBox(width: 8),
          Text(
            info.label,
            style: TextStyle(
              color: info.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// アイコンのみ表示
  Widget _buildIconOnly(_StatusInfo info) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: info.color, width: 1.5),
      ),
      child: Icon(info.icon, color: info.color, size: iconSize),
    );
  }

  /// ステータス情報取得
  _StatusInfo _getStatusInfo() {
    switch (status) {
      case MatchStatus.waiting:
        return _StatusInfo(
          icon: Icons.hourglass_empty,
          label: '待機中',
          color: Colors.orange,
        );
      case MatchStatus.matched:
        return _StatusInfo(
          icon: Icons.check_circle,
          label: 'マッチング成立',
          color: Colors.green,
        );
      case MatchStatus.inProgress:
        return _StatusInfo(
          icon: Icons.play_circle,
          label: '進行中',
          color: Colors.blue,
        );
      case MatchStatus.completed:
        return _StatusInfo(
          icon: Icons.done_all,
          label: '完了',
          color: Colors.grey,
        );
      case MatchStatus.cancelled:
        return _StatusInfo(
          icon: Icons.cancel,
          label: 'キャンセル',
          color: Colors.red,
        );
    }
  }
}

/// ステータス情報クラス
class _StatusInfo {
  final IconData icon;
  final String label;
  final Color color;

  _StatusInfo({
    required this.icon,
    required this.label,
    required this.color,
  });
}

/// アニメーション付きマッチングインジケーター
class MatchingIndicator extends StatefulWidget {
  final String message;
  final Color color;

  const MatchingIndicator({
    super.key,
    this.message = 'マッチング中...',
    this.color = Colors.blue,
  });

  @override
  State<MatchingIndicator> createState() => _MatchingIndicatorState();
}

class _MatchingIndicatorState extends State<MatchingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _controller,
          child: Icon(
            Icons.sync,
            size: 48,
            color: widget.color,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.color,
          ),
        ),
      ],
    );
  }
}

/// マッチング成功アニメーション
class MatchSuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const MatchSuccessAnimation({
    super.key,
    this.onComplete,
  });

  @override
  State<MatchSuccessAnimation> createState() => _MatchSuccessAnimationState();
}

class _MatchSuccessAnimationState extends State<MatchSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// レベル進行度Widget
class LevelProgressWidget extends StatelessWidget {
  final int level;
  final int currentPoints;
  final int pointsToNextLevel;
  final bool showDetails;

  const LevelProgressWidget({
    super.key,
    required this.level,
    required this.currentPoints,
    required this.pointsToNextLevel,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = pointsToNextLevel > 0
        ? currentPoints / pointsToNextLevel
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getLevelColor(level),
            _getLevelColor(level).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getLevelColor(level).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildLevelBadge(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLevelTitle(level),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'レベル $level',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showDetails) ...[
            const SizedBox(height: 20),
            _buildProgressBar(progress),
            const SizedBox(height: 12),
            _buildPointsInfo(),
          ],
        ],
      ),
    );
  }

  /// レベルバッジ
  Widget _buildLevelBadge() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          '$level',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// プログレスバー
  Widget _buildProgressBar(double progress) {
    return Stack(
      children: [
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ポイント情報
  Widget _buildPointsInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$currentPoints pt',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          '次のレベルまで ${pointsToNextLevel - currentPoints} pt',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// レベル色取得
  Color _getLevelColor(int level) {
    if (level < 5) return Colors.green;
    if (level < 10) return Colors.blue;
    if (level < 20) return Colors.purple;
    if (level < 30) return Colors.orange;
    return Colors.red;
  }

  /// レベルタイトル取得
  String _getLevelTitle(int level) {
    if (level < 5) return '初心者';
    if (level < 10) return '中級者';
    if (level < 20) return '上級者';
    if (level < 30) return 'エキスパート';
    if (level < 40) return 'マスター';
    return 'レジェンド';
  }
}

/// コンパクトレベル表示Widget
class CompactLevelWidget extends StatelessWidget {
  final int level;
  final double size;

  const CompactLevelWidget({
    super.key,
    required this.level,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getLevelColor(level),
            _getLevelColor(level).withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: _getLevelColor(level).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$level',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level < 5) return Colors.green;
    if (level < 10) return Colors.blue;
    if (level < 20) return Colors.purple;
    if (level < 30) return Colors.orange;
    return Colors.red;
  }
}

/// 円形レベルプログレスWidget
class CircularLevelProgressWidget extends StatelessWidget {
  final int level;
  final int currentPoints;
  final int pointsToNextLevel;
  final double size;

  const CircularLevelProgressWidget({
    super.key,
    required this.level,
    required this.currentPoints,
    required this.pointsToNextLevel,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final progress = pointsToNextLevel > 0
        ? currentPoints / pointsToNextLevel
        : 1.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景円
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: 1.0,
              color: Colors.grey[200]!,
              strokeWidth: 8,
            ),
          ),
          // プログレス円
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress,
              color: _getLevelColor(level),
              strokeWidth: 8,
            ),
          ),
          // レベル表示
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lv',
                style: TextStyle(
                  fontSize: size * 0.12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$level',
                style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.bold,
                  color: _getLevelColor(level),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.1,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level < 5) return Colors.green;
    if (level < 10) return Colors.blue;
    if (level < 20) return Colors.purple;
    if (level < 30) return Colors.orange;
    return Colors.red;
  }
}

/// 円形プログレスペインター
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// レベルアップアニメーションWidget
class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final VoidCallback? onComplete;

  const LevelUpAnimation({
    super.key,
    required this.newLevel,
    this.onComplete,
  });

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_controller);

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: RotationTransition(
              turns: _rotationAnimation,
              child: const Icon(
                Icons.star,
                size: 100,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                const Text(
                  'レベルアップ！',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'レベル ${widget.newLevel}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

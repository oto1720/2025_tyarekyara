import 'package:flutter/material.dart';
import '../../models/user_debate_stats.dart';

/// バッジ表示Widget
class BadgeDisplayWidget extends StatelessWidget {
  final BadgeType badgeType;
  final bool earned;
  final DateTime? earnedAt;
  final VoidCallback? onTap;

  const BadgeDisplayWidget({
    super.key,
    required this.badgeType,
    this.earned = false,
    this.earnedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeInfo = _getBadgeInfo(badgeType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: earned
              ? badgeInfo.color.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: earned ? badgeInfo.color : Colors.grey[300]!,
            width: earned ? 2 : 1,
          ),
          boxShadow: earned
              ? [
                  BoxShadow(
                    color: badgeInfo.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  badgeInfo.icon,
                  size: 48,
                  color: earned ? badgeInfo.color : Colors.grey[400],
                ),
                if (!earned)
                  Icon(
                    Icons.lock,
                    size: 24,
                    color: Colors.grey[600],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              badgeInfo.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: earned ? badgeInfo.color : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (earned && earnedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(earnedAt!),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// バッジ情報取得
  _BadgeInfo _getBadgeInfo(BadgeType type) {
    switch (type) {
      case BadgeType.firstDebate:
        return _BadgeInfo(
          icon: Icons.flag,
          displayName: 'はじめの一歩',
          color: Colors.blue,
        );
      case BadgeType.tenDebates:
        return _BadgeInfo(
          icon: Icons.emoji_events,
          displayName: '10回達成',
          color: Colors.orange,
        );
      case BadgeType.firstWin:
        return _BadgeInfo(
          icon: Icons.star,
          displayName: '初勝利',
          color: Colors.amber,
        );
      case BadgeType.tenWins:
        return _BadgeInfo(
          icon: Icons.military_tech,
          displayName: '10勝達成',
          color: Colors.purple,
        );
      case BadgeType.winStreak:
        return _BadgeInfo(
          icon: Icons.local_fire_department,
          displayName: '連勝記録',
          color: Colors.red,
        );
      case BadgeType.perfectScore:
        return _BadgeInfo(
          icon: Icons.diamond,
          displayName: '完璧な論理',
          color: Colors.cyan,
        );
      case BadgeType.mvp:
        return _BadgeInfo(
          icon: Icons.workspace_premium,
          displayName: 'MVP獲得',
          color: Colors.pink,
        );
      case BadgeType.participation:
        return _BadgeInfo(
          icon: Icons.celebration,
          displayName: '皆勤賞',
          color: Colors.green,
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}

/// バッジ情報クラス
class _BadgeInfo {
  final IconData icon;
  final String displayName;
  final Color color;

  _BadgeInfo({
    required this.icon,
    required this.displayName,
    required this.color,
  });
}

/// バッジグリッド表示Widget
class BadgeGridWidget extends StatelessWidget {
  final List<EarnedBadge> earnedBadges;
  final Function(BadgeType)? onBadgeTap;

  const BadgeGridWidget({
    super.key,
    required this.earnedBadges,
    this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    final allBadges = BadgeType.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: allBadges.length,
      itemBuilder: (context, index) {
        final badgeType = allBadges[index];
        final earned = earnedBadges.any((b) => b.type == badgeType);
        final earnedBadge = earned
            ? earnedBadges.firstWhere((b) => b.type == badgeType)
            : null;

        return BadgeDisplayWidget(
          badgeType: badgeType,
          earned: earned,
          earnedAt: earnedBadge?.earnedAt,
          onTap: onBadgeTap != null ? () => onBadgeTap!(badgeType) : null,
        );
      },
    );
  }
}

/// バッジ詳細ダイアログ
class BadgeDetailDialog extends StatelessWidget {
  final BadgeType badgeType;
  final bool earned;
  final DateTime? earnedAt;

  const BadgeDetailDialog({
    super.key,
    required this.badgeType,
    this.earned = false,
    this.earnedAt,
  });

  @override
  Widget build(BuildContext context) {
    final description = _getBadgeDescription(badgeType);
    final requirement = _getBadgeRequirement(badgeType);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BadgeDisplayWidget(
              badgeType: badgeType,
              earned: earned,
              earnedAt: earnedAt,
            ),
            const SizedBox(height: 24),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      requirement,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (earned && earnedAt != null) ...[
              const SizedBox(height: 16),
              Text(
                '獲得日: ${_formatDate(earnedAt!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBadgeDescription(BadgeType type) {
    switch (type) {
      case BadgeType.firstDebate:
        return '初めてのディベートに参加したことを記念するバッジです。あなたのディベートの旅が始まりました！';
      case BadgeType.tenDebates:
        return '10回のディベートに参加した証です。継続は力なり！';
      case BadgeType.firstWin:
        return '初めての勝利を祝福するバッジです。素晴らしい議論でした！';
      case BadgeType.tenWins:
        return '10回の勝利を達成した実力者の証です。あなたの論理力は確かです！';
      case BadgeType.winStreak:
        return '3連勝を達成した栄誉あるバッジです。勢いが止まりません！';
      case BadgeType.perfectScore:
        return 'いずれかの評価項目で満点を獲得した証です。完璧な論理構成でした！';
      case BadgeType.mvp:
        return 'ディベートでMVPを獲得した証です。チームの勝利に貢献しました！';
      case BadgeType.participation:
        return '1週間連続でディベートに参加した継続力の証です。素晴らしい！';
    }
  }

  String _getBadgeRequirement(BadgeType type) {
    switch (type) {
      case BadgeType.firstDebate:
        return '獲得条件: 初めてのディベート参加';
      case BadgeType.tenDebates:
        return '獲得条件: ディベート10回参加';
      case BadgeType.firstWin:
        return '獲得条件: 初勝利';
      case BadgeType.tenWins:
        return '獲得条件: 10勝達成';
      case BadgeType.winStreak:
        return '獲得条件: 3連勝達成';
      case BadgeType.perfectScore:
        return '獲得条件: いずれかの項目で10点獲得';
      case BadgeType.mvp:
        return '獲得条件: MVP獲得';
      case BadgeType.participation:
        return '獲得条件: 1週間連続参加';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// バッジ獲得通知Widget
class BadgeEarnedNotification extends StatefulWidget {
  final BadgeType badgeType;
  final VoidCallback? onDismiss;

  const BadgeEarnedNotification({
    super.key,
    required this.badgeType,
    this.onDismiss,
  });

  @override
  State<BadgeEarnedNotification> createState() =>
      _BadgeEarnedNotificationState();
}

class _BadgeEarnedNotificationState extends State<BadgeEarnedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // 3秒後に自動で閉じる
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss?.call();
      }
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
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[100]!, Colors.orange[100]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            const Text(
              '🎉 バッジ獲得！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            BadgeDisplayWidget(
              badgeType: widget.badgeType,
              earned: true,
            ),
          ],
        ),
      ),
    );
  }
}

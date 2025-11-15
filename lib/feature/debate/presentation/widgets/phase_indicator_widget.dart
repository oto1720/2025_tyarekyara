import 'package:flutter/material.dart';
import '../../models/debate_room.dart';

/// フェーズ表示Widget
class PhaseIndicatorWidget extends StatelessWidget {
  final DebatePhase currentPhase;
  final bool isCompact;

  const PhaseIndicatorWidget({
    super.key,
    required this.currentPhase,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final phaseInfo = _getPhaseInfo();

    if (isCompact) {
      return _buildCompactView(phaseInfo);
    } else {
      return _buildFullView(phaseInfo);
    }
  }

  /// フル表示
  Widget _buildFullView(_PhaseInfo info) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            info.color.withValues(alpha: 0.8),
            info.color.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: info.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            info.icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '現在のフェーズ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// コンパクト表示
  Widget _buildCompactView(_PhaseInfo info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: info.color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, color: info.color, size: 20),
          const SizedBox(width: 8),
          Text(
            info.displayName,
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

  /// フェーズ情報取得
  _PhaseInfo _getPhaseInfo() {
    switch (currentPhase) {
      case DebatePhase.preparation:
        return _PhaseInfo(
          icon: Icons.pending,
          displayName: currentPhase.displayName,
          color: Colors.blue,
        );
      case DebatePhase.openingPro:
      case DebatePhase.openingCon:
        return _PhaseInfo(
          icon: Icons.campaign,
          displayName: currentPhase.displayName,
          color: Colors.green,
        );
      case DebatePhase.questionPro:
      case DebatePhase.questionCon:
        return _PhaseInfo(
          icon: Icons.help_outline,
          displayName: currentPhase.displayName,
          color: Colors.orange,
        );
      case DebatePhase.rebuttalPro:
      case DebatePhase.rebuttalCon:
        return _PhaseInfo(
          icon: Icons.gavel,
          displayName: currentPhase.displayName,
          color: Colors.red,
        );
      case DebatePhase.closingPro:
      case DebatePhase.closingCon:
        return _PhaseInfo(
          icon: Icons.emoji_events,
          displayName: currentPhase.displayName,
          color: Colors.purple,
        );
      case DebatePhase.judgment:
        return _PhaseInfo(
          icon: Icons.psychology,
          displayName: currentPhase.displayName,
          color: Colors.indigo,
        );
      case DebatePhase.result:
        return _PhaseInfo(
          icon: Icons.star,
          displayName: currentPhase.displayName,
          color: Colors.amber,
        );
      case DebatePhase.completed:
        return _PhaseInfo(
          icon: Icons.done_all,
          displayName: currentPhase.displayName,
          color: Colors.grey,
        );
    }
  }
}

/// フェーズ情報クラス
class _PhaseInfo {
  final IconData icon;
  final String displayName;
  final Color color;

  _PhaseInfo({
    required this.icon,
    required this.displayName,
    required this.color,
  });
}

/// フェーズプログレスバー
class PhaseProgressBar extends StatelessWidget {
  final DebatePhase currentPhase;

  const PhaseProgressBar({
    super.key,
    required this.currentPhase,
  });

  @override
  Widget build(BuildContext context) {
    final totalPhases = DebatePhase.values.length;
    final currentIndex = DebatePhase.values.indexOf(currentPhase);
    final progress = (currentIndex + 1) / totalPhases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ディベート進行状況',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${currentIndex + 1}/$totalPhases',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getPhaseColor(currentPhase),
            ),
          ),
        ),
      ],
    );
  }

  Color _getPhaseColor(DebatePhase phase) {
    if (phase == DebatePhase.preparation) return Colors.blue;
    if (phase == DebatePhase.judgment) return Colors.indigo;
    if (phase == DebatePhase.result) return Colors.amber;
    if (phase == DebatePhase.completed) return Colors.grey;
    return Colors.green;
  }
}

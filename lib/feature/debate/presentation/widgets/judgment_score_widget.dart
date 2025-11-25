import 'package:flutter/material.dart';
import '../../models/judgment_result.dart';
import '../../../../core/constants/app_colors.dart';

/// 判定スコア表示Widget
class JudgmentScoreWidget extends StatelessWidget {
  final TeamScore teamScore;
  final String teamLabel;
  final Color teamColor;
  final bool isWinner;

  const JudgmentScoreWidget({
    super.key,
    required this.teamScore,
    required this.teamLabel,
    required this.teamColor,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isWinner ? teamColor.withValues(alpha: 0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner ? teamColor : AppColors.border,
          width: isWinner ? 3 : 1,
        ),
        boxShadow: isWinner
            ? [
                BoxShadow(
                  color: teamColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildScoreDetails(),
        ],
      ),
    );
  }

  /// ヘッダー
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: teamColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWinner ? Icons.emoji_events : Icons.groups,
            color: teamColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      teamLabel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: teamColor,
                      ),
                    ),
                    if (isWinner) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '勝利',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '合計スコア',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${teamScore.totalScore}',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: teamColor,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            ' /50',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// スコア詳細
  Widget _buildScoreDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildScoreRow(
            '論理性',
            teamScore.logicScore,
            Icons.psychology,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildScoreRow(
            '根拠・証拠',
            teamScore.evidenceScore,
            Icons.fact_check,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildScoreRow(
            '反論力',
            teamScore.rebuttalScore,
            Icons.gavel,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildScoreRow(
            '説得力',
            teamScore.persuasivenessScore,
            Icons.campaign,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildScoreRow(
            'マナー',
            teamScore.mannerScore,
            Icons.favorite,
            Colors.pink,
          ),
        ],
      ),
    );
  }

  /// スコア行
  Widget _buildScoreRow(
    String label,
    int score,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: score / 10,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '$score/10',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// MVP表示Widget
class MVPDisplayWidget extends StatelessWidget {
  final String userId;
  final String? userName;
  final Color teamColor;

  const MVPDisplayWidget({
    super.key,
    required this.userId,
    this.userName,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber[100]!,
            Colors.orange[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            size: 60,
            color: Colors.amber,
          ),
          const SizedBox(height: 12),
          const Text(
            'MVP',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: teamColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: teamColor),
            ),
            child: Text(
              userName ?? 'ユーザー',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: teamColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 判定コメントWidget
class JudgmentCommentWidget extends StatelessWidget {
  final String comment;
  final String title;
  final IconData icon;
  final Color color;

  const JudgmentCommentWidget({
    super.key,
    required this.comment,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

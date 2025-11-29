import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// ディベートルール説明画面
class DebateRulesPage extends StatelessWidget {
  const DebateRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ディベートのルール'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.gavel,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'AI審査ディベート',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AIが公平に判定し、あなたのスキルを評価します',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // AI審査基準
            _buildSection(
              context,
              title: 'AI審査の評価基準',
              icon: Icons.analytics,
              children: [
                _buildCriteriaCard(
                  icon: Icons.lightbulb_outline,
                  title: '論理性',
                  score: '10点',
                  description: '主張の論理的整合性、因果関係の明確さ',
                  color: Colors.blue,
                ),
                _buildCriteriaCard(
                  icon: Icons.article_outlined,
                  title: '根拠・証拠',
                  score: '10点',
                  description: '具体例やデータの提示、証拠の信頼性',
                  color: Colors.green,
                ),
                _buildCriteriaCard(
                  icon: Icons.security,
                  title: '反論力',
                  score: '10点',
                  description: '相手の主張への効果的な反論、対応の的確さ',
                  color: Colors.orange,
                ),
                _buildCriteriaCard(
                  icon: Icons.psychology,
                  title: '説得力',
                  score: '10点',
                  description: '表現の明確さ、聴衆を納得させる力',
                  color: Colors.purple,
                ),
                _buildCriteriaCard(
                  icon: Icons.emoji_emotions_outlined,
                  title: 'マナー',
                  score: '10点',
                  description: '礼儀正しさ、冷静さ、相手への敬意',
                  color: Colors.pink,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '合計スコア',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '全項目の合計で50点満点',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 勝利基準
            _buildSection(
              context,
              title: '勝利基準',
              icon: Icons.emoji_events,
              children: [
                _buildInfoCard(
                  icon: Icons.trending_up,
                  title: 'スコア勝負',
                  description: '合計スコアが高いチームが勝利となります',
                  color: Colors.green,
                ),
                _buildInfoCard(
                  icon: Icons.balance,
                  title: '引き分け',
                  description: '同点の場合は引き分けとなります',
                  color: Colors.grey,
                ),
                _buildInfoCard(
                  icon: Icons.workspace_premium,
                  title: 'MVP選出',
                  description: '最も優れた発言をした参加者がMVPに選ばれます',
                  color: Colors.amber,
                ),
              ],
            ),

            // ディベートの流れ
            _buildSection(
              context,
              title: 'ディベートの流れ',
              icon: Icons.timeline,
              children: [
                _buildPhaseItem('1. 準備', '1分', '作戦会議の時間'),
                _buildPhaseItem('2. 立論（賛成）', '2分', '賛成側が主張を展開'),
                _buildPhaseItem('3. 立論（反対）', '2分', '反対側が主張を展開'),
                _buildPhaseItem('4. 質疑応答準備', '30秒', '質問を準備'),
                _buildPhaseItem('5. 質疑応答', '各1分', '相手チームへの質問'),
                _buildPhaseItem('6. 反論準備', '30秒', '反論を準備'),
                _buildPhaseItem('7. 反論', '各1.5分', '相手の主張に反論'),
                _buildPhaseItem('8. 最終主張', '各1分', '総括と最終アピール'),
              ],
            ),

            // // ポイントシステム
            // _buildSection(
            //   context,
            //   title: 'ポイントシステム',
            //   icon: Icons.stars,
            //   children: [
            //     _buildPointItem('参加', '10pt', Icons.event_available),
            //     _buildPointItem('勝利', '30pt', Icons.emoji_events),
            //     _buildPointItem('引き分け', '15pt', Icons.handshake),
            //     _buildPointItem('MVP獲得', '50pt', Icons.workspace_premium),
            //     _buildPointItem('満点評価項目', '20pt', Icons.star),
            //     _buildPointItem(
            //         '連勝ボーナス', '10pt × 連勝数', Icons.local_fire_department),
            //   ],
            // ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCriteriaCard({
    required IconData icon,
    required String title,
    required String score,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          score,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseItem(String phase, String duration, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      phase,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointItem(String action, String points, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Text(
            points,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

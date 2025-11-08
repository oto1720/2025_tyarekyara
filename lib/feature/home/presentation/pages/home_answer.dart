import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/opinion.dart';
import '../../providers/opinion_provider.dart';
import '../../providers/daily_topic_provider.dart';
import '../widgets/topic_card.dart';

/// 意見一覧画面
class OpinionListScreen extends ConsumerWidget {
  final String topicId;

  const OpinionListScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opinionState = ref.watch(opinionListProvider(topicId));
    final opinionNotifier = ref.read(opinionListProvider(topicId).notifier);
    final postState = ref.watch(opinionPostProvider(topicId));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black87),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          '意見一覧',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // 自分の投稿へのリンク（投稿済みの場合のみ表示）
          if (postState.hasPosted)
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.black87),
              tooltip: '自分の投稿を見る',
              onPressed: () {
                context.push('/my-opinion/$topicId');
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => opinionNotifier.refresh(),
          ),
        ],
      ),
      body: _buildBody(context, ref, opinionState, opinionNotifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    OpinionListState state,
    OpinionListNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildErrorView(state.error!, notifier);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: CustomScrollView(
        slivers: [
          // トピックセクション
          SliverList(
            delegate: SliverChildListDelegate([
              _buildTopicSection(ref),
              const SizedBox(height: 8),
            ]),
          ),

          // 統計セクション
          SliverList(
            delegate: SliverChildListDelegate([
              _buildStatsSection(state),
              const SizedBox(height: 16),
            ]),
          ),

          // 空の場合
          if (state.opinions.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyView(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final opinion = state.opinions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OpinionCard(
                        opinion: opinion,
                        topicId: topicId,
                      ),
                    );
                  },
                  childCount: state.opinions.length,
                ),
              ),
            ),

          // 空の場合
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSection(WidgetRef ref) {
    final topicState = ref.watch(dailyTopicProvider);
    final topic = topicState.currentTopic;

    if (topic == null) {
      return const SizedBox.shrink();
    }

    return TopicCard(topic: topic);
  }

  Widget _buildStatsSection(OpinionListState state) {
    final total = state.opinions.length;
    final agreeCount = state.stanceCounts[OpinionStance.agree] ?? 0;
    final disagreeCount = state.stanceCounts[OpinionStance.disagree] ?? 0;
    final neutralCount = state.stanceCounts[OpinionStance.neutral] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '意見一覧',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'h$total',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: '賛成',
                  count: agreeCount,
                  total: total,
                  color: Colors.blue,
                  icon: Icons.thumb_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  label: '反対',
                  count: disagreeCount,
                  total: total,
                  color: Colors.red,
                  icon: Icons.thumb_down,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  label: '中立',
                  count: neutralCount,
                  total: total,
                  color: Colors.grey,
                  icon: Icons.horizontal_rule,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.comment_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '意見がありません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '意見を投稿してください',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error, OpinionListNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => notifier.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('更新'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 統計項目
class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 意見カード
class _OpinionCard extends ConsumerWidget {
  final Opinion opinion;
  final String topicId;

  const _OpinionCard({
    required this.opinion,
    required this.topicId,
  });

  Color _getStanceColor() {
    switch (opinion.stance) {
      case OpinionStance.agree:
        return Colors.blue;
      case OpinionStance.disagree:
        return Colors.red;
      case OpinionStance.neutral:
        return Colors.grey;
    }
  }

  IconData _getStanceIcon() {
    switch (opinion.stance) {
      case OpinionStance.agree:
        return Icons.thumb_up;
      case OpinionStance.disagree:
        return Icons.thumb_down;
      case OpinionStance.neutral:
        return Icons.horizontal_rule;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stanceColor = _getStanceColor();
    final currentUser = FirebaseAuth.instance.currentUser;
    final isMyOpinion = currentUser != null && opinion.userId == currentUser.uid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMyOpinion
            ? Colors.blue.shade50.withOpacity(0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMyOpinion
              ? Colors.blue.withOpacity(0.5)
              : stanceColor.withOpacity(0.3),
          width: isMyOpinion ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isMyOpinion
                ? Colors.blue.withOpacity(0.15)
                : Colors.grey.withOpacity(0.1),
            blurRadius: isMyOpinion ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 立場表示
          Row(
            children: [
              // 立場カード
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stanceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStanceIcon(), size: 14, color: stanceColor),
                    const SizedBox(width: 4),
                    Text(
                      opinion.stance.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: stanceColor,
                      ),
                    ),
                  ],
                ),
              ),
              // 自分の意見バッジ
              if (isMyOpinion) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'あなたの意見',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // 投稿者名
              Text(
                opinion.userName,
                style: TextStyle(
                  fontSize: 12,
                  color: isMyOpinion
                      ? Colors.blue.shade700
                      : Colors.grey.shade600,
                  fontWeight: isMyOpinion
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 意見内容
          Text(
            opinion.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),

          // リアクションボタン
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReactionType.values.map((type) {
                  final key = type.key;
                  final count = opinion.reactionCounts[key] ?? 0;
                  final reactedUsersList = opinion.reactedUsers[key] ?? [];
                  final hasReacted = reactedUsersList.contains(currentUser.uid);

                  return _ReactionButton(
                    type: type,
                    count: count,
                    hasReacted: hasReacted,
                    onTap: () {
                      ref.read(opinionListProvider(topicId).notifier).toggleReaction(
                            opinionId: opinion.id,
                            type: type,
                          );
                    },
                  );
                }).toList(),
              ),
            ),

          // 投稿日時といいね数
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                _formatDate(opinion.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              if (opinion.likeCount > 0) ...[
                Icon(Icons.favorite, size: 14, color: Colors.pink.shade300),
                const SizedBox(width: 4),
                Text(
                  '${opinion.likeCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return '1分前';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}時間前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}日前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}

/// リアクションボタン
class _ReactionButton extends StatelessWidget {
  final ReactionType type;
  final int count;
  final bool hasReacted;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.type,
    required this.count,
    required this.hasReacted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasReacted
              ? Colors.blue.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasReacted
                ? Colors.blue.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: hasReacted ? FontWeight.bold : FontWeight.normal,
                  color: hasReacted ? Colors.blue : Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

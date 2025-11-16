import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/opinion.dart';
import '../../models/topic.dart';
import '../../providers/opinion_provider.dart';
import '../../providers/daily_topic_provider.dart';
import '../../repositories/daily_topic_repository.dart';
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
    final selectedDate = ref.watch(selectedDateProvider);
    final topicAsync = ref.watch(topicByDateProvider(selectedDate));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black87),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: _buildDateSelector(context, ref),
        actions: [
          // リフレッシュボタン
          topicAsync.maybeWhen(
            data: (topic) => topic != null
                ? IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.black87),
                    onPressed: () {
                      ref.read(opinionListProvider(topic.id).notifier).refresh();
                    },
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: topicAsync.when(
        data: (topic) {
          if (topic == null) {
            return _buildNoTopicView();
          }
          // 選択した日付のトピックの意見を表示
          final opinionState = ref.watch(opinionListProvider(topic.id));
          final opinionNotifier = ref.read(opinionListProvider(topic.id).notifier);
          return _buildBody(context, ref, opinionState, opinionNotifier, topic.id);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildTopicLoadErrorView(error.toString()),
      ),
    );
  }

  /// トピックが存在しない場合の表示
  Widget _buildNoTopicView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'トピックがありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'この日のトピックはまだ作成されていません',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// トピック読み込みエラー表示
  Widget _buildTopicLoadErrorView(String error) {
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
          ],
        ),
      ),
    );
  }

  /// 日付選択UI
  Widget _buildDateSelector(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateTime.now();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 前の日へ
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black87),
          onPressed: () => _goToPreviousDay(ref),
          tooltip: '前の日',
        ),
        // 日付表示（タップでDatePicker表示）
        InkWell(
          onTap: () => _showDatePicker(context, ref),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('M/d (E)', 'ja').format(selectedDate),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.calendar_today, size: 16, color: Colors.black87),
              ],
            ),
          ),
        ),
        // 次の日へ（今日より先には進めない）
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isToday ? Colors.grey.shade300 : Colors.black87,
          ),
          onPressed: isToday ? null : () => _goToNextDay(ref),
          tooltip: '次の日',
        ),
      ],
    );
  }

  /// 前の日へ移動
  void _goToPreviousDay(WidgetRef ref) {
    final currentDate = ref.read(selectedDateProvider);
    final previousDay = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day - 1,
    );
    ref.read(selectedDateProvider.notifier).setDate(previousDay);
  }

  /// 次の日へ移動
  void _goToNextDay(WidgetRef ref) {
    final currentDate = ref.read(selectedDateProvider);
    final today = DateTime.now();
    final nextDay = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day + 1,
    );

    // 今日より先には進めない
    if (nextDay.year <= today.year &&
        nextDay.month <= today.month &&
        nextDay.day <= today.day) {
      ref.read(selectedDateProvider.notifier).setDate(nextDay);
    }
  }

  /// DatePickerを表示
  Future<void> _showDatePicker(BuildContext context, WidgetRef ref) async {
    final currentDate = ref.read(selectedDateProvider);
    final today = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020, 1, 1), // 適切な過去の日付を設定
      lastDate: today, // 今日まで
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      ref.read(selectedDateProvider.notifier).setDate(selectedDate);
    }
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    OpinionListState state,
    OpinionListNotifier notifier,
    String currentTopicId,
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
              _buildTopicSection(ref, currentTopicId),
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

          // フィードバックセクション（投稿済みユーザーのみ表示）
          SliverList(
            delegate: SliverChildListDelegate([
              _buildFeedbackSection(ref, currentTopicId),
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
                        topicId: currentTopicId,
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

  Widget _buildTopicSection(WidgetRef ref, String currentTopicId) {
    final selectedDate = ref.watch(selectedDateProvider);
    final topicAsync = ref.watch(topicByDateProvider(selectedDate));

    // トピックが既にロード済みなので、単純に表示
    return topicAsync.maybeWhen(
      data: (topic) => topic != null ? TopicCard(topic: topic) : const SizedBox.shrink(),
      orElse: () => const SizedBox.shrink(),
    );
  }

  /// フィードバックセクション
  Widget _buildFeedbackSection(WidgetRef ref, String currentTopicId) {
    final postState = ref.watch(opinionPostProvider(currentTopicId));
    final currentUser = FirebaseAuth.instance.currentUser;

    // 投稿していないユーザーには表示しない
    if (!postState.hasPosted || currentUser == null) {
      return const SizedBox.shrink();
    }

    final selectedDate = ref.watch(selectedDateProvider);
    final topicAsync = ref.watch(topicByDateProvider(selectedDate));

    return topicAsync.when(
      data: (topic) {
        if (topic == null) return const SizedBox.shrink();

        return _FeedbackCard(
          topic: topic,
          selectedDate: selectedDate,
          userId: currentUser.uid,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
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

/// トピックフィードバックカード
class _FeedbackCard extends ConsumerStatefulWidget {
  final Topic topic;
  final DateTime selectedDate;
  final String userId;

  const _FeedbackCard({
    required this.topic,
    required this.selectedDate,
    required this.userId,
  });

  @override
  ConsumerState<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends ConsumerState<_FeedbackCard> {
  String? _userFeedback;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserFeedback();
  }

  @override
  void didUpdateWidget(_FeedbackCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 日付が変わったら再読み込み
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadUserFeedback();
    }
  }

  Future<void> _loadUserFeedback() async {
    final repository = ref.read(dailyTopicRepositoryProvider);
    final feedback = await repository.getUserFeedback(
      date: widget.selectedDate,
      userId: widget.userId,
    );
    if (mounted) {
      setState(() {
        _userFeedback = feedback;
      });
    }
  }

  Future<void> _submitFeedback(TopicFeedback feedback) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(dailyTopicRepositoryProvider);
      await repository.submitFeedback(
        date: widget.selectedDate,
        userId: widget.userId,
        feedbackType: feedback.key,
      );

      if (mounted) {
        setState(() {
          _userFeedback = feedback.key;
          _isSubmitting = false;
        });

        // トピックを再読み込みして最新のフィードバック数を取得
        ref.invalidate(topicByDateProvider(widget.selectedDate));

        // スナックバーで通知
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('フィードバックを送信しました: ${feedback.displayName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              Icon(Icons.feedback_outlined, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'このトピックはどうでしたか？',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '意見を投稿したあなたの評価をお聞かせください',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: TopicFeedback.values.map((feedback) {
              final count = widget.topic.feedbackCounts[feedback.key] ?? 0;
              final isSelected = _userFeedback == feedback.key;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _FeedbackButton(
                    feedback: feedback,
                    count: count,
                    isSelected: isSelected,
                    isSubmitting: _isSubmitting,
                    onTap: () => _submitFeedback(feedback),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// フィードバックボタン
class _FeedbackButton extends StatelessWidget {
  final TopicFeedback feedback;
  final int count;
  final bool isSelected;
  final bool isSubmitting;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.feedback,
    required this.count,
    required this.isSelected,
    required this.isSubmitting,
    required this.onTap,
  });

  Color _getColor() {
    switch (feedback) {
      case TopicFeedback.good:
        return Colors.green;
      case TopicFeedback.normal:
        return Colors.orange;
      case TopicFeedback.bad:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return InkWell(
      onTap: isSubmitting ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              feedback.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              feedback.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

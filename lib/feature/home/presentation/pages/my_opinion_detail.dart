import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/opinion.dart';
import '../../providers/opinion_provider.dart';
import '../../providers/daily_topic_provider.dart';

/// 自分の投稿詳細・編集画面
class MyOpinionDetailScreen extends ConsumerStatefulWidget {
  final String topicId;

  const MyOpinionDetailScreen({
    super.key,
    required this.topicId,
  });

  @override
  ConsumerState<MyOpinionDetailScreen> createState() =>
      _MyOpinionDetailScreenState();
}

class _MyOpinionDetailScreenState extends ConsumerState<MyOpinionDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _contentController;
  OpinionStance? _selectedStance;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(opinionPostProvider(widget.topicId));
    final postNotifier = ref.read(opinionPostProvider(widget.topicId).notifier);
    final topicState = ref.watch(dailyTopicProvider);
    final topic = topicState.currentTopic;

    final userOpinion = postState.userOpinion;

    if (userOpinion == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '自分の投稿',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            '投稿が見つかりませんでした',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // 編集モードでない場合、初期値を設定
    if (!_isEditing) {
      _selectedStance = userOpinion.stance;
      _contentController.text = userOpinion.content;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '自分の投稿',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('編集'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // トピック表示
            if (topic != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'トピック',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

            // 投稿内容
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '投稿内容',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 立場選択
                  const Text(
                    '立場',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    _buildStanceSelector()
                  else
                    _buildStanceDisplay(userOpinion.stance),

                  const SizedBox(height: 24),

                  // 意見内容
                  const Text(
                    '意見',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    TextField(
                      controller: _contentController,
                      maxLines: 8,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: '意見を入力してください',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    )
                  else
                    Text(
                      userOpinion.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 投稿日時
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '投稿: ${_formatDate(userOpinion.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // 編集ボタン
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: postState.isPosting
                                ? null
                                : () {
                                    setState(() {
                                      _isEditing = false;
                                      _selectedStance = userOpinion.stance;
                                      _contentController.text = userOpinion.content;
                                    });
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.border),
                              foregroundColor: AppColors.textPrimary,
                            ),
                            child: const Text('キャンセル'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: postState.isPosting ? null : _handleUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: postState.isPosting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textOnPrimary,
                                    ),
                                  )
                                : const Text(
                                    '更新',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStanceSelector() {
    return Column(
      children: [
        _buildStanceOption(
          OpinionStance.agree,
          '賛成',
          Icons.thumb_up,
          AppColors.agree,
        ),
        const SizedBox(height: 8),
        _buildStanceOption(
          OpinionStance.disagree,
          '反対',
          Icons.thumb_down,
          AppColors.disagree,
        ),
        const SizedBox(height: 8),
        _buildStanceOption(
          OpinionStance.neutral,
          '中立',
          Icons.horizontal_rule,
          AppColors.neutral,
        ),
      ],
    );
  }

  Widget _buildStanceOption(
    OpinionStance stance,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedStance == stance;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStance = stance;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20)
            else
              const Icon(Icons.circle_outlined, color: AppColors.disabled, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStanceDisplay(OpinionStance stance) {
    Color color;
    IconData icon;
    String label;

    switch (stance) {
      case OpinionStance.agree:
        color = AppColors.agree;
        icon = Icons.thumb_up;
        label = '賛成';
        break;
      case OpinionStance.disagree:
        color = AppColors.disagree;
        icon = Icons.thumb_down;
        label = '反対';
        break;
      case OpinionStance.neutral:
        color = AppColors.neutral;
        icon = Icons.horizontal_rule;
        label = '中立';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_selectedStance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('立場を選択してください')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('意見を入力してください')),
      );
      return;
    }

    final postNotifier = ref.read(opinionPostProvider(widget.topicId).notifier);
    final success = await postNotifier.updateOpinion(
      stance: _selectedStance!,
      content: _contentController.text.trim(),
    );

    if (success) {
      setState(() {
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('投稿を更新しました'),
            backgroundColor: AppColors.success,
          ),
        );
        // 意見一覧を更新
        ref.read(opinionListProvider(widget.topicId).notifier).refresh();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: ${ref.read(opinionPostProvider(widget.topicId)).error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}

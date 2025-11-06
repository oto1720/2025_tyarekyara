import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '自分の投稿',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: Text('投稿が見つかりませんでした'),
        ),
      );
    }

    // 編集モードでない場合、初期値を設定
    if (!_isEditing) {
      _selectedStance = userOpinion.stance;
      _contentController.text = userOpinion.content;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '自分の投稿',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
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
                foregroundColor: Colors.blue,
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
                    const Text(
                      'トピック',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
                  const Text(
                    '投稿内容',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 立場選択
                  const Text(
                    '立場',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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
                      color: Colors.grey,
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    )
                  else
                    Text(
                      userOpinion.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 投稿日時
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '投稿: ${_formatDate(userOpinion.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
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
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: const Text('キャンセル'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: postState.isPosting ? null : _handleUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: postState.isPosting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '更新',
                                    style: TextStyle(
                                      color: Colors.white,
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
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildStanceOption(
          OpinionStance.disagree,
          '反対',
          Icons.thumb_down,
          Colors.red,
        ),
        const SizedBox(height: 8),
        _buildStanceOption(
          OpinionStance.neutral,
          '中立',
          Icons.horizontal_rule,
          Colors.grey,
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
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
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
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 20),
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
        color = Colors.blue;
        icon = Icons.thumb_up;
        label = '賛成';
        break;
      case OpinionStance.disagree:
        color = Colors.red;
        icon = Icons.thumb_down;
        label = '反対';
        break;
      case OpinionStance.neutral:
        color = Colors.grey;
        icon = Icons.horizontal_rule;
        label = '中立';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
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

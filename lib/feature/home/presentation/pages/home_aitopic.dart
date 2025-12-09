import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/topic.dart';
import '../../providers/topic_generation_provider.dart';
import '../../repositories/ai_repository.dart';

class AITopicHomeScreen extends ConsumerStatefulWidget {
  const AITopicHomeScreen({super.key});

  @override
  ConsumerState<AITopicHomeScreen> createState() => _AITopicHomeScreenState();
}

class _AITopicHomeScreenState extends ConsumerState<AITopicHomeScreen> {
  bool _isGuestMode = false;

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGuestMode = prefs.getBool('is_guest_mode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(topicGenerationProvider);
    final notifier = ref.read(topicGenerationProvider.notifier);
    final aiProvider = ref.watch(aiProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIトピック生成'),
        actions: [
          // AIプロバイダー切り替え
          PopupMenuButton<AIProvider>(
            icon: const Icon(Icons.settings),
            onSelected: (provider) {
              ref.read(aiProviderProvider.notifier).update(provider);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AIProvider.openai,
                child: Text('OpenAI (GPT-4)'),
              ),
              const PopupMenuItem(
                value: AIProvider.claude,
                child: Text('Anthropic (Claude)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // AI プロバイダー表示
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smart_toy, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  '使用中: ${aiProvider == AIProvider.openai ? "OpenAI GPT-4" : "Claude"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // エラー表示
          if (state.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => notifier.clearError(),
                  ),
                ],
              ),
            ),

          // 現在のトピック表示
          Expanded(
            child: state.currentTopic != null
                ? _TopicDisplay(topic: state.currentTopic!)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'トピックを生成してください',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // 生成ボタンエリア
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // カテゴリ別生成ボタン
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: TopicCategory.values.map((category) {
                    return _CategoryButton(
                      category: category,
                      onPressed: state.isGenerating
                          ? null
                          : () => notifier.generateTopic(category: category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // ランダム生成ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isGenerating
                        ? null
                        : () => notifier.generateTopic(),
                    icon: state.isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      state.isGenerating ? '生成中...' : 'ランダムに生成',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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

/// トピック表示ウィジェット
class _TopicDisplay extends StatelessWidget {
  final Topic topic;

  const _TopicDisplay({required this.topic});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カテゴリと難易度のバッジ
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                label: topic.category.displayName,
                color: _getCategoryColor(topic.category),
                icon: Icons.category,
              ),
              _Badge(
                label: topic.difficulty.displayName,
                color: _getDifficultyColor(topic.difficulty),
                icon: Icons.speed,
              ),
              if (topic.source == TopicSource.ai)
                _Badge(
                  label: 'AI生成',
                  color: Colors.purple,
                  icon: Icons.smart_toy,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // トピックテキスト
          Card(
            elevation: 0,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                topic.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // タグ表示
          if (topic.tags.isNotEmpty) ...[
            const Text(
              'タグ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topic.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.grey.shade100,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // 類似度スコア（開発用）
          if (topic.similarityScore > 0) ...[
            Text(
              '類似度スコア: ${(topic.similarityScore * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (topic.similarityScore > 0.8)
              Text(
                '⚠ 既存のトピックと類似している可能性があります',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],

          // 生成日時
          const SizedBox(height: 8),
          Text(
            '生成日時: ${_formatDateTime(topic.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(TopicCategory category) {
    switch (category) {
      case TopicCategory.daily:
        return Colors.green;
      case TopicCategory.social:
        return Colors.blue;
      case TopicCategory.value:
        return Colors.orange;
    }
  }

  Color _getDifficultyColor(TopicDifficulty difficulty) {
    switch (difficulty) {
      case TopicDifficulty.easy:
        return Colors.teal;
      case TopicDifficulty.medium:
        return Colors.amber;
      case TopicDifficulty.hard:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// カテゴリボタン
class _CategoryButton extends StatelessWidget {
  final TopicCategory category;
  final VoidCallback? onPressed;

  const _CategoryButton({
    required this.category,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(_getCategoryIcon(category), size: 18),
      label: Text(category.displayName),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(TopicCategory category) {
    switch (category) {
      case TopicCategory.daily:
        return Icons.home;
      case TopicCategory.social:
        return Icons.public;
      case TopicCategory.value:
        return Icons.psychology;
    }
  }
}

/// バッジウィジェット
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

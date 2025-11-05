import 'package:flutter/material.dart';
import '../../models/topic.dart';

/// カテゴリー付きトピックカード
class TopicCard extends StatelessWidget {
  final Topic topic;
  final String? dateText; // オプションで日付テキストをオーバーライド可能

  const TopicCard({
    Key? key,
    required this.topic,
    this.dateText,
  }) : super(key: key);

  /// カテゴリーに応じたテーマカラーを返す
  Color getCategoryColor() {
    switch (topic.category) {
      case TopicCategory.social:
        return Colors.blue;
      case TopicCategory.value:
        return Colors.orange;
      case TopicCategory.daily:
        return Colors.green;
    }
  }

  /// カテゴリーに応じたアイコンを返す
  IconData getCategoryIcon() {
    switch (topic.category) {
      case TopicCategory.social:
        return Icons.public;
      case TopicCategory.value:
        return Icons.psychology;
      case TopicCategory.daily:
        return Icons.home;
    }
  }

  /// 難易度に応じたカラーを返す
  Color getDifficultyColor() {
    switch (topic.difficulty) {
      case TopicDifficulty.easy:
        return Colors.teal;
      case TopicDifficulty.medium:
        return Colors.amber;
      case TopicDifficulty.hard:
        return Colors.red;
    }
  }

  /// 日付テキストを生成
  String _getDateText() {
    if (dateText != null) return dateText!;

    final date = topic.createdAt;
    return '${date.year}年${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = getCategoryColor();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カテゴリーと難易度バッジ
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // カテゴリーバッジ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(getCategoryIcon(), size: 12, color: categoryColor),
                    const SizedBox(width: 4),
                    Text(
                      topic.category.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: categoryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 難易度バッジ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getDifficultyColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.speed, size: 12, color: getDifficultyColor()),
                    const SizedBox(width: 4),
                    Text(
                      topic.difficulty.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: getDifficultyColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // AI生成バッジ
              if (topic.source == TopicSource.ai)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.smart_toy, size: 12, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text(
                        'AI生成',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 投稿日時
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                _getDateText(),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // トピックテキスト
          Text(
            topic.text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          // 説明（オプション）
          if (topic.description != null) ...[
            const SizedBox(height: 12),
            Text(
              topic.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
          ],

          // タグ
          if (topic.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: topic.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

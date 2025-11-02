import '../models/topic.dart';

/// トピックの重複検出サービス
class TopicDuplicateDetector {
  /// 2つのトピック間の類似度を計算（0.0～1.0）
  double calculateSimilarity(String topic1, String topic2) {
    // 基本的な類似度計算：レーベンシュタイン距離ベース
    final distance = _levenshteinDistance(topic1, topic2);
    final maxLength = topic1.length > topic2.length ? topic1.length : topic2.length;

    if (maxLength == 0) return 1.0;

    return 1.0 - (distance / maxLength);
  }

  /// トピックと既存トピックリストの類似度をチェック
  /// 最も類似度の高いトピックのスコアを返す
  double findMaxSimilarity(String newTopic, List<Topic> existingTopics) {
    if (existingTopics.isEmpty) return 0.0;

    double maxSimilarity = 0.0;
    for (final topic in existingTopics) {
      final similarity = calculateSimilarity(newTopic, topic.text);
      if (similarity > maxSimilarity) {
        maxSimilarity = similarity;
      }
    }

    return maxSimilarity;
  }

  /// トピックが既存のトピックと重複しているかチェック
  /// threshold: 重複と判定する類似度の閾値（デフォルト0.8）
  bool isDuplicate(String newTopic, List<Topic> existingTopics,
      {double threshold = 0.8}) {
    final maxSimilarity = findMaxSimilarity(newTopic, existingTopics);
    return maxSimilarity >= threshold;
  }

  /// 最も類似しているトピックを取得
  Topic? findMostSimilarTopic(String newTopic, List<Topic> existingTopics) {
    if (existingTopics.isEmpty) return null;

    Topic? mostSimilar;
    double maxSimilarity = 0.0;

    for (final topic in existingTopics) {
      final similarity = calculateSimilarity(newTopic, topic.text);
      if (similarity > maxSimilarity) {
        maxSimilarity = similarity;
        mostSimilar = topic;
      }
    }

    return mostSimilar;
  }

  /// レーベンシュタイン距離を計算
  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final len1 = s1.length;
    final len2 = s2.length;
    final distances = List.generate(
      len1 + 1,
      (i) => List.filled(len2 + 1, 0),
    );

    for (var i = 0; i <= len1; i++) {
      distances[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      distances[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        distances[i][j] = [
          distances[i - 1][j] + 1, // 削除
          distances[i][j - 1] + 1, // 挿入
          distances[i - 1][j - 1] + cost, // 置換
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return distances[len1][len2];
  }

  /// Jaccard係数による類似度計算（単語ベース）
  double calculateJaccardSimilarity(String topic1, String topic2) {
    final words1 = _tokenize(topic1);
    final words2 = _tokenize(topic2);

    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;

    if (union == 0) return 0.0;

    return intersection / union;
  }

  /// テキストを単語に分割（簡易的な実装）
  Set<String> _tokenize(String text) {
    // 日本語の場合、文字単位で分割（本格的には形態素解析が必要）
    return text
        .replaceAll(RegExp(r'[、。？！\s]'), '')
        .split('')
        .where((c) => c.isNotEmpty)
        .toSet();
  }

  /// 複数の類似度計算手法を組み合わせた総合スコア
  double calculateCompositeSimilarity(String topic1, String topic2) {
    final levenshteinScore = calculateSimilarity(topic1, topic2);
    final jaccardScore = calculateJaccardSimilarity(topic1, topic2);

    // 2つのスコアの加重平均
    return levenshteinScore * 0.6 + jaccardScore * 0.4;
  }
}

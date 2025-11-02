import '../models/topic.dart';

/// ユーザー層
enum UserLevel {
  beginner, // 初心者：簡単な話題を好む
  intermediate, // 中級者：バランスの取れた話題を好む
  advanced, // 上級者：深い話題を好む
}

/// トピック難易度調整サービス
class TopicDifficultyAdjuster {
  /// ユーザー層に応じた難易度の配分を取得
  /// 返り値は各難易度の出現確率（合計1.0）
  Map<TopicDifficulty, double> getDifficultyDistribution(UserLevel userLevel) {
    switch (userLevel) {
      case UserLevel.beginner:
        return {
          TopicDifficulty.easy: 0.6,
          TopicDifficulty.medium: 0.3,
          TopicDifficulty.hard: 0.1,
        };
      case UserLevel.intermediate:
        return {
          TopicDifficulty.easy: 0.3,
          TopicDifficulty.medium: 0.5,
          TopicDifficulty.hard: 0.2,
        };
      case UserLevel.advanced:
        return {
          TopicDifficulty.easy: 0.1,
          TopicDifficulty.medium: 0.3,
          TopicDifficulty.hard: 0.6,
        };
    }
  }

  /// 配分に基づいてランダムに難易度を選択
  TopicDifficulty selectDifficulty(UserLevel userLevel) {
    final distribution = getDifficultyDistribution(userLevel);
    final random = DateTime.now().millisecondsSinceEpoch % 100 / 100.0;

    double cumulative = 0.0;
    for (final entry in distribution.entries) {
      cumulative += entry.value;
      if (random < cumulative) {
        return entry.key;
      }
    }

    return TopicDifficulty.medium; // フォールバック
  }

  /// トピックの難易度を評価（テキストベース）
  TopicDifficulty evaluateDifficulty(String topicText) {
    final lowerText = topicText.toLowerCase();

    // キーワードベースの簡易評価
    if (_containsHardKeywords(lowerText)) {
      return TopicDifficulty.hard;
    } else if (_containsEasyKeywords(lowerText)) {
      return TopicDifficulty.easy;
    }

    return TopicDifficulty.medium;
  }

  /// 難しいトピックを示すキーワードを含むか
  bool _containsHardKeywords(String text) {
    final hardKeywords = [
      'なぜ',
      '理由',
      '根拠',
      '原因',
      '影響',
      '解決',
      '問題',
      'べき',
      '倫理',
      '道徳',
      '哲学',
      '正義',
    ];

    return hardKeywords.any((keyword) => text.contains(keyword));
  }

  /// 簡単なトピックを示すキーワードを含むか
  bool _containsEasyKeywords(String text) {
    final easyKeywords = [
      '好き',
      '嫌い',
      '選ぶなら',
      'どっち',
      '派',
      'あなたは',
      '好み',
    ];

    return easyKeywords.any((keyword) => text.contains(keyword));
  }

  /// ユーザーのフィードバックに基づいてユーザー層を更新
  /// feedbackScore: -1（難しすぎる）、0（適切）、1（簡単すぎる）
  UserLevel adjustUserLevel(UserLevel currentLevel, int feedbackScore) {
    if (feedbackScore > 0) {
      // 簡単すぎる → レベルアップ
      switch (currentLevel) {
        case UserLevel.beginner:
          return UserLevel.intermediate;
        case UserLevel.intermediate:
          return UserLevel.advanced;
        case UserLevel.advanced:
          return UserLevel.advanced; // 最大
      }
    } else if (feedbackScore < 0) {
      // 難しすぎる → レベルダウン
      switch (currentLevel) {
        case UserLevel.beginner:
          return UserLevel.beginner; // 最小
        case UserLevel.intermediate:
          return UserLevel.beginner;
        case UserLevel.advanced:
          return UserLevel.intermediate;
      }
    }

    return currentLevel; // 適切な場合は変更なし
  }

  /// トピックセットの難易度バランスをチェック
  /// 理想的な配分からの乖離度を返す（0.0が完璧、1.0が最悪）
  double checkBalance(List<Topic> topics, UserLevel targetLevel) {
    if (topics.isEmpty) return 0.0;

    final targetDistribution = getDifficultyDistribution(targetLevel);
    final actualCount = <TopicDifficulty, int>{
      TopicDifficulty.easy: 0,
      TopicDifficulty.medium: 0,
      TopicDifficulty.hard: 0,
    };

    for (final topic in topics) {
      actualCount[topic.difficulty] = (actualCount[topic.difficulty] ?? 0) + 1;
    }

    final actualDistribution = actualCount.map(
      (difficulty, count) => MapEntry(difficulty, count / topics.length),
    );

    // 各難易度の配分の差の絶対値の合計
    double totalDifference = 0.0;
    for (final difficulty in TopicDifficulty.values) {
      final target = targetDistribution[difficulty] ?? 0.0;
      final actual = actualDistribution[difficulty] ?? 0.0;
      totalDifference += (target - actual).abs();
    }

    return totalDifference / 2; // 正規化（最大値は1.0）
  }
}

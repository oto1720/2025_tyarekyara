import 'dart:math';
import '../models/topic.dart';

/// トピックのカテゴリーと難易度をランダムに選択するユーティリティ
class RandomTopicSelector {
  final Random _random = Random();

  /// カテゴリーをランダムに選択
  /// 確率:
  /// - 日常系: 40%
  /// - 社会問題系: 35%
  /// - 価値観系: 25%
  TopicCategory selectRandomCategory() {
    final rand = _random.nextDouble();

    if (rand < 0.40) {
      return TopicCategory.daily;
    } else if (rand < 0.75) {
      return TopicCategory.social;
    } else {
      return TopicCategory.value;
    }
  }

  /// 難易度をランダムに選択
  /// 確率:
  /// - 簡単: 45%
  /// - 中程度: 35%
  /// - 難しい: 20%
  TopicDifficulty selectRandomDifficulty() {
    final rand = _random.nextDouble();

    if (rand < 0.45) {
      return TopicDifficulty.easy;
    } else if (rand < 0.80) {
      return TopicDifficulty.medium;
    } else {
      return TopicDifficulty.hard;
    }
  }

  /// カテゴリーと難易度の両方をランダムに選択
  ({TopicCategory category, TopicDifficulty difficulty}) selectRandom() {
    return (
      category: selectRandomCategory(),
      difficulty: selectRandomDifficulty(),
    );
  }

  /// カスタム確率でカテゴリーを選択
  /// [weights] は [daily, social, value] の順で指定
  TopicCategory selectCategoryWithWeights(List<double> weights) {
    assert(weights.length == 3, 'weights must have 3 elements');
    assert(
      (weights.reduce((a, b) => a + b) - 1.0).abs() < 0.001,
      'weights must sum to 1.0',
    );

    final rand = _random.nextDouble();
    double sum = 0.0;

    for (int i = 0; i < weights.length; i++) {
      sum += weights[i];
      if (rand < sum) {
        return TopicCategory.values[i];
      }
    }

    return TopicCategory.values.last;
  }

  /// カスタム確率で難易度を選択
  /// [weights] は [easy, medium, hard] の順で指定
  TopicDifficulty selectDifficultyWithWeights(List<double> weights) {
    assert(weights.length == 3, 'weights must have 3 elements');
    assert(
      (weights.reduce((a, b) => a + b) - 1.0).abs() < 0.001,
      'weights must sum to 1.0',
    );

    final rand = _random.nextDouble();
    double sum = 0.0;

    for (int i = 0; i < weights.length; i++) {
      sum += weights[i];
      if (rand < sum) {
        return TopicDifficulty.values[i];
      }
    }

    return TopicDifficulty.values.last;
  }
}

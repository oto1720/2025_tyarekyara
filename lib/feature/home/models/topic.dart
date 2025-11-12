import 'package:freezed_annotation/freezed_annotation.dart';
import 'news_item.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

/// トピックのカテゴリ
enum TopicCategory {
  @JsonValue('daily')
  daily, // 日常系
  @JsonValue('social')
  social, // 社会問題系
  @JsonValue('value')
  value, // 価値観系
}

/// トピックの難易度
enum TopicDifficulty {
  @JsonValue('easy')
  easy, // 簡単（気軽に答えられる）
  @JsonValue('medium')
  medium, // 中程度（少し考える必要がある）
  @JsonValue('hard')
  hard, // 難しい（深い思考が必要）
}

/// トピックの生成元
enum TopicSource {
  @JsonValue('ai')
  ai, // AIによる生成
  @JsonValue('manual')
  manual, // 手動作成
}

/// トピックへのフィードバック種類
enum TopicFeedback {
  @JsonValue('good')
  good, // よかった
  @JsonValue('normal')
  normal, // 普通
  @JsonValue('bad')
  bad, // 悪かった
}

@freezed
class Topic with _$Topic {
  const factory Topic({
    required String id,
    required String text,
    required TopicCategory category,
    required TopicDifficulty difficulty,
    required DateTime createdAt,
    @Default(TopicSource.ai) TopicSource source,
    @Default([]) List<String> tags,
    String? description, // トピックの説明（オプション）
    @Default(0) double similarityScore, // 既存トピックとの類似度スコア
    @Default([]) List<NewsItem> relatedNews, // 関連ニュース
    @Default({}) Map<String, int> feedbackCounts, // フィードバック数 {'good': 5, 'normal': 3, 'bad': 1}
    @Default({}) Map<String, String> feedbackUsers, // ユーザーのフィードバック {userId: 'good'}
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
}

/// カテゴリの日本語名を取得
extension TopicCategoryExtension on TopicCategory {
  String get displayName {
    switch (this) {
      case TopicCategory.daily:
        return '日常系';
      case TopicCategory.social:
        return '社会問題系';
      case TopicCategory.value:
        return '価値観系';
    }
  }

  String get description {
    switch (this) {
      case TopicCategory.daily:
        return '日常生活や身近なテーマについての話題';
      case TopicCategory.social:
        return '社会問題や時事的なテーマについての話題';
      case TopicCategory.value:
        return '価値観や人生観についての深いテーマ';
    }
  }
}

/// 難易度の日本語名を取得
extension TopicDifficultyExtension on TopicDifficulty {
  String get displayName {
    switch (this) {
      case TopicDifficulty.easy:
        return '簡単';
      case TopicDifficulty.medium:
        return '中程度';
      case TopicDifficulty.hard:
        return '難しい';
    }
  }

  String get description {
    switch (this) {
      case TopicDifficulty.easy:
        return '気軽に答えられる話題';
      case TopicDifficulty.medium:
        return '少し考える必要がある話題';
      case TopicDifficulty.hard:
        return '深い思考が必要な話題';
    }
  }
}

/// フィードバックの日本語名とアイコンを取得
extension TopicFeedbackExtension on TopicFeedback {
  String get displayName {
    switch (this) {
      case TopicFeedback.good:
        return 'よかった';
      case TopicFeedback.normal:
        return '普通';
      case TopicFeedback.bad:
        return '悪かった';
    }
  }

  String get emoji {
    switch (this) {
      case TopicFeedback.good:
        return '👍';
      case TopicFeedback.normal:
        return '😐';
      case TopicFeedback.bad:
        return '👎';
    }
  }

  String get key {
    switch (this) {
      case TopicFeedback.good:
        return 'good';
      case TopicFeedback.normal:
        return 'normal';
      case TopicFeedback.bad:
        return 'bad';
    }
  }
}

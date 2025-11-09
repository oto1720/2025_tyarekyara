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

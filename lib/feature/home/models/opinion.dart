import 'package:freezed_annotation/freezed_annotation.dart';

part 'opinion.freezed.dart';
part 'opinion.g.dart';

/// 意見の立場
enum OpinionStance {
  @JsonValue('agree')
  agree, // 賛成
  @JsonValue('disagree')
  disagree, // 反対
  @JsonValue('neutral')
  neutral, // 中立
}

/// 意見モデル
@freezed
class Opinion with _$Opinion {
  const factory Opinion({
    required String id,
    required String topicId, // トピックID
    required String topicText, // トピックのテキスト（表示用）
    required String userId, // 投稿者のUID
    required String userName, // 投稿者の名前
    required OpinionStance stance, // 立場
    required String content, // 意見の内容
    required DateTime createdAt, // 投稿日時
    @Default(0) int likeCount, // いいね数
    @Default(false) bool isDeleted, // 削除フラグ
  }) = _Opinion;

  factory Opinion.fromJson(Map<String, dynamic> json) =>
      _$OpinionFromJson(json);
}

/// 立場の日本語名を取得
extension OpinionStanceExtension on OpinionStance {
  String get displayName {
    switch (this) {
      case OpinionStance.agree:
        return '賛成';
      case OpinionStance.disagree:
        return '反対';
      case OpinionStance.neutral:
        return '中立';
    }
  }

  String get emoji {
    switch (this) {
      case OpinionStance.agree:
        return '👍';
      case OpinionStance.disagree:
        return '👎';
      case OpinionStance.neutral:
        return '🤔';
    }
  }
}

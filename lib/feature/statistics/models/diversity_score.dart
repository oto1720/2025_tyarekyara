import 'package:freezed_annotation/freezed_annotation.dart';

part 'diversity_score.freezed.dart';
part 'diversity_score.g.dart';

@freezed
class DiversityScore with _$DiversityScore {
  const factory DiversityScore({
    required String userId,
    required double score,

    /// 任意の内訳（例: カテゴリ -> スコア）
    required Map<String, double> breakdown,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DiversityScore;

  factory DiversityScore.fromJson(Map<String, dynamic> json) =>
      _$DiversityScoreFromJson(json);
}

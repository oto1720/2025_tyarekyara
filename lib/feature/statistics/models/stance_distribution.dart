import 'package:freezed_annotation/freezed_annotation.dart';

part 'stance_distribution.freezed.dart';
part 'stance_distribution.g.dart';

@freezed
class StanceDistribution with _$StanceDistribution {
  const factory StanceDistribution({
    required String userId,

    /// 立場ごとのカウント（例: "賛成": 12, "反対": 5）
    required Map<String, int> counts,
    required int total,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StanceDistribution;

  factory StanceDistribution.fromJson(Map<String, dynamic> json) =>
      _$StanceDistributionFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_statistics.freezed.dart';
part 'user_statistics.g.dart';

@freezed
class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    required String userId,
    required int participationDays,
    required int totalOpinions,
    required int consecutiveDays,
    required DateTime lastParticipation,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserStatistics;

  factory UserStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserStatisticsFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_stats_model.freezed.dart';
part 'user_stats_model.g.dart';

@freezed
class UserStatsModel with _$UserStatsModel {
  const factory UserStatsModel({
    required String userId,
    @Default(0) int totalMatches,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int draws,
    @Default(0.0) double winRate,
    @Default(0) int ranking,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserStatsModel;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);
}

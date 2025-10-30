import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/user_statistics.dart';
import '../models/diversity_score.dart';
import '../models/stance_distribution.dart';
import '../models/participation_trend.dart';
import '../models/badge.dart';

part 'statistics_state.freezed.dart';

@freezed
class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    @Default(false) bool isLoading,
    UserStatistics? userStatistics,
    DiversityScore? diversityScore,
    StanceDistribution? stanceDistribution,
    ParticipationTrend? participationTrend,
    @Default(<Badge>[]) List<Badge> earnedBadges,
    String? error,
  }) = _StatisticsState;
}

import '../models/user_statistics.dart';
import '../models/diversity_score.dart';
import '../models/stance_distribution.dart';
import '../models/participation_trend.dart';

abstract class StatisticsRepository {
  Future<UserStatistics> fetchUserStatistics(String userId);
  Future<DiversityScore?> fetchDiversityScore(String userId);
  Future<StanceDistribution?> fetchStanceDistribution(String userId);
  Future<ParticipationTrend?> fetchParticipationTrend(String userId, {required int year, required int month});
}

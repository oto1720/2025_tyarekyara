import '../models/user_statistics.dart';

/// Firestore などから統計情報を取得するサービスの雛形
class StatisticsService {
  StatisticsService();

  Future<UserStatistics> fetchUserStatistics(String userId) async {
    throw UnimplementedError('fetchUserStatistics is not implemented');
  }
}

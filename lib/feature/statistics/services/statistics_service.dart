import '../models/user_statistics.dart';

/// Firestore などから統計情報を取得するサービスの雛形
class StatisticsService {
  StatisticsService();

  Future<UserStatistics> fetchUserStatistics(String userId) async {
    // TODO: 実際は Firestore クエリをここに実装
    throw UnimplementedError('fetchUserStatistics is not implemented');
  }
}

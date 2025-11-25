import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_statistics.dart';
import '../models/diversity_score.dart';
import '../models/stance_distribution.dart';
import '../models/participation_trend.dart';
import 'statistics_repository.dart';

/// Firestore統計リポジトリ
class FirestoreStatisticsRepository implements StatisticsRepository {
  final FirebaseFirestore _firestore;

  FirestoreStatisticsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserStatistics> fetchUserStatistics(String userId) async {
    try {
      print('🔍 Firestore: opinionsクエリ開始 userId=$userId');
      // opinionsコレクションからユーザーの投稿を集計
      final opinionsQuery = await _firestore
          .collection('opinions')
          .where('userId', isEqualTo: userId)
          .get();

      final opinions = opinionsQuery.docs;
      final totalOpinions = opinions.length;
      print('🔍 Firestore: ${totalOpinions}件の投稿を取得');

      // 参加日数を計算（ユニークな日付の数）
      final participationDates = <String>{};
      DateTime? lastParticipation;

      for (final doc in opinions) {
        final data = doc.data();
        final createdAtField = data['createdAt'];

        // TimestampまたはStringに対応
        final DateTime createdAt;
        if (createdAtField is Timestamp) {
          createdAt = createdAtField.toDate();
        } else if (createdAtField is String) {
          createdAt = DateTime.parse(createdAtField);
        } else {
          continue; // 不正なデータはスキップ
        }

        if (lastParticipation == null || createdAt.isAfter(lastParticipation)) {
          lastParticipation = createdAt;
        }

        final dateKey = '${createdAt.year}-${createdAt.month}-${createdAt.day}';
        participationDates.add(dateKey);
      }

      final participationDays = participationDates.length;

      // 連続参加日数を計算
      final consecutiveDays = _calculateConsecutiveDays(opinions);
      print('🔍 Firestore: participationDays=$participationDays, consecutiveDays=$consecutiveDays');

      final now = DateTime.now();
      return UserStatistics(
        userId: userId,
        participationDays: participationDays,
        totalOpinions: totalOpinions,
        consecutiveDays: consecutiveDays,
        lastParticipation: lastParticipation ?? now,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      // エラー時はデフォルト値を返す
      print('❌ Firestore fetchUserStatistics エラー: $e');
      final now = DateTime.now();
      return UserStatistics(
        userId: userId,
        participationDays: 0,
        totalOpinions: 0,
        consecutiveDays: 0,
        lastParticipation: now,
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  @override
  Future<DiversityScore?> fetchDiversityScore(String userId) async {
    try {
      // opinionsコレクションからユーザーの立場分布を取得
      final opinionsQuery = await _firestore
          .collection('opinions')
          .where('userId', isEqualTo: userId)
          .get();

      if (opinionsQuery.docs.isEmpty) return null;

      final stanceCounts = <String, int>{
        'agree': 0,
        'disagree': 0,
        'neutral': 0,
      };

      for (final doc in opinionsQuery.docs) {
        final data = doc.data();
        final stance = data['stance'] as String?;
        if (stance != null && stanceCounts.containsKey(stance)) {
          stanceCounts[stance] = (stanceCounts[stance] ?? 0) + 1;
        }
      }

      // 多様性スコアを計算（3つの立場がバランスよく分布しているほど高い）
      final total = opinionsQuery.docs.length;
      final agreeRatio = (stanceCounts['agree'] ?? 0) / total;
      final disagreeRatio = (stanceCounts['disagree'] ?? 0) / total;
      final neutralRatio = (stanceCounts['neutral'] ?? 0) / total;

      // エントロピーベースのスコア計算（0-100）
      double entropy = 0;
      for (final ratio in [agreeRatio, disagreeRatio, neutralRatio]) {
        if (ratio > 0) {
          entropy -= ratio * (ratio == 0 ? 0 : (ratio * 3.32193)); // log2(x) approximation
        }
      }
      final diversityScore = (entropy / 1.585) * 100; // 正規化（log2(3) = 1.585）

      final now = DateTime.now();
      return DiversityScore(
        userId: userId,
        score: diversityScore.clamp(0, 100),
        breakdown: {
          '議論の幅': diversityScore * 0.6,
          '情報源の多様性': diversityScore * 0.4,
        },
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<StanceDistribution?> fetchStanceDistribution(String userId) async {
    try {
      final opinionsQuery = await _firestore
          .collection('opinions')
          .where('userId', isEqualTo: userId)
          .get();

      if (opinionsQuery.docs.isEmpty) return null;

      final stanceCounts = <String, int>{
        '賛成': 0,
        '中立': 0,
        '反対': 0,
      };

      for (final doc in opinionsQuery.docs) {
        final data = doc.data();
        final stanceStr = data['stance'] as String?;

        // OpinionStance enum値を日本語に変換
        String? displayName;
        if (stanceStr == 'agree') {
          displayName = '賛成';
        } else if (stanceStr == 'disagree') {
          displayName = '反対';
        } else if (stanceStr == 'neutral') {
          displayName = '中立';
        }

        if (displayName != null) {
          stanceCounts[displayName] = (stanceCounts[displayName] ?? 0) + 1;
        }
      }

      final now = DateTime.now();
      return StanceDistribution(
        userId: userId,
        counts: stanceCounts,
        total: opinionsQuery.docs.length,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ParticipationTrend?> fetchParticipationTrend(String userId, {required int year, required int month}) async {
    try {
      // 指定月の最初の日と最後の日を計算
      final firstDayOfMonth = DateTime(year, month, 1);
      final lastDayOfMonth = DateTime(year, month + 1, 0); // 次の月の0日 = 今月の最終日

      final opinionsQuery = await _firestore
          .collection('opinions')
          .where('userId', isEqualTo: userId)
          .get();

      // 週ごとにカウント（月曜始まり）
      final countsByWeekStart = <DateTime, int>{};

      for (final doc in opinionsQuery.docs) {
        final data = doc.data();
        final createdAtField = data['createdAt'];

        // TimestampまたはStringに対応
        final DateTime createdAt;
        if (createdAtField is Timestamp) {
          createdAt = createdAtField.toDate();
        } else if (createdAtField is String) {
          createdAt = DateTime.parse(createdAtField);
        } else {
          continue; // 不正なデータはスキップ
        }

        // 指定月のデータのみカウント
        if (createdAt.isBefore(firstDayOfMonth) || createdAt.isAfter(lastDayOfMonth)) {
          continue;
        }

        // その日が属する週の月曜日を計算
        final daysSinceMonday = (createdAt.weekday - 1) % 7;
        final weekStart = createdAt.subtract(Duration(days: daysSinceMonday));
        final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

        countsByWeekStart[weekStartDate] = (countsByWeekStart[weekStartDate] ?? 0) + 1;
      }

      // 月の全週のポイントを作成
      final points = <ParticipationPoint>[];
      DateTime currentWeekStart = firstDayOfMonth.subtract(Duration(days: (firstDayOfMonth.weekday - 1) % 7));

      while (currentWeekStart.isBefore(lastDayOfMonth) || currentWeekStart.isAtSameMomentAs(lastDayOfMonth)) {
        final weekStartDate = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);
        final count = countsByWeekStart[weekStartDate] ?? 0;

        // この週が指定月に含まれるかチェック（少なくとも1日が月内にある）
        final weekEnd = weekStartDate.add(const Duration(days: 6));
        if (weekEnd.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
            weekStartDate.isBefore(lastDayOfMonth.add(const Duration(days: 1)))) {
          points.add(ParticipationPoint(date: weekStartDate, count: count));
        }

        currentWeekStart = currentWeekStart.add(const Duration(days: 7));
      }

      final now = DateTime.now();
      return ParticipationTrend(
        userId: userId,
        points: points,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      return null;
    }
  }

  /// 連続参加日数を計算
  int _calculateConsecutiveDays(List<QueryDocumentSnapshot> opinions) {
    if (opinions.isEmpty) return 0;

    // 日付のみのセットを作成
    final dates = <DateTime>{};
    for (final doc in opinions) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAtField = data['createdAt'];

      // TimestampまたはStringに対応
      final DateTime createdAt;
      if (createdAtField is Timestamp) {
        createdAt = createdAtField.toDate();
      } else if (createdAtField is String) {
        createdAt = DateTime.parse(createdAtField);
      } else {
        continue; // 不正なデータはスキップ
      }

      final dateOnly = DateTime(createdAt.year, createdAt.month, createdAt.day);
      dates.add(dateOnly);
    }

    // 日付をソート
    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));

    // 今日から連続している日数をカウント
    int consecutive = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < sortedDates.length; i++) {
      final expectedDate = todayDate.subtract(Duration(days: i));
      if (sortedDates[i].isAtSameMomentAs(expectedDate)) {
        consecutive++;
      } else {
        break;
      }
    }

    return consecutive;
  }
}

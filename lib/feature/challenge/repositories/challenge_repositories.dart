import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import '../../home/models/opinion.dart';
import '../../home/repositories/opinion_repository.dart';
import '../presentaion/widgets/difficultry_budge.dart';

/// Firestoreからチャレンジデータを取得するリポジトリ
class ChallengeRepository {
  final FirebaseFirestore _firestore;
  final OpinionRepository _opinionRepository;
  static const String _collectionName = 'userChallenges';

  ChallengeRepository({
    FirebaseFirestore? firestore,
    OpinionRepository? opinionRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _opinionRepository = opinionRepository ?? OpinionRepository();

  /// チャレンジを保存する
  Future<void> saveUserChallenge(Challenge challenge) async {
    print('💾 [Repository] ========== saveUserChallenge() 開始 ==========');
    print('   コレクション名: $_collectionName');

    try {
      final docId = '${challenge.userId}_${challenge.id}';
      print('   ドキュメントID: $docId');

      final data = challenge.toJson();
      print('   保存データ内容:');
      print('     - id: ${data['id']}');
      print('     - userId: ${data['userId']}');
      print('     - status: ${data['status']}');
      print('     - oppositeOpinionText: ${data['oppositeOpinionText']}');
      print('     - earnedPoints: ${data['earnedPoints']}');
      print('     - completedAt: ${data['completedAt']}');

      print('   Firestoreへの書き込み開始...');
      await _firestore
          .collection(_collectionName)
          .doc(docId)
          .set(data);

      print('✅ [Repository] Firestoreへの書き込み成功！');
      print('💾 [Repository] ========================================\n');
    } catch (e, stackTrace) {
      print('❌ [Repository] Firestoreへの書き込み失敗！');
      print('   エラー内容: $e');
      print('   スタックトレース: $stackTrace');
      print('💾 [Repository] ========================================\n');
      rethrow;
    }
  }

  /// ユーザーのチャレンジ一覧を取得する
  Future<List<Challenge>> getUserChallenges(String userId) async {
    print('🔍 [Repository] ========== getUserChallenges() 開始 ==========');
    print('   コレクション名: $_collectionName');
    print('   ユーザーID: $userId');

    try {
      print('   Firestoreクエリ実行中...');
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      print('   取得したドキュメント数: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('   ⚪ ドキュメントが見つかりませんでした');
        print('🔍 [Repository] ========================================\n');
        return [];
      }

      // ドキュメントの詳細を表示
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('   ドキュメント: ${doc.id}');
        print('     - status: ${data['status']}');
        print('     - oppositeOpinionText: ${data['oppositeOpinionText'] != null ? "あり(${(data['oppositeOpinionText'] as String).length}文字)" : "なし"}');
      }

      final challenges = snapshot.docs
          .map((doc) {
            try {
              return Challenge.fromJson(doc.data());
            } catch (e) {
              print('❌ [Repository] ドキュメント ${doc.id} のパースに失敗: $e');
              rethrow;
            }
          })
          .toList();

      print('   パース成功: ${challenges.length}件');

      // チャレンジを完了日時でソート
      challenges.sort((a, b) {
        if (a.status == ChallengeStatus.completed &&
            b.status == ChallengeStatus.completed) {
          // 完了日時がある場合はそれでソート
          if (a.completedAt != null && b.completedAt != null) {
            return b.completedAt!.compareTo(a.completedAt!);
          }
        }
        // チャレンジIDでソート
        return a.id.compareTo(b.id);
      });

      print('✅ [Repository] データ取得成功！返却件数: ${challenges.length}');
      print('🔍 [Repository] ========================================\n');
      return challenges;
    } catch (e, stackTrace) {
      print('❌ [Repository] エラー発生！');
      print('   エラー内容: $e');
      print('   スタックトレース: $stackTrace');
      print('🔍 [Repository] ========================================\n');
      return [];
    }
  }

  /// ユーザーの特定のチャレンジを取得する
  Future<Challenge?> getUserChallenge(String userId, String challengeId) async {
    try {
      final docId = '${userId}_$challengeId';
      final doc = await _firestore
          .collection(_collectionName)
          .doc(docId)
          .get();

      if (!doc.exists) return null;
      return Challenge.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting user challenge: $e');
      return null;
    }
  }

  /// チャレンジのステータスを更新する
  Future<void> updateChallengeStatus({
    required String userId,
    required String challengeId,
    required ChallengeStatus status,
    String? oppositeOpinionText,
    int? earnedPoints,
  }) async {
    try {
      final docId = '${userId}_$challengeId';
      final updateData = <String, dynamic>{
        'status': status.name,
      };

      if (oppositeOpinionText != null) {
        updateData['oppositeOpinionText'] = oppositeOpinionText;
      }

      if (earnedPoints != null) {
        updateData['earnedPoints'] = earnedPoints;
      }

      if (status == ChallengeStatus.completed) {
        updateData['completedAt'] = Timestamp.now();
      }

      await _firestore
          .collection(_collectionName)
          .doc(docId)
          .update(updateData);
    } catch (e) {
      print('Error updating challenge status: $e');
      rethrow;
    }
  }

  /// ユーザーのチャレンジ一覧を監視するStream
  Stream<List<Challenge>> watchUserChallenges(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final challenges = snapshot.docs
              .map((doc) => Challenge.fromJson(doc.data()))
              .toList();

          // チャレンジを完了日時でソート
          challenges.sort((a, b) {
            if (a.status == ChallengeStatus.completed &&
                b.status == ChallengeStatus.completed) {
              if (a.completedAt != null && b.completedAt != null) {
                return b.completedAt!.compareTo(a.completedAt!);
              }
            }
            return a.id.compareTo(b.id);
          });

          return challenges;
        });
  }

  /// ユーザーの完了したチャレンジ数を取得する
  Future<int> getCompletedChallengeCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: ChallengeStatus.completed.name)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting completed challenge count: $e');
      return 0;
    }
  }

  /// ユーザーの獲得ポイント合計を取得する
  Future<int> getTotalEarnedPoints(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: ChallengeStatus.completed.name)
          .get();

      int totalPoints = 0;
      for (final doc in snapshot.docs) {
        final challenge = Challenge.fromJson(doc.data());
        totalPoints += challenge.earnedPoints ?? 0;
      }

      return totalPoints;
    } catch (e) {
      print('Error getting total earned points: $e');
      return 0;
    }
  }

  /// ユーザーの投稿した意見を取得してチャレンジに変換する
  Future<List<Challenge>> getChallengesFromUserOpinions(String userId) async {
    print('🔍 [Repository] ========== getChallengesFromUserOpinions() 開始 ==========');
    print('   ユーザーID: $userId');

    try {
      // ユーザーの投稿した意見を取得
      final opinions = await _opinionRepository.getOpinionsByUser(userId);
      print('   取得した意見数: ${opinions.length}');

      // OpinionをChallengeに変換
      final challenges = opinions.map((opinion) {
        return _opinionToChallenge(opinion, userId);
      }).toList();

      print('✅ [Repository] チャレンジ変換完了: ${challenges.length}件');
      print('🔍 [Repository] ========================================\n');
      return challenges;
    } catch (e, stackTrace) {
      print('❌ [Repository] エラー発生！');
      print('   エラー内容: $e');
      print('   スタックトレース: $stackTrace');
      print('🔍 [Repository] ========================================\n');
      return [];
    }
  }

  /// OpinionをChallengeに変換する
  Challenge _opinionToChallenge(Opinion opinion, String userId) {
    // 難易度を決定（意見の文字数に応じて）
    final difficulty = _calculateDifficulty(opinion.content);

    // 元の立場を保存
    final originalStance = _opinionStanceToChallenge(opinion.stance);

    // 元の立場とは反対の立場をチャレンジとする
    final challengeStance = _getOppositeStance(opinion.stance);

    return Challenge(
      id: opinion.id, // 意見IDをチャレンジIDとして使用
      title: opinion.topicText, // トピックのテキストをタイトルに
      stance: challengeStance, // チャレンジで取るべき立場（反対）
      originalStance: originalStance, // 元の意見の立場
      difficulty: difficulty,
      originalOpinionText: opinion.content,
      userId: userId,
      status: ChallengeStatus.available,
      opinionId: opinion.id, // 元の意見IDを保存
    );
  }

  /// 意見の文字数に応じて難易度を決定
  ChallengeDifficulty _calculateDifficulty(String content) {
    final length = content.length;

    if (length < 100) {
      return ChallengeDifficulty.easy;
    } else if (length < 200) {
      return ChallengeDifficulty.normal;
    } else {
      return ChallengeDifficulty.hard;
    }
  }

  /// OpinionStanceをChallengeのStanceに変換（そのまま）
  Stance _opinionStanceToChallenge(OpinionStance opinionStance) {
    switch (opinionStance) {
      case OpinionStance.agree:
        return Stance.pro; // 賛成 → 賛成
      case OpinionStance.disagree:
        return Stance.con; // 反対 → 反対
      case OpinionStance.neutral:
        // 中立の場合は中立として扱う（仮にproとする）
        return Stance.pro;
    }
  }

  /// OpinionStanceをChallengeのStanceに変換（反対の立場）
  Stance _getOppositeStance(OpinionStance opinionStance) {
    switch (opinionStance) {
      case OpinionStance.agree:
        return Stance.con; // 賛成 → 反対
      case OpinionStance.disagree:
        return Stance.pro; // 反対 → 賛成
      case OpinionStance.neutral:
        // 中立の場合は反対にする（より明確な立場を取る練習）
        return Stance.con;
    }
  }
}

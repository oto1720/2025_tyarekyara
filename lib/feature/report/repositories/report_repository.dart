import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/report.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReportRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// 報告を作成
  Future<void> createReport({
    required String reportedUserId,
    required ReportType type,
    required String contentId,
    required ReportReason reason,
    String? details,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('ログインが必要です');
    }

    final reportId = const Uuid().v4();
    final report = Report(
      id: reportId,
      reporterId: currentUser.uid,
      reportedUserId: reportedUserId,
      type: type,
      contentId: contentId,
      reason: reason,
      details: details,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('reports').doc(reportId).set(report.toJson());
  }

  /// 既に報告済みかどうかをチェック
  Future<bool> hasReported({
    required String contentId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return false;
    }

    final snapshot = await _firestore
        .collection('reports')
        .where('reporterId', isEqualTo: currentUser.uid)
        .where('contentId', isEqualTo: contentId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// 報告の一覧を取得（管理者用）
  Future<List<Report>> getReports({
    bool? isResolved,
    int limit = 50,
  }) async {
    Query query = _firestore.collection('reports').orderBy('createdAt', descending: true);

    if (isResolved != null) {
      query = query.where('isResolved', isEqualTo: isResolved);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs
        .map((doc) => Report.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// 報告を対応済みにする（管理者用）
  Future<void> resolveReport(String reportId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('ログインが必要です');
    }

    await _firestore.collection('reports').doc(reportId).update({
      'isResolved': true,
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolvedBy': currentUser.uid,
    });
  }
}

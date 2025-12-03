import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/terms_acceptance.dart';

class TermsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TermsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // 現在の利用規約バージョン
  static const String currentVersion = '1.0.0';

  /// ユーザーが利用規約に同意したかどうかを確認
  Future<bool> hasAcceptedTerms(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('termsAcceptance')
          .doc(currentVersion)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// 利用規約への同意を記録
  Future<void> acceptTerms(String userId) async {
    final acceptance = TermsAcceptance(
      userId: userId,
      version: currentVersion,
      acceptedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('termsAcceptance')
        .doc(currentVersion)
        .set(acceptance.toJson());
  }

  /// 現在のユーザーIDを取得
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}

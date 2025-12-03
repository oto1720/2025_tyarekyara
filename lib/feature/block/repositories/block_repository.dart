import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlockRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BlockRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// ユーザーをブロック
  Future<void> blockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('ログインが必要です');
    }

    if (currentUser.uid == blockedUserId) {
      throw Exception('自分自身をブロックすることはできません');
    }

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blockedUsers')
        .doc(blockedUserId)
        .set({
      'blockedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ユーザーのブロックを解除
  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('ログインが必要です');
    }

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  /// 特定のユーザーをブロックしているかチェック
  Future<bool> isBlocked(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return false;
    }

    final doc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blockedUsers')
        .doc(userId)
        .get();

    return doc.exists;
  }

  /// ブロックしたユーザーのIDリストを取得
  Future<List<String>> getBlockedUserIds() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blockedUsers')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// ブロックしたユーザーのIDリストをストリームで取得
  Stream<List<String>> watchBlockedUserIds() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blockedUsers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}

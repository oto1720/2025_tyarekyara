import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../repositories/auth_repository.dart';
import '../models/user/user_model.dart';
import '../../settings/services/notification_service.dart';

class AuthService implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? getCurrentUser() => _auth.currentUser;

  @override
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  @override
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  @override
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'ユーザーがログインしていません';
      }
      // Firebase 10.x以降はverifyBeforeUpdateEmailを使用
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'ユーザーがログインしていません';
      }
      // 再認証してからパスワードを変更
      await reauthenticate(currentPassword);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw 'ユーザーがログインしていません';
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Googleサインインフローを開始
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // ユーザーがサインインをキャンセル
        throw 'Googleサインインがキャンセルされました';
      }

      // Google認証情報を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase認証用のクレデンシャルを作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebaseにサインイン
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Googleサインインに失敗しました: $e';
    }
  }

  @override
  Future<UserCredential> signInWithApple() async {
    try {
      // Apple Sign Inが利用可能かチェック
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw 'このデバイスではApple Sign Inを利用できません';
      }

      // Apple認証情報を取得
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Firebase認証用のOAuthクレデンシャルを作成
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Firebaseにサインイン
      return await _auth.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Apple Sign Inに失敗しました: $e';
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'User account has been disabled';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Wrong password';
      case 'too-many-requests':
        return 'Too many requests. Try again later';
      case 'network-request-failed':
        return 'Network error. Check connection';
      default:
        return 'Authentication error: ${e.message ?? "Unknown error"}';
    }
  }

  String _handleFirestoreException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Permission denied';
      case 'unavailable':
        return 'Service temporarily unavailable';
      case 'not-found':
        return 'Data not found';
      case 'already-exists':
        return 'Data already exists';
      default:
        return 'Database error: ${e.message ?? "Unknown error"}';
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'ユーザーがログインしていません';
      }

      final errors = <String>[];

      // 1. FCMトークンを削除
      try {
        await NotificationService().removeFcmToken(userId);
      } catch (e) {
        errors.add('FCMトークンの削除に失敗: $e');
      }

      // 2. Firebase Storageのプロフィール画像を削除
      try {
        final storageRef = FirebaseStorage.instance.ref();
        // 複数の画像形式を試みる
        final extensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        for (final ext in extensions) {
          try {
            final imageRef = storageRef.child('user_icons/$userId.$ext');
            await imageRef.delete();
          } catch (e) {
            // ファイルが存在しない場合はスキップ
          }
        }
      } catch (e) {
        errors.add('プロフィール画像の削除に失敗: $e');
      }

      // 3. Firestoreのデータを削除
      final batch = _firestore.batch();

      // 3-1. opinions（ユーザーの意見投稿）
      try {
        final opinionsQuery = await _firestore
            .collection('opinions')
            .where('userId', isEqualTo: userId)
            .get();
        for (final doc in opinionsQuery.docs) {
          batch.delete(doc.reference);
        }
      } catch (e) {
        errors.add('意見投稿の削除に失敗: $e');
      }

      // 3-2. userChallenges（チャレンジデータ）
      try {
        final challengesQuery = await _firestore
            .collection('userChallenges')
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: '${userId}_')
            .where(FieldPath.documentId, isLessThanOrEqualTo: '${userId}_\uf8ff')
            .get();
        for (final doc in challengesQuery.docs) {
          batch.delete(doc.reference);
        }
      } catch (e) {
        errors.add('チャレンジデータの削除に失敗: $e');
      }

      // 3-3. debateEntries（ディベートエントリー）
      try {
        final entriesQuery = await _firestore
            .collection('debateEntries')
            .where('userId', isEqualTo: userId)
            .get();
        for (final doc in entriesQuery.docs) {
          batch.delete(doc.reference);
        }
      } catch (e) {
        errors.add('ディベートエントリーの削除に失敗: $e');
      }

      // 3-4. debateStats（ディベート統計）
      try {
        final statsDoc = _firestore.collection('debateStats').doc(userId);
        batch.delete(statsDoc);
      } catch (e) {
        errors.add('ディベート統計の削除に失敗: $e');
      }

      // 3-5. users（ユーザープロフィール）
      try {
        final userDoc = _firestore.collection('users').doc(userId);
        batch.delete(userDoc);
      } catch (e) {
        errors.add('ユーザープロフィールの削除に失敗: $e');
      }

      // バッチコミット
      try {
        await batch.commit();
      } catch (e) {
        errors.add('Firestoreデータの削除に失敗: $e');
      }

      // 4. debateMatchesとdebateMessages（個別に削除）
      // 注: マッチデータは相手も関係するため、削除せずに保持する場合もある
      // ここでは完全削除を実装
      try {
        // user1.userIdまたはuser2.userIdが一致するマッチを検索
        final matchesQuery1 = await _firestore
            .collection('debateMatches')
            .where('user1.userId', isEqualTo: userId)
            .get();
        final matchesQuery2 = await _firestore
            .collection('debateMatches')
            .where('user2.userId', isEqualTo: userId)
            .get();

        final allMatches = {...matchesQuery1.docs, ...matchesQuery2.docs};
        for (final doc in allMatches) {
          // マッチに関連するメッセージも削除
          final matchId = doc.id;
          final messagesQuery = await _firestore
              .collection('debateMessages')
              .where('matchId', isEqualTo: matchId)
              .get();
          for (final msgDoc in messagesQuery.docs) {
            await msgDoc.reference.delete();
          }
          // マッチ自体を削除
          await doc.reference.delete();
        }
      } catch (e) {
        errors.add('ディベートマッチデータの削除に失敗: $e');
      }

      // 5. FirebaseAuthのアカウントを最後に削除
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw '再認証が必要です。一度ログアウトして再度ログインしてからアカウント削除を行ってください。';
        }
        throw _handleAuthException(e);
      }

      // エラーがあった場合は警告として投げる
      if (errors.isNotEmpty) {
        throw 'アカウントは削除されましたが、一部のデータ削除に失敗しました:\n${errors.join('\n')}';
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw 'アカウントの削除に失敗しました: $e';
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user/user_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  User? getCurrentUser();

  Future<void> saveUserData(UserModel user);

  Future<UserModel?> getUserData(String userId);

  Future<void> updateUserData(UserModel user);

  Future<void> updateEmail(String newEmail);

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> reauthenticate(String password);

  Future<void> sendPasswordResetEmail(String email);
}

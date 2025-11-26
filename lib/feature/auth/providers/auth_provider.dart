import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../models/user/user_model.dart';
import 'auth_state.dart';
import '../../settings/services/notification_service.dart';

final authServiceProvider = Provider<AuthRepository>((ref) {
  return AuthService();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = authService.getCurrentUser();
  if (user == null) return null;

  final userData = await authService.getUserData(user.uid);
  return userData;
});

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  AuthRepository get _authRepository => ref.read(authServiceProvider);

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  }) async {
    state = const AuthState.loading();
    try {
      final credential = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        state = const AuthState.error('Failed to create user');
        return;
      }

      final now = DateTime.now();
      final userModel = UserModel(
        id: credential.user!.uid,
        nickname: nickname,
        email: email,
        createdAt: now,
        updatedAt: now,
      );

      await _authRepository.saveUserData(userModel);

      // ゲストモードフラグをクリア
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_guest_mode');

      // FCMトークンを保存
      await NotificationService().saveFcmToken(userModel.id);

      state = AuthState.authenticated(userModel);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final credential = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        state = const AuthState.error('Failed to sign in');
        return;
      }

      final userModel = await _authRepository.getUserData(credential.user!.uid);
      if (userModel == null) {
        state = const AuthState.error('User data not found');
        return;
      }

      // ゲストモードフラグをクリア
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_guest_mode');

      // FCMトークンを保存
      await NotificationService().saveFcmToken(userModel.id);

      state = AuthState.authenticated(userModel);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      // 現在のユーザーIDを取得してFCMトークンを削除
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser != null) {
        await NotificationService().removeFcmToken(currentUser.uid);
      }

      // ゲストモードフラグをクリア
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_guest_mode');

      await _authRepository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// ゲストモードに移行
  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest_mode', true);
    state = const AuthState.guest();
  }

  Future<void> updateProfile({
    required String userId,
    required String nickname,
    String? ageRange,
    String? region,
    String? iconUrl,
  }) async {
    state = const AuthState.loading();
    try {
      final currentUser = await _authRepository.getUserData(userId);
      if (currentUser == null) {
        state = const AuthState.error('User not found');
        return;
      }

      final updatedUser = currentUser.copyWith(
        nickname: nickname,
        ageRange: ageRange ?? currentUser.ageRange,
        region: region ?? currentUser.region,
        iconUrl: iconUrl ?? currentUser.iconUrl,
        updatedAt: DateTime.now(),
      );

      await _authRepository.updateUserData(updatedUser);
      state = AuthState.authenticated(updatedUser);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> fetchUserData(String userId) async {
    state = const AuthState.loading();
    try {
      final userModel = await _authRepository.getUserData(userId);
      if (userModel == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      state = AuthState.authenticated(userModel);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

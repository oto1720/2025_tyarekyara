import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/storage_service_provider.dart';

/// プロフィール更新を管理するNotifier
class ProfileUpdateNotifier {
  final Ref ref;

  ProfileUpdateNotifier(this.ref);

  /// プロフィール情報を更新
  Future<void> updateProfile({
    required String userId,
    required String nickname,
    String? iconUrl,
    String? ageRange,
    String? region,
  }) async {
    final authRepository = ref.read(authServiceProvider);
    final currentUser = await authRepository.getUserData(userId);

    if (currentUser == null) {
      throw 'ユーザー情報が見つかりません';
    }

    final updatedUser = currentUser.copyWith(
      nickname: nickname,
      iconUrl: iconUrl ?? currentUser.iconUrl,
      ageRange: ageRange ?? currentUser.ageRange,
      region: region ?? currentUser.region,
      updatedAt: DateTime.now(),
    );

    await authRepository.updateUserData(updatedUser);

    // プロバイダーを更新してUIに反映
    ref.invalidate(currentUserProvider);
  }

  /// プロフィール画像を更新
  Future<String> updateProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final downloadUrl = await storageService.uploadProfileImage(
        userId: userId,
        imageFile: imageFile,
      );
      return downloadUrl;
    } catch (e) {
      throw 'プロフィール画像のアップロードに失敗しました: $e';
    }
  }

  /// メールアドレスを更新
  Future<void> updateEmail({
    required String userId,
    required String newEmail,
    required String currentPassword,
  }) async {
    final authRepository = ref.read(authServiceProvider);

    // 再認証
    await authRepository.reauthenticate(currentPassword);

    // Firebase Authのメールアドレスを更新
    await authRepository.updateEmail(newEmail);

    // Firestoreのユーザーデータを更新
    final currentUser = await authRepository.getUserData(userId);
    if (currentUser == null) {
      throw 'ユーザー情報が見つかりません';
    }

    final updatedUser = currentUser.copyWith(
      email: newEmail,
      updatedAt: DateTime.now(),
    );

    await authRepository.updateUserData(updatedUser);

    // プロバイダーを更新してUIに反映
    ref.invalidate(currentUserProvider);
  }

  /// パスワードを更新
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final authRepository = ref.read(authServiceProvider);
    await authRepository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

/// プロフィール更新用のProvider
final profileUpdateProvider = Provider<ProfileUpdateNotifier>((ref) {
  return ProfileUpdateNotifier(ref);
});

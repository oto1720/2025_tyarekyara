// lib/feature/settings/providers/profile_edit_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import 'profile_edit_state.dart';
import 'profile_update_provider.dart';

/// プロフィール編集フォームのNotifier
class ProfileEditNotifier extends Notifier<ProfileEditState> {
  @override
  ProfileEditState build() {
    print('=== ProfileEditNotifier.build ===');
    // 現在のユーザー情報から初期状態を作成
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) {
          print('⚠️ ユーザー情報がnull');
          return const ProfileEditState(nickname: '');
        }
        print('✅ ユーザー情報取得成功:');
        print('  - nickname: ${user.nickname}');
        print('  - ageRange: ${user.ageRange}');
        print('  - region: ${user.region}');
        print('  - iconUrl: ${user.iconUrl}');

        final state = ProfileEditState.fromUser(
          nickname: user.nickname,
          ageRange: user.ageRange.isNotEmpty ? user.ageRange : null,
          region: user.region.isNotEmpty ? user.region : null,
          iconUrl: user.iconUrl.isNotEmpty ? user.iconUrl : null,
        );

        print('  - 初期化後のstate.uploadedImageUrl: ${state.uploadedImageUrl}');
        return state;
      },
      loading: () {
        print('⏳ ユーザー情報読み込み中...');
        return const ProfileEditState(nickname: '');
      },
      error: (error, _) {
        print('❌ ユーザー情報読み込みエラー: $error');
        // エラーが発生しても空の状態を返す（エラー状態にしない）
        // エラーはユーザーがログインしていない可能性があるため
        return const ProfileEditState(nickname: '');
      },
    );
  }

  /// ニックネームを更新
  void updateNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  /// 年代を更新
  void updateAgeRange(String? ageRange) {
    state = state.copyWith(ageRange: ageRange);
  }

  /// 地域を更新
  void updateRegion(String? region) {
    state = state.copyWith(region: region);
  }

  /// 選択した画像を更新
  void updateSelectedImage(File? image) {
    state = state.copyWith(selectedImage: image);
  }

  /// パスワード編集モードを切り替え
  void togglePasswordEditing() {
    state = state.copyWith(
      isEditingPassword: !state.isEditingPassword,
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    );
  }

  /// 現在のパスワードを更新
  void updateCurrentPassword(String password) {
    state = state.copyWith(currentPassword: password);
  }

  /// 新しいパスワードを更新
  void updateNewPassword(String password) {
    state = state.copyWith(newPassword: password);
  }

  /// 確認用パスワードを更新
  void updateConfirmPassword(String password) {
    state = state.copyWith(confirmPassword: password);
  }

  /// フォームバリデーション
  ProfileEditValidation validate() {
    String? nicknameError;
    String? currentPasswordError;
    String? newPasswordError;
    String? confirmPasswordError;

    // ニックネームのバリデーション
    if (state.nickname.isEmpty) {
      nicknameError = 'ニックネームを入力してください';
    }

    // パスワード編集時のバリデーション
    if (state.isEditingPassword) {
      if (state.currentPassword.isEmpty) {
        currentPasswordError = '現在のパスワードを入力してください';
      }
      if (state.newPassword.isEmpty) {
        newPasswordError = '新しいパスワードを入力してください';
      } else if (state.newPassword.length < 6) {
        newPasswordError = 'パスワードは6文字以上にしてください';
      }
      if (state.newPassword != state.confirmPassword) {
        confirmPasswordError = 'パスワードが一致しません';
      }
    }
    return ProfileEditValidation(
      nicknameError: nicknameError,
      currentPasswordError: currentPasswordError,
      newPasswordError: newPasswordError,
      confirmPasswordError: confirmPasswordError,
    );
  }

  /// パスワードフィールドをクリア
  void clearPasswordFields() {
    state = state.copyWith(
      isEditingPassword: false,
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    );
  }
}

/// プロフィール編集フォームのProvider
final profileEditProvider =
    NotifierProvider<ProfileEditNotifier, ProfileEditState>(
  ProfileEditNotifier.new,
);

/// プロフィール保存処理のAsyncNotifier
class ProfileSaveNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 初期状態は何もしない
  }

  /// プロフィールを保存
  Future<void> save() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final editState = ref.read(profileEditProvider);
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;

      if (user == null) {
        throw 'ユーザー情報が見つかりません';
      }

      final profileUpdate = ref.read(profileUpdateProvider);

      // 1. 画像をアップロード
      String? uploadedImageUrl;
      if (editState.selectedImage != null) {
        uploadedImageUrl = await profileUpdate.updateProfileImage(
          userId: user.id,
          imageFile: editState.selectedImage!,
        );
      }

      // 3. パスワードを変更
      if (editState.isEditingPassword &&
          editState.currentPassword.isNotEmpty &&
          editState.newPassword.isNotEmpty) {
        await profileUpdate.updatePassword(
          currentPassword: editState.currentPassword,
          newPassword: editState.newPassword,
        );
      }

      // 4. プロフィール情報を更新
      await profileUpdate.updateProfile(
        userId: user.id,
        nickname: editState.nickname.trim(),
        iconUrl: uploadedImageUrl,
        ageRange: editState.ageRange,
        region: editState.region,
      );

      // パスワードフィールドをクリア
      ref.read(profileEditProvider.notifier).clearPasswordFields();
    });
  }
}

/// プロフィール保存のProvider
final profileSaveProvider = AsyncNotifierProvider<ProfileSaveNotifier, void>(
  ProfileSaveNotifier.new,
);
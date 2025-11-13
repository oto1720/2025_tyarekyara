import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_edit_state.freezed.dart';

/// プロフィール編集の状態
@freezed
class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState({
    required String nickname,
    String? ageRange,
    String? region,
    File? selectedImage,
    String? uploadedImageUrl,
    @Default(false) bool isEditingPassword,
    @Default('') String currentPassword,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
  }) = _ProfileEditState;

  factory ProfileEditState.fromUser({
    required String nickname,
    String? ageRange,
    String? region,
  }) {
    return ProfileEditState(
      nickname: nickname,
      ageRange: ageRange,
      region: region,
    );
  }
}

/// プロフィール編集のフォームバリデーション結果
@freezed
class ProfileEditValidation with _$ProfileEditValidation {
  const factory ProfileEditValidation({
    String? nicknameError,
    String? currentPasswordError,
    String? newPasswordError,
    String? confirmPasswordError,
  }) = _ProfileEditValidation;

  const ProfileEditValidation._();

  bool get isValid =>
      nicknameError == null &&
      currentPasswordError == null &&
      newPasswordError == null &&
      confirmPasswordError == null;
}

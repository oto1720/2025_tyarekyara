import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'profile_setup_state.dart';
import 'storage_service_provider.dart';
import 'auth_provider.dart';

/// プロフィール設定のNotifierProvider
final profileSetupProvider =
    NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(() {
  return ProfileSetupNotifier();
});

/// プロフィール設定のNotifier
class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  final _imagePicker = ImagePicker();

  @override
  ProfileSetupState build() {
    return const ProfileSetupState();
  }

  /// 年齢範囲を設定
  void setAgeRange(String ageRange) {
    state = state.copyWith(selectedAgeRange: ageRange);
  }

  /// 地域を設定
  void setRegion(String region) {
    state = state.copyWith(selectedRegion: region);
  }

  /// 画像を選択
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // XFileからバイトデータを読み込み、一時ディレクトリに保存
        final bytes = await pickedFile.readAsBytes();
        final tempDir = await getTemporaryDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(bytes);

        state = state.copyWith(
          selectedImage: tempFile,
          errorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: '画像の選択に失敗しました: $e',
      );
    }
  }

  /// プロフィールを保存
  Future<bool> saveProfile({
    required String nickname,
  }) async {
    // バリデーション
    if (state.selectedAgeRange == null) {
      state = state.copyWith(errorMessage: '年齢は必須です');
      return false;
    }

    if (state.selectedRegion == null) {
      state = state.copyWith(errorMessage: '地域は必須です');
      return false;
    }

    // 現在のユーザーを取得
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) {
      state = state.copyWith(errorMessage: 'ユーザーが見つかりません');
      return false;
    }

    state = state.copyWith(isUploading: true, errorMessage: null);

    try {
      String? iconUrl;

      // 画像が選択されている場合はアップロード
      if (state.selectedImage != null) {
        final storageService = ref.read(storageServiceProvider);
        iconUrl = await storageService.uploadProfileImage(
          userId: currentUser.id,
          imageFile: state.selectedImage!,
        );
      }

      // プロフィール更新
      await ref.read(authControllerProvider.notifier).updateProfile(
            userId: currentUser.id,
            nickname: nickname,
            ageRange: state.selectedAgeRange,
            region: state.selectedRegion,
            iconUrl: iconUrl,
          );

      state = state.copyWith(isUploading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'エラーが発生しました: $e',
      );
      return false;
    }
  }

  /// 現在のユーザー情報で初期化
  void initializeFromUser({
    required String nickname,
    String? ageRange,
    String? region,
  }) {
    state = state.copyWith(
      selectedAgeRange: ageRange,
      selectedRegion: region,
    );
  }

  /// エラーメッセージをクリア
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 状態をリセット
  void reset() {
    state = const ProfileSetupState();
  }
}

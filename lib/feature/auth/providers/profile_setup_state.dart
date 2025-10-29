import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_setup_state.freezed.dart';

/// プロフィール設定画面の状態
@freezed
class ProfileSetupState with _$ProfileSetupState {
  const factory ProfileSetupState({
    /// 選択された画像ファイル
    File? selectedImage,

    /// 選択された年齢範囲
    String? selectedAgeRange,

    /// 選択された地域
    String? selectedRegion,

    /// 画像アップロード中かどうか
    @Default(false) bool isUploading,

    /// エラーメッセージ
    String? errorMessage,
  }) = _ProfileSetupState;
}

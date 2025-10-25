import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/user_model.dart';

part 'auth_state.freezed.dart';

/// 認証状態を管理するFreezedクラス
@freezed
class AuthState with _$AuthState {
  /// 初期状態
  const factory AuthState.initial() = _Initial;

  /// ローディング中
  const factory AuthState.loading() = _Loading;

  /// 認証済み
  const factory AuthState.authenticated(UserModel user) = _Authenticated;

  /// 未認証
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// エラー
  const factory AuthState.error(String message) = _Error;
}

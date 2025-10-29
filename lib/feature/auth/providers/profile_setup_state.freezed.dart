// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_setup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileSetupState {
  /// 選択された画像ファイル
  File? get selectedImage => throw _privateConstructorUsedError;

  /// 選択された年齢範囲
  String? get selectedAgeRange => throw _privateConstructorUsedError;

  /// 選択された地域
  String? get selectedRegion => throw _privateConstructorUsedError;

  /// 画像アップロード中かどうか
  bool get isUploading => throw _privateConstructorUsedError;

  /// エラーメッセージ
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileSetupStateCopyWith<ProfileSetupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileSetupStateCopyWith<$Res> {
  factory $ProfileSetupStateCopyWith(
    ProfileSetupState value,
    $Res Function(ProfileSetupState) then,
  ) = _$ProfileSetupStateCopyWithImpl<$Res, ProfileSetupState>;
  @useResult
  $Res call({
    File? selectedImage,
    String? selectedAgeRange,
    String? selectedRegion,
    bool isUploading,
    String? errorMessage,
  });
}

/// @nodoc
class _$ProfileSetupStateCopyWithImpl<$Res, $Val extends ProfileSetupState>
    implements $ProfileSetupStateCopyWith<$Res> {
  _$ProfileSetupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedImage = freezed,
    Object? selectedAgeRange = freezed,
    Object? selectedRegion = freezed,
    Object? isUploading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            selectedImage: freezed == selectedImage
                ? _value.selectedImage
                : selectedImage // ignore: cast_nullable_to_non_nullable
                      as File?,
            selectedAgeRange: freezed == selectedAgeRange
                ? _value.selectedAgeRange
                : selectedAgeRange // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedRegion: freezed == selectedRegion
                ? _value.selectedRegion
                : selectedRegion // ignore: cast_nullable_to_non_nullable
                      as String?,
            isUploading: null == isUploading
                ? _value.isUploading
                : isUploading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileSetupStateImplCopyWith<$Res>
    implements $ProfileSetupStateCopyWith<$Res> {
  factory _$$ProfileSetupStateImplCopyWith(
    _$ProfileSetupStateImpl value,
    $Res Function(_$ProfileSetupStateImpl) then,
  ) = __$$ProfileSetupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    File? selectedImage,
    String? selectedAgeRange,
    String? selectedRegion,
    bool isUploading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$ProfileSetupStateImplCopyWithImpl<$Res>
    extends _$ProfileSetupStateCopyWithImpl<$Res, _$ProfileSetupStateImpl>
    implements _$$ProfileSetupStateImplCopyWith<$Res> {
  __$$ProfileSetupStateImplCopyWithImpl(
    _$ProfileSetupStateImpl _value,
    $Res Function(_$ProfileSetupStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedImage = freezed,
    Object? selectedAgeRange = freezed,
    Object? selectedRegion = freezed,
    Object? isUploading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ProfileSetupStateImpl(
        selectedImage: freezed == selectedImage
            ? _value.selectedImage
            : selectedImage // ignore: cast_nullable_to_non_nullable
                  as File?,
        selectedAgeRange: freezed == selectedAgeRange
            ? _value.selectedAgeRange
            : selectedAgeRange // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedRegion: freezed == selectedRegion
            ? _value.selectedRegion
            : selectedRegion // ignore: cast_nullable_to_non_nullable
                  as String?,
        isUploading: null == isUploading
            ? _value.isUploading
            : isUploading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ProfileSetupStateImpl implements _ProfileSetupState {
  const _$ProfileSetupStateImpl({
    this.selectedImage,
    this.selectedAgeRange,
    this.selectedRegion,
    this.isUploading = false,
    this.errorMessage,
  });

  /// 選択された画像ファイル
  @override
  final File? selectedImage;

  /// 選択された年齢範囲
  @override
  final String? selectedAgeRange;

  /// 選択された地域
  @override
  final String? selectedRegion;

  /// 画像アップロード中かどうか
  @override
  @JsonKey()
  final bool isUploading;

  /// エラーメッセージ
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ProfileSetupState(selectedImage: $selectedImage, selectedAgeRange: $selectedAgeRange, selectedRegion: $selectedRegion, isUploading: $isUploading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileSetupStateImpl &&
            (identical(other.selectedImage, selectedImage) ||
                other.selectedImage == selectedImage) &&
            (identical(other.selectedAgeRange, selectedAgeRange) ||
                other.selectedAgeRange == selectedAgeRange) &&
            (identical(other.selectedRegion, selectedRegion) ||
                other.selectedRegion == selectedRegion) &&
            (identical(other.isUploading, isUploading) ||
                other.isUploading == isUploading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedImage,
    selectedAgeRange,
    selectedRegion,
    isUploading,
    errorMessage,
  );

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileSetupStateImplCopyWith<_$ProfileSetupStateImpl> get copyWith =>
      __$$ProfileSetupStateImplCopyWithImpl<_$ProfileSetupStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProfileSetupState implements ProfileSetupState {
  const factory _ProfileSetupState({
    final File? selectedImage,
    final String? selectedAgeRange,
    final String? selectedRegion,
    final bool isUploading,
    final String? errorMessage,
  }) = _$ProfileSetupStateImpl;

  /// 選択された画像ファイル
  @override
  File? get selectedImage;

  /// 選択された年齢範囲
  @override
  String? get selectedAgeRange;

  /// 選択された地域
  @override
  String? get selectedRegion;

  /// 画像アップロード中かどうか
  @override
  bool get isUploading;

  /// エラーメッセージ
  @override
  String? get errorMessage;

  /// Create a copy of ProfileSetupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileSetupStateImplCopyWith<_$ProfileSetupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

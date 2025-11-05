// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opinion_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OpinionListState {
  List<Opinion> get opinions => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<OpinionStance, int> get stanceCounts =>
      throw _privateConstructorUsedError;

  /// Create a copy of OpinionListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpinionListStateCopyWith<OpinionListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpinionListStateCopyWith<$Res> {
  factory $OpinionListStateCopyWith(
    OpinionListState value,
    $Res Function(OpinionListState) then,
  ) = _$OpinionListStateCopyWithImpl<$Res, OpinionListState>;
  @useResult
  $Res call({
    List<Opinion> opinions,
    bool isLoading,
    String? error,
    Map<OpinionStance, int> stanceCounts,
  });
}

/// @nodoc
class _$OpinionListStateCopyWithImpl<$Res, $Val extends OpinionListState>
    implements $OpinionListStateCopyWith<$Res> {
  _$OpinionListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpinionListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? opinions = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? stanceCounts = null,
  }) {
    return _then(
      _value.copyWith(
            opinions: null == opinions
                ? _value.opinions
                : opinions // ignore: cast_nullable_to_non_nullable
                      as List<Opinion>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            stanceCounts: null == stanceCounts
                ? _value.stanceCounts
                : stanceCounts // ignore: cast_nullable_to_non_nullable
                      as Map<OpinionStance, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OpinionListStateImplCopyWith<$Res>
    implements $OpinionListStateCopyWith<$Res> {
  factory _$$OpinionListStateImplCopyWith(
    _$OpinionListStateImpl value,
    $Res Function(_$OpinionListStateImpl) then,
  ) = __$$OpinionListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Opinion> opinions,
    bool isLoading,
    String? error,
    Map<OpinionStance, int> stanceCounts,
  });
}

/// @nodoc
class __$$OpinionListStateImplCopyWithImpl<$Res>
    extends _$OpinionListStateCopyWithImpl<$Res, _$OpinionListStateImpl>
    implements _$$OpinionListStateImplCopyWith<$Res> {
  __$$OpinionListStateImplCopyWithImpl(
    _$OpinionListStateImpl _value,
    $Res Function(_$OpinionListStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OpinionListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? opinions = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? stanceCounts = null,
  }) {
    return _then(
      _$OpinionListStateImpl(
        opinions: null == opinions
            ? _value._opinions
            : opinions // ignore: cast_nullable_to_non_nullable
                  as List<Opinion>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        stanceCounts: null == stanceCounts
            ? _value._stanceCounts
            : stanceCounts // ignore: cast_nullable_to_non_nullable
                  as Map<OpinionStance, int>,
      ),
    );
  }
}

/// @nodoc

class _$OpinionListStateImpl implements _OpinionListState {
  const _$OpinionListStateImpl({
    final List<Opinion> opinions = const [],
    this.isLoading = false,
    this.error,
    final Map<OpinionStance, int> stanceCounts = const {},
  }) : _opinions = opinions,
       _stanceCounts = stanceCounts;

  final List<Opinion> _opinions;
  @override
  @JsonKey()
  List<Opinion> get opinions {
    if (_opinions is EqualUnmodifiableListView) return _opinions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_opinions);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final Map<OpinionStance, int> _stanceCounts;
  @override
  @JsonKey()
  Map<OpinionStance, int> get stanceCounts {
    if (_stanceCounts is EqualUnmodifiableMapView) return _stanceCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stanceCounts);
  }

  @override
  String toString() {
    return 'OpinionListState(opinions: $opinions, isLoading: $isLoading, error: $error, stanceCounts: $stanceCounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpinionListStateImpl &&
            const DeepCollectionEquality().equals(other._opinions, _opinions) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(
              other._stanceCounts,
              _stanceCounts,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_opinions),
    isLoading,
    error,
    const DeepCollectionEquality().hash(_stanceCounts),
  );

  /// Create a copy of OpinionListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpinionListStateImplCopyWith<_$OpinionListStateImpl> get copyWith =>
      __$$OpinionListStateImplCopyWithImpl<_$OpinionListStateImpl>(
        this,
        _$identity,
      );
}

abstract class _OpinionListState implements OpinionListState {
  const factory _OpinionListState({
    final List<Opinion> opinions,
    final bool isLoading,
    final String? error,
    final Map<OpinionStance, int> stanceCounts,
  }) = _$OpinionListStateImpl;

  @override
  List<Opinion> get opinions;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  Map<OpinionStance, int> get stanceCounts;

  /// Create a copy of OpinionListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpinionListStateImplCopyWith<_$OpinionListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OpinionPostState {
  bool get isPosting => throw _privateConstructorUsedError;
  bool get hasPosted => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Opinion? get userOpinion => throw _privateConstructorUsedError;

  /// Create a copy of OpinionPostState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpinionPostStateCopyWith<OpinionPostState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpinionPostStateCopyWith<$Res> {
  factory $OpinionPostStateCopyWith(
    OpinionPostState value,
    $Res Function(OpinionPostState) then,
  ) = _$OpinionPostStateCopyWithImpl<$Res, OpinionPostState>;
  @useResult
  $Res call({
    bool isPosting,
    bool hasPosted,
    String? error,
    Opinion? userOpinion,
  });

  $OpinionCopyWith<$Res>? get userOpinion;
}

/// @nodoc
class _$OpinionPostStateCopyWithImpl<$Res, $Val extends OpinionPostState>
    implements $OpinionPostStateCopyWith<$Res> {
  _$OpinionPostStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpinionPostState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPosting = null,
    Object? hasPosted = null,
    Object? error = freezed,
    Object? userOpinion = freezed,
  }) {
    return _then(
      _value.copyWith(
            isPosting: null == isPosting
                ? _value.isPosting
                : isPosting // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasPosted: null == hasPosted
                ? _value.hasPosted
                : hasPosted // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            userOpinion: freezed == userOpinion
                ? _value.userOpinion
                : userOpinion // ignore: cast_nullable_to_non_nullable
                      as Opinion?,
          )
          as $Val,
    );
  }

  /// Create a copy of OpinionPostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OpinionCopyWith<$Res>? get userOpinion {
    if (_value.userOpinion == null) {
      return null;
    }

    return $OpinionCopyWith<$Res>(_value.userOpinion!, (value) {
      return _then(_value.copyWith(userOpinion: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OpinionPostStateImplCopyWith<$Res>
    implements $OpinionPostStateCopyWith<$Res> {
  factory _$$OpinionPostStateImplCopyWith(
    _$OpinionPostStateImpl value,
    $Res Function(_$OpinionPostStateImpl) then,
  ) = __$$OpinionPostStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isPosting,
    bool hasPosted,
    String? error,
    Opinion? userOpinion,
  });

  @override
  $OpinionCopyWith<$Res>? get userOpinion;
}

/// @nodoc
class __$$OpinionPostStateImplCopyWithImpl<$Res>
    extends _$OpinionPostStateCopyWithImpl<$Res, _$OpinionPostStateImpl>
    implements _$$OpinionPostStateImplCopyWith<$Res> {
  __$$OpinionPostStateImplCopyWithImpl(
    _$OpinionPostStateImpl _value,
    $Res Function(_$OpinionPostStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OpinionPostState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPosting = null,
    Object? hasPosted = null,
    Object? error = freezed,
    Object? userOpinion = freezed,
  }) {
    return _then(
      _$OpinionPostStateImpl(
        isPosting: null == isPosting
            ? _value.isPosting
            : isPosting // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasPosted: null == hasPosted
            ? _value.hasPosted
            : hasPosted // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        userOpinion: freezed == userOpinion
            ? _value.userOpinion
            : userOpinion // ignore: cast_nullable_to_non_nullable
                  as Opinion?,
      ),
    );
  }
}

/// @nodoc

class _$OpinionPostStateImpl implements _OpinionPostState {
  const _$OpinionPostStateImpl({
    this.isPosting = false,
    this.hasPosted = false,
    this.error,
    this.userOpinion,
  });

  @override
  @JsonKey()
  final bool isPosting;
  @override
  @JsonKey()
  final bool hasPosted;
  @override
  final String? error;
  @override
  final Opinion? userOpinion;

  @override
  String toString() {
    return 'OpinionPostState(isPosting: $isPosting, hasPosted: $hasPosted, error: $error, userOpinion: $userOpinion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpinionPostStateImpl &&
            (identical(other.isPosting, isPosting) ||
                other.isPosting == isPosting) &&
            (identical(other.hasPosted, hasPosted) ||
                other.hasPosted == hasPosted) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.userOpinion, userOpinion) ||
                other.userOpinion == userOpinion));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isPosting, hasPosted, error, userOpinion);

  /// Create a copy of OpinionPostState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpinionPostStateImplCopyWith<_$OpinionPostStateImpl> get copyWith =>
      __$$OpinionPostStateImplCopyWithImpl<_$OpinionPostStateImpl>(
        this,
        _$identity,
      );
}

abstract class _OpinionPostState implements OpinionPostState {
  const factory _OpinionPostState({
    final bool isPosting,
    final bool hasPosted,
    final String? error,
    final Opinion? userOpinion,
  }) = _$OpinionPostStateImpl;

  @override
  bool get isPosting;
  @override
  bool get hasPosted;
  @override
  String? get error;
  @override
  Opinion? get userOpinion;

  /// Create a copy of OpinionPostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpinionPostStateImplCopyWith<_$OpinionPostStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

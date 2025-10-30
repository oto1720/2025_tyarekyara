// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BadgeState {
  List<Badge> get earnedBadges => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of BadgeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeStateCopyWith<BadgeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeStateCopyWith<$Res> {
  factory $BadgeStateCopyWith(
    BadgeState value,
    $Res Function(BadgeState) then,
  ) = _$BadgeStateCopyWithImpl<$Res, BadgeState>;
  @useResult
  $Res call({List<Badge> earnedBadges, bool isLoading, String? error});
}

/// @nodoc
class _$BadgeStateCopyWithImpl<$Res, $Val extends BadgeState>
    implements $BadgeStateCopyWith<$Res> {
  _$BadgeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BadgeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? earnedBadges = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            earnedBadges: null == earnedBadges
                ? _value.earnedBadges
                : earnedBadges // ignore: cast_nullable_to_non_nullable
                      as List<Badge>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BadgeStateImplCopyWith<$Res>
    implements $BadgeStateCopyWith<$Res> {
  factory _$$BadgeStateImplCopyWith(
    _$BadgeStateImpl value,
    $Res Function(_$BadgeStateImpl) then,
  ) = __$$BadgeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Badge> earnedBadges, bool isLoading, String? error});
}

/// @nodoc
class __$$BadgeStateImplCopyWithImpl<$Res>
    extends _$BadgeStateCopyWithImpl<$Res, _$BadgeStateImpl>
    implements _$$BadgeStateImplCopyWith<$Res> {
  __$$BadgeStateImplCopyWithImpl(
    _$BadgeStateImpl _value,
    $Res Function(_$BadgeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BadgeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? earnedBadges = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$BadgeStateImpl(
        earnedBadges: null == earnedBadges
            ? _value._earnedBadges
            : earnedBadges // ignore: cast_nullable_to_non_nullable
                  as List<Badge>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$BadgeStateImpl implements _BadgeState {
  const _$BadgeStateImpl({
    final List<Badge> earnedBadges = const <Badge>[],
    this.isLoading = false,
    this.error,
  }) : _earnedBadges = earnedBadges;

  final List<Badge> _earnedBadges;
  @override
  @JsonKey()
  List<Badge> get earnedBadges {
    if (_earnedBadges is EqualUnmodifiableListView) return _earnedBadges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_earnedBadges);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'BadgeState(earnedBadges: $earnedBadges, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeStateImpl &&
            const DeepCollectionEquality().equals(
              other._earnedBadges,
              _earnedBadges,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_earnedBadges),
    isLoading,
    error,
  );

  /// Create a copy of BadgeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeStateImplCopyWith<_$BadgeStateImpl> get copyWith =>
      __$$BadgeStateImplCopyWithImpl<_$BadgeStateImpl>(this, _$identity);
}

abstract class _BadgeState implements BadgeState {
  const factory _BadgeState({
    final List<Badge> earnedBadges,
    final bool isLoading,
    final String? error,
  }) = _$BadgeStateImpl;

  @override
  List<Badge> get earnedBadges;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of BadgeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeStateImplCopyWith<_$BadgeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

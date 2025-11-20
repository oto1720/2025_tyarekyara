// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earned_badge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EarnedBadge _$EarnedBadgeFromJson(Map<String, dynamic> json) {
  return _EarnedBadge.fromJson(json);
}

/// @nodoc
mixin _$EarnedBadge {
  String get badgeId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get earnedAt => throw _privateConstructorUsedError;
  String? get awardedBy => throw _privateConstructorUsedError;

  /// Serializes this EarnedBadge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EarnedBadge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EarnedBadgeCopyWith<EarnedBadge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EarnedBadgeCopyWith<$Res> {
  factory $EarnedBadgeCopyWith(
    EarnedBadge value,
    $Res Function(EarnedBadge) then,
  ) = _$EarnedBadgeCopyWithImpl<$Res, EarnedBadge>;
  @useResult
  $Res call({
    String badgeId,
    @TimestampConverter() DateTime earnedAt,
    String? awardedBy,
  });
}

/// @nodoc
class _$EarnedBadgeCopyWithImpl<$Res, $Val extends EarnedBadge>
    implements $EarnedBadgeCopyWith<$Res> {
  _$EarnedBadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EarnedBadge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? badgeId = null,
    Object? earnedAt = null,
    Object? awardedBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            badgeId: null == badgeId
                ? _value.badgeId
                : badgeId // ignore: cast_nullable_to_non_nullable
                      as String,
            earnedAt: null == earnedAt
                ? _value.earnedAt
                : earnedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            awardedBy: freezed == awardedBy
                ? _value.awardedBy
                : awardedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EarnedBadgeImplCopyWith<$Res>
    implements $EarnedBadgeCopyWith<$Res> {
  factory _$$EarnedBadgeImplCopyWith(
    _$EarnedBadgeImpl value,
    $Res Function(_$EarnedBadgeImpl) then,
  ) = __$$EarnedBadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String badgeId,
    @TimestampConverter() DateTime earnedAt,
    String? awardedBy,
  });
}

/// @nodoc
class __$$EarnedBadgeImplCopyWithImpl<$Res>
    extends _$EarnedBadgeCopyWithImpl<$Res, _$EarnedBadgeImpl>
    implements _$$EarnedBadgeImplCopyWith<$Res> {
  __$$EarnedBadgeImplCopyWithImpl(
    _$EarnedBadgeImpl _value,
    $Res Function(_$EarnedBadgeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EarnedBadge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? badgeId = null,
    Object? earnedAt = null,
    Object? awardedBy = freezed,
  }) {
    return _then(
      _$EarnedBadgeImpl(
        badgeId: null == badgeId
            ? _value.badgeId
            : badgeId // ignore: cast_nullable_to_non_nullable
                  as String,
        earnedAt: null == earnedAt
            ? _value.earnedAt
            : earnedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        awardedBy: freezed == awardedBy
            ? _value.awardedBy
            : awardedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EarnedBadgeImpl implements _EarnedBadge {
  const _$EarnedBadgeImpl({
    required this.badgeId,
    @TimestampConverter() required this.earnedAt,
    this.awardedBy,
  });

  factory _$EarnedBadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EarnedBadgeImplFromJson(json);

  @override
  final String badgeId;
  @override
  @TimestampConverter()
  final DateTime earnedAt;
  @override
  final String? awardedBy;

  @override
  String toString() {
    return 'EarnedBadge(badgeId: $badgeId, earnedAt: $earnedAt, awardedBy: $awardedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarnedBadgeImpl &&
            (identical(other.badgeId, badgeId) || other.badgeId == badgeId) &&
            (identical(other.earnedAt, earnedAt) ||
                other.earnedAt == earnedAt) &&
            (identical(other.awardedBy, awardedBy) ||
                other.awardedBy == awardedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, badgeId, earnedAt, awardedBy);

  /// Create a copy of EarnedBadge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EarnedBadgeImplCopyWith<_$EarnedBadgeImpl> get copyWith =>
      __$$EarnedBadgeImplCopyWithImpl<_$EarnedBadgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EarnedBadgeImplToJson(this);
  }
}

abstract class _EarnedBadge implements EarnedBadge {
  const factory _EarnedBadge({
    required final String badgeId,
    @TimestampConverter() required final DateTime earnedAt,
    final String? awardedBy,
  }) = _$EarnedBadgeImpl;

  factory _EarnedBadge.fromJson(Map<String, dynamic> json) =
      _$EarnedBadgeImpl.fromJson;

  @override
  String get badgeId;
  @override
  @TimestampConverter()
  DateTime get earnedAt;
  @override
  String? get awardedBy;

  /// Create a copy of EarnedBadge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EarnedBadgeImplCopyWith<_$EarnedBadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

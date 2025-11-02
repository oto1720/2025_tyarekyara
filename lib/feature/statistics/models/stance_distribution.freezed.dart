// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stance_distribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StanceDistribution _$StanceDistributionFromJson(Map<String, dynamic> json) {
  return _StanceDistribution.fromJson(json);
}

/// @nodoc
mixin _$StanceDistribution {
  String get userId => throw _privateConstructorUsedError;

  /// 立場ごとのカウント（例: "賛成": 12, "反対": 5）
  Map<String, int> get counts => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StanceDistribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StanceDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StanceDistributionCopyWith<StanceDistribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StanceDistributionCopyWith<$Res> {
  factory $StanceDistributionCopyWith(
    StanceDistribution value,
    $Res Function(StanceDistribution) then,
  ) = _$StanceDistributionCopyWithImpl<$Res, StanceDistribution>;
  @useResult
  $Res call({
    String userId,
    Map<String, int> counts,
    int total,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$StanceDistributionCopyWithImpl<$Res, $Val extends StanceDistribution>
    implements $StanceDistributionCopyWith<$Res> {
  _$StanceDistributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StanceDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? counts = null,
    Object? total = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            counts: null == counts
                ? _value.counts
                : counts // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StanceDistributionImplCopyWith<$Res>
    implements $StanceDistributionCopyWith<$Res> {
  factory _$$StanceDistributionImplCopyWith(
    _$StanceDistributionImpl value,
    $Res Function(_$StanceDistributionImpl) then,
  ) = __$$StanceDistributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    Map<String, int> counts,
    int total,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$StanceDistributionImplCopyWithImpl<$Res>
    extends _$StanceDistributionCopyWithImpl<$Res, _$StanceDistributionImpl>
    implements _$$StanceDistributionImplCopyWith<$Res> {
  __$$StanceDistributionImplCopyWithImpl(
    _$StanceDistributionImpl _value,
    $Res Function(_$StanceDistributionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StanceDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? counts = null,
    Object? total = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$StanceDistributionImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        counts: null == counts
            ? _value._counts
            : counts // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StanceDistributionImpl implements _StanceDistribution {
  const _$StanceDistributionImpl({
    required this.userId,
    required final Map<String, int> counts,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  }) : _counts = counts;

  factory _$StanceDistributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$StanceDistributionImplFromJson(json);

  @override
  final String userId;

  /// 立場ごとのカウント（例: "賛成": 12, "反対": 5）
  final Map<String, int> _counts;

  /// 立場ごとのカウント（例: "賛成": 12, "反対": 5）
  @override
  Map<String, int> get counts {
    if (_counts is EqualUnmodifiableMapView) return _counts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_counts);
  }

  @override
  final int total;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'StanceDistribution(userId: $userId, counts: $counts, total: $total, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StanceDistributionImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._counts, _counts) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    const DeepCollectionEquality().hash(_counts),
    total,
    createdAt,
    updatedAt,
  );

  /// Create a copy of StanceDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StanceDistributionImplCopyWith<_$StanceDistributionImpl> get copyWith =>
      __$$StanceDistributionImplCopyWithImpl<_$StanceDistributionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StanceDistributionImplToJson(this);
  }
}

abstract class _StanceDistribution implements StanceDistribution {
  const factory _StanceDistribution({
    required final String userId,
    required final Map<String, int> counts,
    required final int total,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$StanceDistributionImpl;

  factory _StanceDistribution.fromJson(Map<String, dynamic> json) =
      _$StanceDistributionImpl.fromJson;

  @override
  String get userId;

  /// 立場ごとのカウント（例: "賛成": 12, "反対": 5）
  @override
  Map<String, int> get counts;
  @override
  int get total;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of StanceDistribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StanceDistributionImplCopyWith<_$StanceDistributionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

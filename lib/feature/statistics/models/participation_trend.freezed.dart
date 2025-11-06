// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participation_trend.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ParticipationPoint _$ParticipationPointFromJson(Map<String, dynamic> json) {
  return _ParticipationPoint.fromJson(json);
}

/// @nodoc
mixin _$ParticipationPoint {
  DateTime get date => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this ParticipationPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParticipationPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticipationPointCopyWith<ParticipationPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipationPointCopyWith<$Res> {
  factory $ParticipationPointCopyWith(
    ParticipationPoint value,
    $Res Function(ParticipationPoint) then,
  ) = _$ParticipationPointCopyWithImpl<$Res, ParticipationPoint>;
  @useResult
  $Res call({DateTime date, int count});
}

/// @nodoc
class _$ParticipationPointCopyWithImpl<$Res, $Val extends ParticipationPoint>
    implements $ParticipationPointCopyWith<$Res> {
  _$ParticipationPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParticipationPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParticipationPointImplCopyWith<$Res>
    implements $ParticipationPointCopyWith<$Res> {
  factory _$$ParticipationPointImplCopyWith(
    _$ParticipationPointImpl value,
    $Res Function(_$ParticipationPointImpl) then,
  ) = __$$ParticipationPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int count});
}

/// @nodoc
class __$$ParticipationPointImplCopyWithImpl<$Res>
    extends _$ParticipationPointCopyWithImpl<$Res, _$ParticipationPointImpl>
    implements _$$ParticipationPointImplCopyWith<$Res> {
  __$$ParticipationPointImplCopyWithImpl(
    _$ParticipationPointImpl _value,
    $Res Function(_$ParticipationPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParticipationPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? count = null}) {
    return _then(
      _$ParticipationPointImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParticipationPointImpl implements _ParticipationPoint {
  const _$ParticipationPointImpl({required this.date, required this.count});

  factory _$ParticipationPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParticipationPointImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int count;

  @override
  String toString() {
    return 'ParticipationPoint(date: $date, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticipationPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, count);

  /// Create a copy of ParticipationPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticipationPointImplCopyWith<_$ParticipationPointImpl> get copyWith =>
      __$$ParticipationPointImplCopyWithImpl<_$ParticipationPointImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParticipationPointImplToJson(this);
  }
}

abstract class _ParticipationPoint implements ParticipationPoint {
  const factory _ParticipationPoint({
    required final DateTime date,
    required final int count,
  }) = _$ParticipationPointImpl;

  factory _ParticipationPoint.fromJson(Map<String, dynamic> json) =
      _$ParticipationPointImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get count;

  /// Create a copy of ParticipationPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticipationPointImplCopyWith<_$ParticipationPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParticipationTrend _$ParticipationTrendFromJson(Map<String, dynamic> json) {
  return _ParticipationTrend.fromJson(json);
}

/// @nodoc
mixin _$ParticipationTrend {
  String get userId => throw _privateConstructorUsedError;
  List<ParticipationPoint> get points => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ParticipationTrend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParticipationTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticipationTrendCopyWith<ParticipationTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipationTrendCopyWith<$Res> {
  factory $ParticipationTrendCopyWith(
    ParticipationTrend value,
    $Res Function(ParticipationTrend) then,
  ) = _$ParticipationTrendCopyWithImpl<$Res, ParticipationTrend>;
  @useResult
  $Res call({
    String userId,
    List<ParticipationPoint> points,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ParticipationTrendCopyWithImpl<$Res, $Val extends ParticipationTrend>
    implements $ParticipationTrendCopyWith<$Res> {
  _$ParticipationTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParticipationTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? points = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as List<ParticipationPoint>,
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
abstract class _$$ParticipationTrendImplCopyWith<$Res>
    implements $ParticipationTrendCopyWith<$Res> {
  factory _$$ParticipationTrendImplCopyWith(
    _$ParticipationTrendImpl value,
    $Res Function(_$ParticipationTrendImpl) then,
  ) = __$$ParticipationTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    List<ParticipationPoint> points,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ParticipationTrendImplCopyWithImpl<$Res>
    extends _$ParticipationTrendCopyWithImpl<$Res, _$ParticipationTrendImpl>
    implements _$$ParticipationTrendImplCopyWith<$Res> {
  __$$ParticipationTrendImplCopyWithImpl(
    _$ParticipationTrendImpl _value,
    $Res Function(_$ParticipationTrendImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParticipationTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? points = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ParticipationTrendImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        points: null == points
            ? _value._points
            : points // ignore: cast_nullable_to_non_nullable
                  as List<ParticipationPoint>,
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
class _$ParticipationTrendImpl implements _ParticipationTrend {
  const _$ParticipationTrendImpl({
    required this.userId,
    required final List<ParticipationPoint> points,
    required this.createdAt,
    required this.updatedAt,
  }) : _points = points;

  factory _$ParticipationTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParticipationTrendImplFromJson(json);

  @override
  final String userId;
  final List<ParticipationPoint> _points;
  @override
  List<ParticipationPoint> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ParticipationTrend(userId: $userId, points: $points, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticipationTrendImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._points, _points) &&
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
    const DeepCollectionEquality().hash(_points),
    createdAt,
    updatedAt,
  );

  /// Create a copy of ParticipationTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticipationTrendImplCopyWith<_$ParticipationTrendImpl> get copyWith =>
      __$$ParticipationTrendImplCopyWithImpl<_$ParticipationTrendImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParticipationTrendImplToJson(this);
  }
}

abstract class _ParticipationTrend implements ParticipationTrend {
  const factory _ParticipationTrend({
    required final String userId,
    required final List<ParticipationPoint> points,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ParticipationTrendImpl;

  factory _ParticipationTrend.fromJson(Map<String, dynamic> json) =
      _$ParticipationTrendImpl.fromJson;

  @override
  String get userId;
  @override
  List<ParticipationPoint> get points;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of ParticipationTrend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticipationTrendImplCopyWith<_$ParticipationTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

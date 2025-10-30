// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserStatistics _$UserStatisticsFromJson(Map<String, dynamic> json) {
  return _UserStatistics.fromJson(json);
}

/// @nodoc
mixin _$UserStatistics {
  String get userId => throw _privateConstructorUsedError;
  int get participationDays => throw _privateConstructorUsedError;
  int get totalOpinions => throw _privateConstructorUsedError;
  int get consecutiveDays => throw _privateConstructorUsedError;
  DateTime get lastParticipation => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserStatistics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStatisticsCopyWith<UserStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatisticsCopyWith<$Res> {
  factory $UserStatisticsCopyWith(
    UserStatistics value,
    $Res Function(UserStatistics) then,
  ) = _$UserStatisticsCopyWithImpl<$Res, UserStatistics>;
  @useResult
  $Res call({
    String userId,
    int participationDays,
    int totalOpinions,
    int consecutiveDays,
    DateTime lastParticipation,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$UserStatisticsCopyWithImpl<$Res, $Val extends UserStatistics>
    implements $UserStatisticsCopyWith<$Res> {
  _$UserStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? participationDays = null,
    Object? totalOpinions = null,
    Object? consecutiveDays = null,
    Object? lastParticipation = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            participationDays: null == participationDays
                ? _value.participationDays
                : participationDays // ignore: cast_nullable_to_non_nullable
                      as int,
            totalOpinions: null == totalOpinions
                ? _value.totalOpinions
                : totalOpinions // ignore: cast_nullable_to_non_nullable
                      as int,
            consecutiveDays: null == consecutiveDays
                ? _value.consecutiveDays
                : consecutiveDays // ignore: cast_nullable_to_non_nullable
                      as int,
            lastParticipation: null == lastParticipation
                ? _value.lastParticipation
                : lastParticipation // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$UserStatisticsImplCopyWith<$Res>
    implements $UserStatisticsCopyWith<$Res> {
  factory _$$UserStatisticsImplCopyWith(
    _$UserStatisticsImpl value,
    $Res Function(_$UserStatisticsImpl) then,
  ) = __$$UserStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    int participationDays,
    int totalOpinions,
    int consecutiveDays,
    DateTime lastParticipation,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$UserStatisticsImplCopyWithImpl<$Res>
    extends _$UserStatisticsCopyWithImpl<$Res, _$UserStatisticsImpl>
    implements _$$UserStatisticsImplCopyWith<$Res> {
  __$$UserStatisticsImplCopyWithImpl(
    _$UserStatisticsImpl _value,
    $Res Function(_$UserStatisticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? participationDays = null,
    Object? totalOpinions = null,
    Object? consecutiveDays = null,
    Object? lastParticipation = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UserStatisticsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        participationDays: null == participationDays
            ? _value.participationDays
            : participationDays // ignore: cast_nullable_to_non_nullable
                  as int,
        totalOpinions: null == totalOpinions
            ? _value.totalOpinions
            : totalOpinions // ignore: cast_nullable_to_non_nullable
                  as int,
        consecutiveDays: null == consecutiveDays
            ? _value.consecutiveDays
            : consecutiveDays // ignore: cast_nullable_to_non_nullable
                  as int,
        lastParticipation: null == lastParticipation
            ? _value.lastParticipation
            : lastParticipation // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$UserStatisticsImpl implements _UserStatistics {
  const _$UserStatisticsImpl({
    required this.userId,
    required this.participationDays,
    required this.totalOpinions,
    required this.consecutiveDays,
    required this.lastParticipation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$UserStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatisticsImplFromJson(json);

  @override
  final String userId;
  @override
  final int participationDays;
  @override
  final int totalOpinions;
  @override
  final int consecutiveDays;
  @override
  final DateTime lastParticipation;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserStatistics(userId: $userId, participationDays: $participationDays, totalOpinions: $totalOpinions, consecutiveDays: $consecutiveDays, lastParticipation: $lastParticipation, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatisticsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.participationDays, participationDays) ||
                other.participationDays == participationDays) &&
            (identical(other.totalOpinions, totalOpinions) ||
                other.totalOpinions == totalOpinions) &&
            (identical(other.consecutiveDays, consecutiveDays) ||
                other.consecutiveDays == consecutiveDays) &&
            (identical(other.lastParticipation, lastParticipation) ||
                other.lastParticipation == lastParticipation) &&
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
    participationDays,
    totalOpinions,
    consecutiveDays,
    lastParticipation,
    createdAt,
    updatedAt,
  );

  /// Create a copy of UserStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatisticsImplCopyWith<_$UserStatisticsImpl> get copyWith =>
      __$$UserStatisticsImplCopyWithImpl<_$UserStatisticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatisticsImplToJson(this);
  }
}

abstract class _UserStatistics implements UserStatistics {
  const factory _UserStatistics({
    required final String userId,
    required final int participationDays,
    required final int totalOpinions,
    required final int consecutiveDays,
    required final DateTime lastParticipation,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$UserStatisticsImpl;

  factory _UserStatistics.fromJson(Map<String, dynamic> json) =
      _$UserStatisticsImpl.fromJson;

  @override
  String get userId;
  @override
  int get participationDays;
  @override
  int get totalOpinions;
  @override
  int get consecutiveDays;
  @override
  DateTime get lastParticipation;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of UserStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStatisticsImplCopyWith<_$UserStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

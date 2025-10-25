// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) {
  return _UserStatsModel.fromJson(json);
}

/// @nodoc
mixin _$UserStatsModel {
  String get userId => throw _privateConstructorUsedError;
  int get totalMatches => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  int get losses => throw _privateConstructorUsedError;
  int get draws => throw _privateConstructorUsedError;
  double get winRate => throw _privateConstructorUsedError;
  int get ranking => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStatsModelCopyWith<UserStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatsModelCopyWith<$Res> {
  factory $UserStatsModelCopyWith(
    UserStatsModel value,
    $Res Function(UserStatsModel) then,
  ) = _$UserStatsModelCopyWithImpl<$Res, UserStatsModel>;
  @useResult
  $Res call({
    String userId,
    int totalMatches,
    int wins,
    int losses,
    int draws,
    double winRate,
    int ranking,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$UserStatsModelCopyWithImpl<$Res, $Val extends UserStatsModel>
    implements $UserStatsModelCopyWith<$Res> {
  _$UserStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalMatches = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? winRate = null,
    Object? ranking = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalMatches: null == totalMatches
                ? _value.totalMatches
                : totalMatches // ignore: cast_nullable_to_non_nullable
                      as int,
            wins: null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                      as int,
            losses: null == losses
                ? _value.losses
                : losses // ignore: cast_nullable_to_non_nullable
                      as int,
            draws: null == draws
                ? _value.draws
                : draws // ignore: cast_nullable_to_non_nullable
                      as int,
            winRate: null == winRate
                ? _value.winRate
                : winRate // ignore: cast_nullable_to_non_nullable
                      as double,
            ranking: null == ranking
                ? _value.ranking
                : ranking // ignore: cast_nullable_to_non_nullable
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
abstract class _$$UserStatsModelImplCopyWith<$Res>
    implements $UserStatsModelCopyWith<$Res> {
  factory _$$UserStatsModelImplCopyWith(
    _$UserStatsModelImpl value,
    $Res Function(_$UserStatsModelImpl) then,
  ) = __$$UserStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    int totalMatches,
    int wins,
    int losses,
    int draws,
    double winRate,
    int ranking,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$UserStatsModelImplCopyWithImpl<$Res>
    extends _$UserStatsModelCopyWithImpl<$Res, _$UserStatsModelImpl>
    implements _$$UserStatsModelImplCopyWith<$Res> {
  __$$UserStatsModelImplCopyWithImpl(
    _$UserStatsModelImpl _value,
    $Res Function(_$UserStatsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalMatches = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? winRate = null,
    Object? ranking = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UserStatsModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalMatches: null == totalMatches
            ? _value.totalMatches
            : totalMatches // ignore: cast_nullable_to_non_nullable
                  as int,
        wins: null == wins
            ? _value.wins
            : wins // ignore: cast_nullable_to_non_nullable
                  as int,
        losses: null == losses
            ? _value.losses
            : losses // ignore: cast_nullable_to_non_nullable
                  as int,
        draws: null == draws
            ? _value.draws
            : draws // ignore: cast_nullable_to_non_nullable
                  as int,
        winRate: null == winRate
            ? _value.winRate
            : winRate // ignore: cast_nullable_to_non_nullable
                  as double,
        ranking: null == ranking
            ? _value.ranking
            : ranking // ignore: cast_nullable_to_non_nullable
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
class _$UserStatsModelImpl implements _UserStatsModel {
  const _$UserStatsModelImpl({
    required this.userId,
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winRate = 0.0,
    this.ranking = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$UserStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsModelImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final int totalMatches;
  @override
  @JsonKey()
  final int wins;
  @override
  @JsonKey()
  final int losses;
  @override
  @JsonKey()
  final int draws;
  @override
  @JsonKey()
  final double winRate;
  @override
  @JsonKey()
  final int ranking;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserStatsModel(userId: $userId, totalMatches: $totalMatches, wins: $wins, losses: $losses, draws: $draws, winRate: $winRate, ranking: $ranking, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatsModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalMatches, totalMatches) ||
                other.totalMatches == totalMatches) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.draws, draws) || other.draws == draws) &&
            (identical(other.winRate, winRate) || other.winRate == winRate) &&
            (identical(other.ranking, ranking) || other.ranking == ranking) &&
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
    totalMatches,
    wins,
    losses,
    draws,
    winRate,
    ranking,
    createdAt,
    updatedAt,
  );

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      __$$UserStatsModelImplCopyWithImpl<_$UserStatsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatsModelImplToJson(this);
  }
}

abstract class _UserStatsModel implements UserStatsModel {
  const factory _UserStatsModel({
    required final String userId,
    final int totalMatches,
    final int wins,
    final int losses,
    final int draws,
    final double winRate,
    final int ranking,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$UserStatsModelImpl;

  factory _UserStatsModel.fromJson(Map<String, dynamic> json) =
      _$UserStatsModelImpl.fromJson;

  @override
  String get userId;
  @override
  int get totalMatches;
  @override
  int get wins;
  @override
  int get losses;
  @override
  int get draws;
  @override
  double get winRate;
  @override
  int get ranking;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

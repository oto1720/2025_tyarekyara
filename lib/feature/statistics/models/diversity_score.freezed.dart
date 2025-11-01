// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diversity_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DiversityScore _$DiversityScoreFromJson(Map<String, dynamic> json) {
  return _DiversityScore.fromJson(json);
}

/// @nodoc
mixin _$DiversityScore {
  String get userId => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;

  /// 任意の内訳（例: カテゴリ -> スコア）
  Map<String, double> get breakdown => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DiversityScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiversityScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiversityScoreCopyWith<DiversityScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiversityScoreCopyWith<$Res> {
  factory $DiversityScoreCopyWith(
    DiversityScore value,
    $Res Function(DiversityScore) then,
  ) = _$DiversityScoreCopyWithImpl<$Res, DiversityScore>;
  @useResult
  $Res call({
    String userId,
    double score,
    Map<String, double> breakdown,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$DiversityScoreCopyWithImpl<$Res, $Val extends DiversityScore>
    implements $DiversityScoreCopyWith<$Res> {
  _$DiversityScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiversityScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? score = null,
    Object? breakdown = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            breakdown: null == breakdown
                ? _value.breakdown
                : breakdown // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
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
abstract class _$$DiversityScoreImplCopyWith<$Res>
    implements $DiversityScoreCopyWith<$Res> {
  factory _$$DiversityScoreImplCopyWith(
    _$DiversityScoreImpl value,
    $Res Function(_$DiversityScoreImpl) then,
  ) = __$$DiversityScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    double score,
    Map<String, double> breakdown,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$DiversityScoreImplCopyWithImpl<$Res>
    extends _$DiversityScoreCopyWithImpl<$Res, _$DiversityScoreImpl>
    implements _$$DiversityScoreImplCopyWith<$Res> {
  __$$DiversityScoreImplCopyWithImpl(
    _$DiversityScoreImpl _value,
    $Res Function(_$DiversityScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiversityScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? score = null,
    Object? breakdown = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$DiversityScoreImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        breakdown: null == breakdown
            ? _value._breakdown
            : breakdown // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
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
class _$DiversityScoreImpl implements _DiversityScore {
  const _$DiversityScoreImpl({
    required this.userId,
    required this.score,
    required final Map<String, double> breakdown,
    required this.createdAt,
    required this.updatedAt,
  }) : _breakdown = breakdown;

  factory _$DiversityScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiversityScoreImplFromJson(json);

  @override
  final String userId;
  @override
  final double score;

  /// 任意の内訳（例: カテゴリ -> スコア）
  final Map<String, double> _breakdown;

  /// 任意の内訳（例: カテゴリ -> スコア）
  @override
  Map<String, double> get breakdown {
    if (_breakdown is EqualUnmodifiableMapView) return _breakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_breakdown);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'DiversityScore(userId: $userId, score: $score, breakdown: $breakdown, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiversityScoreImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(
              other._breakdown,
              _breakdown,
            ) &&
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
    score,
    const DeepCollectionEquality().hash(_breakdown),
    createdAt,
    updatedAt,
  );

  /// Create a copy of DiversityScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiversityScoreImplCopyWith<_$DiversityScoreImpl> get copyWith =>
      __$$DiversityScoreImplCopyWithImpl<_$DiversityScoreImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DiversityScoreImplToJson(this);
  }
}

abstract class _DiversityScore implements DiversityScore {
  const factory _DiversityScore({
    required final String userId,
    required final double score,
    required final Map<String, double> breakdown,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$DiversityScoreImpl;

  factory _DiversityScore.fromJson(Map<String, dynamic> json) =
      _$DiversityScoreImpl.fromJson;

  @override
  String get userId;
  @override
  double get score;

  /// 任意の内訳（例: カテゴリ -> スコア）
  @override
  Map<String, double> get breakdown;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of DiversityScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiversityScoreImplCopyWith<_$DiversityScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

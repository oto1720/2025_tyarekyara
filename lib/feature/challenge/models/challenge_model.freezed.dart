// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Challenge _$ChallengeFromJson(Map<String, dynamic> json) {
  return _Challenge.fromJson(json);
}

/// @nodoc
mixin _$Challenge {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  Stance get stance => throw _privateConstructorUsedError; // チャレンジで取るべき立場
  Stance? get originalStance => throw _privateConstructorUsedError; // 元の意見の立場
  ChallengeDifficulty get difficulty => throw _privateConstructorUsedError;
  ChallengeStatus get status => throw _privateConstructorUsedError;
  String get originalOpinionText => throw _privateConstructorUsedError; // 元の意見
  String? get oppositeOpinionText =>
      throw _privateConstructorUsedError; // チャレンジによる反対の意見
  String get userId => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError; // 完了日時
  int? get earnedPoints => throw _privateConstructorUsedError; // 獲得ポイント
  String? get opinionId => throw _privateConstructorUsedError; // 元の意見ID
  String? get feedbackText => throw _privateConstructorUsedError; // AIフィードバック本文
  int? get feedbackScore => throw _privateConstructorUsedError; // 評価スコア（0-100）
  DateTime? get feedbackGeneratedAt => throw _privateConstructorUsedError;

  /// Serializes this Challenge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeCopyWith<Challenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeCopyWith<$Res> {
  factory $ChallengeCopyWith(Challenge value, $Res Function(Challenge) then) =
      _$ChallengeCopyWithImpl<$Res, Challenge>;
  @useResult
  $Res call({
    String id,
    String title,
    Stance stance,
    Stance? originalStance,
    ChallengeDifficulty difficulty,
    ChallengeStatus status,
    String originalOpinionText,
    String? oppositeOpinionText,
    String userId,
    DateTime? completedAt,
    int? earnedPoints,
    String? opinionId,
    String? feedbackText,
    int? feedbackScore,
    DateTime? feedbackGeneratedAt,
  });
}

/// @nodoc
class _$ChallengeCopyWithImpl<$Res, $Val extends Challenge>
    implements $ChallengeCopyWith<$Res> {
  _$ChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? stance = null,
    Object? originalStance = freezed,
    Object? difficulty = null,
    Object? status = null,
    Object? originalOpinionText = null,
    Object? oppositeOpinionText = freezed,
    Object? userId = null,
    Object? completedAt = freezed,
    Object? earnedPoints = freezed,
    Object? opinionId = freezed,
    Object? feedbackText = freezed,
    Object? feedbackScore = freezed,
    Object? feedbackGeneratedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            stance: null == stance
                ? _value.stance
                : stance // ignore: cast_nullable_to_non_nullable
                      as Stance,
            originalStance: freezed == originalStance
                ? _value.originalStance
                : originalStance // ignore: cast_nullable_to_non_nullable
                      as Stance?,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as ChallengeDifficulty,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ChallengeStatus,
            originalOpinionText: null == originalOpinionText
                ? _value.originalOpinionText
                : originalOpinionText // ignore: cast_nullable_to_non_nullable
                      as String,
            oppositeOpinionText: freezed == oppositeOpinionText
                ? _value.oppositeOpinionText
                : oppositeOpinionText // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            earnedPoints: freezed == earnedPoints
                ? _value.earnedPoints
                : earnedPoints // ignore: cast_nullable_to_non_nullable
                      as int?,
            opinionId: freezed == opinionId
                ? _value.opinionId
                : opinionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            feedbackText: freezed == feedbackText
                ? _value.feedbackText
                : feedbackText // ignore: cast_nullable_to_non_nullable
                      as String?,
            feedbackScore: freezed == feedbackScore
                ? _value.feedbackScore
                : feedbackScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            feedbackGeneratedAt: freezed == feedbackGeneratedAt
                ? _value.feedbackGeneratedAt
                : feedbackGeneratedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChallengeImplCopyWith<$Res>
    implements $ChallengeCopyWith<$Res> {
  factory _$$ChallengeImplCopyWith(
    _$ChallengeImpl value,
    $Res Function(_$ChallengeImpl) then,
  ) = __$$ChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    Stance stance,
    Stance? originalStance,
    ChallengeDifficulty difficulty,
    ChallengeStatus status,
    String originalOpinionText,
    String? oppositeOpinionText,
    String userId,
    DateTime? completedAt,
    int? earnedPoints,
    String? opinionId,
    String? feedbackText,
    int? feedbackScore,
    DateTime? feedbackGeneratedAt,
  });
}

/// @nodoc
class __$$ChallengeImplCopyWithImpl<$Res>
    extends _$ChallengeCopyWithImpl<$Res, _$ChallengeImpl>
    implements _$$ChallengeImplCopyWith<$Res> {
  __$$ChallengeImplCopyWithImpl(
    _$ChallengeImpl _value,
    $Res Function(_$ChallengeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? stance = null,
    Object? originalStance = freezed,
    Object? difficulty = null,
    Object? status = null,
    Object? originalOpinionText = null,
    Object? oppositeOpinionText = freezed,
    Object? userId = null,
    Object? completedAt = freezed,
    Object? earnedPoints = freezed,
    Object? opinionId = freezed,
    Object? feedbackText = freezed,
    Object? feedbackScore = freezed,
    Object? feedbackGeneratedAt = freezed,
  }) {
    return _then(
      _$ChallengeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        stance: null == stance
            ? _value.stance
            : stance // ignore: cast_nullable_to_non_nullable
                  as Stance,
        originalStance: freezed == originalStance
            ? _value.originalStance
            : originalStance // ignore: cast_nullable_to_non_nullable
                  as Stance?,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as ChallengeDifficulty,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ChallengeStatus,
        originalOpinionText: null == originalOpinionText
            ? _value.originalOpinionText
            : originalOpinionText // ignore: cast_nullable_to_non_nullable
                  as String,
        oppositeOpinionText: freezed == oppositeOpinionText
            ? _value.oppositeOpinionText
            : oppositeOpinionText // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        earnedPoints: freezed == earnedPoints
            ? _value.earnedPoints
            : earnedPoints // ignore: cast_nullable_to_non_nullable
                  as int?,
        opinionId: freezed == opinionId
            ? _value.opinionId
            : opinionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        feedbackText: freezed == feedbackText
            ? _value.feedbackText
            : feedbackText // ignore: cast_nullable_to_non_nullable
                  as String?,
        feedbackScore: freezed == feedbackScore
            ? _value.feedbackScore
            : feedbackScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        feedbackGeneratedAt: freezed == feedbackGeneratedAt
            ? _value.feedbackGeneratedAt
            : feedbackGeneratedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeImpl extends _Challenge {
  const _$ChallengeImpl({
    required this.id,
    required this.title,
    required this.stance,
    this.originalStance,
    required this.difficulty,
    this.status = ChallengeStatus.available,
    required this.originalOpinionText,
    this.oppositeOpinionText,
    required this.userId,
    this.completedAt,
    this.earnedPoints,
    this.opinionId,
    this.feedbackText,
    this.feedbackScore,
    this.feedbackGeneratedAt,
  }) : super._();

  factory _$ChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final Stance stance;
  // チャレンジで取るべき立場
  @override
  final Stance? originalStance;
  // 元の意見の立場
  @override
  final ChallengeDifficulty difficulty;
  @override
  @JsonKey()
  final ChallengeStatus status;
  @override
  final String originalOpinionText;
  // 元の意見
  @override
  final String? oppositeOpinionText;
  // チャレンジによる反対の意見
  @override
  final String userId;
  @override
  final DateTime? completedAt;
  // 完了日時
  @override
  final int? earnedPoints;
  // 獲得ポイント
  @override
  final String? opinionId;
  // 元の意見ID
  @override
  final String? feedbackText;
  // AIフィードバック本文
  @override
  final int? feedbackScore;
  // 評価スコア（0-100）
  @override
  final DateTime? feedbackGeneratedAt;

  @override
  String toString() {
    return 'Challenge(id: $id, title: $title, stance: $stance, originalStance: $originalStance, difficulty: $difficulty, status: $status, originalOpinionText: $originalOpinionText, oppositeOpinionText: $oppositeOpinionText, userId: $userId, completedAt: $completedAt, earnedPoints: $earnedPoints, opinionId: $opinionId, feedbackText: $feedbackText, feedbackScore: $feedbackScore, feedbackGeneratedAt: $feedbackGeneratedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.stance, stance) || other.stance == stance) &&
            (identical(other.originalStance, originalStance) ||
                other.originalStance == originalStance) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.originalOpinionText, originalOpinionText) ||
                other.originalOpinionText == originalOpinionText) &&
            (identical(other.oppositeOpinionText, oppositeOpinionText) ||
                other.oppositeOpinionText == oppositeOpinionText) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.earnedPoints, earnedPoints) ||
                other.earnedPoints == earnedPoints) &&
            (identical(other.opinionId, opinionId) ||
                other.opinionId == opinionId) &&
            (identical(other.feedbackText, feedbackText) ||
                other.feedbackText == feedbackText) &&
            (identical(other.feedbackScore, feedbackScore) ||
                other.feedbackScore == feedbackScore) &&
            (identical(other.feedbackGeneratedAt, feedbackGeneratedAt) ||
                other.feedbackGeneratedAt == feedbackGeneratedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    stance,
    originalStance,
    difficulty,
    status,
    originalOpinionText,
    oppositeOpinionText,
    userId,
    completedAt,
    earnedPoints,
    opinionId,
    feedbackText,
    feedbackScore,
    feedbackGeneratedAt,
  );

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      __$$ChallengeImplCopyWithImpl<_$ChallengeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeImplToJson(this);
  }
}

abstract class _Challenge extends Challenge {
  const factory _Challenge({
    required final String id,
    required final String title,
    required final Stance stance,
    final Stance? originalStance,
    required final ChallengeDifficulty difficulty,
    final ChallengeStatus status,
    required final String originalOpinionText,
    final String? oppositeOpinionText,
    required final String userId,
    final DateTime? completedAt,
    final int? earnedPoints,
    final String? opinionId,
    final String? feedbackText,
    final int? feedbackScore,
    final DateTime? feedbackGeneratedAt,
  }) = _$ChallengeImpl;
  const _Challenge._() : super._();

  factory _Challenge.fromJson(Map<String, dynamic> json) =
      _$ChallengeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  Stance get stance; // チャレンジで取るべき立場
  @override
  Stance? get originalStance; // 元の意見の立場
  @override
  ChallengeDifficulty get difficulty;
  @override
  ChallengeStatus get status;
  @override
  String get originalOpinionText; // 元の意見
  @override
  String? get oppositeOpinionText; // チャレンジによる反対の意見
  @override
  String get userId;
  @override
  DateTime? get completedAt; // 完了日時
  @override
  int? get earnedPoints; // 獲得ポイント
  @override
  String? get opinionId; // 元の意見ID
  @override
  String? get feedbackText; // AIフィードバック本文
  @override
  int? get feedbackScore; // 評価スコア（0-100）
  @override
  DateTime? get feedbackGeneratedAt;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

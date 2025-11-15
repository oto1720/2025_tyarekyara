// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'judgment_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamScore _$TeamScoreFromJson(Map<String, dynamic> json) {
  return _TeamScore.fromJson(json);
}

/// @nodoc
mixin _$TeamScore {
  DebateStance get stance => throw _privateConstructorUsedError;
  int get logic => throw _privateConstructorUsedError;
  int get evidence => throw _privateConstructorUsedError;
  int get rebuttal => throw _privateConstructorUsedError;
  int get persuasiveness => throw _privateConstructorUsedError;
  int get manner => throw _privateConstructorUsedError;
  int get total =>
      throw _privateConstructorUsedError; // エイリアス（Cloud Functions互換用）
  int get logicScore => throw _privateConstructorUsedError;
  int get evidenceScore => throw _privateConstructorUsedError;
  int get rebuttalScore => throw _privateConstructorUsedError;
  int get persuasivenessScore => throw _privateConstructorUsedError;
  int get mannerScore => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  String? get feedback => throw _privateConstructorUsedError;

  /// Serializes this TeamScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamScoreCopyWith<TeamScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamScoreCopyWith<$Res> {
  factory $TeamScoreCopyWith(TeamScore value, $Res Function(TeamScore) then) =
      _$TeamScoreCopyWithImpl<$Res, TeamScore>;
  @useResult
  $Res call({
    DebateStance stance,
    int logic,
    int evidence,
    int rebuttal,
    int persuasiveness,
    int manner,
    int total,
    int logicScore,
    int evidenceScore,
    int rebuttalScore,
    int persuasivenessScore,
    int mannerScore,
    int totalScore,
    String? feedback,
  });
}

/// @nodoc
class _$TeamScoreCopyWithImpl<$Res, $Val extends TeamScore>
    implements $TeamScoreCopyWith<$Res> {
  _$TeamScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stance = null,
    Object? logic = null,
    Object? evidence = null,
    Object? rebuttal = null,
    Object? persuasiveness = null,
    Object? manner = null,
    Object? total = null,
    Object? logicScore = null,
    Object? evidenceScore = null,
    Object? rebuttalScore = null,
    Object? persuasivenessScore = null,
    Object? mannerScore = null,
    Object? totalScore = null,
    Object? feedback = freezed,
  }) {
    return _then(
      _value.copyWith(
            stance: null == stance
                ? _value.stance
                : stance // ignore: cast_nullable_to_non_nullable
                      as DebateStance,
            logic: null == logic
                ? _value.logic
                : logic // ignore: cast_nullable_to_non_nullable
                      as int,
            evidence: null == evidence
                ? _value.evidence
                : evidence // ignore: cast_nullable_to_non_nullable
                      as int,
            rebuttal: null == rebuttal
                ? _value.rebuttal
                : rebuttal // ignore: cast_nullable_to_non_nullable
                      as int,
            persuasiveness: null == persuasiveness
                ? _value.persuasiveness
                : persuasiveness // ignore: cast_nullable_to_non_nullable
                      as int,
            manner: null == manner
                ? _value.manner
                : manner // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            logicScore: null == logicScore
                ? _value.logicScore
                : logicScore // ignore: cast_nullable_to_non_nullable
                      as int,
            evidenceScore: null == evidenceScore
                ? _value.evidenceScore
                : evidenceScore // ignore: cast_nullable_to_non_nullable
                      as int,
            rebuttalScore: null == rebuttalScore
                ? _value.rebuttalScore
                : rebuttalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            persuasivenessScore: null == persuasivenessScore
                ? _value.persuasivenessScore
                : persuasivenessScore // ignore: cast_nullable_to_non_nullable
                      as int,
            mannerScore: null == mannerScore
                ? _value.mannerScore
                : mannerScore // ignore: cast_nullable_to_non_nullable
                      as int,
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            feedback: freezed == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamScoreImplCopyWith<$Res>
    implements $TeamScoreCopyWith<$Res> {
  factory _$$TeamScoreImplCopyWith(
    _$TeamScoreImpl value,
    $Res Function(_$TeamScoreImpl) then,
  ) = __$$TeamScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DebateStance stance,
    int logic,
    int evidence,
    int rebuttal,
    int persuasiveness,
    int manner,
    int total,
    int logicScore,
    int evidenceScore,
    int rebuttalScore,
    int persuasivenessScore,
    int mannerScore,
    int totalScore,
    String? feedback,
  });
}

/// @nodoc
class __$$TeamScoreImplCopyWithImpl<$Res>
    extends _$TeamScoreCopyWithImpl<$Res, _$TeamScoreImpl>
    implements _$$TeamScoreImplCopyWith<$Res> {
  __$$TeamScoreImplCopyWithImpl(
    _$TeamScoreImpl _value,
    $Res Function(_$TeamScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stance = null,
    Object? logic = null,
    Object? evidence = null,
    Object? rebuttal = null,
    Object? persuasiveness = null,
    Object? manner = null,
    Object? total = null,
    Object? logicScore = null,
    Object? evidenceScore = null,
    Object? rebuttalScore = null,
    Object? persuasivenessScore = null,
    Object? mannerScore = null,
    Object? totalScore = null,
    Object? feedback = freezed,
  }) {
    return _then(
      _$TeamScoreImpl(
        stance: null == stance
            ? _value.stance
            : stance // ignore: cast_nullable_to_non_nullable
                  as DebateStance,
        logic: null == logic
            ? _value.logic
            : logic // ignore: cast_nullable_to_non_nullable
                  as int,
        evidence: null == evidence
            ? _value.evidence
            : evidence // ignore: cast_nullable_to_non_nullable
                  as int,
        rebuttal: null == rebuttal
            ? _value.rebuttal
            : rebuttal // ignore: cast_nullable_to_non_nullable
                  as int,
        persuasiveness: null == persuasiveness
            ? _value.persuasiveness
            : persuasiveness // ignore: cast_nullable_to_non_nullable
                  as int,
        manner: null == manner
            ? _value.manner
            : manner // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        logicScore: null == logicScore
            ? _value.logicScore
            : logicScore // ignore: cast_nullable_to_non_nullable
                  as int,
        evidenceScore: null == evidenceScore
            ? _value.evidenceScore
            : evidenceScore // ignore: cast_nullable_to_non_nullable
                  as int,
        rebuttalScore: null == rebuttalScore
            ? _value.rebuttalScore
            : rebuttalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        persuasivenessScore: null == persuasivenessScore
            ? _value.persuasivenessScore
            : persuasivenessScore // ignore: cast_nullable_to_non_nullable
                  as int,
        mannerScore: null == mannerScore
            ? _value.mannerScore
            : mannerScore // ignore: cast_nullable_to_non_nullable
                  as int,
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        feedback: freezed == feedback
            ? _value.feedback
            : feedback // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamScoreImpl implements _TeamScore {
  const _$TeamScoreImpl({
    required this.stance,
    this.logic = 0,
    this.evidence = 0,
    this.rebuttal = 0,
    this.persuasiveness = 0,
    this.manner = 0,
    this.total = 0,
    this.logicScore = 0,
    this.evidenceScore = 0,
    this.rebuttalScore = 0,
    this.persuasivenessScore = 0,
    this.mannerScore = 0,
    this.totalScore = 0,
    this.feedback,
  });

  factory _$TeamScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamScoreImplFromJson(json);

  @override
  final DebateStance stance;
  @override
  @JsonKey()
  final int logic;
  @override
  @JsonKey()
  final int evidence;
  @override
  @JsonKey()
  final int rebuttal;
  @override
  @JsonKey()
  final int persuasiveness;
  @override
  @JsonKey()
  final int manner;
  @override
  @JsonKey()
  final int total;
  // エイリアス（Cloud Functions互換用）
  @override
  @JsonKey()
  final int logicScore;
  @override
  @JsonKey()
  final int evidenceScore;
  @override
  @JsonKey()
  final int rebuttalScore;
  @override
  @JsonKey()
  final int persuasivenessScore;
  @override
  @JsonKey()
  final int mannerScore;
  @override
  @JsonKey()
  final int totalScore;
  @override
  final String? feedback;

  @override
  String toString() {
    return 'TeamScore(stance: $stance, logic: $logic, evidence: $evidence, rebuttal: $rebuttal, persuasiveness: $persuasiveness, manner: $manner, total: $total, logicScore: $logicScore, evidenceScore: $evidenceScore, rebuttalScore: $rebuttalScore, persuasivenessScore: $persuasivenessScore, mannerScore: $mannerScore, totalScore: $totalScore, feedback: $feedback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamScoreImpl &&
            (identical(other.stance, stance) || other.stance == stance) &&
            (identical(other.logic, logic) || other.logic == logic) &&
            (identical(other.evidence, evidence) ||
                other.evidence == evidence) &&
            (identical(other.rebuttal, rebuttal) ||
                other.rebuttal == rebuttal) &&
            (identical(other.persuasiveness, persuasiveness) ||
                other.persuasiveness == persuasiveness) &&
            (identical(other.manner, manner) || other.manner == manner) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.logicScore, logicScore) ||
                other.logicScore == logicScore) &&
            (identical(other.evidenceScore, evidenceScore) ||
                other.evidenceScore == evidenceScore) &&
            (identical(other.rebuttalScore, rebuttalScore) ||
                other.rebuttalScore == rebuttalScore) &&
            (identical(other.persuasivenessScore, persuasivenessScore) ||
                other.persuasivenessScore == persuasivenessScore) &&
            (identical(other.mannerScore, mannerScore) ||
                other.mannerScore == mannerScore) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    stance,
    logic,
    evidence,
    rebuttal,
    persuasiveness,
    manner,
    total,
    logicScore,
    evidenceScore,
    rebuttalScore,
    persuasivenessScore,
    mannerScore,
    totalScore,
    feedback,
  );

  /// Create a copy of TeamScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamScoreImplCopyWith<_$TeamScoreImpl> get copyWith =>
      __$$TeamScoreImplCopyWithImpl<_$TeamScoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamScoreImplToJson(this);
  }
}

abstract class _TeamScore implements TeamScore {
  const factory _TeamScore({
    required final DebateStance stance,
    final int logic,
    final int evidence,
    final int rebuttal,
    final int persuasiveness,
    final int manner,
    final int total,
    final int logicScore,
    final int evidenceScore,
    final int rebuttalScore,
    final int persuasivenessScore,
    final int mannerScore,
    final int totalScore,
    final String? feedback,
  }) = _$TeamScoreImpl;

  factory _TeamScore.fromJson(Map<String, dynamic> json) =
      _$TeamScoreImpl.fromJson;

  @override
  DebateStance get stance;
  @override
  int get logic;
  @override
  int get evidence;
  @override
  int get rebuttal;
  @override
  int get persuasiveness;
  @override
  int get manner;
  @override
  int get total; // エイリアス（Cloud Functions互換用）
  @override
  int get logicScore;
  @override
  int get evidenceScore;
  @override
  int get rebuttalScore;
  @override
  int get persuasivenessScore;
  @override
  int get mannerScore;
  @override
  int get totalScore;
  @override
  String? get feedback;

  /// Create a copy of TeamScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamScoreImplCopyWith<_$TeamScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IndividualEvaluation _$IndividualEvaluationFromJson(Map<String, dynamic> json) {
  return _IndividualEvaluation.fromJson(json);
}

/// @nodoc
mixin _$IndividualEvaluation {
  String get userId => throw _privateConstructorUsedError;
  String get userNickname => throw _privateConstructorUsedError;
  DebateStance get stance => throw _privateConstructorUsedError;
  int get contributionScore => throw _privateConstructorUsedError;
  List<String> get strengths => throw _privateConstructorUsedError;
  List<String> get improvements => throw _privateConstructorUsedError;
  bool get isMvp => throw _privateConstructorUsedError;

  /// Serializes this IndividualEvaluation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IndividualEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IndividualEvaluationCopyWith<IndividualEvaluation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IndividualEvaluationCopyWith<$Res> {
  factory $IndividualEvaluationCopyWith(
    IndividualEvaluation value,
    $Res Function(IndividualEvaluation) then,
  ) = _$IndividualEvaluationCopyWithImpl<$Res, IndividualEvaluation>;
  @useResult
  $Res call({
    String userId,
    String userNickname,
    DebateStance stance,
    int contributionScore,
    List<String> strengths,
    List<String> improvements,
    bool isMvp,
  });
}

/// @nodoc
class _$IndividualEvaluationCopyWithImpl<
  $Res,
  $Val extends IndividualEvaluation
>
    implements $IndividualEvaluationCopyWith<$Res> {
  _$IndividualEvaluationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IndividualEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userNickname = null,
    Object? stance = null,
    Object? contributionScore = null,
    Object? strengths = null,
    Object? improvements = null,
    Object? isMvp = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userNickname: null == userNickname
                ? _value.userNickname
                : userNickname // ignore: cast_nullable_to_non_nullable
                      as String,
            stance: null == stance
                ? _value.stance
                : stance // ignore: cast_nullable_to_non_nullable
                      as DebateStance,
            contributionScore: null == contributionScore
                ? _value.contributionScore
                : contributionScore // ignore: cast_nullable_to_non_nullable
                      as int,
            strengths: null == strengths
                ? _value.strengths
                : strengths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            improvements: null == improvements
                ? _value.improvements
                : improvements // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isMvp: null == isMvp
                ? _value.isMvp
                : isMvp // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IndividualEvaluationImplCopyWith<$Res>
    implements $IndividualEvaluationCopyWith<$Res> {
  factory _$$IndividualEvaluationImplCopyWith(
    _$IndividualEvaluationImpl value,
    $Res Function(_$IndividualEvaluationImpl) then,
  ) = __$$IndividualEvaluationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userNickname,
    DebateStance stance,
    int contributionScore,
    List<String> strengths,
    List<String> improvements,
    bool isMvp,
  });
}

/// @nodoc
class __$$IndividualEvaluationImplCopyWithImpl<$Res>
    extends _$IndividualEvaluationCopyWithImpl<$Res, _$IndividualEvaluationImpl>
    implements _$$IndividualEvaluationImplCopyWith<$Res> {
  __$$IndividualEvaluationImplCopyWithImpl(
    _$IndividualEvaluationImpl _value,
    $Res Function(_$IndividualEvaluationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IndividualEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userNickname = null,
    Object? stance = null,
    Object? contributionScore = null,
    Object? strengths = null,
    Object? improvements = null,
    Object? isMvp = null,
  }) {
    return _then(
      _$IndividualEvaluationImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userNickname: null == userNickname
            ? _value.userNickname
            : userNickname // ignore: cast_nullable_to_non_nullable
                  as String,
        stance: null == stance
            ? _value.stance
            : stance // ignore: cast_nullable_to_non_nullable
                  as DebateStance,
        contributionScore: null == contributionScore
            ? _value.contributionScore
            : contributionScore // ignore: cast_nullable_to_non_nullable
                  as int,
        strengths: null == strengths
            ? _value._strengths
            : strengths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        improvements: null == improvements
            ? _value._improvements
            : improvements // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isMvp: null == isMvp
            ? _value.isMvp
            : isMvp // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IndividualEvaluationImpl implements _IndividualEvaluation {
  const _$IndividualEvaluationImpl({
    required this.userId,
    required this.userNickname,
    required this.stance,
    this.contributionScore = 0,
    final List<String> strengths = const [],
    final List<String> improvements = const [],
    this.isMvp = false,
  }) : _strengths = strengths,
       _improvements = improvements;

  factory _$IndividualEvaluationImpl.fromJson(Map<String, dynamic> json) =>
      _$$IndividualEvaluationImplFromJson(json);

  @override
  final String userId;
  @override
  final String userNickname;
  @override
  final DebateStance stance;
  @override
  @JsonKey()
  final int contributionScore;
  final List<String> _strengths;
  @override
  @JsonKey()
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<String> _improvements;
  @override
  @JsonKey()
  List<String> get improvements {
    if (_improvements is EqualUnmodifiableListView) return _improvements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_improvements);
  }

  @override
  @JsonKey()
  final bool isMvp;

  @override
  String toString() {
    return 'IndividualEvaluation(userId: $userId, userNickname: $userNickname, stance: $stance, contributionScore: $contributionScore, strengths: $strengths, improvements: $improvements, isMvp: $isMvp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IndividualEvaluationImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userNickname, userNickname) ||
                other.userNickname == userNickname) &&
            (identical(other.stance, stance) || other.stance == stance) &&
            (identical(other.contributionScore, contributionScore) ||
                other.contributionScore == contributionScore) &&
            const DeepCollectionEquality().equals(
              other._strengths,
              _strengths,
            ) &&
            const DeepCollectionEquality().equals(
              other._improvements,
              _improvements,
            ) &&
            (identical(other.isMvp, isMvp) || other.isMvp == isMvp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    userNickname,
    stance,
    contributionScore,
    const DeepCollectionEquality().hash(_strengths),
    const DeepCollectionEquality().hash(_improvements),
    isMvp,
  );

  /// Create a copy of IndividualEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IndividualEvaluationImplCopyWith<_$IndividualEvaluationImpl>
  get copyWith =>
      __$$IndividualEvaluationImplCopyWithImpl<_$IndividualEvaluationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IndividualEvaluationImplToJson(this);
  }
}

abstract class _IndividualEvaluation implements IndividualEvaluation {
  const factory _IndividualEvaluation({
    required final String userId,
    required final String userNickname,
    required final DebateStance stance,
    final int contributionScore,
    final List<String> strengths,
    final List<String> improvements,
    final bool isMvp,
  }) = _$IndividualEvaluationImpl;

  factory _IndividualEvaluation.fromJson(Map<String, dynamic> json) =
      _$IndividualEvaluationImpl.fromJson;

  @override
  String get userId;
  @override
  String get userNickname;
  @override
  DebateStance get stance;
  @override
  int get contributionScore;
  @override
  List<String> get strengths;
  @override
  List<String> get improvements;
  @override
  bool get isMvp;

  /// Create a copy of IndividualEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IndividualEvaluationImplCopyWith<_$IndividualEvaluationImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$JudgmentResult {
  String get id => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  String get matchId => throw _privateConstructorUsedError;
  TeamScore get proTeamScore => throw _privateConstructorUsedError;
  TeamScore get conTeamScore => throw _privateConstructorUsedError;
  DebateStance? get winningSide => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  DateTime get judgedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<IndividualEvaluation> get individualEvaluations =>
      throw _privateConstructorUsedError;
  String? get mvpUserId => throw _privateConstructorUsedError;
  String? get keyMoment =>
      throw _privateConstructorUsedError; // Cloud Functions互換用コメント
  String? get overallComment => throw _privateConstructorUsedError;
  String? get proTeamComment => throw _privateConstructorUsedError;
  String? get conTeamComment => throw _privateConstructorUsedError;
  Map<String, dynamic>? get aiMetadata => throw _privateConstructorUsedError;

  /// Create a copy of JudgmentResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JudgmentResultCopyWith<JudgmentResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JudgmentResultCopyWith<$Res> {
  factory $JudgmentResultCopyWith(
    JudgmentResult value,
    $Res Function(JudgmentResult) then,
  ) = _$JudgmentResultCopyWithImpl<$Res, JudgmentResult>;
  @useResult
  $Res call({
    String id,
    String roomId,
    String matchId,
    TeamScore proTeamScore,
    TeamScore conTeamScore,
    DebateStance? winningSide,
    String summary,
    DateTime judgedAt,
    DateTime createdAt,
    List<IndividualEvaluation> individualEvaluations,
    String? mvpUserId,
    String? keyMoment,
    String? overallComment,
    String? proTeamComment,
    String? conTeamComment,
    Map<String, dynamic>? aiMetadata,
  });

  $TeamScoreCopyWith<$Res> get proTeamScore;
  $TeamScoreCopyWith<$Res> get conTeamScore;
}

/// @nodoc
class _$JudgmentResultCopyWithImpl<$Res, $Val extends JudgmentResult>
    implements $JudgmentResultCopyWith<$Res> {
  _$JudgmentResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JudgmentResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? matchId = null,
    Object? proTeamScore = null,
    Object? conTeamScore = null,
    Object? winningSide = freezed,
    Object? summary = null,
    Object? judgedAt = null,
    Object? createdAt = null,
    Object? individualEvaluations = null,
    Object? mvpUserId = freezed,
    Object? keyMoment = freezed,
    Object? overallComment = freezed,
    Object? proTeamComment = freezed,
    Object? conTeamComment = freezed,
    Object? aiMetadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            roomId: null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String,
            matchId: null == matchId
                ? _value.matchId
                : matchId // ignore: cast_nullable_to_non_nullable
                      as String,
            proTeamScore: null == proTeamScore
                ? _value.proTeamScore
                : proTeamScore // ignore: cast_nullable_to_non_nullable
                      as TeamScore,
            conTeamScore: null == conTeamScore
                ? _value.conTeamScore
                : conTeamScore // ignore: cast_nullable_to_non_nullable
                      as TeamScore,
            winningSide: freezed == winningSide
                ? _value.winningSide
                : winningSide // ignore: cast_nullable_to_non_nullable
                      as DebateStance?,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            judgedAt: null == judgedAt
                ? _value.judgedAt
                : judgedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            individualEvaluations: null == individualEvaluations
                ? _value.individualEvaluations
                : individualEvaluations // ignore: cast_nullable_to_non_nullable
                      as List<IndividualEvaluation>,
            mvpUserId: freezed == mvpUserId
                ? _value.mvpUserId
                : mvpUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            keyMoment: freezed == keyMoment
                ? _value.keyMoment
                : keyMoment // ignore: cast_nullable_to_non_nullable
                      as String?,
            overallComment: freezed == overallComment
                ? _value.overallComment
                : overallComment // ignore: cast_nullable_to_non_nullable
                      as String?,
            proTeamComment: freezed == proTeamComment
                ? _value.proTeamComment
                : proTeamComment // ignore: cast_nullable_to_non_nullable
                      as String?,
            conTeamComment: freezed == conTeamComment
                ? _value.conTeamComment
                : conTeamComment // ignore: cast_nullable_to_non_nullable
                      as String?,
            aiMetadata: freezed == aiMetadata
                ? _value.aiMetadata
                : aiMetadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of JudgmentResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamScoreCopyWith<$Res> get proTeamScore {
    return $TeamScoreCopyWith<$Res>(_value.proTeamScore, (value) {
      return _then(_value.copyWith(proTeamScore: value) as $Val);
    });
  }

  /// Create a copy of JudgmentResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamScoreCopyWith<$Res> get conTeamScore {
    return $TeamScoreCopyWith<$Res>(_value.conTeamScore, (value) {
      return _then(_value.copyWith(conTeamScore: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$JudgmentResultImplCopyWith<$Res>
    implements $JudgmentResultCopyWith<$Res> {
  factory _$$JudgmentResultImplCopyWith(
    _$JudgmentResultImpl value,
    $Res Function(_$JudgmentResultImpl) then,
  ) = __$$JudgmentResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String roomId,
    String matchId,
    TeamScore proTeamScore,
    TeamScore conTeamScore,
    DebateStance? winningSide,
    String summary,
    DateTime judgedAt,
    DateTime createdAt,
    List<IndividualEvaluation> individualEvaluations,
    String? mvpUserId,
    String? keyMoment,
    String? overallComment,
    String? proTeamComment,
    String? conTeamComment,
    Map<String, dynamic>? aiMetadata,
  });

  @override
  $TeamScoreCopyWith<$Res> get proTeamScore;
  @override
  $TeamScoreCopyWith<$Res> get conTeamScore;
}

/// @nodoc
class __$$JudgmentResultImplCopyWithImpl<$Res>
    extends _$JudgmentResultCopyWithImpl<$Res, _$JudgmentResultImpl>
    implements _$$JudgmentResultImplCopyWith<$Res> {
  __$$JudgmentResultImplCopyWithImpl(
    _$JudgmentResultImpl _value,
    $Res Function(_$JudgmentResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JudgmentResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? matchId = null,
    Object? proTeamScore = null,
    Object? conTeamScore = null,
    Object? winningSide = freezed,
    Object? summary = null,
    Object? judgedAt = null,
    Object? createdAt = null,
    Object? individualEvaluations = null,
    Object? mvpUserId = freezed,
    Object? keyMoment = freezed,
    Object? overallComment = freezed,
    Object? proTeamComment = freezed,
    Object? conTeamComment = freezed,
    Object? aiMetadata = freezed,
  }) {
    return _then(
      _$JudgmentResultImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        roomId: null == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String,
        matchId: null == matchId
            ? _value.matchId
            : matchId // ignore: cast_nullable_to_non_nullable
                  as String,
        proTeamScore: null == proTeamScore
            ? _value.proTeamScore
            : proTeamScore // ignore: cast_nullable_to_non_nullable
                  as TeamScore,
        conTeamScore: null == conTeamScore
            ? _value.conTeamScore
            : conTeamScore // ignore: cast_nullable_to_non_nullable
                  as TeamScore,
        winningSide: freezed == winningSide
            ? _value.winningSide
            : winningSide // ignore: cast_nullable_to_non_nullable
                  as DebateStance?,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        judgedAt: null == judgedAt
            ? _value.judgedAt
            : judgedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        individualEvaluations: null == individualEvaluations
            ? _value._individualEvaluations
            : individualEvaluations // ignore: cast_nullable_to_non_nullable
                  as List<IndividualEvaluation>,
        mvpUserId: freezed == mvpUserId
            ? _value.mvpUserId
            : mvpUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        keyMoment: freezed == keyMoment
            ? _value.keyMoment
            : keyMoment // ignore: cast_nullable_to_non_nullable
                  as String?,
        overallComment: freezed == overallComment
            ? _value.overallComment
            : overallComment // ignore: cast_nullable_to_non_nullable
                  as String?,
        proTeamComment: freezed == proTeamComment
            ? _value.proTeamComment
            : proTeamComment // ignore: cast_nullable_to_non_nullable
                  as String?,
        conTeamComment: freezed == conTeamComment
            ? _value.conTeamComment
            : conTeamComment // ignore: cast_nullable_to_non_nullable
                  as String?,
        aiMetadata: freezed == aiMetadata
            ? _value._aiMetadata
            : aiMetadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$JudgmentResultImpl implements _JudgmentResult {
  const _$JudgmentResultImpl({
    required this.id,
    required this.roomId,
    required this.matchId,
    required this.proTeamScore,
    required this.conTeamScore,
    this.winningSide,
    required this.summary,
    required this.judgedAt,
    required this.createdAt,
    final List<IndividualEvaluation> individualEvaluations = const [],
    this.mvpUserId,
    this.keyMoment,
    this.overallComment,
    this.proTeamComment,
    this.conTeamComment,
    final Map<String, dynamic>? aiMetadata,
  }) : _individualEvaluations = individualEvaluations,
       _aiMetadata = aiMetadata;

  @override
  final String id;
  @override
  final String roomId;
  @override
  final String matchId;
  @override
  final TeamScore proTeamScore;
  @override
  final TeamScore conTeamScore;
  @override
  final DebateStance? winningSide;
  @override
  final String summary;
  @override
  final DateTime judgedAt;
  @override
  final DateTime createdAt;
  final List<IndividualEvaluation> _individualEvaluations;
  @override
  @JsonKey()
  List<IndividualEvaluation> get individualEvaluations {
    if (_individualEvaluations is EqualUnmodifiableListView)
      return _individualEvaluations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_individualEvaluations);
  }

  @override
  final String? mvpUserId;
  @override
  final String? keyMoment;
  // Cloud Functions互換用コメント
  @override
  final String? overallComment;
  @override
  final String? proTeamComment;
  @override
  final String? conTeamComment;
  final Map<String, dynamic>? _aiMetadata;
  @override
  Map<String, dynamic>? get aiMetadata {
    final value = _aiMetadata;
    if (value == null) return null;
    if (_aiMetadata is EqualUnmodifiableMapView) return _aiMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'JudgmentResult(id: $id, roomId: $roomId, matchId: $matchId, proTeamScore: $proTeamScore, conTeamScore: $conTeamScore, winningSide: $winningSide, summary: $summary, judgedAt: $judgedAt, createdAt: $createdAt, individualEvaluations: $individualEvaluations, mvpUserId: $mvpUserId, keyMoment: $keyMoment, overallComment: $overallComment, proTeamComment: $proTeamComment, conTeamComment: $conTeamComment, aiMetadata: $aiMetadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JudgmentResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.proTeamScore, proTeamScore) ||
                other.proTeamScore == proTeamScore) &&
            (identical(other.conTeamScore, conTeamScore) ||
                other.conTeamScore == conTeamScore) &&
            (identical(other.winningSide, winningSide) ||
                other.winningSide == winningSide) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.judgedAt, judgedAt) ||
                other.judgedAt == judgedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(
              other._individualEvaluations,
              _individualEvaluations,
            ) &&
            (identical(other.mvpUserId, mvpUserId) ||
                other.mvpUserId == mvpUserId) &&
            (identical(other.keyMoment, keyMoment) ||
                other.keyMoment == keyMoment) &&
            (identical(other.overallComment, overallComment) ||
                other.overallComment == overallComment) &&
            (identical(other.proTeamComment, proTeamComment) ||
                other.proTeamComment == proTeamComment) &&
            (identical(other.conTeamComment, conTeamComment) ||
                other.conTeamComment == conTeamComment) &&
            const DeepCollectionEquality().equals(
              other._aiMetadata,
              _aiMetadata,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    roomId,
    matchId,
    proTeamScore,
    conTeamScore,
    winningSide,
    summary,
    judgedAt,
    createdAt,
    const DeepCollectionEquality().hash(_individualEvaluations),
    mvpUserId,
    keyMoment,
    overallComment,
    proTeamComment,
    conTeamComment,
    const DeepCollectionEquality().hash(_aiMetadata),
  );

  /// Create a copy of JudgmentResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JudgmentResultImplCopyWith<_$JudgmentResultImpl> get copyWith =>
      __$$JudgmentResultImplCopyWithImpl<_$JudgmentResultImpl>(
        this,
        _$identity,
      );
}

abstract class _JudgmentResult implements JudgmentResult {
  const factory _JudgmentResult({
    required final String id,
    required final String roomId,
    required final String matchId,
    required final TeamScore proTeamScore,
    required final TeamScore conTeamScore,
    final DebateStance? winningSide,
    required final String summary,
    required final DateTime judgedAt,
    required final DateTime createdAt,
    final List<IndividualEvaluation> individualEvaluations,
    final String? mvpUserId,
    final String? keyMoment,
    final String? overallComment,
    final String? proTeamComment,
    final String? conTeamComment,
    final Map<String, dynamic>? aiMetadata,
  }) = _$JudgmentResultImpl;

  @override
  String get id;
  @override
  String get roomId;
  @override
  String get matchId;
  @override
  TeamScore get proTeamScore;
  @override
  TeamScore get conTeamScore;
  @override
  DebateStance? get winningSide;
  @override
  String get summary;
  @override
  DateTime get judgedAt;
  @override
  DateTime get createdAt;
  @override
  List<IndividualEvaluation> get individualEvaluations;
  @override
  String? get mvpUserId;
  @override
  String? get keyMoment; // Cloud Functions互換用コメント
  @override
  String? get overallComment;
  @override
  String? get proTeamComment;
  @override
  String? get conTeamComment;
  @override
  Map<String, dynamic>? get aiMetadata;

  /// Create a copy of JudgmentResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JudgmentResultImplCopyWith<_$JudgmentResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

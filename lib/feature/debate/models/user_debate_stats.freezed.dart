// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_debate_stats.dart';

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
  BadgeType get type => throw _privateConstructorUsedError;
  DateTime get earnedAt => throw _privateConstructorUsedError;

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
  $Res call({BadgeType type, DateTime earnedAt});
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
  $Res call({Object? type = null, Object? earnedAt = null}) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as BadgeType,
            earnedAt: null == earnedAt
                ? _value.earnedAt
                : earnedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
  $Res call({BadgeType type, DateTime earnedAt});
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
  $Res call({Object? type = null, Object? earnedAt = null}) {
    return _then(
      _$EarnedBadgeImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as BadgeType,
        earnedAt: null == earnedAt
            ? _value.earnedAt
            : earnedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EarnedBadgeImpl implements _EarnedBadge {
  const _$EarnedBadgeImpl({required this.type, required this.earnedAt});

  factory _$EarnedBadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EarnedBadgeImplFromJson(json);

  @override
  final BadgeType type;
  @override
  final DateTime earnedAt;

  @override
  String toString() {
    return 'EarnedBadge(type: $type, earnedAt: $earnedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarnedBadgeImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.earnedAt, earnedAt) ||
                other.earnedAt == earnedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, earnedAt);

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
    required final BadgeType type,
    required final DateTime earnedAt,
  }) = _$EarnedBadgeImpl;

  factory _EarnedBadge.fromJson(Map<String, dynamic> json) =
      _$EarnedBadgeImpl.fromJson;

  @override
  BadgeType get type;
  @override
  DateTime get earnedAt;

  /// Create a copy of EarnedBadge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EarnedBadgeImplCopyWith<_$EarnedBadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserDebateStats {
  String get userId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError; // 基本統計
  int get totalDebates => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  int get losses => throw _privateConstructorUsedError;
  int get draws => throw _privateConstructorUsedError;
  double get winRate => throw _privateConstructorUsedError; // ポイント・経験値
  int get totalPoints => throw _privateConstructorUsedError;
  int get currentMonthPoints => throw _privateConstructorUsedError;
  int get experiencePoints => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get currentLevelPoints => throw _privateConstructorUsedError;
  int get pointsToNextLevel => throw _privateConstructorUsedError; // MVP・特別賞
  int get mvpCount => throw _privateConstructorUsedError;
  int get mannerAwardCount => throw _privateConstructorUsedError; // 連勝記録
  int get currentWinStreak => throw _privateConstructorUsedError;
  int get maxWinStreak => throw _privateConstructorUsedError; // 立場別統計
  int get proWins => throw _privateConstructorUsedError;
  int get conWins => throw _privateConstructorUsedError; // 獲得バッジ
  List<DebateBadge> get badges => throw _privateConstructorUsedError;
  List<EarnedBadge> get earnedBadges => throw _privateConstructorUsedError;
  DateTime? get lastDebateAt => throw _privateConstructorUsedError;
  DateTime? get lastMonthlyReset => throw _privateConstructorUsedError; // 平均スコア
  double get avgLogicScore => throw _privateConstructorUsedError;
  double get avgEvidenceScore => throw _privateConstructorUsedError;
  double get avgRebuttalScore => throw _privateConstructorUsedError;
  double get avgPersuasivenessScore => throw _privateConstructorUsedError;
  double get avgMannerScore => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Create a copy of UserDebateStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDebateStatsCopyWith<UserDebateStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDebateStatsCopyWith<$Res> {
  factory $UserDebateStatsCopyWith(
    UserDebateStats value,
    $Res Function(UserDebateStats) then,
  ) = _$UserDebateStatsCopyWithImpl<$Res, UserDebateStats>;
  @useResult
  $Res call({
    String userId,
    DateTime createdAt,
    DateTime updatedAt,
    int totalDebates,
    int wins,
    int losses,
    int draws,
    double winRate,
    int totalPoints,
    int currentMonthPoints,
    int experiencePoints,
    int level,
    int currentLevelPoints,
    int pointsToNextLevel,
    int mvpCount,
    int mannerAwardCount,
    int currentWinStreak,
    int maxWinStreak,
    int proWins,
    int conWins,
    List<DebateBadge> badges,
    List<EarnedBadge> earnedBadges,
    DateTime? lastDebateAt,
    DateTime? lastMonthlyReset,
    double avgLogicScore,
    double avgEvidenceScore,
    double avgRebuttalScore,
    double avgPersuasivenessScore,
    double avgMannerScore,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$UserDebateStatsCopyWithImpl<$Res, $Val extends UserDebateStats>
    implements $UserDebateStatsCopyWith<$Res> {
  _$UserDebateStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDebateStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? totalDebates = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? winRate = null,
    Object? totalPoints = null,
    Object? currentMonthPoints = null,
    Object? experiencePoints = null,
    Object? level = null,
    Object? currentLevelPoints = null,
    Object? pointsToNextLevel = null,
    Object? mvpCount = null,
    Object? mannerAwardCount = null,
    Object? currentWinStreak = null,
    Object? maxWinStreak = null,
    Object? proWins = null,
    Object? conWins = null,
    Object? badges = null,
    Object? earnedBadges = null,
    Object? lastDebateAt = freezed,
    Object? lastMonthlyReset = freezed,
    Object? avgLogicScore = null,
    Object? avgEvidenceScore = null,
    Object? avgRebuttalScore = null,
    Object? avgPersuasivenessScore = null,
    Object? avgMannerScore = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            totalDebates: null == totalDebates
                ? _value.totalDebates
                : totalDebates // ignore: cast_nullable_to_non_nullable
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
            totalPoints: null == totalPoints
                ? _value.totalPoints
                : totalPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            currentMonthPoints: null == currentMonthPoints
                ? _value.currentMonthPoints
                : currentMonthPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            experiencePoints: null == experiencePoints
                ? _value.experiencePoints
                : experiencePoints // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            currentLevelPoints: null == currentLevelPoints
                ? _value.currentLevelPoints
                : currentLevelPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            pointsToNextLevel: null == pointsToNextLevel
                ? _value.pointsToNextLevel
                : pointsToNextLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            mvpCount: null == mvpCount
                ? _value.mvpCount
                : mvpCount // ignore: cast_nullable_to_non_nullable
                      as int,
            mannerAwardCount: null == mannerAwardCount
                ? _value.mannerAwardCount
                : mannerAwardCount // ignore: cast_nullable_to_non_nullable
                      as int,
            currentWinStreak: null == currentWinStreak
                ? _value.currentWinStreak
                : currentWinStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            maxWinStreak: null == maxWinStreak
                ? _value.maxWinStreak
                : maxWinStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            proWins: null == proWins
                ? _value.proWins
                : proWins // ignore: cast_nullable_to_non_nullable
                      as int,
            conWins: null == conWins
                ? _value.conWins
                : conWins // ignore: cast_nullable_to_non_nullable
                      as int,
            badges: null == badges
                ? _value.badges
                : badges // ignore: cast_nullable_to_non_nullable
                      as List<DebateBadge>,
            earnedBadges: null == earnedBadges
                ? _value.earnedBadges
                : earnedBadges // ignore: cast_nullable_to_non_nullable
                      as List<EarnedBadge>,
            lastDebateAt: freezed == lastDebateAt
                ? _value.lastDebateAt
                : lastDebateAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastMonthlyReset: freezed == lastMonthlyReset
                ? _value.lastMonthlyReset
                : lastMonthlyReset // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            avgLogicScore: null == avgLogicScore
                ? _value.avgLogicScore
                : avgLogicScore // ignore: cast_nullable_to_non_nullable
                      as double,
            avgEvidenceScore: null == avgEvidenceScore
                ? _value.avgEvidenceScore
                : avgEvidenceScore // ignore: cast_nullable_to_non_nullable
                      as double,
            avgRebuttalScore: null == avgRebuttalScore
                ? _value.avgRebuttalScore
                : avgRebuttalScore // ignore: cast_nullable_to_non_nullable
                      as double,
            avgPersuasivenessScore: null == avgPersuasivenessScore
                ? _value.avgPersuasivenessScore
                : avgPersuasivenessScore // ignore: cast_nullable_to_non_nullable
                      as double,
            avgMannerScore: null == avgMannerScore
                ? _value.avgMannerScore
                : avgMannerScore // ignore: cast_nullable_to_non_nullable
                      as double,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserDebateStatsImplCopyWith<$Res>
    implements $UserDebateStatsCopyWith<$Res> {
  factory _$$UserDebateStatsImplCopyWith(
    _$UserDebateStatsImpl value,
    $Res Function(_$UserDebateStatsImpl) then,
  ) = __$$UserDebateStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    DateTime createdAt,
    DateTime updatedAt,
    int totalDebates,
    int wins,
    int losses,
    int draws,
    double winRate,
    int totalPoints,
    int currentMonthPoints,
    int experiencePoints,
    int level,
    int currentLevelPoints,
    int pointsToNextLevel,
    int mvpCount,
    int mannerAwardCount,
    int currentWinStreak,
    int maxWinStreak,
    int proWins,
    int conWins,
    List<DebateBadge> badges,
    List<EarnedBadge> earnedBadges,
    DateTime? lastDebateAt,
    DateTime? lastMonthlyReset,
    double avgLogicScore,
    double avgEvidenceScore,
    double avgRebuttalScore,
    double avgPersuasivenessScore,
    double avgMannerScore,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$UserDebateStatsImplCopyWithImpl<$Res>
    extends _$UserDebateStatsCopyWithImpl<$Res, _$UserDebateStatsImpl>
    implements _$$UserDebateStatsImplCopyWith<$Res> {
  __$$UserDebateStatsImplCopyWithImpl(
    _$UserDebateStatsImpl _value,
    $Res Function(_$UserDebateStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserDebateStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? totalDebates = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? winRate = null,
    Object? totalPoints = null,
    Object? currentMonthPoints = null,
    Object? experiencePoints = null,
    Object? level = null,
    Object? currentLevelPoints = null,
    Object? pointsToNextLevel = null,
    Object? mvpCount = null,
    Object? mannerAwardCount = null,
    Object? currentWinStreak = null,
    Object? maxWinStreak = null,
    Object? proWins = null,
    Object? conWins = null,
    Object? badges = null,
    Object? earnedBadges = null,
    Object? lastDebateAt = freezed,
    Object? lastMonthlyReset = freezed,
    Object? avgLogicScore = null,
    Object? avgEvidenceScore = null,
    Object? avgRebuttalScore = null,
    Object? avgPersuasivenessScore = null,
    Object? avgMannerScore = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$UserDebateStatsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        totalDebates: null == totalDebates
            ? _value.totalDebates
            : totalDebates // ignore: cast_nullable_to_non_nullable
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
        totalPoints: null == totalPoints
            ? _value.totalPoints
            : totalPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        currentMonthPoints: null == currentMonthPoints
            ? _value.currentMonthPoints
            : currentMonthPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        experiencePoints: null == experiencePoints
            ? _value.experiencePoints
            : experiencePoints // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        currentLevelPoints: null == currentLevelPoints
            ? _value.currentLevelPoints
            : currentLevelPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        pointsToNextLevel: null == pointsToNextLevel
            ? _value.pointsToNextLevel
            : pointsToNextLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        mvpCount: null == mvpCount
            ? _value.mvpCount
            : mvpCount // ignore: cast_nullable_to_non_nullable
                  as int,
        mannerAwardCount: null == mannerAwardCount
            ? _value.mannerAwardCount
            : mannerAwardCount // ignore: cast_nullable_to_non_nullable
                  as int,
        currentWinStreak: null == currentWinStreak
            ? _value.currentWinStreak
            : currentWinStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        maxWinStreak: null == maxWinStreak
            ? _value.maxWinStreak
            : maxWinStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        proWins: null == proWins
            ? _value.proWins
            : proWins // ignore: cast_nullable_to_non_nullable
                  as int,
        conWins: null == conWins
            ? _value.conWins
            : conWins // ignore: cast_nullable_to_non_nullable
                  as int,
        badges: null == badges
            ? _value._badges
            : badges // ignore: cast_nullable_to_non_nullable
                  as List<DebateBadge>,
        earnedBadges: null == earnedBadges
            ? _value._earnedBadges
            : earnedBadges // ignore: cast_nullable_to_non_nullable
                  as List<EarnedBadge>,
        lastDebateAt: freezed == lastDebateAt
            ? _value.lastDebateAt
            : lastDebateAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastMonthlyReset: freezed == lastMonthlyReset
            ? _value.lastMonthlyReset
            : lastMonthlyReset // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        avgLogicScore: null == avgLogicScore
            ? _value.avgLogicScore
            : avgLogicScore // ignore: cast_nullable_to_non_nullable
                  as double,
        avgEvidenceScore: null == avgEvidenceScore
            ? _value.avgEvidenceScore
            : avgEvidenceScore // ignore: cast_nullable_to_non_nullable
                  as double,
        avgRebuttalScore: null == avgRebuttalScore
            ? _value.avgRebuttalScore
            : avgRebuttalScore // ignore: cast_nullable_to_non_nullable
                  as double,
        avgPersuasivenessScore: null == avgPersuasivenessScore
            ? _value.avgPersuasivenessScore
            : avgPersuasivenessScore // ignore: cast_nullable_to_non_nullable
                  as double,
        avgMannerScore: null == avgMannerScore
            ? _value.avgMannerScore
            : avgMannerScore // ignore: cast_nullable_to_non_nullable
                  as double,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$UserDebateStatsImpl implements _UserDebateStats {
  const _$UserDebateStatsImpl({
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.totalDebates = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winRate = 0.0,
    this.totalPoints = 0,
    this.currentMonthPoints = 0,
    this.experiencePoints = 0,
    this.level = 1,
    this.currentLevelPoints = 0,
    this.pointsToNextLevel = 100,
    this.mvpCount = 0,
    this.mannerAwardCount = 0,
    this.currentWinStreak = 0,
    this.maxWinStreak = 0,
    this.proWins = 0,
    this.conWins = 0,
    final List<DebateBadge> badges = const [],
    final List<EarnedBadge> earnedBadges = const [],
    this.lastDebateAt,
    this.lastMonthlyReset,
    this.avgLogicScore = 0.0,
    this.avgEvidenceScore = 0.0,
    this.avgRebuttalScore = 0.0,
    this.avgPersuasivenessScore = 0.0,
    this.avgMannerScore = 0.0,
    final Map<String, dynamic>? metadata,
  }) : _badges = badges,
       _earnedBadges = earnedBadges,
       _metadata = metadata;

  @override
  final String userId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  // 基本統計
  @override
  @JsonKey()
  final int totalDebates;
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
  // ポイント・経験値
  @override
  @JsonKey()
  final int totalPoints;
  @override
  @JsonKey()
  final int currentMonthPoints;
  @override
  @JsonKey()
  final int experiencePoints;
  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final int currentLevelPoints;
  @override
  @JsonKey()
  final int pointsToNextLevel;
  // MVP・特別賞
  @override
  @JsonKey()
  final int mvpCount;
  @override
  @JsonKey()
  final int mannerAwardCount;
  // 連勝記録
  @override
  @JsonKey()
  final int currentWinStreak;
  @override
  @JsonKey()
  final int maxWinStreak;
  // 立場別統計
  @override
  @JsonKey()
  final int proWins;
  @override
  @JsonKey()
  final int conWins;
  // 獲得バッジ
  final List<DebateBadge> _badges;
  // 獲得バッジ
  @override
  @JsonKey()
  List<DebateBadge> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  final List<EarnedBadge> _earnedBadges;
  @override
  @JsonKey()
  List<EarnedBadge> get earnedBadges {
    if (_earnedBadges is EqualUnmodifiableListView) return _earnedBadges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_earnedBadges);
  }

  @override
  final DateTime? lastDebateAt;
  @override
  final DateTime? lastMonthlyReset;
  // 平均スコア
  @override
  @JsonKey()
  final double avgLogicScore;
  @override
  @JsonKey()
  final double avgEvidenceScore;
  @override
  @JsonKey()
  final double avgRebuttalScore;
  @override
  @JsonKey()
  final double avgPersuasivenessScore;
  @override
  @JsonKey()
  final double avgMannerScore;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'UserDebateStats(userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, totalDebates: $totalDebates, wins: $wins, losses: $losses, draws: $draws, winRate: $winRate, totalPoints: $totalPoints, currentMonthPoints: $currentMonthPoints, experiencePoints: $experiencePoints, level: $level, currentLevelPoints: $currentLevelPoints, pointsToNextLevel: $pointsToNextLevel, mvpCount: $mvpCount, mannerAwardCount: $mannerAwardCount, currentWinStreak: $currentWinStreak, maxWinStreak: $maxWinStreak, proWins: $proWins, conWins: $conWins, badges: $badges, earnedBadges: $earnedBadges, lastDebateAt: $lastDebateAt, lastMonthlyReset: $lastMonthlyReset, avgLogicScore: $avgLogicScore, avgEvidenceScore: $avgEvidenceScore, avgRebuttalScore: $avgRebuttalScore, avgPersuasivenessScore: $avgPersuasivenessScore, avgMannerScore: $avgMannerScore, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDebateStatsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.totalDebates, totalDebates) ||
                other.totalDebates == totalDebates) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.draws, draws) || other.draws == draws) &&
            (identical(other.winRate, winRate) || other.winRate == winRate) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.currentMonthPoints, currentMonthPoints) ||
                other.currentMonthPoints == currentMonthPoints) &&
            (identical(other.experiencePoints, experiencePoints) ||
                other.experiencePoints == experiencePoints) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.currentLevelPoints, currentLevelPoints) ||
                other.currentLevelPoints == currentLevelPoints) &&
            (identical(other.pointsToNextLevel, pointsToNextLevel) ||
                other.pointsToNextLevel == pointsToNextLevel) &&
            (identical(other.mvpCount, mvpCount) ||
                other.mvpCount == mvpCount) &&
            (identical(other.mannerAwardCount, mannerAwardCount) ||
                other.mannerAwardCount == mannerAwardCount) &&
            (identical(other.currentWinStreak, currentWinStreak) ||
                other.currentWinStreak == currentWinStreak) &&
            (identical(other.maxWinStreak, maxWinStreak) ||
                other.maxWinStreak == maxWinStreak) &&
            (identical(other.proWins, proWins) || other.proWins == proWins) &&
            (identical(other.conWins, conWins) || other.conWins == conWins) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            const DeepCollectionEquality().equals(
              other._earnedBadges,
              _earnedBadges,
            ) &&
            (identical(other.lastDebateAt, lastDebateAt) ||
                other.lastDebateAt == lastDebateAt) &&
            (identical(other.lastMonthlyReset, lastMonthlyReset) ||
                other.lastMonthlyReset == lastMonthlyReset) &&
            (identical(other.avgLogicScore, avgLogicScore) ||
                other.avgLogicScore == avgLogicScore) &&
            (identical(other.avgEvidenceScore, avgEvidenceScore) ||
                other.avgEvidenceScore == avgEvidenceScore) &&
            (identical(other.avgRebuttalScore, avgRebuttalScore) ||
                other.avgRebuttalScore == avgRebuttalScore) &&
            (identical(other.avgPersuasivenessScore, avgPersuasivenessScore) ||
                other.avgPersuasivenessScore == avgPersuasivenessScore) &&
            (identical(other.avgMannerScore, avgMannerScore) ||
                other.avgMannerScore == avgMannerScore) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    userId,
    createdAt,
    updatedAt,
    totalDebates,
    wins,
    losses,
    draws,
    winRate,
    totalPoints,
    currentMonthPoints,
    experiencePoints,
    level,
    currentLevelPoints,
    pointsToNextLevel,
    mvpCount,
    mannerAwardCount,
    currentWinStreak,
    maxWinStreak,
    proWins,
    conWins,
    const DeepCollectionEquality().hash(_badges),
    const DeepCollectionEquality().hash(_earnedBadges),
    lastDebateAt,
    lastMonthlyReset,
    avgLogicScore,
    avgEvidenceScore,
    avgRebuttalScore,
    avgPersuasivenessScore,
    avgMannerScore,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of UserDebateStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDebateStatsImplCopyWith<_$UserDebateStatsImpl> get copyWith =>
      __$$UserDebateStatsImplCopyWithImpl<_$UserDebateStatsImpl>(
        this,
        _$identity,
      );
}

abstract class _UserDebateStats implements UserDebateStats {
  const factory _UserDebateStats({
    required final String userId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final int totalDebates,
    final int wins,
    final int losses,
    final int draws,
    final double winRate,
    final int totalPoints,
    final int currentMonthPoints,
    final int experiencePoints,
    final int level,
    final int currentLevelPoints,
    final int pointsToNextLevel,
    final int mvpCount,
    final int mannerAwardCount,
    final int currentWinStreak,
    final int maxWinStreak,
    final int proWins,
    final int conWins,
    final List<DebateBadge> badges,
    final List<EarnedBadge> earnedBadges,
    final DateTime? lastDebateAt,
    final DateTime? lastMonthlyReset,
    final double avgLogicScore,
    final double avgEvidenceScore,
    final double avgRebuttalScore,
    final double avgPersuasivenessScore,
    final double avgMannerScore,
    final Map<String, dynamic>? metadata,
  }) = _$UserDebateStatsImpl;

  @override
  String get userId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt; // 基本統計
  @override
  int get totalDebates;
  @override
  int get wins;
  @override
  int get losses;
  @override
  int get draws;
  @override
  double get winRate; // ポイント・経験値
  @override
  int get totalPoints;
  @override
  int get currentMonthPoints;
  @override
  int get experiencePoints;
  @override
  int get level;
  @override
  int get currentLevelPoints;
  @override
  int get pointsToNextLevel; // MVP・特別賞
  @override
  int get mvpCount;
  @override
  int get mannerAwardCount; // 連勝記録
  @override
  int get currentWinStreak;
  @override
  int get maxWinStreak; // 立場別統計
  @override
  int get proWins;
  @override
  int get conWins; // 獲得バッジ
  @override
  List<DebateBadge> get badges;
  @override
  List<EarnedBadge> get earnedBadges;
  @override
  DateTime? get lastDebateAt;
  @override
  DateTime? get lastMonthlyReset; // 平均スコア
  @override
  double get avgLogicScore;
  @override
  double get avgEvidenceScore;
  @override
  double get avgRebuttalScore;
  @override
  double get avgPersuasivenessScore;
  @override
  double get avgMannerScore;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of UserDebateStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDebateStatsImplCopyWith<_$UserDebateStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RankingEntry _$RankingEntryFromJson(Map<String, dynamic> json) {
  return _RankingEntry.fromJson(json);
}

/// @nodoc
mixin _$RankingEntry {
  String get userId => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;
  String? get userNickname => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError;
  int get totalPoints => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  int get losses => throw _privateConstructorUsedError;
  int get totalDebates => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  String? get userIconUrl => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this RankingEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RankingEntryCopyWith<RankingEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankingEntryCopyWith<$Res> {
  factory $RankingEntryCopyWith(
    RankingEntry value,
    $Res Function(RankingEntry) then,
  ) = _$RankingEntryCopyWithImpl<$Res, RankingEntry>;
  @useResult
  $Res call({
    String userId,
    String? userName,
    String? userNickname,
    int rank,
    int value,
    int totalPoints,
    int wins,
    int losses,
    int totalDebates,
    int level,
    String? userIconUrl,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$RankingEntryCopyWithImpl<$Res, $Val extends RankingEntry>
    implements $RankingEntryCopyWith<$Res> {
  _$RankingEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = freezed,
    Object? userNickname = freezed,
    Object? rank = null,
    Object? value = null,
    Object? totalPoints = null,
    Object? wins = null,
    Object? losses = null,
    Object? totalDebates = null,
    Object? level = null,
    Object? userIconUrl = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            userNickname: freezed == userNickname
                ? _value.userNickname
                : userNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPoints: null == totalPoints
                ? _value.totalPoints
                : totalPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            wins: null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                      as int,
            losses: null == losses
                ? _value.losses
                : losses // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDebates: null == totalDebates
                ? _value.totalDebates
                : totalDebates // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            userIconUrl: freezed == userIconUrl
                ? _value.userIconUrl
                : userIconUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RankingEntryImplCopyWith<$Res>
    implements $RankingEntryCopyWith<$Res> {
  factory _$$RankingEntryImplCopyWith(
    _$RankingEntryImpl value,
    $Res Function(_$RankingEntryImpl) then,
  ) = __$$RankingEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String? userName,
    String? userNickname,
    int rank,
    int value,
    int totalPoints,
    int wins,
    int losses,
    int totalDebates,
    int level,
    String? userIconUrl,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$RankingEntryImplCopyWithImpl<$Res>
    extends _$RankingEntryCopyWithImpl<$Res, _$RankingEntryImpl>
    implements _$$RankingEntryImplCopyWith<$Res> {
  __$$RankingEntryImplCopyWithImpl(
    _$RankingEntryImpl _value,
    $Res Function(_$RankingEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = freezed,
    Object? userNickname = freezed,
    Object? rank = null,
    Object? value = null,
    Object? totalPoints = null,
    Object? wins = null,
    Object? losses = null,
    Object? totalDebates = null,
    Object? level = null,
    Object? userIconUrl = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$RankingEntryImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
        userNickname: freezed == userNickname
            ? _value.userNickname
            : userNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPoints: null == totalPoints
            ? _value.totalPoints
            : totalPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        wins: null == wins
            ? _value.wins
            : wins // ignore: cast_nullable_to_non_nullable
                  as int,
        losses: null == losses
            ? _value.losses
            : losses // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDebates: null == totalDebates
            ? _value.totalDebates
            : totalDebates // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        userIconUrl: freezed == userIconUrl
            ? _value.userIconUrl
            : userIconUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RankingEntryImpl implements _RankingEntry {
  const _$RankingEntryImpl({
    required this.userId,
    this.userName,
    this.userNickname,
    this.rank = 0,
    this.value = 0,
    this.totalPoints = 0,
    this.wins = 0,
    this.losses = 0,
    this.totalDebates = 0,
    this.level = 1,
    this.userIconUrl,
    this.updatedAt,
  });

  factory _$RankingEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RankingEntryImplFromJson(json);

  @override
  final String userId;
  @override
  final String? userName;
  @override
  final String? userNickname;
  @override
  @JsonKey()
  final int rank;
  @override
  @JsonKey()
  final int value;
  @override
  @JsonKey()
  final int totalPoints;
  @override
  @JsonKey()
  final int wins;
  @override
  @JsonKey()
  final int losses;
  @override
  @JsonKey()
  final int totalDebates;
  @override
  @JsonKey()
  final int level;
  @override
  final String? userIconUrl;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'RankingEntry(userId: $userId, userName: $userName, userNickname: $userNickname, rank: $rank, value: $value, totalPoints: $totalPoints, wins: $wins, losses: $losses, totalDebates: $totalDebates, level: $level, userIconUrl: $userIconUrl, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingEntryImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userNickname, userNickname) ||
                other.userNickname == userNickname) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.totalDebates, totalDebates) ||
                other.totalDebates == totalDebates) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.userIconUrl, userIconUrl) ||
                other.userIconUrl == userIconUrl) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    userName,
    userNickname,
    rank,
    value,
    totalPoints,
    wins,
    losses,
    totalDebates,
    level,
    userIconUrl,
    updatedAt,
  );

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RankingEntryImplCopyWith<_$RankingEntryImpl> get copyWith =>
      __$$RankingEntryImplCopyWithImpl<_$RankingEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RankingEntryImplToJson(this);
  }
}

abstract class _RankingEntry implements RankingEntry {
  const factory _RankingEntry({
    required final String userId,
    final String? userName,
    final String? userNickname,
    final int rank,
    final int value,
    final int totalPoints,
    final int wins,
    final int losses,
    final int totalDebates,
    final int level,
    final String? userIconUrl,
    final DateTime? updatedAt,
  }) = _$RankingEntryImpl;

  factory _RankingEntry.fromJson(Map<String, dynamic> json) =
      _$RankingEntryImpl.fromJson;

  @override
  String get userId;
  @override
  String? get userName;
  @override
  String? get userNickname;
  @override
  int get rank;
  @override
  int get value;
  @override
  int get totalPoints;
  @override
  int get wins;
  @override
  int get losses;
  @override
  int get totalDebates;
  @override
  int get level;
  @override
  String? get userIconUrl;
  @override
  DateTime? get updatedAt;

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingEntryImplCopyWith<_$RankingEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StatisticsState {
  bool get isLoading => throw _privateConstructorUsedError;
  UserStatistics? get userStatistics => throw _privateConstructorUsedError;
  DiversityScore? get diversityScore => throw _privateConstructorUsedError;
  StanceDistribution? get stanceDistribution =>
      throw _privateConstructorUsedError;
  ParticipationTrend? get participationTrend =>
      throw _privateConstructorUsedError;
  List<Badge> get earnedBadges => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int? get selectedYear => throw _privateConstructorUsedError;
  int? get selectedMonth => throw _privateConstructorUsedError;

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatisticsStateCopyWith<StatisticsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatisticsStateCopyWith<$Res> {
  factory $StatisticsStateCopyWith(
    StatisticsState value,
    $Res Function(StatisticsState) then,
  ) = _$StatisticsStateCopyWithImpl<$Res, StatisticsState>;
  @useResult
  $Res call({
    bool isLoading,
    UserStatistics? userStatistics,
    DiversityScore? diversityScore,
    StanceDistribution? stanceDistribution,
    ParticipationTrend? participationTrend,
    List<Badge> earnedBadges,
    String? error,
    int? selectedYear,
    int? selectedMonth,
  });

  $UserStatisticsCopyWith<$Res>? get userStatistics;
  $DiversityScoreCopyWith<$Res>? get diversityScore;
  $StanceDistributionCopyWith<$Res>? get stanceDistribution;
  $ParticipationTrendCopyWith<$Res>? get participationTrend;
}

/// @nodoc
class _$StatisticsStateCopyWithImpl<$Res, $Val extends StatisticsState>
    implements $StatisticsStateCopyWith<$Res> {
  _$StatisticsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? userStatistics = freezed,
    Object? diversityScore = freezed,
    Object? stanceDistribution = freezed,
    Object? participationTrend = freezed,
    Object? earnedBadges = null,
    Object? error = freezed,
    Object? selectedYear = freezed,
    Object? selectedMonth = freezed,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            userStatistics: freezed == userStatistics
                ? _value.userStatistics
                : userStatistics // ignore: cast_nullable_to_non_nullable
                      as UserStatistics?,
            diversityScore: freezed == diversityScore
                ? _value.diversityScore
                : diversityScore // ignore: cast_nullable_to_non_nullable
                      as DiversityScore?,
            stanceDistribution: freezed == stanceDistribution
                ? _value.stanceDistribution
                : stanceDistribution // ignore: cast_nullable_to_non_nullable
                      as StanceDistribution?,
            participationTrend: freezed == participationTrend
                ? _value.participationTrend
                : participationTrend // ignore: cast_nullable_to_non_nullable
                      as ParticipationTrend?,
            earnedBadges: null == earnedBadges
                ? _value.earnedBadges
                : earnedBadges // ignore: cast_nullable_to_non_nullable
                      as List<Badge>,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedYear: freezed == selectedYear
                ? _value.selectedYear
                : selectedYear // ignore: cast_nullable_to_non_nullable
                      as int?,
            selectedMonth: freezed == selectedMonth
                ? _value.selectedMonth
                : selectedMonth // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserStatisticsCopyWith<$Res>? get userStatistics {
    if (_value.userStatistics == null) {
      return null;
    }

    return $UserStatisticsCopyWith<$Res>(_value.userStatistics!, (value) {
      return _then(_value.copyWith(userStatistics: value) as $Val);
    });
  }

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiversityScoreCopyWith<$Res>? get diversityScore {
    if (_value.diversityScore == null) {
      return null;
    }

    return $DiversityScoreCopyWith<$Res>(_value.diversityScore!, (value) {
      return _then(_value.copyWith(diversityScore: value) as $Val);
    });
  }

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StanceDistributionCopyWith<$Res>? get stanceDistribution {
    if (_value.stanceDistribution == null) {
      return null;
    }

    return $StanceDistributionCopyWith<$Res>(_value.stanceDistribution!, (
      value,
    ) {
      return _then(_value.copyWith(stanceDistribution: value) as $Val);
    });
  }

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParticipationTrendCopyWith<$Res>? get participationTrend {
    if (_value.participationTrend == null) {
      return null;
    }

    return $ParticipationTrendCopyWith<$Res>(_value.participationTrend!, (
      value,
    ) {
      return _then(_value.copyWith(participationTrend: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StatisticsStateImplCopyWith<$Res>
    implements $StatisticsStateCopyWith<$Res> {
  factory _$$StatisticsStateImplCopyWith(
    _$StatisticsStateImpl value,
    $Res Function(_$StatisticsStateImpl) then,
  ) = __$$StatisticsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    UserStatistics? userStatistics,
    DiversityScore? diversityScore,
    StanceDistribution? stanceDistribution,
    ParticipationTrend? participationTrend,
    List<Badge> earnedBadges,
    String? error,
    int? selectedYear,
    int? selectedMonth,
  });

  @override
  $UserStatisticsCopyWith<$Res>? get userStatistics;
  @override
  $DiversityScoreCopyWith<$Res>? get diversityScore;
  @override
  $StanceDistributionCopyWith<$Res>? get stanceDistribution;
  @override
  $ParticipationTrendCopyWith<$Res>? get participationTrend;
}

/// @nodoc
class __$$StatisticsStateImplCopyWithImpl<$Res>
    extends _$StatisticsStateCopyWithImpl<$Res, _$StatisticsStateImpl>
    implements _$$StatisticsStateImplCopyWith<$Res> {
  __$$StatisticsStateImplCopyWithImpl(
    _$StatisticsStateImpl _value,
    $Res Function(_$StatisticsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? userStatistics = freezed,
    Object? diversityScore = freezed,
    Object? stanceDistribution = freezed,
    Object? participationTrend = freezed,
    Object? earnedBadges = null,
    Object? error = freezed,
    Object? selectedYear = freezed,
    Object? selectedMonth = freezed,
  }) {
    return _then(
      _$StatisticsStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        userStatistics: freezed == userStatistics
            ? _value.userStatistics
            : userStatistics // ignore: cast_nullable_to_non_nullable
                  as UserStatistics?,
        diversityScore: freezed == diversityScore
            ? _value.diversityScore
            : diversityScore // ignore: cast_nullable_to_non_nullable
                  as DiversityScore?,
        stanceDistribution: freezed == stanceDistribution
            ? _value.stanceDistribution
            : stanceDistribution // ignore: cast_nullable_to_non_nullable
                  as StanceDistribution?,
        participationTrend: freezed == participationTrend
            ? _value.participationTrend
            : participationTrend // ignore: cast_nullable_to_non_nullable
                  as ParticipationTrend?,
        earnedBadges: null == earnedBadges
            ? _value._earnedBadges
            : earnedBadges // ignore: cast_nullable_to_non_nullable
                  as List<Badge>,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedYear: freezed == selectedYear
            ? _value.selectedYear
            : selectedYear // ignore: cast_nullable_to_non_nullable
                  as int?,
        selectedMonth: freezed == selectedMonth
            ? _value.selectedMonth
            : selectedMonth // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$StatisticsStateImpl implements _StatisticsState {
  const _$StatisticsStateImpl({
    this.isLoading = false,
    this.userStatistics,
    this.diversityScore,
    this.stanceDistribution,
    this.participationTrend,
    final List<Badge> earnedBadges = const <Badge>[],
    this.error,
    this.selectedYear,
    this.selectedMonth,
  }) : _earnedBadges = earnedBadges;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final UserStatistics? userStatistics;
  @override
  final DiversityScore? diversityScore;
  @override
  final StanceDistribution? stanceDistribution;
  @override
  final ParticipationTrend? participationTrend;
  final List<Badge> _earnedBadges;
  @override
  @JsonKey()
  List<Badge> get earnedBadges {
    if (_earnedBadges is EqualUnmodifiableListView) return _earnedBadges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_earnedBadges);
  }

  @override
  final String? error;
  @override
  final int? selectedYear;
  @override
  final int? selectedMonth;

  @override
  String toString() {
    return 'StatisticsState(isLoading: $isLoading, userStatistics: $userStatistics, diversityScore: $diversityScore, stanceDistribution: $stanceDistribution, participationTrend: $participationTrend, earnedBadges: $earnedBadges, error: $error, selectedYear: $selectedYear, selectedMonth: $selectedMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatisticsStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.userStatistics, userStatistics) ||
                other.userStatistics == userStatistics) &&
            (identical(other.diversityScore, diversityScore) ||
                other.diversityScore == diversityScore) &&
            (identical(other.stanceDistribution, stanceDistribution) ||
                other.stanceDistribution == stanceDistribution) &&
            (identical(other.participationTrend, participationTrend) ||
                other.participationTrend == participationTrend) &&
            const DeepCollectionEquality().equals(
              other._earnedBadges,
              _earnedBadges,
            ) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedYear, selectedYear) ||
                other.selectedYear == selectedYear) &&
            (identical(other.selectedMonth, selectedMonth) ||
                other.selectedMonth == selectedMonth));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    userStatistics,
    diversityScore,
    stanceDistribution,
    participationTrend,
    const DeepCollectionEquality().hash(_earnedBadges),
    error,
    selectedYear,
    selectedMonth,
  );

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatisticsStateImplCopyWith<_$StatisticsStateImpl> get copyWith =>
      __$$StatisticsStateImplCopyWithImpl<_$StatisticsStateImpl>(
        this,
        _$identity,
      );
}

abstract class _StatisticsState implements StatisticsState {
  const factory _StatisticsState({
    final bool isLoading,
    final UserStatistics? userStatistics,
    final DiversityScore? diversityScore,
    final StanceDistribution? stanceDistribution,
    final ParticipationTrend? participationTrend,
    final List<Badge> earnedBadges,
    final String? error,
    final int? selectedYear,
    final int? selectedMonth,
  }) = _$StatisticsStateImpl;

  @override
  bool get isLoading;
  @override
  UserStatistics? get userStatistics;
  @override
  DiversityScore? get diversityScore;
  @override
  StanceDistribution? get stanceDistribution;
  @override
  ParticipationTrend? get participationTrend;
  @override
  List<Badge> get earnedBadges;
  @override
  String? get error;
  @override
  int? get selectedYear;
  @override
  int? get selectedMonth;

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatisticsStateImplCopyWith<_$StatisticsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

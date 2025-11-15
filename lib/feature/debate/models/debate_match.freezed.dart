// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debate_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DebateEntry {
  String get userId => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  DebateDuration get preferredDuration => throw _privateConstructorUsedError;
  DebateFormat get preferredFormat => throw _privateConstructorUsedError;
  DebateStance get preferredStance => throw _privateConstructorUsedError;
  DateTime get enteredAt => throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  String? get matchId => throw _privateConstructorUsedError;

  /// Create a copy of DebateEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebateEntryCopyWith<DebateEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebateEntryCopyWith<$Res> {
  factory $DebateEntryCopyWith(
    DebateEntry value,
    $Res Function(DebateEntry) then,
  ) = _$DebateEntryCopyWithImpl<$Res, DebateEntry>;
  @useResult
  $Res call({
    String userId,
    String eventId,
    DebateDuration preferredDuration,
    DebateFormat preferredFormat,
    DebateStance preferredStance,
    DateTime enteredAt,
    MatchStatus status,
    String? matchId,
  });
}

/// @nodoc
class _$DebateEntryCopyWithImpl<$Res, $Val extends DebateEntry>
    implements $DebateEntryCopyWith<$Res> {
  _$DebateEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebateEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? eventId = null,
    Object? preferredDuration = null,
    Object? preferredFormat = null,
    Object? preferredStance = null,
    Object? enteredAt = null,
    Object? status = null,
    Object? matchId = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            preferredDuration: null == preferredDuration
                ? _value.preferredDuration
                : preferredDuration // ignore: cast_nullable_to_non_nullable
                      as DebateDuration,
            preferredFormat: null == preferredFormat
                ? _value.preferredFormat
                : preferredFormat // ignore: cast_nullable_to_non_nullable
                      as DebateFormat,
            preferredStance: null == preferredStance
                ? _value.preferredStance
                : preferredStance // ignore: cast_nullable_to_non_nullable
                      as DebateStance,
            enteredAt: null == enteredAt
                ? _value.enteredAt
                : enteredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MatchStatus,
            matchId: freezed == matchId
                ? _value.matchId
                : matchId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DebateEntryImplCopyWith<$Res>
    implements $DebateEntryCopyWith<$Res> {
  factory _$$DebateEntryImplCopyWith(
    _$DebateEntryImpl value,
    $Res Function(_$DebateEntryImpl) then,
  ) = __$$DebateEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String eventId,
    DebateDuration preferredDuration,
    DebateFormat preferredFormat,
    DebateStance preferredStance,
    DateTime enteredAt,
    MatchStatus status,
    String? matchId,
  });
}

/// @nodoc
class __$$DebateEntryImplCopyWithImpl<$Res>
    extends _$DebateEntryCopyWithImpl<$Res, _$DebateEntryImpl>
    implements _$$DebateEntryImplCopyWith<$Res> {
  __$$DebateEntryImplCopyWithImpl(
    _$DebateEntryImpl _value,
    $Res Function(_$DebateEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DebateEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? eventId = null,
    Object? preferredDuration = null,
    Object? preferredFormat = null,
    Object? preferredStance = null,
    Object? enteredAt = null,
    Object? status = null,
    Object? matchId = freezed,
  }) {
    return _then(
      _$DebateEntryImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        preferredDuration: null == preferredDuration
            ? _value.preferredDuration
            : preferredDuration // ignore: cast_nullable_to_non_nullable
                  as DebateDuration,
        preferredFormat: null == preferredFormat
            ? _value.preferredFormat
            : preferredFormat // ignore: cast_nullable_to_non_nullable
                  as DebateFormat,
        preferredStance: null == preferredStance
            ? _value.preferredStance
            : preferredStance // ignore: cast_nullable_to_non_nullable
                  as DebateStance,
        enteredAt: null == enteredAt
            ? _value.enteredAt
            : enteredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MatchStatus,
        matchId: freezed == matchId
            ? _value.matchId
            : matchId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DebateEntryImpl implements _DebateEntry {
  const _$DebateEntryImpl({
    required this.userId,
    required this.eventId,
    required this.preferredDuration,
    required this.preferredFormat,
    required this.preferredStance,
    required this.enteredAt,
    this.status = MatchStatus.waiting,
    this.matchId,
  });

  @override
  final String userId;
  @override
  final String eventId;
  @override
  final DebateDuration preferredDuration;
  @override
  final DebateFormat preferredFormat;
  @override
  final DebateStance preferredStance;
  @override
  final DateTime enteredAt;
  @override
  @JsonKey()
  final MatchStatus status;
  @override
  final String? matchId;

  @override
  String toString() {
    return 'DebateEntry(userId: $userId, eventId: $eventId, preferredDuration: $preferredDuration, preferredFormat: $preferredFormat, preferredStance: $preferredStance, enteredAt: $enteredAt, status: $status, matchId: $matchId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebateEntryImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.preferredDuration, preferredDuration) ||
                other.preferredDuration == preferredDuration) &&
            (identical(other.preferredFormat, preferredFormat) ||
                other.preferredFormat == preferredFormat) &&
            (identical(other.preferredStance, preferredStance) ||
                other.preferredStance == preferredStance) &&
            (identical(other.enteredAt, enteredAt) ||
                other.enteredAt == enteredAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.matchId, matchId) || other.matchId == matchId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    eventId,
    preferredDuration,
    preferredFormat,
    preferredStance,
    enteredAt,
    status,
    matchId,
  );

  /// Create a copy of DebateEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebateEntryImplCopyWith<_$DebateEntryImpl> get copyWith =>
      __$$DebateEntryImplCopyWithImpl<_$DebateEntryImpl>(this, _$identity);
}

abstract class _DebateEntry implements DebateEntry {
  const factory _DebateEntry({
    required final String userId,
    required final String eventId,
    required final DebateDuration preferredDuration,
    required final DebateFormat preferredFormat,
    required final DebateStance preferredStance,
    required final DateTime enteredAt,
    final MatchStatus status,
    final String? matchId,
  }) = _$DebateEntryImpl;

  @override
  String get userId;
  @override
  String get eventId;
  @override
  DebateDuration get preferredDuration;
  @override
  DebateFormat get preferredFormat;
  @override
  DebateStance get preferredStance;
  @override
  DateTime get enteredAt;
  @override
  MatchStatus get status;
  @override
  String? get matchId;

  /// Create a copy of DebateEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebateEntryImplCopyWith<_$DebateEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DebateTeam _$DebateTeamFromJson(Map<String, dynamic> json) {
  return _DebateTeam.fromJson(json);
}

/// @nodoc
mixin _$DebateTeam {
  DebateStance get stance => throw _privateConstructorUsedError;
  List<String> get memberIds => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  String? get mvpUserId => throw _privateConstructorUsedError;

  /// Serializes this DebateTeam to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DebateTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebateTeamCopyWith<DebateTeam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebateTeamCopyWith<$Res> {
  factory $DebateTeamCopyWith(
    DebateTeam value,
    $Res Function(DebateTeam) then,
  ) = _$DebateTeamCopyWithImpl<$Res, DebateTeam>;
  @useResult
  $Res call({
    DebateStance stance,
    List<String> memberIds,
    int score,
    String? mvpUserId,
  });
}

/// @nodoc
class _$DebateTeamCopyWithImpl<$Res, $Val extends DebateTeam>
    implements $DebateTeamCopyWith<$Res> {
  _$DebateTeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebateTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stance = null,
    Object? memberIds = null,
    Object? score = null,
    Object? mvpUserId = freezed,
  }) {
    return _then(
      _value.copyWith(
            stance: null == stance
                ? _value.stance
                : stance // ignore: cast_nullable_to_non_nullable
                      as DebateStance,
            memberIds: null == memberIds
                ? _value.memberIds
                : memberIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            mvpUserId: freezed == mvpUserId
                ? _value.mvpUserId
                : mvpUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DebateTeamImplCopyWith<$Res>
    implements $DebateTeamCopyWith<$Res> {
  factory _$$DebateTeamImplCopyWith(
    _$DebateTeamImpl value,
    $Res Function(_$DebateTeamImpl) then,
  ) = __$$DebateTeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DebateStance stance,
    List<String> memberIds,
    int score,
    String? mvpUserId,
  });
}

/// @nodoc
class __$$DebateTeamImplCopyWithImpl<$Res>
    extends _$DebateTeamCopyWithImpl<$Res, _$DebateTeamImpl>
    implements _$$DebateTeamImplCopyWith<$Res> {
  __$$DebateTeamImplCopyWithImpl(
    _$DebateTeamImpl _value,
    $Res Function(_$DebateTeamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DebateTeam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stance = null,
    Object? memberIds = null,
    Object? score = null,
    Object? mvpUserId = freezed,
  }) {
    return _then(
      _$DebateTeamImpl(
        stance: null == stance
            ? _value.stance
            : stance // ignore: cast_nullable_to_non_nullable
                  as DebateStance,
        memberIds: null == memberIds
            ? _value._memberIds
            : memberIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        mvpUserId: freezed == mvpUserId
            ? _value.mvpUserId
            : mvpUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DebateTeamImpl implements _DebateTeam {
  const _$DebateTeamImpl({
    required this.stance,
    required final List<String> memberIds,
    this.score = 0,
    this.mvpUserId,
  }) : _memberIds = memberIds;

  factory _$DebateTeamImpl.fromJson(Map<String, dynamic> json) =>
      _$$DebateTeamImplFromJson(json);

  @override
  final DebateStance stance;
  final List<String> _memberIds;
  @override
  List<String> get memberIds {
    if (_memberIds is EqualUnmodifiableListView) return _memberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberIds);
  }

  @override
  @JsonKey()
  final int score;
  @override
  final String? mvpUserId;

  @override
  String toString() {
    return 'DebateTeam(stance: $stance, memberIds: $memberIds, score: $score, mvpUserId: $mvpUserId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebateTeamImpl &&
            (identical(other.stance, stance) || other.stance == stance) &&
            const DeepCollectionEquality().equals(
              other._memberIds,
              _memberIds,
            ) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.mvpUserId, mvpUserId) ||
                other.mvpUserId == mvpUserId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    stance,
    const DeepCollectionEquality().hash(_memberIds),
    score,
    mvpUserId,
  );

  /// Create a copy of DebateTeam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebateTeamImplCopyWith<_$DebateTeamImpl> get copyWith =>
      __$$DebateTeamImplCopyWithImpl<_$DebateTeamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DebateTeamImplToJson(this);
  }
}

abstract class _DebateTeam implements DebateTeam {
  const factory _DebateTeam({
    required final DebateStance stance,
    required final List<String> memberIds,
    final int score,
    final String? mvpUserId,
  }) = _$DebateTeamImpl;

  factory _DebateTeam.fromJson(Map<String, dynamic> json) =
      _$DebateTeamImpl.fromJson;

  @override
  DebateStance get stance;
  @override
  List<String> get memberIds;
  @override
  int get score;
  @override
  String? get mvpUserId;

  /// Create a copy of DebateTeam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebateTeamImplCopyWith<_$DebateTeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DebateMatch {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  DebateFormat get format => throw _privateConstructorUsedError;
  DebateDuration get duration => throw _privateConstructorUsedError;
  DebateTeam get proTeam => throw _privateConstructorUsedError;
  DebateTeam get conTeam => throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  DateTime get matchedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get roomId => throw _privateConstructorUsedError;
  String? get winningSide => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Create a copy of DebateMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebateMatchCopyWith<DebateMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebateMatchCopyWith<$Res> {
  factory $DebateMatchCopyWith(
    DebateMatch value,
    $Res Function(DebateMatch) then,
  ) = _$DebateMatchCopyWithImpl<$Res, DebateMatch>;
  @useResult
  $Res call({
    String id,
    String eventId,
    DebateFormat format,
    DebateDuration duration,
    DebateTeam proTeam,
    DebateTeam conTeam,
    MatchStatus status,
    DateTime matchedAt,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? roomId,
    String? winningSide,
    Map<String, dynamic>? metadata,
  });

  $DebateTeamCopyWith<$Res> get proTeam;
  $DebateTeamCopyWith<$Res> get conTeam;
}

/// @nodoc
class _$DebateMatchCopyWithImpl<$Res, $Val extends DebateMatch>
    implements $DebateMatchCopyWith<$Res> {
  _$DebateMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebateMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? format = null,
    Object? duration = null,
    Object? proTeam = null,
    Object? conTeam = null,
    Object? status = null,
    Object? matchedAt = null,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? roomId = freezed,
    Object? winningSide = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as DebateFormat,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as DebateDuration,
            proTeam: null == proTeam
                ? _value.proTeam
                : proTeam // ignore: cast_nullable_to_non_nullable
                      as DebateTeam,
            conTeam: null == conTeam
                ? _value.conTeam
                : conTeam // ignore: cast_nullable_to_non_nullable
                      as DebateTeam,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MatchStatus,
            matchedAt: null == matchedAt
                ? _value.matchedAt
                : matchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            roomId: freezed == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String?,
            winningSide: freezed == winningSide
                ? _value.winningSide
                : winningSide // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of DebateMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DebateTeamCopyWith<$Res> get proTeam {
    return $DebateTeamCopyWith<$Res>(_value.proTeam, (value) {
      return _then(_value.copyWith(proTeam: value) as $Val);
    });
  }

  /// Create a copy of DebateMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DebateTeamCopyWith<$Res> get conTeam {
    return $DebateTeamCopyWith<$Res>(_value.conTeam, (value) {
      return _then(_value.copyWith(conTeam: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DebateMatchImplCopyWith<$Res>
    implements $DebateMatchCopyWith<$Res> {
  factory _$$DebateMatchImplCopyWith(
    _$DebateMatchImpl value,
    $Res Function(_$DebateMatchImpl) then,
  ) = __$$DebateMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String eventId,
    DebateFormat format,
    DebateDuration duration,
    DebateTeam proTeam,
    DebateTeam conTeam,
    MatchStatus status,
    DateTime matchedAt,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? roomId,
    String? winningSide,
    Map<String, dynamic>? metadata,
  });

  @override
  $DebateTeamCopyWith<$Res> get proTeam;
  @override
  $DebateTeamCopyWith<$Res> get conTeam;
}

/// @nodoc
class __$$DebateMatchImplCopyWithImpl<$Res>
    extends _$DebateMatchCopyWithImpl<$Res, _$DebateMatchImpl>
    implements _$$DebateMatchImplCopyWith<$Res> {
  __$$DebateMatchImplCopyWithImpl(
    _$DebateMatchImpl _value,
    $Res Function(_$DebateMatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DebateMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? format = null,
    Object? duration = null,
    Object? proTeam = null,
    Object? conTeam = null,
    Object? status = null,
    Object? matchedAt = null,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? roomId = freezed,
    Object? winningSide = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DebateMatchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as DebateFormat,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as DebateDuration,
        proTeam: null == proTeam
            ? _value.proTeam
            : proTeam // ignore: cast_nullable_to_non_nullable
                  as DebateTeam,
        conTeam: null == conTeam
            ? _value.conTeam
            : conTeam // ignore: cast_nullable_to_non_nullable
                  as DebateTeam,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MatchStatus,
        matchedAt: null == matchedAt
            ? _value.matchedAt
            : matchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        roomId: freezed == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String?,
        winningSide: freezed == winningSide
            ? _value.winningSide
            : winningSide // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$DebateMatchImpl implements _DebateMatch {
  const _$DebateMatchImpl({
    required this.id,
    required this.eventId,
    required this.format,
    required this.duration,
    required this.proTeam,
    required this.conTeam,
    required this.status,
    required this.matchedAt,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.roomId,
    this.winningSide,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  @override
  final String id;
  @override
  final String eventId;
  @override
  final DebateFormat format;
  @override
  final DebateDuration duration;
  @override
  final DebateTeam proTeam;
  @override
  final DebateTeam conTeam;
  @override
  final MatchStatus status;
  @override
  final DateTime matchedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? roomId;
  @override
  final String? winningSide;
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
    return 'DebateMatch(id: $id, eventId: $eventId, format: $format, duration: $duration, proTeam: $proTeam, conTeam: $conTeam, status: $status, matchedAt: $matchedAt, createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt, roomId: $roomId, winningSide: $winningSide, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebateMatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.proTeam, proTeam) || other.proTeam == proTeam) &&
            (identical(other.conTeam, conTeam) || other.conTeam == conTeam) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.matchedAt, matchedAt) ||
                other.matchedAt == matchedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.winningSide, winningSide) ||
                other.winningSide == winningSide) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    eventId,
    format,
    duration,
    proTeam,
    conTeam,
    status,
    matchedAt,
    createdAt,
    startedAt,
    completedAt,
    roomId,
    winningSide,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DebateMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebateMatchImplCopyWith<_$DebateMatchImpl> get copyWith =>
      __$$DebateMatchImplCopyWithImpl<_$DebateMatchImpl>(this, _$identity);
}

abstract class _DebateMatch implements DebateMatch {
  const factory _DebateMatch({
    required final String id,
    required final String eventId,
    required final DebateFormat format,
    required final DebateDuration duration,
    required final DebateTeam proTeam,
    required final DebateTeam conTeam,
    required final MatchStatus status,
    required final DateTime matchedAt,
    required final DateTime createdAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final String? roomId,
    final String? winningSide,
    final Map<String, dynamic>? metadata,
  }) = _$DebateMatchImpl;

  @override
  String get id;
  @override
  String get eventId;
  @override
  DebateFormat get format;
  @override
  DebateDuration get duration;
  @override
  DebateTeam get proTeam;
  @override
  DebateTeam get conTeam;
  @override
  MatchStatus get status;
  @override
  DateTime get matchedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String? get roomId;
  @override
  String? get winningSide;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DebateMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebateMatchImplCopyWith<_$DebateMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

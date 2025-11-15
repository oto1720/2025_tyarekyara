// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debate_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DebateRoom {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get matchId => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  Map<String, DebateStance> get participantStances =>
      throw _privateConstructorUsedError;
  RoomStatus get status => throw _privateConstructorUsedError;
  DebatePhase get currentPhase => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get phaseStartedAt => throw _privateConstructorUsedError;
  int get phaseTimeRemaining => throw _privateConstructorUsedError;
  Map<String, int> get messageCount => throw _privateConstructorUsedError;
  Map<String, int> get warningCount => throw _privateConstructorUsedError;
  String? get judgmentId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Create a copy of DebateRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebateRoomCopyWith<DebateRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebateRoomCopyWith<$Res> {
  factory $DebateRoomCopyWith(
    DebateRoom value,
    $Res Function(DebateRoom) then,
  ) = _$DebateRoomCopyWithImpl<$Res, DebateRoom>;
  @useResult
  $Res call({
    String id,
    String eventId,
    String matchId,
    List<String> participantIds,
    Map<String, DebateStance> participantStances,
    RoomStatus status,
    DebatePhase currentPhase,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? phaseStartedAt,
    int phaseTimeRemaining,
    Map<String, int> messageCount,
    Map<String, int> warningCount,
    String? judgmentId,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DebateRoomCopyWithImpl<$Res, $Val extends DebateRoom>
    implements $DebateRoomCopyWith<$Res> {
  _$DebateRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebateRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? matchId = null,
    Object? participantIds = null,
    Object? participantStances = null,
    Object? status = null,
    Object? currentPhase = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? phaseStartedAt = freezed,
    Object? phaseTimeRemaining = null,
    Object? messageCount = null,
    Object? warningCount = null,
    Object? judgmentId = freezed,
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
            matchId: null == matchId
                ? _value.matchId
                : matchId // ignore: cast_nullable_to_non_nullable
                      as String,
            participantIds: null == participantIds
                ? _value.participantIds
                : participantIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            participantStances: null == participantStances
                ? _value.participantStances
                : participantStances // ignore: cast_nullable_to_non_nullable
                      as Map<String, DebateStance>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RoomStatus,
            currentPhase: null == currentPhase
                ? _value.currentPhase
                : currentPhase // ignore: cast_nullable_to_non_nullable
                      as DebatePhase,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            phaseStartedAt: freezed == phaseStartedAt
                ? _value.phaseStartedAt
                : phaseStartedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            phaseTimeRemaining: null == phaseTimeRemaining
                ? _value.phaseTimeRemaining
                : phaseTimeRemaining // ignore: cast_nullable_to_non_nullable
                      as int,
            messageCount: null == messageCount
                ? _value.messageCount
                : messageCount // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            warningCount: null == warningCount
                ? _value.warningCount
                : warningCount // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            judgmentId: freezed == judgmentId
                ? _value.judgmentId
                : judgmentId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$DebateRoomImplCopyWith<$Res>
    implements $DebateRoomCopyWith<$Res> {
  factory _$$DebateRoomImplCopyWith(
    _$DebateRoomImpl value,
    $Res Function(_$DebateRoomImpl) then,
  ) = __$$DebateRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String eventId,
    String matchId,
    List<String> participantIds,
    Map<String, DebateStance> participantStances,
    RoomStatus status,
    DebatePhase currentPhase,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? phaseStartedAt,
    int phaseTimeRemaining,
    Map<String, int> messageCount,
    Map<String, int> warningCount,
    String? judgmentId,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DebateRoomImplCopyWithImpl<$Res>
    extends _$DebateRoomCopyWithImpl<$Res, _$DebateRoomImpl>
    implements _$$DebateRoomImplCopyWith<$Res> {
  __$$DebateRoomImplCopyWithImpl(
    _$DebateRoomImpl _value,
    $Res Function(_$DebateRoomImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DebateRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? matchId = null,
    Object? participantIds = null,
    Object? participantStances = null,
    Object? status = null,
    Object? currentPhase = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? phaseStartedAt = freezed,
    Object? phaseTimeRemaining = null,
    Object? messageCount = null,
    Object? warningCount = null,
    Object? judgmentId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DebateRoomImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        matchId: null == matchId
            ? _value.matchId
            : matchId // ignore: cast_nullable_to_non_nullable
                  as String,
        participantIds: null == participantIds
            ? _value._participantIds
            : participantIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        participantStances: null == participantStances
            ? _value._participantStances
            : participantStances // ignore: cast_nullable_to_non_nullable
                  as Map<String, DebateStance>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RoomStatus,
        currentPhase: null == currentPhase
            ? _value.currentPhase
            : currentPhase // ignore: cast_nullable_to_non_nullable
                  as DebatePhase,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        phaseStartedAt: freezed == phaseStartedAt
            ? _value.phaseStartedAt
            : phaseStartedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        phaseTimeRemaining: null == phaseTimeRemaining
            ? _value.phaseTimeRemaining
            : phaseTimeRemaining // ignore: cast_nullable_to_non_nullable
                  as int,
        messageCount: null == messageCount
            ? _value._messageCount
            : messageCount // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        warningCount: null == warningCount
            ? _value._warningCount
            : warningCount // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        judgmentId: freezed == judgmentId
            ? _value.judgmentId
            : judgmentId // ignore: cast_nullable_to_non_nullable
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

class _$DebateRoomImpl implements _DebateRoom {
  const _$DebateRoomImpl({
    required this.id,
    required this.eventId,
    required this.matchId,
    required final List<String> participantIds,
    required final Map<String, DebateStance> participantStances,
    required this.status,
    required this.currentPhase,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.phaseStartedAt,
    this.phaseTimeRemaining = 0,
    final Map<String, int> messageCount = const {},
    final Map<String, int> warningCount = const {},
    this.judgmentId,
    final Map<String, dynamic>? metadata,
  }) : _participantIds = participantIds,
       _participantStances = participantStances,
       _messageCount = messageCount,
       _warningCount = warningCount,
       _metadata = metadata;

  @override
  final String id;
  @override
  final String eventId;
  @override
  final String matchId;
  final List<String> _participantIds;
  @override
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  final Map<String, DebateStance> _participantStances;
  @override
  Map<String, DebateStance> get participantStances {
    if (_participantStances is EqualUnmodifiableMapView)
      return _participantStances;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_participantStances);
  }

  @override
  final RoomStatus status;
  @override
  final DebatePhase currentPhase;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? phaseStartedAt;
  @override
  @JsonKey()
  final int phaseTimeRemaining;
  final Map<String, int> _messageCount;
  @override
  @JsonKey()
  Map<String, int> get messageCount {
    if (_messageCount is EqualUnmodifiableMapView) return _messageCount;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_messageCount);
  }

  final Map<String, int> _warningCount;
  @override
  @JsonKey()
  Map<String, int> get warningCount {
    if (_warningCount is EqualUnmodifiableMapView) return _warningCount;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_warningCount);
  }

  @override
  final String? judgmentId;
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
    return 'DebateRoom(id: $id, eventId: $eventId, matchId: $matchId, participantIds: $participantIds, participantStances: $participantStances, status: $status, currentPhase: $currentPhase, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, completedAt: $completedAt, phaseStartedAt: $phaseStartedAt, phaseTimeRemaining: $phaseTimeRemaining, messageCount: $messageCount, warningCount: $warningCount, judgmentId: $judgmentId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebateRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            const DeepCollectionEquality().equals(
              other._participantIds,
              _participantIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._participantStances,
              _participantStances,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentPhase, currentPhase) ||
                other.currentPhase == currentPhase) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.phaseStartedAt, phaseStartedAt) ||
                other.phaseStartedAt == phaseStartedAt) &&
            (identical(other.phaseTimeRemaining, phaseTimeRemaining) ||
                other.phaseTimeRemaining == phaseTimeRemaining) &&
            const DeepCollectionEquality().equals(
              other._messageCount,
              _messageCount,
            ) &&
            const DeepCollectionEquality().equals(
              other._warningCount,
              _warningCount,
            ) &&
            (identical(other.judgmentId, judgmentId) ||
                other.judgmentId == judgmentId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    eventId,
    matchId,
    const DeepCollectionEquality().hash(_participantIds),
    const DeepCollectionEquality().hash(_participantStances),
    status,
    currentPhase,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
    phaseStartedAt,
    phaseTimeRemaining,
    const DeepCollectionEquality().hash(_messageCount),
    const DeepCollectionEquality().hash(_warningCount),
    judgmentId,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DebateRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebateRoomImplCopyWith<_$DebateRoomImpl> get copyWith =>
      __$$DebateRoomImplCopyWithImpl<_$DebateRoomImpl>(this, _$identity);
}

abstract class _DebateRoom implements DebateRoom {
  const factory _DebateRoom({
    required final String id,
    required final String eventId,
    required final String matchId,
    required final List<String> participantIds,
    required final Map<String, DebateStance> participantStances,
    required final RoomStatus status,
    required final DebatePhase currentPhase,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final DateTime? phaseStartedAt,
    final int phaseTimeRemaining,
    final Map<String, int> messageCount,
    final Map<String, int> warningCount,
    final String? judgmentId,
    final Map<String, dynamic>? metadata,
  }) = _$DebateRoomImpl;

  @override
  String get id;
  @override
  String get eventId;
  @override
  String get matchId;
  @override
  List<String> get participantIds;
  @override
  Map<String, DebateStance> get participantStances;
  @override
  RoomStatus get status;
  @override
  DebatePhase get currentPhase;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get phaseStartedAt;
  @override
  int get phaseTimeRemaining;
  @override
  Map<String, int> get messageCount;
  @override
  Map<String, int> get warningCount;
  @override
  String? get judgmentId;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DebateRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebateRoomImplCopyWith<_$DebateRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

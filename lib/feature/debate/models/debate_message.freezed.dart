// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debate_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DebateMessage {
  String get id => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  DebatePhase get phase => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  MessageStatus get status => throw _privateConstructorUsedError;
  String? get userNickname => throw _privateConstructorUsedError;
  DebateStance? get senderStance => throw _privateConstructorUsedError;
  bool? get isWarning => throw _privateConstructorUsedError;
  String? get flagReason => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Create a copy of DebateMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebateMessageCopyWith<DebateMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebateMessageCopyWith<$Res> {
  factory $DebateMessageCopyWith(
    DebateMessage value,
    $Res Function(DebateMessage) then,
  ) = _$DebateMessageCopyWithImpl<$Res, DebateMessage>;
  @useResult
  $Res call({
    String id,
    String roomId,
    String userId,
    String content,
    MessageType type,
    DebatePhase phase,
    DateTime createdAt,
    MessageStatus status,
    String? userNickname,
    DebateStance? senderStance,
    bool? isWarning,
    String? flagReason,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DebateMessageCopyWithImpl<$Res, $Val extends DebateMessage>
    implements $DebateMessageCopyWith<$Res> {
  _$DebateMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebateMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? userId = null,
    Object? content = null,
    Object? type = null,
    Object? phase = null,
    Object? createdAt = null,
    Object? status = null,
    Object? userNickname = freezed,
    Object? senderStance = freezed,
    Object? isWarning = freezed,
    Object? flagReason = freezed,
    Object? metadata = freezed,
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
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MessageType,
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as DebatePhase,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MessageStatus,
            userNickname: freezed == userNickname
                ? _value.userNickname
                : userNickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderStance: freezed == senderStance
                ? _value.senderStance
                : senderStance // ignore: cast_nullable_to_non_nullable
                      as DebateStance?,
            isWarning: freezed == isWarning
                ? _value.isWarning
                : isWarning // ignore: cast_nullable_to_non_nullable
                      as bool?,
            flagReason: freezed == flagReason
                ? _value.flagReason
                : flagReason // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DebateMessageImplCopyWith<$Res>
    implements $DebateMessageCopyWith<$Res> {
  factory _$$DebateMessageImplCopyWith(
    _$DebateMessageImpl value,
    $Res Function(_$DebateMessageImpl) then,
  ) = __$$DebateMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String roomId,
    String userId,
    String content,
    MessageType type,
    DebatePhase phase,
    DateTime createdAt,
    MessageStatus status,
    String? userNickname,
    DebateStance? senderStance,
    bool? isWarning,
    String? flagReason,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DebateMessageImplCopyWithImpl<$Res>
    extends _$DebateMessageCopyWithImpl<$Res, _$DebateMessageImpl>
    implements _$$DebateMessageImplCopyWith<$Res> {
  __$$DebateMessageImplCopyWithImpl(
    _$DebateMessageImpl _value,
    $Res Function(_$DebateMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DebateMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? userId = null,
    Object? content = null,
    Object? type = null,
    Object? phase = null,
    Object? createdAt = null,
    Object? status = null,
    Object? userNickname = freezed,
    Object? senderStance = freezed,
    Object? isWarning = freezed,
    Object? flagReason = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DebateMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        roomId: null == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MessageType,
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as DebatePhase,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MessageStatus,
        userNickname: freezed == userNickname
            ? _value.userNickname
            : userNickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        senderStance: freezed == senderStance
            ? _value.senderStance
            : senderStance // ignore: cast_nullable_to_non_nullable
                  as DebateStance?,
        isWarning: freezed == isWarning
            ? _value.isWarning
            : isWarning // ignore: cast_nullable_to_non_nullable
                  as bool?,
        flagReason: freezed == flagReason
            ? _value.flagReason
            : flagReason // ignore: cast_nullable_to_non_nullable
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

class _$DebateMessageImpl implements _DebateMessage {
  const _$DebateMessageImpl({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.content,
    required this.type,
    required this.phase,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.userNickname,
    this.senderStance,
    this.isWarning,
    this.flagReason,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  @override
  final String id;
  @override
  final String roomId;
  @override
  final String userId;
  @override
  final String content;
  @override
  final MessageType type;
  @override
  final DebatePhase phase;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final MessageStatus status;
  @override
  final String? userNickname;
  @override
  final DebateStance? senderStance;
  @override
  final bool? isWarning;
  @override
  final String? flagReason;
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
    return 'DebateMessage(id: $id, roomId: $roomId, userId: $userId, content: $content, type: $type, phase: $phase, createdAt: $createdAt, status: $status, userNickname: $userNickname, senderStance: $senderStance, isWarning: $isWarning, flagReason: $flagReason, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebateMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.userNickname, userNickname) ||
                other.userNickname == userNickname) &&
            (identical(other.senderStance, senderStance) ||
                other.senderStance == senderStance) &&
            (identical(other.isWarning, isWarning) ||
                other.isWarning == isWarning) &&
            (identical(other.flagReason, flagReason) ||
                other.flagReason == flagReason) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    roomId,
    userId,
    content,
    type,
    phase,
    createdAt,
    status,
    userNickname,
    senderStance,
    isWarning,
    flagReason,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DebateMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebateMessageImplCopyWith<_$DebateMessageImpl> get copyWith =>
      __$$DebateMessageImplCopyWithImpl<_$DebateMessageImpl>(this, _$identity);
}

abstract class _DebateMessage implements DebateMessage {
  const factory _DebateMessage({
    required final String id,
    required final String roomId,
    required final String userId,
    required final String content,
    required final MessageType type,
    required final DebatePhase phase,
    required final DateTime createdAt,
    final MessageStatus status,
    final String? userNickname,
    final DebateStance? senderStance,
    final bool? isWarning,
    final String? flagReason,
    final Map<String, dynamic>? metadata,
  }) = _$DebateMessageImpl;

  @override
  String get id;
  @override
  String get roomId;
  @override
  String get userId;
  @override
  String get content;
  @override
  MessageType get type;
  @override
  DebatePhase get phase;
  @override
  DateTime get createdAt;
  @override
  MessageStatus get status;
  @override
  String? get userNickname;
  @override
  DebateStance? get senderStance;
  @override
  bool? get isWarning;
  @override
  String? get flagReason;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DebateMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebateMessageImplCopyWith<_$DebateMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageLimits _$MessageLimitsFromJson(Map<String, dynamic> json) {
  return _MessageLimits.fromJson(json);
}

/// @nodoc
mixin _$MessageLimits {
  int get maxCharacters => throw _privateConstructorUsedError;
  Map<DebatePhase, int> get maxMessagesPerPhase =>
      throw _privateConstructorUsedError;
  int get maxWarnings => throw _privateConstructorUsedError;
  int get cooldownSeconds => throw _privateConstructorUsedError;

  /// Serializes this MessageLimits to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageLimits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageLimitsCopyWith<MessageLimits> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageLimitsCopyWith<$Res> {
  factory $MessageLimitsCopyWith(
    MessageLimits value,
    $Res Function(MessageLimits) then,
  ) = _$MessageLimitsCopyWithImpl<$Res, MessageLimits>;
  @useResult
  $Res call({
    int maxCharacters,
    Map<DebatePhase, int> maxMessagesPerPhase,
    int maxWarnings,
    int cooldownSeconds,
  });
}

/// @nodoc
class _$MessageLimitsCopyWithImpl<$Res, $Val extends MessageLimits>
    implements $MessageLimitsCopyWith<$Res> {
  _$MessageLimitsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageLimits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxCharacters = null,
    Object? maxMessagesPerPhase = null,
    Object? maxWarnings = null,
    Object? cooldownSeconds = null,
  }) {
    return _then(
      _value.copyWith(
            maxCharacters: null == maxCharacters
                ? _value.maxCharacters
                : maxCharacters // ignore: cast_nullable_to_non_nullable
                      as int,
            maxMessagesPerPhase: null == maxMessagesPerPhase
                ? _value.maxMessagesPerPhase
                : maxMessagesPerPhase // ignore: cast_nullable_to_non_nullable
                      as Map<DebatePhase, int>,
            maxWarnings: null == maxWarnings
                ? _value.maxWarnings
                : maxWarnings // ignore: cast_nullable_to_non_nullable
                      as int,
            cooldownSeconds: null == cooldownSeconds
                ? _value.cooldownSeconds
                : cooldownSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageLimitsImplCopyWith<$Res>
    implements $MessageLimitsCopyWith<$Res> {
  factory _$$MessageLimitsImplCopyWith(
    _$MessageLimitsImpl value,
    $Res Function(_$MessageLimitsImpl) then,
  ) = __$$MessageLimitsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int maxCharacters,
    Map<DebatePhase, int> maxMessagesPerPhase,
    int maxWarnings,
    int cooldownSeconds,
  });
}

/// @nodoc
class __$$MessageLimitsImplCopyWithImpl<$Res>
    extends _$MessageLimitsCopyWithImpl<$Res, _$MessageLimitsImpl>
    implements _$$MessageLimitsImplCopyWith<$Res> {
  __$$MessageLimitsImplCopyWithImpl(
    _$MessageLimitsImpl _value,
    $Res Function(_$MessageLimitsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageLimits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxCharacters = null,
    Object? maxMessagesPerPhase = null,
    Object? maxWarnings = null,
    Object? cooldownSeconds = null,
  }) {
    return _then(
      _$MessageLimitsImpl(
        maxCharacters: null == maxCharacters
            ? _value.maxCharacters
            : maxCharacters // ignore: cast_nullable_to_non_nullable
                  as int,
        maxMessagesPerPhase: null == maxMessagesPerPhase
            ? _value._maxMessagesPerPhase
            : maxMessagesPerPhase // ignore: cast_nullable_to_non_nullable
                  as Map<DebatePhase, int>,
        maxWarnings: null == maxWarnings
            ? _value.maxWarnings
            : maxWarnings // ignore: cast_nullable_to_non_nullable
                  as int,
        cooldownSeconds: null == cooldownSeconds
            ? _value.cooldownSeconds
            : cooldownSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageLimitsImpl implements _MessageLimits {
  const _$MessageLimitsImpl({
    this.maxCharacters = 200,
    final Map<DebatePhase, int> maxMessagesPerPhase = const {},
    this.maxWarnings = 3,
    this.cooldownSeconds = 30,
  }) : _maxMessagesPerPhase = maxMessagesPerPhase;

  factory _$MessageLimitsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageLimitsImplFromJson(json);

  @override
  @JsonKey()
  final int maxCharacters;
  final Map<DebatePhase, int> _maxMessagesPerPhase;
  @override
  @JsonKey()
  Map<DebatePhase, int> get maxMessagesPerPhase {
    if (_maxMessagesPerPhase is EqualUnmodifiableMapView)
      return _maxMessagesPerPhase;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_maxMessagesPerPhase);
  }

  @override
  @JsonKey()
  final int maxWarnings;
  @override
  @JsonKey()
  final int cooldownSeconds;

  @override
  String toString() {
    return 'MessageLimits(maxCharacters: $maxCharacters, maxMessagesPerPhase: $maxMessagesPerPhase, maxWarnings: $maxWarnings, cooldownSeconds: $cooldownSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageLimitsImpl &&
            (identical(other.maxCharacters, maxCharacters) ||
                other.maxCharacters == maxCharacters) &&
            const DeepCollectionEquality().equals(
              other._maxMessagesPerPhase,
              _maxMessagesPerPhase,
            ) &&
            (identical(other.maxWarnings, maxWarnings) ||
                other.maxWarnings == maxWarnings) &&
            (identical(other.cooldownSeconds, cooldownSeconds) ||
                other.cooldownSeconds == cooldownSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    maxCharacters,
    const DeepCollectionEquality().hash(_maxMessagesPerPhase),
    maxWarnings,
    cooldownSeconds,
  );

  /// Create a copy of MessageLimits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageLimitsImplCopyWith<_$MessageLimitsImpl> get copyWith =>
      __$$MessageLimitsImplCopyWithImpl<_$MessageLimitsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageLimitsImplToJson(this);
  }
}

abstract class _MessageLimits implements MessageLimits {
  const factory _MessageLimits({
    final int maxCharacters,
    final Map<DebatePhase, int> maxMessagesPerPhase,
    final int maxWarnings,
    final int cooldownSeconds,
  }) = _$MessageLimitsImpl;

  factory _MessageLimits.fromJson(Map<String, dynamic> json) =
      _$MessageLimitsImpl.fromJson;

  @override
  int get maxCharacters;
  @override
  Map<DebatePhase, int> get maxMessagesPerPhase;
  @override
  int get maxWarnings;
  @override
  int get cooldownSeconds;

  /// Create a copy of MessageLimits
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageLimitsImplCopyWith<_$MessageLimitsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

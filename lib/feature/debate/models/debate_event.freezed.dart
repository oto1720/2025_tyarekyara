// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debate_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DebateEvent {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  EventStatus get status => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  DateTime get entryDeadline => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<DebateDuration> get availableDurations =>
      throw _privateConstructorUsedError;
  List<DebateFormat> get availableFormats => throw _privateConstructorUsedError;
  int get currentParticipants => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Create a copy of DebateEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebateEventCopyWith<DebateEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebateEventCopyWith<$Res> {
  factory $DebateEventCopyWith(
    DebateEvent value,
    $Res Function(DebateEvent) then,
  ) = _$DebateEventCopyWithImpl<$Res, DebateEvent>;
  @useResult
  $Res call({
    String id,
    String title,
    String topic,
    String description,
    EventStatus status,
    DateTime scheduledAt,
    DateTime entryDeadline,
    DateTime createdAt,
    DateTime updatedAt,
    List<DebateDuration> availableDurations,
    List<DebateFormat> availableFormats,
    int currentParticipants,
    int maxParticipants,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DebateEventCopyWithImpl<$Res, $Val extends DebateEvent>
    implements $DebateEventCopyWith<$Res> {
  _$DebateEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebateEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? topic = null,
    Object? description = null,
    Object? status = null,
    Object? scheduledAt = null,
    Object? entryDeadline = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? availableDurations = null,
    Object? availableFormats = null,
    Object? currentParticipants = null,
    Object? maxParticipants = null,
    Object? imageUrl = freezed,
    Object? metadata = freezed,
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
            topic: null == topic
                ? _value.topic
                : topic // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EventStatus,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            entryDeadline: null == entryDeadline
                ? _value.entryDeadline
                : entryDeadline // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            availableDurations: null == availableDurations
                ? _value.availableDurations
                : availableDurations // ignore: cast_nullable_to_non_nullable
                      as List<DebateDuration>,
            availableFormats: null == availableFormats
                ? _value.availableFormats
                : availableFormats // ignore: cast_nullable_to_non_nullable
                      as List<DebateFormat>,
            currentParticipants: null == currentParticipants
                ? _value.currentParticipants
                : currentParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
            maxParticipants: null == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DebateEventImplCopyWith<$Res>
    implements $DebateEventCopyWith<$Res> {
  factory _$$DebateEventImplCopyWith(
    _$DebateEventImpl value,
    $Res Function(_$DebateEventImpl) then,
  ) = __$$DebateEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String topic,
    String description,
    EventStatus status,
    DateTime scheduledAt,
    DateTime entryDeadline,
    DateTime createdAt,
    DateTime updatedAt,
    List<DebateDuration> availableDurations,
    List<DebateFormat> availableFormats,
    int currentParticipants,
    int maxParticipants,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DebateEventImplCopyWithImpl<$Res>
    extends _$DebateEventCopyWithImpl<$Res, _$DebateEventImpl>
    implements _$$DebateEventImplCopyWith<$Res> {
  __$$DebateEventImplCopyWithImpl(
    _$DebateEventImpl _value,
    $Res Function(_$DebateEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DebateEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? topic = null,
    Object? description = null,
    Object? status = null,
    Object? scheduledAt = null,
    Object? entryDeadline = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? availableDurations = null,
    Object? availableFormats = null,
    Object? currentParticipants = null,
    Object? maxParticipants = null,
    Object? imageUrl = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DebateEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EventStatus,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        entryDeadline: null == entryDeadline
            ? _value.entryDeadline
            : entryDeadline // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        availableDurations: null == availableDurations
            ? _value._availableDurations
            : availableDurations // ignore: cast_nullable_to_non_nullable
                  as List<DebateDuration>,
        availableFormats: null == availableFormats
            ? _value._availableFormats
            : availableFormats // ignore: cast_nullable_to_non_nullable
                  as List<DebateFormat>,
        currentParticipants: null == currentParticipants
            ? _value.currentParticipants
            : currentParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
        maxParticipants: null == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
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

class _$DebateEventImpl implements _DebateEvent {
  const _$DebateEventImpl({
    required this.id,
    required this.title,
    required this.topic,
    required this.description,
    required this.status,
    required this.scheduledAt,
    required this.entryDeadline,
    required this.createdAt,
    required this.updatedAt,
    final List<DebateDuration> availableDurations = const [],
    final List<DebateFormat> availableFormats = const [],
    this.currentParticipants = 0,
    this.maxParticipants = 100,
    this.imageUrl,
    final Map<String, dynamic>? metadata,
  }) : _availableDurations = availableDurations,
       _availableFormats = availableFormats,
       _metadata = metadata;

  @override
  final String id;
  @override
  final String title;
  @override
  final String topic;
  @override
  final String description;
  @override
  final EventStatus status;
  @override
  final DateTime scheduledAt;
  @override
  final DateTime entryDeadline;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final List<DebateDuration> _availableDurations;
  @override
  @JsonKey()
  List<DebateDuration> get availableDurations {
    if (_availableDurations is EqualUnmodifiableListView)
      return _availableDurations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableDurations);
  }

  final List<DebateFormat> _availableFormats;
  @override
  @JsonKey()
  List<DebateFormat> get availableFormats {
    if (_availableFormats is EqualUnmodifiableListView)
      return _availableFormats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableFormats);
  }

  @override
  @JsonKey()
  final int currentParticipants;
  @override
  @JsonKey()
  final int maxParticipants;
  @override
  final String? imageUrl;
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
    return 'DebateEvent(id: $id, title: $title, topic: $topic, description: $description, status: $status, scheduledAt: $scheduledAt, entryDeadline: $entryDeadline, createdAt: $createdAt, updatedAt: $updatedAt, availableDurations: $availableDurations, availableFormats: $availableFormats, currentParticipants: $currentParticipants, maxParticipants: $maxParticipants, imageUrl: $imageUrl, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebateEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.entryDeadline, entryDeadline) ||
                other.entryDeadline == entryDeadline) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._availableDurations,
              _availableDurations,
            ) &&
            const DeepCollectionEquality().equals(
              other._availableFormats,
              _availableFormats,
            ) &&
            (identical(other.currentParticipants, currentParticipants) ||
                other.currentParticipants == currentParticipants) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    topic,
    description,
    status,
    scheduledAt,
    entryDeadline,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_availableDurations),
    const DeepCollectionEquality().hash(_availableFormats),
    currentParticipants,
    maxParticipants,
    imageUrl,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DebateEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebateEventImplCopyWith<_$DebateEventImpl> get copyWith =>
      __$$DebateEventImplCopyWithImpl<_$DebateEventImpl>(this, _$identity);
}

abstract class _DebateEvent implements DebateEvent {
  const factory _DebateEvent({
    required final String id,
    required final String title,
    required final String topic,
    required final String description,
    required final EventStatus status,
    required final DateTime scheduledAt,
    required final DateTime entryDeadline,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final List<DebateDuration> availableDurations,
    final List<DebateFormat> availableFormats,
    final int currentParticipants,
    final int maxParticipants,
    final String? imageUrl,
    final Map<String, dynamic>? metadata,
  }) = _$DebateEventImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get topic;
  @override
  String get description;
  @override
  EventStatus get status;
  @override
  DateTime get scheduledAt;
  @override
  DateTime get entryDeadline;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  List<DebateDuration> get availableDurations;
  @override
  List<DebateFormat> get availableFormats;
  @override
  int get currentParticipants;
  @override
  int get maxParticipants;
  @override
  String? get imageUrl;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DebateEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebateEventImplCopyWith<_$DebateEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

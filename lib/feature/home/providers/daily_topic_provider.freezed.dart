// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_topic_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyTopicState {
  Topic? get currentTopic => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isGenerating => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of DailyTopicState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyTopicStateCopyWith<DailyTopicState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyTopicStateCopyWith<$Res> {
  factory $DailyTopicStateCopyWith(
    DailyTopicState value,
    $Res Function(DailyTopicState) then,
  ) = _$DailyTopicStateCopyWithImpl<$Res, DailyTopicState>;
  @useResult
  $Res call({
    Topic? currentTopic,
    bool isLoading,
    bool isGenerating,
    String? error,
  });

  $TopicCopyWith<$Res>? get currentTopic;
}

/// @nodoc
class _$DailyTopicStateCopyWithImpl<$Res, $Val extends DailyTopicState>
    implements $DailyTopicStateCopyWith<$Res> {
  _$DailyTopicStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyTopicState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentTopic = freezed,
    Object? isLoading = null,
    Object? isGenerating = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentTopic: freezed == currentTopic
                ? _value.currentTopic
                : currentTopic // ignore: cast_nullable_to_non_nullable
                      as Topic?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isGenerating: null == isGenerating
                ? _value.isGenerating
                : isGenerating // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of DailyTopicState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TopicCopyWith<$Res>? get currentTopic {
    if (_value.currentTopic == null) {
      return null;
    }

    return $TopicCopyWith<$Res>(_value.currentTopic!, (value) {
      return _then(_value.copyWith(currentTopic: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyTopicStateImplCopyWith<$Res>
    implements $DailyTopicStateCopyWith<$Res> {
  factory _$$DailyTopicStateImplCopyWith(
    _$DailyTopicStateImpl value,
    $Res Function(_$DailyTopicStateImpl) then,
  ) = __$$DailyTopicStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Topic? currentTopic,
    bool isLoading,
    bool isGenerating,
    String? error,
  });

  @override
  $TopicCopyWith<$Res>? get currentTopic;
}

/// @nodoc
class __$$DailyTopicStateImplCopyWithImpl<$Res>
    extends _$DailyTopicStateCopyWithImpl<$Res, _$DailyTopicStateImpl>
    implements _$$DailyTopicStateImplCopyWith<$Res> {
  __$$DailyTopicStateImplCopyWithImpl(
    _$DailyTopicStateImpl _value,
    $Res Function(_$DailyTopicStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyTopicState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentTopic = freezed,
    Object? isLoading = null,
    Object? isGenerating = null,
    Object? error = freezed,
  }) {
    return _then(
      _$DailyTopicStateImpl(
        currentTopic: freezed == currentTopic
            ? _value.currentTopic
            : currentTopic // ignore: cast_nullable_to_non_nullable
                  as Topic?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isGenerating: null == isGenerating
            ? _value.isGenerating
            : isGenerating // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DailyTopicStateImpl implements _DailyTopicState {
  const _$DailyTopicStateImpl({
    this.currentTopic,
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
  });

  @override
  final Topic? currentTopic;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isGenerating;
  @override
  final String? error;

  @override
  String toString() {
    return 'DailyTopicState(currentTopic: $currentTopic, isLoading: $isLoading, isGenerating: $isGenerating, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyTopicStateImpl &&
            (identical(other.currentTopic, currentTopic) ||
                other.currentTopic == currentTopic) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isGenerating, isGenerating) ||
                other.isGenerating == isGenerating) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, currentTopic, isLoading, isGenerating, error);

  /// Create a copy of DailyTopicState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyTopicStateImplCopyWith<_$DailyTopicStateImpl> get copyWith =>
      __$$DailyTopicStateImplCopyWithImpl<_$DailyTopicStateImpl>(
        this,
        _$identity,
      );
}

abstract class _DailyTopicState implements DailyTopicState {
  const factory _DailyTopicState({
    final Topic? currentTopic,
    final bool isLoading,
    final bool isGenerating,
    final String? error,
  }) = _$DailyTopicStateImpl;

  @override
  Topic? get currentTopic;
  @override
  bool get isLoading;
  @override
  bool get isGenerating;
  @override
  String? get error;

  /// Create a copy of DailyTopicState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyTopicStateImplCopyWith<_$DailyTopicStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

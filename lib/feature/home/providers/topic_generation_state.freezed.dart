// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic_generation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TopicGenerationState {
  bool get isGenerating => throw _privateConstructorUsedError;
  List<Topic> get generatedTopics => throw _privateConstructorUsedError;
  List<Topic> get allTopics =>
      throw _privateConstructorUsedError; // 過去に生成された全トピック
  String? get error => throw _privateConstructorUsedError;
  Topic? get currentTopic => throw _privateConstructorUsedError;

  /// Create a copy of TopicGenerationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopicGenerationStateCopyWith<TopicGenerationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicGenerationStateCopyWith<$Res> {
  factory $TopicGenerationStateCopyWith(
    TopicGenerationState value,
    $Res Function(TopicGenerationState) then,
  ) = _$TopicGenerationStateCopyWithImpl<$Res, TopicGenerationState>;
  @useResult
  $Res call({
    bool isGenerating,
    List<Topic> generatedTopics,
    List<Topic> allTopics,
    String? error,
    Topic? currentTopic,
  });

  $TopicCopyWith<$Res>? get currentTopic;
}

/// @nodoc
class _$TopicGenerationStateCopyWithImpl<
  $Res,
  $Val extends TopicGenerationState
>
    implements $TopicGenerationStateCopyWith<$Res> {
  _$TopicGenerationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopicGenerationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isGenerating = null,
    Object? generatedTopics = null,
    Object? allTopics = null,
    Object? error = freezed,
    Object? currentTopic = freezed,
  }) {
    return _then(
      _value.copyWith(
            isGenerating: null == isGenerating
                ? _value.isGenerating
                : isGenerating // ignore: cast_nullable_to_non_nullable
                      as bool,
            generatedTopics: null == generatedTopics
                ? _value.generatedTopics
                : generatedTopics // ignore: cast_nullable_to_non_nullable
                      as List<Topic>,
            allTopics: null == allTopics
                ? _value.allTopics
                : allTopics // ignore: cast_nullable_to_non_nullable
                      as List<Topic>,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentTopic: freezed == currentTopic
                ? _value.currentTopic
                : currentTopic // ignore: cast_nullable_to_non_nullable
                      as Topic?,
          )
          as $Val,
    );
  }

  /// Create a copy of TopicGenerationState
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
abstract class _$$TopicGenerationStateImplCopyWith<$Res>
    implements $TopicGenerationStateCopyWith<$Res> {
  factory _$$TopicGenerationStateImplCopyWith(
    _$TopicGenerationStateImpl value,
    $Res Function(_$TopicGenerationStateImpl) then,
  ) = __$$TopicGenerationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isGenerating,
    List<Topic> generatedTopics,
    List<Topic> allTopics,
    String? error,
    Topic? currentTopic,
  });

  @override
  $TopicCopyWith<$Res>? get currentTopic;
}

/// @nodoc
class __$$TopicGenerationStateImplCopyWithImpl<$Res>
    extends _$TopicGenerationStateCopyWithImpl<$Res, _$TopicGenerationStateImpl>
    implements _$$TopicGenerationStateImplCopyWith<$Res> {
  __$$TopicGenerationStateImplCopyWithImpl(
    _$TopicGenerationStateImpl _value,
    $Res Function(_$TopicGenerationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopicGenerationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isGenerating = null,
    Object? generatedTopics = null,
    Object? allTopics = null,
    Object? error = freezed,
    Object? currentTopic = freezed,
  }) {
    return _then(
      _$TopicGenerationStateImpl(
        isGenerating: null == isGenerating
            ? _value.isGenerating
            : isGenerating // ignore: cast_nullable_to_non_nullable
                  as bool,
        generatedTopics: null == generatedTopics
            ? _value._generatedTopics
            : generatedTopics // ignore: cast_nullable_to_non_nullable
                  as List<Topic>,
        allTopics: null == allTopics
            ? _value._allTopics
            : allTopics // ignore: cast_nullable_to_non_nullable
                  as List<Topic>,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentTopic: freezed == currentTopic
            ? _value.currentTopic
            : currentTopic // ignore: cast_nullable_to_non_nullable
                  as Topic?,
      ),
    );
  }
}

/// @nodoc

class _$TopicGenerationStateImpl implements _TopicGenerationState {
  const _$TopicGenerationStateImpl({
    this.isGenerating = false,
    final List<Topic> generatedTopics = const [],
    final List<Topic> allTopics = const [],
    this.error,
    this.currentTopic,
  }) : _generatedTopics = generatedTopics,
       _allTopics = allTopics;

  @override
  @JsonKey()
  final bool isGenerating;
  final List<Topic> _generatedTopics;
  @override
  @JsonKey()
  List<Topic> get generatedTopics {
    if (_generatedTopics is EqualUnmodifiableListView) return _generatedTopics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_generatedTopics);
  }

  final List<Topic> _allTopics;
  @override
  @JsonKey()
  List<Topic> get allTopics {
    if (_allTopics is EqualUnmodifiableListView) return _allTopics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allTopics);
  }

  // 過去に生成された全トピック
  @override
  final String? error;
  @override
  final Topic? currentTopic;

  @override
  String toString() {
    return 'TopicGenerationState(isGenerating: $isGenerating, generatedTopics: $generatedTopics, allTopics: $allTopics, error: $error, currentTopic: $currentTopic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicGenerationStateImpl &&
            (identical(other.isGenerating, isGenerating) ||
                other.isGenerating == isGenerating) &&
            const DeepCollectionEquality().equals(
              other._generatedTopics,
              _generatedTopics,
            ) &&
            const DeepCollectionEquality().equals(
              other._allTopics,
              _allTopics,
            ) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentTopic, currentTopic) ||
                other.currentTopic == currentTopic));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isGenerating,
    const DeepCollectionEquality().hash(_generatedTopics),
    const DeepCollectionEquality().hash(_allTopics),
    error,
    currentTopic,
  );

  /// Create a copy of TopicGenerationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicGenerationStateImplCopyWith<_$TopicGenerationStateImpl>
  get copyWith =>
      __$$TopicGenerationStateImplCopyWithImpl<_$TopicGenerationStateImpl>(
        this,
        _$identity,
      );
}

abstract class _TopicGenerationState implements TopicGenerationState {
  const factory _TopicGenerationState({
    final bool isGenerating,
    final List<Topic> generatedTopics,
    final List<Topic> allTopics,
    final String? error,
    final Topic? currentTopic,
  }) = _$TopicGenerationStateImpl;

  @override
  bool get isGenerating;
  @override
  List<Topic> get generatedTopics;
  @override
  List<Topic> get allTopics; // 過去に生成された全トピック
  @override
  String? get error;
  @override
  Topic? get currentTopic;

  /// Create a copy of TopicGenerationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicGenerationStateImplCopyWith<_$TopicGenerationStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

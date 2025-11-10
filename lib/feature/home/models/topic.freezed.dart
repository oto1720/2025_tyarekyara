// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Topic _$TopicFromJson(Map<String, dynamic> json) {
  return _Topic.fromJson(json);
}

/// @nodoc
mixin _$Topic {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  TopicCategory get category => throw _privateConstructorUsedError;
  TopicDifficulty get difficulty => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  TopicSource get source => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get description =>
      throw _privateConstructorUsedError; // トピックの説明（オプション）
  double get similarityScore =>
      throw _privateConstructorUsedError; // 既存トピックとの類似度スコア
  List<NewsItem> get relatedNews => throw _privateConstructorUsedError;

  /// Serializes this Topic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopicCopyWith<Topic> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicCopyWith<$Res> {
  factory $TopicCopyWith(Topic value, $Res Function(Topic) then) =
      _$TopicCopyWithImpl<$Res, Topic>;
  @useResult
  $Res call({
    String id,
    String text,
    TopicCategory category,
    TopicDifficulty difficulty,
    DateTime createdAt,
    TopicSource source,
    List<String> tags,
    String? description,
    double similarityScore,
    List<NewsItem> relatedNews,
  });
}

/// @nodoc
class _$TopicCopyWithImpl<$Res, $Val extends Topic>
    implements $TopicCopyWith<$Res> {
  _$TopicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? category = null,
    Object? difficulty = null,
    Object? createdAt = null,
    Object? source = null,
    Object? tags = null,
    Object? description = freezed,
    Object? similarityScore = null,
    Object? relatedNews = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as TopicCategory,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as TopicDifficulty,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as TopicSource,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            similarityScore: null == similarityScore
                ? _value.similarityScore
                : similarityScore // ignore: cast_nullable_to_non_nullable
                      as double,
            relatedNews: null == relatedNews
                ? _value.relatedNews
                : relatedNews // ignore: cast_nullable_to_non_nullable
                      as List<NewsItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopicImplCopyWith<$Res> implements $TopicCopyWith<$Res> {
  factory _$$TopicImplCopyWith(
    _$TopicImpl value,
    $Res Function(_$TopicImpl) then,
  ) = __$$TopicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String text,
    TopicCategory category,
    TopicDifficulty difficulty,
    DateTime createdAt,
    TopicSource source,
    List<String> tags,
    String? description,
    double similarityScore,
    List<NewsItem> relatedNews,
  });
}

/// @nodoc
class __$$TopicImplCopyWithImpl<$Res>
    extends _$TopicCopyWithImpl<$Res, _$TopicImpl>
    implements _$$TopicImplCopyWith<$Res> {
  __$$TopicImplCopyWithImpl(
    _$TopicImpl _value,
    $Res Function(_$TopicImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? category = null,
    Object? difficulty = null,
    Object? createdAt = null,
    Object? source = null,
    Object? tags = null,
    Object? description = freezed,
    Object? similarityScore = null,
    Object? relatedNews = null,
  }) {
    return _then(
      _$TopicImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as TopicCategory,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as TopicDifficulty,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as TopicSource,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        similarityScore: null == similarityScore
            ? _value.similarityScore
            : similarityScore // ignore: cast_nullable_to_non_nullable
                  as double,
        relatedNews: null == relatedNews
            ? _value._relatedNews
            : relatedNews // ignore: cast_nullable_to_non_nullable
                  as List<NewsItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopicImpl implements _Topic {
  const _$TopicImpl({
    required this.id,
    required this.text,
    required this.category,
    required this.difficulty,
    required this.createdAt,
    this.source = TopicSource.ai,
    final List<String> tags = const [],
    this.description,
    this.similarityScore = 0,
    final List<NewsItem> relatedNews = const [],
  }) : _tags = tags,
       _relatedNews = relatedNews;

  factory _$TopicImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopicImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
  @override
  final TopicCategory category;
  @override
  final TopicDifficulty difficulty;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final TopicSource source;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? description;
  // トピックの説明（オプション）
  @override
  @JsonKey()
  final double similarityScore;
  // 既存トピックとの類似度スコア
  final List<NewsItem> _relatedNews;
  // 既存トピックとの類似度スコア
  @override
  @JsonKey()
  List<NewsItem> get relatedNews {
    if (_relatedNews is EqualUnmodifiableListView) return _relatedNews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedNews);
  }

  @override
  String toString() {
    return 'Topic(id: $id, text: $text, category: $category, difficulty: $difficulty, createdAt: $createdAt, source: $source, tags: $tags, description: $description, similarityScore: $similarityScore, relatedNews: $relatedNews)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.similarityScore, similarityScore) ||
                other.similarityScore == similarityScore) &&
            const DeepCollectionEquality().equals(
              other._relatedNews,
              _relatedNews,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    text,
    category,
    difficulty,
    createdAt,
    source,
    const DeepCollectionEquality().hash(_tags),
    description,
    similarityScore,
    const DeepCollectionEquality().hash(_relatedNews),
  );

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicImplCopyWith<_$TopicImpl> get copyWith =>
      __$$TopicImplCopyWithImpl<_$TopicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopicImplToJson(this);
  }
}

abstract class _Topic implements Topic {
  const factory _Topic({
    required final String id,
    required final String text,
    required final TopicCategory category,
    required final TopicDifficulty difficulty,
    required final DateTime createdAt,
    final TopicSource source,
    final List<String> tags,
    final String? description,
    final double similarityScore,
    final List<NewsItem> relatedNews,
  }) = _$TopicImpl;

  factory _Topic.fromJson(Map<String, dynamic> json) = _$TopicImpl.fromJson;

  @override
  String get id;
  @override
  String get text;
  @override
  TopicCategory get category;
  @override
  TopicDifficulty get difficulty;
  @override
  DateTime get createdAt;
  @override
  TopicSource get source;
  @override
  List<String> get tags;
  @override
  String? get description; // トピックの説明（オプション）
  @override
  double get similarityScore; // 既存トピックとの類似度スコア
  @override
  List<NewsItem> get relatedNews;

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicImplCopyWith<_$TopicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

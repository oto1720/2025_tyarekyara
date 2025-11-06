// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opinion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Opinion _$OpinionFromJson(Map<String, dynamic> json) {
  return _Opinion.fromJson(json);
}

/// @nodoc
mixin _$Opinion {
  String get id => throw _privateConstructorUsedError;
  String get topicId => throw _privateConstructorUsedError; // トピックID
  String get topicText => throw _privateConstructorUsedError; // トピックのテキスト（表示用）
  String get userId => throw _privateConstructorUsedError; // 投稿者のUID
  String get userName => throw _privateConstructorUsedError; // 投稿者の名前
  OpinionStance get stance => throw _privateConstructorUsedError; // 立場
  String get content => throw _privateConstructorUsedError; // 意見の内容
  DateTime get createdAt => throw _privateConstructorUsedError; // 投稿日時
  int get likeCount => throw _privateConstructorUsedError; // いいね数
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this Opinion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Opinion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpinionCopyWith<Opinion> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpinionCopyWith<$Res> {
  factory $OpinionCopyWith(Opinion value, $Res Function(Opinion) then) =
      _$OpinionCopyWithImpl<$Res, Opinion>;
  @useResult
  $Res call({
    String id,
    String topicId,
    String topicText,
    String userId,
    String userName,
    OpinionStance stance,
    String content,
    DateTime createdAt,
    int likeCount,
    bool isDeleted,
  });
}

/// @nodoc
class _$OpinionCopyWithImpl<$Res, $Val extends Opinion>
    implements $OpinionCopyWith<$Res> {
  _$OpinionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Opinion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? topicId = null,
    Object? topicText = null,
    Object? userId = null,
    Object? userName = null,
    Object? stance = null,
    Object? content = null,
    Object? createdAt = null,
    Object? likeCount = null,
    Object? isDeleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            topicId: null == topicId
                ? _value.topicId
                : topicId // ignore: cast_nullable_to_non_nullable
                      as String,
            topicText: null == topicText
                ? _value.topicText
                : topicText // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            stance: null == stance
                ? _value.stance
                : stance // ignore: cast_nullable_to_non_nullable
                      as OpinionStance,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            likeCount: null == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OpinionImplCopyWith<$Res> implements $OpinionCopyWith<$Res> {
  factory _$$OpinionImplCopyWith(
    _$OpinionImpl value,
    $Res Function(_$OpinionImpl) then,
  ) = __$$OpinionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String topicId,
    String topicText,
    String userId,
    String userName,
    OpinionStance stance,
    String content,
    DateTime createdAt,
    int likeCount,
    bool isDeleted,
  });
}

/// @nodoc
class __$$OpinionImplCopyWithImpl<$Res>
    extends _$OpinionCopyWithImpl<$Res, _$OpinionImpl>
    implements _$$OpinionImplCopyWith<$Res> {
  __$$OpinionImplCopyWithImpl(
    _$OpinionImpl _value,
    $Res Function(_$OpinionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Opinion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? topicId = null,
    Object? topicText = null,
    Object? userId = null,
    Object? userName = null,
    Object? stance = null,
    Object? content = null,
    Object? createdAt = null,
    Object? likeCount = null,
    Object? isDeleted = null,
  }) {
    return _then(
      _$OpinionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        topicId: null == topicId
            ? _value.topicId
            : topicId // ignore: cast_nullable_to_non_nullable
                  as String,
        topicText: null == topicText
            ? _value.topicText
            : topicText // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        stance: null == stance
            ? _value.stance
            : stance // ignore: cast_nullable_to_non_nullable
                  as OpinionStance,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        likeCount: null == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OpinionImpl implements _Opinion {
  const _$OpinionImpl({
    required this.id,
    required this.topicId,
    required this.topicText,
    required this.userId,
    required this.userName,
    required this.stance,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.isDeleted = false,
  });

  factory _$OpinionImpl.fromJson(Map<String, dynamic> json) =>
      _$$OpinionImplFromJson(json);

  @override
  final String id;
  @override
  final String topicId;
  // トピックID
  @override
  final String topicText;
  // トピックのテキスト（表示用）
  @override
  final String userId;
  // 投稿者のUID
  @override
  final String userName;
  // 投稿者の名前
  @override
  final OpinionStance stance;
  // 立場
  @override
  final String content;
  // 意見の内容
  @override
  final DateTime createdAt;
  // 投稿日時
  @override
  @JsonKey()
  final int likeCount;
  // いいね数
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'Opinion(id: $id, topicId: $topicId, topicText: $topicText, userId: $userId, userName: $userName, stance: $stance, content: $content, createdAt: $createdAt, likeCount: $likeCount, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpinionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.topicText, topicText) ||
                other.topicText == topicText) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.stance, stance) || other.stance == stance) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    topicId,
    topicText,
    userId,
    userName,
    stance,
    content,
    createdAt,
    likeCount,
    isDeleted,
  );

  /// Create a copy of Opinion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpinionImplCopyWith<_$OpinionImpl> get copyWith =>
      __$$OpinionImplCopyWithImpl<_$OpinionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OpinionImplToJson(this);
  }
}

abstract class _Opinion implements Opinion {
  const factory _Opinion({
    required final String id,
    required final String topicId,
    required final String topicText,
    required final String userId,
    required final String userName,
    required final OpinionStance stance,
    required final String content,
    required final DateTime createdAt,
    final int likeCount,
    final bool isDeleted,
  }) = _$OpinionImpl;

  factory _Opinion.fromJson(Map<String, dynamic> json) = _$OpinionImpl.fromJson;

  @override
  String get id;
  @override
  String get topicId; // トピックID
  @override
  String get topicText; // トピックのテキスト（表示用）
  @override
  String get userId; // 投稿者のUID
  @override
  String get userName; // 投稿者の名前
  @override
  OpinionStance get stance; // 立場
  @override
  String get content; // 意見の内容
  @override
  DateTime get createdAt; // 投稿日時
  @override
  int get likeCount; // いいね数
  @override
  bool get isDeleted;

  /// Create a copy of Opinion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpinionImplCopyWith<_$OpinionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Report _$ReportFromJson(Map<String, dynamic> json) {
  return _Report.fromJson(json);
}

/// @nodoc
mixin _$Report {
  String get id => throw _privateConstructorUsedError;
  String get reporterId => throw _privateConstructorUsedError; // 報告者のUID
  String get reportedUserId =>
      throw _privateConstructorUsedError; // 報告されたユーザーのUID
  ReportType get type => throw _privateConstructorUsedError; // 報告の種類
  String get contentId =>
      throw _privateConstructorUsedError; // 報告されたコンテンツのID（意見IDまたはメッセージID）
  ReportReason get reason => throw _privateConstructorUsedError; // 報告理由
  String? get details => throw _privateConstructorUsedError; // 詳細説明（任意）
  DateTime get createdAt => throw _privateConstructorUsedError; // 報告日時
  bool get isResolved => throw _privateConstructorUsedError; // 対応済みかどうか
  DateTime? get resolvedAt => throw _privateConstructorUsedError; // 対応日時
  String? get resolvedBy => throw _privateConstructorUsedError;

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportCopyWith<Report> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportCopyWith<$Res> {
  factory $ReportCopyWith(Report value, $Res Function(Report) then) =
      _$ReportCopyWithImpl<$Res, Report>;
  @useResult
  $Res call({
    String id,
    String reporterId,
    String reportedUserId,
    ReportType type,
    String contentId,
    ReportReason reason,
    String? details,
    DateTime createdAt,
    bool isResolved,
    DateTime? resolvedAt,
    String? resolvedBy,
  });
}

/// @nodoc
class _$ReportCopyWithImpl<$Res, $Val extends Report>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporterId = null,
    Object? reportedUserId = null,
    Object? type = null,
    Object? contentId = null,
    Object? reason = null,
    Object? details = freezed,
    Object? createdAt = null,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            reporterId: null == reporterId
                ? _value.reporterId
                : reporterId // ignore: cast_nullable_to_non_nullable
                      as String,
            reportedUserId: null == reportedUserId
                ? _value.reportedUserId
                : reportedUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ReportType,
            contentId: null == contentId
                ? _value.contentId
                : contentId // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as ReportReason,
            details: freezed == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isResolved: null == isResolved
                ? _value.isResolved
                : isResolved // ignore: cast_nullable_to_non_nullable
                      as bool,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            resolvedBy: freezed == resolvedBy
                ? _value.resolvedBy
                : resolvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReportImplCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$$ReportImplCopyWith(
    _$ReportImpl value,
    $Res Function(_$ReportImpl) then,
  ) = __$$ReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String reporterId,
    String reportedUserId,
    ReportType type,
    String contentId,
    ReportReason reason,
    String? details,
    DateTime createdAt,
    bool isResolved,
    DateTime? resolvedAt,
    String? resolvedBy,
  });
}

/// @nodoc
class __$$ReportImplCopyWithImpl<$Res>
    extends _$ReportCopyWithImpl<$Res, _$ReportImpl>
    implements _$$ReportImplCopyWith<$Res> {
  __$$ReportImplCopyWithImpl(
    _$ReportImpl _value,
    $Res Function(_$ReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporterId = null,
    Object? reportedUserId = null,
    Object? type = null,
    Object? contentId = null,
    Object? reason = null,
    Object? details = freezed,
    Object? createdAt = null,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
  }) {
    return _then(
      _$ReportImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        reporterId: null == reporterId
            ? _value.reporterId
            : reporterId // ignore: cast_nullable_to_non_nullable
                  as String,
        reportedUserId: null == reportedUserId
            ? _value.reportedUserId
            : reportedUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ReportType,
        contentId: null == contentId
            ? _value.contentId
            : contentId // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as ReportReason,
        details: freezed == details
            ? _value.details
            : details // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isResolved: null == isResolved
            ? _value.isResolved
            : isResolved // ignore: cast_nullable_to_non_nullable
                  as bool,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        resolvedBy: freezed == resolvedBy
            ? _value.resolvedBy
            : resolvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportImpl implements _Report {
  const _$ReportImpl({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.type,
    required this.contentId,
    required this.reason,
    this.details,
    required this.createdAt,
    this.isResolved = false,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory _$ReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportImplFromJson(json);

  @override
  final String id;
  @override
  final String reporterId;
  // 報告者のUID
  @override
  final String reportedUserId;
  // 報告されたユーザーのUID
  @override
  final ReportType type;
  // 報告の種類
  @override
  final String contentId;
  // 報告されたコンテンツのID（意見IDまたはメッセージID）
  @override
  final ReportReason reason;
  // 報告理由
  @override
  final String? details;
  // 詳細説明（任意）
  @override
  final DateTime createdAt;
  // 報告日時
  @override
  @JsonKey()
  final bool isResolved;
  // 対応済みかどうか
  @override
  final DateTime? resolvedAt;
  // 対応日時
  @override
  final String? resolvedBy;

  @override
  String toString() {
    return 'Report(id: $id, reporterId: $reporterId, reportedUserId: $reportedUserId, type: $type, contentId: $contentId, reason: $reason, details: $details, createdAt: $createdAt, isResolved: $isResolved, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reporterId, reporterId) ||
                other.reporterId == reporterId) &&
            (identical(other.reportedUserId, reportedUserId) ||
                other.reportedUserId == reportedUserId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    reporterId,
    reportedUserId,
    type,
    contentId,
    reason,
    details,
    createdAt,
    isResolved,
    resolvedAt,
    resolvedBy,
  );

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportImplCopyWith<_$ReportImpl> get copyWith =>
      __$$ReportImplCopyWithImpl<_$ReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportImplToJson(this);
  }
}

abstract class _Report implements Report {
  const factory _Report({
    required final String id,
    required final String reporterId,
    required final String reportedUserId,
    required final ReportType type,
    required final String contentId,
    required final ReportReason reason,
    final String? details,
    required final DateTime createdAt,
    final bool isResolved,
    final DateTime? resolvedAt,
    final String? resolvedBy,
  }) = _$ReportImpl;

  factory _Report.fromJson(Map<String, dynamic> json) = _$ReportImpl.fromJson;

  @override
  String get id;
  @override
  String get reporterId; // 報告者のUID
  @override
  String get reportedUserId; // 報告されたユーザーのUID
  @override
  ReportType get type; // 報告の種類
  @override
  String get contentId; // 報告されたコンテンツのID（意見IDまたはメッセージID）
  @override
  ReportReason get reason; // 報告理由
  @override
  String? get details; // 詳細説明（任意）
  @override
  DateTime get createdAt; // 報告日時
  @override
  bool get isResolved; // 対応済みかどうか
  @override
  DateTime? get resolvedAt; // 対応日時
  @override
  String? get resolvedBy;

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportImplCopyWith<_$ReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

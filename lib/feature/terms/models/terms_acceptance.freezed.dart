// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'terms_acceptance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TermsAcceptance _$TermsAcceptanceFromJson(Map<String, dynamic> json) {
  return _TermsAcceptance.fromJson(json);
}

/// @nodoc
mixin _$TermsAcceptance {
  String get userId => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError; // 利用規約のバージョン
  DateTime get acceptedAt => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;

  /// Serializes this TermsAcceptance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TermsAcceptance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TermsAcceptanceCopyWith<TermsAcceptance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TermsAcceptanceCopyWith<$Res> {
  factory $TermsAcceptanceCopyWith(
    TermsAcceptance value,
    $Res Function(TermsAcceptance) then,
  ) = _$TermsAcceptanceCopyWithImpl<$Res, TermsAcceptance>;
  @useResult
  $Res call({
    String userId,
    String version,
    DateTime acceptedAt,
    String? ipAddress,
  });
}

/// @nodoc
class _$TermsAcceptanceCopyWithImpl<$Res, $Val extends TermsAcceptance>
    implements $TermsAcceptanceCopyWith<$Res> {
  _$TermsAcceptanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TermsAcceptance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? version = null,
    Object? acceptedAt = null,
    Object? ipAddress = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
            acceptedAt: null == acceptedAt
                ? _value.acceptedAt
                : acceptedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ipAddress: freezed == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TermsAcceptanceImplCopyWith<$Res>
    implements $TermsAcceptanceCopyWith<$Res> {
  factory _$$TermsAcceptanceImplCopyWith(
    _$TermsAcceptanceImpl value,
    $Res Function(_$TermsAcceptanceImpl) then,
  ) = __$$TermsAcceptanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String version,
    DateTime acceptedAt,
    String? ipAddress,
  });
}

/// @nodoc
class __$$TermsAcceptanceImplCopyWithImpl<$Res>
    extends _$TermsAcceptanceCopyWithImpl<$Res, _$TermsAcceptanceImpl>
    implements _$$TermsAcceptanceImplCopyWith<$Res> {
  __$$TermsAcceptanceImplCopyWithImpl(
    _$TermsAcceptanceImpl _value,
    $Res Function(_$TermsAcceptanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TermsAcceptance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? version = null,
    Object? acceptedAt = null,
    Object? ipAddress = freezed,
  }) {
    return _then(
      _$TermsAcceptanceImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        acceptedAt: null == acceptedAt
            ? _value.acceptedAt
            : acceptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ipAddress: freezed == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TermsAcceptanceImpl implements _TermsAcceptance {
  const _$TermsAcceptanceImpl({
    required this.userId,
    required this.version,
    required this.acceptedAt,
    this.ipAddress,
  });

  factory _$TermsAcceptanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TermsAcceptanceImplFromJson(json);

  @override
  final String userId;
  @override
  final String version;
  // 利用規約のバージョン
  @override
  final DateTime acceptedAt;
  @override
  final String? ipAddress;

  @override
  String toString() {
    return 'TermsAcceptance(userId: $userId, version: $version, acceptedAt: $acceptedAt, ipAddress: $ipAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TermsAcceptanceImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, version, acceptedAt, ipAddress);

  /// Create a copy of TermsAcceptance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TermsAcceptanceImplCopyWith<_$TermsAcceptanceImpl> get copyWith =>
      __$$TermsAcceptanceImplCopyWithImpl<_$TermsAcceptanceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TermsAcceptanceImplToJson(this);
  }
}

abstract class _TermsAcceptance implements TermsAcceptance {
  const factory _TermsAcceptance({
    required final String userId,
    required final String version,
    required final DateTime acceptedAt,
    final String? ipAddress,
  }) = _$TermsAcceptanceImpl;

  factory _TermsAcceptance.fromJson(Map<String, dynamic> json) =
      _$TermsAcceptanceImpl.fromJson;

  @override
  String get userId;
  @override
  String get version; // 利用規約のバージョン
  @override
  DateTime get acceptedAt;
  @override
  String? get ipAddress;

  /// Create a copy of TermsAcceptance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TermsAcceptanceImplCopyWith<_$TermsAcceptanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

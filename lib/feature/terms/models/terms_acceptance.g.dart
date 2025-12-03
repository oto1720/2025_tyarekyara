// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terms_acceptance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TermsAcceptanceImpl _$$TermsAcceptanceImplFromJson(
  Map<String, dynamic> json,
) => _$TermsAcceptanceImpl(
  userId: json['userId'] as String,
  version: json['version'] as String,
  acceptedAt: DateTime.parse(json['acceptedAt'] as String),
  ipAddress: json['ipAddress'] as String?,
);

Map<String, dynamic> _$$TermsAcceptanceImplToJson(
  _$TermsAcceptanceImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'version': instance.version,
  'acceptedAt': instance.acceptedAt.toIso8601String(),
  'ipAddress': instance.ipAddress,
};

import 'package:freezed_annotation/freezed_annotation.dart';

part 'terms_acceptance.freezed.dart';
part 'terms_acceptance.g.dart';

@freezed
class TermsAcceptance with _$TermsAcceptance {
  const factory TermsAcceptance({
    required String userId,
    required String version, // 利用規約のバージョン
    required DateTime acceptedAt,
    String? ipAddress,
  }) = _TermsAcceptance;

  factory TermsAcceptance.fromJson(Map<String, dynamic> json) =>
      _$TermsAcceptanceFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/timestamp_converter.dart';

part 'earned_badge.freezed.dart';
part 'earned_badge.g.dart';

@freezed
class EarnedBadge with _$EarnedBadge {
  const factory EarnedBadge({
    required String badgeId,
    @TimestampConverter() required DateTime earnedAt,
    String? awardedBy,
  }) = _EarnedBadge;

  factory EarnedBadge.fromJson(Map<String, dynamic> json) =>
      _$EarnedBadgeFromJson(json);
}

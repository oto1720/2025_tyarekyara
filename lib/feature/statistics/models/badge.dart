import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge.freezed.dart';
part 'badge.g.dart';

@freezed
class Badge with _$Badge {
  const factory Badge({
    required String id,
    required String name,
    String? description,
    String? iconUrl,
    DateTime? earnedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? criteria,
    String? awardedBy,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}

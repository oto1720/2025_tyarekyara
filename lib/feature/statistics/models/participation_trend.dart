import 'package:freezed_annotation/freezed_annotation.dart';

part 'participation_trend.freezed.dart';
part 'participation_trend.g.dart';

@freezed
class ParticipationPoint with _$ParticipationPoint {
  const factory ParticipationPoint({
    required DateTime date,
    required int count,
  }) = _ParticipationPoint;

  factory ParticipationPoint.fromJson(Map<String, dynamic> json) =>
      _$ParticipationPointFromJson(json);
}

@freezed
class ParticipationTrend with _$ParticipationTrend {
  const factory ParticipationTrend({
    required String userId,
    required List<ParticipationPoint> points,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ParticipationTrend;

  factory ParticipationTrend.fromJson(Map<String, dynamic> json) =>
      _$ParticipationTrendFromJson(json);
}

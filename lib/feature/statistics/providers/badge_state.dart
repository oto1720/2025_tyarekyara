import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/badge.dart';

part 'badge_state.freezed.dart';

@freezed
class BadgeState with _$BadgeState {
  const factory BadgeState({
    @Default(<Badge>[]) List<Badge> earnedBadges,
    @Default(false) bool isLoading,
    String? error,
  }) = _BadgeState;
}

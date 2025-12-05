import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'badge_state.dart';

class BadgeNotifier extends Notifier<BadgeState> {
  @override
  BadgeState build() {
    return const BadgeState();
  }

  Future<void> loadEarnedBadges(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final badgeNotifierProvider = NotifierProvider<BadgeNotifier, BadgeState>(() {
  return BadgeNotifier();
});

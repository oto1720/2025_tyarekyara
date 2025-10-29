import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// チュートリアル完了状態のProvider
final tutorialCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('tutorial_completed') ?? false;
});

/// チュートリアル管理Notifier
class TutorialNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// 次のページへ
  void nextPage() {
    state = state + 1;
  }

  /// 前のページへ
  void previousPage() {
    if (state > 0) {
      state = state - 1;
    }
  }

  /// 特定のページへ
  void goToPage(int page) {
    state = page;
  }

  /// チュートリアルを完了としてマーク
  Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    // tutorialCompletedProviderを再読み込み
    ref.invalidate(tutorialCompletedProvider);
  }

  /// チュートリアルをリセット（デバッグ用）
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', false);
    state = 0;
    ref.invalidate(tutorialCompletedProvider);
  }
}

/// チュートリアルページインデックスのProvider
final tutorialNotifierProvider = NotifierProvider<TutorialNotifier, int>(() {
  return TutorialNotifier();
});

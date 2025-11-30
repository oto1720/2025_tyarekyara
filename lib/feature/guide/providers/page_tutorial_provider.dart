// lib/feature/guide/providers/page_tutorial_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 画面ごとの初回表示フラグを管理するNotifier
class PageTutorialNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    return {};
  }

  /// 特定の画面のチュートリアルが表示済みかチェック
  Future<bool> hasShownTutorial(String pageKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_shown_$pageKey') ?? false;
  }

  /// チュートリアルを表示済みとしてマーク
  Future<void> markTutorialShown(String pageKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_shown_$pageKey', true);
    state = {...state, pageKey: true};
  }

  /// チュートリアルをリセット（開発/デバッグ用）
  Future<void> resetTutorial(String pageKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutorial_shown_$pageKey');
    state = {...state, pageKey: false};
  }

  /// 全てのチュートリアルフラグをリセット（開発/デバッグ用）
  Future<void> resetAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('tutorial_shown_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
    state = {};
  }
}

final pageTutorialProvider =
    NotifierProvider<PageTutorialNotifier, Map<String, bool>>(() {
  return PageTutorialNotifier();
});

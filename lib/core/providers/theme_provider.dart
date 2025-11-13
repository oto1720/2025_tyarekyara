// lib/core/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier for the theme mode
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // TODO: SharedPreferencesなどで永続化設定を読み込む
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // TODO: SharedPreferencesなどに永続化設定を保存する
  }
}

// Provider for the theme mode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
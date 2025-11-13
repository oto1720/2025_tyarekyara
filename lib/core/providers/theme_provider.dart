// lib/core/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// アプリのテーマモードを管理するProvider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // TODO: SharedPreferencesなどで永続化設定を読み込む
  return ThemeMode.system;
});
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tyarekyara/core/route/app_router.dart';
import 'firebase_options.dart';
import 'package:device_preview/device_preview.dart';
import 'package:tyarekyara/core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // デバッグモードとプロファイルモードで有効
      builder: (context) => const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      themeMode: themeMode, // ★ ここに設定
      theme: ThemeData.light(useMaterial3: true),     // ライトモード用テーマ
      darkTheme: ThemeData.dark(useMaterial3: true),  // ダークモード用テーマ
      routerConfig: router,
      // DevicePreview設定
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      // デバッグバナーを非表示
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // ← コメントアウト
import 'feature/home/presentation/pages/home_answer.dart';

void main() async {
  // .envの読み込みをスキップ
  // await dotenv.load(fileName: ".env"); // ← コメントアウト

  runApp(const ProviderScope(child: HomeTestApp()));
}

class HomeTestApp extends StatelessWidget {
  const HomeTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '意見投稿画面テスト',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const OpinionPostScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyarekyara/feature/statistics/presentation/pages/statistic.dart';

void main() {
  runApp(const ProviderScope(child: PreviewApp()));
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statistic Preview',
      home: const StatisticPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// lib/feature/home/presentation/pages/home.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('トピック一覧')),
      body: ListView(
        children: [
          // トピックのリストを表示
          _TopicCard(
            title: '夜休3日前に投入すべきか？',
            category: '社会問題',
            date: '2025年10月26日',
            onTap: () {
              // 意見投稿画面に遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OpinionPostScreen(),
                ),
              );
            },
          ),
          // 他のトピック...
        ],
      ),
    );
  }
}

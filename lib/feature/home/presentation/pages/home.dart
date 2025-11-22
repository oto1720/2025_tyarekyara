// lib/feature/home/presentation/pages/home.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/feature/home/presentation/pages/home_topic.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('トピック一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // トピックのリストを表示
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OpinionPostScreen(),
                ),
              );
            },
            child: const TopicCard(
              title: '夜休3日前に投入すべきか？',
              category: '社会問題',
              date: '2025年10月26日',
              description: '週休3日制の導入について、労働時間の短縮と生産性向上の観点から議論します。',
            ),
          ),
          // 他のトピック...
        ],
      ),
    );
  }
}

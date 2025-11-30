// lib/feature/guide/presentaion/widgets/tutorial_showcase_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../providers/page_tutorial_provider.dart';

/// ShowCaseを管理するラッパーウィジェット
class TutorialShowcaseWrapper extends ConsumerStatefulWidget {
  final String pageKey;
  final GlobalKey showcaseKey;
  final Widget child;

  const TutorialShowcaseWrapper({
    super.key,
    required this.pageKey,
    required this.showcaseKey,
    required this.child,
  });

  @override
  ConsumerState<TutorialShowcaseWrapper> createState() =>
      _TutorialShowcaseWrapperState();
}

class _TutorialShowcaseWrapperState
    extends ConsumerState<TutorialShowcaseWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    final hasShown = await ref
        .read(pageTutorialProvider.notifier)
        .hasShownTutorial(widget.pageKey);

    if (!hasShown && mounted) {
      // 少し遅延させてから表示（画面描画完了後）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ShowCaseWidget.of(context).startShowCase([widget.showcaseKey]);
          // ショーケース完了後にフラグを保存
          ref
              .read(pageTutorialProvider.notifier)
              .markTutorialShown(widget.pageKey);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

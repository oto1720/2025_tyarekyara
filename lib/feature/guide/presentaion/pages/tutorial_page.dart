import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';
import '../../models/tutorial_item.dart';
import '../../providers/tutorial_provider.dart';
import '../widgets/tutorial_card.dart';
import '../../../auth/providers/auth_provider.dart';

/// チュートリアル画面
class TutorialPage extends ConsumerStatefulWidget {
  const TutorialPage({super.key});

  @override
  ConsumerState<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends ConsumerState<TutorialPage> {
  late PageController _pageController;
  final List<TutorialItem> _tutorialItems = TutorialData.items;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    ref.read(tutorialNotifierProvider.notifier).goToPage(page);
  }

  void _goToNextPage() {
    final currentPage = ref.read(tutorialNotifierProvider);
    if (currentPage < _tutorialItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionChoice();
    }
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// チュートリアル完了後の選択画面を表示
  Future<void> _showCompletionChoice() async {
    await ref.read(tutorialNotifierProvider.notifier).completeTutorial();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'アプリを始める',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'アカウントを作成して全ての機能を利用するか、\nゲストモードで一部機能を試すことができます。',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'ログイン / 新規登録',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final router = GoRouter.of(context);
                  navigator.pop();
                  await ref.read(authControllerProvider.notifier).continueAsGuest();
                  router.go('/');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'ゲストで続ける',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _skipTutorial() {
    _showCompletionChoice();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(tutorialNotifierProvider);
    final isLastPage = currentPage == _tutorialItems.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー（スキップボタン）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLastPage)
                    TextButton(
                      onPressed: _skipTutorial,
                      child: const Text(
                        'スキップ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // メインコンテンツ（PageView）
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _tutorialItems.length,
                itemBuilder: (context, index) {
                  return TutorialCard(item: _tutorialItems[index]);
                },
              ),
            ),

            // フッター（インジケーター + ボタン）
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ページインジケーター
                  PageIndicator(
                    currentPage: currentPage,
                    totalPages: _tutorialItems.length,
                    activeColor: _tutorialItems[currentPage].primaryColor,
                    inactiveColor: AppColors.border,
                  ),
                  const SizedBox(height: 32),

                  // ナビゲーションボタン
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 戻るボタン
                      if (currentPage > 0)
                        OutlinedButton(
                          onPressed: _goToPreviousPage,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '戻る',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(width: 80),

                      // 次へ / 始めるボタン
                      ElevatedButton(
                        onPressed: _goToNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _tutorialItems[currentPage].primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          children: [
                            Text(
                              isLastPage ? '始める' : '次へ',
                              style: const TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLastPage ? Icons.check : Icons.arrow_forward,
                              color: AppColors.textOnPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

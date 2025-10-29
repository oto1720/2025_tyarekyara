import 'package:flutter/material.dart';
import '../../models/tutorial_item.dart';

/// チュートリアルカードWidget
class TutorialCard extends StatelessWidget {
  final TutorialItem item;

  const TutorialCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Card(
          elevation: 8,
          shadowColor: item.primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 500,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.primaryColor.withValues(alpha: 0.1),
                  item.secondaryColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // アイコン
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          item.primaryColor,
                          item.secondaryColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: item.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      item.icon,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // タイトル
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: item.primaryColor,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // 説明文
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ページインジケーター
class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;
  final Color inactiveColor;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

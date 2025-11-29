import 'package:flutter/material.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';
import '../../models/tutorial_item.dart';

/// チュートリアルカードWidget（画面全体スライド方式）
class TutorialCard extends StatelessWidget {
  final TutorialItem item;

  const TutorialCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // タイトル
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: item.primaryColor,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // サブタイトル
                if (item.subtitle != null) ...[
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: item.primaryColor.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                // 説明文
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                      height: 1.8,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // 箇条書き
                if (item.bulletPoints != null && item.bulletPoints!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.bulletPoints!
                          .map(
                            (point) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: item.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],

                // 画像エリア（showImageがtrueの場合のみ表示）
                if (item.showImage) ...[
                  const SizedBox(height: 60),
                  // 丸い画像/アイコン
                  Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                      boxShadow: [
                        BoxShadow(
                          color: item.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: item.imagePath != null
                        ? ClipOval(
                            child: item.imagePath ==
                                    'assets/images/onboarding/icon2.png'
                                ? Image.asset(item.imagePath!,
                                    fit: BoxFit.cover)
                                : Transform.scale(
                                    scale: 1.5,
                                    child: Image.asset(
                                      item.imagePath!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          )
                        : Icon(item.icon,
                            size: 100, color: AppColors.textOnPrimary),
                  ),
                ] else ...[
                  const SizedBox(height: 40),
                ],
                /*child: Padding(
                        
                            padding: const EdgeInsets.all(20), // ← 画像周りに余白を追加
                            child: Image.asset(
                              item.imagePath!,
                              fit: BoxFit.contain, // ← cover から contain に変更
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
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
                                  ),
                                  child: Icon(
                                    item.icon,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : Icon(item.icon, size: 100, color: AppColors.textOnPrimary),
                ),

                Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: item.imagePath == null
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              item.primaryColor,
                              item.secondaryColor,
                            ],
                          )
                        : null,
                    color: item.imagePath != null ? Colors.white : null,
                    boxShadow: [
                      BoxShadow(
                        color: item.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: item.imagePath != null
                      ? ClipOval(
                          child: Image.asset(
                            item.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // 画像が見つからない場合はアイコンを表示
                              return Container(
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
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        )
                      : Icon(
                          item.icon,
                          size: 100,
                          color: Colors.white,
                        ),
                ),*/
              ],
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
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.border,
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

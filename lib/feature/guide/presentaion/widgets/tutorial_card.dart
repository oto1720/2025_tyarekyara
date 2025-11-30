import 'package:flutter/material.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';
import '../../models/tutorial_item.dart';

/// チュートリアルカードWidget（画面全体スライド方式）
class TutorialCard extends StatelessWidget {
  final TutorialItem item;

  const TutorialCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // タブレット判定（最小辺が600px以上）
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // 画面幅に応じたスケールファクター（375pxを基準）
    // タブレット: 1.0〜1.2（文字を大きく表示）
    // スマートフォン: 0.75〜0.95（画面に収める）
    final widthScale = isTablet
        ? (width / 375).clamp(1.0, 1.2)
        : (width / 375).clamp(0.75, 0.95);

    // 画面高さに応じたスケールファクター（812pxを基準: iPhone 13/14）
    final heightScale = isTablet
        ? (height / 812).clamp(1.0, 1.2)
        : (height / 812).clamp(0.7, 0.9);

    // 幅と高さのスケールの小さい方を採用（コンテンツが確実に収まるように）
    final scale = widthScale < heightScale ? widthScale : heightScale;

    // 小さい画面（360px未満）の判定
    final isSmallScreen = width < 360;

    // 低い画面（700px未満）の判定
    final isShortScreen = height < 700;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 24 : 40,
              vertical: isShortScreen ? 20 : (isSmallScreen ? 40 : 60),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // タイトル
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 36 * scale,
                    fontWeight: FontWeight.bold,
                    color: item.primaryColor,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 24 * scale),

                // サブタイトル
                if (item.subtitle != null) ...[
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w600,
                      color: item.primaryColor.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16 * scale),
                ],

                // 説明文
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 18 * scale,
                      color: AppColors.textSecondary,
                      height: 1.8,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 箇条書き
                if (item.bulletPoints != null && item.bulletPoints!.isNotEmpty) ...[
                  SizedBox(height: isShortScreen ? 20 * scale : 32 * scale),
                  Container(
                    constraints: BoxConstraints(maxWidth: 400 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.bulletPoints!
                          .map(
                            (point) => Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isShortScreen ? 4 * scale : 8 * scale,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: item.primaryColor,
                                    size: 24 * scale,
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: TextStyle(
                                        fontSize: 16 * scale,
                                        color: AppColors.textPrimary,
                                        height: 1.6,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
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
                  SizedBox(height: isShortScreen ? 30 * scale : 60 * scale),
                  // 丸い画像/アイコン
                  Container(
                    width: (isSmallScreen || isShortScreen ? 240 : 380) * scale,
                    height: (isSmallScreen || isShortScreen ? 240 : 380) * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                      boxShadow: [
                        BoxShadow(
                          color: item.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 30 * scale,
                          offset: Offset(0, 15 * scale),
                          spreadRadius: 5 * scale,
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
                            size: 100 * scale,
                            color: AppColors.textOnPrimary),
                  ),
                ] else ...[
                  SizedBox(height: 40 * scale),
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

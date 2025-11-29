import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';

/// アプリ起動時の最初のページ
class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

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

    // 画面高さに応じたスケールファクター（812pxを基準）
    final heightScale = isTablet
        ? (height / 812).clamp(1.0, 1.2)
        : (height / 812).clamp(0.7, 0.9);

    // 幅と高さのスケールの小さい方を採用
    final scale = widthScale < heightScale ? widthScale : heightScale;

    // 小さい画面・低い画面の判定
    final isSmallScreen = width < 360;
    final isShortScreen = height < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // メインコンテンツ
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24 : 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isShortScreen ? 20 * scale : 40 * scale),

                        // アプリ名
                        Text(
                          'Critica',
                          style: TextStyle(
                            fontSize: 80 * scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16 * scale),

                        // 説明文
                        Text(
                          'あなたの意見を共有し、\n新しい発見をしよう',
                          style: TextStyle(
                            fontSize: 18 * scale,
                            color: AppColors.textSecondary,
                            height: 1.6,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isShortScreen ? 30 * scale : 50 * scale),

                        // 画像エリア
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxWidth: (isSmallScreen || isShortScreen ? 280 : 400) * scale,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20 * scale),
                            child: Image.asset(
                              'assets/images/onboarding/icon.png',
                              fit: BoxFit.cover,
                              height: (isSmallScreen || isShortScreen ? 200 : 250) * scale,
                            /*errorBuilder: (context, error, stackTrace) {
                              // 画像がない場合はプレースホルダーを表示
                              return Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '画像を追加できます',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },*/
                          ),
                        ),
                      ),
                      SizedBox(height: isShortScreen ? 20 * scale : 40 * scale),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ボトムエリア
          Padding(
              padding: EdgeInsets.all(isShortScreen ? 16 : 24),
              child: Column(
                children: [
                  // 始めるボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/tutorial');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: isShortScreen ? 14 : 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        '始める',
                        style: TextStyle(
                          fontSize: 18 * scale.clamp(0.85, 1.0),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isShortScreen ? 12 : 16),

                  // ログインリンク
                  TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(
                        fontSize: 14 * scale.clamp(0.85, 1.0),
                        fontWeight: FontWeight.w600,
                        inherit: false,
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14 * scale.clamp(0.85, 1.0),
                          color: AppColors.textSecondary,
                          inherit: false,
                        ),
                        children: [
                          const TextSpan(text: 'アカウントをお持ちの方は '),
                          TextSpan(
                            text: 'ログイン',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14 * scale.clamp(0.85, 1.0),
                              inherit: false,
                            ),
                          ),
                        ],
                      ),
                    ),
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

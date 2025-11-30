// lib/feature/guide/presentaion/widgets/tutorial_dialog.dart

import 'package:flutter/material.dart';
import '../../models/page_tutorial_data.dart';

/// 操作ガイドを表示するボトムシート
class TutorialBottomSheet extends StatelessWidget {
  final String pageKey;

  const TutorialBottomSheet({
    super.key,
    required this.pageKey,
  });

  /// ボトムシートを表示する静的メソッド
  static void show(BuildContext context, String pageKey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TutorialBottomSheet(pageKey: pageKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = PageTutorialData.tutorials[pageKey] ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // ハンドルバー
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // ヘッダー
              Row(
                children: [
                  const Icon(Icons.help_outline, size: 28, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Text(
                    '操作ガイド',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // チュートリアルステップのリスト
              ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 画像がある場合は表示
                    if (step.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          step.imagePath!,
                          width: double.infinity,
                          height: 350,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // 画像が見つからない場合のプレースホルダー
                            return Container(
                              width: double.infinity,
                              height: 350,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '画像を準備中',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('閉じる'),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 後方互換性のため、TutorialDialogもエイリアスとして残す
class TutorialDialog extends TutorialBottomSheet {
  const TutorialDialog({
    super.key,
    required super.pageKey,
  });
}

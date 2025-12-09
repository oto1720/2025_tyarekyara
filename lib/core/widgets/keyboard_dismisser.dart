import 'package:flutter/material.dart';

/// キーボードを自動的に閉じるためのウィジェット
///
/// テキスト入力フィールドの外側をタップしたときにキーボードを閉じます。
/// 使い方:
/// ```dart
/// Scaffold(
///   body: KeyboardDismisser(
///     child: YourContent(),
///   ),
/// )
/// ```
class KeyboardDismisser extends StatelessWidget {
  final Widget child;

  const KeyboardDismisser({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 現在のフォーカスを外してキーボードを閉じる
        FocusScope.of(context).unfocus();
      },
      // 透明な部分のタップも検知する
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

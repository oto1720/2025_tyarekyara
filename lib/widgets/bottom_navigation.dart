import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:tyarekyara/core/constants/app_colors.dart';

/// Bottom Navigationの設定
/// 新しいタブを追加する場合は、[navigationItems]に追加してください
class BottomNavigationConfig {
  static const List<NavigationItem> navigationItems = [
    NavigationItem(icon: Icons.home, label: 'ホーム', route: '/'),
    NavigationItem(icon: Icons.shuffle, label: 'チャレンジ', route: '/challenge'),
    NavigationItem(icon: Icons.chat, label: 'ディベート', route: '/debate'),
    NavigationItem(icon: Icons.bar_chart, label: '統計', route: '/statistics'),
    NavigationItem(icon: Icons.bug_report, label: 'マッチングデバッグ', route: '/debug/matching'),
    NavigationItem(icon: Icons.settings, label: '設定', route: '/settings'),
  ];
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

/// Bottom Navigationバーを表示するScaffold
class ScaffoldWithBottomNavigation extends StatelessWidget {
  const ScaffoldWithBottomNavigation({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bodyをBottomNavigationBarの下まで拡張し、ガラス効果で背景が透けて見えるようにする
      extendBody: true,
      body: child,
      bottomNavigationBar: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          thickness: 15,
          blur: 20,
          glassColor: AppColors.background.withValues(alpha: 0.3),
        ),
        child: LiquidGlass(
          shape: const LiquidRoundedSuperellipse(borderRadius: 0),
          child: BottomNavigationBar(
            // 固定タイプにして、アイテム数が4つ以上になっても
            // 背景が透明になる（shiftingによる）挙動を抑制します。
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textTertiary,
            currentIndex: _calculateSelectedIndex(context),
            onTap: (index) => _onItemTapped(index, context),
            items: BottomNavigationConfig.navigationItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    // 意見一覧画面や編集画面の場合は「ホーム」を選択状態にする
    if (location.startsWith('/opinions/') || location.startsWith('/my-opinion/')) {
      return 0; // ホームのインデックス
    }

    for (int i = 0; i < BottomNavigationConfig.navigationItems.length; i++) {
      if (location == BottomNavigationConfig.navigationItems[i].route) {
        return i;
      }
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    context.go(BottomNavigationConfig.navigationItems[index].route);
  }
}

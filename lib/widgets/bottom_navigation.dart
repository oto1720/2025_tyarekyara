import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom Navigationの設定
/// 新しいタブを追加する場合は、[navigationItems]に追加してください
class BottomNavigationConfig {
  static const List<NavigationItem> navigationItems = [
    NavigationItem(
      icon: Icons.home,
      label: 'ホーム',
      route: '/',
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'プロフィール',
      route: '/profile',
    ),
    NavigationItem(
      icon: Icons.settings,
      label: '設定',
      route: '/settings',
    ),
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
  const ScaffoldWithBottomNavigation({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

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

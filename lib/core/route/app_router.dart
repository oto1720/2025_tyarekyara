
import 'package:go_router/go_router.dart';
import 'package:tyarekyara/feature/home/home.dart';
import 'package:tyarekyara/feature/profile/profile_screen.dart';
import 'package:tyarekyara/feature/settings/settings_screen.dart';
import 'package:tyarekyara/widgets/bottom_navigation.dart';

// ルーティング設定
// 新しい画面を追加する場合：
// 1. lib/feature/配下に画面ファイルを作成
// 2. lib/widgets/bottom_navigation.dartのBottomNavigationConfigに追加
// 3. 以下のShellRouteのroutesに新しいGoRouteを追加
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNavigation(
          child: child,
        );
      },
      routes: [
        // ホーム画面
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        // プロフィール画面
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
        // 設定画面
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
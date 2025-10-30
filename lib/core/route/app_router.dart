import 'package:go_router/go_router.dart';
import 'package:tyarekyara/feature/home/presentation/pages/home.dart';
import 'package:tyarekyara/feature/settings/presentation/pages/profile_screen.dart';
import 'package:tyarekyara/feature/settings/presentation/pages/settings_screen.dart';
import 'package:tyarekyara/widgets/bottom_navigation.dart';
import 'package:tyarekyara/feature/auth/presentaion/pages/login.dart';
import 'package:tyarekyara/feature/auth/presentaion/pages/signup_page.dart';
import 'package:tyarekyara/feature/auth/presentaion/pages/profile_setup_page.dart';
import 'package:tyarekyara/feature/guide/presentaion/pages/tutorial_page.dart';
import 'package:tyarekyara/feature/settings/presentation/pages/notice_screen.dart';

// ルーティング設定
// 新しい画面を追加する場合：
// 1. lib/feature/配下に画面ファイルを作成
// 2. lib/widgets/bottom_navigation.dartのBottomNavigationConfigに追加
// 3. 以下のShellRouteのroutesに新しいGoRouteを追加
final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    // 認証画面（BottomNavigation なし）
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginPage(),
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SignUpPage(),
      ),
    ),
    GoRoute(
      path: '/profile-setup',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ProfileSetupPage(),
      ),
    ),
    GoRoute(
      path: '/tutorial',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: TutorialPage(),
      ),
    ),
    GoRoute(
      path: '/notice',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: NoticeScreen(),
      ),
    ),
    // メインアプリ（BottomNavigation あり）
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
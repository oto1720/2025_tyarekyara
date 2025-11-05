import 'package:go_router/go_router.dart';
import 'package:tyarekyara/feature/home/presentation/pages/daily_topic_home.dart';
import 'package:tyarekyara/feature/home/presentation/pages/home_answer.dart';
import 'package:tyarekyara/feature/home/presentation/pages/my_opinion_detail.dart';
import 'package:tyarekyara/feature/settings/presentation/pages/profile_screen.dart';
import 'package:tyarekyara/feature/settings/presentation/pages/settings_screen.dart';
import 'package:tyarekyara/widgets/bottom_navigation.dart';
import 'package:tyarekyara/feature/auth/presentaion/pages/login.dart';
import 'package:tyarekyara/feature/auth/presentaion/pages/signup_page.dart';
import 'package:tyarekyara/feature/auth/presentaion/pages/profile_setup_page.dart';
import 'package:tyarekyara/feature/guide/presentaion/pages/first_page.dart';
import 'package:tyarekyara/feature/statistics/presentation/pages/statistic.dart';
import 'package:tyarekyara/feature/guide/presentaion/pages/tutorial_page.dart';
import 'package:tyarekyara/feature/settings/presentation/pages/notice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ルーティング設定
// 新しい画面を追加する場合：
// 1. lib/feature/配下に画面ファイルを作成
// 2. lib/widgets/bottom_navigation.dartのBottomNavigationConfigに追加
// 3. 以下のShellRouteのroutesに新しいGoRouteを追加
final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final currentPath = state.uri.path;

    // 認証状態とチュートリアル完了状態を確認
    final prefs = await SharedPreferences.getInstance();
    final tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;

    // 認証関連ページは常にアクセス可能
    final authPages = ['/login', '/signup', '/profile-setup'];
    if (authPages.contains(currentPath)) {
      return null;
    }

    // リダイレクトロジック
    // 1. ログイン済み & チュートリアル完了 → ホームへ
    if (isAuthenticated && tutorialCompleted) {
      if (currentPath == '/first' || currentPath == '/tutorial') {
        return '/';
      }
      return null; // ホームや他のページは正常にアクセス
    }

    // 2. ログイン済み & チュートリアル未完了 → チュートリアルへ
    if (isAuthenticated && !tutorialCompleted) {
      if (currentPath != '/tutorial' && currentPath != '/first') {
        return '/tutorial';
      }
      return null;
    }

    // 3. 未ログイン & チュートリアル完了 → ログインへ
    if (!isAuthenticated && tutorialCompleted) {
      if (currentPath == '/first' || currentPath == '/tutorial') {
        return '/login';
      }
      // メインアプリへのアクセスもログインにリダイレクト
      if (currentPath == '/' || currentPath == '/settings' ||
          currentPath == '/profile' || currentPath == '/statistics') {
        return '/login';
      }
      return null;
    }

    // 4. 未ログイン & チュートリアル未完了 → 初回画面へ
    if (!isAuthenticated && !tutorialCompleted) {
      if (currentPath != '/first' && currentPath != '/tutorial') {
        return '/first';
      }
      return null;
    }

    return null;
  },
  routes: [
    // 初回起動画面
    GoRoute(
      path: '/first',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: FirstPage(),
      ),
    ),
    // チュートリアル画面
    GoRoute(
      path: '/tutorial',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: TutorialPage(),
      ),
    ),
    // 認証画面（BottomNavigation なし）
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SignUpPage()),
    ),
    GoRoute(
      path: '/profile-setup',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ProfileSetupPage()),
    ),
    GoRoute(
      path: '/tutorial',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: TutorialPage()),
    ),
    GoRoute(
      path: '/notice',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: NoticeScreen(),
      ),
    ),
    // 意見一覧画面
    GoRoute(
      path: '/opinions/:topicId',
      pageBuilder: (context, state) {
        final topicId = state.pathParameters['topicId']!;
        return NoTransitionPage(
          child: OpinionListScreen(topicId: topicId),
        );
      },
    ),
    // 自分の投稿詳細・編集画面
    GoRoute(
      path: '/my-opinion/:topicId',
      pageBuilder: (context, state) {
        final topicId = state.pathParameters['topicId']!;
        return NoTransitionPage(
          child: MyOpinionDetailScreen(topicId: topicId),
        );
      },
    ),
    // メインアプリ（BottomNavigation あり）
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNavigation(child: child);
      },
      routes: [
        // ホーム画面
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DailyTopicHomeScreen()),
        ),
        // 統計画面
        GoRoute(
          path: '/statistics',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StatisticPage()),
        ),
        // プロフィール画面
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
        // 設定画面
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
  ],
);

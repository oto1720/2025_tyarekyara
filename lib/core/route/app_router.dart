import 'package:go_router/go_router.dart';
import 'package:tyarekyara/feature/challenge/presentaion/pages/challenge_detail.dart';
import 'package:tyarekyara/feature/home/presentation/pages/home.dart';
import 'package:tyarekyara/feature/profile/profile_screen.dart';
import 'package:tyarekyara/feature/settings/settings_screen.dart';
import 'package:tyarekyara/widgets/bottom_navigation.dart';
import 'package:tyarekyara/feature/auth/presentaion/pages/login.dart';
import 'package:tyarekyara/feature/auth/presentaion/pages/signup_page.dart';
import 'package:tyarekyara/feature/auth/presentaion/pages/profile_setup_page.dart';
import 'package:tyarekyara/feature/guide/presentaion/pages/tutorial_page.dart';
import 'package:tyarekyara/feature/challenge/presentaion/pages/challenge.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';

// ルーティング設定
// 新しい画面を追加する場合：
// 1. lib/feature/配下に画面ファイルを作成
// 2. lib/widgets/bottom_navigation.dartのBottomNavigationConfigに追加
// 3. 以下のShellRouteのroutesに新しいGoRouteを追加
final GoRouter router = GoRouter(
  // initialLocation: '/login',
  //ログイン画面をスキップしてchallenge画面へ(終わったら戻す)
  initialLocation: '/challenge',
  routes: [
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

    // チャレンジ詳細ページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/challenge/:challengeId', // ← :challengeId でIDを受け取る
      pageBuilder: (context, state) {
        // extra から Challenge オブジェクトを取り出す
        final Challenge challenge = state.extra as Challenge;

        return NoTransitionPage(
          // Challenge オブジェクトを詳細ページに渡す
          child: ChallengeDetailPage(challenge: challenge),
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
              const NoTransitionPage(child: HomeScreen()),
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
        GoRoute(
          path: '/challenge',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ChallengePage()),
        ),
      ],
    ),
  ],
);

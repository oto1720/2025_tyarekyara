import 'package:go_router/go_router.dart';
import 'package:tyarekyara/debug/enhanced_matching_debug_page.dart';
import 'package:tyarekyara/feature/challenge/presentaion/pages/challenge_detail.dart';
import 'package:tyarekyara/feature/challenge/presentaion/pages/challenge_feedback_page.dart';
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
import 'package:tyarekyara/feature/challenge/presentaion/pages/challenge.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:tyarekyara/feature/settings/presentation/pages/notice_screen.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_event_list_page.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_event_detail_page.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_entry_page.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_waiting_room_page.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_match_detail_page.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_room_page.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_judgment_waiting_page.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_result_page.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_ranking_page.dart';
import 'package:tyarekyara/feature/debate/presentation/pages/debate_stats_page.dart';
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

    // 認証関連ページとディベート関連ページは常にアクセス可能
    final authPages = ['/login', '/signup', '/profile-setup'];
    final debatePages = currentPath.startsWith('/debate/');
    if (authPages.contains(currentPath) || debatePages) {
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

    // チャレンジ詳細ページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/challenge/:challengeId', // ← :challengeId でIDを受け取る
      pageBuilder: (context, state) {
        // extra から Challenge オブジェクトを取り出す
        Challenge challenge;
        
        if (state.extra == null) {
          // extraがnullの場合はエラー
          throw Exception('Challenge object is required for challenge detail page');
        }
        
        if (state.extra is Challenge) {
          // Challengeオブジェクトの場合
          challenge = state.extra as Challenge;
        } else if (state.extra is Map<String, dynamic>) {
          // Map<String, dynamic>の場合はChallengeに変換
          try {
            challenge = Challenge.fromFirestore(state.extra as Map<String, dynamic>);
          } catch (e) {
            throw Exception('Failed to convert Map to Challenge: $e');
          }
        } else {
          throw Exception('Invalid extra type: ${state.extra.runtimeType}');
        }

        return NoTransitionPage(
          // Challenge オブジェクトを詳細ページに渡す
          child: ChallengeDetailPage(challenge: challenge),
        );
      },
    ),

    // チャレンジフィードバックページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/challenge/:challengeId/feedback',
      pageBuilder: (context, state) {
        // extra から Challenge オブジェクトと回答を取り出す
        final extra = state.extra as Map<String, dynamic>;
        final challenge = extra['challenge'] as Challenge;
        final challengeAnswer = extra['challengeAnswer'] as String;

        return NoTransitionPage(
          child: ChallengeFeedbackPage(
            challenge: challenge,
            challengeAnswer: challengeAnswer,
          ),
        );
      },
    ),

    // ディベートイベント詳細ページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/debate/event/:eventId',
      pageBuilder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        return NoTransitionPage(
          child: DebateEventDetailPage(eventId: eventId),
        );
      },
    ),

    // ディベートエントリーページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/debate/event/:eventId/entry',
      pageBuilder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        return NoTransitionPage(
          child: DebateEntryPage(eventId: eventId),
        );
      },
    ),

    // ディベートウェイティングルームページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/debate/event/:eventId/waiting',
      pageBuilder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        return NoTransitionPage(
          child: DebateWaitingRoomPage(eventId: eventId),
        );
      },
    ),

    // ディベートマッチ詳細ページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/debate/match/:matchId',
      pageBuilder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        return NoTransitionPage(
          child: DebateMatchDetailPage(matchId: matchId),
        );
      },
    ),

    // ディベートルームページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/debate/room/:matchId',
      pageBuilder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        return NoTransitionPage(
          child: DebateRoomPage(matchId: matchId),
        );
      },
    ),

    // AI判定待機ページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/debate/judgment/:matchId',
      pageBuilder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        return NoTransitionPage(
          child: DebateJudgmentWaitingPage(matchId: matchId),
        );
      },
    ),

    // 判定結果ページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/debate/result/:matchId',
      pageBuilder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        return NoTransitionPage(
          child: DebateResultPage(matchId: matchId),
        );
      },
    ),

    // ディベートランキングページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/debate/ranking',
      pageBuilder: (context, state) {
        return const NoTransitionPage(
          child: DebateRankingPage(),
        );
      },
    ),

    // ディベート統計ページ (ShellRoute の「外」に置く)
    GoRoute(
      path: '/debate/stats',
      pageBuilder: (context, state) {
        return const NoTransitionPage(
          child: DebateStatsPage(),
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
        GoRoute(
          path: '/challenge',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ChallengePage()),
        ),
        // ディベートイベント一覧画面
        GoRoute(
          path: '/debate',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DebateEventListPage()),
        ),
        GoRoute(
          path: '/debug/matching',
          pageBuilder: (context, state) => const NoTransitionPage(child: EnhancedMatchingDebugPage()),
        ),
      ],
    ),
  ],
);

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:tyarekyara/feature/challenge/repositories/challenge_repositories.dart';


// 表示フィルタ用のenum
enum ChallengeFilter {
  available, // 「可能」を表示
  completed, // 「済み」を表示
}

// リポジトリプロバイダー
final challengeRepositoryProvider = riverpod.Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});

class ChallengeState {
  // 元のProviderが持っていた変数をここに入れる
  final List<Challenge> allChallenges;
  final ChallengeFilter currentFilter;
  final int currentPoints;
  final int maxPoints;
  final bool isLoading;

  // コンストラクタ
  const ChallengeState({
    required this.allChallenges,
    this.currentFilter = ChallengeFilter.available, // フィルタの初期値を設定
    this.currentPoints = 0, // Firestoreから計算
    this.maxPoints = 500, // 仮の最大値
    this.isLoading = false,
  });

  // 状態をコピーして新しい状態を作るためのメソッド
  // (状態を変更するときに使う)
  ChallengeState copyWith({
    List<Challenge>? allChallenges,
    ChallengeFilter? currentFilter,
    int? currentPoints,
    int? maxPoints,
    bool? isLoading,
  }) {
    return ChallengeState(
      allChallenges: allChallenges ?? this.allChallenges,
      currentFilter: currentFilter ?? this.currentFilter,
      currentPoints: currentPoints ?? this.currentPoints,
      maxPoints: maxPoints ?? this.maxPoints,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<Challenge> get filteredChallenges {
    if (currentFilter == ChallengeFilter.available) {
      // 「可能」が選ばれていたら、statusがavailableのものだけを絞り込む
      return allChallenges.where((c) => c.status == ChallengeStatus.available).toList();
    } else {
      // 「済み」が選ばれていたら、statusがcompletedのものだけを絞り込む
      return allChallenges.where((c) => c.status == ChallengeStatus.completed).toList();
    }
  }
}

// -----------------------------------------------------------------
// ステップ3: 状態を操作する「Notifier」クラスを定義
// -----------------------------------------------------------------
class ChallengeNotifier extends riverpod.Notifier<ChallengeState> {
  ChallengeRepository get repository => ref.read(challengeRepositoryProvider);

  @override
  ChallengeState build() {
    // 非同期でデータを読み込む
    Future.microtask(() => loadChallenges());
    return ChallengeState(
      allChallenges: _createDummyData(), // 初期状態はダミーデータ
      currentFilter: ChallengeFilter.available,
      isLoading: true,
    );
  }

  /// チャレンジデータを読み込む
  Future<void> loadChallenges() async {
    print('📊 [Challenge] ========== loadChallenges() 開始 ==========');
    final currentUser = FirebaseAuth.instance.currentUser;

    // ログインしていない場合はダミーデータのみ表示
    if (currentUser == null) {
      print('⚠️ [Challenge] ユーザーがログインしていません。ダミーデータを使用します。');
      state = state.copyWith(
        allChallenges: _createDummyData(),
        isLoading: false,
      );
      return;
    }

    print('✅ [Challenge] ログイン中のユーザーID: ${currentUser.uid}');
    state = state.copyWith(isLoading: true);

    try {
      // 1. ユーザーの投稿した意見からチャレンジを生成
      print('🔍 [Challenge] ユーザーの投稿意見からチャレンジ生成開始...');
      final opinionBasedChallenges = await repository.getChallengesFromUserOpinions(currentUser.uid);
      print('📦 [Challenge] 生成されたチャレンジ数: ${opinionBasedChallenges.length}');

      // 2. Firestoreからユーザーのチャレンジ完了状況を取得
      print('🔍 [Challenge] Firestoreから完了データ取得開始...');
      final completedChallenges = await repository.getUserChallenges(currentUser.uid);
      print('📦 [Challenge] Firestoreから取得した完了チャレンジ数: ${completedChallenges.length}');

      // 取得したデータの詳細をログ出力
      if (completedChallenges.isEmpty) {
        print('  ⚪ Firestoreに完了データが存在しません');
      } else {
        for (var challenge in completedChallenges) {
          print('  - ID:${challenge.id} / ステータス:${challenge.status.name} / '
                '反対意見:${challenge.oppositeOpinionText != null ? "あり(${challenge.oppositeOpinionText!.length}文字)" : "なし"} / '
                'ポイント:${challenge.earnedPoints ?? 0}');
        }
      }

      // 3. 獲得ポイントの合計を計算
      final totalPoints = await repository.getTotalEarnedPoints(currentUser.uid);
      print('💰 [Challenge] 合計獲得ポイント: $totalPoints');

      // 4. 意見ベースのチャレンジとFirestoreの完了データをマージ
      print('🔄 [Challenge] データマージ処理開始...');
      print('  意見ベースチャレンジ数: ${opinionBasedChallenges.length}');
      print('  完了済みチャレンジ数: ${completedChallenges.length}');

      List<Challenge> mergedChallenges;

      if (opinionBasedChallenges.isEmpty) {
        // 意見がない場合はダミーデータを使用
        print('⚠️ [Challenge] 投稿意見がないため、ダミーデータを使用します');
        final dummyChallenges = _createDummyData();
        mergedChallenges = dummyChallenges.map((dummy) {
          // Firestoreに該当するチャレンジがあるか確認
          final completed = completedChallenges.firstWhere(
            (c) => c.id == dummy.id,
            orElse: () => dummy,
          );
          return completed;
        }).toList();
      } else {
        // 意見ベースのチャレンジを使用
        mergedChallenges = opinionBasedChallenges.map((challenge) {
          // Firestoreに該当する完了チャレンジがあるか確認
          final completed = completedChallenges.firstWhere(
            (c) => c.id == challenge.id,
            orElse: () {
              print('  ⚪ ID:${challenge.id} 未完了（挑戦可能）');
              return challenge;
            },
          );

          if (completed.oppositeOpinionText != null) {
            print('  ✅ ID:${challenge.id} 完了済み（${completed.earnedPoints}P）');
          }

          return completed;
        }).toList();
      }

      print('✅ [Challenge] データマージ完了。最終チャレンジ数: ${mergedChallenges.length}');

      // 完了済みの数を確認
      final completedCount = mergedChallenges.where((c) => c.status == ChallengeStatus.completed).length;
      print('  完了済み: $completedCount件 / 未完了: ${mergedChallenges.length - completedCount}件');

      state = state.copyWith(
        allChallenges: mergedChallenges,
        currentPoints: totalPoints,
        isLoading: false,
      );

      print('🎉 [Challenge] loadChallenges() 正常終了');
      print('📊 [Challenge] ========================================\n');
    } catch (e, stackTrace) {
      print('❌ [Challenge] エラー発生！');
      print('   エラー内容: $e');
      print('   スタックトレース: $stackTrace');
      state = state.copyWith(
        allChallenges: _createDummyData(),
        isLoading: false,
      );
      print('📊 [Challenge] ========================================\n');
    }
  }

  // フィルタを変更するメソッド
  void setFilter(ChallengeFilter filter) {
    if (state.currentFilter != filter) {
      state = state.copyWith(currentFilter: filter);
    }
  }

  /// チャレンジを完了にする
  Future<void> completeChallenge(String challengeId, String oppositeOpinion, int earnedPoints) async {
    print('✍️ [Challenge] ========== completeChallenge() 開始 ==========');
    print('   チャレンジID: $challengeId');
    print('   反対意見の文字数: ${oppositeOpinion.length}文字');
    print('   獲得ポイント: $earnedPoints');

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('❌ [Challenge] ユーザーがログインしていません。処理を中断します。');
      return;
    }

    print('✅ [Challenge] ユーザーID: ${currentUser.uid}');

    // 1. allChallenges リストをコピー（新しいリストを作成）
    final updatedChallenges = List<Challenge>.from(state.allChallenges);

    // 2. 該当するチャレンジのインデックスを探す
    final index = updatedChallenges.indexWhere((c) => c.id == challengeId);

    if (index != -1) {
      print('✅ [Challenge] 該当チャレンジを発見（インデックス: $index）');

      // 3. 該当チャレンジのステータスと意見を更新
      final oldChallenge = updatedChallenges[index];
      print('   元のステータス: ${oldChallenge.status.name}');

      final completedChallenge = Challenge(
        id: oldChallenge.id,
        title: oldChallenge.title,
        stance: oldChallenge.stance,
        difficulty: oldChallenge.difficulty,
        originalOpinionText: oldChallenge.originalOpinionText,
        status: ChallengeStatus.completed,
        oppositeOpinionText: oppositeOpinion,
        userId: currentUser.uid,
        completedAt: DateTime.now(),
        earnedPoints: earnedPoints,
      );

      print('✅ [Challenge] 新しいチャレンジオブジェクトを作成');
      print('   ステータス: ${completedChallenge.status.name}');
      print('   反対意見: ${completedChallenge.oppositeOpinionText?.substring(0, 20)}...');

      updatedChallenges[index] = completedChallenge;

      // 4. ローカル状態を即座に更新（楽観的UI更新）
      print('🔄 [Challenge] ローカル状態を更新（楽観的UI更新）');
      state = state.copyWith(
        allChallenges: updatedChallenges,
        currentPoints: state.currentPoints + earnedPoints,
      );
      print('✅ [Challenge] ローカル状態更新完了（現在のポイント: ${state.currentPoints}）');

      // 5. Firestoreに保存
      print('💾 [Challenge] Firestoreに保存開始...');
      try {
        await repository.saveUserChallenge(completedChallenge);
        print('✅ [Challenge] Firestoreへの保存成功！');
        print('   保存したデータ:');
        print('     - ID: ${completedChallenge.id}');
        print('     - userId: ${completedChallenge.userId}');
        print('     - status: ${completedChallenge.status.name}');
        print('     - oppositeOpinionText: ${completedChallenge.oppositeOpinionText?.length}文字');
        print('     - earnedPoints: ${completedChallenge.earnedPoints}');
      } catch (e, stackTrace) {
        print('❌ [Challenge] Firestoreへの保存失敗！');
        print('   エラー内容: $e');
        print('   スタックトレース: $stackTrace');
        print('🔄 [Challenge] データを再読み込みします...');
        // エラー時は元に戻す
        await loadChallenges();
      }
    } else {
      print('❌ [Challenge] 該当するチャレンジが見つかりません（ID: $challengeId）');
    }

    print('✍️ [Challenge] ========================================\n');
  }

  /// データをリフレッシュ
  Future<void> refresh() => loadChallenges();
}

final challengeProvider =
    riverpod.NotifierProvider<ChallengeNotifier, ChallengeState>(() {
  return ChallengeNotifier();
});

// -----------------------------------------------------------------
// ステップ4: UIがアクセスするための「Provider」を定義
// -----------------------------------------------------------------

List<Challenge> _createDummyData() {
  // ダミーデータ用の仮のユーザーID（実際のユーザーIDで上書きされる）
  const dummyUserId = 'dummy';

  return [
    Challenge(
      id: '1',
      title: '週休3日制は導入すべきか？',
      difficulty: ChallengeDifficulty.easy,
      originalStance: Stance.con, // 元の意見: 反対
      stance: Stance.pro, // チャレンジ: 賛成の立場で考える
      originalOpinionText: '週休3日制は、労働者のワークライフバランスを向上させ、生産性を高める可能性があります。',
      status: ChallengeStatus.available,
      userId: dummyUserId,
    ),
    Challenge(
      id: '2',
      difficulty: ChallengeDifficulty.normal,
      title: '今日のご飯なに？',
      originalStance: Stance.pro, // 元の意見: 賛成
      stance: Stance.con, // チャレンジ: 反対の立場で考える
      originalOpinionText: 'カレーライスが食べたいです。',
      status: ChallengeStatus.available,
      userId: dummyUserId,
    ),
    Challenge(
      id: '3',
      difficulty: ChallengeDifficulty.hard,
      title: 'は？',
      originalStance: Stance.con, // 元の意見: 反対
      stance: Stance.pro, // チャレンジ: 賛成の立場で考える
      originalOpinionText: 'は？',
      status: ChallengeStatus.available,
      userId: dummyUserId,
    ),
    Challenge(
      id: '4',
      title: 'お題C：SNSは社会に有益か？',
      originalStance: Stance.pro, // 元の意見: 賛成
      stance: Stance.con, // チャレンジ: 反対の立場で考える
      difficulty: ChallengeDifficulty.normal,
      originalOpinionText: '遠くの人と繋がれる点で、非常に有益だ。',
      status: ChallengeStatus.available, // デフォルトは挑戦可能に変更
      userId: dummyUserId,
    ),
  ];
}
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter/material.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';


// 表示フィルタ用のenum
enum ChallengeFilter {
  available, // 「可能」を表示
  completed, // 「済み」を表示
}

class ChallengeState {
  // 元のProviderが持っていた変数をここに入れる
  final List<Challenge> allChallenges;
  final ChallengeFilter currentFilter;
  final int currentPoints;
  final int maxPoints;

  // コンストラクタ
  const ChallengeState({
    required this.allChallenges,
    this.currentFilter = ChallengeFilter.available, // フィルタの初期値を設定
    this.currentPoints = 40, // 仮の初期値
    this.maxPoints = 500, // 仮の最大値
  });

  // 状態をコピーして新しい状態を作るためのメソッド
  // (状態を変更するときに使う)
  ChallengeState copyWith({
    List<Challenge>? allChallenges,
    ChallengeFilter? currentFilter,
    int? currentPoints,
    int? maxPoints,
  }) {
    return ChallengeState(
      allChallenges: allChallenges ?? this.allChallenges,
      currentFilter: currentFilter ?? this.currentFilter,
      currentPoints: currentPoints ?? this.currentPoints,
      maxPoints: maxPoints ?? this.maxPoints,
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
  @override
  ChallengeState build() {
    return ChallengeState(
      allChallenges: _createDummyData(), // ↓で定義する関数を呼ぶ
      currentFilter: ChallengeFilter.available,
    );
  }

  // フィルタを変更するメソッド
  void setFilter(ChallengeFilter filter) {
    if (state.currentFilter != filter) {
      state = state.copyWith(currentFilter: filter);
    }
  }

  // ... 今後、チャレンジを完了にするメソッドなどもここに追加 ...
  void completeChallenge(String challengeId, String oppositeOpinion, int earnedPoints) {
    // 1. allChallenges リストをコピー（新しいリストを作成）
    final updatedChallenges = List<Challenge>.from(state.allChallenges);
    
    // 2. 該当するチャレンジのインデックスを探す
    final index = updatedChallenges.indexWhere((c) => c.id == challengeId);

    if (index != -1) {
      // 3. 該当チャレンジのステータスと意見を更新
      //    （元のオブジェクトを変更せず、新しいインスタンスを作成）
      final oldChallenge = updatedChallenges[index];
      updatedChallenges[index] = Challenge(
        id: oldChallenge.id,
        title: oldChallenge.title,
        stance: oldChallenge.stance,
        difficulty: oldChallenge.difficulty,
        originalOpinionText: oldChallenge.originalOpinionText,
        status: ChallengeStatus.completed, // ステータスを「完了」に
        oppositeOpinionText: oppositeOpinion, // 挑戦した意見を保存
      );

      // 4. 新しい状態（更新されたリストとポイント）で state を更新
      state = state.copyWith(
        allChallenges: updatedChallenges,
        currentPoints: state.currentPoints + earnedPoints,
      );
    }
  }
}

final challengeProvider =
    riverpod.NotifierProvider<ChallengeNotifier, ChallengeState>(() {
  return ChallengeNotifier();
});

// -----------------------------------------------------------------
// ステップ4: UIがアクセスするための「Provider」を定義
// -----------------------------------------------------------------

List<Challenge> _createDummyData() {
  return [
    Challenge(
      id: '1',
      title: '週休3日制は導入すべきか？',
      difficulty: ChallengeDifficulty.easy,
      stance: Stance.pro,
      originalOpinionText: '週休3日制は、労働者のワークライフバランスを向上させ、生産性を高める可能性があります。',
      status: ChallengeStatus.available, // 挑戦可能
    ),
    Challenge(
      id: '2',
      difficulty: ChallengeDifficulty.normal,
      title: '今日のご飯なに？',
      stance: Stance.pro,
      originalOpinionText: 'カレーライスが食べたいです。',
      status: ChallengeStatus.available, // 挑戦可能
    ),
    Challenge(
      id: '3', // IDが重複していたので '3' に修正
      difficulty: ChallengeDifficulty.hard,
      title: 'は？',
      stance: Stance.pro,
      originalOpinionText: 'は？',
      status: ChallengeStatus.available, // 挑戦可能
    ),
    Challenge(
      id: '4', // IDが重複していたので '4' に修正
      title: 'お題C：SNSは社会に有益か？',
      stance: Stance.pro,
      difficulty: ChallengeDifficulty.normal,
      originalOpinionText: '遠くの人と繋がれる点で、非常に有益だ。',
      status: ChallengeStatus.completed, // 完了済み
    ),
  ];
}
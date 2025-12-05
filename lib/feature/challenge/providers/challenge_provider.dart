import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_model.dart';
import 'package:tyarekyara/feature/challenge/models/challenge_state.dart';
import 'package:tyarekyara/feature/challenge/presentaion/widgets/difficultry_budge.dart';
import 'package:tyarekyara/feature/challenge/repositories/challenge_repositories.dart';


// 表示フィルタ用のenum
enum ChallengeFilter {
  available, // 「可能」を表示
  completed, // 「済み」を表示
}

// リポジトリプロバイダー
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});

// フィルタNotifier
class ChallengeFilterNotifier extends Notifier<ChallengeFilter> {
  @override
  ChallengeFilter build() => ChallengeFilter.available;

  void setFilter(ChallengeFilter filter) {
    state = filter;
  }
}

// ポイントNotifier
class CurrentPointsNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPoints(int points) {
    state = points;
  }

  void addPoints(int points) {
    state = state + points;
  }
}

// フィルタプロバイダー（独立した状態として管理）
final challengeFilterProvider = NotifierProvider<ChallengeFilterNotifier, ChallengeFilter>(() {
  return ChallengeFilterNotifier();
});

// 現在のポイントプロバイダー（独立した状態として管理）
final currentPointsProvider = NotifierProvider<CurrentPointsNotifier, int>(() {
  return CurrentPointsNotifier();
});

// ChallengeStateはmodels/challenge_state.dartに移動（Freezed使用）

// フィルタリングされたチャレンジを提供するプロバイダー
final filteredChallengesProvider = Provider<List<Challenge>>((ref) {
  final asyncValue = ref.watch(challengeProvider);
  final filter = ref.watch(challengeFilterProvider);

  // AsyncValueからデータを取得
  final state = asyncValue.value;

  // データがない場合は空リストを返す
  if (state == null || state.isLoading) {
    return [];
  }

  if (filter == ChallengeFilter.available) {
    return state.challenges
        .where((c) => c.status == ChallengeStatus.available)
        .toList();
  } else {
    return state.challenges
        .where((c) => c.status == ChallengeStatus.completed)
        .toList();
  }
});

// -----------------------------------------------------------------
// AsyncNotifier を使用した非同期状態管理
// -----------------------------------------------------------------
class ChallengeNotifier extends AsyncNotifier<ChallengeState> {
  ChallengeRepository get repository => ref.read(challengeRepositoryProvider);

  @override
  Future<ChallengeState> build() async {
    // AsyncNotifierを使用することで、build()内で適切に非同期処理が可能
    return await _loadChallenges();
  }

  /// チャレンジデータを読み込む（内部メソッド）
  Future<ChallengeState> _loadChallenges() async {
    if (kDebugMode) {
      print('📊 [Challenge] ========== _loadChallenges() 開始 ==========');
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    // ログインしていない場合はダミーデータのみ表示
    if (currentUser == null) {
      if (kDebugMode) {
        print('⚠️ [Challenge] ユーザーがログインしていません。ダミーデータを使用します。');
      }
      return const ChallengeState(
        challenges: [], // ダミーデータは後で追加
      );
    }

    if (kDebugMode) {
      print('✅ [Challenge] ログイン中のユーザーID: ${currentUser.uid}');
    }

    try {
      // 1. ユーザーの投稿した意見からチャレンジを生成
      if (kDebugMode) {
        print('🔍 [Challenge] ユーザーの投稿意見からチャレンジ生成開始...');
      }
      final opinionBasedChallenges =
          await repository.getChallengesFromUserOpinions(currentUser.uid);

      if (kDebugMode) {
        print('📦 [Challenge] 生成されたチャレンジ数: ${opinionBasedChallenges.length}');
      }

      // 2. Firestoreからユーザーのチャレンジ完了状況を取得
      if (kDebugMode) {
        print('🔍 [Challenge] Firestoreから完了データ取得開始...');
      }
      final completedChallenges = await repository.getUserChallenges(currentUser.uid);

      if (kDebugMode) {
        print('📦 [Challenge] Firestoreから取得した完了チャレンジ数: ${completedChallenges.length}');
      }

      // 3. 獲得ポイントの合計を計算
      final totalPoints = await repository.getTotalEarnedPoints(currentUser.uid);
      if (kDebugMode) {
        print('💰 [Challenge] 合計獲得ポイント: $totalPoints');
      }

      // ポイントを別プロバイダーに反映
      ref.read(currentPointsProvider.notifier).setPoints(totalPoints);

      // 4. データマージ処理（最適化版）
      final mergedChallenges = _mergeChallenges(
        opinionBasedChallenges,
        completedChallenges,
      );

      if (kDebugMode) {
        final completedCount = mergedChallenges
            .where((c) => c.status == ChallengeStatus.completed)
            .length;
        print('✅ [Challenge] データマージ完了。最終チャレンジ数: ${mergedChallenges.length}');
        print('  完了済み: $completedCount件 / 未完了: ${mergedChallenges.length - completedCount}件');
        print('🎉 [Challenge] _loadChallenges() 正常終了');
        print('📊 [Challenge] ========================================\n');
      }

      return ChallengeState(
        challenges: mergedChallenges,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Challenge] エラー発生！');
        print('   エラー内容: $e');
        print('   スタックトレース: $stackTrace');
        print('📊 [Challenge] ========================================\n');
      }

      return ChallengeState(
        challenges: [],
        errorMessage: e.toString(),
      );
    }
  }

  /// データマージ処理（最適化版）
  /// O(n×m) → O(n+m) に改善
  List<Challenge> _mergeChallenges(
    List<Challenge> baseChallenges,
    List<Challenge> completedChallenges,
  ) {
    if (kDebugMode) {
      print('🔄 [Challenge] データマージ処理開始...');
      print('  ベースチャレンジ数: ${baseChallenges.length}');
      print('  完了済みチャレンジ数: ${completedChallenges.length}');
    }

    // MapベースでO(1)のルックアップを実現
    final completedMap = <String, Challenge>{
      for (var c in completedChallenges) c.id: c
    };

    // マージ処理
    final merged = baseChallenges.map((challenge) {
      final completed = completedMap[challenge.id];
      if (completed != null) {
        if (kDebugMode && completed.oppositeOpinionText != null) {
          print('  ✅ ID:${challenge.id} 完了済み（${completed.earnedPoints}P）');
        }
        return completed;
      } else {
        if (kDebugMode) {
          print('  ⚪ ID:${challenge.id} 未完了（挑戦可能）');
        }
        return challenge;
      }
    }).toList();

    return merged;
  }

  // フィルタを変更するメソッド（非推奨 - challengeFilterProviderを直接使用）
  @Deprecated('Use challengeFilterProvider instead')
  void setFilter(ChallengeFilter filter) {
    ref.read(challengeFilterProvider.notifier).state = filter;
  }

  /// チャレンジを完了にする
  Future<void> completeChallenge(
    String challengeId,
    String oppositeOpinion,
    int earnedPoints, {
    String? feedbackText,
    int? feedbackScore,
  }) async {
    if (kDebugMode) {
      print('✍️ [Challenge] ========== completeChallenge() 開始 ==========');
      print('   チャレンジID: $challengeId');
      print('   反対意見の文字数: ${oppositeOpinion.length}文字');
      print('   獲得ポイント: $earnedPoints');
      if (feedbackText != null) {
        print('   フィードバック: ${feedbackText.length}文字');
        print('   フィードバックスコア: $feedbackScore');
      }
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (kDebugMode) {
        print('❌ [Challenge] ユーザーがログインしていません。処理を中断します。');
      }
      throw Exception('ユーザーがログインしていません');
    }

    if (kDebugMode) {
      print('✅ [Challenge] ユーザーID: ${currentUser.uid}');
    }

    // 現在の状態を取得（AsyncValueから）
    final currentState = state.value;
    if (currentState == null) {
      throw Exception('状態が初期化されていません');
    }

    // 該当するチャレンジを探す
    final index = currentState.challenges.indexWhere((c) => c.id == challengeId);

    if (index == -1) {
      if (kDebugMode) {
        print('❌ [Challenge] 該当するチャレンジが見つかりません（ID: $challengeId）');
      }
      throw Exception('チャレンジが見つかりません');
    }

    if (kDebugMode) {
      print('✅ [Challenge] 該当チャレンジを発見（インデックス: $index）');
    }

    final oldChallenge = currentState.challenges[index];
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
      feedbackText: feedbackText,
      feedbackScore: feedbackScore,
      feedbackGeneratedAt: feedbackText != null ? DateTime.now() : null,
    );

    // 楽観的UI更新用の新しいリスト
    final updatedChallenges = List<Challenge>.from(currentState.challenges);
    updatedChallenges[index] = completedChallenge;

    // 楽観的UI更新
    if (kDebugMode) {
      print('🔄 [Challenge] ローカル状態を更新（楽観的UI更新）');
    }

    final newState = currentState.copyWith(challenges: updatedChallenges);
    state = AsyncValue.data(newState);

    // ポイント更新
    final currentPoints = ref.read(currentPointsProvider);
    ref.read(currentPointsProvider.notifier).addPoints(earnedPoints);

    if (kDebugMode) {
      print('✅ [Challenge] ローカル状態更新完了（現在のポイント: ${currentPoints + earnedPoints}）');
    }

    // Firestoreに保存
    if (kDebugMode) {
      print('💾 [Challenge] Firestoreに保存開始...');
    }

    try {
      await repository.saveUserChallenge(completedChallenge);

      if (kDebugMode) {
        print('✅ [Challenge] Firestoreへの保存成功！');
        print('   保存したデータ:');
        print('     - ID: ${completedChallenge.id}');
        print('     - userId: ${completedChallenge.userId}');
        print('     - status: ${completedChallenge.status.name}');
        print('     - oppositeOpinionText: ${completedChallenge.oppositeOpinionText?.length}文字');
        print('     - earnedPoints: ${completedChallenge.earnedPoints}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Challenge] Firestoreへの保存失敗！');
        print('   エラー内容: $e');
        print('   スタックトレース: $stackTrace');
        print('🔄 [Challenge] 状態をロールバックします...');
      }

      // エラー時は元の状態に戻す（正確なロールバック）
      state = AsyncValue.data(currentState);
      ref.read(currentPointsProvider.notifier).setPoints(currentPoints);

      rethrow; // エラーを再スロー
    }

    if (kDebugMode) {
      print('✍️ [Challenge] ========================================\n');
    }
  }

  /// データをリフレッシュ
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadChallenges());
  }
}

final challengeProvider =
    AsyncNotifierProvider<ChallengeNotifier, ChallengeState>(() {
  return ChallengeNotifier();
});

// -----------------------------------------------------------------

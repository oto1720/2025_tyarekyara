import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/opinion.dart';
import '../models/topic.dart'; // TopicDifficultyをインポート
import '../repositories/opinion_repository.dart';
import '../../block/repositories/block_repository.dart';

part 'opinion_provider.freezed.dart';

/// 意見一覧の状態
@freezed
class OpinionListState with _$OpinionListState {
  const factory OpinionListState({
    @Default([]) List<Opinion> opinions,
    @Default(false) bool isLoading,
    String? error,
    @Default({}) Map<OpinionStance, int> stanceCounts,
  }) = _OpinionListState;
}

/// 意見投稿の状態
@freezed
class OpinionPostState with _$OpinionPostState {
  const factory OpinionPostState({
    @Default(false) bool isPosting,
    @Default(false) bool hasPosted,
    String? error,
    Opinion? userOpinion, // ユーザーが投稿した意見
  }) = _OpinionPostState;
}

/// 意見リポジトリプロバイダー
final opinionRepositoryProvider = Provider<OpinionRepository>((ref) {
  return OpinionRepository();
});

/// 意見一覧管理ノーティファイア
class OpinionListNotifier extends Notifier<OpinionListState> {
  OpinionListNotifier(this.topicId);

  final String topicId;

  OpinionRepository get repository => ref.read(opinionRepositoryProvider);

  @override
  OpinionListState build() {
    Future.microtask(() => loadOpinions());
    return const OpinionListState();
  }

  /// 意見一覧を読み込む
  Future<void> loadOpinions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final opinions = await repository.getOpinionsByTopic(topicId);
      final counts = await repository.getOpinionCountsByStance(topicId);

      // ブロックしたユーザーのIDリストを取得
      final blockRepository = BlockRepository();
      final blockedUserIds = await blockRepository.getBlockedUserIds();

      // ブロックしたユーザーの投稿を除外
      final filteredOpinions = opinions
          .where((o) => !blockedUserIds.contains(o.userId))
          .toList();

      // 自分の投稿を一番上に表示するようにソート
      final currentUser = FirebaseAuth.instance.currentUser;
      final sortedOpinions = <Opinion>[];

      if (currentUser != null) {
        // 自分の投稿を先に追加
        final myOpinions = filteredOpinions.where((o) => o.userId == currentUser.uid).toList();
        sortedOpinions.addAll(myOpinions);

        // 他の人の投稿を後に追加
        final otherOpinions = filteredOpinions.where((o) => o.userId != currentUser.uid).toList();
        sortedOpinions.addAll(otherOpinions);
      } else {
        // ログインしていない場合はそのまま
        sortedOpinions.addAll(filteredOpinions);
      }

      state = state.copyWith(
        opinions: sortedOpinions,
        stanceCounts: counts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '意見の読み込みに失敗しました: $e',
      );
    }
  }

  /// 意見をリフレッシュ
  Future<void> refresh() => loadOpinions();

  /// エラーをクリア
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// リアクションをトグル（楽観的UI更新）
  Future<void> toggleReaction({
    required String opinionId,
    required ReactionType type,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final key = type.key;
    final userId = currentUser.uid;

    // 即座にローカル状態を更新（楽観的UI更新）
    final updatedOpinions = state.opinions.map((opinion) {
      if (opinion.id != opinionId) return opinion;

      // このユーザーが既にリアクション済みか確認
      final reactedUsersList = opinion.reactedUsers[key] ?? [];
      final hasReacted = reactedUsersList.contains(userId);

      // リアクション情報を更新
      final newReactionCounts = Map<String, int>.from(opinion.reactionCounts);
      final newReactedUsers = Map<String, List<String>>.from(
        opinion.reactedUsers.map((k, v) => MapEntry(k, List<String>.from(v))),
      );

      if (hasReacted) {
        // リアクション削除
        newReactionCounts[key] = (newReactionCounts[key] ?? 1) - 1;
        newReactedUsers[key] = (newReactedUsers[key] ?? [])
          ..remove(userId);
      } else {
        // リアクション追加
        newReactionCounts[key] = (newReactionCounts[key] ?? 0) + 1;
        newReactedUsers[key] = (newReactedUsers[key] ?? [])
          ..add(userId);
      }

      return opinion.copyWith(
        reactionCounts: newReactionCounts,
        reactedUsers: newReactedUsers,
      );
    }).toList();

    // 状態を即座に更新
    state = state.copyWith(opinions: updatedOpinions);

    // バックグラウンドでFirestoreを更新
    try {
      await repository.toggleReaction(
        opinionId: opinionId,
        userId: userId,
        type: type,
      );
    } catch (e) {
      print('Error toggling reaction: $e');
      // エラー時は元に戻す
      await loadOpinions();
    }
  }
}

/// 特定トピックの意見一覧プロバイダー
final opinionListProvider =
    NotifierProvider.family<OpinionListNotifier, OpinionListState, String>(
  OpinionListNotifier.new,
);

/// 意見投稿管理ノーティファイア
class OpinionPostNotifier extends Notifier<OpinionPostState> {
  OpinionPostNotifier(this.topicId);

  final String topicId;

  OpinionRepository get repository => ref.read(opinionRepositoryProvider);

  @override
  OpinionPostState build() {
    Future.microtask(() => checkUserOpinion());
    return const OpinionPostState();
  }

  /// ユーザーが既に投稿しているか確認
  Future<void> checkUserOpinion() async {
    // ゲストモードの場合はスキップ（ゲストは複数回投稿可能）
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('is_guest_mode') ?? false;
    if (isGuest) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userOpinion = await repository.getUserOpinion(topicId, user.uid);
      state = state.copyWith(
        hasPosted: userOpinion != null,
        userOpinion: userOpinion,
      );
    } catch (e) {
      print('Error checking user opinion: $e');
    }
  }

  /// 意見を投稿
  Future<bool> postOpinion({
    required String topicText,
    TopicDifficulty? topicDifficulty, // トピックの難易度を追加
    required OpinionStance stance,
    required String content,
  }) async {
    // ゲストモードをチェック
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('is_guest_mode') ?? false;

    String userId;
    String userName;

    if (isGuest) {
      // ゲストモードの場合
      userId = 'guest_${const Uuid().v4().substring(0, 8)}'; // ユニークなゲストID
      userName = 'ゲスト';
    } else {
      // 通常モード：Firebaseユーザーを使用
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(error: 'ログインしてください');
        return false;
      }

      userId = user.uid;

      // Firestoreからユーザー情報（nickname）を取得
      userName = '匿名ユーザー';
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          userName = userDoc.data()?['nickname'] ?? '匿名ユーザー';
        }
      } catch (e) {
        print('Error fetching user nickname: $e');
        // エラーの場合はデフォルト値を使用
      }
    }

    state = state.copyWith(isPosting: true, error: null);

    try {
      final opinion = Opinion(
        id: const Uuid().v4(),
        topicId: topicId,
        topicText: topicText,
        topicDifficulty: topicDifficulty, // トピックの難易度を保存
        userId: userId,
        userName: userName,
        stance: stance,
        content: content,
        createdAt: DateTime.now(),
      );

      await repository.postOpinion(opinion);

      state = state.copyWith(
        isPosting: false,
        hasPosted: true,
        userOpinion: opinion,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        error: '意見の投稿に失敗しました: $e',
      );
      return false;
    }
  }

  /// 意見を更新（編集）
  Future<bool> updateOpinion({
    required OpinionStance stance,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || state.userOpinion == null) {
      state = state.copyWith(error: 'ログインしてください');
      return false;
    }

    state = state.copyWith(isPosting: true, error: null);

    try {
      await repository.updateOpinion(
        opinionId: state.userOpinion!.id,
        stance: stance,
        content: content,
      );

      // 更新後の意見を作成
      final updatedOpinion = state.userOpinion!.copyWith(
        stance: stance,
        content: content,
      );

      state = state.copyWith(
        isPosting: false,
        userOpinion: updatedOpinion,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        error: '意見の更新に失敗しました: $e',
      );
      return false;
    }
  }

  /// エラーをクリア
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 意見投稿プロバイダー
final opinionPostProvider =
    NotifierProvider.family<OpinionPostNotifier, OpinionPostState, String>(
  OpinionPostNotifier.new,
);

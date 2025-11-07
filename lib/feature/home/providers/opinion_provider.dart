import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/opinion.dart';
import '../repositories/opinion_repository.dart';

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

      // 自分の投稿を一番上に表示するようにソート
      final currentUser = FirebaseAuth.instance.currentUser;
      final sortedOpinions = <Opinion>[];

      if (currentUser != null) {
        // 自分の投稿を先に追加
        final myOpinions = opinions.where((o) => o.userId == currentUser.uid).toList();
        sortedOpinions.addAll(myOpinions);

        // 他の人の投稿を後に追加
        final otherOpinions = opinions.where((o) => o.userId != currentUser.uid).toList();
        sortedOpinions.addAll(otherOpinions);
      } else {
        // ログインしていない場合はそのまま
        sortedOpinions.addAll(opinions);
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
    required OpinionStance stance,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(error: 'ログインしてください');
      return false;
    }

    state = state.copyWith(isPosting: true, error: null);

    try {
      final opinion = Opinion(
        id: const Uuid().v4(),
        topicId: topicId,
        topicText: topicText,
        userId: user.uid,
        userName: user.displayName ?? '匿名ユーザー',
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/block_repository.dart';

// リポジトリのプロバイダー
final blockRepositoryProvider = Provider<BlockRepository>((ref) {
  return BlockRepository();
});

// ブロックしたユーザーのIDリストを監視
final blockedUserIdsProvider = StreamProvider<List<String>>((ref) {
  final repository = ref.watch(blockRepositoryProvider);
  return repository.watchBlockedUserIds();
});

// 特定のユーザーをブロックしているかどうか
final isUserBlockedProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.watch(blockRepositoryProvider);
  return await repository.isBlocked(userId);
});

// ブロック操作の状態管理
class BlockNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 初期化は不要
  }

  Future<void> blockUser(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(blockRepositoryProvider);
      await repository.blockUser(userId);
    });
  }

  Future<void> unblockUser(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(blockRepositoryProvider);
      await repository.unblockUser(userId);
    });
  }
}

final blockNotifierProvider = AsyncNotifierProvider<BlockNotifier, void>(() {
  return BlockNotifier();
});

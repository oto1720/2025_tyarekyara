import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/terms_repository.dart';

// リポジトリのプロバイダー
final termsRepositoryProvider = Provider<TermsRepository>((ref) {
  return TermsRepository();
});

// 利用規約に同意済みかどうかをチェック
final hasAcceptedTermsProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repository = ref.watch(termsRepositoryProvider);
  final userId = repository.getCurrentUserId();

  if (userId == null) {
    return false;
  }

  return await repository.hasAcceptedTerms(userId);
});

// 利用規約に同意中かどうかの状態（使用されていない可能性があるため削除）
// final isAcceptingTermsProvider = StateProvider<bool>((ref) => false);

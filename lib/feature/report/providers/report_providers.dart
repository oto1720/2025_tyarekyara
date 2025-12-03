import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/report_repository.dart';
import '../models/report.dart';

// リポジトリのプロバイダー
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

// 報告ダイアログを表示するためのヘルパー関数を提供するプロバイダー
class ReportNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 初期化は不要
  }

  Future<void> submitReport({
    required String reportedUserId,
    required ReportType type,
    required String contentId,
    required ReportReason reason,
    String? details,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reportRepositoryProvider);
      await repository.createReport(
        reportedUserId: reportedUserId,
        type: type,
        contentId: contentId,
        reason: reason,
        details: details,
      );
    });
  }
}

final reportNotifierProvider = AsyncNotifierProvider<ReportNotifier, void>(() {
  return ReportNotifier();
});

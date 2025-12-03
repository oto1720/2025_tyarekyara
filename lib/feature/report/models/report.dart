import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

enum ReportType {
  opinion,        // 意見投稿
  debateMessage,  // ディベートメッセージ
}

enum ReportReason {
  spam,           // スパム
  inappropriate,  // 不適切なコンテンツ
  harassment,     // ハラスメント
  hateSpeech,     // ヘイトスピーチ
  violence,       // 暴力的な表現
  other,          // その他
}

@freezed
class Report with _$Report {
  const factory Report({
    required String id,
    required String reporterId,      // 報告者のUID
    required String reportedUserId,  // 報告されたユーザーのUID
    required ReportType type,        // 報告の種類
    required String contentId,       // 報告されたコンテンツのID（意見IDまたはメッセージID）
    required ReportReason reason,    // 報告理由
    String? details,                 // 詳細説明（任意）
    required DateTime createdAt,     // 報告日時
    @Default(false) bool isResolved, // 対応済みかどうか
    DateTime? resolvedAt,            // 対応日時
    String? resolvedBy,              // 対応した管理者のUID
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

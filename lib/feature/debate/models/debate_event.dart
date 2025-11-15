import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'debate_event.freezed.dart';

/// イベント開催状態
enum EventStatus {
  scheduled,  // スケジュール済み
  accepting,  // エントリー受付中
  matching,   // マッチング中
  inProgress, // 開催中
  completed,  // 完了
  cancelled,  // キャンセル
}

/// ディベート時間設定
enum DebateDuration {
  short,   // 5分
  medium,  // 10分
  long,    // 15分
}

extension DebateDurationExtension on DebateDuration {
  int get minutes {
    switch (this) {
      case DebateDuration.short:
        return 5;
      case DebateDuration.medium:
        return 10;
      case DebateDuration.long:
        return 15;
    }
  }

  String get displayName {
    switch (this) {
      case DebateDuration.short:
        return '5分';
      case DebateDuration.medium:
        return '10分';
      case DebateDuration.long:
        return '15分';
    }
  }
}

/// ディベート形式
enum DebateFormat {
  oneVsOne, // 1vs1
  twoVsTwo, // 2vs2
}

extension DebateFormatExtension on DebateFormat {
  String get displayName {
    switch (this) {
      case DebateFormat.oneVsOne:
        return '1vs1';
      case DebateFormat.twoVsTwo:
        return '2vs2';
    }
  }

  int get teamSize {
    switch (this) {
      case DebateFormat.oneVsOne:
        return 1;
      case DebateFormat.twoVsTwo:
        return 2;
    }
  }
}

/// ディベートイベント
@freezed
class DebateEvent with _$DebateEvent {
  const factory DebateEvent({
    required String id,
    required String title,
    required String topic,
    required String description,
    required EventStatus status,
    required DateTime scheduledAt,
    required DateTime entryDeadline,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<DebateDuration> availableDurations,
    @Default([]) List<DebateFormat> availableFormats,
    @Default(0) int currentParticipants,
    @Default(100) int maxParticipants,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) = _DebateEvent;

  factory DebateEvent.fromJson(Map<String, dynamic> json) {
    // TimestampをDateTimeに変換
    return DebateEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String,
      description: json['description'] as String,
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.scheduled,
      ),
      scheduledAt: (json['scheduledAt'] as Timestamp).toDate(),
      entryDeadline: (json['entryDeadline'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      availableDurations: (json['availableDurations'] as List<dynamic>?)
              ?.map((e) => DebateDuration.values.firstWhere(
                    (d) => d.name == e,
                    orElse: () => DebateDuration.medium,
                  ))
              .toList() ??
          [],
      availableFormats: (json['availableFormats'] as List<dynamic>?)
              ?.map((e) => DebateFormat.values.firstWhere(
                    (f) => f.name == e,
                    orElse: () => DebateFormat.twoVsTwo,
                  ))
              .toList() ??
          [],
      currentParticipants: json['currentParticipants'] as int? ?? 0,
      maxParticipants: json['maxParticipants'] as int? ?? 100,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Firestore保存用のtoJsonカスタマイズ
  static Map<String, dynamic> toFirestore(DebateEvent event) {
    return {
      'id': event.id,
      'title': event.title,
      'topic': event.topic,
      'description': event.description,
      'status': event.status.name,
      'scheduledAt': Timestamp.fromDate(event.scheduledAt),
      'entryDeadline': Timestamp.fromDate(event.entryDeadline),
      'createdAt': Timestamp.fromDate(event.createdAt),
      'updatedAt': Timestamp.fromDate(event.updatedAt),
      'availableDurations':
          event.availableDurations.map((e) => e.name).toList(),
      'availableFormats': event.availableFormats.map((e) => e.name).toList(),
      'currentParticipants': event.currentParticipants,
      'maxParticipants': event.maxParticipants,
      'imageUrl': event.imageUrl,
      'metadata': event.metadata,
    };
  }
}

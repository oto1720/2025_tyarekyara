# ディベート機能

ユーザーがリアルタイムで議論を行い、AIによる公平な判定を受けることができるディベート機能の実装です。

## 📁 ディレクトリ構成

```
lib/feature/debate/
├── models/                              # データモデル（Freezed）
│   ├── debate_event.dart               # イベント定義
│   ├── debate_match.dart               # マッチ・エントリー
│   ├── debate_room.dart                # ルーム定義
│   ├── debate_message.dart             # メッセージ
│   ├── judgment_result.dart            # AI判定結果
│   ├── user_debate_stats.dart          # ユーザー統計
│   └── *.freezed.dart / *.g.dart       # 自動生成ファイル
├── repositories/                        # データアクセスレイヤー
│   ├── debate_event_repository.dart    # イベントCRUD
│   ├── debate_match_repository.dart    # マッチ・エントリー管理
│   ├── debate_room_repository.dart     # ルーム・メッセージ・判定管理
│   └── user_debate_stats_repository.dart # 統計・ランキング
├── providers/                           # 状態管理（Riverpod）
│   ├── debate_event_provider.dart      # イベント関連プロバイダー
│   ├── debate_match_provider.dart      # マッチ関連プロバイダー
│   ├── debate_room_provider.dart       # ルーム関連プロバイダー
│   ├── user_debate_stats_provider.dart # 統計関連プロバイダー
│   └── today_debate_event_provider.dart # 今日のイベントチェック
├── presentation/
│   ├── pages/                          # 画面
│   │   ├── debate_event_list_page.dart       # イベント一覧
│   │   ├── debate_event_detail_page.dart     # イベント詳細
│   │   ├── debate_entry_page.dart            # エントリー画面
│   │   ├── debate_waiting_room_page.dart     # 待機画面
│   │   ├── debate_match_detail_page.dart     # マッチ詳細
│   │   ├── debate_room_page.dart             # ディベートルーム
│   │   ├── debate_judgment_waiting_page.dart # 判定待機
│   │   ├── debate_result_page.dart           # 結果表示
│   │   ├── debate_ranking_page.dart          # ランキング
│   │   ├── debate_stats_page.dart            # 統計
│   │   └── debate_rules_page.dart            # ルール説明
│   └── widgets/                        # UIコンポーネント
│       ├── event_card.dart             # イベントカード
│       ├── entry_form.dart             # エントリーフォーム
│       ├── phase_indicator_widget.dart # フェーズ表示
│       ├── debate_timer_widget.dart    # タイマー
│       ├── debate_chat_widget.dart     # チャット
│       ├── judgment_score_widget.dart  # スコア表示
│       ├── judgment_chart_widget.dart  # チャート
│       ├── matching_status_widget.dart # マッチング状態
│       ├── level_progress_widget.dart  # レベル進捗
│       ├── badge_display_widget.dart   # バッジ表示
│       └── points_animation_widget.dart # ポイントアニメーション
├── FIRESTORE_SCHEMA.md                 # Firestoreスキーマ定義
├── AI_JUDGMENT_IMPLEMENTATION.md       # AI判定実装詳細
└── README.md                           # このファイル
```

---

## 🏗️ アーキテクチャ概要

### レイヤー構成

```
Presentation Layer (UI)
    ↓ (使用)
Providers Layer (State Management - Riverpod)
    ↓ (使用)
Repositories Layer (Data Access)
    ↓ (アクセス)
Firebase Firestore (Database)
    ↓ (トリガー)
Cloud Functions (Server Logic)
    ↓ (呼び出し)
Vertex AI (Gemini 1.5 Flash)
```

### データフロー

```
UI → Provider → Repository → Firestore
                    ↓
              Cloud Functions
                    ↓
              Vertex AI (判定)
                    ↓
              Firestore (判定結果保存)
                    ↓
              Provider (リアルタイム更新)
                    ↓
              UI (結果表示)
```

---

## 📊 データモデル詳細

### 1. DebateEvent（イベント）

**ファイル**: `models/debate_event.dart`

**クラス構造**:
```dart
@freezed
class DebateEvent with _$DebateEvent {
  const factory DebateEvent({
    required String id,
    required String topic,
    required String description,
    required String category,
    @TimestampConverter() required DateTime scheduledAt,
    required EventStatus status,
    required List<DebateDuration> allowedDurations,
    required List<DebateFormat> allowedFormats,
    @Default(0) int participantCount,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _DebateEvent;
}
```

**Enum定義**:
- `EventStatus`: scheduled, accepting, matching, inProgress, completed, cancelled
- `DebateDuration`: short(5分), medium(10分), long(15分)
- `DebateFormat`: oneVsOne(1v1), twoVsTwo(2v2)

**使用箇所**:
- `DebateEventRepository`: CRUD操作
- `debate_event_provider.dart`: 状態管理
- `debate_event_list_page.dart`: 一覧表示
- `debate_event_detail_page.dart`: 詳細表示

---

### 2. DebateMatch（マッチ）・ DebateEntry（エントリー）

**ファイル**: `models/debate_match.dart`

**DebateEntry**:
```dart
@freezed
class DebateEntry with _$DebateEntry {
  const factory DebateEntry({
    required String id,
    required String eventId,
    required String userId,
    required DebateStance stance,
    required DebateFormat format,
    required DebateDuration duration,
    required MatchStatus status,
    String? matchId,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _DebateEntry;
}
```

**DebateTeam**:
```dart
@freezed
class DebateTeam with _$DebateTeam {
  const factory DebateTeam({
    required List<String> memberIds,
    required DebateStance stance,
  }) = _DebateTeam;
}
```

**DebateMatch**:
```dart
@freezed
class DebateMatch with _$DebateMatch {
  const factory DebateMatch({
    required String id,
    required String eventId,
    required DebateTeam proTeam,
    required DebateTeam conTeam,
    required DebateDuration duration,
    required DebateFormat format,
    required MatchStatus status,
    String? roomId,
    String? judgmentId,
    DebateStance? winningSide,
    @TimestampConverter() required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _DebateMatch;
}
```

**Enum定義**:
- `MatchStatus`: waiting, matched, inProgress, completed, cancelled
- `DebateStance`: pro(賛成), con(反対), any(どちらでも)

**使用箇所**:
- `DebateMatchRepository`: エントリー・マッチ管理
- `debate_match_provider.dart`: 状態管理
- `debate_entry_page.dart`: エントリー登録
- `debate_waiting_room_page.dart`: マッチング待機
- `debate_match_detail_page.dart`: マッチ詳細

---

### 3. DebateRoom（ルーム）

**ファイル**: `models/debate_room.dart`

**クラス構造**:
```dart
@freezed
class DebateRoom with _$DebateRoom {
  const factory DebateRoom({
    required String id,
    required String matchId,
    required String eventId,
    required DebatePhase currentPhase,
    @TimestampConverter() required DateTime phaseStartedAt,
    required RoomStatus status,
    required Map<String, DebateStance> participantStances,
    @Default({}) Map<String, int> messageCount,
    @Default({}) Map<String, int> warningCount,
    String? judgmentId,
    @TimestampConverter() required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _DebateRoom;
}
```

**Enum定義**:
- `RoomStatus`: waiting, active, completed, judging
- `DebatePhase`: 12フェーズ
  - preparation（準備）
  - openingPro（立論 賛成）
  - openingCon（立論 反対）
  - questionPrepPro（質疑準備 賛成）
  - questionToPro（質疑 賛成へ）
  - questionPrepCon（質疑準備 反対）
  - questionToCon（質疑 反対へ）
  - rebuttalPrepPro（反論準備 賛成）
  - rebuttalPro（反論 賛成）
  - rebuttalPrepCon（反論準備 反対）
  - rebuttalCon（反論 反対）
  - closingPro, closingCon（最終主張）
  - judgment（判定）

**使用箇所**:
- `DebateRoomRepository`: ルーム管理
- `debate_room_provider.dart`: 状態管理
- `debate_room_page.dart`: ディベート実行

---

### 4. DebateMessage（メッセージ）

**ファイル**: `models/debate_message.dart`

**クラス構造**:
```dart
@freezed
class DebateMessage with _$DebateMessage {
  const factory DebateMessage({
    required String id,
    required String roomId,
    required String userId,
    required String content,
    required MessageType type,
    required DebatePhase phase,
    required MessageStatus status,
    @Default(false) bool isWarning,
    DebateStance? senderStance,
    @TimestampConverter() required DateTime createdAt,
  }) = _DebateMessage;
}
```

**Enum定義**:
- `MessageType`: public（公開）, team（チーム内）
- `MessageStatus`: sent, received, deleted

**制限定数**:
```dart
class MessageLimits {
  static const int maxLength = 200;
  static const Duration cooldown = Duration(seconds: 30);
  static const int maxWarnings = 3;
}
```

**使用箇所**:
- `DebateRoomRepository`: メッセージCRUD
- `debate_room_provider.dart`: リアルタイム監視
- `debate_chat_widget.dart`: チャット表示・送信

---

### 5. JudgmentResult（判定結果）

**ファイル**: `models/judgment_result.dart`

**クラス構造**:
```dart
@freezed
class JudgmentResult with _$JudgmentResult {
  const factory JudgmentResult({
    required String id,
    required String matchId,
    required String roomId,
    required String eventId,
    required TeamScore proTeamScore,
    required TeamScore conTeamScore,
    DebateStance? winningSide,
    String? mvpUserId,
    required String overallComment,
    required String proTeamComment,
    required String conTeamComment,
    @TimestampConverter() required DateTime judgedAt,
    @TimestampConverter() required DateTime createdAt,
  }) = _JudgmentResult;
}

@freezed
class TeamScore with _$TeamScore {
  const factory TeamScore({
    required int logicScore,        // 論理性（0-10）
    required int evidenceScore,     // 根拠（0-10）
    required int rebuttalScore,     // 反論力（0-10）
    required int persuasivenessScore, // 説得力（0-10）
    required int mannerScore,       // マナー（0-10）
    required int totalScore,        // 合計（0-50）
  }) = _TeamScore;
}
```

**使用箇所**:
- Cloud Functions: AI判定で作成
- `DebateRoomRepository`: 判定結果取得
- `debate_room_provider.dart`: 判定結果提供
- `debate_result_page.dart`: 結果表示

---

### 6. UserDebateStats（ユーザー統計）

**ファイル**: `models/user_debate_stats.dart`

**クラス構造**:
```dart
@freezed
class UserDebateStats with _$UserDebateStats {
  const factory UserDebateStats({
    required String userId,
    @Default(0) int totalDebates,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int draws,
    @Default(0) int totalPoints,
    @Default(1) int level,
    @Default(0) int currentLevelPoints,
    @Default(100) int pointsToNextLevel,
    @Default(0) int mvpCount,
    @Default(0) int winStreak,
    @Default(0) int currentMonthPoints,
    @Default([]) List<EarnedBadge> earnedBadges,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _UserDebateStats;
}

@freezed
class EarnedBadge with _$EarnedBadge {
  const factory EarnedBadge({
    required BadgeType type,
    @TimestampConverter() required DateTime earnedAt,
  }) = _EarnedBadge;
}
```

**Enum定義**:
```dart
enum BadgeType {
  firstDebate,      // はじめの一歩
  tenDebates,       // 10回参加
  firstWin,         // 初勝利
  tenWins,          // 10勝
  winStreak,        // 3連勝
  perfectLogic,     // 論理性満点
  mvpAward,         // MVP獲得
  weeklyParticipation, // 週間皆勤
}
```

**使用箇所**:
- `UserDebateStatsRepository`: 統計CRUD
- `user_debate_stats_provider.dart`: 状態管理
- `debate_stats_page.dart`: 統計表示
- Cloud Functions: ディベート後に更新

---

## 🔄 リポジトリ詳細

### 1. DebateEventRepository

**ファイル**: `repositories/debate_event_repository.dart`

**依存関係**:
- `cloud_firestore` - Firebaseデータベース
- `models/debate_event.dart` - データモデル

**主要メソッド**:
```dart
class DebateEventRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'debate_events';

  // イベント取得（Future）
  Future<List<DebateEvent>> getUpcomingEvents({int limit = 20})
  Future<List<DebateEvent>> getCompletedEvents({int limit = 20})
  Future<DebateEvent?> getEvent(String eventId)

  // イベント監視（Stream）
  Stream<DebateEvent?> watchEvent(String eventId)
  Stream<List<DebateEvent>> watchUpcomingEvents({int limit = 20})

  // イベント作成・更新
  Future<void> createEvent(DebateEvent event)
  Future<void> updateEvent(String eventId, Map<String, dynamic> data)
  Future<void> updateParticipantCount(String eventId, int count)
}
```

**使用されるプロバイダー**:
- `debateEventRepositoryProvider`
- `upcomingEventsProvider`
- `eventDetailProvider`
- `eventListProvider`
- `completedEventsProvider`

---

### 2. DebateMatchRepository

**ファイル**: `repositories/debate_match_repository.dart`

**依存関係**:
- `cloud_firestore`
- `models/debate_match.dart`

**主要メソッド**:
```dart
class DebateMatchRepository {
  final FirebaseFirestore _firestore;
  static const String _entriesCollection = 'debate_entries';
  static const String _matchesCollection = 'debate_matches';

  // エントリー管理
  Future<void> createEntry(DebateEntry entry)
  Future<DebateEntry?> getUserEntry(String eventId, String userId)
  Stream<DebateEntry?> watchUserEntry(String eventId, String userId)
  Future<int> getEntryCount(String eventId, MatchStatus status)

  // マッチ管理
  Future<DebateMatch?> getCurrentMatch(String userId)
  Future<DebateMatch?> getUserMatchByEvent(String eventId, String userId)
  Stream<DebateMatch?> watchMatch(String matchId)
  Future<List<DebateMatch>> getUserMatchHistory(String userId, {int limit = 20})
  Future<void> updateMatchStatus(String matchId, MatchStatus status)
}
```

**使用されるプロバイダー**:
- `debateMatchRepositoryProvider`
- `userEntryProvider` - (eventId, userId)をパラメータとするfamily
- `currentMatchProvider` - userIdをパラメータ
- `matchDetailProvider` - matchIdをパラメータ
- `matchHistoryProvider` - userIdをパラメータ

---

### 3. DebateRoomRepository

**ファイル**: `repositories/debate_room_repository.dart`

**依存関係**:
- `cloud_firestore`
- `models/debate_room.dart`
- `models/debate_message.dart`
- `models/judgment_result.dart`

**主要メソッド**:
```dart
class DebateRoomRepository {
  final FirebaseFirestore _firestore;
  static const String _roomsCollection = 'debate_rooms';
  static const String _messagesSubcollection = 'messages';
  static const String _judgmentsCollection = 'debate_judgments';

  // ルーム管理
  Future<DebateRoom?> getRoom(String roomId)
  Stream<DebateRoom?> watchRoom(String roomId)
  Stream<DebateRoom?> watchRoomByMatchId(String matchId)
  Future<void> updateRoom(String roomId, Map<String, dynamic> data)
  Future<void> updatePhase(String roomId, DebatePhase newPhase)

  // メッセージ管理
  Future<void> sendMessage(DebateMessage message)
  Stream<List<DebateMessage>> watchMessages(
    String roomId, {
    MessageType? type,
    DebateStance? senderStance,
  })
  Future<List<DebateMessage>> getMessages(String roomId)

  // 判定管理
  Future<JudgmentResult?> getJudgmentByMatchId(String matchId)
  Future<JudgmentResult?> getJudgment(String judgmentId)
}
```

**使用されるプロバイダー**:
- `debateRoomRepositoryProvider`
- `roomDetailProvider` - roomIdをパラメータ
- `roomMessagesProvider` - roomIdをパラメータ
- `teamMessagesProvider` - roomIdをパラメータ
- `debateRoomByMatchProvider` - matchIdをパラメータ
- `debateMessagesProvider` - (roomId, MessageType)をパラメータ
- `teamMessagesWithStanceProvider` - (roomId, DebateStance)をパラメータ
- `judgmentResultProvider` - matchIdをパラメータ

---

### 4. UserDebateStatsRepository

**ファイル**: `repositories/user_debate_stats_repository.dart`

**依存関係**:
- `cloud_firestore`
- `models/user_debate_stats.dart`

**主要メソッド**:
```dart
class UserDebateStatsRepository {
  final FirebaseFirestore _firestore;
  static const String _statsCollection = 'user_debate_stats';
  static const String _rankingsCollection = 'debate_rankings';

  // 統計管理
  Future<UserDebateStats?> getUserStats(String userId)
  Stream<UserDebateStats?> watchUserStats(String userId)
  Future<void> updateStats(String userId, Map<String, dynamic> data)
  Future<void> awardBadge(String userId, BadgeType badge)
  Future<void> resetMonthlyPoints()

  // ランキング
  Future<List<RankingEntry>> getPointsRanking({int limit = 100})
  Future<List<RankingEntry>> getWinRateRanking({int limit = 100})
  Future<List<RankingEntry>> getParticipationRanking({int limit = 100})
}
```

**使用されるプロバイダー**:
- `userDebateStatsRepositoryProvider`
- `userStatsProvider` - userIdをパラメータ
- `pointsRankingProvider`
- `winRateRankingProvider`
- `participationRankingProvider`

---

## 📡 プロバイダー詳細

### 1. debate_event_provider.dart

**プロバイダー一覧**:
```dart
// リポジトリ提供
final debateEventRepositoryProvider = Provider<DebateEventRepository>

// 開催予定イベント（マッチ完了済みイベントを除外）
final upcomingEventsProvider = StreamProvider.autoDispose<List<DebateEvent>>

// 特定イベント詳細
final eventDetailProvider = StreamProvider.autoDispose.family<DebateEvent?, String>

// イベント一覧（Future）
final eventListProvider = FutureProvider.autoDispose<List<DebateEvent>>

// 完了イベント一覧
final completedEventsProvider = FutureProvider.autoDispose<List<DebateEvent>>
```

**依存関係**:
- `debateEventRepositoryProvider`
- `debateMatchRepositoryProvider` - ユーザーのマッチ確認用
- `firebase_auth` - 現在のユーザー取得

**使用箇所**:
- `debate_event_list_page.dart`
- `debate_event_detail_page.dart`

---

### 2. debate_match_provider.dart

**プロバイダー一覧**:
```dart
// リポジトリ提供
final debateMatchRepositoryProvider = Provider<DebateMatchRepository>

// ユーザーのエントリー状態
final userEntryProvider = StreamProvider.autoDispose.family<DebateEntry?, (String, String)>

// ユーザーの現在のマッチ
final currentMatchProvider = FutureProvider.autoDispose.family<DebateMatch?, String>

// マッチ詳細
final matchDetailProvider = StreamProvider.autoDispose.family<DebateMatch?, String>

// マッチ履歴
final matchHistoryProvider = FutureProvider.autoDispose.family<List<DebateMatch>, String>
```

**依存関係**:
- `debateMatchRepositoryProvider`

**使用箇所**:
- `debate_entry_page.dart`
- `debate_waiting_room_page.dart`
- `debate_match_detail_page.dart`
- `debate_room_page.dart`

---

### 3. debate_room_provider.dart

**プロバイダー一覧**:
```dart
// リポジトリ提供
final debateRoomRepositoryProvider = Provider<DebateRoomRepository>

// ルーム詳細
final roomDetailProvider = StreamProvider.autoDispose.family<DebateRoom?, String>

// ルームメッセージ一覧
final roomMessagesProvider = StreamProvider.autoDispose.family<List<DebateMessage>, String>

// チーム内メッセージ
final teamMessagesProvider = StreamProvider.autoDispose.family<List<DebateMessage>, String>

// マッチIDからルーム取得
final debateRoomByMatchProvider = StreamProvider.autoDispose.family<DebateRoom?, String>

// メッセージタイプ別
final debateMessagesProvider = StreamProvider.autoDispose.family<List<DebateMessage>, (String, MessageType)>

// チームメッセージ（スタンス別）
final teamMessagesWithStanceProvider = StreamProvider.autoDispose.family<List<DebateMessage>, (String, DebateStance)>

// 判定結果
final judgmentResultProvider = FutureProvider.autoDispose.family<JudgmentResult?, String>
```

**依存関係**:
- `debateRoomRepositoryProvider`

**使用箇所**:
- `debate_room_page.dart` - ルーム、メッセージ、フェーズ管理
- `debate_judgment_waiting_page.dart` - 判定結果監視
- `debate_result_page.dart` - 判定結果表示

---

### 4. user_debate_stats_provider.dart

**プロバイダー一覧**:
```dart
// リポジトリ提供
final userDebateStatsRepositoryProvider = Provider<UserDebateStatsRepository>

// ユーザー統計
final userStatsProvider = StreamProvider.autoDispose.family<UserDebateStats?, String>

// ランキング
final pointsRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>
final winRateRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>
final participationRankingProvider = FutureProvider.autoDispose<List<RankingEntry>>
```

**依存関係**:
- `userDebateStatsRepositoryProvider`

**使用箇所**:
- `debate_stats_page.dart` - 統計表示
- `debate_ranking_page.dart` - ランキング表示

---

### 5. today_debate_event_provider.dart

**プロバイダー一覧**:
```dart
// 特定イベントが今日のイベントか判定
final isTodayEventProvider = Provider.autoDispose.family<bool, String>
```

**依存関係**:
- `debateEventRepositoryProvider`
- 日付比較ロジック

**使用箇所**:
- `core/providers/debate_event_unlock_provider.dart` - ディベート解放判定

---

## 🎨 主要画面とフロー

### 1. イベント一覧画面 → エントリー → マッチング

```
DebateEventListPage
  ↓ (ref.watch)
upcomingEventsProvider
  ↓ (取得)
DebateEventRepository.watchUpcomingEvents()
  ↓ (Firestore Stream)
debate_events コレクション

ユーザーがイベント選択
  ↓
DebateEventDetailPage(eventId)
  ↓ (ref.watch)
eventDetailProvider(eventId)
  ↓
「参加」ボタンタップ
  ↓
DebateEntryPage(eventId)
  ↓ (フォーム送信)
debateMatchRepository.createEntry()
  ↓ (Firestore書き込み)
debate_entries コレクション

遷移: DebateWaitingRoomPage(eventId)
  ↓ (ref.watch)
userEntryProvider((eventId, userId))
  ↓ (Stream監視)
entry.status: waiting → matched
  ↓
entry.matchId が割り当てられる
  ↓ (自動遷移)
DebateMatchDetailPage(matchId)
```

---

### 2. ディベート実行 → 判定 → 結果表示

```
DebateMatchDetailPage(matchId)
  ↓ (ref.watch)
matchDetailProvider(matchId)
  ↓
「開始」ボタンタップ
  ↓
DebateRoomPage(matchId)
  ↓ (ref.watch)
debateRoomByMatchProvider(matchId)
roomMessagesProvider(roomId)
  ↓
ユーザーがメッセージ送信
  ↓
debateRoomRepository.sendMessage()
  ↓ (Firestore書き込み)
debate_rooms/{roomId}/messages サブコレクション
  ↓ (Stream自動更新)
全参加者のUI更新

フェーズ進行（12フェーズ）
  ↓
最終フェーズ終了
  ↓
room.status = RoomStatus.judging
  ↓ (Cloud Functions トリガー)
onDebateComplete
  ↓ (AI判定)
Vertex AI (Gemini 1.5 Flash)
  ↓ (判定結果保存)
debate_judgments コレクション
  ↓
DebateJudgmentWaitingPage(matchId)
  ↓ (ref.watch)
judgmentResultProvider(matchId)
  ↓ (判定完了検知)
自動遷移
  ↓
DebateResultPage(matchId)
  ↓ (表示)
勝敗・スコア・チャート・MVP・コメント
```

---

### 3. 統計・ランキング表示

```
DebateStatsPage
  ↓ (ref.watch)
userStatsProvider(userId)
  ↓ (Stream)
UserDebateStatsRepository.watchUserStats()
  ↓ (Firestore)
user_debate_stats/{userId}
  ↓ (表示)
レベル・ポイント・勝敗・バッジ

DebateRankingPage
  ↓ (ref.watch)
pointsRankingProvider
winRateRankingProvider
participationRankingProvider
  ↓ (Future)
UserDebateStatsRepository.get***Ranking()
  ↓ (Firestore)
debate_rankings/{type}/users コレクション
  ↓ (表示)
ランキングリスト・自分の順位
```

---

## 🔗 依存関係マップ

### 外部パッケージ依存

```
全ファイル共通:
  ├─ flutter_riverpod (状態管理)
  ├─ freezed_annotation (イミュータブルモデル)
  └─ json_annotation (JSONシリアライズ)

models/:
  ├─ cloud_firestore (Timestamp変換)
  └─ core/utils/timestamp_converter.dart

repositories/:
  └─ cloud_firestore (データベースアクセス)

providers/:
  ├─ cloud_firestore
  └─ firebase_auth (認証状態)

presentation/pages/:
  ├─ flutter/material.dart
  ├─ go_router (ルーティング)
  └─ fl_chart (グラフ描画)
```

### プロジェクト内部依存

```
presentation/pages/
  ↓ 使用
providers/
  ↓ 使用
repositories/
  ↓ 使用
models/

相互参照:
  debate_event_provider.dart
    → debate_match_provider.dart (ユーザーマッチ確認用)

  core/providers/debate_event_unlock_provider.dart
    → feature/debate/providers/today_debate_event_provider.dart
    → feature/home/providers/daily_topic_provider.dart
    → feature/home/providers/opinion_provider.dart
```

### プロバイダー → リポジトリ → モデルの依存関係

```
debate_event_provider.dart
  ├─ debateEventRepositoryProvider
  │   └─ DebateEventRepository
  │       └─ models/debate_event.dart
  └─ debateMatchRepositoryProvider (マッチ確認用)

debate_match_provider.dart
  └─ debateMatchRepositoryProvider
      └─ DebateMatchRepository
          └─ models/debate_match.dart

debate_room_provider.dart
  └─ debateRoomRepositoryProvider
      └─ DebateRoomRepository
          ├─ models/debate_room.dart
          ├─ models/debate_message.dart
          └─ models/judgment_result.dart

user_debate_stats_provider.dart
  └─ userDebateStatsRepositoryProvider
      └─ UserDebateStatsRepository
          └─ models/user_debate_stats.dart
```

---

## 🚀 開発ガイド

### コード生成

ディベート機能のモデルはFreezedとjson_serializableを使用しているため、コード生成が必要です。

```bash
# モデル変更後に実行
flutter pub run build_runner build --delete-conflicting-outputs

# 監視モード（開発時）
flutter pub run build_runner watch
```

### 新しいモデル追加手順

1. `models/`配下に新しいFreezedクラスを作成
   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';

   part 'my_model.freezed.dart';
   part 'my_model.g.dart';

   @freezed
   class MyModel with _$MyModel {
     const factory MyModel({
       required String id,
       // ...
     }) = _MyModel;

     factory MyModel.fromJson(Map<String, dynamic> json)
       => _$MyModelFromJson(json);
   }
   ```

2. コード生成を実行
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. リポジトリにCRUDメソッドを追加

4. プロバイダーを作成

5. UIで使用

### 新しいプロバイダー追加手順

```dart
// 1. リポジトリプロバイダー（既存の場合はスキップ）
final myRepositoryProvider = Provider<MyRepository>((ref) {
  return MyRepository(firestore: FirebaseFirestore.instance);
});

// 2. データプロバイダー
final myDataProvider = StreamProvider.autoDispose.family<MyData?, String>(
  (ref, id) {
    final repository = ref.watch(myRepositoryProvider);
    return repository.watchData(id);
  },
);
```

### リアルタイム更新の実装

Firestoreのリアルタイムリスナーを使用する場合:

```dart
// Repository
Stream<MyData?> watchData(String id) {
  return _firestore
    .collection('my_collection')
    .doc(id)
    .snapshots()
    .map((snapshot) {
      if (!snapshot.exists) return null;
      return MyData.fromJson(snapshot.data()!);
    });
}

// Provider
final myDataProvider = StreamProvider.autoDispose.family<MyData?, String>(
  (ref, id) {
    final repository = ref.watch(myRepositoryProvider);
    return repository.watchData(id);
  },
);

// UI
final data = ref.watch(myDataProvider(id));
data.when(
  data: (myData) => Text(myData?.toString() ?? 'No data'),
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);
```

---

## 🔍 トラブルシューティング

### Freezedエラー

```bash
# エラー: Missing part directive
# 解決: ファイル先頭に part ディレクティブを追加
part 'my_model.freezed.dart';
part 'my_model.g.dart';

# エラー: Conflicting outputs
# 解決: --delete-conflicting-outputsオプションを使用
flutter pub run build_runner build --delete-conflicting-outputs
```

### Provider not found

```dart
// エラー: ProviderNotFoundException
// 原因: プロバイダーのインポート忘れ

// 解決: 適切にインポート
import '../providers/debate_event_provider.dart';
```

### Stream監視が更新されない

```dart
// 問題: Streamが更新されない
// 原因: autoDisposeの使用

// autoDisposeは画面を離れるとストリームを破棄する
// 必要に応じてautoDisposeを外す

final myProvider = StreamProvider.family<Data?, String>(
  (ref, id) => repository.watchData(id),
);
```

### Firestoreタイムスタンプエラー

```dart
// エラー: type 'Timestamp' is not a subtype of type 'DateTime'
// 解決: @TimestampConverter()アノテーションを追加

@freezed
class MyModel with _$MyModel {
  const factory MyModel({
    @TimestampConverter() required DateTime createdAt,
  }) = _MyModel;
}
```

---

## 📚 関連ドキュメント

### プロジェクト内ドキュメント
- [FIRESTORE_SCHEMA.md](./FIRESTORE_SCHEMA.md) - Firestoreスキーマ詳細
- [AI_JUDGMENT_IMPLEMENTATION.md](./AI_JUDGMENT_IMPLEMENTATION.md) - AI判定実装詳細
- [lib/core/README.md](../../core/README.md) - コア機能の説明

### プロジェクトメモリ
- `debate_feature_analysis` - ディベート機能の詳細分析
- `navigation_and_user_state` - ナビゲーション構造とユーザー状態管理

### 外部ドキュメント
- [Riverpod公式ドキュメント](https://riverpod.dev/)
- [Freezed公式ドキュメント](https://pub.dev/packages/freezed)
- [Cloud Firestore公式ドキュメント](https://firebase.google.com/docs/firestore)
- [Vertex AI Gemini API](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/gemini)

---

## 📝 コーディング規約

### Dartコーディングスタイル
- Effective Dartに準拠
- linterルールに従う（analysis_options.yaml参照）

### プロバイダー命名規則
- リポジトリプロバイダー: `xxxRepositoryProvider`
- データプロバイダー: `xxxProvider`
- Streamプロバイダー: データのリアルタイム監視
- FutureProvider: 一度だけのデータ取得

### ファイル命名規則
- モデル: `xxx_model.dart` または `xxx.dart`
- リポジトリ: `xxx_repository.dart`
- プロバイダー: `xxx_provider.dart`
- ページ: `xxx_page.dart`
- ウィジェット: `xxx_widget.dart`

### コメント規則
- 公開APIには必ずドキュメントコメント（///）を記述
- 複雑なロジックには実装コメント（//）を追加
- TODOコメントには担当者名と日付を記載

```dart
/// ユーザーのエントリー状態を監視するプロバイダー
///
/// パラメータとして(eventId, userId)のタプルを受け取り、
/// 該当するエントリーのリアルタイム状態を返す。
final userEntryProvider = StreamProvider.autoDispose.family<...>
```

---

## 🎯 今後の拡張予定

### Phase 1: バグフィックス・最適化
- [ ] MVP実名表示の実装
- [ ] フェーズ自動進行の実装
- [ ] メッセージレート制限の実装
- [ ] 判定後の統計自動更新

### Phase 2: 機能強化
- [ ] バッジ授与ロジックの完全実装
- [ ] ランキング自動更新
- [ ] エラーリトライロジック
- [ ] シェア機能の実装

### Phase 3: 高度な機能
- [ ] ディベート録画・再生
- [ ] リプレイ機能
- [ ] トーナメント機能
- [ ] カスタムトピック作成

---

**最終更新日**: 2025-12-05
**バージョン**: 2.0.0
**メンテナー**: Development Team

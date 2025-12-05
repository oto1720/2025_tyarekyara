# Statistics Feature（統計機能）

## 概要

Statistics機能は、ユーザーの行動や参加状況を可視化し、成長を促進するための統計・分析機能です。

以下の機能を提供します：

- **ユーザー統計**: 参加日数、投稿数、連続参加日数の追跡
- **多様性スコア**: 意見の多様性を数値化（0-100点）
- **立場分布**: 賛成・中立・反対の投稿比率の可視化
- **参加トレンド**: 週ごとの参加傾向をグラフで表示
- **バッジシステム**: 達成度に応じたバッジの授与

## ディレクトリ構造

```
lib/feature/statistics/
├── README.md                               # このファイル
├── models/                                 # データモデル（Freezed）
│   ├── user_statistics.dart                # ユーザー統計データ
│   ├── user_statistics.freezed.dart        # Freezed生成ファイル
│   ├── user_statistics.g.dart              # json_serializable生成ファイル
│   ├── diversity_score.dart                # 多様性スコア
│   ├── diversity_score.freezed.dart        # Freezed生成ファイル
│   ├── diversity_score.g.dart              # json_serializable生成ファイル
│   ├── stance_distribution.dart            # 立場分布
│   ├── stance_distribution.freezed.dart    # Freezed生成ファイル
│   ├── stance_distribution.g.dart          # json_serializable生成ファイル
│   ├── participation_trend.dart            # 参加トレンド
│   ├── participation_trend.freezed.dart    # Freezed生成ファイル
│   ├── participation_trend.g.dart          # json_serializable生成ファイル
│   ├── badge.dart                          # バッジモデル
│   ├── badge.freezed.dart                  # Freezed生成ファイル
│   ├── badge.g.dart                        # json_serializable生成ファイル
│   ├── earned_badge.dart                   # 獲得バッジ
│   ├── earned_badge.freezed.dart           # Freezed生成ファイル
│   ├── earned_badge.g.dart                 # json_serializable生成ファイル
│   └── badge_definition.dart               # バッジ定義（マスターデータ）
├── providers/                              # 状態管理（Riverpod）
│   ├── statistics_provider.dart            # 統計データプロバイダー
│   ├── statistics_state.dart               # 統計状態モデル
│   ├── statistics_state.freezed.dart       # Freezed生成ファイル
│   ├── badge_provider.dart                 # バッジプロバイダー
│   ├── badge_state.dart                    # バッジ状態モデル
│   └── badge_state.freezed.dart            # Freezed生成ファイル
├── repositories/                           # データアクセス層
│   ├── statistics_repository.dart          # リポジトリインターフェース
│   ├── local_statistics_repository.dart    # ローカルストレージ実装
│   ├── firestore_statistics_repository.dart # Firestore実装
│   ├── statistics_repositories.dart        # リポジトリエントリーポイント
│   ├── badge_repository.dart               # バッジリポジトリインターフェース
│   └── badge_repository_impl.dart          # バッジリポジトリ実装
├── services/                               # ビジネスロジック層
│   ├── statistics_service.dart             # 統計サービス（未実装）
│   └── badge_service.dart                  # バッジサービス
└── presentation/                           # UI層
    ├── pages/
    │   ├── statistic.dart                  # 統計画面メインページ
    │   └── badge_list_screen.dart          # バッジ一覧画面
    └── widgets/                            # UIコンポーネント
        ├── thinking_profile_card.dart      # プロフィールカード
        ├── diversity_score_card.dart       # 多様性スコアカード
        ├── stance_distribution_card.dart   # 立場分布カード
        ├── participation_trend_card.dart   # 参加トレンドカード
        ├── earned_badges_card.dart         # 獲得バッジカード
        ├── participation_stats_card.dart   # 参加統計カード
        ├── stance_pie_chart.dart           # 立場分布円グラフ
        └── trend_line_chart.dart           # トレンド折れ線グラフ
```

## アーキテクチャ

### レイヤー構成

```
┌─────────────────────────────────────────┐
│  Presentation Layer (UI)                │
│  - pages/: 画面                          │
│  - widgets/: 再利用可能なUIコンポーネント  │
└──────────────┬──────────────────────────┘
               │ 参照
┌──────────────▼──────────────────────────┐
│  Provider Layer (状態管理)               │
│  - statistics_provider.dart             │
│  - badge_provider.dart                  │
│  - StatisticsNotifier                   │
│  - BadgeNotifier                        │
└──────────────┬──────────────────────────┘
               │ 使用
┌──────────────▼──────────────────────────┐
│  Repository Layer (データアクセス)        │
│  - FirestoreStatisticsRepository        │
│  - LocalStatisticsRepository            │
│  - BadgeRepository                      │
└──────────────┬──────────────────────────┘
               │ アクセス
┌──────────────▼──────────────────────────┐
│  Data Layer                             │
│  - Firestore (opinions)                 │
│  - SharedPreferences (ローカルキャッシュ) │
│  - ChallengeRepository (challenge)      │
└─────────────────────────────────────────┘
```

### 依存関係グラフ

```
[Presentation Layer]
  statistic.dart ─────────┐
  badge_list_screen.dart ─┼────> statisticsNotifierProvider
                          └────> badgeNotifierProvider
           │
           ▼
  thinking_profile_card.dart
  diversity_score_card.dart
  stance_distribution_card.dart
  participation_trend_card.dart
  earned_badges_card.dart
  participation_stats_card.dart
  stance_pie_chart.dart
  trend_line_chart.dart

[Provider Layer]
  statisticsNotifierProvider ────> StatisticsNotifier
      │                                 │
      │                                 ├──> FirestoreStatisticsRepository
      │                                 │         │
      │                                 │         └──> Firestore (opinions)
      │                                 │
      │                                 ├──> LocalStatisticsRepository
      │                                 │         │
      │                                 │         └──> SharedPreferences
      │                                 │
      │                                 └──> ChallengeRepository
      │                                           │
      │                                           └──> Firestore (userChallenges)
      │
  badgeNotifierProvider ────────> BadgeNotifier

[External Dependencies]
  - feature/challenge: チャレンジ統計の取得
  - feature/auth: ユーザー認証状態の取得
  - feature/guide: チュートリアル機能
```

## 主要なクラスとその役割

### 1. Models (データモデル)

#### UserStatistics (`lib/feature/statistics/models/user_statistics.dart`)

**責務**: ユーザーの基本統計データを表すイミュータブルなモデル

**使用技術**: Freezed + json_serializable

**主要フィールド**:

```dart
@freezed
class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    required String userId,           // ユーザーID
    required int participationDays,   // 参加日数（ユニークな日数）
    required int totalOpinions,       // 総投稿数
    required int consecutiveDays,     // 連続参加日数
    required DateTime lastParticipation, // 最終参加日時
    required DateTime createdAt,      // 作成日時
    required DateTime updatedAt,      // 更新日時
  }) = _UserStatistics;

  factory UserStatistics.fromJson(Map&lt;String, dynamic&gt; json)
    => _$UserStatisticsFromJson(json);
}
```

**使用箇所**:
- `FirestoreStatisticsRepository`: Firestoreのopinionsコレクションから集計
- `LocalStatisticsRepository`: SharedPreferencesへの保存・読み込み
- `statistics_provider.dart`: 状態管理

---

#### DiversityScore (`lib/feature/statistics/models/diversity_score.dart`)

**責務**: ユーザーの意見の多様性を数値化したスコア

**使用技術**: Freezed + json_serializable

**主要フィールド**:

```dart
@freezed
class DiversityScore with _$DiversityScore {
  const factory DiversityScore({
    required String userId,              // ユーザーID
    required double score,               // 多様性スコア（0-100）
    required Map&lt;String, double&gt; breakdown, // スコアの内訳
    required DateTime createdAt,         // 作成日時
    required DateTime updatedAt,         // 更新日時
  }) = _DiversityScore;

  factory DiversityScore.fromJson(Map&lt;String, dynamic&gt; json)
    => _$DiversityScoreFromJson(json);
}
```

**スコア計算方法**:

```dart
// エントロピーベースの計算
// 賛成・中立・反対の分布が均等なほど高スコア
double entropy = 0;
for (final ratio in [agreeRatio, disagreeRatio, neutralRatio]) {
  if (ratio > 0) {
    entropy -= ratio * (ratio * 3.32193); // log2(x) approximation
  }
}
final diversityScore = (entropy / 1.585) * 100; // 正規化（log2(3) = 1.585）
```

**breakdown の例**:
```dart
{
  '議論の幅': 40.0,
  '情報源の多様性': 38.0,
}
```

---

#### StanceDistribution (`lib/feature/statistics/models/stance_distribution.dart`)

**責務**: ユーザーの立場別投稿数の分布

**使用技術**: Freezed + json_serializable

**主要フィールド**:

```dart
@freezed
class StanceDistribution with _$StanceDistribution {
  const factory StanceDistribution({
    required String userId,           // ユーザーID
    required Map&lt;String, int&gt; counts,   // 立場ごとのカウント
    required int total,               // 総数
    required DateTime createdAt,      // 作成日時
    required DateTime updatedAt,      // 更新日時
  }) = _StanceDistribution;

  factory StanceDistribution.fromJson(Map&lt;String, dynamic&gt; json)
    => _$StanceDistributionFromJson(json);
}
```

**counts の形式**:
```dart
{
  '賛成': 16,
  '中立': 8,
  '反対': 12,
}
```

**Firestoreからのマッピング**:
```dart
// OpinionStance enum値を日本語に変換
'agree'    -> '賛成'
'neutral'  -> '中立'
'disagree' -> '反対'
```

---

#### ParticipationTrend (`lib/feature/statistics/models/participation_trend.dart`)

**責務**: 時系列の参加傾向データ

**使用技術**: Freezed + json_serializable

**主要フィールド**:

```dart
@freezed
class ParticipationPoint with _$ParticipationPoint {
  const factory ParticipationPoint({
    required DateTime date,    // 日付（週の開始日）
    required int count,        // その週の投稿数
  }) = _ParticipationPoint;

  factory ParticipationPoint.fromJson(Map&lt;String, dynamic&gt; json)
    => _$ParticipationPointFromJson(json);
}

@freezed
class ParticipationTrend with _$ParticipationTrend {
  const factory ParticipationTrend({
    required String userId,                // ユーザーID
    required List&lt;ParticipationPoint&gt; points, // データポイント
    required DateTime createdAt,           // 作成日時
    required DateTime updatedAt,           // 更新日時
  }) = _ParticipationTrend;

  factory ParticipationTrend.fromJson(Map&lt;String, dynamic&gt; json)
    => _$ParticipationTrendFromJson(json);
}
```

**データ期間**: 選択された年月の全週（月曜始まり）

**使用箇所**:
- `trend_line_chart.dart`: 折れ線グラフでの可視化

---

#### Badge (`lib/feature/statistics/models/badge.dart`)

**責務**: バッジの詳細情報

**使用技術**: Freezed + json_serializable

**主要フィールド**:

```dart
@freezed
class Badge with _$Badge {
  const factory Badge({
    required String id,                      // バッジID
    required String name,                    // バッジ名
    String? description,                     // 説明
    String? iconUrl,                         // アイコンURL
    DateTime? earnedAt,                      // 獲得日時
    required DateTime createdAt,             // 作成日時
    required DateTime updatedAt,             // 更新日時
    Map&lt;String, dynamic&gt;? criteria,          // 獲得条件
    String? awardedBy,                       // 授与者
  }) = _Badge;

  factory Badge.fromJson(Map&lt;String, dynamic&gt; json) => _$BadgeFromJson(json);
}
```

---

#### BadgeDefinition (`lib/feature/statistics/models/badge_definition.dart`)

**責務**: バッジのマスターデータ定義（静的データ）

**使用技術**: 通常のDartクラス（Freezed不使用）

**主要フィールド**:

```dart
class BadgeDefinition {
  final String id;          // バッジID
  final String name;        // バッジ名
  final String description; // 説明
  final IconData icon;      // アイコン
  final Color color;        // 色

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}
```

**定義されているバッジ**:

| ID | 名前 | 説明 | 条件 |
|----|------|------|------|
| `first_post` | 初投稿 | 初めて意見を投稿しました | totalOpinions >= 1 |
| `ten_posts` | 10投稿達成 | 10回意見を投稿しました | totalOpinions >= 10 |
| `fifty_posts` | 50投稿達成 | 50回意見を投稿しました | totalOpinions >= 50 |
| `hundred_posts` | 100投稿達成 | 100回意見を投稿しました | totalOpinions >= 100 |
| `seven_days_streak` | 7日連続参加 | 7日連続で参加しました | consecutiveDays >= 7 |
| `thirty_days_streak` | 30日連続参加 | 30日連続で参加しました | consecutiveDays >= 30 |
| `thirty_days_total` | 30日間参加 | 累計30日間参加しました | participationDays >= 30 |
| `hundred_days_total` | 100日間参加 | 累計100日間参加しました | participationDays >= 100 |
| `diverse_thinker` | 多様な思考 | 多様性スコアが80以上 | diversityScore >= 80 |
| `balanced_opinions` | バランス型 | 賛成・中立・反対すべてに投稿 | 全立場に投稿あり |
| `first_challenge` | 視点交換入門 | 初めてチャレンジをクリア | completedChallenges >= 1 |
| `challenge_enthusiast` | チャレンジ好き | 5回チャレンジをクリア | completedChallenges >= 5 |
| `challenge_expert` | チャレンジ達人 | 10回チャレンジをクリア | completedChallenges >= 10 |
| `challenge_master` | チャレンジマスター | 累計獲得ポイント500P達成 | totalChallengePoints >= 500 |

**使用箇所**:
- `BadgeDefinitions.getById(id)`: バッジIDから定義を取得
- `earned_badges_card.dart`: バッジ表示

---

### 2. Providers (状態管理)

#### StatisticsNotifier & statisticsNotifierProvider

**場所**: `lib/feature/statistics/providers/statistics_provider.dart`

**責務**: 統計データのメイン状態管理クラス

**クラス構造**:

```dart
class StatisticsNotifier extends Notifier&lt;StatisticsState&gt; {
  @override
  StatisticsState build() {
    final now = DateTime.now();
    return StatisticsState(
      selectedYear: now.year,
      selectedMonth: now.month,
    );
  }

  // 表示月変更
  void changeMonth(int year, int month);
  void goToPreviousMonth();
  void goToNextMonth();

  // 統計データ読み込み
  Future&lt;void&gt; loadUserStatistics(String userId);
}

final statisticsNotifierProvider =
  NotifierProvider&lt;StatisticsNotifier, StatisticsState&gt;(() {
    return StatisticsNotifier();
  });
```

**StatisticsState**:

```dart
@freezed
class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    UserStatistics? userStatistics,
    DiversityScore? diversityScore,
    StanceDistribution? stanceDistribution,
    ParticipationTrend? participationTrend,
    @Default([]) List&lt;Badge&gt; earnedBadges,
    @Default(false) bool isLoading,
    String? error,
    int? selectedYear,
    int? selectedMonth,
  }) = _StatisticsState;
}
```

**主要メソッド詳細**:

##### `loadUserStatistics(String userId)`

統計データの取得とバッジ判定を行う中核メソッド

**処理フロー**:

```
1. ゲストモード判定
   ├─ ゲストモード → モックデータを生成して返却
   └─ 通常モード → 以下の処理を継続

2. Firestoreからデータ取得
   ├─ FirestoreStatisticsRepository.fetchUserStatistics()
   │   └─> opinionsコレクションから集計
   ├─ FirestoreStatisticsRepository.fetchDiversityScore()
   │   └─> 立場分布からエントロピー計算
   ├─ FirestoreStatisticsRepository.fetchStanceDistribution()
   │   └─> 立場ごとのカウント
   └─ FirestoreStatisticsRepository.fetchParticipationTrend()
       └─> 週ごとの参加数

3. チャレンジ統計取得（feature/challengeへの依存）
   ├─ ChallengeRepository.getCompletedChallengeCount(userId)
   └─ ChallengeRepository.getTotalEarnedPoints(userId)

4. ローカルキャッシュ保存
   └─> LocalStatisticsRepository.saveAll()

5. バッジ判定ロジック実行
   ├─ 投稿数系バッジ（1, 10, 50, 100投稿）
   ├─ 連続参加系バッジ（7日, 30日連続）
   ├─ 累計参加系バッジ（30日, 100日）
   ├─ 多様性系バッジ（スコア80以上, バランス型）
   └─ チャレンジ系バッジ（1, 5, 10回, 500P）

6. 状態更新
   └─> state.copyWith(...)

エラー時:
  ├─ LocalStatisticsRepository からキャッシュ読み込み
  └─ キャッシュなし → ダミーデータ生成＆保存
```

**バッジ判定例**:

```dart
// 投稿数系
if (u.totalOpinions >= 1) {
  badges.add(Badge(
    id: 'first_post',
    name: '初投稿',
    description: '初めて意見を投稿しました',
    createdAt: now,
    updatedAt: now,
    earnedAt: now,
  ));
}

// 多様性系
if (d != null && d.score >= 80) {
  badges.add(Badge(
    id: 'diverse_thinker',
    name: '多様な思考',
    description: '多様性スコアが80以上になりました',
    createdAt: now,
    updatedAt: now,
    earnedAt: now,
  ));
}

// バランス型（全立場に投稿あり）
if (s != null &&
    s.counts['賛成']! > 0 &&
    s.counts['中立']! > 0 &&
    s.counts['反対']! > 0) {
  badges.add(Badge(
    id: 'balanced_opinions',
    name: 'バランス型',
    description: '賛成・中立・反対すべてに投稿しました',
    createdAt: now,
    updatedAt: now,
    earnedAt: now,
  ));
}

// チャレンジ系
if (completedChallengeCount >= 5) {
  badges.add(Badge(
    id: 'challenge_enthusiast',
    name: 'チャレンジ好き',
    description: '5回チャレンジをクリアしました',
    createdAt: now,
    updatedAt: now,
    earnedAt: now,
  ));
}
```

**使用箇所**:
- `statistic.dart`: 画面表示時にデータ読み込み
- 各種カードウィジェット: 状態の監視と表示

---

#### BadgeNotifier & badgeNotifierProvider

**場所**: `lib/feature/statistics/providers/badge_provider.dart`

**責務**: バッジデータの状態管理（現在は簡易実装）

**クラス構造**:

```dart
class BadgeNotifier extends Notifier&lt;BadgeState&gt; {
  @override
  BadgeState build() {
    return const BadgeState();
  }

  Future&lt;void&gt; loadEarnedBadges(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final badgeNotifierProvider = NotifierProvider&lt;BadgeNotifier, BadgeState&gt;(() {
  return BadgeNotifier();
});
```

**注意**: 現在は`StatisticsNotifier`がバッジ判定を行っており、`BadgeNotifier`は将来の拡張用

---

### 3. Repository Layer (データアクセス)

#### StatisticsRepository (`lib/feature/statistics/repositories/statistics_repository.dart`)

**責務**: リポジトリの抽象インターフェース

**メソッド定義**:

```dart
abstract class StatisticsRepository {
  Future&lt;UserStatistics&gt; fetchUserStatistics(String userId);
  Future&lt;DiversityScore?&gt; fetchDiversityScore(String userId);
  Future&lt;StanceDistribution?&gt; fetchStanceDistribution(String userId);
  Future&lt;ParticipationTrend?&gt; fetchParticipationTrend(
    String userId,
    {required int year, required int month}
  );
}
```

---

#### LocalStatisticsRepository (`lib/feature/statistics/repositories/local_statistics_repository.dart`)

**責務**: SharedPreferencesを使ったローカルストレージ実装

**依存関係**:
- `shared_preferences`: ローカルストレージ

**保存キー命名規則**:

```dart
static String _userKey(String userId) => 'statistics:user:$userId';
static String _diversityKey(String userId) => 'statistics:diversity:$userId';
static String _stanceKey(String userId) => 'statistics:stance:$userId';
static String _trendKey(String userId) => 'statistics:trend:$userId';
```

**主要メソッド**:

```dart
class LocalStatisticsRepository {
  // 読み込み
  Future&lt;UserStatistics?&gt; fetchUserStatistics(String userId);
  Future&lt;DiversityScore?&gt; fetchDiversityScore(String userId);
  Future&lt;StanceDistribution?&gt; fetchStanceDistribution(String userId);
  Future&lt;ParticipationTrend?&gt; fetchParticipationTrend(
    String userId, {required int year, required int month}
  );

  // 保存
  Future&lt;void&gt; saveUserStatistics(UserStatistics stats);
  Future&lt;void&gt; saveDiversityScore(DiversityScore score);
  Future&lt;void&gt; saveStanceDistribution(StanceDistribution stance);
  Future&lt;void&gt; saveParticipationTrend(ParticipationTrend trend);

  // 一括保存
  Future&lt;void&gt; saveAll({
    required UserStatistics userStatistics,
    required DiversityScore diversityScore,
    required StanceDistribution stanceDistribution,
    required ParticipationTrend participationTrend,
  });
}
```

**保存形式**:

```dart
// モデル -> JSON -> 文字列
await prefs.setString(
  _userKey(userId),
  jsonEncode(userStatistics.toJson())
);

// 文字列 -> JSON -> モデル
final jsonString = prefs.getString(_userKey(userId));
if (jsonString != null) {
  final map = jsonDecode(jsonString) as Map&lt;String, dynamic&gt;;
  return UserStatistics.fromJson(map);
}
```

**エラーハンドリング**:
- JSONパース失敗時は`null`を返却（例外を握り潰す）
- 存在しないキーの読み込みは`null`を返却

**使用箇所**:
- `statistics_provider.dart`: Firestore取得後のキャッシュ、エラー時のフォールバック

---

#### FirestoreStatisticsRepository (`lib/feature/statistics/repositories/firestore_statistics_repository.dart`)

**責務**: Firestoreからの統計データ取得と集計

**依存関係**:
- `cloud_firestore`: Firebaseデータベース

**主要メソッド詳細**:

##### 1. `fetchUserStatistics(String userId)`

**処理内容**:

```dart
1. opinionsコレクションをクエリ
   WHERE userId == userId

2. 投稿数を集計
   totalOpinions = opinions.length

3. 参加日数を計算（ユニークな日付の数）
   - 各投稿のcreatedAtから日付のみを抽出
   - Setで重複を除去
   participationDays = uniqueDates.length

4. 最終参加日を取得
   lastParticipation = max(createdAt)

5. 連続参加日数を計算（_calculateConsecutiveDays）
   - 今日から過去に向かって連続している日数をカウント
   consecutiveDays = count

6. UserStatisticsを返却
```

**連続参加日数計算ロジック**:

```dart
int _calculateConsecutiveDays(List&lt;QueryDocumentSnapshot&gt; opinions) {
  // 日付のみのセットを作成
  final dates = &lt;DateTime&gt;{};
  for (final doc in opinions) {
    final createdAt = doc['createdAt'].toDate();
    final dateOnly = DateTime(createdAt.year, createdAt.month, createdAt.day);
    dates.add(dateOnly);
  }

  // 日付を降順ソート
  final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));

  // 今日から連続している日数をカウント
  int consecutive = 0;
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  for (int i = 0; i < sortedDates.length; i++) {
    final expectedDate = todayDate.subtract(Duration(days: i));
    if (sortedDates[i].isAtSameMomentAs(expectedDate)) {
      consecutive++;
    } else {
      break; // 連続が途切れた
    }
  }

  return consecutive;
}
```

---

##### 2. `fetchDiversityScore(String userId)`

**処理内容**:

```dart
1. opinionsコレクションをクエリ
   WHERE userId == userId

2. 立場別のカウント
   stanceCounts = {
     'agree': 0,
     'disagree': 0,
     'neutral': 0,
   }

3. 各立場の比率を計算
   agreeRatio = agree / total
   disagreeRatio = disagree / total
   neutralRatio = neutral / total

4. エントロピーベースのスコア計算
   entropy = 0
   for ratio in [agreeRatio, disagreeRatio, neutralRatio]:
     if ratio > 0:
       entropy -= ratio * (ratio * 3.32193)  // log2(x) approximation

   diversityScore = (entropy / 1.585) * 100  // 正規化（log2(3) = 1.585）

5. breakdownを作成
   breakdown = {
     '議論の幅': diversityScore * 0.6,
     '情報源の多様性': diversityScore * 0.4,
   }

6. DiversityScoreを返却（0-100にクランプ）
```

**スコアの意味**:
- 100点: 賛成・中立・反対が完全に均等（33.3%, 33.3%, 33.3%）
- 0点: すべて同じ立場（100%, 0%, 0%）

---

##### 3. `fetchStanceDistribution(String userId)`

**処理内容**:

```dart
1. opinionsコレクションをクエリ
   WHERE userId == userId

2. 立場別のカウント（日本語表記）
   stanceCounts = {
     '賛成': 0,   // 'agree'
     '中立': 0,   // 'neutral'
     '反対': 0,   // 'disagree'
   }

3. OpinionStance enum値を日本語に変換
   'agree'    -> '賛成'
   'neutral'  -> '中立'
   'disagree' -> '反対'

4. StanceDistributionを返却
```

---

##### 4. `fetchParticipationTrend(String userId, {required int year, required int month})`

**処理内容**:

```dart
1. 指定月の範囲を計算
   firstDayOfMonth = DateTime(year, month, 1)
   lastDayOfMonth = DateTime(year, month + 1, 0)

2. opinionsコレクションをクエリ
   WHERE userId == userId

3. 週ごとにカウント（月曜始まり）
   for opinion in opinions:
     if opinion.createdAt in [firstDay, lastDay]:
       週の開始日（月曜）を計算
       countsByWeekStart[weekStart]++

4. 月の全週のポイントを作成
   currentWeekStart = 月の最初の週の月曜日
   while currentWeekStart <= lastDayOfMonth:
     points.add(ParticipationPoint(
       date: weekStartDate,
       count: countsByWeekStart[weekStartDate] ?? 0,
     ))
     currentWeekStart += 7日

5. ParticipationTrendを返却
```

**週の開始日計算**:

```dart
// その日が属する週の月曜日を計算
final daysSinceMonday = (createdAt.weekday - 1) % 7;
final weekStart = createdAt.subtract(Duration(days: daysSinceMonday));
final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
```

---

### 4. Presentation Layer (UI)

#### StatisticPage (`lib/feature/statistics/presentation/pages/statistic.dart`)

**責務**: 統計画面のメインページ

**主要機能**:
- ゲストモード判定とモックデータ表示
- ユーザー統計データの読み込み
- 各種カードの表示
- チュートリアルガイド表示

**構造**:

```dart
StatisticPage (ConsumerStatefulWidget)
  ↓
ShowCaseWidget (チュートリアル用)
  ↓
TutorialShowcaseWrapper
  ↓
FutureBuilder&lt;bool&gt; (ゲストモード判定)
  ↓
Scaffold
  ├─ AppBar
  │   ├─ タイトル: '統計'
  │   └─ アクション: ヘルプボタン (Showcase)
  └─ Body
      ├─ ローディング表示 (isLoading && userStatistics == null)
      └─ スクロール可能なコンテンツ
          ├─ ThinkingProfileCard      // プロフィールカード
          ├─ ParticipationStatsCard   // 参加統計カード
          ├─ DiversityScoreCard       // 多様性スコアカード
          ├─ StanceDistributionCard   // 立場分布カード
          ├─ ParticipationTrendCard   // 参加トレンドカード
          └─ EarnedBadgesCard         // 獲得バッジカード
```

**データ読み込みフロー**:

```dart
// ゲストモード
if (isGuest) {
  ref.read(statisticsNotifierProvider.notifier)
    .loadUserStatistics('guest');
  // -> モックデータが生成される
}

// 通常モード
else {
  final userId = authState.user?.uid;
  if (userId != null && _loadedUserId != userId) {
    _loadedUserId = userId;
    ref.read(statisticsNotifierProvider.notifier)
      .loadUserStatistics(userId);
  }
}
```

**使用プロバイダー**:
- `statisticsNotifierProvider`: 統計データ
- `authProvider`: ユーザー認証状態

---

#### 主要ウィジェット

##### ThinkingProfileCard

**責務**: ユーザープロフィールの概要表示

**表示内容**:
- ユーザー名
- 参加日数
- 総投稿数

---

##### ParticipationStatsCard

**責務**: 参加統計の詳細表示

**表示内容**:
- 累計参加日数
- 連続参加日数
- 総投稿数
- 最終参加日時

---

##### DiversityScoreCard

**責務**: 多様性スコアの表示

**表示内容**:
- スコア（0-100）
- 円形プログレスインジケーター
- スコアの内訳（breakdown）
- スコアに応じたメッセージ

**スコア評価**:
```dart
if (score >= 80) '素晴らしい！'
else if (score >= 60) '良い多様性'
else if (score >= 40) '改善の余地あり'
else '多様性を高めましょう'
```

---

##### StanceDistributionCard

**責務**: 立場分布の可視化

**表示内容**:
- 円グラフ（StancePieChart）
- 各立場の割合
- 総投稿数

**使用ライブラリ**: `fl_chart`

---

##### ParticipationTrendCard

**責務**: 参加トレンドのグラフ表示

**表示内容**:
- 月選択UI（前月・次月ボタン）
- 折れ線グラフ（TrendLineChart）
- 週ごとの投稿数

**使用ライブラリ**: `fl_chart`

**月変更処理**:

```dart
// 前月へ
onPressed: () {
  ref.read(statisticsNotifierProvider.notifier)
    .goToPreviousMonth();

  // データ再読み込み
  ref.read(statisticsNotifierProvider.notifier)
    .loadUserStatistics(userId);
}

// 次月へ
onPressed: () {
  ref.read(statisticsNotifierProvider.notifier)
    .goToNextMonth();

  ref.read(statisticsNotifierProvider.notifier)
    .loadUserStatistics(userId);
}
```

---

##### EarnedBadgesCard

**責務**: 獲得バッジの一覧表示

**表示内容**:
- 獲得済みバッジのグリッド表示
- バッジ詳細画面への遷移

**バッジ表示**:

```dart
for (final badge in earnedBadges) {
  final definition = BadgeDefinitions.getById(badge.id);
  // アイコン、色、名前を表示
  Icon(definition.icon, color: definition.color);
  Text(definition.name);
}
```

**タップ時**: `badge_list_screen.dart` へ遷移

---

## データフロー詳細

### 1. アプリ起動時のデータ読み込み

```
[User]
  ↓ 統計画面を表示
[StatisticPage] (build)
  ↓ FutureBuilder(ゲストモード判定)
SharedPreferences.getBool('is_guest_mode')
  ↓
[ゲストモード] OR [通常モード]

===== ゲストモードの場合 =====
[StatisticsNotifier.loadUserStatistics('guest')]
  ↓
モックデータ生成
  ├─ UserStatistics (participationDays: 10, totalOpinions: 42, ...)
  ├─ DiversityScore (score: 78.0, ...)
  ├─ StanceDistribution (賛成: 16, 中立: 8, 反対: 12)
  ├─ ParticipationTrend (過去7日分のダミーデータ)
  └─ Badges (初投稿, 7日連続参加)
  ↓
state更新
  ↓
[UI] 反映

===== 通常モードの場合 =====
[StatisticsNotifier.loadUserStatistics(userId)]
  ↓
[FirestoreStatisticsRepository]
  ├─> fetchUserStatistics(userId)
  │     ↓ Firestore.collection('opinions').where('userId', isEqualTo: userId)
  │     ↓ 集計処理
  │     └─> UserStatistics
  │
  ├─> fetchDiversityScore(userId)
  │     ↓ opinions から立場分布を取得
  │     ↓ エントロピー計算
  │     └─> DiversityScore
  │
  ├─> fetchStanceDistribution(userId)
  │     ↓ opinions から立場ごとにカウント
  │     └─> StanceDistribution
  │
  └─> fetchParticipationTrend(userId, year, month)
        ↓ opinions から週ごとにカウント
        └─> ParticipationTrend

[ChallengeRepository] (feature/challenge)
  ├─> getCompletedChallengeCount(userId)
  │     └─> completedChallenges
  └─> getTotalEarnedPoints(userId)
        └─> totalChallengePoints

[LocalStatisticsRepository]
  └─> saveAll(userStatistics, diversityScore, stanceDistribution, participationTrend)
        ↓ SharedPreferencesに保存（キャッシュ）

[バッジ判定ロジック]
  ├─ 投稿数系（1, 10, 50, 100投稿）
  ├─ 連続参加系（7日, 30日）
  ├─ 累計参加系（30日, 100日）
  ├─ 多様性系（スコア80以上, バランス型）
  └─ チャレンジ系（1, 5, 10回, 500P）
  ↓
List&lt;Badge&gt; earnedBadges

[StatisticsState] 更新
  ↓
[UI] 反映
  ├─ ThinkingProfileCard
  ├─ ParticipationStatsCard
  ├─ DiversityScoreCard
  ├─ StanceDistributionCard
  ├─ ParticipationTrendCard
  └─ EarnedBadgesCard

===== エラー時のフォールバック =====
[StatisticsNotifier] catch (e)
  ↓
[LocalStatisticsRepository]
  ├─> fetchUserStatistics(userId)
  ├─> fetchDiversityScore(userId)
  ├─> fetchStanceDistribution(userId)
  └─> fetchParticipationTrend(userId, year, month)
  ↓
キャッシュデータがある → 使用
キャッシュデータがない → ダミーデータ生成＆保存
  ↓
[StatisticsState] 更新
  ↓
[UI] 反映
```

---

### 2. 月変更時のデータフロー

```
[User]
  ↓ 前月/次月ボタンをタップ
[ParticipationTrendCard]
  ↓ onPressed
[StatisticsNotifier.goToPreviousMonth()] OR [goToNextMonth()]
  ↓ 月計算
state.copyWith(selectedYear: newYear, selectedMonth: newMonth)
  ↓
[StatisticsNotifier.loadUserStatistics(userId)]
  ↓ selectedYear, selectedMonthを使用
[FirestoreStatisticsRepository.fetchParticipationTrend(
  userId,
  year: selectedYear,
  month: selectedMonth
)]
  ↓ 指定月のデータを集計
ParticipationTrend (新しい月のデータ)
  ↓
state.copyWith(participationTrend: newTrend)
  ↓
[TrendLineChart] 再描画
```

---

### 3. バッジ獲得のトリガー

```
[User]
  ↓ ホーム画面で意見を投稿
[OpinionRepository.createOpinion()]
  ↓ Firestore: opinionsコレクションに保存

[User]
  ↓ 統計画面を開く
[StatisticPage]
  ↓
[StatisticsNotifier.loadUserStatistics(userId)]
  ↓ opinionsを集計
totalOpinions, participationDays, consecutiveDays を更新
  ↓ バッジ判定
if (totalOpinions >= 10) {
  badges.add('ten_posts')
}
if (consecutiveDays >= 7) {
  badges.add('seven_days_streak')
}
  ↓
[EarnedBadgesCard] 新しいバッジを表示
```

**注意**: 現在の実装では、統計画面を開いた時にバッジ判定が行われます。将来的には、投稿時やバックグラウンドでの自動判定を検討する必要があります。

---

## 他のFeatureとの連携

### 1. Challenge Feature との連携

**依存関係**:

```
StatisticsNotifier
  └─> ChallengeRepository (lib/feature/challenge/repositories/challenge_repositories.dart)
        ├─> getCompletedChallengeCount(userId)
        │     → 完了済みチャレンジ数を取得
        └─> getTotalEarnedPoints(userId)
              → 累計獲得ポイントを取得
```

**連携フロー**:

```
[統計画面での表示]
1. StatisticPage表示
2. statisticsNotifier.loadUserStatistics(userId)
3. ChallengeRepository.getCompletedChallengeCount(userId)
   → Firestore: userChallengesコレクション
   → WHERE userId == userId AND status == 'completed'
   → count
4. ChallengeRepository.getTotalEarnedPoints(userId)
   → Firestore: userChallengesコレクション
   → WHERE userId == userId
   → SUM(earnedPoints)
5. バッジ判定
   - completedChallengeCount >= 1  → 'first_challenge'
   - completedChallengeCount >= 5  → 'challenge_enthusiast'
   - completedChallengeCount >= 10 → 'challenge_expert'
   - totalChallengePoints >= 500   → 'challenge_master'
6. EarnedBadgesCardで表示
```

**使用しているバッジ**:
- 視点交換入門 (`first_challenge`)
- チャレンジ好き (`challenge_enthusiast`)
- チャレンジ達人 (`challenge_expert`)
- チャレンジマスター (`challenge_master`)

---

### 2. Home Feature との連携

**依存関係**:

```
FirestoreStatisticsRepository
  └─> Firestore: opinionsコレクション
        └─> ホーム画面で投稿された意見を集計
```

**連携フロー**:

```
[投稿→統計反映]
1. ユーザーがホーム画面で意見を投稿
2. OpinionRepository.createOpinion()
   → Firestore: opinionsコレクションに保存
   {
     userId: 'user123',
     stance: 'agree',
     text: '...',
     createdAt: Timestamp,
     ...
   }

3. ユーザーが統計画面を開く
4. FirestoreStatisticsRepository.fetchUserStatistics(userId)
   → WHERE userId == 'user123'
   → 投稿数集計
   → 参加日数計算
   → 連続日数計算

5. FirestoreStatisticsRepository.fetchStanceDistribution(userId)
   → stance別にカウント
   → '賛成': count('agree')
   → '中立': count('neutral')
   → '反対': count('disagree')

6. FirestoreStatisticsRepository.fetchDiversityScore(userId)
   → 立場分布からエントロピー計算
   → スコア生成

7. 統計画面に反映
```

**データマッピング**:

| Opinion (home) | Statistics |
|----------------|------------|
| userId | userId |
| stance: 'agree' | counts['賛成']++ |
| stance: 'neutral' | counts['中立']++ |
| stance: 'disagree' | counts['反対']++ |
| createdAt | participationDays, lastParticipation |

---

### 3. Auth Feature との連携

**依存関係**:

```
StatisticPage
  └─> authProvider (lib/feature/auth/providers/auth_provider.dart)
        └─> 現在のユーザーIDを取得
```

**連携フロー**:

```
[ユーザー認証状態の確認]
1. StatisticPage.build()
2. ref.watch(authProvider)
3. authState.user?.uid
4. if (userId != null) {
     statisticsNotifier.loadUserStatistics(userId);
   }

[ゲストモード判定]
1. SharedPreferences.getBool('is_guest_mode')
2. if (isGuest) {
     statisticsNotifier.loadUserStatistics('guest');
     // -> モックデータ使用
   }
```

---

### 4. Guide Feature との連携

**依存関係**:

```
StatisticPage
  ├─> TutorialShowcaseWrapper (lib/feature/guide/presentaion/widgets/tutorial_showcase_wrapper.dart)
  └─> TutorialBottomSheet (lib/feature/guide/presentaion/widgets/tutorial_dialog.dart)
```

**連携フロー**:

```
[チュートリアル表示]
1. StatisticPage初回表示
2. TutorialShowcaseWrapper(pageKey: 'statistics')
   → 初回かどうかを判定
3. 初回の場合 → ShowCaseを表示
   - ヘルプボタンのハイライト
   - 説明テキスト: '操作ガイド'

[ヘルプボタンタップ]
1. IconButton(onPressed)
2. TutorialBottomSheet.show(context, 'statistics')
   → ボトムシートでガイドを表示
```

---

## 使用方法とコード例

### 1. 統計データの読み込み

```dart
// ページ表示時に自動読み込み
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(statisticsNotifierProvider);

  // ユーザーIDを取得
  final authState = ref.watch(authProvider);
  final userId = authState.user?.uid;

  if (userId != null && _loadedUserId != userId) {
    _loadedUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsNotifierProvider.notifier)
        .loadUserStatistics(userId);
    });
  }

  return Scaffold(
    body: state.isLoading && state.userStatistics == null
        ? Center(child: CircularProgressIndicator())
        : _buildContent(state),
  );
}
```

---

### 2. 統計データの表示

```dart
Widget _buildContent(StatisticsState state) {
  final userStats = state.userStatistics;
  final diversityScore = state.diversityScore;
  final stanceDistribution = state.stanceDistribution;
  final participationTrend = state.participationTrend;
  final earnedBadges = state.earnedBadges;

  if (userStats == null) {
    return Center(child: Text('データがありません'));
  }

  return ListView(
    children: [
      // プロフィールカード
      ThinkingProfileCard(userStatistics: userStats),

      // 参加統計カード
      ParticipationStatsCard(userStatistics: userStats),

      // 多様性スコアカード
      if (diversityScore != null)
        DiversityScoreCard(diversityScore: diversityScore),

      // 立場分布カード
      if (stanceDistribution != null)
        StanceDistributionCard(stanceDistribution: stanceDistribution),

      // 参加トレンドカード
      if (participationTrend != null)
        ParticipationTrendCard(
          participationTrend: participationTrend,
          selectedYear: state.selectedYear!,
          selectedMonth: state.selectedMonth!,
          onPreviousMonth: () {
            ref.read(statisticsNotifierProvider.notifier)
              .goToPreviousMonth();
            // データ再読み込み
            final userId = ref.read(authProvider).user?.uid;
            if (userId != null) {
              ref.read(statisticsNotifierProvider.notifier)
                .loadUserStatistics(userId);
            }
          },
          onNextMonth: () {
            ref.read(statisticsNotifierProvider.notifier)
              .goToNextMonth();
            // データ再読み込み
            final userId = ref.read(authProvider).user?.uid;
            if (userId != null) {
              ref.read(statisticsNotifierProvider.notifier)
                .loadUserStatistics(userId);
            }
          },
        ),

      // 獲得バッジカード
      EarnedBadgesCard(badges: earnedBadges),
    ],
  );
}
```

---

### 3. 月変更処理

```dart
// 前月へ移動
void _goToPreviousMonth(WidgetRef ref) {
  ref.read(statisticsNotifierProvider.notifier).goToPreviousMonth();
  _reloadData(ref);
}

// 次月へ移動
void _goToNextMonth(WidgetRef ref) {
  ref.read(statisticsNotifierProvider.notifier).goToNextMonth();
  _reloadData(ref);
}

// データ再読み込み
void _reloadData(WidgetRef ref) {
  final userId = ref.read(authProvider).user?.uid;
  if (userId != null) {
    ref.read(statisticsNotifierProvider.notifier)
      .loadUserStatistics(userId);
  }
}
```

---

### 4. バッジの表示

```dart
Widget _buildBadgeList(List&lt;Badge&gt; badges) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemCount: badges.length,
    itemBuilder: (context, index) {
      final badge = badges[index];
      final definition = BadgeDefinitions.getById(badge.id);

      if (definition == null) {
        return const SizedBox.shrink();
      }

      return Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              definition.icon,
              size: 32,
              color: definition.color,
            ),
            const SizedBox(height: 8),
            Text(
              definition.name,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            if (badge.earnedAt != null)
              Text(
                DateFormat('yyyy/MM/dd').format(badge.earnedAt!),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      );
    },
  );
}
```

---

### 5. ローカルリポジトリの直接使用

```dart
// ローカルにデータを保存
Future&lt;void&gt; saveStatsLocally() async {
  final repo = LocalStatisticsRepository();

  final userStats = UserStatistics(
    userId: 'user123',
    participationDays: 10,
    totalOpinions: 42,
    consecutiveDays: 3,
    lastParticipation: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  await repo.saveUserStatistics(userStats);
}

// ローカルからデータを読み込み
Future&lt;void&gt; loadStatsLocally() async {
  final repo = LocalStatisticsRepository();
  final userStats = await repo.fetchUserStatistics('user123');

  if (userStats != null) {
    print('参加日数: ${userStats.participationDays}');
    print('総投稿数: ${userStats.totalOpinions}');
  }
}
```

---

## データ永続化とキャッシュ戦略

### SharedPreferencesの使用

**保存タイミング**:
- Firestoreからデータ取得成功時
- エラー発生時のダミーデータ生成時

**読み込みタイミング**:
- Firestoreからのデータ取得失敗時（フォールバック）

**キャッシュの利点**:
- オフライン時でもデータ表示可能
- 読み込み速度の向上
- Firestoreの読み込み回数削減（コスト削減）

**キャッシュの欠点**:
- データの鮮度が保証されない
- SharedPreferencesの容量制限（大量データには不向き）

**将来の改善案**:
- キャッシュの有効期限設定
- キャッシュとFirestoreの差分検出
- SQLiteへの移行（大量データ対応）

---

## エラーハンドリング

### 1. Firestoreエラー

```dart
try {
  final userStats = await firestoreRepo.fetchUserStatistics(userId);
  // ...
} catch (e) {
  // エラー時はローカルキャッシュからフォールバック
  final localRepo = LocalStatisticsRepository();
  final cachedStats = await localRepo.fetchUserStatistics(userId);

  if (cachedStats != null) {
    // キャッシュデータを使用
    state = state.copyWith(userStatistics: cachedStats, isLoading: false);
  } else {
    // キャッシュもない場合はダミーデータ生成
    final dummyStats = _createDummyUserStatistics(userId);
    await localRepo.saveUserStatistics(dummyStats);
    state = state.copyWith(userStatistics: dummyStats, isLoading: false);
  }
}
```

---

### 2. JSONパースエラー

```dart
Future&lt;UserStatistics?&gt; fetchUserStatistics(String userId) async {
  final prefs = await _prefs;
  final jsonString = prefs.getString(_userKey(userId));
  if (jsonString == null) return null;

  try {
    final map = jsonDecode(jsonString) as Map&lt;String, dynamic&gt;;
    return UserStatistics.fromJson(map);
  } catch (e) {
    // パース失敗時はnullを返す（エラーを握り潰す）
    debugPrint('JSONパースエラー: $e');
    return null;
  }
}
```

**注意**: 現在の実装では、JSONパースエラーを握り潰して`null`を返しています。将来的にはエラーログの記録やSentryへの送信を検討する必要があります。

---

### 3. ゲストモードのハンドリング

```dart
// ゲストモードの判定
final prefs = await SharedPreferences.getInstance();
final isGuest = prefs.getBool('is_guest_mode') ?? false;

if (isGuest || userId.isEmpty) {
  // ゲストモード用のモックデータを生成
  debugPrint('👤 ゲストモード: モックデータを使用');

  final mockData = _createMockData();
  state = state.copyWith(
    userStatistics: mockData.userStatistics,
    diversityScore: mockData.diversityScore,
    stanceDistribution: mockData.stanceDistribution,
    participationTrend: mockData.participationTrend,
    earnedBadges: mockData.badges,
    isLoading: false,
  );
  return;
}
```

---

## 技術的な特徴

### 1. Freezedの使用

**メリット**:
- イミュータブルなデータクラス
- `copyWith()`メソッドの自動生成
- `==`と`hashCode`の自動実装
- JSON変換の簡潔な実装

**使用例**:

```dart
final updatedStats = userStats.copyWith(
  totalOpinions: userStats.totalOpinions + 1,
  updatedAt: DateTime.now(),
);
```

---

### 2. Repository パターン

**メリット**:
- データソースの抽象化
- テスト容易性の向上
- データソースの切り替えが容易

**実装**:

```dart
// インターフェース定義
abstract class StatisticsRepository {
  Future&lt;UserStatistics&gt; fetchUserStatistics(String userId);
  // ...
}

// Firestore実装
class FirestoreStatisticsRepository implements StatisticsRepository {
  @override
  Future&lt;UserStatistics&gt; fetchUserStatistics(String userId) async {
    // Firestoreからデータ取得
  }
}

// ローカル実装
class LocalStatisticsRepository implements StatisticsRepository {
  @override
  Future&lt;UserStatistics&gt; fetchUserStatistics(String userId) async {
    // SharedPreferencesからデータ取得
  }
}
```

---

### 3. エントロピーベースの多様性スコア計算

**アルゴリズム**:

```dart
// シャノンエントロピーの計算
double calculateEntropy(List&lt;double&gt; probabilities) {
  double entropy = 0;
  for (final p in probabilities) {
    if (p > 0) {
      entropy -= p * log2(p);
    }
  }
  return entropy;
}

// 最大エントロピー（3つの選択肢の場合）
final maxEntropy = log2(3); // 1.585

// 0-100のスコアに正規化
final score = (entropy / maxEntropy) * 100;
```

**特性**:
- 均等分布（33.3%, 33.3%, 33.3%）→ 100点
- 完全偏り（100%, 0%, 0%）→ 0点
- 2:1分布（50%, 50%, 0%）→ 63点

---

### 4. 週単位の集計ロジック

**月曜始まりの週計算**:

```dart
// ある日が属する週の月曜日を計算
DateTime getWeekStart(DateTime date) {
  final daysSinceMonday = (date.weekday - 1) % 7;
  return date.subtract(Duration(days: daysSinceMonday));
}

// 週の開始日（時刻を00:00:00に正規化）
final weekStartDate = DateTime(
  weekStart.year,
  weekStart.month,
  weekStart.day
);
```

**月の全週を網羅**:

```dart
// 月の最初の週（月曜）から最後の週まで
DateTime currentWeekStart = firstDayOfMonth.subtract(
  Duration(days: (firstDayOfMonth.weekday - 1) % 7)
);

while (currentWeekStart.isBefore(lastDayOfMonth) ||
       currentWeekStart.isAtSameMomentAs(lastDayOfMonth)) {
  // ポイント追加
  points.add(ParticipationPoint(date: weekStartDate, count: count));

  // 次の週へ
  currentWeekStart = currentWeekStart.add(const Duration(days: 7));
}
```

---

## テストガイド

### ユニットテスト例

#### モデルのJSON変換テスト

```dart
test('UserStatistics toJson/fromJson', () {
  final stats = UserStatistics(
    userId: 'user123',
    participationDays: 10,
    totalOpinions: 42,
    consecutiveDays: 3,
    lastParticipation: DateTime(2025, 1, 1),
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final json = stats.toJson();
  final decoded = UserStatistics.fromJson(json);

  expect(decoded, stats);
});
```

---

#### リポジトリのテスト

```dart
test('LocalStatisticsRepository save and fetch', () async {
  // SharedPreferencesのモックを使用
  SharedPreferences.setMockInitialValues({});

  final repo = LocalStatisticsRepository();
  final stats = UserStatistics(
    userId: 'user123',
    participationDays: 10,
    totalOpinions: 42,
    consecutiveDays: 3,
    lastParticipation: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // 保存
  await repo.saveUserStatistics(stats);

  // 読み込み
  final fetched = await repo.fetchUserStatistics('user123');

  expect(fetched, isNotNull);
  expect(fetched!.userId, 'user123');
  expect(fetched.totalOpinions, 42);
});
```

---

#### バッジ判定ロジックのテスト

```dart
test('Badge award logic - first post', () {
  final stats = UserStatistics(
    userId: 'user123',
    participationDays: 1,
    totalOpinions: 1, // 1投稿
    consecutiveDays: 1,
    lastParticipation: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final badges = _awardBadges(stats, null, null, 0, 0);

  expect(badges.any((b) => b.id == 'first_post'), isTrue);
  expect(badges.any((b) => b.id == 'ten_posts'), isFalse);
});

test('Badge award logic - 7 days streak', () {
  final stats = UserStatistics(
    userId: 'user123',
    participationDays: 10,
    totalOpinions: 20,
    consecutiveDays: 7, // 7日連続
    lastParticipation: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final badges = _awardBadges(stats, null, null, 0, 0);

  expect(badges.any((b) => b.id == 'seven_days_streak'), isTrue);
});
```

---

#### 多様性スコア計算のテスト

```dart
test('Diversity score calculation - balanced', () {
  final counts = {
    'agree': 33,
    'neutral': 33,
    'disagree': 34,
  };

  final score = _calculateDiversityScore(counts);

  // 均等分布なので100点に近い
  expect(score, greaterThan(95));
  expect(score, lessThanOrEqualTo(100));
});

test('Diversity score calculation - biased', () {
  final counts = {
    'agree': 100,
    'neutral': 0,
    'disagree': 0,
  };

  final score = _calculateDiversityScore(counts);

  // 完全偏りなので0点
  expect(score, equals(0));
});
```

---

## トラブルシューティング

### 統計データが表示されない

**原因**: Firestoreのopinionsコレクションにデータがない、またはユーザーIDが不一致

**解決策**:
1. Firestoreコンソールでopinionsコレクションを確認
2. `userId`フィールドが正しいか確認
3. Firestoreセキュリティルールを確認
4. デバッグログで`opinions.length`を確認

```dart
debugPrint('📊 統計データ取得開始: userId=$userId');
debugPrint('📊 UserStatistics取得: totalOpinions=${u.totalOpinions}');
```

---

### バッジが表示されない

**原因**: バッジIDが`BadgeDefinitions`に存在しない

**解決策**:
1. `BadgeDefinitions.getById(badge.id)`の戻り値を確認
2. `badge.id`が正しいか確認
3. `BadgeDefinitions.all`にバッジが定義されているか確認

```dart
final definition = BadgeDefinitions.getById(badge.id);
if (definition == null) {
  debugPrint('❌ バッジ定義が見つかりません: ${badge.id}');
  return const SizedBox.shrink();
}
```

---

### 多様性スコアが表示されない

**原因**: すべての立場が0件（投稿がない）

**解決策**:
1. `fetchDiversityScore`が`null`を返す場合は非表示
2. 最低1件の投稿が必要

```dart
if (diversityScore != null) {
  DiversityScoreCard(diversityScore: diversityScore);
}
```

---

### 月変更が反映されない

**原因**: `loadUserStatistics`が呼ばれていない

**解決策**:

```dart
onPressed: () {
  // 1. 月を変更
  ref.read(statisticsNotifierProvider.notifier).goToNextMonth();

  // 2. データ再読み込み（重要！）
  final userId = ref.read(authProvider).user?.uid;
  if (userId != null) {
    ref.read(statisticsNotifierProvider.notifier)
      .loadUserStatistics(userId);
  }
}
```

---

### ローカルキャッシュが更新されない

**原因**: `saveAll`の呼び出しタイミングが不適切

**解決策**:

```dart
// Firestoreから全データ取得後に保存
if (d != null && s != null && t != null) {
  final localRepo = LocalStatisticsRepository();
  await localRepo.saveAll(
    userStatistics: u,
    diversityScore: d,
    stanceDistribution: s,
    participationTrend: t,
  );
}
```

---

## 今後の拡張予定

### Phase 1: バグフィックス・最適化
- [ ] バッジ授与タイミングの最適化（投稿時に自動判定）
- [ ] キャッシュの有効期限設定
- [ ] エラーログの記録（Sentry連携）
- [ ] 多様性スコアの計算精度向上

### Phase 2: 機能強化
- [ ] 統計データのエクスポート機能（CSV, JSON）
- [ ] 月次レポートの自動生成
- [ ] バッジ獲得時の通知機能
- [ ] ランキング機能（全ユーザー比較）
- [ ] 統計グラフのカスタマイズ

### Phase 3: 高度な機能
- [ ] 機械学習による参加予測
- [ ] パーソナライズされたインサイト提供
- [ ] ソーシャル比較機能
- [ ] カスタムバッジの作成機能

---

## コーディング規約

### Dartコーディングスタイル
- Effective Dartに準拠
- linterルールに従う（`analysis_options.yaml`参照）

### ファイル命名規則
- モデル: `xxx.dart`（例: `user_statistics.dart`）
- プロバイダー: `xxx_provider.dart`
- リポジトリ: `xxx_repository.dart`
- ページ: `xxx.dart`または`xxx_page.dart`
- ウィジェット: `xxx_widget.dart`または`xxx_card.dart`

### コメント規則
- 公開APIには必ずドキュメントコメント（`///`）を記述
- 複雑なロジックには実装コメント（`//`）を追加
- TODOコメントには担当者名と日付を記載

```dart
/// ユーザーの統計データを取得する
///
/// [userId]: ユーザーID
///
/// 戻り値: UserStatistics（取得失敗時はダミーデータ）
Future&lt;UserStatistics&gt; fetchUserStatistics(String userId) async {
  // Firestoreからopinionsを取得
  final opinionsQuery = await _firestore
      .collection('opinions')
      .where('userId', isEqualTo: userId)
      .get();

  // TODO(@username, 2025-12-10): キャッシュロジックを追加

  // ...
}
```

---

## 参考資料

### プロジェクト内ドキュメント
- [lib/feature/challenge/README.md](../challenge/README.md) - Challenge機能の説明
- [lib/feature/debate/README.md](../debate/README.md) - Debate機能の説明
- [lib/core/README.md](../../core/README.md) - コア機能の説明

### 外部ドキュメント
- [Riverpod公式ドキュメント](https://riverpod.dev/)
- [Freezed公式ドキュメント](https://pub.dev/packages/freezed)
- [Cloud Firestore公式ドキュメント](https://firebase.google.com/docs/firestore)
- [fl_chart公式ドキュメント](https://pub.dev/packages/fl_chart)
- [shared_preferences公式ドキュメント](https://pub.dev/packages/shared_preferences)

---

**最終更新日**: 2025-12-05
**バージョン**: 2.0.0
**メンテナー**: Development Team

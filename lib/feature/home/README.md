# Home機能 - AIトピック生成とディスカッション

AIを活用した1日1回のトピック自動生成とディスカッション機能を提供するモジュールです。

## 目次

1. [機能概要](#機能概要)
2. [アーキテクチャ概要](#アーキテクチャ概要)
3. [依存関係](#依存関係)
4. [クラス構成と責任](#クラス構成と責任)
5. [データフロー](#データフロー)
6. [ディレクトリ構成](#ディレクトリ構成)
7. [セットアップ](#セットアップ)
8. [使い方](#使い方)
9. [コード例](#コード例)
10. [トラブルシューティング](#トラブルシューティング)
11. [今後の拡張予定](#今後の拡張予定)

---

## 機能概要

### 日別トピック機能

**メインのホーム画面機能** - 1日1回AIによって自動生成されるトピックをユーザーに提示し、意見投稿を促す機能

#### 特徴
- ✅ **1日1回の自動生成**: 毎日新しいトピックがAIによって生成される
- ✅ **Firestoreでキャッシュ**: 同じ日は同じトピックを表示（API コスト削減）
- ✅ **ランダムな特性**: カテゴリーと難易度が確率的に決定される
- ✅ **意見投稿機能**: 賛成/反対/中立の立場で100〜3000文字の意見を投稿
- ✅ **Debate機能連携**: トピック生成時に自動的にDebateイベントも作成

#### カテゴリー分布（確率的選択）
| カテゴリー | 確率 | 説明 |
|----------|------|------|
| 日常系 | 40% | 日常生活や身近なテーマについての話題 |
| 社会問題系 | 35% | 社会問題や時事的なテーマについての話題 |
| 価値観系 | 25% | 価値観や人生観についての深いテーマ |

#### 難易度分布（確率的選択）
| 難易度 | 確率 | 説明 |
|--------|------|------|
| 簡単 | 45% | 気軽に答えられる話題 |
| 中程度 | 35% | 少し考える必要がある話題 |
| 難しい | 20% | 深い思考が必要な話題 |

---

### 意見投稿・一覧機能

**トピックに対する意見の投稿・閲覧・編集機能** - ユーザーが各トピックに対して自分の意見を投稿し、他のユーザーの意見を閲覧できる機能

#### 特徴
- ✅ **1トピック1投稿制限**: 各ユーザーは1つのトピックに対して1回のみ意見を投稿可能
- ✅ **立場表明**: 賛成/反対/中立の3つの立場から選択
- ✅ **リアクション機能**: 共感/深い/新しい視点の3種類のリアクション
- ✅ **自動遷移**: 投稿完了後、自動的に意見一覧画面に遷移
- ✅ **統計表示**: 立場別の意見数と割合をリアルタイムで表示
- ✅ **編集機能**: 自分の投稿を後から編集可能
- ✅ **Firestore連携**: 全ての意見はFirestoreにリアルタイムで保存
- ✅ **日付選択機能**: 過去のトピックと意見を閲覧可能

---

### AIトピック生成機能

**開発・テスト用の生成画面** - 様々な条件でトピックを生成・テストできる機能

#### 主な機能
1. **トピック生成**: OpenAI GPT-4、Anthropic Claude、Google Gemini を使用
2. **トピック分類器**: 自動分類とタグ抽出
3. **重複検出**: レーベンシュタイン距離とJaccard係数による類似度計算
4. **難易度調整**: ユーザー層に応じた難易度配分

---

## アーキテクチャ概要

この機能は**クリーンアーキテクチャ**と**Riverpod**を採用した階層型アーキテクチャで構築されています。

### レイヤー構成

```
┌─────────────────────────────────────────────────────┐
│ Presentation Layer (UI)                             │
│  - Pages (画面)                                      │
│  - Widgets (再利用可能なUIコンポーネント)              │
└─────────────────────────────────────────────────────┘
                         ↓↑
┌─────────────────────────────────────────────────────┐
│ Provider Layer (状態管理)                            │
│  - Notifier (状態管理ロジック)                        │
│  - State (状態クラス)                                │
└─────────────────────────────────────────────────────┘
                         ↓↑
┌─────────────────────────────────────────────────────┐
│ Service Layer (ビジネスロジック)                      │
│  - TopicGenerationService (トピック生成)              │
│  - TopicClassifierService (分類)                     │
│  - TopicDuplicateDetector (重複検出)                 │
│  - TopicDifficultyAdjuster (難易度調整)              │
│  - NewsService (ニュース取得)                         │
└─────────────────────────────────────────────────────┘
                         ↓↑
┌─────────────────────────────────────────────────────┐
│ Repository Layer (データアクセス)                     │
│  - OpinionRepository (Firestore: 意見)               │
│  - DailyTopicRepository (Firestore: トピック)         │
│  - AIRepository (外部API: OpenAI/Claude/Gemini)      │
└─────────────────────────────────────────────────────┘
                         ↓↑
┌─────────────────────────────────────────────────────┐
│ Model Layer (データモデル)                           │
│  - Opinion (意見)                                    │
│  - Topic (トピック)                                  │
│  - NewsItem (ニュース)                               │
└─────────────────────────────────────────────────────┘
```

### 設計原則

1. **単一責任の原則**: 各クラスは1つの責任のみを持つ
2. **依存性逆転の原則**: 上位層は下位層に依存するが、具象クラスではなく抽象に依存
3. **状態管理の集中化**: Riverpodによる一元的な状態管理
4. **不変性**: Freezedによる不変データモデル

---

## 依存関係

### 外部依存（他のFeatureモジュール）

```
lib/feature/home
    ↓
    └─→ lib/feature/debate
         └─→ DebateEventRepository (Debateイベント自動作成)
              - トピック生成時にDebateイベントも作成
              - タグ情報を自動生成して連携
```

**詳細**:
- `lib/feature/home/providers/daily_topic_provider.dart:10` で `DebateEventRepository` をインポート
- トピック生成時に `_createDebateEventFromTopic()` メソッドでDebateイベントを自動作成
- これにより、ホームで生成されたトピックがDebate機能でもディスカッションできる

### 外部パッケージ依存

| パッケージ | バージョン | 用途 | 使用箇所 |
|----------|----------|------|---------|
| `flutter_riverpod` | ^3.0.0 | 状態管理 | 全Provider, ConsumerWidget |
| `freezed` | ^2.0.0 | 不変データモデル | Topic, Opinion, State classes |
| `freezed_annotation` | ^2.0.0 | Freezed用アノテーション | モデルクラス |
| `json_annotation` | ^4.0.0 | JSON シリアライズ | モデルクラス |
| `cloud_firestore` | ^5.0.0 | データベース | Repository層 |
| `firebase_auth` | ^5.0.0 | 認証（ユーザーID取得） | Opinion投稿時 |
| `uuid` | ^4.0.0 | UUID生成 | Opinion ID生成 |
| `http` | ^1.0.0 | HTTP通信 | AIRepository |
| `flutter_dotenv` | ^5.0.0 | 環境変数管理 | APIキー管理 |
| `go_router` | ^14.0.0 | ルーティング | 画面遷移 |
| `intl` | ^0.19.0 | 日付フォーマット | 日付選択UI |

### 内部パッケージ依存

**コアライブラリ**: 現在、home機能は独立しており、core層への依存はありません。将来的に共通ユーティリティが必要になった場合は`lib/core/`に配置される予定です。

---

## プロバイダー依存関係図

### DailyTopicProvider の依存関係

```
dailyTopicProvider (NotifierProvider)
    ├─→ dailyTopicRepositoryProvider (Provider)
    │    └─→ DailyTopicRepository (Firestore接続)
    │
    ├─→ randomTopicSelectorProvider (Provider)
    │    └─→ RandomTopicSelector (確率的選択ロジック)
    │
    ├─→ geminiRepositoryProviderForDaily (Provider)
    │    └─→ GeminiRepository (Gemini API接続)
    │
    ├─→ newsServiceProviderForDaily (Provider)
    │    └─→ NewsService
    │         └─→ geminiRepositoryProviderForDaily
    │
    ├─→ debateEventRepositoryProviderForDaily (Provider)
    │    └─→ DebateEventRepository (外部feature: debate)
    │         └─→ Firestore (debate_events コレクション)
    │
    └─→ TopicGenerationService (直接生成)
         └─→ AIRepositoryFactory.create(AIProvider.openai)
              └─→ OpenAIRepository (OpenAI API接続)
```

### OpinionProvider の依存関係

```
opinionPostProvider (NotifierProvider.family)
    └─→ opinionRepositoryProvider (Provider)
         └─→ OpinionRepository (Firestore接続)
              └─→ opinions コレクション

opinionListProvider (NotifierProvider.family)
    └─→ opinionRepositoryProvider (Provider)
         └─→ OpinionRepository (Firestore接続)
              └─→ opinions コレクション
```

### TopicGenerationProvider の依存関係

```
topicGenerationProvider (NotifierProvider)
    ├─→ aiProviderProvider (NotifierProvider)
    │    └─→ AIProvider enum (openai/claude/gemini)
    │
    ├─→ aiRepositoryProvider (Provider)
    │    └─→ AIRepositoryFactory
    │         ├─→ OpenAIRepository
    │         ├─→ ClaudeRepository
    │         └─→ GeminiRepository
    │
    ├─→ topicGenerationServiceProvider (Provider)
    │    └─→ TopicGenerationService
    │         └─→ aiRepositoryProvider
    │
    ├─→ topicClassifierServiceProvider (Provider)
    │    └─→ TopicClassifierService
    │         └─→ aiRepositoryProvider
    │
    ├─→ topicDuplicateDetectorProvider (Provider)
    │    └─→ TopicDuplicateDetector
    │
    ├─→ topicDifficultyAdjusterProvider (Provider)
    │    └─→ TopicDifficultyAdjuster
    │
    ├─→ newsServiceProvider (Provider)
    │    └─→ NewsService
    │         └─→ geminiRepositoryProvider
    │
    └─→ userLevelProvider (NotifierProvider)
         └─→ UserLevel enum
```

### 日付選択Provider の依存関係

```
selectedDateProvider (NotifierProvider)
    └─→ SelectedDateNotifier
         └─→ DateTime state

topicByDateProvider (FutureProvider.family)
    ├─→ selectedDateProvider (日付を監視)
    └─→ dailyTopicRepositoryProvider
         └─→ DailyTopicRepository.getTopicByDate(date)
```

---

## クラス構成と責任

### Models層

#### Opinion (`lib/feature/home/models/opinion.dart`)

**責任**: 意見データの表現

```dart
@freezed
class Opinion with _$Opinion {
  const factory Opinion({
    required String id,           // UUID
    required String topicId,      // 関連トピックID
    required String topicText,    // トピック本文（スナップショット）
    required String userId,       // 投稿者ID
    required String userName,     // 投稿者名
    required OpinionStance stance, // 立場
    required String content,      // 意見内容
    required DateTime createdAt,  // 投稿日時
    @Default(0) int likeCount,    // いいね数
    @Default({}) Map<String, List<String>> reactions, // リアクション
    @Default(false) bool isDeleted, // 削除フラグ
  }) = _Opinion;
}
```

**関連Enum**:
- `OpinionStance`: agree, disagree, neutral
- `ReactionType`: empathy, thoughtful, newPerspective

**ファイル間の関連**:
- → `OpinionRepository`: Firestore へのシリアライズ/デシリアライズ
- → `OpinionPostNotifier`: 意見投稿時のモデル生成
- → `OpinionListNotifier`: 意見一覧の表示

#### Topic (`lib/feature/home/models/topic.dart`)

**責任**: トピックデータの表現

```dart
@freezed
class Topic with _$Topic {
  const factory Topic({
    required String id,
    required String text,
    required TopicCategory category,
    required TopicDifficulty difficulty,
    required DateTime createdAt,
    required TopicSource source,     // ai/manual
    @Default([]) List<String> tags,
    String? description,
    Map<TopicFeedback, int>? feedbackCounts,
  }) = _Topic;
}
```

**関連Enum**:
- `TopicCategory`: daily, social, value
- `TopicDifficulty`: easy, medium, hard
- `TopicSource`: ai, manual
- `TopicFeedback`: good, normal, bad

**ファイル間の関連**:
- → `DailyTopicRepository`: Firestore へのシリアライズ/デシリアライズ
- → `TopicGenerationService`: トピック生成時のモデル生成
- → `DailyTopicNotifier`: 日別トピックの状態管理

#### NewsItem (`lib/feature/home/models/news_item.dart`)

**責任**: ニュースデータの表現

```dart
@freezed
class NewsItem with _$NewsItem {
  const factory NewsItem({
    required String title,
    required String description,
    required String url,
    required DateTime publishedAt,
  }) = _NewsItem;
}
```

**ファイル間の関連**:
- → `NewsService`: Gemini APIからのニュース取得
- → `TopicGenerationService`: トピック生成時のコンテキスト情報

---

### Repository層

#### OpinionRepository (`lib/feature/home/repositories/opinion_repository.dart`)

**責任**: 意見データの永続化とFirestore操作

**依存先**:
- `cloud_firestore`: Firestoreクライアント
- `Opinion`: データモデル

**主要メソッド**:
```dart
Future<void> postOpinion(Opinion opinion)
Future<List<Opinion>> getOpinionsByTopic(String topicId)
Future<Map<OpinionStance, int>> getOpinionCountsByStance(String topicId)
Future<Opinion?> getUserOpinion(String topicId, String userId)
Future<bool> hasUserPostedOpinion(String topicId, String userId)
Future<void> updateOpinion(String id, OpinionStance stance, String content)
Future<void> deleteOpinion(String opinionId)
Future<void> likeOpinion(String opinionId)
Stream<List<Opinion>> watchOpinionsByTopic(String topicId)
Future<void> toggleReaction(String opinionId, String userId, ReactionType type)
```

**Firestoreコレクション**:
- `opinions/{opinionId}`

**呼び出し元**:
- `OpinionPostNotifier`
- `OpinionListNotifier`

#### DailyTopicRepository (`lib/feature/home/repositories/daily_topic_repository.dart`)

**責任**: 日別トピックデータの永続化とFirestore操作

**依存先**:
- `cloud_firestore`: Firestoreクライアント
- `Topic`: データモデル

**主要メソッド**:
```dart
Future<Topic?> getTodayTopic()
Future<void> saveTodayTopic(Topic topic)
Future<Topic?> getTopicByDate(DateTime date)
Future<List<Topic>> getRecentTopics({int limit = 30})
Future<bool> hasTodayTopic()
Future<void> deleteTopic(String dateKey)
Future<void> submitFeedback(String dateKey, String userId, TopicFeedback feedback)
Future<TopicFeedback?> getUserFeedback(String dateKey, String userId)
```

**Firestoreコレクション**:
- `daily_topics/{YYYY-MM-DD}`

**呼び出し元**:
- `DailyTopicNotifier`

#### AIRepository (`lib/feature/home/repositories/ai_repository.dart`)

**責任**: AI APIとの通信（Factory パターン）

**依存先**:
- `http`: HTTP通信
- `flutter_dotenv`: 環境変数

**実装クラス**:
1. **OpenAIRepository**: OpenAI GPT-4 API
2. **ClaudeRepository**: Anthropic Claude API
3. **GeminiRepository**: Google Gemini API

**主要メソッド**:
```dart
abstract class AIRepository {
  Future<String> generateText(String prompt, {Map<String, dynamic>? options});
}

// Gemini専用
Future<String> generateTextWithSearch(String prompt)
```

**呼び出し元**:
- `TopicGenerationService`
- `TopicClassifierService`
- `NewsService`

---

### Service層

#### TopicGenerationService (`lib/feature/home/services/topic_generation_service.dart`)

**責任**: AIを使用したトピック生成ロジック

**依存先**:
- `AIRepository`: AI API通信
- `Topic`: データモデル

**主要メソッド**:
```dart
Future<String> generateTopic({
  TopicCategory? category,
  TopicDifficulty? difficulty,
})

Future<List<String>> generateMultipleTopics(int count, {
  TopicCategory? category,
  TopicDifficulty? difficulty,
})

Future<Map<TopicCategory, String>> generateByCategories({
  TopicDifficulty? difficulty,
})
```

**呼び出し元**:
- `DailyTopicNotifier`
- `TopicGenerationNotifier`

#### TopicClassifierService (`lib/feature/home/services/topic_classifier_service.dart`)

**責任**: トピックの自動分類とタグ抽出

**依存先**:
- `AIRepository`: AI API通信
- `Topic`: データモデル

**主要メソッド**:
```dart
Future<ClassificationResult> classifyTopic(String topicText)
ClassificationResult classifyTopicByRules(String topicText) // フォールバック
```

**呼び出し元**:
- `TopicGenerationNotifier`

#### TopicDuplicateDetector (`lib/feature/home/services/topic_duplicate_detector.dart`)

**責任**: トピックの重複検出

**依存先**: なし（純粋な計算ロジック）

**主要メソッド**:
```dart
double calculateSimilarity(String text1, String text2)
double findMaxSimilarity(String target, List<String> existing)
bool isDuplicate(String target, List<String> existing, {double threshold = 0.8})
String? findMostSimilarTopic(String target, List<String> existing)
double calculateJaccardSimilarity(String text1, String text2)
double calculateCompositeSimilarity(String text1, String text2)
```

**アルゴリズム**:
- レーベンシュタイン距離
- Jaccard係数
- 複合類似度スコア

**呼び出し元**:
- `TopicGenerationNotifier`

#### TopicDifficultyAdjuster (`lib/feature/home/services/topic_difficulty_adjuster.dart`)

**責任**: ユーザーレベルに応じた難易度調整

**依存先**:
- `Topic`: データモデル（TopicDifficulty, UserLevel）

**主要メソッド**:
```dart
Map<TopicDifficulty, double> getDifficultyDistribution(UserLevel level)
TopicDifficulty selectDifficulty(UserLevel level)
TopicDifficulty evaluateDifficulty(String topicText)
UserLevel adjustUserLevel(UserLevel current, List<bool> recentResults)
bool checkBalance(List<TopicDifficulty> recentTopics)
```

**呼び出し元**:
- `TopicGenerationNotifier`

#### NewsService (`lib/feature/home/services/news_service.dart`)

**責任**: Gemini APIを使用したニュース取得

**依存先**:
- `GeminiRepository`: Gemini API通信
- `NewsItem`: データモデル

**主要メソッド**:
```dart
Future<List<NewsItem>> getRelatedNews(String topic)
Future<List<NewsItem>> getNewsByCategory(String category)
```

**呼び出し元**:
- `DailyTopicNotifier` (トピック生成時のコンテキスト情報として使用)

---

### Provider層（状態管理）

#### DailyTopicNotifier (`lib/feature/home/providers/daily_topic_provider.dart`)

**責任**: 日別トピックの状態管理とビジネスロジック調整

**状態クラス**: `DailyTopicState`
```dart
@freezed
class DailyTopicState with _$DailyTopicState {
  const factory DailyTopicState({
    Topic? currentTopic,
    @Default(false) bool isLoading,
    @Default(false) bool isGenerating,
    String? error,
  }) = _DailyTopicState;
}
```

**依存先**:
- `DailyTopicRepository`
- `TopicGenerationService`
- `RandomTopicSelector`
- `NewsService`
- `DebateEventRepository` (外部feature)

**主要メソッド**:
```dart
Future<void> loadTodayTopic()
Future<void> generateNewTopic()
Future<void> regenerateTopic()
void clearError()
```

**特殊なロジック**:
- トピック生成時にDebateイベントも自動作成（`_createDebateEventFromTopic()`）
- タグの自動生成（`_generateTags()`）

**使用される画面**:
- `DailyTopicHomeScreen`
- `OpinionListScreen`

#### OpinionPostNotifier (`lib/feature/home/providers/opinion_provider.dart`)

**責任**: 意見投稿の状態管理

**状態クラス**: `OpinionPostState`
```dart
@freezed
class OpinionPostState with _$OpinionPostState {
  const factory OpinionPostState({
    @Default(false) bool isPosting,
    @Default(false) bool hasPosted,
    String? error,
    Opinion? userOpinion,
  }) = _OpinionPostState;
}
```

**依存先**:
- `OpinionRepository`
- `firebase_auth`: ユーザーID取得

**主要メソッド**:
```dart
Future<void> checkUserOpinion()
Future<bool> postOpinion({
  required String topicText,
  required OpinionStance stance,
  required String content,
})
Future<bool> updateOpinion(OpinionStance stance, String content)
void clearError()
```

**使用される画面**:
- `DailyTopicHomeScreen`
- `MyOpinionDetailScreen`

#### OpinionListNotifier (`lib/feature/home/providers/opinion_provider.dart`)

**責任**: 意見一覧の状態管理

**状態クラス**: `OpinionListState`
```dart
@freezed
class OpinionListState with _$OpinionListState {
  const factory OpinionListState({
    @Default([]) List<Opinion> opinions,
    @Default(false) bool isLoading,
    String? error,
    @Default({}) Map<OpinionStance, int> stanceCounts,
  }) = _OpinionListState;
}
```

**依存先**:
- `OpinionRepository`

**主要メソッド**:
```dart
Future<void> loadOpinions()
Future<void> refresh()
void clearError()
Future<void> toggleReaction(String opinionId, ReactionType type)
```

**使用される画面**:
- `OpinionListScreen`

#### TopicGenerationNotifier (`lib/feature/home/providers/topic_generation_provider.dart`)

**責任**: AI トピック生成画面（開発用）の状態管理

**状態クラス**: `TopicGenerationState`
```dart
@freezed
class TopicGenerationState with _$TopicGenerationState {
  const factory TopicGenerationState({
    @Default(false) bool isGenerating,
    String? error,
    Topic? currentTopic,
    @Default([]) List<Topic> generatedTopics,
    @Default([]) List<String> existingTopics,
  }) = _TopicGenerationState;
}
```

**依存先**:
- `TopicGenerationService`
- `TopicClassifierService`
- `TopicDuplicateDetector`
- `TopicDifficultyAdjuster`
- `AIRepositoryProvider`

**主要メソッド**:
```dart
Future<void> generateTopic({TopicCategory? category, TopicDifficulty? difficulty})
Future<void> generateMultipleTopics(int count)
Future<void> generateByCategories()
void clearGeneratedTopics()
void setCurrentTopic(Topic? topic)
```

**使用される画面**:
- `AITopicHomeScreen`

#### SelectedDateNotifier (`lib/feature/home/providers/daily_topic_provider.dart`)

**責任**: 日付選択の状態管理（過去のトピック閲覧用）

**状態**: `DateTime`

**主要メソッド**:
```dart
void setDate(DateTime date)
```

**使用される画面**:
- `OpinionListScreen`（日付選択機能）

---

### Presentation層

#### Pages

**DailyTopicHomeScreen** (`lib/feature/home/presentation/pages/daily_topic_home.dart`)
- **責任**: 今日のトピック表示と意見投稿UI
- **依存Provider**: `dailyTopicProvider`, `opinionPostProvider`
- **ナビゲーション先**: `OpinionListScreen`（投稿完了後）

**OpinionListScreen** (`lib/feature/home/presentation/pages/home_answer.dart`)
- **責任**: 意見一覧表示、日付選択、フィードバック機能
- **依存Provider**: `opinionListProvider`, `selectedDateProvider`, `topicByDateProvider`, `dailyTopicProvider`
- **ナビゲーション先**: `MyOpinionDetailScreen`

**MyOpinionDetailScreen** (`lib/feature/home/presentation/pages/my_opinion_detail.dart`)
- **責任**: 自分の意見詳細表示・編集
- **依存Provider**: `opinionPostProvider`
- **ナビゲーション**: 戻るボタンで前画面へ

**AITopicHomeScreen** (`lib/feature/home/presentation/pages/home_aitopic.dart`)
- **責任**: 開発・テスト用AI トピック生成画面
- **依存Provider**: `topicGenerationProvider`, `aiProviderProvider`

**（旧）HomeScreen** (`lib/feature/home/presentation/pages/home.dart`)
- **責任**: 旧ホーム画面（現在は使用頻度低）
- **依存Provider**: なし

**（旧）TopicCard** (`lib/feature/home/presentation/pages/home_topic.dart`)
- **責任**: トピック表示画面（旧）
- **依存Provider**: なし

#### Widgets

**TopicCard** (`lib/feature/home/presentation/widgets/topic_card.dart`)
- **責任**: トピック情報を表示する再利用可能なカードUI
- **Props**: `Topic topic`, `String? dateText`
- **使用箇所**: `DailyTopicHomeScreen`, `OpinionListScreen`, `AITopicHomeScreen`

**NewsCard** (`lib/feature/home/presentation/widgets/news_card.dart`)
- **責任**: ニュース情報を表示するカードUI
- **Props**: `NewsItem news`
- **使用箇所**: （将来的な使用を想定）

**NewsList** (`lib/feature/home/presentation/widgets/news_list.dart`)
- **責任**: ニュース一覧を表示
- **Props**: `List<NewsItem> news`
- **使用箇所**: （将来的な使用を想定）

**DateSelectorWidget** (`lib/feature/home/presentation/widgets/date_selector_widget.dart`)
- **責任**: 日付選択UI（前日/翌日ボタン、カレンダーピッカー）
- **依存Provider**: `selectedDateProvider`
- **使用箇所**: `OpinionListScreen` の AppBar

---

### Utils層

**RandomTopicSelector** (`lib/feature/home/utils/random_topic_selector.dart`)

**責任**: カテゴリーと難易度の確率的選択

**主要メソッド**:
```dart
TopicCategory selectRandomCategory()
TopicDifficulty selectRandomDifficulty()
({TopicCategory category, TopicDifficulty difficulty}) selectRandom()
TopicCategory selectCategoryWithWeights(List<double> weights)
TopicDifficulty selectDifficultyWithWeights(List<double> weights)
```

**デフォルト確率分布**:
- カテゴリー: [0.4, 0.35, 0.25] (daily, social, value)
- 難易度: [0.45, 0.35, 0.2] (easy, medium, hard)

**呼び出し元**:
- `DailyTopicNotifier.generateNewTopic()`

---

## データフロー

### 1. トピック生成フロー

```
[アプリ起動]
    ↓
DailyTopicHomeScreen
    ↓
dailyTopicProvider.loadTodayTopic()
    ↓
DailyTopicRepository.getTodayTopic()
    ↓
[Firestore: daily_topics/{today}]
    ↓
├─ トピック存在 → 表示
└─ トピック不存在
    ↓
    ※ サーバー側で9:00に自動生成される想定
    （または手動で generateNewTopic() を実行）
    ↓
    DailyTopicNotifier.generateNewTopic()
        ↓
        RandomTopicSelector.selectRandom()
        ↓ (category, difficulty)
        TopicGenerationService.generateTopic()
        ↓
        [AI API: OpenAI/Claude/Gemini]
        ↓ (topic text)
        Topic オブジェクト生成
        ↓
        DailyTopicRepository.saveTodayTopic()
        ↓
        [Firestore: daily_topics/{today}]
        ↓
        DebateEventRepository.createEvent() (外部feature)
        ↓
        [Firestore: debate_events/{eventId}]
        ↓
        状態更新 → UI表示
```

### 2. 意見投稿フロー

```
[DailyTopicHomeScreen]
    ↓
ユーザー入力（立場選択、意見入力）
    ↓
opinionPostProvider.postOpinion()
    ↓
Opinion オブジェクト生成（UUID生成）
    ↓
OpinionRepository.postOpinion()
    ↓
[Firestore: opinions/{opinionId}]
    ↓
hasPosted フラグ = true
    ↓
context.go('/opinions/:topicId') (自動遷移)
    ↓
[OpinionListScreen]
    ↓
opinionListProvider.loadOpinions()
    ↓
OpinionRepository.getOpinionsByTopic()
    ↓
[Firestore: opinions (where topicId == {topicId})]
    ↓
意見一覧取得 + 統計計算
    ↓
UI表示
```

### 3. 意見編集フロー

```
[OpinionListScreen]
    ↓
「自分の投稿」アイコンタップ
    ↓
context.push('/my_opinion/:topicId')
    ↓
[MyOpinionDetailScreen]
    ↓
opinionPostProvider.checkUserOpinion()
    ↓
OpinionRepository.getUserOpinion()
    ↓
意見表示
    ↓
「編集」ボタンタップ → 編集モード
    ↓
ユーザー編集（立場、内容）
    ↓
「更新」ボタンタップ
    ↓
opinionPostProvider.updateOpinion()
    ↓
OpinionRepository.updateOpinion()
    ↓
[Firestore: opinions/{opinionId} 更新]
    ↓
成功 → Navigator.pop()
    ↓
[OpinionListScreen]
    ↓
opinionListProvider.refresh() (自動)
    ↓
最新の意見一覧表示
```

### 4. 日付選択フロー（過去のトピック閲覧）

```
[OpinionListScreen]
    ↓
selectedDateProvider 監視中（初期値: 今日）
    ↓
ユーザーが「←」または「→」ボタンタップ
    ↓
selectedDateProvider.setDate(newDate)
    ↓
topicByDateProvider(selectedDate) が自動再評価
    ↓
DailyTopicRepository.getTopicByDate(date)
    ↓
[Firestore: daily_topics/{YYYY-MM-DD}]
    ↓
Topic取得
    ↓
opinionListProvider も自動的に新しい topicId で再評価
    ↓
OpinionRepository.getOpinionsByTopic(topicId)
    ↓
[Firestore: opinions (where topicId == {topicId})]
    ↓
過去の日付のトピック + 意見一覧を表示
```

### 5. リアクション機能フロー

```
[OpinionListScreen]
    ↓
意見カードの「共感」「深い」「新しい視点」ボタンタップ
    ↓
opinionListProvider.toggleReaction(opinionId, type)
    ↓
OpinionRepository.toggleReaction(opinionId, userId, type)
    ↓
[Firestore: opinions/{opinionId}]
    ↓
reactions フィールド更新
    {
      'empathy': ['userId1', 'userId2', ...],
      'thoughtful': ['userId3', ...],
      'newPerspective': ['userId4', ...]
    }
    ↓
opinionListProvider.refresh()
    ↓
更新されたリアクション数を表示
```

---

## ディレクトリ構成

```
lib/feature/home/
├── README.md                              # このファイル
│
├── models/                                # データモデル
│   ├── topic.dart                         # トピックモデル（Freezed）
│   ├── topic.freezed.dart
│   ├── topic.g.dart
│   ├── opinion.dart                       # 意見モデル（Freezed）
│   ├── opinion.freezed.dart
│   ├── opinion.g.dart
│   ├── news_item.dart                     # ニュースモデル（Freezed）
│   ├── news_item.freezed.dart
│   └── news_item.g.dart
│
├── repositories/                          # データ永続化・外部API
│   ├── ai_repository.dart                 # AI API（OpenAI/Claude/Gemini）
│   ├── daily_topic_repository.dart        # 日別トピック Firestore リポジトリ
│   └── opinion_repository.dart            # 意見 Firestore リポジトリ
│
├── services/                              # ビジネスロジック
│   ├── topic_generation_service.dart      # トピック生成サービス
│   ├── topic_classifier_service.dart      # トピック分類サービス
│   ├── topic_difficulty_adjuster.dart     # 難易度調整サービス
│   ├── topic_duplicate_detector.dart      # 重複検出サービス
│   └── news_service.dart                  # ニュース取得サービス
│
├── providers/                             # 状態管理（Riverpod）
│   ├── daily_topic_provider.dart          # 日別トピック状態管理
│   ├── daily_topic_provider.freezed.dart
│   ├── opinion_provider.dart              # 意見投稿・一覧状態管理
│   ├── opinion_provider.freezed.dart
│   ├── topic_generation_provider.dart     # トピック生成プロバイダー
│   ├── topic_generation_state.dart        # トピック生成状態
│   └── topic_generation_state.freezed.dart
│
├── utils/                                 # ユーティリティ
│   └── random_topic_selector.dart         # ランダムセレクター
│
└── presentation/                          # UI
    ├── pages/
    │   ├── daily_topic_home.dart          # メインホーム画面（意見投稿機能含む）
    │   ├── home_answer.dart               # 意見一覧画面（日付選択機能含む）
    │   ├── my_opinion_detail.dart         # 自分の投稿詳細・編集画面
    │   ├── home_aitopic.dart              # AI トピック生成画面（開発用）
    │   ├── home_topic.dart                # トピック表示画面（旧）
    │   └── home.dart                      # ホーム画面（旧）
    └── widgets/
        ├── topic_card.dart                # トピックカードウィジェット
        ├── news_card.dart                 # ニュースカードウィジェット
        ├── news_list.dart                 # ニュース一覧ウィジェット
        └── date_selector_widget.dart      # 日付選択ウィジェット
```

---

## セットアップ

### 1. APIキーの設定

`.env`ファイルを作成し、APIキーを設定してください：

```bash
# .envファイル（プロジェクトルート）
OPENAI_API_KEY=sk-your-openai-api-key-here
ANTHROPIC_API_KEY=sk-ant-your-anthropic-api-key-here
GEMINI_API_KEY=your-gemini-api-key-here
```

**注意**: `.env`ファイルは`.gitignore`に含まれているため、Gitにコミットされません。

### 2. APIキーの取得方法

#### OpenAI API
1. [OpenAI Platform](https://platform.openai.com/)にアクセス
2. アカウントを作成（または既存アカウントでログイン）
3. [API Keys](https://platform.openai.com/api-keys)ページで新しいAPIキーを作成
4. キーをコピーして`.env`ファイルに設定

#### Anthropic API (Claude)
1. [Anthropic Console](https://console.anthropic.com/)にアクセス
2. アカウントを作成（または既存アカウントでログイン）
3. API Keysセクションで新しいAPIキーを作成
4. キーをコピーして`.env`ファイルに設定

#### Google Gemini API
1. [Google AI Studio](https://makersuite.google.com/app/apikey)にアクセス
2. Googleアカウントでログイン
3. 「Get API Key」から新しいAPIキーを作成
4. キーをコピーして`.env`ファイルに設定

### 3. パッケージのインストール

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Firebaseセキュリティルール設定

`firestore.rules`に以下を追加:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 日別トピック
    match /daily_topics/{date} {
      // 認証済みユーザーは読み取り可能
      allow read: if request.auth != null;

      // 認証済みユーザーは書き込み可能（アプリが自動生成するため）
      allow write: if request.auth != null;

      // 管理者のみ書き込み可能にする場合（オプション）
      // allow write: if request.auth != null &&
      //                 get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    // 意見（Opinion）
    match /opinions/{opinionId} {
      // 認証済みユーザーは全ての意見を読み取り可能
      allow read: if request.auth != null;

      // 新規作成: 認証済みユーザーのみ可能
      allow create: if request.auth != null &&
                       request.resource.data.userId == request.auth.uid &&
                       request.resource.data.keys().hasAll(['id', 'topicId', 'topicText', 'userId', 'userName', 'stance', 'content', 'createdAt', 'likeCount', 'isDeleted']);

      // 更新: 自分の投稿のみ可能（stance と content のみ変更可能）
      allow update: if request.auth != null &&
                       resource.data.userId == request.auth.uid &&
                       request.resource.data.userId == resource.data.userId &&
                       request.resource.data.id == resource.data.id &&
                       request.resource.data.topicId == resource.data.topicId;

      // 削除: 自分の投稿のみ論理削除可能
      allow delete: if request.auth != null &&
                       resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 使い方

### メインホーム画面（日別トピック）

#### 基本的な流れ
1. アプリを起動すると自動的に今日のトピックが読み込まれる
2. トピックが存在しない場合、サーバー側で9:00に自動生成される
3. トピックを読んで賛成/反対/中立を選択
4. 100〜3000文字で理由を記述
5. 「意見を投稿する」ボタンで投稿
6. 自動的に意見一覧画面に遷移

#### 手動リロード
- アプリバーの更新ボタンで今日のトピックを再読み込み
- 既に今日のトピックがある場合は同じものが表示される

#### 強制再生成（開発・管理者用）
```dart
// プロバイダーから再生成
await ref.read(dailyTopicProvider.notifier).regenerateTopic();
```

### 意見投稿機能

#### 意見を投稿する
1. **ホーム画面でトピックを確認**: 今日のトピックが自動的に表示される
2. **立場を選択**: 賛成/反対/中立から1つを選択
3. **意見を入力**: テキストフィールドに100〜3000文字で意見を記述
4. **投稿ボタンをタップ**: 確認ダイアログが表示される
5. **確認**: 「投稿する」をタップ
6. **自動遷移**: 投稿完了後、自動的に意見一覧画面に移動

#### 意見一覧を見る
- **自動遷移**: 投稿完了後に自動的に意見一覧画面が開く
- **手動アクセス**: ホーム画面から「みんなの意見を見る」ボタンをタップ
- **統計確認**: 賛成/反対/中立の数と割合を確認
- **意見閲覧**: 他のユーザーの意見をスクロールして閲覧
- **リアクション**: 共感/深い/新しい視点のリアクションを送る
- **リフレッシュ**: 右上の更新ボタンで最新の意見を取得

#### 過去の意見を見る（日付選択機能）
1. **意見一覧画面を開く**: 投稿後の自動遷移、またはホーム画面から手動でアクセス
2. **前日へ移動**: AppBarの左矢印「←」ボタンをタップして前日のトピックと意見を表示
3. **翌日へ移動**: AppBarの右矢印「→」ボタンをタップして翌日のトピックと意見を表示
4. **カレンダーで選択**: AppBarの日付表示（例: 11/12 (火)）をタップしてカレンダーから選択
5. **今日に戻る**: 右矢印を連続でタップ、またはカレンダーから今日を選択

#### 自分の意見を編集する
1. **意見一覧画面を開く**: 投稿後に自動遷移、または手動でアクセス
2. **自分の投稿アイコンをタップ**: 右上のノートアイコン（投稿済みの場合のみ表示）
3. **編集ボタンをタップ**: 右上の「編集」ボタン
4. **内容を変更**: 立場や意見内容を修正
5. **更新ボタンをタップ**: 確認後、変更が保存される
6. **自動反映**: 意見一覧に即座に反映される

### AI トピック生成画面（開発用）

#### ランダム生成
1. 「ランダムに生成」ボタンをタップ
2. AIが自動的にトピックを生成
3. カテゴリと難易度は自動判定

#### カテゴリ指定生成
1. 日常系・社会問題系・価値観系のボタンから選択
2. 選択したカテゴリに適したトピックが生成

#### AIプロバイダーの切り替え
- 右上の設定アイコンから OpenAI、Claude、Gemini を選択
- それぞれの特性に応じたトピック生成が可能

---

## コード例

### 日別トピックの取得

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyarekyara/feature/home/providers/daily_topic_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyTopicProvider);
    final notifier = ref.read(dailyTopicProvider.notifier);

    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    if (state.error != null) {
      return Text('エラー: ${state.error}');
    }

    if (state.currentTopic != null) {
      return TopicCard(topic: state.currentTopic!);
    }

    return ElevatedButton(
      onPressed: () => notifier.generateNewTopic(),
      child: Text('トピックを生成'),
    );
  }
}
```

### 過去のトピックを取得

```dart
final repository = ref.read(dailyTopicRepositoryProvider);
final recentTopics = await repository.getRecentTopics(limit: 30);

for (final topic in recentTopics) {
  print('${topic.createdAt}: ${topic.text}');
}
```

### 意見を投稿する

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyarekyara/feature/home/providers/opinion_provider.dart';
import 'package:tyarekyara/feature/home/models/opinion.dart';

class OpinionFormWidget extends ConsumerWidget {
  final String topicId;
  final String topicText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(opinionPostProvider(topicId));
    final postNotifier = ref.read(opinionPostProvider(topicId).notifier);

    return ElevatedButton(
      onPressed: postState.isPosting ? null : () async {
        final success = await postNotifier.postOpinion(
          topicText: topicText,
          stance: OpinionStance.agree,
          content: 'これは私の意見です...',
        );

        if (success) {
          // 投稿成功 - 自動的に意見一覧画面に遷移
          print('投稿完了！');
        } else {
          // エラー処理
          print('エラー: ${postState.error}');
        }
      },
      child: Text(postState.isPosting ? '投稿中...' : '意見を投稿'),
    );
  }
}
```

### 意見一覧を表示する

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyarekyara/feature/home/providers/opinion_provider.dart';

class OpinionListWidget extends ConsumerWidget {
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(opinionListProvider(topicId));

    if (listState.isLoading) {
      return CircularProgressIndicator();
    }

    if (listState.error != null) {
      return Text('エラー: ${listState.error}');
    }

    return ListView.builder(
      itemCount: listState.opinions.length,
      itemBuilder: (context, index) {
        final opinion = listState.opinions[index];
        return ListTile(
          title: Text(opinion.userName),
          subtitle: Text(opinion.content),
          leading: Icon(
            opinion.stance == OpinionStance.agree
                ? Icons.thumb_up
                : opinion.stance == OpinionStance.disagree
                    ? Icons.thumb_down
                    : Icons.horizontal_rule,
          ),
        );
      },
    );
  }
}
```

### 意見にリアクションを送る

```dart
final listNotifier = ref.read(opinionListProvider(topicId).notifier);

// 共感リアクションを送る
await listNotifier.toggleReaction(opinionId, ReactionType.empathy);

// 「深い」リアクションを送る
await listNotifier.toggleReaction(opinionId, ReactionType.thoughtful);

// 「新しい視点」リアクションを送る
await listNotifier.toggleReaction(opinionId, ReactionType.newPerspective);
```

### 意見を編集する

```dart
final postNotifier = ref.read(opinionPostProvider(topicId).notifier);

final success = await postNotifier.updateOpinion(
  stance: OpinionStance.neutral,
  content: '意見を変更しました...',
);

if (success) {
  print('更新完了！');
  // 意見一覧を更新
  ref.read(opinionListProvider(topicId).notifier).refresh();
}
```

### 投稿済みかチェックする

```dart
final postState = ref.watch(opinionPostProvider(topicId));

if (postState.hasPosted) {
  print('既に投稿済みです');
  print('あなたの立場: ${postState.userOpinion?.stance.displayName}');
} else {
  print('まだ投稿していません');
}
```

### 日付選択機能を使用する

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tyarekyara/feature/home/providers/daily_topic_provider.dart';

class DateSelectorWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final topicAsync = ref.watch(topicByDateProvider(selectedDate));

    return Column(
      children: [
        // 日付表示
        Text(
          DateFormat('M/d (E)', 'ja').format(selectedDate),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        // 前日へ移動
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            final previousDay = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day - 1,
            );
            ref.read(selectedDateProvider.notifier).setDate(previousDay);
          },
        ),

        // トピック表示
        topicAsync.when(
          data: (topic) {
            if (topic == null) {
              return Text('この日のトピックはありません');
            }
            return TopicCard(topic: topic);
          },
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => Text('エラー: $error'),
        ),
      ],
    );
  }
}
```

### カレンダーピッカーで日付を選択する

```dart
Future<void> _showDatePicker(BuildContext context, WidgetRef ref) async {
  final currentDate = ref.read(selectedDateProvider);
  final today = DateTime.now();

  final selectedDate = await showDatePicker(
    context: context,
    initialDate: currentDate,
    firstDate: DateTime(2020, 1, 1),
    lastDate: today,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue.shade600,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      );
    },
  );

  if (selectedDate != null) {
    ref.read(selectedDateProvider.notifier).setDate(selectedDate);
  }
}
```

### AIプロバイダーの切り替え

```dart
// OpenAI を使用
ref.read(aiProviderProvider.notifier).update(AIProvider.openai);

// Claude を使用
ref.read(aiProviderProvider.notifier).update(AIProvider.claude);

// Gemini を使用
ref.read(aiProviderProvider.notifier).update(AIProvider.gemini);
```

---

## トラブルシューティング

### トピックが生成されない

1. `.env`ファイルにAPIキーが正しく設定されているか確認
2. APIキーが有効か確認（課金設定など）
3. Firebaseプロジェクトの設定を確認
4. インターネット接続を確認
5. API利用制限（レート制限）に達していないか確認
6. コンソールでエラーログを確認

### 同じトピックが何度も表示される

**これは正常な動作です！**
- 1日1回のみ新しいトピックが生成されます
- 日付が変わるまで同じトピックが表示されます
- 強制的に再生成したい場合は、`regenerateTopic()` を使用

### APIエラーが発生する場合

1. APIキーの有効性を確認
2. APIの利用制限を確認
3. リクエストレート制限を確認
4. ネットワークエラーの場合は接続を確認

### ビルドエラーが発生する場合

```bash
# キャッシュをクリアして再ビルド
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firestore接続エラー

1. Firebaseプロジェクトの設定を確認
2. `google-services.json`（Android）と`GoogleService-Info.plist`（iOS）が正しく配置されているか確認
3. Firestoreのセキュリティルールを確認
4. Firebase Consoleでプロジェクトが有効化されているか確認

### 重複検出が正しく動作しない場合

類似度の閾値を調整: `TopicDuplicateDetector`の`isDuplicate`メソッドの`threshold`パラメータ（デフォルト0.8）

### 意見が投稿できない場合

1. **認証状態を確認**: ユーザーがログインしているか確認
2. **Firestoreのセキュリティルール**: `opinions`コレクションのルールが正しく設定されているか確認
3. **ネットワーク接続**: インターネット接続を確認
4. **エラーメッセージ**: コンソールで詳細なエラーログを確認
5. **投稿済みフラグ**: 既に投稿済みの場合は再投稿できない（編集機能を使用）

### 意見一覧が表示されない場合

1. **トピックID**: 正しいトピックIDが渡されているか確認
2. **Firestore接続**: Firestoreに正しく接続されているか確認
3. **データ存在確認**: Firebase Consoleで`opinions`コレクションにデータが存在するか確認
4. **セキュリティルール**: 読み取り権限が正しく設定されているか確認

### 意見が編集できない場合

1. **所有権確認**: 自分の投稿のみ編集可能
2. **hasPostedフラグ**: `hasPosted`が`true`であることを確認
3. **userOpinion**: `postState.userOpinion`が`null`でないことを確認
4. **セキュリティルール**: 更新権限が正しく設定されているか確認

### 自動遷移が動作しない場合

1. **ルーティング設定**: `/opinions/:topicId`のルートが正しく設定されているか確認
2. **go_router**: `go_router`パッケージが正しくインストールされているか確認
3. **hasPosted**: 投稿後に`hasPosted`が`true`に更新されているか確認
4. **context.go()**: `WidgetsBinding.instance.addPostFrameCallback`が正しく呼ばれているか確認

### 日付選択機能が動作しない場合

1. **DatePicker エラー**:
   - `MaterialLocalizations`エラーが発生した場合は、`showDatePicker`の`locale`パラメータを削除
   - アプリ全体のローカライゼーション設定を確認

2. **日付が変更されない**:
   - `selectedDateProvider.notifier.setDate()`が正しく呼ばれているか確認
   - Riverpod DevToolsで状態の変更を確認

3. **過去のトピックが表示されない**:
   - `topicByDateProvider`が正しく動作しているか確認
   - Firestoreの`daily_topics`コレクションにデータが存在するか確認（日付キー: YYYY-MM-DD形式）
   - `DailyTopicRepository.getTopicByDate()`メソッドが正しく実装されているか確認

4. **カレンダーが開かない**:
   - `showDatePicker`が正しく呼ばれているか確認
   - `context`が有効か確認
   - エラーログを確認

5. **日付フォーマットが表示されない**:
   - `intl`パッケージがインストールされているか確認: `flutter pub get`
   - `DateFormat`のインポートが正しいか確認: `import 'package:intl/intl.dart';`

### リアクション機能が動作しない場合

1. **リアクションが保存されない**:
   - Firestoreのセキュリティルールで`reactions`フィールドの更新が許可されているか確認
   - `OpinionRepository.toggleReaction()`が正しく実装されているか確認

2. **リアクション数が表示されない**:
   - `Opinion`モデルの`reactions`フィールドが正しく取得されているか確認
   - UIでリアクション数の計算ロジックを確認

---

## 今後の拡張予定

### 日別トピック機能
- [ ] トピックのお気に入り機能
- [ ] ユーザーがトピックをリクエストできる機能
- [ ] トピックの共有機能（SNS連携）
- [ ] 過去のトピック一覧表示
- [ ] プッシュ通知での新トピック通知（朝9時など）
- [ ] トピックの難易度フィルター
- [ ] カテゴリー別のトピック表示

### 意見投稿・一覧機能
- [x] 日付選択機能（過去の意見閲覧） - **完成**
- [x] リアクション機能（共感/深い/新しい視点） - **完成**
- [ ] いいね機能の実装
- [ ] コメント機能（意見に対する返信）
- [ ] 意見の検索・フィルター機能
- [ ] 立場別の意見ソート
- [ ] 人気の意見ランキング
- [ ] 意見の共有機能（SNS連携）
- [ ] 通知機能（自分の意見にリアクションが付いた時など）
- [ ] ブックマーク機能
- [ ] レポート機能（不適切な投稿の報告）
- [ ] 意見の履歴表示（自分の過去の投稿一覧）
- [ ] AIによる意見分析・要約機能
- [ ] 議論の可視化（立場の分布グラフなど）
- [ ] 日付選択機能の拡張（月別カレンダービュー）
- [ ] 日付選択機能の拡張（週別ビュー）

### AI生成機能
- [ ] カスタムプロンプト機能
- [ ] バッチ生成機能（複数トピックを一括生成）
- [ ] 多言語対応
- [ ] トピック生成履歴の永続化
- [ ] ユーザー設定の永続化
- [ ] A/Bテスト用の複数トピック生成

---

## 参考リンク

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod ドキュメント](https://riverpod.dev/)
- [Freezed ドキュメント](https://pub.dev/packages/freezed)
- [Cloud Firestore ドキュメント](https://firebase.google.com/docs/firestore)
- [Go Router ドキュメント](https://pub.dev/packages/go_router)
- [OpenAI API ドキュメント](https://platform.openai.com/docs/)
- [Anthropic API ドキュメント](https://docs.anthropic.com/)
- [Google Gemini API ドキュメント](https://ai.google.dev/docs)

---

## ライセンス

このプロジェクトの一部です。

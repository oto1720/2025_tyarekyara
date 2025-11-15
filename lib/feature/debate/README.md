# ディベート機能 仕様書

## 📋 目次

1. [概要](#概要)
2. [機能一覧](#機能一覧)
3. [アーキテクチャ](#アーキテクチャ)
4. [データモデル](#データモデル)
5. [ディベートフロー](#ディベートフロー)
6. [AI判定システム](#ai判定システム)
7. [ゲーミフィケーション](#ゲーミフィケーション)
8. [Firestoreスキーマ](#firestoreスキーマ)
9. [Cloud Functions](#cloud-functions)
10. [画面一覧](#画面一覧)
11. [開発ガイド](#開発ガイド)

---

## 概要

ディベート機能は、ユーザーが特定のトピックについて賛成・反対に分かれて議論を行い、AIによる公平な判定を受けることができる機能です。

### 主な特徴

- 📅 **定期開催**: 週2-3回の定期イベント
- 🤖 **AI判定**: Gemini 1.5 Flashによる5項目評価
- 🎮 **ゲーミフィケーション**: ポイント、レベル、バッジシステム
- 👥 **チーム制**: 2対2のチーム戦
- ⏱️ **時間制限**: 5分/10分/15分の選択式
- 📊 **統計機能**: 詳細な成績・ランキング表示

---

## 機能一覧

### 1. イベント管理
- ✅ イベント一覧表示（開催予定・終了済み）
- ✅ イベント詳細確認
- ✅ エントリー登録

### 2. マッチング
- ✅ 設定選択（時間、形式、立場）
- ✅ 自動マッチング
- ✅ マッチング成功通知
- ✅ マッチ詳細表示

### 3. ディベート実行
- ✅ 12フェーズの進行管理
- ✅ リアルタイムチャット（公開・チーム内）
- ✅ タイマー表示
- ✅ フェーズインジケーター

### 4. AI判定
- ✅ 自動判定（ディベート終了時）
- ✅ 5項目評価（論理性、根拠、反論力、説得力、マナー）
- ✅ MVP選出
- ✅ チーム別フィードバック

### 5. ゲーミフィケーション
- ✅ ポイントシステム
- ✅ レベルアップ
- ✅ バッジ獲得
- ✅ ランキング（ポイント・勝率・参加数）
- ✅ 統計表示

---

## アーキテクチャ

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (Dart)                    │
├─────────────────────────────────────────────────────────┤
│  Presentation Layer                                      │
│  ├─ Pages (UI Screens)                                  │
│  ├─ Widgets (Reusable Components)                       │
│  └─ Providers (Riverpod State Management)              │
├─────────────────────────────────────────────────────────┤
│  Domain Layer                                            │
│  ├─ Models (Freezed Data Classes)                       │
│  └─ Repositories (Data Access)                          │
└─────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────┐
│                 Firebase Services                        │
├─────────────────────────────────────────────────────────┤
│  Firestore (Database)                                    │
│  ├─ debate_events                                       │
│  ├─ debate_matches                                      │
│  ├─ debate_rooms                                        │
│  ├─ debate_judgments                                    │
│  ├─ user_debate_stats                                   │
│  └─ debate_rankings                                     │
├─────────────────────────────────────────────────────────┤
│  Cloud Functions (Node.js/TypeScript)                   │
│  ├─ onDebateComplete (Firestore Trigger)               │
│  └─ manualJudgeDebate (HTTPS Callable)                 │
├─────────────────────────────────────────────────────────┤
│  Vertex AI (Gemini 1.5 Flash)                           │
│  └─ AI Judgment Service                                 │
└─────────────────────────────────────────────────────────┘
```

### 技術スタック

**フロントエンド:**
- Flutter 3.x
- Riverpod (状態管理)
- Freezed (イミュータブルモデル)
- fl_chart (グラフ表示)
- go_router (ルーティング)

**バックエンド:**
- Firebase Firestore (データベース)
- Cloud Functions v2 (サーバーレス)
- Vertex AI API (AI判定)

---

## データモデル

### 主要モデル

#### 1. DebateEvent (イベント)
```dart
class DebateEvent {
  String id;
  String topic;              // トピック
  String description;        // 説明
  DateTime scheduledAt;      // 開催日時
  EventStatus status;        // ステータス
  List<DebateDuration> allowedDurations;  // 許可された時間
  List<DebateFormat> allowedFormats;      // 許可された形式
}
```

#### 2. DebateMatch (マッチ)
```dart
class DebateMatch {
  String id;
  String eventId;
  DebateTeam proTeam;        // 賛成チーム
  DebateTeam conTeam;        // 反対チーム
  DebateDuration duration;   // 制限時間
  DebateFormat format;       // 形式
  MatchStatus status;        // ステータス
}
```

#### 3. DebateRoom (ルーム)
```dart
class DebateRoom {
  String id;
  String matchId;
  DebatePhase currentPhase;  // 現在のフェーズ
  DateTime phaseStartedAt;   // フェーズ開始時刻
  RoomStatus status;         // ステータス
}
```

#### 4. JudgmentResult (判定結果)
```dart
class JudgmentResult {
  String id;
  TeamScore proTeamScore;    // 賛成チームスコア
  TeamScore conTeamScore;    // 反対チームスコア
  DebateStance? winningSide; // 勝利チーム (null=引き分け)
  String? mvpUserId;         // MVP
  String overallComment;     // 全体講評
  String proTeamComment;     // 賛成チームコメント
  String conTeamComment;     // 反対チームコメント
}

class TeamScore {
  int logicScore;           // 論理性 (0-10)
  int evidenceScore;        // 根拠 (0-10)
  int rebuttalScore;        // 反論力 (0-10)
  int persuasivenessScore;  // 説得力 (0-10)
  int mannerScore;          // マナー (0-10)
  int totalScore;           // 合計 (0-50)
}
```

#### 5. UserDebateStats (統計)
```dart
class UserDebateStats {
  String userId;
  int totalDebates;          // 総参加数
  int wins;                  // 勝利数
  int losses;                // 敗北数
  int draws;                 // 引き分け数
  int totalPoints;           // 総ポイント
  int level;                 // レベル
  int currentLevelPoints;    // 現在レベルのポイント
  int pointsToNextLevel;     // 次レベルまでのポイント
  int mvpCount;              // MVP獲得数
  List<EarnedBadge> earnedBadges;  // 獲得バッジ
}
```

---

## ディベートフロー

### フェーズ構成（12フェーズ）

| フェーズ | 名称 | 時間 | 説明 |
|---------|------|------|------|
| 1 | 準備 | 1分 | 作戦会議 |
| 2 | 立論（賛成） | 2分 | 賛成側の主張 |
| 3 | 立論（反対） | 2分 | 反対側の主張 |
| 4 | 質疑応答準備（賛成） | 30秒 | 質問準備 |
| 5 | 質疑応答（賛成へ） | 1分 | 反対→賛成への質問 |
| 6 | 質疑応答準備（反対） | 30秒 | 質問準備 |
| 7 | 質疑応答（反対へ） | 1分 | 賛成→反対への質問 |
| 8 | 反論準備（賛成） | 30秒 | 反論準備 |
| 9 | 反論（賛成） | 1.5分 | 賛成側の反論 |
| 10 | 反論準備（反対） | 30秒 | 反論準備 |
| 11 | 反論（反対） | 1.5分 | 反対側の反論 |
| 12 | 最終主張 | 各1分 | 両チームの総括 |

### 状態遷移

```
イベント作成 → エントリー受付 → マッチング
    ↓
マッチ成立 → ルーム作成 → ディベート実行
    ↓
完了 → AI判定中 → 判定完了 → 結果表示
    ↓
統計更新 → ランキング更新
```

---

## AI判定システム

### 評価基準（各10点満点）

1. **論理性** (Logic)
   - 主張の論理的整合性
   - 因果関係の明確さ

2. **根拠・証拠** (Evidence)
   - 具体例やデータの提示
   - 証拠の信頼性

3. **反論力** (Rebuttal)
   - 相手の主張への効果的な反論
   - 対応の的確さ

4. **説得力** (Persuasiveness)
   - 表現の明確さ
   - 聴衆を納得させる力

5. **マナー** (Manner)
   - 礼儀正しさ
   - 冷静さ

### AI判定プロセス

```typescript
1. ディベート終了時、Firestoreトリガー発動
   ↓
2. 全メッセージを取得・フェーズ別に分類
   ↓
3. Gemini 1.5 Flashへプロンプト送信
   ↓
4. JSON形式で5項目評価 + コメント受信
   ↓
5. Firestoreに判定結果を保存
   ↓
6. マッチステータスを更新
   ↓
7. ユーザー統計を更新
```

### プロンプト構造

```
あなたはディベート審判です。以下のディベートを公平に判定してください。

## ディベートトピック
{topic}

## ディベート内容
### 立論フェーズ（賛成）
{messages}
...

## 評価基準（各項目10点満点）
1. 論理性
2. 根拠・証拠
3. 反論力
4. 説得力
5. マナー

## 出力形式
JSON形式で判定結果を返してください
```

### コスト見積もり

- **モデル**: Gemini 1.5 Flash
- **入力**: 約2,000文字 = $0.25
- **出力**: 約500文字 = $0.19
- **合計**: 約$0.44/判定

---

## ゲーミフィケーション

### ポイントシステム

| アクション | 獲得ポイント |
|----------|------------|
| 参加 | 10pt |
| 勝利 | 30pt |
| 引き分け | 15pt |
| MVP獲得 | 50pt |
| 満点評価項目 | 20pt |
| 連勝ボーナス | 10pt × 連勝数 |

### レベルシステム

| レベル | 称号 | 必要ポイント | カラー |
|-------|------|------------|--------|
| 1-4 | 初心者 | 0-400 | Green |
| 5-9 | 中級者 | 400-900 | Blue |
| 10-19 | 上級者 | 900-1900 | Purple |
| 20-29 | エキスパート | 1900-2900 | Orange |
| 30-39 | マスター | 2900-3900 | Red |
| 40+ | レジェンド | 3900+ | Gold |

### バッジシステム

| バッジ | 条件 | アイコン |
|-------|------|---------|
| はじめの一歩 | 初参加 | 🚩 |
| 10回達成 | 10回参加 | 🏆 |
| 初勝利 | 初勝利 | ⭐ |
| 10勝達成 | 10勝 | 🎖️ |
| 連勝記録 | 3連勝 | 🔥 |
| 完璧な論理 | 満点項目獲得 | 💎 |
| MVP獲得 | MVP獲得 | 👑 |
| 皆勤賞 | 1週間連続参加 | 🎉 |

### ランキング

1. **ポイントランキング**: 総獲得ポイント順
2. **勝率ランキング**: 勝率順（最低10試合）
3. **参加数ランキング**: 参加回数順

---

## Firestoreスキーマ

### debate_events
```
/debate_events/{eventId}
  - id: string
  - topic: string
  - description: string
  - scheduledAt: timestamp
  - status: string (scheduled/active/completed/cancelled)
  - allowedDurations: array<string>
  - allowedFormats: array<string>
  - createdAt: timestamp
  - updatedAt: timestamp
```

### debate_matches
```
/debate_matches/{matchId}
  - id: string
  - eventId: string
  - proTeam: {
      memberIds: array<string>
      stance: "pro"
    }
  - conTeam: {
      memberIds: array<string>
      stance: "con"
    }
  - duration: string (five/ten/fifteen)
  - format: string (standard/quick)
  - status: string (matching/matched/inProgress/completed)
  - createdAt: timestamp
  - startedAt: timestamp?
  - completedAt: timestamp?
```

### debate_rooms
```
/debate_rooms/{roomId}
  - id: string
  - matchId: string
  - eventId: string
  - currentPhase: string
  - phaseStartedAt: timestamp
  - status: string (waiting/active/completed)
  - createdAt: timestamp

  /messages (subcollection)
    /{messageId}
      - userId: string
      - content: string
      - type: string (public/team)
      - phase: string
      - createdAt: timestamp
```

### debate_judgments
```
/debate_judgments/{judgmentId}
  - id: string
  - matchId: string
  - roomId: string
  - eventId: string
  - winningSide: string? (pro/con/null)
  - proTeamScore: {
      logicScore: number
      evidenceScore: number
      rebuttalScore: number
      persuasivenessScore: number
      mannerScore: number
      totalScore: number
    }
  - conTeamScore: { ... }
  - mvpUserId: string?
  - overallComment: string
  - proTeamComment: string
  - conTeamComment: string
  - judgedAt: timestamp
  - createdAt: timestamp
```

### user_debate_stats
```
/user_debate_stats/{userId}
  - userId: string
  - totalDebates: number
  - wins: number
  - losses: number
  - draws: number
  - totalPoints: number
  - level: number
  - currentLevelPoints: number
  - pointsToNextLevel: number
  - mvpCount: number
  - earnedBadges: array<object>
  - createdAt: timestamp
  - updatedAt: timestamp
```

### debate_rankings
```
/debate_rankings/{rankingType}/users/{userId}
  - userId: string
  - userName: string
  - rank: number
  - value: number
  - level: number
  - updatedAt: timestamp

rankingType: total_points | win_rate | participation
```

---

## Cloud Functions

### 1. onDebateComplete

**トリガー**: Firestore `debate_rooms/{roomId}` の更新
**条件**: `status` が `completed` に変更された時
**処理**:
1. イベント情報を取得
2. ディベートメッセージを取得
3. AI判定を実行
4. 判定結果を保存
5. マッチステータスを更新

```typescript
export const onDebateComplete = onDocumentUpdated(
  { document: "debate_rooms/{roomId}", region: "asia-northeast1" },
  async (event) => {
    // AI判定処理
  }
);
```

### 2. manualJudgeDebate

**トリガー**: HTTPSコール
**用途**: デバッグ・手動判定
**認証**: 必須

```typescript
export const manualJudgeDebate = onCall(
  { region: "asia-northeast1" },
  async (request) => {
    const {roomId} = request.data;
    const judgment = await judgeDebate(roomId, eventTopic);
    return { success: true, judgment };
  }
);
```

---

## 画面一覧

### 1. イベント一覧画面
**Path**: `/debate`
**ファイル**: `debate_event_list_page.dart`

- タブ（開催予定・終了済み）
- イベントカード表示
- プルリフレッシュ

### 2. イベント詳細画面
**Path**: `/debate/event/:eventId`
**ファイル**: `debate_event_detail_page.dart`

- SliverAppBar
- トピック・説明表示
- エントリーボタン

### 3. エントリー画面
**Path**: `/debate/event/:eventId/entry`
**ファイル**: `debate_entry_page.dart`

- 設定フォーム（時間・形式・立場）
- エントリー送信

### 4. 待機画面
**Path**: `/debate/event/:eventId/waiting`
**ファイル**: `debate_waiting_room_page.dart`

- マッチング状態表示
- エントリー一覧
- 自動遷移

### 5. マッチ詳細画面
**Path**: `/debate/match/:matchId`
**ファイル**: `debate_match_detail_page.dart`

- チーム情報表示
- マッチ設定確認
- 開始ボタン

### 6. ディベートルーム画面
**Path**: `/debate/room/:matchId`
**ファイル**: `debate_room_page.dart`

- フェーズインジケーター
- タイマー表示
- チャット（公開・チーム内）
- チーム情報

### 7. AI判定待機画面
**Path**: `/debate/judgment/:matchId`
**ファイル**: `debate_judgment_waiting_page.dart`

- AI判定進行状況
- ローディングアニメーション
- 自動遷移

### 8. 結果画面
**Path**: `/debate/result/:matchId`
**ファイル**: `debate_result_page.dart`

- 勝敗表示
- スコア比較
- レーダーチャート
- MVP表示
- AIコメント

### 9. ランキング画面
**Path**: `/debate/ranking`
**ファイル**: `debate_ranking_page.dart`

- 3つのタブ（ポイント・勝率・参加数）
- トップ3表示
- 自分の順位

### 10. 統計画面
**Path**: `/debate/stats`
**ファイル**: `debate_stats_page.dart`

- レベル進行度
- 総合統計
- 円グラフ（勝敗分布）
- ポイント内訳
- バッジコレクション

---

## 開発ガイド

### セットアップ

1. **依存関係インストール**
```bash
flutter pub get
```

2. **コード生成**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **Cloud Functionsセットアップ**
```bash
cd functions
npm install
npm install @google-cloud/vertexai
```

4. **デプロイ**
```bash
firebase deploy --only functions
```

### 新機能追加の手順

#### 1. モデル追加
```bash
# models/ にFreezedクラスを作成
# build_runner で生成
flutter pub run build_runner build
```

#### 2. Repository追加
```bash
# repositories/ にリポジトリクラスを作成
# Firestoreアクセスロジックを実装
```

#### 3. Provider追加
```bash
# providers/ にRiverpod Providerを作成
# Repositoryを利用したデータ取得
```

#### 4. UI追加
```bash
# pages/ または widgets/ に画面・コンポーネント作成
# Providerを利用して状態管理
```

#### 5. ルーティング追加
```bash
# app_router.dart にルート追加
```

### テスト

#### 手動判定のテスト
```dart
final functions = FirebaseFunctions.instanceFor(
  region: 'asia-northeast1'
);

final result = await functions
    .httpsCallable('manualJudgeDebate')
    .call({'roomId': 'test-room-id'});
```

#### エミュレータ使用
```bash
firebase emulators:start
```

### デバッグ

#### Firestoreデータ確認
```
Firebase Console → Firestore Database
```

#### Cloud Functionsログ確認
```bash
firebase functions:log --only onDebateComplete
```

#### Flutter DevTools
```bash
flutter run
# DevToolsでRiverpod状態確認
```

---

## トラブルシューティング

### よくある問題

#### 1. Freezedエラー
```bash
# 解決: コード再生成
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. Provider not found
```bash
# 解決: Providerのimport確認
import '../providers/debate_event_provider.dart';
```

#### 3. AI判定が動かない
```bash
# 確認事項:
# - Vertex AI APIが有効か
# - Cloud Functionsがデプロイされているか
# - Firestoreトリガーが動作しているか
```

#### 4. ランキングが表示されない
```bash
# 確認事項:
# - user_debate_statsが更新されているか
# - debate_rankingsコレクションが存在するか
# - Repositoryメソッドが正しく実装されているか
```

---

## データフロー詳細

### エンドツーエンドのデータフロー

#### 1. イベント参加からマッチング

```
ユーザー操作: イベント詳細画面で「参加」タップ
    ↓
DebateEntryPage表示
    ↓
ユーザーが設定選択（時間・形式・立場）
    ↓
_submitEntry() 実行:
  1. DebateEntryオブジェクト作成
  2. repository.createEntry()
  3. Firestore: debate_entries/{eventId}_{userId} 作成
  4. repository.getEntryCount() でエントリー数取得
  5. eventRepository.updateParticipantCount() で参加者数更新
    ↓
自動遷移: /debate/event/{eventId}/waiting
    ↓
DebateWaitingRoomPage表示:
  - userEntryProvider((eventId, userId)) を監視
  - entry.status が waiting → matched に変わるまで待機
    ↓
Cloud Function (バックエンド) がマッチング実行:
  1. debate_matches/{matchId} 作成
  2. debate_entries/{entryId}.matchId 更新
    ↓
userEntryProvider がストリームで変更検知
    ↓
自動遷移: /debate/match/{matchId}
```

#### 2. ディベート実行からAI判定

```
DebateRoomPage表示:
  - matchDetailProvider(matchId) でマッチ取得
  - debateRoomByMatchProvider(matchId) でルーム取得
  - room.participantStances[userId] で自分の立場確認
    ↓
ユーザーがメッセージ送信:
  DebateChatWidget._sendMessage():
    1. DebateMessageオブジェクト作成
    2. repository.sendMessage()
    3. Firestore: debate_rooms/{roomId}/messages/{messageId} 作成
    4. roomMessagesProvider がストリームで新メッセージ受信
    5. UI自動更新
    ↓
各フェーズが進行（preparation → opening → question → rebuttal → closing）
    ↓
最終フェーズ終了:
  - room.status → RoomStatus.judging
  - room.currentPhase → DebatePhase.judgment
    ↓
Cloud Function onDebateComplete トリガー:
  1. debate_rooms/{roomId}/messages 全取得
  2. Vertex AI (Gemini) で判定実行
  3. JudgmentResult作成
  4. Firestore: debate_judgments/{judgmentId} 保存
  5. debate_matches/{matchId} 更新（status: completed, winningSide設定）
  6. user_debate_stats/{userId} 更新（勝敗・ポイント・レベル）
  7. debate_rankings/{type}/users/{userId} 更新
    ↓
DebateJudgmentWaitingPage:
  - judgmentResultProvider(matchId) でポーリング
  - 判定結果が保存されると検知
    ↓
自動遷移: /debate/result/{matchId}
    ↓
DebateResultPage表示:
  - 勝者表示
  - 詳細スコア（5項目）
  - チャート（レーダー・棒グラフ）
  - MVP表示
  - AIコメント
```

### リアルタイムストリーム一覧

| Provider | データソース | 更新トリガー |
|----------|------------|------------|
| `eventDetailProvider(eventId)` | watchEvent(eventId) | イベント情報更新時 |
| `upcomingEventsProvider` | watchUpcomingEvents() | 新イベント追加時 |
| `userEntryProvider({eventId, userId})` | watchUserEntry() | エントリー状態変更・マッチID割り当て時 |
| `matchDetailProvider(matchId)` | watchMatch(matchId) | マッチ状態変更時 |
| `roomDetailProvider(roomId)` | watchRoom(roomId) | フェーズ変更・タイマー更新時 |
| `roomMessagesProvider(roomId)` | watchMessages(roomId) | 新メッセージ投稿時 |
| `teamMessagesProvider(roomId)` | watchMessages(roomId, type: team) | チームメッセージ投稿時 |
| `userStatsProvider(userId)` | watchUserStats(userId) | 統計更新時 |

---

## ユーザーアクションフロー

### アクション1: イベントエントリー

```
1. ユーザーが DebateEventDetailPage(eventId) を開く
2. eventDetailProvider(eventId) からイベント情報取得
3. 「参加」ボタンタップ
4. DebateEntryPage(eventId) に遷移
5. フォーム表示（時間・形式・立場選択）
6. 送信ボタンタップ
7. _submitEntry() 実行:
   a. DebateEntry作成（status: waiting）
   b. repository.createEntry() → debate_entries/{eventId}_{userId}
   c. repository.getEntryCount() → 待機中エントリー数取得
   d. eventRepository.updateParticipantCount() → イベント参加者数更新
8. 成功 → pushReplacement('/debate/event/{eventId}/waiting')
9. DebateWaitingRoomPage表示
```

### アクション2: マッチング待機

```
1. DebateWaitingRoomPage マウント
2. userEntryProvider((eventId, userId)) 監視開始
3. エントリー設定表示（選択した時間・形式・立場）
4. 待機タイマー開始（1秒ごとに増加）
5. entry.status の変化を監視（waiting → matched）
6. entry.matchId が割り当てられたら:
   a. ストリームで変更検知
   b. pushReplacementNamed('/debate/match/{matchId}')
7. DebateMatchDetailPage に遷移
```

### アクション3: ディベート開始

```
1. DebateMatchDetailPage でマッチ詳細表示
2. 対戦相手情報表示
3. 「開始」ボタンタップ
4. push('/debate/room/{matchId}')
5. DebateRoomPage ロード:
   a. matchDetailProvider(matchId) → DebateMatch取得
   b. debateRoomByMatchProvider(matchId) → DebateRoom取得
   c. room.participantStances[userId] → 自分の立場取得
6. UI表示:
   - 現在フェーズ（例: "Opening Pro", "Rebuttal Con"）
   - フェーズタイマー（残り秒数）
   - タブ: 公開チャット | チーム内チャット
7. ルームヘッダー:
   - 賛成チーム vs 反対チーム
   - チームメンバー数
   - 自分のチームをハイライト
```

### アクション4: メッセージ送信

```
1. メッセージ入力フィールドにフォーカス
2. メッセージ入力（最大200文字、レート制限あり）
3. 送信タップ
4. DebateChatWidget._sendMessage():
   a. DebateMessageオブジェクト作成:
      - id: UUID
      - roomId, userId
      - content: 入力テキスト
      - type: MessageType.public または .team
      - phase: 現在のフェーズ
      - status: MessageStatus.sent
      - createdAt: now
   b. repository.sendMessage() 呼び出し
   c. Firestore書き込み: debate_rooms/{roomId}/messages/{messageId}
5. watchMessages ストリームで新メッセージ受信
6. 全参加者が公開メッセージを閲覧
7. チームメンバーのみチャットを閲覧
8. messageCount[userId] 増加
9. 不適切コンテンツ検出時 → isWarning=true、システムがフラグ
```

### アクション5: 判定待機と結果表示

```
1. 最終フェーズ（closingCon）タイムアウト
2. room.status → RoomStatus.judging
3. currentPhase → DebatePhase.judgment
4. Cloud Function トリガー（バックエンド）:
   - roomId
   - matchId
   - debate_rooms/{roomId}/messages 全メッセージ
   - participantStances からチーム割り当て
5. AI判定実行
6. JudgmentResult作成:
   - 5項目でスコアリング（pro/con）
   - MVP選出
   - コメント生成
   - debate_judgments/{judgmentId} に保存
7. room.judgmentId 更新
8. DebateJudgmentWaitingPage:
   - judgmentResultProvider(matchId) でポーリング
   - 判定発見 → pushReplacementNamed('/debate/result/{matchId}')
9. DebateResultPage表示:
   a. 勝者バナー（pro/con/引き分け）
   b. 合計スコア（pro vs con）
   c. 詳細スコア（論理性・根拠・反論・説得力・マナー）
   d. チャート（レーダー・棒グラフ）
   e. MVPセクション（mvpUserId存在時）
   f. AIコメント
10. 「ホーム」タップ → popUntil(isFirst)
```

### アクション6: 統計確認

```
1. DebateStatsPage マウント
2. authControllerProvider から userId 取得
3. userDebateStatsProvider(userId) 監視
4. 表示:
   - レベル進捗ウィジェット（currentLevelPoints / pointsToNextLevel）
   - 総合統計: totalDebates, wins, losses, draws, totalPoints, mvpCount
   - 円グラフ: 勝敗分布
   - ポイント内訳（推定）
   - バッジグリッド（獲得バッジ）
5. リフレッシュアイコンタップ → ref.invalidate(provider)
```

### アクション7: ランキング閲覧

```
1. DebateRankingPage 表示
2. 3タブ: ポイント | 勝率 | 参加数
3. 各タブでランキングプロバイダー監視:
   - pointsRankingProvider
   - winRateRankingProvider
   - participationRankingProvider
4. debate_rankings/{type}/users から取得
5. 表示:
   - 上部: ユーザーのランクカード（トップ100内の場合）
   - 下部: 全ランキングリスト
   - トップ3にメダル表示（金・銀・銅）
6. 各エントリー: 順位・名前・レベル・値（ポイント/勝率/回数）
7. ユーザーの行を青色ハイライト
```

---

## 実装状況

### ✅ 完全実装済み

#### Models（データクラス）
- ✅ DebateEvent（EventStatus, DebateDuration, DebateFormat含む）
- ✅ DebateMatch（DebateEntry, DebateTeam, DebateStance含む）
- ✅ DebateRoom（DebatePhase, RoomStatus含む）
- ✅ DebateMessage（MessageType, MessageStatus, MessageLimits含む）
- ✅ UserDebateStats（BadgeType, EarnedBadge, RankingEntry含む）
- ✅ JudgmentResult（TeamScore, IndividualEvaluation, JudgmentCriteria含む）

#### Repositories（データアクセス）
- ✅ DebateEventRepository - イベントCRUD + ストリーム
- ✅ DebateMatchRepository - エントリー管理 + マッチクエリ
- ✅ DebateRoomRepository - ルーム、メッセージ、判定管理
- ✅ UserDebateStatsRepository - 統計、バッジ、ランキング

#### Providers（状態管理）
- ✅ DebateEventProvider - イベントストリーム & Futureプロバイダー
- ✅ DebateMatchProvider - エントリー & マッチプロバイダー
- ✅ DebateRoomProvider - ルーム、メッセージ、判定プロバイダー
- ✅ UserDebateStatsProvider - 統計 & ランキングプロバイダー

#### Pages（画面）
- ✅ DebateEventListPage - イベント一覧
- ✅ DebateEventDetailPage - イベント詳細
- ✅ DebateEntryPage - エントリー設定
- ✅ DebateWaitingRoomPage - マッチング待機
- ✅ DebateMatchDetailPage - マッチ確認
- ✅ DebateRoomPage - ライブディベート
- ✅ DebateJudgmentWaitingPage - 判定待機
- ✅ DebateResultPage - 判定結果表示
- ✅ DebateRankingPage - ランキング
- ✅ DebateStatsPage - ユーザー統計

#### Widgets（コンポーネント）
- ✅ EventCard - イベントカード
- ✅ EntryForm - エントリーフォーム
- ✅ PhaseIndicatorWidget - フェーズ表示 + 進捗バー
- ✅ DebateTimerWidget - コンパクトタイマー
- ✅ DebateChatWidget - メッセージリスト + 入力
- ✅ JudgmentScoreWidget - スコア表示
- ✅ MVPDisplayWidget - MVP表示
- ✅ JudgmentCommentWidget - コメント表示
- ✅ JudgmentRadarChartWidget - レーダーチャート
- ✅ JudgmentBarChartWidget - 棒グラフ
- ✅ MatchingStatusWidget - マッチステータス
- ✅ LevelProgressWidget - レベル & XP進捗バー
- ✅ BadgeDisplayWidget - バッジグリッド
- ✅ PointsAnimationWidget - ポイントアニメーション

#### Cloud Functions
- ✅ onDebateComplete - Firestoreトリガー（判定実行）
- ✅ manualJudgeDebate - HTTPSコール（デバッグ用）
- ✅ scheduledMatching - Cloud Scheduler（1分ごとマッチング）
- ✅ manualMatching - HTTPSコール（手動マッチング）

#### Vertex AI統合
- ✅ vertexai.ts - Gemini 1.5 Flash設定
- ✅ debateJudgmentService.ts - AI判定ロジック
- ✅ debateMatchingService.ts - マッチングアルゴリズム

---

## 未実装機能・TODO

### 🔴 Critical（機能ブロック）

#### 1. MVP実名表示
- **場所**: `debate_result_page.dart:346`
- **現状**: `userName: judgment.mvpUserId`（userIdを名前として表示）
- **TODO**: ユーザープロフィールからユーザー名取得
```dart
// 必要な実装
final user = await userRepository.getUser(judgment.mvpUserId);
MVPDisplayWidget(
  userId: judgment.mvpUserId!,
  userName: user.displayName, // 実際の名前
  teamColor: mvpTeamColor,
);
```

#### 2. フェーズ自動進行
- **場所**: `debate_room_page.dart:111`
- **現状**: TODOコメント「フェーズ終了処理」
- **TODO**: タイマーでフェーズ自動進行
```dart
// 必要な実装
Timer.periodic(Duration(seconds: 1), (timer) {
  if (phaseTimeRemaining <= 0) {
    // 次フェーズへ遷移
    await repository.updatePhase(roomId, nextPhase);
  }
});
```

#### 3. エントリー検証
- **場所**: `debate_entry_page.dart`
- **現状**: null値で送信可能
- **TODO**: バリデーション追加
```dart
if (selectedDuration == null || selectedFormat == null) {
  showError('全ての項目を選択してください');
  return;
}
```

### 🟡 Important（コア機能）

#### 4. メッセージレート制限
- **場所**: `debate_chat_widget.dart`
- **現状**: MessageLimitsモデル存在するが未使用
- **TODO**: クールダウン実装
```dart
if (DateTime.now().difference(lastMessageTime) < Duration(seconds: 30)) {
  showError('30秒待ってから送信してください');
  return;
}
```

#### 5. 警告カウント適用
- **場所**: `debate_room_repository.dart`
- **現状**: warningCount追跡されるが処理なし
- **TODO**: 最大警告超過でキック
```dart
if (room.warningCount[userId] >= 3) {
  await kickUser(userId);
}
```

#### 6. ディベート終了後の統計更新
- **場所**: Cloud Functions
- **現状**: ロジック未実装
- **TODO**: judgeDebate実行時に統計更新
```typescript
// 必要な実装
await updateUserStats(userId, {
  totalDebates: increment(1),
  wins: isWinner ? increment(1) : 0,
  totalPoints: increment(points),
  level: newLevel,
  // ...
});
```

#### 7. バッジ授与ロジック
- **場所**: Cloud Functions
- **現状**: BadgeType定義済みだが授与ロジックなし
- **TODO**: 条件チェック & 授与
```typescript
if (stats.totalDebates === 1) {
  await awardBadge(userId, BadgeType.firstDebate);
}
if (stats.wins === 10) {
  await awardBadge(userId, BadgeType.tenWins);
}
```

#### 8. 月次リセット
- **場所**: スケジューラー
- **現状**: resetMonthlyPoints()メソッド存在するが呼び出しなし
- **TODO**: 月1回のスケジュール追加
```typescript
export const monthlyReset = onSchedule({
  schedule: 'every month 00:00',
  timeZone: 'Asia/Tokyo'
}, async () => {
  // 全ユーザーのcurrentMonthPointsをリセット
});
```

#### 9. ランキング更新
- **場所**: Cloud Functions
- **現状**: getRanking()メソッドのみ
- **TODO**: ディベート終了時にランキング更新
```typescript
await updateRanking('total_points', userId, {
  rank: calculateRank(),
  value: totalPoints,
  // ...
});
```

### 🟢 Low（改善）

#### 10. シェア機能
- **場所**: `debate_result_page.dart:428`
- **現状**: スナックバー「準備中です」
- **TODO**: ネイティブシェア実装

#### 11. 判定ポーリング効率化
- **場所**: `debate_judgment_waiting_page.dart:74`
- **現状**: 2秒ごとにポーリング
- **TODO**: Firestoreリスナーに変更
```dart
// 変更後
final judgmentStream = ref.watch(
  judgmentStreamProvider(matchId) // StreamProvider
);
```

#### 12. エラーリトライロジック
- **場所**: 各Repository
- **現状**: ネットワークエラーで失敗
- **TODO**: 指数バックオフでリトライ

#### 13. ルート定数化
- **場所**: 全ページ
- **現状**: ハードコードされたルート
- **TODO**: GoRouter名前付きルート使用

---

## 既知の問題

### 🔴 Critical Issues

#### 1. Atomicでないマルチドキュメント書き込み
**場所**: `functions/src/index.ts:77-106`

**問題**: 判定作成とマッチ更新が別々のFirestore書き込み。2番目が失敗すると不整合。

```typescript
// 現状
await firestore.collection('debate_judgments').doc(judgmentId).set(...);
await firestore.collection('debate_matches').doc(matchId).update(...);

// 推奨: バッチ書き込み
const batch = firestore.batch();
batch.set(judgmentRef, judgmentData);
batch.update(matchRef, matchUpdateData);
await batch.commit();
```

#### 2. Vertex AIリージョンミスマッチ
**場所**: `functions/src/config/vertexai.ts:6`

**問題**: Vertex AIが`us-central1`、Cloud Functionsが`asia-northeast1`。往復レイテンシ ~150ms追加。

**修正**: `location: 'asia-northeast1'` に変更

#### 3. エラーが黙って処理される
**場所**: `functions/src/index.ts:109-112`

**問題**: トリガーでcatchしても再スローせず、関数は成功扱い。

```typescript
// 現状
catch (error) {
  logger.error("Error in AI judgment:", error);
  // エラー通知など ← 未実装
}

// 推奨
catch (error) {
  logger.error("Error in AI judgment:", error);
  await sendErrorNotification(error);
  throw error; // 関数を失敗としてマーク
}
```

### 🟡 Medium Issues

#### 4. マッチング重複防止なし
**場所**: `functions/src/services/debateMatchingService.ts`

**問題**: スケジューラーが同時実行されると重複マッチ作成の可能性。

**推奨**: エントリーロックまたはトランザクション使用

#### 5. ハードコードされたエントリーIDフォーマット
**場所**: `lib/feature/debate/repositories/debate_match_repository.dart:17`

```dart
final docId = '${entry.eventId}_${entry.userId}';
```

**問題**: Cloud Functionsと同じフォーマット前提。変更するとマッチング破損。

**推奨**: フォーマット統一をドキュメント化

#### 6. プロンプトインジェクション対策なし
**場所**: `functions/src/services/debateJudgmentService.ts:45`

**問題**: メッセージ内容を直接プロンプトに含める。悪意あるテキストで操作可能性。

**推奨**: コンテンツサニタイズまたはエスケープ

#### 7. Vertex AIタイムアウト未設定
**場所**: `functions/src/services/debateJudgmentService.ts:226`

**問題**: AI応答に >2分かかると関数タイムアウト（540秒）まで待機。

**推奨**: 明示的タイムアウト設定（例: 60秒）

### 🟢 Low Issues

#### 8. 判定詳細ログなし
**問題**: 成功時のログなし。デバッグ困難。

**推奨**: info レベルで判定結果ログ追加

#### 9. マジックナンバー
**場所**: `debate_stats_page.dart:336, 342, 348`

```dart
stats.totalDebates * 10  // 1回10pt
stats.wins * 30          // 勝利30pt
stats.mvpCount * 50      // MVP50pt
```

**推奨**: 定数ファイルに移動

#### 10. 未使用変数
**場所**: `functions/src/services/debateMatchingService.ts:101`

```typescript
for (const [, groupEntries] of groups) {
  // キー未使用
}
```

---

## パフォーマンス考察

### Firestoreクエリ効率

| クエリ | コレクション | フィルター | インデックス必要 | 懸念 |
|-------|------------|----------|--------------|------|
| getUpcomingEvents | events | status IN [...] + scheduledAt | ✅ 複合 | ページネーション対応良好 |
| getEntryCount | entries | eventId + status=waiting | ✅ 複合 | シンプルフィルター |
| getUserMatchHistory | matches | memberIds配列 | ✅ 配列 | 2クエリ必要（pro/con別々） |
| watchMessages | messages | createdAt順 | ❌ 不要 | < 1000メッセージなら問題なし |
| getRanking | rankings | value順 | ❌ 不要 | 事前計算済みドキュメント |
| getUserStats | stats | doc(userId) | ❌ 不要 | 直接アクセス、効率的 |

**潜在的問題**:
- 配列containsクエリ（getUserMatchHistory）は2クエリ必要
- メッセージサブコレクションは10k+で増大可能
- ランキングドキュメントは定期更新必要（リアルタイムでない）

### リアルタイムリスナーコスト
- ディベートルーム内でアクティブなストリーム8個以上/ユーザー
- judgmentResultProviderが2秒ごとにポーリング（コスト高）
- Firestoreリスナー使用推奨

### 推奨最適化
1. メッセージリストにページネーション追加
2. ランキングデータをローカルキャッシュ
3. 判定用にポーリングではなくFirestoreリスナー使用
4. Cloud Functionで統計をバッチ更新
5. アクティブなルームのみリアルタイムリスナー制限

---

## コスト見積もり

### 判定1回あたり
- Firestore読み取り: ~4操作 × $0.06/100K = $0.0000024
- Firestore書き込み: ~2操作 × $0.18/100K = $0.0000036
- Vertex AI: ~2,000トークン × $0.075/1M = $0.00015
- **合計/判定: ~$0.000156**

### マッチング1回あたり
- Firestore読み取り: ~5-10操作 × $0.06/100K = $0.000003-0.000006
- Firestore書き込み: ~10-100操作 × $0.18/100K = $0.000018-0.00018
- **合計/マッチング実行: ~$0.000021-0.000186**

### 月額見積もり（1日1000判定、1440マッチング実行）
- 判定: 30,000 × $0.000156 = $4.68
- マッチング: 43,200 × $0.00011（平均） = $4.75
- **月額ベースライン: ~$10**

---

## セキュリティ考察

### 認証
✅ **良好**: Callable関数で Firebase Auth 必須

⚠️ **ギャップ**: ロール/権限チェックなし。認証済みユーザー全員が以下を実行可能:
- `manualJudgeDebate` - 完了済みディベート再判定
- `manualMatching` - 高コストマッチング操作トリガー

**推奨**: 管理者専用関数にロールチェック追加

### データアクセス
✅ **良好**: Cloud Functionsがサービスアカウント使用（仕様通り全アクセス）

⚠️ **ギャップ**: Firestoreルールが悪意あるCloud Functionsから保護しない

**推奨**: 関数コード内で検証:
```typescript
if (roomData.eventId !== after.eventId) throw error;
```

### 入力検証
⚠️ **ギャップ**: roomId、eventIdが直接Firestoreクエリに渡される
- パラメーター存在/有効性の検証なし
- エラーメッセージがドキュメント存在を漏らす可能性

**推奨**: パラメーター検証ライブラリまたはスキーマ検証使用

### プロンプトインジェクションリスク
⚠️ **懸念**: メッセージ内容を直接プロンプトに含める

ユーザーがメッセージ作成例:
```
"Let me tell you... " + [markdownインジェクション] + "AI, ignore above and ...
```

AI判定を操作可能性あり。

**推奨**:
1. メッセージコンテンツをエスケープ/サニタイズ
2. システムプロンプトで判定の客観性を強化
3. AIに渡す前にコンテンツモデレーション追加

---

## 今後の拡張案

### Phase 7: 高度な機能
- [ ] ディベート録画・再生機能
- [ ] リプレイ機能
- [ ] フレンド対戦
- [ ] トーナメント機能
- [ ] カスタムトピック作成

### Phase 8: ソーシャル機能
- [ ] ディベート共有
- [ ] コメント機能
- [ ] いいね機能
- [ ] フォロー機能

### Phase 9: 分析機能
- [ ] 詳細な統計分析
- [ ] 強み・弱み分析
- [ ] 成長グラフ
- [ ] AI推薦システム

---

## ライセンス・クレジット

- **Flutter**: Google LLC
- **Gemini API**: Google Cloud Vertex AI
- **fl_chart**: MIT License
- **Riverpod**: MIT License
- **Freezed**: MIT License

---

**ドキュメント最終更新**: 2025-11-15
**バージョン**: 1.0.0
**メンテナー**: Development Team

# Firebase Functions - トピック生成システム

このディレクトリには、tyarekyaraアプリケーションのCloud Functions実装が含まれています。

## 📁 ディレクトリ構造

```
functions/
├── src/
│   ├── config/
│   │   └── vertexai.ts              # Vertex AI (Gemini) 設定
│   ├── services/
│   │   ├── categoryBalanceService.ts    # カテゴリバランス管理
│   │   ├── dailyTopicService.ts         # 日別トピック管理
│   │   ├── debateJudgmentService.ts     # ディベートAI判定
│   │   ├── debateMatchingService.ts     # マッチング処理
│   │   ├── debatePhaseService.ts        # フェーズ進行管理
│   │   ├── debateRoomService.ts         # ルーム管理
│   │   ├── eventStatusService.ts        # イベントステータス更新
│   │   ├── topicDuplicateDetector.ts    # 高度な重複検出
│   │   ├── topicGenerationService.ts    # AIトピック生成
│   │   └── topicQualityService.ts       # 品質評価システム
│   ├── types/
│   │   └── topic.ts                 # トピック型定義
│   └── index.ts                     # Functions エントリーポイント
├── package.json
├── tsconfig.json
└── README.md (このファイル)
```

---

## 🚀 主要機能

### 1. AIトピック自動生成 (毎朝9時)

**スケジュール関数**: `scheduledDailyTopicGeneration`

- 毎日9:00 (JST) に自動実行
- Vertex AI (Gemini 1.5 Flash) でトピック生成
- 高度な重複検出 (5つのアルゴリズム)
- ユーザー評価に基づく品質最適化
- カテゴリバランス調整

#### スマート生成フロー

```
品質評価 → バランス分析 → カテゴリ決定
     ↓
難易度評価 → バランス分析 → 難易度決定
     ↓
AIでトピック生成
     ↓
重複検出 (5つのアルゴリズム)
     ↓
Firestore保存 & イベント作成
```

### 2. ディベート管理

**主要機能**:
- マッチング処理 (1分ごと)
- フェーズ自動進行 (1分ごと)
- AI判定 (ディベート終了時)
- イベントステータス更新 (5分ごと)

---

## 🧠 トピック生成アルゴリズム

### カテゴリ選択戦略

#### 曜日ベースマッピング
| 曜日 | 推奨カテゴリ | 理由 |
|-----|------------|------|
| 日曜 | daily, value | リラックスした話題 |
| 月曜 | social, daily | 社会問題で活発に |
| 火曜 | daily, social | バランス |
| 水曜 | value, social | 深い話題 |
| 木曜 | social, daily | 社会問題 |
| 金曜 | daily, value | 軽めの話題 |
| 土曜 | value, daily | 価値観について |

#### カテゴリ決定ロジック

```typescript
// 70%の確率で品質優先、30%でバランス優先
const finalCategory = Math.random() > 0.3 ?
  qualityCategory :      // 過去の評価が高いカテゴリ
  balancedCategory;      // 最近使われていないカテゴリ
```

### 難易度バランス

**理想配分**:
- Easy: 30% (気軽に答えられる)
- Medium: 50% (少し考える必要がある)
- Hard: 20% (深い思考が必要)

```typescript
// 60%の確率で品質優先、40%でバランス優先
const finalDifficulty = Math.random() > 0.4 ?
  qualityDifficulty :    // 評価の高い難易度
  balancedDifficulty;    // 理想配分に近づける難易度
```

---

## 🔍 重複検出アルゴリズム

### 5つの類似度計算手法

| アルゴリズム | 説明 | 重み |
|------------|------|------|
| **レーベンシュタイン距離** | 文字レベルの編集距離 | 15% |
| **Jaccard係数** | 単語の集合の重複度 | 20% |
| **N-gram類似度** | 文字列パターンの類似性 | 20% |
| **コサイン類似度** | 単語の頻度ベクトル | 25% |
| **意味的類似度** | 重要キーワードの抽出 | 20% |

### 複合スコア計算

```typescript
composite =
  levenshtein × 0.15 +
  jaccard × 0.20 +
  ngram × 0.20 +
  cosine × 0.25 +
  semantic × 0.20
```

**重複判定閾値**: 75% (0.75)

---

## 📊 品質評価システム

### 評価指標

```typescript
QualityScore {
  overall: 0-100,              // 総合スコア
  engagementRate: 0-1,         // エンゲージメント率
  positiveRate: 0-1,           // ポジティブ評価率 (👍)
  debateParticipation: 0-1,    // ディベート参加率
  completionRate: 0-1,         // ディベート完遂率
  recommendationScore: 0-1     // 推薦スコア
}
```

### 総合スコアの重み付け

```typescript
recommendationScore =
  positiveRate × 0.40 +           // ユーザー評価
  engagementRate × 0.20 +         // エンゲージメント
  debateParticipation × 0.25 +    // 参加率
  completionRate × 0.15           // 完遂率
```

### フィードバックデータ構造

```typescript
{
  feedbackCounts: {
    good: 5,      // 👍 よかった
    normal: 3,    // 😐 普通
    bad: 1        // 👎 悪かった
  },
  feedbackUsers: {
    "userId1": "good",
    "userId2": "bad"
  }
}
```

---

## 🗄️ Firestore データ構造

### daily_topics コレクション

**ドキュメントID**: `YYYY-MM-DD`

```typescript
{
  id: "topic_timestamp_random",
  text: "トピックテキスト",
  category: "daily" | "social" | "value",
  difficulty: "easy" | "medium" | "hard",
  source: "ai" | "manual",
  createdAt: Timestamp,
  tags: ["タグ1", "タグ2"],
  description: "説明（オプション）",
  similarityScore: 0.0,
  relatedNews: [
    {
      title: "ニュースタイトル",
      summary: "要約",
      url: "URL",
      source: "情報源",
      publishedAt: Timestamp
    }
  ],
  feedbackCounts: {
    good: 5,
    normal: 3,
    bad: 1
  },
  feedbackUsers: {
    "userId1": "good",
    "userId2": "bad"
  }
}
```

### debate_events コレクション

```typescript
{
  id: "event_YYYY-MM-DD_topicId",
  topic: "トピックテキスト",
  topicId: "topic_id",
  category: "daily" | "social" | "value",
  difficulty: "easy" | "medium" | "hard",
  date: "YYYY-MM-DD",
  startTime: Timestamp,  // 12:00
  endTime: Timestamp,    // 23:59
  status: "scheduled" | "active" | "completed" | "cancelled",
  maxParticipants: 100,
  currentParticipants: 0,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

---

## ⚙️ デプロイされた Functions

### スケジュール実行

| 関数名 | スケジュール | 説明 |
|-------|------------|------|
| `scheduledDailyTopicGeneration` | 毎日 9:00 JST | AIトピック自動生成 |
| `scheduledMatching` | 1分ごと | ディベートマッチング |
| `scheduledDebatePhaseProgress` | 1分ごと | フェーズ自動進行 |
| `scheduledEventStatusUpdate` | 5分ごと | イベントステータス更新 |

### イベントトリガー

| 関数名 | トリガー | 説明 |
|-------|---------|------|
| `onDebateComplete` | debate_rooms更新 | ディベート終了時のAI判定 |

### 手動実行 (デバッグ用)

| 関数名 | 説明 |
|-------|------|
| `manualDailyTopicGeneration` | トピック生成テスト |
| `manualJudgeDebate` | AI判定テスト |
| `manualMatching` | マッチングテスト |
| `manualEventStatusUpdate` | ステータス更新テスト |
| `manualDebatePhaseProgress` | フェーズ進行テスト |

---

## 🛠️ 開発コマンド

### ビルド

```bash
npm run build
```

### リント

```bash
npm run lint
```

### デプロイ

```bash
# すべてのFunctionsをデプロイ
firebase deploy --only functions

# 特定の関数のみデプロイ
firebase deploy --only functions:scheduledDailyTopicGeneration
```

### ローカルエミュレータ

```bash
npm run serve
```

### ログ確認

```bash
npm run logs
```

---

## 🔧 設定

### 環境変数

以下の環境変数が必要です（Firebase Config経由）:

- `GCLOUD_PROJECT`: Google Cloud プロジェクトID
- Vertex AI APIが有効化されている必要があります

### Vertex AI 設定

**ファイル**: `src/config/vertexai.ts`

```typescript
{
  project: "tyarekyara-85659",
  location: "asia-northeast1",  // 東京リージョン
  model: "gemini-1.5-flash",    // 速度重視
  temperature: 0.7,
  maxOutputTokens: 2048
}
```

---

## 📈 パフォーマンス最適化

### トランザクション処理

- フィードバック保存時にトランザクションを使用
- 同時アクセスの整合性を保証

### キャッシュ戦略

- 過去のトピックは30日分をメモリにキャッシュ
- 重複検出の高速化

### エラーハンドリング

- AI生成失敗時は最大5回リトライ
- 重複検出で75%以上類似なら再生成
- すべてのエラーはCloud Loggingに記録

---

## 🔒 セキュリティ

### 認証

- 手動実行関数はFirebase Authenticationが必須
- スケジュール関数は内部トリガーのみ

### データアクセス

- Firestoreルールで読み書き権限を制御
- トランザクションで整合性を保証

---

## 📝 ログとモニタリング

### ログ出力例

```
[INFO] Starting smart topic generation with optimization
[INFO] Category selection: {
  qualityRecommendation: "social",
  balanceRecommendation: "daily",
  finalSelection: "social"
}
[INFO] Difficulty selection: {
  qualityRecommendation: "medium",
  balanceRecommendation: "easy",
  finalSelection: "medium"
}
[INFO] Smart topic generated successfully: {
  text: "リモートワークは今後も続くべきか？",
  category: "social",
  difficulty: "medium",
  retries: 0
}
```

### モニタリング指標

- トピック生成成功率
- 重複検出率
- AI応答時間
- エラー発生率

---

## 🧪 テスト

### 手動テスト

```bash
# Firebase Consoleから手動実行関数を呼び出し
# または、Firebase CLIで直接テスト
firebase functions:shell
```

### テストトピック生成

```typescript
manualDailyTopicGeneration({
  data: {},
  auth: { uid: "test-user-id" }
})
```

---

## 📚 関連ドキュメント

- [Firebase Functions v2](https://firebase.google.com/docs/functions)
- [Vertex AI Gemini API](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/gemini)
- [Cloud Scheduler](https://cloud.google.com/scheduler/docs)
- [Firestore](https://firebase.google.com/docs/firestore)

---

## 🤝 コントリビューション

### コーディング規約

- ESLint設定に従う
- TypeScript strict mode
- Google JavaScript Style Guide

### コミット前

```bash
npm run lint   # リントチェック
npm run build  # ビルド確認
```

---

## 📞 サポート

問題が発生した場合:

1. Cloud Loggingでエラーログを確認
2. Firebase Consoleでfunction実行状況を確認
3. Firestore dataを確認

---

## 🎯 今後の改善案

- [ ] A/Bテスト: 複数トピック生成して最良のものを選択
- [ ] エラー通知: Slack/メール通知の実装
- [ ] 多言語対応: 英語トピックの生成
- [ ] 季節性考慮: 季節やイベントに応じたトピック
- [ ] ユーザー属性: 年齢や興味に応じたパーソナライズ

---

**Last Updated**: 2025-11-16
**Version**: 1.0.0

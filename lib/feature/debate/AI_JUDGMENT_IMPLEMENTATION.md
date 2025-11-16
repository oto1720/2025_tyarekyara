# AI判定システム実装ガイド

## 概要

このドキュメントでは、ディベート機能のAI判定システムをCloud Functionsで実装する方法を説明します。

---

## 前提条件

### 1. Firebase設定

- Firebase Projectで課金が有効化されていること（Blaze プラン）
- 以下のAPIが有効化されていること：
  - Cloud Functions for Firebase
  - Cloud Firestore
  - Vertex AI API

### 2. 必要なツール

```bash
# Firebase CLI
npm install -g firebase-tools

# Firebase ログイン
firebase login

# プロジェクト初期化（既存の場合はスキップ）
firebase init functions
```

---

## 実装ステップ

### Step 1: Cloud Functionsプロジェクトのセットアップ

```bash
# プロジェクトルートで実行
cd functions

# 依存関係のインストール
npm install
npm install @google-cloud/aiplatform
```

### Step 2: Vertex AI設定

#### `functions/src/config/vertexai.ts`

```typescript
import { VertexAI } from '@google-cloud/aiplatform';

// Vertex AI初期化
export const vertexAI = new VertexAI({
  project: process.env.GCLOUD_PROJECT || 'your-project-id',
  location: 'us-central1', // または 'asia-northeast1'
});

// モデル設定
export const MODEL_CONFIG = {
  model: 'gemini-1.5-flash', // 速度重視: gemini-1.5-flash, 精度重視: gemini-1.5-pro
  temperature: 0.7,
  maxOutputTokens: 2048,
  topP: 0.95,
  topK: 40,
};
```

### Step 3: AI判定ロジック実装

#### `functions/src/services/debateJudgmentService.ts`

```typescript
import * as admin from 'firebase-admin';
import { vertexAI, MODEL_CONFIG } from '../config/vertexai';

interface DebateMessage {
  userId: string;
  content: string;
  phase: string;
  createdAt: Date;
}

interface JudgmentResult {
  winningSide: 'pro' | 'con' | null;
  proTeamScore: TeamScore;
  conTeamScore: TeamScore;
  mvpUserId: string | null;
  overallComment: string;
  proTeamComment: string;
  conTeamComment: string;
}

interface TeamScore {
  logicScore: number;        // 0-10
  evidenceScore: number;     // 0-10
  rebuttalScore: number;     // 0-10
  persuasivenessScore: number; // 0-10
  mannerScore: number;       // 0-10
  totalScore: number;        // 合計 0-50
}

/**
 * ディベートを判定する
 */
export async function judgeDebate(
  roomId: string,
  eventTopic: string
): Promise<JudgmentResult> {
  try {
    // 1. メッセージを取得
    const messages = await fetchDebateMessages(roomId);

    // 2. プロンプトを生成
    const prompt = buildJudgmentPrompt(eventTopic, messages);

    // 3. Vertex AIでAI判定を実行
    const aiResponse = await callVertexAI(prompt);

    // 4. レスポンスをパース
    const result = parseAIResponse(aiResponse);

    return result;
  } catch (error) {
    console.error('Error judging debate:', error);
    throw new Error('AI判定に失敗しました');
  }
}

/**
 * メッセージを取得
 */
async function fetchDebateMessages(roomId: string): Promise<DebateMessage[]> {
  const messagesSnapshot = await admin
    .firestore()
    .collection('debate_rooms')
    .doc(roomId)
    .collection('messages')
    .where('type', '==', 'public') // 公開メッセージのみ
    .orderBy('createdAt', 'asc')
    .get();

  return messagesSnapshot.docs.map(doc => doc.data() as DebateMessage);
}

/**
 * 判定プロンプトを構築
 */
function buildJudgmentPrompt(
  topic: string,
  messages: DebateMessage[]
): string {
  // フェーズごとにメッセージを分類
  const messagesByPhase = groupMessagesByPhase(messages);

  return `
あなたはディベート審判です。以下のディベートを公平に判定してください。

## ディベートトピック
${topic}

## 参加チーム
- **賛成チーム**: トピックに賛成の立場
- **反対チーム**: トピックに反対の立場

## ディベート内容

### 立論フェーズ（賛成）
${formatMessages(messagesByPhase.openingPro || [])}

### 立論フェーズ（反対）
${formatMessages(messagesByPhase.openingCon || [])}

### 質疑応答フェーズ（賛成への質問）
${formatMessages(messagesByPhase.questionPro || [])}

### 質疑応答フェーズ（反対への質問）
${formatMessages(messagesByPhase.questionCon || [])}

### 反論フェーズ（賛成）
${formatMessages(messagesByPhase.rebuttalPro || [])}

### 反論フェーズ（反対）
${formatMessages(messagesByPhase.rebuttalCon || [])}

### 最終主張フェーズ（賛成）
${formatMessages(messagesByPhase.closingPro || [])}

### 最終主張フェーズ（反対）
${formatMessages(messagesByPhase.closingCon || [])}

## 評価基準（各項目10点満点）

1. **論理性**: 主張の論理的整合性
2. **根拠・証拠**: 主張を裏付ける証拠の質と量
3. **反論力**: 相手の主張への効果的な反論
4. **説得力**: 聴衆を納得させる力
5. **マナー**: ディベートマナーの遵守

## 出力形式

以下のJSON形式で判定結果を返してください：

\`\`\`json
{
  "winningSide": "pro" | "con" | null,
  "proTeamScore": {
    "logicScore": 0-10,
    "evidenceScore": 0-10,
    "rebuttalScore": 0-10,
    "persuasivenessScore": 0-10,
    "mannerScore": 0-10,
    "totalScore": 0-50
  },
  "conTeamScore": {
    "logicScore": 0-10,
    "evidenceScore": 0-10,
    "rebuttalScore": 0-10,
    "persuasivenessScore": 0-10,
    "mannerScore": 0-10,
    "totalScore": 0-50
  },
  "mvpUserId": "最も優れた発言をしたユーザーID",
  "overallComment": "ディベート全体の講評（100-200文字）",
  "proTeamComment": "賛成チームへのフィードバック（100-200文字）",
  "conTeamComment": "反対チームへのフィードバック（100-200文字）"
}
\`\`\`

**重要な注意事項**:
- 必ず公平に判定してください
- totalScoreは各項目の合計です
- 同点の場合はwinningSideをnullにしてください
- コメントは建設的で具体的にしてください
`;
}

/**
 * メッセージをフェーズごとにグループ化
 */
function groupMessagesByPhase(messages: DebateMessage[]): Record<string, DebateMessage[]> {
  const grouped: Record<string, DebateMessage[]> = {};

  for (const message of messages) {
    if (!grouped[message.phase]) {
      grouped[message.phase] = [];
    }
    grouped[message.phase].push(message);
  }

  return grouped;
}

/**
 * メッセージをフォーマット
 */
function formatMessages(messages: DebateMessage[]): string {
  if (messages.length === 0) {
    return '（発言なし）';
  }

  return messages
    .map((msg, index) => `${index + 1}. ${msg.content}`)
    .join('\n');
}

/**
 * Vertex AIを呼び出し
 */
async function callVertexAI(prompt: string): Promise<string> {
  const generativeModel = vertexAI.preview.getGenerativeModel({
    model: MODEL_CONFIG.model,
    generationConfig: {
      temperature: MODEL_CONFIG.temperature,
      maxOutputTokens: MODEL_CONFIG.maxOutputTokens,
      topP: MODEL_CONFIG.topP,
      topK: MODEL_CONFIG.topK,
    },
  });

  const result = await generativeModel.generateContent({
    contents: [{ role: 'user', parts: [{ text: prompt }] }],
  });

  const response = result.response;
  return response.candidates[0].content.parts[0].text;
}

/**
 * AIレスポンスをパース
 */
function parseAIResponse(response: string): JudgmentResult {
  try {
    // JSONブロックを抽出
    const jsonMatch = response.match(/```json\n([\s\S]*?)\n```/);
    const jsonString = jsonMatch ? jsonMatch[1] : response;

    const parsed = JSON.parse(jsonString);

    // totalScoreを計算
    parsed.proTeamScore.totalScore =
      parsed.proTeamScore.logicScore +
      parsed.proTeamScore.evidenceScore +
      parsed.proTeamScore.rebuttalScore +
      parsed.proTeamScore.persuasivenessScore +
      parsed.proTeamScore.mannerScore;

    parsed.conTeamScore.totalScore =
      parsed.conTeamScore.logicScore +
      parsed.conTeamScore.evidenceScore +
      parsed.conTeamScore.rebuttalScore +
      parsed.conTeamScore.persuasivenessScore +
      parsed.conTeamScore.mannerScore;

    return parsed as JudgmentResult;
  } catch (error) {
    console.error('Error parsing AI response:', error);
    throw new Error('AI判定結果のパースに失敗しました');
  }
}

export { JudgmentResult, TeamScore };
```

### Step 4: Cloud Functionトリガー実装

#### `functions/src/index.ts`

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { judgeDebate } from './services/debateJudgmentService';

admin.initializeApp();

/**
 * ディベート終了時にAI判定を実行
 */
export const onDebateComplete = functions
  .region('asia-northeast1') // リージョン設定
  .firestore
  .document('debate_rooms/{roomId}')
  .onUpdate(async (change, context) => {
    const roomId = context.params.roomId;
    const before = change.before.data();
    const after = change.after.data();

    // ステータスがcompletedに変わった場合のみ実行
    if (before.status !== 'completed' && after.status === 'completed') {
      try {
        console.log(`Starting AI judgment for room: ${roomId}`);

        // イベント情報を取得
        const eventDoc = await admin
          .firestore()
          .collection('debate_events')
          .doc(after.eventId)
          .get();

        const eventData = eventDoc.data();
        if (!eventData) {
          throw new Error('Event not found');
        }

        // AI判定を実行
        const judgment = await judgeDebate(roomId, eventData.topic);

        // 判定結果を保存
        const judgmentId = `judgment_${after.matchId}`;
        await admin
          .firestore()
          .collection('debate_judgments')
          .doc(judgmentId)
          .set({
            id: judgmentId,
            matchId: after.matchId,
            roomId: roomId,
            eventId: after.eventId,
            winningSide: judgment.winningSide,
            proTeamScore: judgment.proTeamScore,
            conTeamScore: judgment.conTeamScore,
            mvpUserId: judgment.mvpUserId,
            overallComment: judgment.overallComment,
            proTeamComment: judgment.proTeamComment,
            conTeamComment: judgment.conTeamComment,
            judgedAt: admin.firestore.FieldValue.serverTimestamp(),
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        // マッチステータスを更新
        await admin
          .firestore()
          .collection('debate_matches')
          .doc(after.matchId)
          .update({
            status: 'completed',
            winningSide: judgment.winningSide,
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        console.log(`AI judgment completed for room: ${roomId}`);
      } catch (error) {
        console.error('Error in AI judgment:', error);
        // エラー通知など
      }
    }

    return null;
  });

/**
 * 手動判定トリガー（デバッグ用）
 */
export const manualJudgeDebate = functions
  .region('asia-northeast1')
  .https
  .onCall(async (data, context) => {
    // 認証チェック
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Authentication required'
      );
    }

    const { roomId } = data;

    try {
      const roomDoc = await admin
        .firestore()
        .collection('debate_rooms')
        .doc(roomId)
        .get();

      const roomData = roomDoc.data();
      if (!roomData) {
        throw new functions.https.HttpsError('not-found', 'Room not found');
      }

      const eventDoc = await admin
        .firestore()
        .collection('debate_events')
        .doc(roomData.eventId)
        .get();

      const eventData = eventDoc.data();
      if (!eventData) {
        throw new functions.https.HttpsError('not-found', 'Event not found');
      }

      const judgment = await judgeDebate(roomId, eventData.topic);

      return {
        success: true,
        judgment,
      };
    } catch (error) {
      console.error('Error in manual judgment:', error);
      throw new functions.https.HttpsError('internal', 'Judgment failed');
    }
  });
```

### Step 5: デプロイ

```bash
# Firebase Functionsデプロイ
firebase deploy --only functions

# 特定の関数のみデプロイ
firebase deploy --only functions:onDebateComplete
firebase deploy --only functions:manualJudgeDebate
```

---

## テスト方法

### 1. ローカルエミュレータでテスト

```bash
# エミュレータ起動
firebase emulators:start

# functions/src/test/judgment.test.ts
import { judgeDebate } from '../services/debateJudgmentService';

describe('Debate Judgment', () => {
  it('should judge debate correctly', async () => {
    const result = await judgeDebate('test-room-id', 'AIは人類に有益か？');

    expect(result.winningSide).toBeDefined();
    expect(result.proTeamScore.totalScore).toBeGreaterThanOrEqual(0);
    expect(result.proTeamScore.totalScore).toBeLessThanOrEqual(50);
  });
});
```

### 2. 本番環境でテスト

Flutter側からCallable Functionを呼び出してテスト：

```dart
// lib/feature/debate/services/debate_judgment_service.dart
import 'package:cloud_functions/cloud_functions.dart';

class DebateJudgmentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> manualJudge(String roomId) async {
    try {
      final result = await _functions
          .httpsCallable('manualJudgeDebate')
          .call({'roomId': roomId});

      return result.data as Map<String, dynamic>;
    } catch (e) {
      print('Error calling manual judgment: $e');
      rethrow;
    }
  }
}
```

---

## コスト見積もり

### Vertex AI (Gemini 1.5 Flash)

- 入力: $0.000125 / 1K characters
- 出力: $0.000375 / 1K characters

**1回の判定あたり**:
- 入力トークン: 約2,000文字 = $0.25
- 出力トークン: 約500文字 = $0.19
- **合計: 約$0.44 / 判定**

### Cloud Functions

- 呼び出し: 200万回/月まで無料
- 実行時間: 40万GB秒/月まで無料

**月間1,000試合の場合**:
- Vertex AI: $440
- Cloud Functions: ほぼ無料

---

## トラブルシューティング

### エラー: "Permission denied"

```bash
# サービスアカウントに権限を付与
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
  --role="roles/aiplatform.user"
```

### エラー: "Quota exceeded"

Vertex AI APIのクォータを確認・増加：
https://console.cloud.google.com/iam-admin/quotas

### AIの判定が不正確

プロンプトを調整：
- より具体的な評価基準を追加
- 例を含める（Few-shot learning）
- temperature値を下げる（0.5-0.7）

---

## 次のステップ

1. ✅ Flutter UI実装完了
2. ⬜ Cloud Functions実装
3. ⬜ Vertex AI設定
4. ⬜ 本番テスト
5. ⬜ モニタリング設定

---

## 参考リンク

- [Vertex AI Documentation](https://cloud.google.com/vertex-ai/docs)
- [Gemini API Guide](https://ai.google.dev/gemini-api/docs)
- [Firebase Functions](https://firebase.google.com/docs/functions)
- [Cloud Firestore Triggers](https://firebase.google.com/docs/functions/firestore-events)

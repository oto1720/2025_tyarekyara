import * as admin from "firebase-admin";
import {vertexAI, MODEL_CONFIG} from "../config/vertexai";

interface DebateMessage {
  userId: string;
  content: string;
  phase: string;
  createdAt: Date;
}

interface JudgmentResult {
  winningSide: "pro" | "con" | null;
  proTeamScore: TeamScore;
  conTeamScore: TeamScore;
  mvpUserId: string | null;
  overallComment: string;
  proTeamComment: string;
  conTeamComment: string;
}

interface TeamScore {
  logicScore: number; // 0-10
  evidenceScore: number; // 0-10
  rebuttalScore: number; // 0-10
  persuasivenessScore: number; // 0-10
  mannerScore: number; // 0-10
  totalScore: number; // 合計 0-50
}

/**
 * ディベートを判定する
 * @param {string} roomId - ディベートルームID
 * @param {string} eventTopic - ディベートトピック
 * @return {Promise<JudgmentResult>} 判定結果
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
    console.error("Error judging debate:", error);
    throw new Error("AI判定に失敗しました");
  }
}

/**
 * メッセージを取得
 * @param {string} roomId - ディベートルームID
 * @return {Promise<DebateMessage[]>} メッセージリスト
 */
async function fetchDebateMessages(
  roomId: string
): Promise<DebateMessage[]> {
  const messagesSnapshot = await admin
    .firestore()
    .collection("debate_rooms")
    .doc(roomId)
    .collection("messages")
    .where("type", "==", "public") // 公開メッセージのみ
    .orderBy("createdAt", "asc")
    .get();

  return messagesSnapshot.docs.map((doc) => doc.data() as DebateMessage);
}

/**
 * 判定プロンプトを構築
 * @param {string} topic - ディベートトピック
 * @param {DebateMessage[]} messages - メッセージリスト
 * @return {string} AI判定用プロンプト
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
 * @param {DebateMessage[]} messages - メッセージリスト
 * @return {Record<string, DebateMessage[]>} フェーズ別メッセージ
 */
function groupMessagesByPhase(
  messages: DebateMessage[]
): Record<string, DebateMessage[]> {
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
 * @param {DebateMessage[]} messages - メッセージリスト
 * @return {string} フォーマット済みメッセージ
 */
function formatMessages(messages: DebateMessage[]): string {
  if (messages.length === 0) {
    return "（発言なし）";
  }

  return messages
    .map((msg, index) => `${index + 1}. ${msg.content}`)
    .join("\n");
}

/**
 * Vertex AIを呼び出し
 * @param {string} prompt - AI用プロンプト
 * @return {Promise<string>} AI応答テキスト
 */
async function callVertexAI(prompt: string): Promise<string> {
  const generativeModel = vertexAI.getGenerativeModel({
    model: MODEL_CONFIG.model,
    generationConfig: {
      temperature: MODEL_CONFIG.temperature,
      maxOutputTokens: MODEL_CONFIG.maxOutputTokens,
      topP: MODEL_CONFIG.topP,
      topK: MODEL_CONFIG.topK,
    },
  });

  const result = await generativeModel.generateContent({
    contents: [{role: "user", parts: [{text: prompt}]}],
  });

  const response = result.response;
  if (!response.candidates || response.candidates.length === 0) {
    throw new Error("No response from AI");
  }

  const candidate = response.candidates[0];
  if (!candidate.content ||
      !candidate.content.parts ||
      candidate.content.parts.length === 0) {
    throw new Error("Invalid AI response format");
  }

  return candidate.content.parts[0].text || "";
}

/**
 * AIレスポンスをパース
 * @param {string} response - AI応答テキスト
 * @return {JudgmentResult} パース済み判定結果
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
    console.error("Error parsing AI response:", error);
    throw new Error("AI判定結果のパースに失敗しました");
  }
}

export {JudgmentResult, TeamScore};

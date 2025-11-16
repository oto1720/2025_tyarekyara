/**
 * AIトピック生成サービス
 */

import * as logger from "firebase-functions/logger";
import {vertexAI, MODEL_CONFIG} from "../config/vertexai";
import {
  Topic,
  TopicCategory,
  TopicDifficulty,
  TopicSource,
  NewsItem,
} from "../types/topic";

/**
 * カテゴリの日本語マッピング
 */
const CATEGORY_LABELS: Record<TopicCategory, string> = {
  daily: "日常生活や身近なテーマ",
  social: "社会問題や時事的なテーマ",
  value: "価値観や人生観についての深いテーマ",
};

/**
 * 難易度の日本語マッピング
 */
const DIFFICULTY_LABELS: Record<TopicDifficulty, string> = {
  easy: "気軽に答えられる",
  medium: "少し考える必要がある",
  hard: "深い思考が必要",
};

/**
 * トピックテキストをAIで生成
 * @param {TopicCategory} category トピックカテゴリ
 * @param {TopicDifficulty} difficulty トピック難易度
 * @return {Promise<string>} 生成されたトピックテキスト
 */
export async function generateTopicText(
  category: TopicCategory,
  difficulty: TopicDifficulty
): Promise<string> {
  const generativeModel = vertexAI.getGenerativeModel({
    model: MODEL_CONFIG.model,
    generationConfig: {
      temperature: MODEL_CONFIG.temperature,
      maxOutputTokens: MODEL_CONFIG.maxOutputTokens,
      topP: MODEL_CONFIG.topP,
      topK: MODEL_CONFIG.topK,
    },
  });

  const prompt = `あなたは議論を促すトピックを生成するアシスタントです。

## 条件
- トピックは簡潔で明確にしてください（1-2文程度）
- 多様な意見が出やすいテーマを選んでください
- 議論を促す形式（問いかけ形式など）にしてください
- 具体的すぎず、抽象的すぎないバランスを取ってください
- 論争的すぎず、建設的な議論ができるテーマにしてください

## カテゴリ: ${CATEGORY_LABELS[category]}
## 難易度: ${DIFFICULTY_LABELS[difficulty]}

## 出力形式
トピックのみを出力してください。説明や前置きは不要です。`;

  try {
    const result = await generativeModel.generateContent(prompt);
    const response = result.response;
    const text = response.candidates?.[0]?.content?.parts?.[0]?.text || "";

    if (!text) {
      throw new Error("AI generated empty topic");
    }

    return text.trim();
  } catch (error) {
    logger.error("Error generating topic text:", error);
    throw new Error("Failed to generate topic text");
  }
}

/**
 * トピックを分類（カテゴリ・難易度・タグを判定）
 * @param {string} topicText トピックテキスト
 * @return {Promise<object>} 分類結果
 */
export async function classifyTopic(topicText: string): Promise<{
  category: TopicCategory;
  difficulty: TopicDifficulty;
  tags: string[];
}> {
  const generativeModel = vertexAI.getGenerativeModel({
    model: MODEL_CONFIG.model,
    generationConfig: {
      temperature: 0.3, // 分類は安定性重視
      maxOutputTokens: 500,
    },
  });

  const prompt = `以下のトピックを分析して、カテゴリ、難易度、タグを判定してください。

トピック: "${topicText}"

## カテゴリ
- daily: 日常生活や身近なテーマ
- social: 社会問題や時事的なテーマ
- value: 価値観や人生観についての深いテーマ

## 難易度
- easy: 気軽に答えられる
- medium: 少し考える必要がある
- hard: 深い思考が必要

## タグ
トピックの内容を表す3-5個のタグを生成してください。

## 出力形式（必ずJSON形式で出力）
{
  "category": "daily|social|value",
  "difficulty": "easy|medium|hard",
  "tags": ["タグ1", "タグ2", "タグ3"]
}`;

  try {
    const result = await generativeModel.generateContent(prompt);
    const response = result.response;
    const text = response.candidates?.[0]?.content?.parts?.[0]?.text || "";

    // JSONを抽出（マークダウンのコードブロックを除去）
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error("Invalid JSON response from AI");
    }

    const classification = JSON.parse(jsonMatch[0]);

    // バリデーション
    const validCategories: TopicCategory[] = ["daily", "social", "value"];
    const validDifficulties: TopicDifficulty[] = ["easy", "medium", "hard"];

    if (!validCategories.includes(classification.category)) {
      classification.category = "daily"; // デフォルト
    }
    if (!validDifficulties.includes(classification.difficulty)) {
      classification.difficulty = "medium"; // デフォルト
    }
    if (!Array.isArray(classification.tags)) {
      classification.tags = [];
    }

    return classification;
  } catch (error) {
    logger.error("Error classifying topic:", error);
    // フォールバック: ルールベース分類
    return {
      category: "daily",
      difficulty: "medium",
      tags: [],
    };
  }
}

/**
 * 関連ニュースを検索（Google Search Grounding使用）
 * @param {string} topicText トピックテキスト
 * @param {TopicCategory} category トピックカテゴリ
 * @return {Promise<NewsItem[]>} ニュースアイテムの配列
 */
export async function fetchRelatedNews(
  topicText: string,
  category: TopicCategory
): Promise<NewsItem[]> {
  try {
    const generativeModel = vertexAI.getGenerativeModel({
      model: "gemini-2.0-flash-exp", // Search Grounding対応モデル
    });

    const prompt = `以下のトピックに関連する最新ニュースを3件検索し、要約してください。

トピック: "${topicText}"
カテゴリ: ${CATEGORY_LABELS[category]}

各ニュースについて以下の情報を含めてください：
- タイトル
- 要約（100文字程度）
- 情報源
- URL（可能な場合）

出力形式（JSON配列）：
[
  {
    "title": "ニュースタイトル",
    "summary": "要約",
    "source": "情報源",
    "url": "URL"
  }
]`;

    // Note: Google Search Groundingはモデルによっては利用不可の場合があります
    const result = await generativeModel.generateContent(prompt);

    const response = result.response;
    const text = response.candidates?.[0]?.content?.parts?.[0]?.text || "[]";

    // JSONを抽出
    const jsonMatch = text.match(/\[[\s\S]*\]/);
    if (!jsonMatch) {
      return [];
    }

    const newsItems = JSON.parse(jsonMatch[0]);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    return newsItems.map((item: any) => ({
      title: item.title || "",
      summary: item.summary || "",
      url: item.url,
      source: item.source,
      publishedAt: new Date(),
    }));
  } catch (error) {
    logger.warn("Error fetching related news:", error);
    // ニュース取得失敗は致命的ではないので空配列を返す
    return [];
  }
}

/**
 * 完全なトピックを生成
 * @param {TopicCategory} category トピックカテゴリ（省略可）
 * @param {TopicDifficulty} difficulty トピック難易度（省略可）
 * @return {Promise<Topic>} 生成されたトピック
 */
export async function generateTopic(
  category?: TopicCategory,
  difficulty?: TopicDifficulty
): Promise<Topic> {
  // ランダムにカテゴリと難易度を選択（指定がない場合）
  const selectedCategory = category ||
    (["daily", "social", "value"][
      Math.floor(Math.random() * 3)
    ] as TopicCategory);

  const selectedDifficulty = difficulty ||
    (["easy", "medium", "hard"][
      Math.floor(Math.random() * 3)
    ] as TopicDifficulty);

  logger.info(`Generating topic - Category: ${selectedCategory}, ` +
    `Difficulty: ${selectedDifficulty}`);

  // 1. トピックテキストを生成
  const topicText = await generateTopicText(
    selectedCategory,
    selectedDifficulty
  );
  logger.info(`Generated topic text: ${topicText}`);

  // 2. トピックを分類（より正確なカテゴリ・難易度・タグを取得）
  const classification = await classifyTopic(topicText);
  logger.info("Classification result:", classification);

  // 3. 関連ニュースを取得
  const relatedNews = await fetchRelatedNews(
    topicText,
    classification.category
  );
  logger.info(`Fetched ${relatedNews.length} related news items`);

  // 4. トピックオブジェクトを構築
  const topic: Topic = {
    id: "topic_" + Date.now() + "_" + Math.random().toString(36).substr(2, 9),
    text: topicText,
    category: classification.category,
    difficulty: classification.difficulty,
    createdAt: new Date(),
    source: "ai" as TopicSource,
    tags: classification.tags,
    similarityScore: 0,
    relatedNews: relatedNews,
    feedbackCounts: {
      good: 0,
      normal: 0,
      bad: 0,
    },
    feedbackUsers: {},
  };

  return topic;
}

/**
 * 複数のトピックを生成（重複チェック付き）
 * @param {number} count 生成するトピック数
 * @param {Topic[]} existingTopics 既存のトピック配列
 * @return {Promise<Topic[]>} 生成されたトピックの配列
 */
export async function generateMultipleTopics(
  count: number,
  existingTopics: Topic[] = []
): Promise<Topic[]> {
  const topics: Topic[] = [];
  const maxRetries = count * 3; // 重複が多い場合のための再試行上限
  let retries = 0;

  while (topics.length < count && retries < maxRetries) {
    const topic = await generateTopic();

    // 重複チェック
    const isDuplicate = existingTopics
      .concat(topics)
      .some((existingTopic) =>
        calculateSimilarity(topic.text, existingTopic.text) > 0.8
      );

    if (!isDuplicate) {
      topics.push(topic);
    } else {
      logger.info("Duplicate topic detected, retrying...");
    }

    retries++;
  }

  if (topics.length < count) {
    logger.warn(`Could only generate ${topics.length} unique topics ` +
      `out of ${count} requested`);
  }

  return topics;
}

/**
 * 文字列の類似度を計算（レーベンシュタイン距離ベース）
 * @param {string} str1 文字列1
 * @param {string} str2 文字列2
 * @return {number} 類似度（0-1の範囲）
 */
function calculateSimilarity(str1: string, str2: string): number {
  const len1 = str1.length;
  const len2 = str2.length;
  const matrix: number[][] = [];

  for (let i = 0; i <= len1; i++) {
    matrix[i] = [i];
  }

  for (let j = 0; j <= len2; j++) {
    matrix[0][j] = j;
  }

  for (let i = 1; i <= len1; i++) {
    for (let j = 1; j <= len2; j++) {
      const cost = str1[i - 1] === str2[j - 1] ? 0 : 1;
      matrix[i][j] = Math.min(
        matrix[i - 1][j] + 1, // 削除
        matrix[i][j - 1] + 1, // 挿入
        matrix[i - 1][j - 1] + cost // 置換
      );
    }
  }

  const distance = matrix[len1][len2];
  const maxLength = Math.max(len1, len2);
  return 1 - distance / maxLength;
}

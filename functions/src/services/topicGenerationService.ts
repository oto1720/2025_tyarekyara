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
import {findDuplicates} from "./topicDuplicateDetector";
import {
  recommendCategory,
  recommendDifficulty,
} from "./topicQualityService";
import {
  recommendBalancedCategory,
  recommendBalancedDifficulty,
} from "./categoryBalanceService";

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
 * @param {string[]} avoidTopics 避けるべきトピック（重複防止用）
 * @return {Promise<string>} 生成されたトピックテキスト
 */
export async function generateTopicText(
  category: TopicCategory,
  difficulty: TopicDifficulty,
  avoidTopics: string[] = []
): Promise<string> {
  const generativeModel = vertexAI.getGenerativeModel({
    model: MODEL_CONFIG.model,
    generationConfig: {
      temperature: 0.7, // 多様性を高めるために上げる
      maxOutputTokens: MODEL_CONFIG.maxOutputTokens,
      topP: MODEL_CONFIG.topP,
      topK: MODEL_CONFIG.topK,
    },
  });

  // 避けるべきトピックリストを整形
  const avoidTopicsSection = avoidTopics.length > 0 ? `

## 避けるべきトピック（これらと似た内容は生成しないでください）
以下のトピックとは異なる、新しいトピックを生成してください：
${avoidTopics.map((topic, index) => `${index + 1}. ${topic}`).join("\n")}
` : "";

  const prompt = `あなたは議論を促すトピックを生成するアシスタントです。

## 条件
- トピックは簡潔で明確にしてください（1-2文程度）
- 多様な意見が出やすいテーマを選んでください
- 議論を促す形式（問いかけ形式など）にしてください
- 具体的すぎず、抽象的すぎないバランスを取ってください
- 論争的すぎず、建設的な議論ができるテーマにしてください

## 重要：意見を表明しやすいトピックにする
- ユーザーが「賛成」「反対」「中立」のいずれかの立場を明確に取れるテーマにしてください
- 事実確認の問題（「○○は存在するか？」など）ではなく、意見や価値判断を求める問題にしてください
- Yes/Noで単純に答えられる質問ではなく、理由や背景を含めて立場を表明できる形式にしてください
- 「〜べきか？」「〜は良いことか？」「〜は必要か？」などの形式が適しています

## 良い例
- 「リモートワークは今後の標準的な働き方になるべきか？」（賛成・反対・中立が取りやすい）
- 「SNSは社会にとってプラスかマイナスか？」（立場を表明しやすい）
- 「学校教育にAIを導入すべきか？」（意見が分かれるテーマ）

## 悪い例
- 「東京の人口は何人か？」（事実確認で意見ではない）
- 「朝食は食べるべきか？」（単純すぎて議論になりにくい）
- 「宇宙人は存在するか？」（事実確認で立場が取りにくい）

## カテゴリ: ${CATEGORY_LABELS[category]}
## 難易度: ${DIFFICULTY_LABELS[difficulty]}${avoidTopicsSection}

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
 * @param {Topic[]} existingTopics 既存のトピック（重複防止用）
 * @return {Promise<Topic>} 生成されたトピック
 */
export async function generateTopic(
  category?: TopicCategory,
  difficulty?: TopicDifficulty,
  existingTopics: Topic[] = []
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

  // 既存のトピックテキストを抽出
  const avoidTopics = existingTopics.map((t) => t.text);

  // 1. トピックテキストを生成
  const topicText = await generateTopicText(
    selectedCategory,
    selectedDifficulty,
    avoidTopics
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
    // 既存のトピック + これまでに生成したトピックを避けるリストとして渡す
    const allExistingTopics = existingTopics.concat(topics);
    const topic = await generateTopic(undefined, undefined, allExistingTopics);

    // 高度な重複チェック
    const allExistingTexts = allExistingTopics.map((t) => t.text);
    const duplicateCheck = findDuplicates(topic.text, allExistingTexts, 0.75);

    if (!duplicateCheck.hasDuplicates) {
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
 * スマートトピック生成（全自動最適化版）
 * - 品質評価に基づくカテゴリ推薦
 * - バランスを考慮した難易度選択
 * - 高度な重複検出
 * @param {Topic[]} existingTopics 既存のトピック配列
 * @return {Promise<Topic>} 生成されたトピック
 */
export async function generateSmartTopic(
  existingTopics: Topic[] = []
): Promise<Topic> {
  logger.info("Starting smart topic generation with optimization");

  // 1. 品質評価に基づくカテゴリ推薦
  const qualityCategory = await recommendCategory();

  // 2. バランスを考慮したカテゴリ推薦
  const balancedCategory = await recommendBalancedCategory(7);

  // 3. 両方を考慮して最終決定（品質を優先、バランスも考慮）
  const finalCategory = Math.random() > 0.3 ?
    qualityCategory :
    balancedCategory;

  logger.info("Category selection:", {
    qualityRecommendation: qualityCategory,
    balanceRecommendation: balancedCategory,
    finalSelection: finalCategory,
  });

  // 4. 品質評価とバランスを考慮した難易度決定
  const qualityDifficulty = await recommendDifficulty();
  const balancedDifficulty = await recommendBalancedDifficulty(7);

  const finalDifficulty = Math.random() > 0.4 ?
    qualityDifficulty :
    balancedDifficulty;

  logger.info("Difficulty selection:", {
    qualityRecommendation: qualityDifficulty,
    balanceRecommendation: balancedDifficulty,
    finalSelection: finalDifficulty,
  });

  // 5. トピック生成（重複チェック付き）
  const maxRetries = 5;
  let retries = 0;
  const rejectedTopics: Topic[] = []; // リトライ時に重複判定されたトピックを蓄積

  while (retries < maxRetries) {
    // 既存のトピック + これまでに重複判定されたトピックを避けるリストとして渡す
    const allExistingTopics = existingTopics.concat(rejectedTopics);
    const topic = await generateTopic(
      finalCategory,
      finalDifficulty,
      allExistingTopics
    );

    // 高度な重複検出を実施
    const existingTexts = allExistingTopics.map((t) => t.text);
    const duplicateCheck = findDuplicates(topic.text, existingTexts, 0.75);

    if (!duplicateCheck.hasDuplicates) {
      logger.info("Smart topic generated successfully:", {
        text: topic.text,
        category: topic.category,
        difficulty: topic.difficulty,
        retries,
      });
      return topic;
    }

    logger.warn("Duplicate detected, regenerating...", {
      attempt: retries + 1,
      maxSimilarity: duplicateCheck.maxSimilarity,
      duplicates: duplicateCheck.duplicates.length,
    });

    // 重複判定されたトピックを記録（次回のリトライで避ける）
    rejectedTopics.push(topic);

    retries++;
  }

  // 最大試行回数に達した場合でも最後に生成したものを返す
  logger.warn("Max retries reached, using last generated topic");
  const allExistingTopics = existingTopics.concat(rejectedTopics);
  return generateTopic(finalCategory, finalDifficulty, allExistingTopics);
}

/**
 * カテゴリバランスサービス
 * 日によってカテゴリを調整し、多様性を確保
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {TopicCategory, TopicDifficulty} from "../types/topic";

/**
 * カテゴリ使用履歴
 */
export interface CategoryHistory {
  date: string;
  category: TopicCategory;
  difficulty: TopicDifficulty;
}

/**
 * カテゴリバランス統計
 */
export interface CategoryBalance {
  daily: number;
  social: number;
  value: number;
  totalDays: number;
}

/**
 * 曜日ベースのカテゴリ推薦マッピング
 */
const WEEKDAY_CATEGORY_MAP: Record<number, TopicCategory[]> = {
  0: ["daily", "value"], // 日曜日: リラックスした話題
  1: ["social", "daily"], // 月曜日: 社会問題で活発に
  2: ["daily", "social"], // 火曜日: バランス
  3: ["value", "social"], // 水曜日: 深い話題
  4: ["social", "daily"], // 木曜日: 社会問題
  5: ["daily", "value"], // 金曜日: 軽めの話題
  6: ["value", "daily"], // 土曜日: 価値観について
};

/**
 * 過去のカテゴリ使用履歴を取得
 * @param {number} days 取得する日数
 * @return {Promise<CategoryHistory[]>} カテゴリ使用履歴
 */
export async function getCategoryHistory(
  days = 14
): Promise<CategoryHistory[]> {
  const db = admin.firestore();
  const history: CategoryHistory[] = [];

  try {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);

    const snapshot = await db
      .collection("daily_topics")
      .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(cutoffDate))
      .orderBy("createdAt", "desc")
      .get();

    snapshot.forEach((doc) => {
      const data = doc.data();
      const date = doc.id; // ドキュメントIDがYYYY-MM-DD形式

      history.push({
        date,
        category: data.category as TopicCategory,
        difficulty: data.difficulty as TopicDifficulty,
      });
    });

    return history;
  } catch (error) {
    logger.error("Error fetching category history:", error);
    return [];
  }
}

/**
 * カテゴリのバランスを分析
 * @param {number} days 分析する日数
 * @return {Promise<CategoryBalance>} カテゴリバランス
 */
export async function analyzeCategoryBalance(
  days = 14
): Promise<CategoryBalance> {
  const history = await getCategoryHistory(days);

  const balance: CategoryBalance = {
    daily: 0,
    social: 0,
    value: 0,
    totalDays: history.length,
  };

  history.forEach((record) => {
    balance[record.category]++;
  });

  logger.info("Category balance analysis:", balance);

  return balance;
}

/**
 * 最近のカテゴリ傾向を考慮して次のカテゴリを推薦
 * @param {number} recentDays 最近の日数
 * @return {Promise<TopicCategory>} 推薦カテゴリ
 */
export async function recommendBalancedCategory(
  recentDays = 7
): Promise<TopicCategory> {
  const history = await getCategoryHistory(recentDays);

  // 曜日ベースの推薦を取得
  const today = new Date();
  const dayOfWeek = today.getDay();
  const weekdayPreferences = WEEKDAY_CATEGORY_MAP[dayOfWeek];

  // 最近の使用頻度をカウント
  const recentUsage: Record<TopicCategory, number> = {
    daily: 0,
    social: 0,
    value: 0,
  };

  history.forEach((record) => {
    recentUsage[record.category]++;
  });

  // 最も使われていないカテゴリを優先
  const leastUsedCategories = (
    Object.entries(recentUsage) as [TopicCategory, number][]
  )
    .sort((a, b) => a[1] - b[1])
    .map(([cat]) => cat);

  // 曜日の推薦と使用頻度を組み合わせて決定
  let recommendedCategory: TopicCategory;

  // 曜日推薦の中で最も使われていないものを選択
  const weekdayLeastUsed = weekdayPreferences.find((cat) =>
    leastUsedCategories.slice(0, 2).includes(cat)
  );

  if (weekdayLeastUsed) {
    recommendedCategory = weekdayLeastUsed;
  } else {
    // フォールバック: 最も使われていないカテゴリ
    recommendedCategory = leastUsedCategories[0];
  }

  logger.info("Balanced category recommendation:", {
    dayOfWeek,
    weekdayPreferences,
    recentUsage,
    leastUsed: leastUsedCategories,
    recommended: recommendedCategory,
  });

  return recommendedCategory;
}

/**
 * バランスを考慮した難易度を推薦
 * @param {number} recentDays 最近の日数
 * @return {Promise<TopicDifficulty>} 推薦難易度
 */
export async function recommendBalancedDifficulty(
  recentDays = 7
): Promise<TopicDifficulty> {
  const history = await getCategoryHistory(recentDays);

  // 最近の使用頻度をカウント
  const recentUsage: Record<TopicDifficulty, number> = {
    easy: 0,
    medium: 0,
    hard: 0,
  };

  history.forEach((record) => {
    recentUsage[record.difficulty]++;
  });

  // 理想的な配分（easy: 30%, medium: 50%, hard: 20%）
  const idealRatio = {
    easy: 0.3,
    medium: 0.5,
    hard: 0.2,
  };

  // 現在の配分を計算
  const totalDays = history.length || 1;
  const currentRatio = {
    easy: recentUsage.easy / totalDays,
    medium: recentUsage.medium / totalDays,
    hard: recentUsage.hard / totalDays,
  };

  // 理想との差が大きいものを優先
  const difficultyScores = (
    Object.entries(idealRatio) as [TopicDifficulty, number][]
  ).map(([diff, ideal]) => ({
    difficulty: diff,
    gap: ideal - currentRatio[diff], // ギャップが大きいほど優先
  }));

  const recommended = difficultyScores.sort((a, b) => b.gap - a.gap)[0]
    .difficulty;

  logger.info("Balanced difficulty recommendation:", {
    recentUsage,
    currentRatio,
    idealRatio,
    gaps: difficultyScores,
    recommended,
  });

  return recommended;
}

/**
 * 曜日パターンに基づく多様性スコアを計算
 * @param {number} days 分析する日数
 * @return {Promise<number>} 多様性スコア（0-1）
 */
export async function calculateDiversityScore(
  days = 14
): Promise<number> {
  const history = await getCategoryHistory(days);

  if (history.length === 0) return 0;

  // カテゴリの種類数
  const uniqueCategories = new Set(history.map((h) => h.category)).size;
  const categoryDiversity = uniqueCategories / 3; // 3種類のカテゴリ

  // 難易度の種類数
  const uniqueDifficulties = new Set(history.map((h) => h.difficulty)).size;
  const difficultyDiversity = uniqueDifficulties / 3; // 3種類の難易度

  // 連続して同じカテゴリが使われていないかチェック
  let consecutiveCount = 0;
  let maxConsecutive = 0;
  let prevCategory = "";

  history.forEach((record) => {
    if (record.category === prevCategory) {
      consecutiveCount++;
      maxConsecutive = Math.max(maxConsecutive, consecutiveCount);
    } else {
      consecutiveCount = 1;
      prevCategory = record.category;
    }
  });

  const consecutivePenalty = Math.max(0, 1 - maxConsecutive / 5);

  const diversityScore =
    (categoryDiversity * 0.4 +
      difficultyDiversity * 0.3 +
      consecutivePenalty * 0.3);

  logger.info("Diversity score calculation:", {
    categoryDiversity,
    difficultyDiversity,
    maxConsecutive,
    consecutivePenalty,
    diversityScore,
  });

  return diversityScore;
}

/**
 * 週間カテゴリプランを生成（7日分）
 * @return {Promise<Array>} 週間プラン
 */
export async function generateWeeklyPlan(): Promise<
  Array<{
    dayOfWeek: number;
    dayName: string;
    recommendedCategory: TopicCategory;
    reason: string;
  }>
  > {
  const dayNames = [
    "日曜日",
    "月曜日",
    "火曜日",
    "水曜日",
    "木曜日",
    "金曜日",
    "土曜日",
  ];

  const categoryReasons: Record<TopicCategory, string> = {
    daily: "日常的で親しみやすいトピック",
    social: "社会問題で議論を活発化",
    value: "価値観について深く考える",
  };

  const plan = [];

  for (let day = 0; day < 7; day++) {
    const preferences = WEEKDAY_CATEGORY_MAP[day];
    const recommendedCategory = preferences[0];

    plan.push({
      dayOfWeek: day,
      dayName: dayNames[day],
      recommendedCategory,
      reason: categoryReasons[recommendedCategory],
    });
  }

  return plan;
}

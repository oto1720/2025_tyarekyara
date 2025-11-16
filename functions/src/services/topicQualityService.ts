/**
 * トピック品質評価サービス
 * ユーザーフィードバックに基づいてトピックの品質を評価し、生成を改善
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {TopicCategory, TopicDifficulty} from "../types/topic";

/**
 * トピック品質スコア
 */
export interface QualityScore {
  overall: number; // 総合スコア（0-100）
  engagementRate: number; // エンゲージメント率
  positiveRate: number; // ポジティブ評価率
  debateParticipation: number; // ディベート参加率
  completionRate: number; // ディベート完遂率
  recommendationScore: number; // 推薦スコア
}

/**
 * カテゴリ別パフォーマンス統計
 */
export interface CategoryPerformance {
  category: TopicCategory;
  averageScore: number;
  totalTopics: number;
  positiveCount: number;
  negativeCount: number;
  participationRate: number;
}

/**
 * 難易度別パフォーマンス統計
 */
export interface DifficultyPerformance {
  difficulty: TopicDifficulty;
  averageScore: number;
  totalTopics: number;
  positiveCount: number;
  negativeCount: number;
  participationRate: number;
}

/**
 * トピックの品質スコアを計算
 * @param {string} topicId トピックID
 * @return {Promise<QualityScore>} 品質スコア
 */
export async function calculateQualityScore(
  topicId: string
): Promise<QualityScore> {
  const db = admin.firestore();

  try {
    // トピックのフィードバックデータを取得
    const topicsSnapshot = await db
      .collection("daily_topics")
      .where("id", "==", topicId)
      .limit(1)
      .get();

    if (topicsSnapshot.empty) {
      throw new Error("Topic not found");
    }

    const topicData = topicsSnapshot.docs[0].data();
    const feedbackCounts = topicData.feedbackCounts || {};
    const totalFeedback =
      (feedbackCounts.good || 0) +
      (feedbackCounts.normal || 0) +
      (feedbackCounts.bad || 0);

    // ディベートイベントデータを取得
    const eventsSnapshot = await db.collection("debate_events")
      .where("topicId", "==", topicId).get();

    let totalParticipants = 0;
    let completedDebates = 0;
    let totalDebates = 0;

    eventsSnapshot.forEach((doc) => {
      const eventData = doc.data();
      totalParticipants += eventData.currentParticipants || 0;
      totalDebates++;
      if (eventData.status === "completed") {
        completedDebates++;
      }
    });

    // スコア計算
    const positiveRate = totalFeedback > 0 ?
      (feedbackCounts.good || 0) / totalFeedback :
      0;

    const engagementRate = totalFeedback > 0 ?
      Math.min(totalFeedback / 10, 1) :
      0;

    const debateParticipation = totalDebates > 0 ?
      Math.min(totalParticipants / 20, 1) :
      0;

    const completionRate = totalDebates > 0 ?
      completedDebates / totalDebates :
      0;

    // 総合スコア計算（重み付き平均）
    const recommendationScore =
      positiveRate * 0.4 +
      engagementRate * 0.2 +
      debateParticipation * 0.25 +
      completionRate * 0.15;

    const overall = recommendationScore * 100;

    return {
      overall,
      engagementRate,
      positiveRate,
      debateParticipation,
      completionRate,
      recommendationScore,
    };
  } catch (error) {
    logger.error("Error calculating quality score:", error);
    throw error;
  }
}

/**
 * カテゴリ別のパフォーマンスを分析
 * @param {number} days 分析する日数
 * @return {Promise<CategoryPerformance[]>} カテゴリ別パフォーマンス
 */
export async function analyzeCategoryPerformance(
  days = 30
): Promise<CategoryPerformance[]> {
  const db = admin.firestore();

  try {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);

    const snapshot = await db
      .collection("daily_topics")
      .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(cutoffDate))
      .get();

    const performanceMap = new Map<
      TopicCategory,
      {
        scores: number[];
        totalTopics: number;
        positiveCount: number;
        negativeCount: number;
        totalParticipants: number;
      }
    >();

    // 初期化
    (["daily", "social", "value"] as TopicCategory[]).forEach((cat) => {
      performanceMap.set(cat, {
        scores: [],
        totalTopics: 0,
        positiveCount: 0,
        negativeCount: 0,
        totalParticipants: 0,
      });
    });

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const category = data.category as TopicCategory;
      const feedbackCounts = data.feedbackCounts || {};

      const performance = performanceMap.get(category);
      if (!performance) continue;

      performance.totalTopics++;
      performance.positiveCount += feedbackCounts.good || 0;
      performance.negativeCount += feedbackCounts.bad || 0;

      // 品質スコアを計算
      const qualityScore = await calculateQualityScore(data.id);
      performance.scores.push(qualityScore.overall);

      // 参加者数を取得
      const eventsSnapshot = await db
        .collection("debate_events")
        .where("topicId", "==", data.id)
        .get();

      eventsSnapshot.forEach((eventDoc) => {
        const eventData = eventDoc.data();
        performance.totalParticipants +=
          eventData.currentParticipants || 0;
      });
    }

    const result: CategoryPerformance[] = [];

    performanceMap.forEach((perf, category) => {
      const averageScore = perf.scores.length > 0 ?
        perf.scores.reduce((a, b) => a + b, 0) / perf.scores.length :
        0;

      const participationRate = perf.totalTopics > 0 ?
        perf.totalParticipants / (perf.totalTopics * 20) :
        0;

      result.push({
        category,
        averageScore,
        totalTopics: perf.totalTopics,
        positiveCount: perf.positiveCount,
        negativeCount: perf.negativeCount,
        participationRate: Math.min(participationRate, 1),
      });
    });

    return result;
  } catch (error) {
    logger.error("Error analyzing category performance:", error);
    return [];
  }
}

/**
 * 難易度別のパフォーマンスを分析
 * @param {number} days 分析する日数
 * @return {Promise<DifficultyPerformance[]>} 難易度別パフォーマンス
 */
export async function analyzeDifficultyPerformance(
  days = 30
): Promise<DifficultyPerformance[]> {
  const db = admin.firestore();

  try {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);

    const snapshot = await db
      .collection("daily_topics")
      .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(cutoffDate))
      .get();

    const performanceMap = new Map<
      TopicDifficulty,
      {
        scores: number[];
        totalTopics: number;
        positiveCount: number;
        negativeCount: number;
        totalParticipants: number;
      }
    >();

    // 初期化
    (["easy", "medium", "hard"] as TopicDifficulty[]).forEach((diff) => {
      performanceMap.set(diff, {
        scores: [],
        totalTopics: 0,
        positiveCount: 0,
        negativeCount: 0,
        totalParticipants: 0,
      });
    });

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const difficulty = data.difficulty as TopicDifficulty;
      const feedbackCounts = data.feedbackCounts || {};

      const performance = performanceMap.get(difficulty);
      if (!performance) continue;

      performance.totalTopics++;
      performance.positiveCount += feedbackCounts.good || 0;
      performance.negativeCount += feedbackCounts.bad || 0;

      // 品質スコアを計算
      const qualityScore = await calculateQualityScore(data.id);
      performance.scores.push(qualityScore.overall);

      // 参加者数を取得
      const eventsSnapshot = await db
        .collection("debate_events")
        .where("topicId", "==", data.id)
        .get();

      eventsSnapshot.forEach((eventDoc) => {
        const eventData = eventDoc.data();
        performance.totalParticipants +=
          eventData.currentParticipants || 0;
      });
    }

    const result: DifficultyPerformance[] = [];

    performanceMap.forEach((perf, difficulty) => {
      const averageScore = perf.scores.length > 0 ?
        perf.scores.reduce((a, b) => a + b, 0) / perf.scores.length :
        0;

      const participationRate = perf.totalTopics > 0 ?
        perf.totalParticipants / (perf.totalTopics * 20) :
        0;

      result.push({
        difficulty,
        averageScore,
        totalTopics: perf.totalTopics,
        positiveCount: perf.positiveCount,
        negativeCount: perf.negativeCount,
        participationRate: Math.min(participationRate, 1),
      });
    });

    return result;
  } catch (error) {
    logger.error("Error analyzing difficulty performance:", error);
    return [];
  }
}

/**
 * パフォーマンス分析に基づいて最適なカテゴリを推薦
 * @return {Promise<TopicCategory>} 推薦カテゴリ
 */
export async function recommendCategory(): Promise<TopicCategory> {
  const performance = await analyzeCategoryPerformance(30);

  if (performance.length === 0) {
    // データがない場合はランダム
    const categories: TopicCategory[] = ["daily", "social", "value"];
    return categories[Math.floor(Math.random() * categories.length)];
  }

  // スコアが最も高いカテゴリを推薦
  const sorted = performance.sort((a, b) => b.averageScore - a.averageScore);

  logger.info("Category recommendation based on performance:", {
    recommended: sorted[0].category,
    scores: performance.map((p) => ({
      category: p.category,
      score: p.averageScore,
    })),
  });

  return sorted[0].category;
}

/**
 * パフォーマンス分析に基づいて最適な難易度を推薦
 * @return {Promise<TopicDifficulty>} 推薦難易度
 */
export async function recommendDifficulty(): Promise<TopicDifficulty> {
  const performance = await analyzeDifficultyPerformance(30);

  if (performance.length === 0) {
    // データがない場合はmedium
    return "medium";
  }

  // スコアが最も高い難易度を推薦
  const sorted = performance.sort((a, b) => b.averageScore - a.averageScore);

  logger.info("Difficulty recommendation based on performance:", {
    recommended: sorted[0].difficulty,
    scores: performance.map((p) => ({
      difficulty: p.difficulty,
      score: p.averageScore,
    })),
  });

  return sorted[0].difficulty;
}

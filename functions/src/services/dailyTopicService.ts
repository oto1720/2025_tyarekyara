/**
 * 日別トピック管理サービス
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {generateTopic} from "./topicGenerationService";
import {Topic, TopicGenerationResult} from "../types/topic";

/**
 * 今日の日付を YYYY-MM-DD 形式で取得
 * @return {string} YYYY-MM-DD形式の日付文字列
 */
function getTodayDateString(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

/**
 * 今日のトピックを取得
 */
export async function getTodayTopic(): Promise<Topic | null> {
  const todayDate = getTodayDateString();
  const db = admin.firestore();

  try {
    const docRef = db.collection("daily_topics").doc(todayDate);
    const doc = await docRef.get();

    if (doc.exists) {
      const data = doc.data();
      if (data) {
        return {
          ...data,
          createdAt: data.createdAt?.toDate() || new Date(),
          relatedNews: data.relatedNews || [],
          feedbackCounts: data.feedbackCounts || {},
          feedbackUsers: data.feedbackUsers || {},
        } as Topic;
      }
    }

    return null;
  } catch (error) {
    logger.error("Error fetching today's topic:", error);
    return null;
  }
}

/**
 * 今日のトピックを生成してFirestoreに保存
 */
export async function createTodayTopic(): Promise<TopicGenerationResult> {
  const todayDate = getTodayDateString();
  const db = admin.firestore();

  try {
    // 既に今日のトピックが存在するかチェック
    const existingTopic = await getTodayTopic();
    if (existingTopic) {
      logger.info(`Topic for ${todayDate} already exists`);
      // 既存のイベントIDを探す
      const eventsSnapshot = await db
        .collection("debate_events")
        .where("topic", "==", existingTopic.text)
        .where("date", "==", todayDate)
        .limit(1)
        .get();

      const eventId = eventsSnapshot.empty ?
        undefined :
        eventsSnapshot.docs[0].id;

      return {
        topic: existingTopic,
        eventId,
      };
    }

    // 新しいトピックを生成
    logger.info(`Generating new topic for ${todayDate}`);
    const topic = await generateTopic();

    // Firestoreに保存
    const topicData = {
      id: topic.id,
      text: topic.text,
      category: topic.category,
      difficulty: topic.difficulty,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      source: topic.source,
      tags: topic.tags,
      description: topic.description || null,
      similarityScore: topic.similarityScore,
      relatedNews: topic.relatedNews.map((news) => ({
        title: news.title,
        summary: news.summary,
        url: news.url || null,
        source: news.source || null,
        publishedAt: news.publishedAt ?
          admin.firestore.Timestamp.fromDate(news.publishedAt) :
          null,
        imageUrl: news.imageUrl || null,
      })),
      feedbackCounts: topic.feedbackCounts,
      feedbackUsers: topic.feedbackUsers,
    };

    await db.collection("daily_topics").doc(todayDate).set(topicData);
    logger.info(`Topic saved for ${todayDate}`);

    // ディベートイベントを作成
    const eventId = await createDebateEvent(topic, todayDate);

    return {
      topic,
      eventId,
    };
  } catch (error) {
    logger.error("Error creating today's topic:", error);
    throw error;
  }
}

/**
 * トピックからディベートイベントを作成
 * @param {Topic} topic トピックオブジェクト
 * @param {string} date 日付文字列 (YYYY-MM-DD)
 * @return {Promise<string>} イベントID
 */
async function createDebateEvent(
  topic: Topic,
  date: string
): Promise<string> {
  const db = admin.firestore();

  try {
    // イベント開始時刻: 今日の12:00（正午）
    const eventDate = new Date(date);
    eventDate.setHours(12, 0, 0, 0);

    // イベント終了時刻: 今日の23:59
    const endDate = new Date(date);
    endDate.setHours(23, 59, 59, 999);

    const eventData = {
      id: `event_${date}_${topic.id}`,
      topic: topic.text,
      topicId: topic.id,
      category: topic.category,
      difficulty: topic.difficulty,
      date: date,
      startTime: admin.firestore.Timestamp.fromDate(eventDate),
      endTime: admin.firestore.Timestamp.fromDate(endDate),
      status: "scheduled", // scheduled, active, completed, cancelled
      maxParticipants: 100, // 最大参加者数
      currentParticipants: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const eventRef = db.collection("debate_events").doc(eventData.id);
    await eventRef.set(eventData);

    logger.info(`Debate event created: ${eventData.id}`);
    return eventData.id;
  } catch (error) {
    logger.error("Error creating debate event:", error);
    throw error;
  }
}

/**
 * 過去のトピックを取得（重複チェック用）
 * @param {number} days 取得する日数
 * @return {Promise<Topic[]>} トピックの配列
 */
export async function getRecentTopics(days = 30): Promise<Topic[]> {
  const db = admin.firestore();
  const topics: Topic[] = [];

  try {
    const snapshot = await db
      .collection("daily_topics")
      .orderBy("createdAt", "desc")
      .limit(days)
      .get();

    snapshot.forEach((doc) => {
      const data = doc.data();
      topics.push({
        ...data,
        createdAt: data.createdAt?.toDate() || new Date(),
        relatedNews: data.relatedNews || [],
        feedbackCounts: data.feedbackCounts || {},
        feedbackUsers: data.feedbackUsers || {},
      } as Topic);
    });

    return topics;
  } catch (error) {
    logger.error("Error fetching recent topics:", error);
    return [];
  }
}

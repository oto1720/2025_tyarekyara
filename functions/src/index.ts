/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
import {onDocumentUpdated, onDocumentCreated} from "firebase-functions/v2/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {getMessaging} from "firebase-admin/messaging";
import {judgeDebate} from "./services/debateJudgmentService";
import {processMatching} from "./services/debateMatchingService";
import {updateEventStatuses} from "./services/eventStatusService";
import {progressDebatePhases} from "./services/debatePhaseService";
import {createTodayTopic} from "./services/dailyTopicService";

// Firebase Admin初期化
admin.initializeApp();

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

/**
 * ディベート終了時にAI判定を実行
 */
export const onDebateComplete = onDocumentUpdated(
  {
    document: "debate_rooms/{roomId}",
    region: "asia-northeast1",
  },
  async (event) => {
    const roomId = event.params.roomId;
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) {
      logger.warn("No data in event");
      return;
    }

    // ステータスがcompletedに変わった場合のみ実行
    if (before.status !== "completed" && after.status === "completed") {
      try {
        logger.info(`Starting AI judgment for room: ${roomId}`);

        // イベント情報を取得
        const eventDoc = await admin
          .firestore()
          .collection("debate_events")
          .doc(after.eventId)
          .get();

        const eventData = eventDoc.data();
        if (!eventData) {
          throw new Error("Event not found");
        }

        // AI判定を実行
        const judgment = await judgeDebate(roomId, eventData.topic);

        // 判定結果を保存
        const judgmentId = `judgment_${after.matchId}`;
        await admin
          .firestore()
          .collection("debate_judgments")
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
          .collection("debate_matches")
          .doc(after.matchId)
          .update({
            status: "completed",
            winningSide: judgment.winningSide,
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        logger.info(`AI judgment completed for room: ${roomId}`);
      } catch (error) {
        logger.error("Error in AI judgment:", error);
        // エラー通知など
      }
    }

    return null;
  }
);

/**
 * 手動判定トリガー（デバッグ用）
 */
export const manualJudgeDebate = onCall(
  {
    region: "asia-northeast1",
  },
  async (request) => {
    // 認証チェック
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    const {roomId} = request.data;

    if (!roomId) {
      throw new HttpsError("invalid-argument", "roomId is required");
    }

    try {
      const roomDoc = await admin
        .firestore()
        .collection("debate_rooms")
        .doc(roomId)
        .get();

      const roomData = roomDoc.data();
      if (!roomData) {
        throw new HttpsError("not-found", "Room not found");
      }

      const eventDoc = await admin
        .firestore()
        .collection("debate_events")
        .doc(roomData.eventId)
        .get();

      const eventData = eventDoc.data();
      if (!eventData) {
        throw new HttpsError("not-found", "Event not found");
      }

      const judgment = await judgeDebate(roomId, eventData.topic);

      return {
        success: true,
        judgment,
      };
    } catch (error) {
      logger.error("Error in manual judgment:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Judgment failed");
    }
  }
);

/**
 * マッチング処理（1分ごとに実行）
 */
export const scheduledMatching = onSchedule(
  {
    schedule: "every 1 minutes",
    region: "asia-northeast1",
    timeZone: "Asia/Tokyo",
  },
  async () => {
    try {
      logger.info("Scheduled matching triggered");
      await processMatching();
    } catch (error) {
      logger.error("Error in scheduled matching:", error);
    }
  }
);

/**
 * 手動マッチングトリガー（デバッグ用）
 */
export const manualMatching = onCall(
  {
    region: "asia-northeast1",
  },
  async (request) => {
    // 認証チェック
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    try {
      await processMatching();
      return {
        success: true,
        message: "Matching process completed",
      };
    } catch (error) {
      logger.error("Error in manual matching:", error);
      throw new HttpsError("internal", "Matching failed");
    }
  }
);

/**
 * イベントステータス自動更新（1分ごとに実行）
 */
export const scheduledEventStatusUpdate = onSchedule(
  {
    schedule: "every 1 minutes",
    region: "asia-northeast1",
    timeZone: "Asia/Tokyo",
  },
  async () => {
    try {
      logger.info("Scheduled event status update triggered");
      await updateEventStatuses();
    } catch (error) {
      logger.error("Error in scheduled event status update:", error);
    }
  }
);

/**
 * 手動イベントステータス更新（デバッグ用）
 */
export const manualEventStatusUpdate = onCall(
  {
    region: "asia-northeast1",
  },
  async (request) => {
    // 認証チェック
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    try {
      await updateEventStatuses();
      return {
        success: true,
        message: "Event status update completed",
      };
    } catch (error) {
      logger.error("Error in manual event status update:", error);
      throw new HttpsError("internal", "Event status update failed");
    }
  }
);

/**
 * ディベートフェーズ自動進行（1分ごとに実行）
 */
export const scheduledDebatePhaseProgress = onSchedule(
  {
    schedule: "every 1 minutes",
    region: "asia-northeast1",
    timeZone: "Asia/Tokyo",
  },
  async () => {
    try {
      logger.info("Scheduled debate phase progress triggered");
      await progressDebatePhases();
    } catch (error) {
      logger.error("Error in scheduled debate phase progress:", error);
    }
  }
);

/**
 * 手動フェーズ進行（デバッグ用）
 */
export const manualDebatePhaseProgress = onCall(
  {
    region: "asia-northeast1",
  },
  async (request) => {
    // 認証チェック
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    try {
      await progressDebatePhases();
      return {
        success: true,
        message: "Debate phase progress completed",
      };
    } catch (error) {
      logger.error("Error in manual debate phase progress:", error);
      throw new HttpsError("internal", "Debate phase progress failed");
    }
  }
);

/**
 * 毎朝9時にAIトピックを自動生成
 */
export const scheduledDailyTopicGeneration = onSchedule(
  {
    schedule: "0 9 * * *", // 毎日9:00 (JST)
    region: "asia-northeast1",
    timeZone: "Asia/Tokyo",
  },
  async () => {
    try {
      logger.info("Scheduled daily topic generation triggered");
      const result = await createTodayTopic();

      logger.info(
        `Daily topic generated successfully: ${result.topic.text}`
      );
      logger.info(`Debate event created: ${result.eventId}`);
    } catch (error) {
      logger.error("Error in scheduled daily topic generation:", error);
      // エラー通知などを追加する場合はここに実装
    }
  }
);

/**
 * 手動トピック生成（デバッグ・テスト用）
 */
export const manualDailyTopicGeneration = onCall(
  {
    region: "asia-northeast1",
  },
  async (request) => {
    // 認証チェック
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    try {
      logger.info("Manual daily topic generation triggered");
      const result = await createTodayTopic();

      return {
        success: true,
        topic: {
          id: result.topic.id,
          text: result.topic.text,
          category: result.topic.category,
          difficulty: result.topic.difficulty,
          tags: result.topic.tags,
          relatedNews: result.topic.relatedNews,
        },
        eventId: result.eventId,
        message: "Daily topic generated successfully",
      };
    } catch (error) {
      logger.error("Error in manual daily topic generation:", error);
      throw new HttpsError("internal", "Topic generation failed");
    }
  }
);

/**
 * マッチング成立時にプッシュ通知を送信
 */
export const onMatchCreated = onDocumentCreated(
  {
    document: "debate_matches/{matchId}",
    region: "asia-northeast1",
  },
  async (event) => {
    const matchId = event.params.matchId;
    const matchData = event.data?.data();

    if (!matchData) {
      logger.warn("No match data in event");
      return;
    }

    try {
      logger.info(`Sending match notification for match: ${matchId}`);

      // 全参加者のユーザーIDを取得
      const proTeamIds: string[] = matchData.proTeam?.memberIds || [];
      const conTeamIds: string[] = matchData.conTeam?.memberIds || [];
      const allUserIds = [...proTeamIds, ...conTeamIds];

      if (allUserIds.length === 0) {
        logger.warn("No users to notify");
        return;
      }

      // ユーザーのFCMトークンを取得
      const tokens: string[] = [];
      for (const userId of allUserIds) {
        const userDoc = await admin
          .firestore()
          .collection("users")
          .doc(userId)
          .get();

        const userData = userDoc.data();
        if (userData?.fcmToken) {
          tokens.push(userData.fcmToken);
        }
      }

      if (tokens.length === 0) {
        logger.warn("No FCM tokens found for users");
        return;
      }

      // 通知を送信
      const message: admin.messaging.MulticastMessage = {
        tokens,
        notification: {
          title: "マッチング成立！",
          body: "対戦相手が見つかりました。ディベートの準備をしましょう！",
        },
        data: {
          matchId: matchId,
          type: "match_created",
        },
        android: {
          notification: {
            channelId: "match_notification",
            priority: "high",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const response = await getMessaging().sendEachForMulticast(message);

      logger.info(
        `Match notifications sent: ${response.successCount} successful, ` +
        `${response.failureCount} failed`
      );

      // 失敗したトークンをログ
      if (response.failureCount > 0) {
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            logger.error(
              `Failed to send to token ${tokens[idx]}: ${resp.error?.message}`
            );
          }
        });
      }
    } catch (error) {
      logger.error("Error sending match notification:", error);
    }

    return null;
  }
);

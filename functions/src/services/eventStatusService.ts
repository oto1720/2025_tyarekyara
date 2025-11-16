import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  createRoomsForEvent,
  activateRoomsForEvent,
} from "./debateRoomService";

/**
 * イベントステータスを時刻に基づいて自動更新
 */
export async function updateEventStatuses(): Promise<void> {
  try {
    logger.info("Starting event status update");

    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    let updatedCount = 0;

    // 1. 開催24時間前になったイベントを「accepting」に変更
    updatedCount += await updateScheduledToAccepting(db, now);

    // 2. エントリー締切を過ぎたイベントを「matching」に変更
    updatedCount +=
      await updateAcceptingToMatching(db, now);

    // 3. 開催時刻を過ぎたイベントを「inProgress」に変更
    updatedCount += await updateMatchingToInProgress(db, now);

    // 4. 終了時刻を過ぎたイベントを「completed」に変更
    // （開催時刻 + 2時間を終了時刻とする）
    updatedCount += await updateInProgressToCompleted(db, now);

    logger.info(
      `Event status update completed. Updated ${updatedCount} events`
    );
  } catch (error) {
    logger.error("Error in event status update:", error);
    throw error;
  }
}

/**
 * accepting → matching への更新
 * エントリー締切を過ぎたイベント
 * @param {admin.firestore.Firestore} db Firestoreインスタンス
 * @param {admin.firestore.Timestamp} now 現在時刻
 * @return {Promise<number>} 更新したイベント数
 */
async function updateAcceptingToMatching(
  db: admin.firestore.Firestore,
  now: admin.firestore.Timestamp
): Promise<number> {
  try {
    const snapshot = await db
      .collection("debate_events")
      .where("status", "==", "accepting")
      .where("entryDeadline", "<=", now)
      .get();

    logger.info(
      `Found ${snapshot.size} events past entry deadline ` +
      "(accepting -> matching)"
    );

    let count = 0;
    for (const doc of snapshot.docs) {
      const eventId = doc.id;

      // イベントステータスを更新
      await doc.ref.update({
        status: "matching",
        updatedAt: now,
      });
      logger.info(`Updated event ${eventId} to matching status`);

      // マッチング済みのマッチのルームを作成
      try {
        const roomsCreated = await createRoomsForEvent(eventId);
        logger.info(
          `Created ${roomsCreated} rooms for event ${eventId}`
        );
      } catch (error) {
        logger.error(
          `Error creating rooms for event ${eventId}:`,
          error
        );
      }

      count++;
    }

    return count;
  } catch (error) {
    logger.error("Error updating accepting to matching:", error);
    return 0;
  }
}

/**
 * matching → inProgress への更新
 * 開催時刻を過ぎたイベント
 * @param {admin.firestore.Firestore} db Firestoreインスタンス
 * @param {admin.firestore.Timestamp} now 現在時刻
 * @return {Promise<number>} 更新したイベント数
 */
async function updateMatchingToInProgress(
  db: admin.firestore.Firestore,
  now: admin.firestore.Timestamp
): Promise<number> {
  try {
    const snapshot = await db
      .collection("debate_events")
      .where("status", "==", "matching")
      .where("scheduledAt", "<=", now)
      .get();

    logger.info(
      `Found ${snapshot.size} events past scheduled time ` +
      "(matching -> inProgress)"
    );

    let count = 0;
    for (const doc of snapshot.docs) {
      const eventId = doc.id;

      // イベントステータスを更新
      await doc.ref.update({
        status: "inProgress",
        updatedAt: now,
      });
      logger.info(`Updated event ${eventId} to inProgress status`);

      // イベントのルームをアクティブ化（ディベート開始）
      try {
        const roomsActivated = await activateRoomsForEvent(eventId);
        logger.info(
          `Activated ${roomsActivated} rooms for event ${eventId}`
        );
      } catch (error) {
        logger.error(
          `Error activating rooms for event ${eventId}:`,
          error
        );
      }

      count++;
    }

    return count;
  } catch (error) {
    logger.error("Error updating matching to inProgress:", error);
    return 0;
  }
}

/**
 * inProgress → completed への更新
 * 開催時刻から2時間経過したイベント
 * @param {admin.firestore.Firestore} db Firestoreインスタンス
 * @param {admin.firestore.Timestamp} now 現在時刻
 * @return {Promise<number>} 更新したイベント数
 */
async function updateInProgressToCompleted(
  db: admin.firestore.Firestore,
  now: admin.firestore.Timestamp
): Promise<number> {
  try {
    // 開催時刻から2時間経過したイベントを取得
    const twoHoursAgo = new Date(
      now.toDate().getTime() - 2 * 60 * 60 * 1000
    );
    const twoHoursAgoTimestamp =
      admin.firestore.Timestamp.fromDate(twoHoursAgo);

    const snapshot = await db
      .collection("debate_events")
      .where("status", "==", "inProgress")
      .where("scheduledAt", "<=", twoHoursAgoTimestamp)
      .get();

    logger.info(
      `Found ${snapshot.size} events past completion time ` +
      "(inProgress -> completed)"
    );

    let count = 0;
    for (const doc of snapshot.docs) {
      await doc.ref.update({
        status: "completed",
        updatedAt: now,
      });
      logger.info(`Updated event ${doc.id} to completed status`);
      count++;
    }

    return count;
  } catch (error) {
    logger.error("Error updating inProgress to completed:", error);
    return 0;
  }
}

/**
 * scheduled → accepting への更新
 * エントリー開始時刻（開催の24時間前）を過ぎたイベント
 * @param {admin.firestore.Firestore} db Firestoreインスタンス
 * @param {admin.firestore.Timestamp} now 現在時刻
 * @return {Promise<number>} 更新したイベント数
 */
export async function updateScheduledToAccepting(
  db: admin.firestore.Firestore,
  now: admin.firestore.Timestamp
): Promise<number> {
  try {
    // 開催24時間前になったイベントを取得
    const twentyFourHoursLater = new Date(
      now.toDate().getTime() + 24 * 60 * 60 * 1000
    );
    const twentyFourHoursLaterTimestamp =
      admin.firestore.Timestamp.fromDate(twentyFourHoursLater);

    const snapshot = await db
      .collection("debate_events")
      .where("status", "==", "scheduled")
      .where("scheduledAt", "<=", twentyFourHoursLaterTimestamp)
      .get();

    logger.info(
      `Found ${snapshot.size} events ready to accept entries ` +
      "(scheduled -> accepting)"
    );

    let count = 0;
    for (const doc of snapshot.docs) {
      await doc.ref.update({
        status: "accepting",
        updatedAt: now,
      });
      logger.info(`Updated event ${doc.id} to accepting status`);
      count++;
    }

    return count;
  } catch (error) {
    logger.error("Error updating scheduled to accepting:", error);
    return 0;
  }
}

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  createRoomsForEvent,
  createRoomForMatch,
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

    // 5. 準備完了タイムアウト処理
    // 開催時刻から5分経過してもまだ準備完了していないマッチを強制開始
    updatedCount += await forceStartTimedOutMatches(db, now);

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

      // 自動開始は無効化 - 参加者の準備完了を待つ
      // ルームは全員が準備完了になったときにアクティブ化される
      logger.info(
        `Waiting for all participants to be ready for event ${eventId}`
      );

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

/**
 * 準備完了タイムアウト処理
 * イベント開始から5分経過してもまだ準備完了していないマッチを強制開始
 * @param {admin.firestore.Firestore} db Firestoreインスタンス
 * @param {admin.firestore.Timestamp} now 現在時刻
 * @return {Promise<number>} 強制開始したマッチ数
 */
async function forceStartTimedOutMatches(
  db: admin.firestore.Firestore,
  now: admin.firestore.Timestamp
): Promise<number> {
  try {
    // 5分前の時刻を計算
    const fiveMinutesAgo = new Date(
      now.toDate().getTime() - 5 * 60 * 1000
    );
    const fiveMinutesAgoTimestamp =
      admin.firestore.Timestamp.fromDate(fiveMinutesAgo);

    // inProgressステータスのイベントを取得
    const eventsSnapshot = await db
      .collection("debate_events")
      .where("status", "==", "inProgress")
      .where("scheduledAt", "<=", fiveMinutesAgoTimestamp)
      .get();

    logger.info(
      `Checking timeout for ${eventsSnapshot.size} in-progress events`
    );

    let count = 0;

    for (const eventDoc of eventsSnapshot.docs) {
      const eventId = eventDoc.id;

      // このイベントのマッチでまだmatchedステータスのものを取得
      const matchesSnapshot = await db
        .collection("debate_matches")
        .where("eventId", "==", eventId)
        .where("status", "==", "matched")
        .get();

      logger.info(
        `Found ${matchesSnapshot.size} timed-out matches for event ${eventId}`
      );

      for (const matchDoc of matchesSnapshot.docs) {
        const matchId = matchDoc.id;
        const matchData = matchDoc.data();

        try {
          // ルームがない場合は作成
          let roomId = matchData.roomId;
          if (!roomId) {
            roomId = await createRoomForMatch(matchId);
          }

          // ルームを強制的にアクティブ化
          await db.collection("debate_rooms").doc(roomId).update({
            status: "inProgress",
            startedAt: now,
            phaseStartedAt: now,
            phaseTimeRemaining: getPhaseTimeRemaining(
              matchData.duration,
              "preparation"
            ),
            updatedAt: now,
          });

          // マッチステータスを更新
          await matchDoc.ref.update({
            status: "inProgress",
            startedAt: now,
            updatedAt: now,
          });

          logger.info(
            `Force-started match ${matchId} due to timeout ` +
            `(room: ${roomId})`
          );

          count++;
        } catch (error) {
          logger.error(
            `Error force-starting match ${matchId}:`,
            error
          );
        }
      }
    }

    return count;
  } catch (error) {
    logger.error("Error in force-start timeout handler:", error);
    return 0;
  }
}

/**
 * フェーズの残り時間を取得
 * @param {string} duration ディベート時間
 * @param {string} phase フェーズ
 * @return {number} 残り時間（秒）
 */
function getPhaseTimeRemaining(
  duration: string,
  phase: string
): number {
  // 5分モード（short）の時間設定
  const shortDuration: {[key: string]: number} = {
    preparation: 30,
    openingPro: 60,
    openingCon: 60,
    rebuttalPro: 45,
    rebuttalCon: 45,
    closingPro: 30,
    closingCon: 30,
    judgment: 15,
  };

  // 10分モード（medium）の時間設定
  const mediumDuration: {[key: string]: number} = {
    preparation: 60,
    openingPro: 90,
    openingCon: 90,
    questionPro: 30,
    questionCon: 30,
    rebuttalPro: 60,
    rebuttalCon: 60,
    closingPro: 45,
    closingCon: 45,
    judgment: 20,
  };

  const durationMap =
    duration === "short" ? shortDuration : mediumDuration;

  return durationMap[phase] || 0;
}

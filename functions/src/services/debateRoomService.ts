import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

interface DebateMatch {
  id: string;
  eventId: string;
  format: string;
  duration: string;
  proTeam: {
    stance: string;
    memberIds: string[];
    score: number;
  };
  conTeam: {
    stance: string;
    memberIds: string[];
    score: number;
  };
  status: string;
  roomId?: string;
}

/**
 * マッチ成立時にディベートルームを作成
 * @param {string} matchId マッチID
 * @return {Promise<string>} 作成されたルームID
 */
export async function createRoomForMatch(
  matchId: string
): Promise<string> {
  const db = admin.firestore();

  try {
    logger.info(`Creating room for match ${matchId}`);

    // マッチ情報を取得
    const matchDoc = await db
      .collection("debate_matches")
      .doc(matchId)
      .get();

    if (!matchDoc.exists) {
      throw new Error(`Match ${matchId} not found`);
    }

    const match = matchDoc.data() as DebateMatch;

    // 既にルームが作成されている場合はスキップ
    if (match.roomId) {
      logger.info(`Room already exists for match ${matchId}: ${match.roomId}`);
      return match.roomId;
    }

    // ルームIDを生成
    const roomId = db.collection("debate_rooms").doc().id;

    // 参加者IDとスタンスのマッピングを作成
    const participantIds = [
      ...match.proTeam.memberIds,
      ...match.conTeam.memberIds,
    ];

    const participantStances: {[key: string]: string} = {};
    match.proTeam.memberIds.forEach((userId) => {
      participantStances[userId] = "pro";
    });
    match.conTeam.memberIds.forEach((userId) => {
      participantStances[userId] = "con";
    });

    const now = admin.firestore.Timestamp.now();

    // ディベートルームを作成
    const room = {
      id: roomId,
      eventId: match.eventId,
      matchId: matchId,
      participantIds: participantIds,
      participantStances: participantStances,
      status: "waiting",
      currentPhase: "preparation",
      createdAt: now,
      updatedAt: now,
      startedAt: null,
      completedAt: null,
      phaseStartedAt: null,
      phaseTimeRemaining: 0,
      messageCount: {},
      warningCount: {},
      judgmentId: null,
      metadata: {},
    };

    // トランザクションでルーム作成とマッチ更新を実行
    await db.runTransaction(async (transaction) => {
      const roomRef = db.collection("debate_rooms").doc(roomId);
      const matchRef = db.collection("debate_matches").doc(matchId);

      // ルームを作成
      transaction.set(roomRef, room);

      // マッチにroomIdを紐付け
      transaction.update(matchRef, {
        roomId: roomId,
        updatedAt: now,
      });
    });

    logger.info(`Room ${roomId} created for match ${matchId}`);

    return roomId;
  } catch (error) {
    logger.error(`Error creating room for match ${matchId}:`, error);
    throw error;
  }
}

/**
 * イベント開始時にルームをアクティブ化
 * @param {string} eventId イベントID
 * @return {Promise<number>} アクティブ化したルーム数
 */
export async function activateRoomsForEvent(
  eventId: string
): Promise<number> {
  const db = admin.firestore();

  try {
    logger.info(`Activating rooms for event ${eventId}`);

    // イベントのマッチ一覧を取得
    const matchesSnapshot = await db
      .collection("debate_matches")
      .where("eventId", "==", eventId)
      .where("status", "==", "matched")
      .get();

    logger.info(`Found ${matchesSnapshot.size} matches for event ${eventId}`);

    let activatedCount = 0;
    const now = admin.firestore.Timestamp.now();

    for (const matchDoc of matchesSnapshot.docs) {
      const match = matchDoc.data() as DebateMatch;

      // ルームがない場合は作成
      let roomId = match.roomId;
      if (!roomId) {
        roomId = await createRoomForMatch(match.id);
      }

      // ルームをアクティブ化（開始状態にする）
      await db.collection("debate_rooms").doc(roomId).update({
        status: "inProgress",
        startedAt: now,
        phaseStartedAt: now,
        phaseTimeRemaining: getPhaseTimeRemaining(
          match.duration,
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

      logger.info(`Activated room ${roomId} for match ${match.id}`);
      activatedCount++;
    }

    logger.info(
      `Activated ${activatedCount} rooms for event ${eventId}`
    );

    return activatedCount;
  } catch (error) {
    logger.error(`Error activating rooms for event ${eventId}:`, error);
    throw error;
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

/**
 * マッチング成立時に全マッチのルームを作成
 * @param {string} eventId イベントID
 * @return {Promise<number>} 作成したルーム数
 */
export async function createRoomsForEvent(
  eventId: string
): Promise<number> {
  const db = admin.firestore();

  try {
    logger.info(`Creating rooms for event ${eventId}`);

    // イベントのマッチ一覧を取得（ルームが未作成のもの）
    const matchesSnapshot = await db
      .collection("debate_matches")
      .where("eventId", "==", eventId)
      .where("status", "==", "matched")
      .get();

    logger.info(
      `Found ${matchesSnapshot.size} matched matches for event ${eventId}`
    );

    let createdCount = 0;

    for (const matchDoc of matchesSnapshot.docs) {
      const match = matchDoc.data() as DebateMatch;

      // 既にルームがある場合はスキップ
      if (match.roomId) {
        continue;
      }

      // ルームを作成
      await createRoomForMatch(match.id);
      createdCount++;
    }

    logger.info(
      `Created ${createdCount} rooms for event ${eventId}`
    );

    return createdCount;
  } catch (error) {
    logger.error(`Error creating rooms for event ${eventId}:`, error);
    throw error;
  }
}

/**
 * 全参加者が準備完了したときにルームをアクティブ化
 * @param {string} matchId マッチID
 * @return {Promise<boolean>} アクティブ化したかどうか
 */
export async function activateRoomWhenAllReady(
  matchId: string
): Promise<boolean> {
  const db = admin.firestore();

  try {
    logger.info(`Checking if all participants are ready for match ${matchId}`);

    // マッチ情報を取得
    const matchDoc = await db
      .collection("debate_matches")
      .doc(matchId)
      .get();

    if (!matchDoc.exists) {
      throw new Error(`Match ${matchId} not found`);
    }

    const match = matchDoc.data() as DebateMatch & {
      readyUsers?: string[];
    };

    // 全参加者のIDを取得
    const allParticipants = [
      ...match.proTeam.memberIds,
      ...match.conTeam.memberIds,
    ];

    // 準備完了したユーザーのリスト
    const readyUsers = match.readyUsers || [];

    logger.info(
      `Match ${matchId}: ${readyUsers.length}/` +
      `${allParticipants.length} participants ready`
    );

    // 全員が準備完了しているかチェック
    const allReady = allParticipants.every((userId) =>
      readyUsers.includes(userId)
    );

    if (!allReady) {
      logger.info(`Not all participants ready for match ${matchId}`);
      return false;
    }

    logger.info(`All participants ready for match ${matchId}, activating room`);

    // ルームがない場合は作成
    let roomId = match.roomId;
    if (!roomId) {
      roomId = await createRoomForMatch(matchId);
    }

    const now = admin.firestore.Timestamp.now();

    // ルームをアクティブ化（開始状態にする）
    await db.collection("debate_rooms").doc(roomId).update({
      status: "inProgress",
      startedAt: now,
      phaseStartedAt: now,
      phaseTimeRemaining: getPhaseTimeRemaining(
        match.duration,
        "preparation"
      ),
      updatedAt: now,
    });

    // マッチステータスを更新
    await db.collection("debate_matches").doc(matchId).update({
      status: "inProgress",
      startedAt: now,
      updatedAt: now,
    });

    logger.info(
      `Successfully activated room ${roomId} for match ${matchId}`
    );

    return true;
  } catch (error) {
    logger.error(
      `Error activating room for match ${matchId}:`,
      error
    );
    throw error;
  }
}

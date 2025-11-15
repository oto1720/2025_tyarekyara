import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

interface DebateEntry {
  userId: string;
  eventId: string;
  preferredDuration: string;
  preferredFormat: string;
  preferredStance: string;
  enteredAt: admin.firestore.Timestamp;
  status: string;
  matchId?: string;
}

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
  matchedAt: admin.firestore.Timestamp;
  createdAt: admin.firestore.Timestamp;
}

/**
 * マッチング処理を実行
 */
export async function processMatching(): Promise<void> {
  try {
    logger.info("Starting matching process");

    const db = admin.firestore();

    // エントリー受付中のイベントを取得
    const eventsSnapshot = await db
      .collection("debate_events")
      .where("status", "in", ["accepting", "matching"])
      .get();

    if (eventsSnapshot.empty) {
      logger.info("No events accepting entries");
      return;
    }

    let totalMatched = 0;

    // 各イベントごとにマッチング処理
    for (const eventDoc of eventsSnapshot.docs) {
      const eventId = eventDoc.id;
      const matched = await matchEntriesForEvent(db, eventId);
      totalMatched += matched;
    }

    logger.info(`Matching process completed. Matched ${totalMatched} pairs`);
  } catch (error) {
    logger.error("Error in matching process:", error);
    throw error;
  }
}

/**
 * 特定イベントのエントリーをマッチング
 * @param {admin.firestore.Firestore} db Firestoreインスタンス
 * @param {string} eventId イベントID
 * @return {Promise<number>} マッチング成功数
 */
async function matchEntriesForEvent(
  db: admin.firestore.Firestore,
  eventId: string
): Promise<number> {
  logger.info(`Matching entries for event: ${eventId}`);

  // 待機中のエントリーを取得
  const entriesSnapshot = await db
    .collection("debate_entries")
    .where("eventId", "==", eventId)
    .where("status", "==", "waiting")
    .orderBy("enteredAt", "asc")
    .get();

  logger.info(
    `Found ${entriesSnapshot.size} waiting entries for event ${eventId}`
  );

  if (entriesSnapshot.size < 2) {
    logger.info(`Not enough entries (${entriesSnapshot.size} < 2), skipping`);
    return 0;
  }

  // エントリーの詳細をログ
  entriesSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    logger.info(
      `  Entry: ${data.userId} - ` +
      `${data.preferredFormat}/${data.preferredDuration} ` +
      `(${data.preferredStance})`
    );
  });

  const entries = entriesSnapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as (DebateEntry & {id: string})[];

  let matchedCount = 0;

  // 形式と時間でグループ化
  const groups = groupEntriesByFormatAndDuration(entries);

  logger.info(`Created ${groups.size} groups`);
  for (const [key, groupEntries] of groups) {
    logger.info(`  Group ${key}: ${groupEntries.length} entries`);
    const matched = await matchGroup(db, eventId, groupEntries);
    matchedCount += matched;
  }

  logger.info(`Total matched: ${matchedCount} pairs`);
  return matchedCount;
}

/**
 * エントリーを形式と時間でグループ化
 * @param {Array} entries エントリー配列
 * @return {Map} グループ化されたエントリー
 */
function groupEntriesByFormatAndDuration(
  entries: (DebateEntry & {id: string})[]
): Map<string, (DebateEntry & {id: string})[]> {
  // eslint-disable-next-line func-call-spacing
  const groups = new Map<string, (DebateEntry & {id: string})[]>();

  for (const entry of entries) {
    const key = `${entry.preferredFormat}_${entry.preferredDuration}`;
    if (!groups.has(key)) {
      groups.set(key, []);
    }
    const group = groups.get(key);
    if (group) {
      group.push(entry);
    }
  }

  return groups;
}

/**
 * グループ内でマッチング
 * @param {admin.firestore.Firestore} db Firestoreインスタンス
 * @param {string} eventId イベントID
 * @param {Array} entries エントリー配列
 * @return {Promise<number>} マッチング成功数
 */
async function matchGroup(
  db: admin.firestore.Firestore,
  eventId: string,
  entries: (DebateEntry & {id: string})[]
): Promise<number> {
  logger.info(`matchGroup called with ${entries.length} entries`);

  if (entries.length < 2) {
    logger.info(`Group too small (${entries.length} < 2)`);
    return 0;
  }

  const format = entries[0].preferredFormat;
  const duration = entries[0].preferredDuration;
  const teamSize = format === "oneVsOne" ? 1 : 2;
  const requiredSize = teamSize * 2; // 2チーム分

  logger.info(
    `Format: ${format}, Duration: ${duration}, ` +
    `TeamSize: ${teamSize}, Required: ${requiredSize}`
  );

  if (entries.length < requiredSize) {
    logger.info(`Not enough entries (${entries.length} < ${requiredSize})`);
    return 0;
  }

  let matchedCount = 0;
  const usedEntryIds = new Set<string>();

  // マッチング可能な組み合わせを探す
  for (let i = 0; i < entries.length - requiredSize + 1; i++) {
    logger.info(`Attempting match starting from entry ${i}`);

    if (usedEntryIds.has(entries[i].id)) {
      logger.info(`Entry ${i} already used, skipping`);
      continue;
    }

    const proTeam: string[] = [];
    const conTeam: string[] = [];

    logger.info("Building pro team...");
    // プロチームを構築
    for (let j = i; j < entries.length && proTeam.length < teamSize; j++) {
      const entry = entries[j];
      if (usedEntryIds.has(entry.id)) {
        logger.info(`  Entry ${j} (${entry.userId}) already used`);
        continue;
      }

      if (
        entry.preferredStance === "pro" ||
        entry.preferredStance === "any"
      ) {
        logger.info(`  Adding ${entry.userId} to pro team`);
        proTeam.push(entry.userId);
        usedEntryIds.add(entry.id);
      } else {
        logger.info(
          `  Entry ${j} (${entry.userId}) ` +
          `stance is ${entry.preferredStance}, skipping`
        );
      }
    }

    logger.info(`Pro team: ${proTeam.length}/${teamSize} members`);

    // プロチームが満たない場合はスキップ
    if (proTeam.length < teamSize) {
      logger.info("Pro team incomplete, rolling back");
      // 使用したエントリーを戻す
      for (const userId of proTeam) {
        const entry = entries.find((e) => e.userId === userId);
        if (entry) {
          usedEntryIds.delete(entry.id);
        }
      }
      continue;
    }

    logger.info("Building con team...");
    // コンチームを構築
    for (let j = i; j < entries.length && conTeam.length < teamSize; j++) {
      const entry = entries[j];
      if (usedEntryIds.has(entry.id)) {
        logger.info(`  Entry ${j} (${entry.userId}) already used`);
        continue;
      }

      if (
        entry.preferredStance === "con" ||
        entry.preferredStance === "any"
      ) {
        logger.info(`  Adding ${entry.userId} to con team`);
        conTeam.push(entry.userId);
        usedEntryIds.add(entry.id);
      } else {
        logger.info(
          `  Entry ${j} (${entry.userId}) ` +
          `stance is ${entry.preferredStance}, skipping`
        );
      }
    }

    logger.info(`Con team: ${conTeam.length}/${teamSize} members`);

    // コンチームが満たない場合はスキップ
    if (conTeam.length < teamSize) {
      logger.info("Con team incomplete, rolling back");
      // 使用したエントリーを戻す
      for (const userId of [...proTeam, ...conTeam]) {
        const entry = entries.find((e) => e.userId === userId);
        if (entry) {
          usedEntryIds.delete(entry.id);
        }
      }
      continue;
    }

    // マッチを作成（トランザクションで安全に実行）
    logger.info(
      `Creating match: Pro[${proTeam.join(",")}] ` +
      `vs Con[${conTeam.join(",")}]`
    );

    // マッチングに使用するエントリーを収集
    const entryDocs = [...proTeam, ...conTeam]
      .map((userId) => entries.find((e) => e.userId === userId))
      .filter((e): e is DebateEntry & {id: string} => e !== undefined);

    try {
      const matchId = await createMatchWithTransaction(
        db,
        eventId,
        format,
        duration,
        proTeam,
        conTeam,
        entryDocs
      );
      logger.info(`Match created with ID: ${matchId}`);
      matchedCount++;
    } catch (error) {
      logger.error("Failed to create match in transaction:", error);
      // トランザクション失敗時は使用したエントリーを戻す
      for (const userId of [...proTeam, ...conTeam]) {
        const entry = entries.find((e) => e.userId === userId);
        if (entry) {
          usedEntryIds.delete(entry.id);
        }
      }
    }
  }

  return matchedCount;
}

/**
 * トランザクションでマッチを作成
 * @param {admin.firestore.Firestore} db Firestoreインスタンス
 * @param {string} eventId イベントID
 * @param {string} format ディベート形式
 * @param {string} duration ディベート時間
 * @param {Array<string>} proTeamMemberIds プロチームメンバーID配列
 * @param {Array<string>} conTeamMemberIds コンチームメンバーID配列
 * @param {Array} entryDocs エントリードキュメント配列
 * @return {Promise<string>} マッチID
 */
async function createMatchWithTransaction(
  db: admin.firestore.Firestore,
  eventId: string,
  format: string,
  duration: string,
  proTeamMemberIds: string[],
  conTeamMemberIds: string[],
  entryDocs: (DebateEntry & {id: string})[]
): Promise<string> {
  const matchId = db.collection("debate_matches").doc().id;

  await db.runTransaction(async (transaction) => {
    // 1. すべてのエントリーが"waiting"状態か確認
    for (const entry of entryDocs) {
      const entryRef = db.collection("debate_entries").doc(entry.id);
      const entryDoc = await transaction.get(entryRef);

      if (!entryDoc.exists) {
        throw new Error(`Entry ${entry.id} does not exist`);
      }

      const currentData = entryDoc.data();
      if (currentData?.status !== "waiting") {
        throw new Error(
          `Entry ${entry.id} is not in waiting status ` +
          `(current: ${currentData?.status})`
        );
      }
    }

    // 2. マッチを作成
    const now = admin.firestore.Timestamp.now();
    const match: DebateMatch = {
      id: matchId,
      eventId: eventId,
      format: format,
      duration: duration,
      proTeam: {
        stance: "pro",
        memberIds: proTeamMemberIds,
        score: 0,
      },
      conTeam: {
        stance: "con",
        memberIds: conTeamMemberIds,
        score: 0,
      },
      status: "matched",
      matchedAt: now,
      createdAt: now,
    };

    const matchRef = db.collection("debate_matches").doc(matchId);
    transaction.set(matchRef, match);

    // 3. すべてのエントリーを"matched"に更新
    for (const entry of entryDocs) {
      const entryRef = db.collection("debate_entries").doc(entry.id);
      transaction.update(entryRef, {
        status: "matched",
        matchId: matchId,
      });
    }

    logger.info(
      `Transaction: Created match ${matchId} ` +
      `and updated ${entryDocs.length} entries`
    );
  });

  return matchId;
}


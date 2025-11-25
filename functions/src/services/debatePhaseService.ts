import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

/**
 * ディベートのフェーズ定義
 */
const DEBATE_PHASES = {
  short: [
    {phase: "preparation", duration: 30},
    {phase: "openingPro", duration: 60},
    {phase: "openingCon", duration: 60},
    {phase: "rebuttalPro", duration: 45},
    {phase: "rebuttalCon", duration: 45},
    {phase: "closingPro", duration: 30},
    {phase: "closingCon", duration: 30},
    {phase: "judgment", duration: 15},
    {phase: "result", duration: 0},
    {phase: "completed", duration: 0},
  ],
  medium: [
    {phase: "preparation", duration: 60},
    {phase: "openingPro", duration: 90},
    {phase: "openingCon", duration: 90},
    {phase: "questionPro", duration: 30},
    {phase: "questionCon", duration: 30},
    {phase: "rebuttalPro", duration: 60},
    {phase: "rebuttalCon", duration: 60},
    {phase: "closingPro", duration: 45},
    {phase: "closingCon", duration: 45},
    {phase: "judgment", duration: 20},
    {phase: "result", duration: 0},
    {phase: "completed", duration: 0},
  ],
};

/**
 * 次のフェーズを取得
 * @param {string} currentPhase 現在のフェーズ
 * @param {string} duration ディベート時間（short or medium）
 * @return {object|null} 次のフェーズ情報、なければnull
 */
function getNextPhase(
  currentPhase: string,
  duration: string
): {phase: string; duration: number} | null {
  const phases =
    DEBATE_PHASES[duration as keyof typeof DEBATE_PHASES] ||
    DEBATE_PHASES.short;

  const currentIndex = phases.findIndex((p) => p.phase === currentPhase);

  if (currentIndex === -1 || currentIndex === phases.length - 1) {
    return null;
  }

  return phases[currentIndex + 1];
}

/**
 * アクティブなルームのフェーズを自動進行
 */
export async function progressDebatePhases(): Promise<void> {
  try {
    logger.info("Starting debate phase progression");

    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    // 進行中のルームを取得
    const snapshot = await db
      .collection("debate_rooms")
      .where("status", "==", "inProgress")
      .get();

    logger.info(`Found ${snapshot.size} active debate rooms`);

    let progressedCount = 0;

    for (const doc of snapshot.docs) {
      const room = doc.data();
      const roomId = doc.id;

      // phaseStartedAtとphaseDurationがない場合はスキップ
      if (!room.phaseStartedAt || room.phaseTimeRemaining === undefined) {
        logger.warn(
          `Room ${roomId} missing phase timing info, skipping`
        );
        continue;
      }

      // フェーズ開始時刻からの経過時間を計算
      const phaseStartTime = room.phaseStartedAt.toDate();
      const elapsedSeconds = Math.floor(
        (now.toDate().getTime() - phaseStartTime.getTime()) / 1000
      );

      // 残り時間を計算（phaseTimeRemainingは初期値、経過時間を引く）
      const remainingTime = room.phaseTimeRemaining - elapsedSeconds;

      logger.info(
        `Room ${roomId}: phase=${room.currentPhase}, ` +
        `elapsed=${elapsedSeconds}s, remaining=${remainingTime}s`
      );

      // 時間切れかチェック
      if (remainingTime <= 0) {
        // 次のフェーズを取得
        const nextPhase = getNextPhase(
          room.currentPhase,
          room.duration || "short"
        );

        if (nextPhase) {
          logger.info(
            `Progressing room ${roomId} from ` +
            `${room.currentPhase} to ${nextPhase.phase}`
          );

          // フェーズを更新
          await doc.ref.update({
            currentPhase: nextPhase.phase,
            phaseStartedAt: now,
            phaseTimeRemaining: nextPhase.duration,
            updatedAt: now,
          });

          // 判定フェーズに入った場合は即座にAI審査をトリガー
          if (nextPhase.phase === "judgment") {
            logger.info(`Room ${roomId} entered judgment phase,`);
            // statusをcompletedにしてonDebateCompleteトリガーを発火
            await doc.ref.update({
              status: "completed",
              updatedAt: now,
            });
          }

          // 判定フェーズが終わったら結果フェーズに進める
          if (
            room.currentPhase === "judgment" &&
            nextPhase.phase === "result"
          ) {
            logger.info(
              `Room ${roomId} judgment complete, ` +
              "moving to result phase"
            );
          }

          progressedCount++;
        } else {
          // これ以上フェーズがない場合は完了
          logger.info(`Room ${roomId} has no more phases, marking complete`);

          await doc.ref.update({
            status: "completed",
            currentPhase: "completed",
            updatedAt: now,
          });

          progressedCount++;
        }
      }
    }

    logger.info(
      "Debate phase progression completed. " +
      `Progressed ${progressedCount} rooms`
    );
  } catch (error) {
    logger.error("Error in debate phase progression:", error);
    throw error;
  }
}

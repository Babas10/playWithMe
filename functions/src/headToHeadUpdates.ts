import * as functions from "firebase-functions";
import { updateNemesis } from "./statsTracking";

/**
 * Trigger nemesis recalculation when head-to-head stats change.
 *
 * Architecture (Story 301.8 - Option 2):
 * - Nemesis is DECOUPLED from ELO calculation
 * - ELO completes fast without waiting for nemesis
 * - Nemesis updates independently when h2h stats change
 * - Scales better (only runs for affected users)
 * - No timeout issues
 *
 * Trigger: onCreate, onUpdate of users/{userId}/headToHead/{opponentId}
 */
export const onHeadToHeadStatsUpdated = functions
  .runWith({
    timeoutSeconds: 60, // Nemesis calculation for single user should be fast
    memory: "256MB",
  })
  .firestore
  .document("users/{userId}/headToHead/{opponentId}")
  .onWrite(async (change, context) => {
    const userId = context.params.userId;

    // Only recalculate if document was created or updated (not deleted)
    if (!change.after.exists) {
      functions.logger.info(`Head-to-head record deleted for ${userId}, skipping nemesis update`);
      return null;
    }

    functions.logger.info(`Head-to-head stats updated for ${userId}, recalculating nemesis...`);

    try {
      await updateNemesis(userId);
      functions.logger.info(`Successfully updated nemesis for ${userId}`);
    } catch (error) {
      functions.logger.error(`Failed to update nemesis for ${userId}`, error);
      // Don't throw - we don't want to retry this repeatedly
      // Nemesis is non-critical and will be recalculated on next h2h change
    }

    return null;
  });

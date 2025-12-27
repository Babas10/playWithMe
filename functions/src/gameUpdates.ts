import * as functions from "firebase-functions";
import { processGameEloUpdates } from "./elo";

/**
 * Trigger ELO updates when a game is completed.
 * This function listens for status changes to "completed".
 *
 * Fully Decoupled Architecture (Story 301.8):
 * - This function: ONLY ELO + teammate stats (fast)
 * - onEloCalculationComplete: H2H stats (triggered by eloCalculated=true)
 * - onHeadToHeadStatsUpdated: Nemesis (triggered by h2h doc changes)
 */
export const onGameStatusChanged = functions
  .runWith({
    timeoutSeconds: 60, // Fast now - only ELO + teammate stats
    memory: "512MB",
  })
  .firestore
  .document("games/{gameId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const gameId = context.params.gameId;

    // Check if status changed to 'completed'
    if (before.status === "completed" || after.status !== "completed") {
      return null;
    }

    // Idempotency check: Check if ELO has already been calculated
    if (after.eloUpdates) {
      functions.logger.info(`ELO already updated for game ${gameId}, skipping.`);
      return null;
    }

    functions.logger.info(`Game ${gameId} completed. initiating ELO updates.`);

    try {
      await processGameEloUpdates(gameId, after);
    } catch (error) {
      functions.logger.error(`Failed to process ELO updates for game ${gameId}`, error);
      // We might want to re-throw here if we want Cloud Functions to retry
      // But for now, just logging it.
    }

    return null;
  });

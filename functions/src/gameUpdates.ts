import * as functions from "firebase-functions";
import { processGameEloUpdates } from "./elo";

/**
 * Trigger ELO updates when a game is completed.
 * This function listens for status changes to "completed".
 *
 * CRITICAL ARCHITECTURE RULE (Story 15.5):
 * - This trigger ONLY watches the "games" collection
 * - Training sessions are in "trainingSessions" collection and NEVER trigger this
 * - Training sessions are NON-COMPETITIVE and do not affect ELO
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
  .document("games/{gameId}") // ONLY games, NOT trainingSessions (Story 15.5)
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

    // DEFENSIVE CHECK (Story 15.5): Verify this is not a training session
    // This should never happen due to trigger path, but defensive programming
    if (change.before.ref.parent.id !== "games") {
      functions.logger.error(
        `CRITICAL: ELO trigger fired for non-game collection: ${change.before.ref.parent.id}`,
        {gameId, collection: change.before.ref.parent.id}
      );
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

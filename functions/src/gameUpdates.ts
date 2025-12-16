import * as functions from "firebase-functions";
import { processGameEloUpdates } from "./elo";

/**
 * Trigger ELO updates when a game is completed.
 * This function listens for status changes to "completed".
 */
export const onGameStatusChanged = functions.firestore
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

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { updateHeadToHeadStats } from "./statsTracking";

/**
 * Trigger head-to-head stats updates after ELO calculation completes.
 *
 * Architecture (Story 301.8 - Full Decoupling):
 * - Runs AFTER onGameStatusChanged completes ELO calculation
 * - Processes all head-to-head matchups for the game
 * - Each h2h update uses a separate transaction (slow but safe)
 * - Nemesis calculation happens automatically via onHeadToHeadStatsUpdated
 *
 * Trigger: onUpdate when eloCalculated changes from false to true
 */
export const onEloCalculationComplete = functions
  .runWith({
    timeoutSeconds: 180, // 3 minutes - multiple h2h transactions can be slow
    memory: "512MB",
  })
  .firestore
  .document("games/{gameId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const gameId = context.params.gameId;

    // Only trigger when eloCalculated changes from false to true
    if (before.eloCalculated !== false || after.eloCalculated !== true) {
      return null;
    }

    // Idempotency check: Check if h2h has already been processed
    if (after.headToHeadProcessed === true) {
      functions.logger.info(`Head-to-head already processed for game ${gameId}, skipping.`);
      return null;
    }

    functions.logger.info(`ELO calculated for game ${gameId}, processing head-to-head stats...`);

    try {
      await processHeadToHeadUpdates(gameId, after);
    } catch (error) {
      functions.logger.error(`Failed to process head-to-head updates for game ${gameId}`, error);
      // Don't throw - we don't want retries that could cause duplicates
    }

    return null;
  });

/**
 * Process all head-to-head stats updates for a completed game.
 * Each update runs in its own transaction (outside the main ELO transaction).
 */
async function processHeadToHeadUpdates(gameId: string, gameData: any): Promise<void> {
  const db = admin.firestore();

  // Validate game data
  if (!gameData.teams || !gameData.teams.teamAPlayerIds || !gameData.teams.teamBPlayerIds) {
    throw new Error("Invalid game data: Missing teams information");
  }

  if (!gameData.result || !gameData.result.games || !Array.isArray(gameData.result.games)) {
    throw new Error("Invalid game data: Missing result or games array");
  }

  if (!gameData.eloUpdates) {
    throw new Error("Invalid game data: Missing eloUpdates (ELO must be calculated first)");
  }

  const teamAPlayerIds = gameData.teams.teamAPlayerIds;
  const teamBPlayerIds = gameData.teams.teamBPlayerIds;
  const individualGames = gameData.result.games;
  const eloUpdates = gameData.eloUpdates;

  // Calculate total points for each team across all individual games
  let teamAPoints = 0;
  let teamBPoints = 0;

  individualGames.forEach((game: any) => {
    teamAPoints += game.teamAScore || 0;
    teamBPoints += game.teamBScore || 0;
  });

  // Determine overall winner
  const teamAWon = gameData.result.overallWinner === "teamA";

  // Update head-to-head stats for all cross-team matchups
  const h2hPromises = [];

  for (const teamAPlayerId of teamAPlayerIds) {
    for (const teamBPlayerId of teamBPlayerIds) {
      const teamAEloChange = eloUpdates[teamAPlayerId]?.change || 0;
      const teamBEloChange = eloUpdates[teamBPlayerId]?.change || 0;

      // Get partner IDs (if applicable)
      const teamAPartnerId = teamAPlayerIds.find((id: string) => id !== teamAPlayerId) || undefined;
      const teamBPartnerId = teamBPlayerIds.find((id: string) => id !== teamBPlayerId) || undefined;

      // Update from Team A player's perspective
      h2hPromises.push(
        updateHeadToHeadStats(
          teamAPlayerId,
          teamBPlayerId,
          teamAWon,
          teamAPoints,
          teamBPoints,
          teamAEloChange,
          gameId,
          teamAPartnerId,
          teamBPartnerId
        )
      );

      // Update from Team B player's perspective
      h2hPromises.push(
        updateHeadToHeadStats(
          teamBPlayerId,
          teamAPlayerId,
          !teamAWon,
          teamBPoints,
          teamAPoints,
          teamBEloChange,
          gameId,
          teamBPartnerId,
          teamAPartnerId
        )
      );
    }
  }

  // Process all h2h updates (each in separate transaction)
  await Promise.all(h2hPromises);

  functions.logger.info(`Successfully processed head-to-head stats for game ${gameId}`);

  // Mark h2h as processed
  await db.collection("games").doc(gameId).update({
    headToHeadProcessed: true,
    headToHeadProcessedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

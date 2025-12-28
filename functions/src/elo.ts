import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { processStatsTracking } from "./statsTracking";

// Constants
const K_FACTOR = 32;
const DEFAULT_ELO = 1200;

/**
 * Calculate team rating using Weak-Link formula.
 * Team Rating = 0.7 * min + 0.3 * max
 */
export function calculateTeamRating(ratings: number[]): number {
  if (ratings.length !== 2) {
     // Fallback for non-2-player teams
     if (ratings.length === 0) return DEFAULT_ELO;
     const sum = ratings.reduce((a, b) => a + b, 0);
     return sum / ratings.length;
  }
  const min = Math.min(...ratings);
  const max = Math.max(...ratings);
  return 0.7 * min + 0.3 * max;
}

/**
 * Calculate expected win probability based on team ratings
 */
export function getExpectedScore(teamRating: number, opponentRating: number): number {
  return 1 / (1 + Math.pow(10, (opponentRating - teamRating) / 400));
}

/**
 * Calculate rating change
 */
export function calculateRatingChange(actualScore: number, expectedScore: number, kFactor: number = K_FACTOR): number {
  return Math.round(kFactor * (actualScore - expectedScore));
}

/**
 * Calculate new streak
 */
function calculateNewStreak(currentStreak: number, won: boolean): number {
  if (won) {
    return currentStreak >= 0 ? currentStreak + 1 : 1;
  } else {
    return currentStreak <= 0 ? currentStreak - 1 : -1;
  }
}

/**
 * Process game completion and update ELO ratings
 */
export async function processGameEloUpdates(gameId: string, gameData: any): Promise<void> {
  const db = admin.firestore();

  // Validate game data
  if (!gameData.teams || !gameData.teams.teamAPlayerIds || !gameData.teams.teamBPlayerIds) {
    throw new Error("Invalid game data: Missing teams information");
  }

  if (!gameData.result || !gameData.result.games || !Array.isArray(gameData.result.games)) {
    throw new Error("Invalid game data: Missing result or games array");
  }

  const teamAPlayerIds = gameData.teams.teamAPlayerIds;
  const teamBPlayerIds = gameData.teams.teamBPlayerIds;
  const individualGames = gameData.result.games; // Array of individual games

  try {
    await db.runTransaction(async (transaction) => {
      // 1. Fetch all players
      const playerIds = [...teamAPlayerIds, ...teamBPlayerIds];
      const playerRefs = playerIds.map((id: string) => db.collection("users").doc(id));
      const playerDocs = await Promise.all(playerRefs.map((ref: any) => transaction.get(ref)));

      const playerMap = new Map<string, any>();
      const displayNames = new Map<string, string>();

      playerDocs.forEach((doc: any) => {
        if (doc.exists) {
          const data = doc.data();
          playerMap.set(doc.id, data);
          displayNames.set(doc.id, data.displayName || data.email || "Unknown");
        }
      });

      // Track current ratings as we process each game (starts with stored ratings)
      const currentRatings = new Map<string, number>();
      playerIds.forEach(id => {
        const data = playerMap.get(id);
        currentRatings.set(id, data?.eloRating || DEFAULT_ELO);
      });

      // Track cumulative changes for each player
      const cumulativeChanges = new Map<string, number>();
      playerIds.forEach(id => cumulativeChanges.set(id, 0));

      const updates: any = {};
      const now = admin.firestore.FieldValue.serverTimestamp(); // For top-level document fields
      const timestampNow = admin.firestore.Timestamp.now(); // For nested objects like bestWin

      // 2. Process each individual game sequentially
      for (let i = 0; i < individualGames.length; i++) {
        const individualGame = individualGames[i];
        const gameWinner = individualGame.winner; // 'teamA' or 'teamB'

        if (!gameWinner) {
          functions.logger.warn(`Game ${i + 1} has no winner, skipping ELO calculation`);
          continue;
        }

        // Get current ratings for this iteration
        const getRatings = (ids: string[]) => ids.map(id => currentRatings.get(id) || DEFAULT_ELO);

        const teamARatings = getRatings(teamAPlayerIds);
        const teamBRatings = getRatings(teamBPlayerIds);

        // Calculate Team Ratings (Weak-Link formula: 0.7 * min + 0.3 * max)
        const teamARating = calculateTeamRating(teamARatings);
        const teamBRating = calculateTeamRating(teamBRatings);

        // Calculate Expected Scores
        const teamAExpected = getExpectedScore(teamARating, teamBRating);
        const teamBExpected = getExpectedScore(teamBRating, teamARating);

        // Determine actual scores based on who won this specific game
        const teamAActualScore = gameWinner === "teamA" ? 1 : 0;
        const teamBActualScore = gameWinner === "teamB" ? 1 : 0;

        // Calculate Rating Changes for this game
        const teamAChange = calculateRatingChange(teamAActualScore, teamAExpected);
        const teamBChange = calculateRatingChange(teamBActualScore, teamBExpected);

        // Update current ratings and track cumulative changes
        teamAPlayerIds.forEach((id: string) => {
          const newRating = (currentRatings.get(id) || DEFAULT_ELO) + teamAChange;
          currentRatings.set(id, newRating);
          cumulativeChanges.set(id, (cumulativeChanges.get(id) || 0) + teamAChange);
        });

        teamBPlayerIds.forEach((id: string) => {
          const newRating = (currentRatings.get(id) || DEFAULT_ELO) + teamBChange;
          currentRatings.set(id, newRating);
          cumulativeChanges.set(id, (cumulativeChanges.get(id) || 0) + teamBChange);
        });

        functions.logger.info(
          `Game ${i + 1}/${individualGames.length}: Winner=${gameWinner}, ` +
          `Team A change=${teamAChange}, Team B change=${teamBChange}`
        );
      }

      // 3. Now apply all updates to Firestore
      // Determine overall winner based on cumulative changes (for win/loss stats)
      const teamAFinalChange = teamAPlayerIds.reduce((sum: number, id: string) => sum + (cumulativeChanges.get(id) || 0), 0) / teamAPlayerIds.length;
      const teamBFinalChange = teamBPlayerIds.reduce((sum: number, id: string) => sum + (cumulativeChanges.get(id) || 0), 0) / teamBPlayerIds.length;
      const overallTeamAWon = teamAFinalChange > 0;
      const overallTeamBWon = teamBFinalChange > 0;

      // Helper to update each player with their cumulative changes
      const updatePlayer = (playerId: string, isTeamA: boolean) => {
        const data = playerMap.get(playerId);
        if (!data) return;

        const originalRating = data.eloRating || DEFAULT_ELO;
        const cumulativeChange = cumulativeChanges.get(playerId) || 0;
        const finalRating = currentRatings.get(playerId) || DEFAULT_ELO;
        const won = isTeamA ? overallTeamAWon : overallTeamBWon;
        const opponentIds = isTeamA ? teamBPlayerIds : teamAPlayerIds;

        const currentPeak = data.eloPeak || originalRating;
        const currentStreak = data.currentStreak || 0;
        const recentGameIds = data.recentGameIds || [];

        const newPeak = Math.max(currentPeak, finalRating);
        const shouldUpdatePeak = finalRating > currentPeak;
        const newPeakDate = shouldUpdatePeak ? now : (data.eloPeakDate || null);

        const newStreak = calculateNewStreak(currentStreak, won);
        const newRecentGames = [gameId, ...recentGameIds].slice(0, 10);

        // Calculate best win tracking (Story 301.6)
        let bestWinUpdate: any = undefined;
        if (won && cumulativeChange > 0) {
          // Get opponent team ratings at the time of the game
          const opponentRatings = opponentIds.map((oid: string) => {
            const oppData = playerMap.get(oid);
            return oppData?.eloRating || DEFAULT_ELO;
          });

          // Calculate opponent team ELO (using same formula as team rating)
          const opponentTeamElo = calculateTeamRating(opponentRatings);
          const opponentTeamAvgElo = opponentRatings.reduce((sum: number, r: number) => sum + r, 0) / opponentRatings.length;

          // Check if this is a better win than current best
          const currentBestWin = data.bestWin;
          const shouldUpdateBestWin = !currentBestWin || opponentTeamElo > (currentBestWin.opponentTeamElo || 0);

          if (shouldUpdateBestWin) {
            const opponentNames = opponentIds.map((oid: string) => displayNames.get(oid) || "Unknown").join(" & ");
            bestWinUpdate = {
              gameId: gameId,
              opponentTeamElo: opponentTeamElo,
              opponentTeamAvgElo: opponentTeamAvgElo,
              eloGained: cumulativeChange,
              date: timestampNow, // Use actual Timestamp for nested object
              gameTitle: `vs ${opponentNames}`,
            };
          }
        }

        // Update User Doc
        const userRef = db.collection("users").doc(playerId);
        const updateData: any = {
          eloRating: finalRating,
          eloLastUpdated: now,
          eloPeak: newPeak,
          eloPeakDate: newPeakDate,
          gamesPlayed: admin.firestore.FieldValue.increment(individualGames.length), // Count all games
          eloGamesPlayed: admin.firestore.FieldValue.increment(individualGames.length),
          wins: won ? admin.firestore.FieldValue.increment(individualGames.length) : admin.firestore.FieldValue.increment(0),
          losses: won ? admin.firestore.FieldValue.increment(0) : admin.firestore.FieldValue.increment(individualGames.length),
          gamesWon: won ? admin.firestore.FieldValue.increment(individualGames.length) : admin.firestore.FieldValue.increment(0),
          gamesLost: won ? admin.firestore.FieldValue.increment(0) : admin.firestore.FieldValue.increment(individualGames.length),
          currentStreak: newStreak,
          recentGameIds: newRecentGames,
          lastGameDate: now,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        // Add bestWin update if this is a new best win
        if (bestWinUpdate) {
          updateData.bestWin = bestWinUpdate;
        }

        transaction.update(userRef, updateData);

        updates[playerId] = {
          previousRating: originalRating,
          newRating: finalRating,
          change: cumulativeChange
        };

        // Add to History (one entry per play session with cumulative change)
        const opponentNames = opponentIds.map((oid: string) => displayNames.get(oid) || "Unknown").join(" & ");
        const historyRef = userRef.collection("ratingHistory").doc();
        transaction.set(historyRef, {
            gameId: gameId,
            oldRating: originalRating,
            newRating: finalRating,
            ratingChange: cumulativeChange,
            opponentTeam: opponentNames,
            won: won,
            timestamp: now,
        });
      };

      // Update all players
      teamAPlayerIds.forEach((id: string) => updatePlayer(id, true));
      teamBPlayerIds.forEach((id: string) => updatePlayer(id, false));

      // 5. Process teammate stats tracking
      // NOTE: Head-to-head stats are processed by onEloCalculationComplete (separate Cloud Function)
      await processStatsTracking(
        transaction,
        gameId,
        teamAPlayerIds,
        teamBPlayerIds,
        overallTeamAWon,
        individualGames,
        cumulativeChanges,
        playerMap // Pass the player data map
      );

      // 6. Record ELO changes in the game document
      // Setting eloCalculated to true triggers onEloCalculationComplete
      transaction.update(db.collection("games").doc(gameId), {
        eloUpdates: updates,
        eloCalculated: true,
        eloCalculatedAt: now,
      });
    });

    // NOTE: Fully decoupled architecture (Story 301.8):
    // 1. This function: ELO + teammate stats (fast, <5 seconds)
    // 2. onEloCalculationComplete: H2H stats updates (triggered by eloCalculated=true)
    // 3. onHeadToHeadStatsUpdated: Nemesis calculation (triggered by h2h doc changes)

    functions.logger.info(`Successfully updated ELO ratings and teammate stats for game ${gameId}`);

  } catch (error) {
    functions.logger.error(`Error updating ELO ratings for game ${gameId}`, error);
    throw error;
  }
}

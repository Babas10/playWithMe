import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

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

  if (!gameData.result || !gameData.result.overallWinner) {
    throw new Error("Invalid game data: Missing result information");
  }

  const teamAPlayerIds = gameData.teams.teamAPlayerIds;
  const teamBPlayerIds = gameData.teams.teamBPlayerIds;
  const overallWinner = gameData.result.overallWinner;

  const teamAActualScore = overallWinner === "teamA" ? 1 : 0;
  const teamBActualScore = 1 - teamAActualScore;
  const teamAWon = teamAActualScore === 1;

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

      // 2. Get ratings for each team
      const getRatings = (ids: string[]) => ids.map(id => {
        const data = playerMap.get(id);
        return data?.eloRating || DEFAULT_ELO;
      });

      const teamARatings = getRatings(teamAPlayerIds);
      const teamBRatings = getRatings(teamBPlayerIds);

      // 3. Calculate Team Ratings (Weak-Link)
      const teamARating = calculateTeamRating(teamARatings);
      const teamBRating = calculateTeamRating(teamBRatings);

      // 4. Calculate Expected Scores
      const teamAExpected = getExpectedScore(teamARating, teamBRating);
      const teamBExpected = getExpectedScore(teamBRating, teamARating);

      // 5. Calculate Rating Changes
      const teamAChange = calculateRatingChange(teamAActualScore, teamAExpected);
      const teamBChange = calculateRatingChange(teamBActualScore, teamBExpected);

      const updates: any = {};
      const now = admin.firestore.FieldValue.serverTimestamp();

      // Helper to update players
      const updatePlayer = (playerId: string, ratingChange: number, won: boolean, opponentIds: string[], teamIds: string[]) => {
        const data = playerMap.get(playerId);
        if (!data) return;

        const currentRating = data.eloRating || DEFAULT_ELO;
        const newRating = currentRating + ratingChange;
        const currentPeak = data.eloPeak || currentRating;
        const currentStreak = data.currentStreak || 0;
        const recentGameIds = data.recentGameIds || [];

        const newPeak = Math.max(currentPeak, newRating);
        // We can't compare serverTimestamp with numbers easily in client code, 
        // but here we are determining IF we should update the date.
        // Logic: if newRating > currentPeak, we update peak and date.
        // Since we don't have the resolved serverTimestamp, we just set it if new peak.
        const shouldUpdatePeak = newRating > currentPeak;
        const newPeakDate = shouldUpdatePeak ? now : (data.eloPeakDate || null);
        
        const newStreak = calculateNewStreak(currentStreak, won);
        
        const newRecentGames = [gameId, ...recentGameIds].slice(0, 10);

        // Update User Doc
        const userRef = db.collection("users").doc(playerId);
        transaction.update(userRef, {
          eloRating: newRating,
          eloLastUpdated: now,
          eloPeak: newPeak,
          eloPeakDate: newPeakDate,
          gamesPlayed: admin.firestore.FieldValue.increment(1),
          eloGamesPlayed: admin.firestore.FieldValue.increment(1),
          wins: won ? admin.firestore.FieldValue.increment(1) : admin.firestore.FieldValue.increment(0),
          losses: won ? admin.firestore.FieldValue.increment(0) : admin.firestore.FieldValue.increment(1),
          gamesWon: won ? admin.firestore.FieldValue.increment(1) : admin.firestore.FieldValue.increment(0),
          gamesLost: won ? admin.firestore.FieldValue.increment(0) : admin.firestore.FieldValue.increment(1),
          currentStreak: newStreak,
          recentGameIds: newRecentGames,
          lastGameDate: now,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        updates[playerId] = {
          previousRating: currentRating,
          newRating: newRating,
          change: ratingChange
        };

        // Add to History
        const opponentNames = opponentIds.map(oid => displayNames.get(oid) || "Unknown").join(" & ");
        const historyRef = userRef.collection("ratingHistory").doc();
        transaction.set(historyRef, {
            gameId: gameId,
            oldRating: currentRating,
            newRating: newRating,
            ratingChange: ratingChange,
            opponentTeam: opponentNames,
            won: won,
            timestamp: now,
        });
      };

      // Update Team A Players
      teamAPlayerIds.forEach((id: string) => updatePlayer(id, teamAChange, teamAWon, teamBPlayerIds, teamAPlayerIds));

      // Update Team B Players
      teamBPlayerIds.forEach((id: string) => updatePlayer(id, teamBChange, !teamAWon, teamAPlayerIds, teamBPlayerIds));

      // 6. Record ELO changes in the game document
      transaction.update(db.collection("games").doc(gameId), {
        eloUpdates: updates,
        eloCalculated: true,
        eloCalculatedAt: now,
      });
    });

    functions.logger.info(`Successfully updated ELO ratings for game ${gameId}`);

  } catch (error) {
    functions.logger.error(`Error updating ELO ratings for game ${gameId}`, error);
    throw error;
  }
}

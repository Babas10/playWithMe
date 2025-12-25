import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Update teammate statistics after a game completes.
 * Tracks performance metrics for players who played together on the same team.
 *
 * NOTE: This function only does WRITES. The caller must pass in the current
 * teammate stats data (read beforehand to satisfy Firestore transaction rules).
 */
export async function updateTeammateStats(
  transaction: admin.firestore.Transaction,
  playerId: string,
  teammateId: string,
  won: boolean,
  pointsScored: number,
  pointsAllowed: number,
  eloChange: number,
  gameId: string,
  currentTeammateStats: any // ← NEW: Pass in the current stats
): Promise<void> {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(playerId);

  // Use the passed-in teammate stats (already read)
  const teammateStats = currentTeammateStats || {};
  const currentStats = teammateStats[teammateId] || {
    gamesPlayed: 0,
    gamesWon: 0,
    gamesLost: 0,
    pointsScored: 0,
    pointsAllowed: 0,
    eloChange: 0.0,
    recentGames: [],
    lastUpdated: null,
  };

  // Update stats
  const updatedStats = {
    gamesPlayed: currentStats.gamesPlayed + 1,
    gamesWon: won ? currentStats.gamesWon + 1 : currentStats.gamesWon,
    gamesLost: won ? currentStats.gamesLost : currentStats.gamesLost + 1,
    pointsScored: currentStats.pointsScored + pointsScored,
    pointsAllowed: currentStats.pointsAllowed + pointsAllowed,
    eloChange: currentStats.eloChange + eloChange,
    recentGames: [
      {
        gameId,
        won,
        pointsScored,
        pointsAllowed,
        eloChange,
        timestamp: new Date(), // Cannot use serverTimestamp() inside arrays
      },
      ...(currentStats.recentGames || []).slice(0, 9), // Keep last 10 games
    ],
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  };

  // Update in transaction
  transaction.update(userRef, {
    [`teammateStats.${teammateId}`]: updatedStats,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  functions.logger.info(
    `Updated teammate stats for ${playerId} with partner ${teammateId}: ` +
    `${updatedStats.gamesWon}W-${updatedStats.gamesLost}L, ` +
    `Win Rate: ${((updatedStats.gamesWon / updatedStats.gamesPlayed) * 100).toFixed(1)}%`
  );
}

/**
 * Update head-to-head statistics after a game completes.
 * Tracks rivalry performance when players are on opposing teams.
 *
 * NOTE: This function runs OUTSIDE the main transaction to avoid
 * Firestore's "all reads before writes" rule. It uses its own transaction.
 */
export async function updateHeadToHeadStats(
  playerId: string,
  opponentId: string,
  won: boolean,
  pointsScored: number,
  pointsAllowed: number,
  eloChange: number,
  gameId: string,
  partnerId?: string,
  opponentPartnerId?: string
): Promise<void> {
  const db = admin.firestore();
  const h2hRef = db
    .collection("users")
    .doc(playerId)
    .collection("headToHead")
    .doc(opponentId);

  // Use a separate transaction for h2h stats
  await db.runTransaction(async (transaction) => {
    // Fetch current head-to-head stats
    const h2hDoc = await transaction.get(h2hRef);
    const h2hData = h2hDoc.data();

  const pointDiff = pointsScored - pointsAllowed;

  const currentStats = h2hData || {
    userId: playerId,
    opponentId: opponentId,
    gamesPlayed: 0,
    gamesWon: 0,
    gamesLost: 0,
    pointsScored: 0,
    pointsAllowed: 0,
    eloChange: 0.0,
    largestVictoryMargin: 0,
    largestDefeatMargin: 0,
    recentMatchups: [],
    lastUpdated: null,
  };

  // Update stats
  const updatedStats = {
    userId: playerId,
    opponentId: opponentId,
    gamesPlayed: currentStats.gamesPlayed + 1,
    gamesWon: won ? currentStats.gamesWon + 1 : currentStats.gamesWon,
    gamesLost: won ? currentStats.gamesLost : currentStats.gamesLost + 1,
    pointsScored: currentStats.pointsScored + pointsScored,
    pointsAllowed: currentStats.pointsAllowed + pointsAllowed,
    eloChange: currentStats.eloChange + eloChange,
    largestVictoryMargin: won
      ? Math.max(currentStats.largestVictoryMargin, pointDiff)
      : currentStats.largestVictoryMargin,
    largestDefeatMargin: !won
      ? Math.max(currentStats.largestDefeatMargin, Math.abs(pointDiff))
      : currentStats.largestDefeatMargin,
    recentMatchups: [
      {
        gameId,
        won,
        pointsScored,
        pointsAllowed,
        eloChange,
        partnerId: partnerId || null,
        opponentPartnerId: opponentPartnerId || null,
        timestamp: new Date(), // Cannot use serverTimestamp() inside arrays
      },
      ...(currentStats.recentMatchups || []).slice(0, 9), // Keep last 10 matchups
    ],
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  };

    // Set or update the document
    transaction.set(h2hRef, updatedStats, {merge: true});
  }); // End of transaction

  // Log after transaction completes
  const finalDoc = await h2hRef.get();
  const finalStats = finalDoc.data();
  if (finalStats) {
    functions.logger.info(
      `Updated head-to-head stats for ${playerId} vs ${opponentId}: ` +
      `${finalStats.gamesWon}W-${finalStats.gamesLost}L, ` +
      `Win Rate: ${((finalStats.gamesWon / finalStats.gamesPlayed) * 100).toFixed(1)}%`
    );
  }
}

/**
 * Process all teammate and head-to-head stats updates for a completed game.
 * Called from the main ELO processing transaction.
 *
 * NOTE: To satisfy Firestore transaction rules (all reads before writes),
 * this function now accepts pre-read user data.
 */
export async function processStatsTracking(
  transaction: admin.firestore.Transaction,
  gameId: string,
  teamAPlayerIds: string[],
  teamBPlayerIds: string[],
  teamAWon: boolean,
  individualGames: any[],
  playerEloChanges: Map<string, number>,
  playerDataMap: Map<string, any> // ← NEW: Pass in pre-read player data
): Promise<void> {
  // Calculate total points for each team across all individual games
  let teamAPoints = 0;
  let teamBPoints = 0;

  individualGames.forEach((game) => {
    teamAPoints += game.teamAScore || 0;
    teamBPoints += game.teamBScore || 0;
  });

  // Update teammate stats for each team
  // Team A partnerships
  for (let i = 0; i < teamAPlayerIds.length; i++) {
    for (let j = i + 1; j < teamAPlayerIds.length; j++) {
      const playerId = teamAPlayerIds[i];
      const teammateId = teamAPlayerIds[j];
      const eloChange = playerEloChanges.get(playerId) || 0;

      const playerData = playerDataMap.get(playerId);
      const teammateData = playerDataMap.get(teammateId);

      await updateTeammateStats(
        transaction,
        playerId,
        teammateId,
        teamAWon,
        teamAPoints,
        teamBPoints,
        eloChange,
        gameId,
        playerData?.teammateStats || {} // ← Pass current stats
      );

      await updateTeammateStats(
        transaction,
        teammateId,
        playerId,
        teamAWon,
        teamAPoints,
        teamBPoints,
        playerEloChanges.get(teammateId) || 0,
        gameId,
        teammateData?.teammateStats || {} // ← Pass current stats
      );
    }
  }

  // Team B partnerships
  for (let i = 0; i < teamBPlayerIds.length; i++) {
    for (let j = i + 1; j < teamBPlayerIds.length; j++) {
      const playerId = teamBPlayerIds[i];
      const teammateId = teamBPlayerIds[j];
      const eloChange = playerEloChanges.get(playerId) || 0;

      const playerData = playerDataMap.get(playerId);
      const teammateData = playerDataMap.get(teammateId);

      await updateTeammateStats(
        transaction,
        playerId,
        teammateId,
        !teamAWon, // Team B won if Team A didn't win
        teamBPoints,
        teamAPoints,
        eloChange,
        gameId,
        playerData?.teammateStats || {} // ← Pass current stats
      );

      await updateTeammateStats(
        transaction,
        teammateId,
        playerId,
        !teamAWon,
        teamBPoints,
        teamAPoints,
        playerEloChanges.get(teammateId) || 0,
        gameId,
        teammateData?.teammateStats || {} // ← Pass current stats
      );
    }
  }

  // Update head-to-head stats for all cross-team matchups
  for (const teamAPlayerId of teamAPlayerIds) {
    for (const teamBPlayerId of teamBPlayerIds) {
      const teamAEloChange = playerEloChanges.get(teamAPlayerId) || 0;
      const teamBEloChange = playerEloChanges.get(teamBPlayerId) || 0;

      // Get partner IDs (if applicable)
      const teamAPartnerId = teamAPlayerIds.find((id) => id !== teamAPlayerId) || undefined;
      const teamBPartnerId = teamBPlayerIds.find((id) => id !== teamBPlayerId) || undefined;

      // Update from Team A player's perspective
      await updateHeadToHeadStats(
        teamAPlayerId,
        teamBPlayerId,
        teamAWon,
        teamAPoints,
        teamBPoints,
        teamAEloChange,
        gameId,
        teamAPartnerId,
        teamBPartnerId
      );

      // Update from Team B player's perspective
      await updateHeadToHeadStats(
        teamBPlayerId,
        teamAPlayerId,
        !teamAWon,
        teamBPoints,
        teamAPoints,
        teamBEloChange,
        gameId,
        teamBPartnerId,
        teamAPartnerId
      );
    }
  }

  // Update nemesis for all players (Story 301.8)
  const allPlayerIds = [...teamAPlayerIds, ...teamBPlayerIds];
  for (const playerId of allPlayerIds) {
    await updateNemesis(playerId);
  }

  functions.logger.info(
    `Successfully processed teammate and head-to-head stats for game ${gameId}`
  );
}

/**
 * Update nemesis record for a player.
 * Identifies the opponent the player has lost to most often (minimum 3 games).
 */
export async function updateNemesis(
  userId: string
): Promise<void> {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(userId);

  // Fetch all head-to-head records for this user
  const h2hSnapshot = await db
    .collection("users")
    .doc(userId)
    .collection("headToHead")
    .get();

  if (h2hSnapshot.empty) {
    // No head-to-head stats, clear nemesis
    await userRef.update({
      nemesis: null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    functions.logger.info(`Cleared nemesis for ${userId} (no h2h stats)`);
    return;
  }

  // Find opponent with most losses (minimum 3 games threshold)
  let nemesis: {
    opponentId: string;
    opponentName: string;
    gamesLost: number;
    gamesWon: number;
    gamesPlayed: number;
    winRate: number;
  } | null = null;
  let maxLosses = 0;

  for (const doc of h2hSnapshot.docs) {
    const stats = doc.data();
    const gamesPlayed = stats.gamesPlayed || 0;
    const gamesLost = stats.gamesLost || 0;
    const gamesWon = stats.gamesWon || 0;

    // Minimum threshold: at least 3 matchups
    if (gamesPlayed >= 3) {
      // Check if this opponent has caused more losses
      if (gamesLost > maxLosses) {
        maxLosses = gamesLost;

        // Fetch opponent name from user document
        const opponentDoc = await db.collection("users").doc(doc.id).get();
        const opponentData = opponentDoc.data();
        const opponentName = opponentData?.displayName ||
                             opponentData?.firstName && opponentData?.lastName
                               ? `${opponentData.firstName} ${opponentData.lastName}`
                               : opponentData?.email || "Unknown";

        const winRate = gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

        nemesis = {
          opponentId: doc.id,
          opponentName: opponentName,
          gamesLost: gamesLost,
          gamesWon: gamesWon,
          gamesPlayed: gamesPlayed,
          winRate: winRate,
        };
      } else if (gamesLost === maxLosses && gamesLost > 0) {
        // Tiebreaker: if tied on losses, choose opponent with most total matchups
        if (nemesis === null || gamesPlayed > nemesis.gamesPlayed) {
          // Fetch opponent name
          const opponentDoc = await db.collection("users").doc(doc.id).get();
          const opponentData = opponentDoc.data();
          const opponentName = opponentData?.displayName ||
                               opponentData?.firstName && opponentData?.lastName
                                 ? `${opponentData.firstName} ${opponentData.lastName}`
                                 : opponentData?.email || "Unknown";

          const winRate = gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

          nemesis = {
            opponentId: doc.id,
            opponentName: opponentName,
            gamesLost: gamesLost,
            gamesWon: gamesWon,
            gamesPlayed: gamesPlayed,
            winRate: winRate,
          };
        }
      }
    }
  }

  // Update user's nemesis field
  await userRef.update({
    nemesis: nemesis,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  if (nemesis) {
    functions.logger.info(
      `Updated nemesis for ${userId}: ${nemesis.opponentName} ` +
      `(${nemesis.gamesWon}W-${nemesis.gamesLost}L, ` +
      `Win Rate: ${nemesis.winRate.toFixed(1)}%)`
    );
  } else {
    functions.logger.info(
      `No nemesis found for ${userId} (no opponents with 3+ games)`
    );
  }
}

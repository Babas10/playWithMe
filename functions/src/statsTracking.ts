import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Update teammate statistics after a game completes.
 * Tracks performance metrics for players who played together on the same team.
 */
export async function updateTeammateStats(
  transaction: admin.firestore.Transaction,
  playerId: string,
  teammateId: string,
  won: boolean,
  pointsScored: number,
  pointsAllowed: number,
  eloChange: number,
  gameId: string
): Promise<void> {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(playerId);

  // Fetch current teammate stats
  const userDoc = await transaction.get(userRef);
  const userData = userDoc.data();
  const teammateStats = userData?.teammateStats || {};
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
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
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
 */
export async function updateHeadToHeadStats(
  transaction: admin.firestore.Transaction,
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
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      },
      ...(currentStats.recentMatchups || []).slice(0, 9), // Keep last 10 matchups
    ],
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  };

  // Set or update the document
  transaction.set(h2hRef, updatedStats, {merge: true});

  functions.logger.info(
    `Updated head-to-head stats for ${playerId} vs ${opponentId}: ` +
    `${updatedStats.gamesWon}W-${updatedStats.gamesLost}L, ` +
    `Win Rate: ${((updatedStats.gamesWon / updatedStats.gamesPlayed) * 100).toFixed(1)}%`
  );
}

/**
 * Process all teammate and head-to-head stats updates for a completed game.
 * Called from the main ELO processing transaction.
 */
export async function processStatsTracking(
  transaction: admin.firestore.Transaction,
  gameId: string,
  teamAPlayerIds: string[],
  teamBPlayerIds: string[],
  teamAWon: boolean,
  individualGames: any[],
  playerEloChanges: Map<string, number>
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

      await updateTeammateStats(
        transaction,
        playerId,
        teammateId,
        teamAWon,
        teamAPoints,
        teamBPoints,
        eloChange,
        gameId
      );

      await updateTeammateStats(
        transaction,
        teammateId,
        playerId,
        teamAWon,
        teamAPoints,
        teamBPoints,
        playerEloChanges.get(teammateId) || 0,
        gameId
      );
    }
  }

  // Team B partnerships
  for (let i = 0; i < teamBPlayerIds.length; i++) {
    for (let j = i + 1; j < teamBPlayerIds.length; j++) {
      const playerId = teamBPlayerIds[i];
      const teammateId = teamBPlayerIds[j];
      const eloChange = playerEloChanges.get(playerId) || 0;

      await updateTeammateStats(
        transaction,
        playerId,
        teammateId,
        !teamAWon, // Team B won if Team A didn't win
        teamBPoints,
        teamAPoints,
        eloChange,
        gameId
      );

      await updateTeammateStats(
        transaction,
        teammateId,
        playerId,
        !teamAWon,
        teamBPoints,
        teamAPoints,
        playerEloChanges.get(teammateId) || 0,
        gameId
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
        transaction,
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
        transaction,
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

  functions.logger.info(
    `Successfully processed teammate and head-to-head stats for game ${gameId}`
  );
}

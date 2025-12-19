import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Scheduled Cloud Function that auto-aborts games with insufficient players.
 *
 * Runs every 1 minute to check for games where:
 * - status is 'scheduled'
 * - scheduledAt time has passed
 * - playerIds.length < 4 (beach volleyball is always 2v2)
 *
 * When a game is auto-aborted:
 * 1. Game status is updated to 'cancelled'
 * 2. A note is added: "Game auto-aborted due to insufficient players."
 * 3. The onGameCancelled Firestore trigger (notifications.ts) automatically fires
 * 4. All players and waitlist users receive notifications (respecting their preferences)
 *
 * Story #285: Auto-Abort Games with Insufficient Players
 */
export const autoAbortGames = functions.pubsub
  .schedule('every 1 minutes') // Runs every minute for fast response
  .onRun(async (context) => {
    const firestore = admin.firestore();
    const now = admin.firestore.Timestamp.now();


    functions.logger.info('Running autoAbortGames scheduled job', { now: now.toDate() });

    try {
      // Query for scheduled games whose scheduled time has passed
      // and which have not yet started or been cancelled
      const gamesToProcessSnapshot = await firestore.collection('games')
        .where('status', '==', 'scheduled')
        .where('scheduledAt', '<=', now)
        .get();

      if (gamesToProcessSnapshot.empty) {
        functions.logger.info('No games to auto-abort found.');
        return null;
      }

      const updates: Promise<FirebaseFirestore.WriteResult>[] = [];
      const abortedGameIds: string[] = [];

      for (const doc of gamesToProcessSnapshot.docs) {
        const gameData = doc.data();
        const gameId = doc.id;
        const playerIds = gameData.playerIds || [];
        const MIN_PLAYERS_REQUIRED = 4; // Beach volleyball is always 2v2 = 4 players

        if (playerIds.length < MIN_PLAYERS_REQUIRED) {
          functions.logger.info(`Aborting game ${gameId} due to insufficient players.`, {
            gameId,
            currentPlayers: playerIds.length,
            minPlayersRequired: MIN_PLAYERS_REQUIRED,
            scheduledAt: gameData.scheduledAt.toDate(),
          });

          // Update game status to 'cancelled'
          updates.push(doc.ref.update({
            status: 'cancelled',
            updatedAt: now,
            notes: 'Game auto-aborted due to insufficient players.',
          }));
          abortedGameIds.push(gameId);
        }
      }

      await Promise.all(updates);

      functions.logger.info(`Successfully processed ${gamesToProcessSnapshot.size} games. Aborted ${abortedGameIds.length} games.`, { abortedGameIds });

    } catch (error: unknown) {
      let errorMessage = 'An unknown error occurred';
      if (error instanceof Error) {
        errorMessage = error.message;
      }
      functions.logger.error('Error in autoAbortGames scheduled job', { error: errorMessage });
      // Depending on policy, rethrow or handle to prevent infinite retries if the error is transient
      throw error;
    }

    return null;
  });

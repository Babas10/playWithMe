import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Get head-to-head statistics between the authenticated user and an opponent.
 *
 * Security: User can only retrieve their own head-to-head stats.
 *
 * @param opponentId - The ID of the opponent to get stats against
 * @returns Head-to-head statistics document or null if not found
 */
export const getHeadToHeadStats = functions.https.onCall(
  async (data, context) => {
    // Validate authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to view head-to-head statistics."
      );
    }

    // Validate input
    if (!data || typeof data.opponentId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        'Expected parameter "opponentId" of type string.'
      );
    }

    const userId = context.auth.uid;
    const opponentId = data.opponentId;

    try {
      const db = admin.firestore();

      // Fetch head-to-head stats document
      const h2hDoc = await db
        .collection("users")
        .doc(userId)
        .collection("headToHead")
        .doc(opponentId)
        .get();

      if (!h2hDoc.exists) {
        return null;
      }

      const h2hData = h2hDoc.data();

      if (!h2hData) {
        return null;
      }

      // Convert Firestore Timestamps to ISO strings for proper JSON serialization
      const serializedData = {
        ...h2hData,
        lastUpdated: h2hData.lastUpdated?.toDate().toISOString() || null,
        recentMatchups: (h2hData.recentMatchups || []).map((matchup: any) => ({
          ...matchup,
          timestamp: matchup.timestamp?.toDate().toISOString() || null,
        })),
      };

      functions.logger.info(
        `Retrieved head-to-head stats for ${userId} vs ${opponentId}: ` +
        `${h2hData.gamesWon}W-${h2hData.gamesLost}L`
      );

      return serializedData;
    } catch (error) {
      functions.logger.error(
        `Error retrieving head-to-head stats for ${userId} vs ${opponentId}:`,
        error
      );
      throw new functions.https.HttpsError(
        "internal",
        "Failed to retrieve head-to-head statistics. Please try again later."
      );
    }
  }
);

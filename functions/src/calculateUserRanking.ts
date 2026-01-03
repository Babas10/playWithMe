import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Response interface for calculateUserRanking Cloud Function (Story 302.2)
 */
export interface UserRankingResponse {
  globalRank: number;
  totalUsers: number;
  percentile: number;
  friendsRank: number | null;
  totalFriends: number | null;
  calculatedAt: number; // Milliseconds since epoch
}

/**
 * Handler function for calculating user ranking (exported for testing)
 *
 * Calculates user's global rank, percentile, and friends rank based on ELO rating.
 * Uses cross-user queries which require Admin SDK (cannot be done from client).
 *
 * @param data - Request data (unused, but required by onCall signature)
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to UserRankingResponse
 */
export async function calculateUserRankingHandler(
  data: any,
  context: functions.https.CallableContext
): Promise<UserRankingResponse> {
  // 1. Authentication check (CRITICAL - per CLAUDE.md Section 11.3)
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to view rankings."
    );
  }

  const userId = context.auth.uid;
  const db = admin.firestore();

  functions.logger.info("Calculating user ranking", {userId});

  try {
    // 2. Get user's current ELO rating
    const userDoc = await db.doc(`users/${userId}`).get();
    if (!userDoc.exists) {
      functions.logger.warn("User not found", {userId});
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    const userData = userDoc.data();
    if (!userData) {
      throw new functions.https.HttpsError("not-found", "User data not found");
    }

    const userElo = userData.eloRating || 1600;
    const eloGamesPlayed = userData.eloGamesPlayed || 0;

    functions.logger.info("User ELO retrieved", {
      userId,
      userElo,
      eloGamesPlayed,
    });

    // 3. Calculate global rank (count users with higher ELO)
    const higherEloCount = await db
      .collection("users")
      .where("eloRating", ">", userElo)
      .where("eloGamesPlayed", ">", 0)
      .count()
      .get();

    const globalRank = higherEloCount.data().count + 1;

    // 4. Get total users with ELO ratings (at least 1 game played)
    const totalUsersSnapshot = await db
      .collection("users")
      .where("eloGamesPlayed", ">", 0)
      .count()
      .get();

    const totalUsers = totalUsersSnapshot.data().count;

    // 5. Calculate percentile (0-100, where 100 = top performer)
    const percentile =
      totalUsers > 0 ? ((totalUsers - globalRank + 1) / totalUsers) * 100 : 0;

    functions.logger.info("Global ranking calculated", {
      userId,
      globalRank,
      totalUsers,
      percentile,
    });

    // 6. Calculate friends rank (if user has friends)
    let friendsRank: number | null = null;
    let totalFriends: number | null = null;

    const friendIds = (userData.friendIds || []) as string[];

    if (friendIds.length > 0) {
      functions.logger.info("Calculating friends ranking", {
        userId,
        friendCount: friendIds.length,
      });

      // Handle Firestore 'in' query limit of 10 items
      const friendsWithHigherElo: number[] = [];
      const friendsWithElo: number[] = [];

      // Process friends in batches of 10
      for (let i = 0; i < friendIds.length; i += 10) {
        const batch = friendIds.slice(i, i + 10);

        const friendsSnapshot = await db
          .collection("users")
          .where(admin.firestore.FieldPath.documentId(), "in", batch)
          .select("eloRating", "eloGamesPlayed")
          .get();

        friendsSnapshot.docs.forEach((doc) => {
          const friendData = doc.data();
          const friendElo = friendData.eloRating || 1600;
          const friendGamesPlayed = friendData.eloGamesPlayed || 0;

          // Only count friends who have played at least one ELO game
          if (friendGamesPlayed > 0) {
            friendsWithElo.push(friendElo);
            if (friendElo > userElo) {
              friendsWithHigherElo.push(friendElo);
            }
          }
        });
      }

      // Only set ranking if user has friends with ELO ratings
      if (friendsWithElo.length > 0) {
        friendsRank = friendsWithHigherElo.length + 1;
        totalFriends = friendsWithElo.length;

        functions.logger.info("Friends ranking calculated", {
          userId,
          friendsRank,
          totalFriends,
        });
      } else {
        functions.logger.info("No friends with ELO ratings", {userId});
      }
    } else {
      functions.logger.info("User has no friends", {userId});
    }

    // 7. Return ranking data
    const response: UserRankingResponse = {
      globalRank,
      totalUsers,
      percentile: parseFloat(percentile.toFixed(2)),
      friendsRank,
      totalFriends,
      calculatedAt: Date.now(), // Milliseconds since epoch (compatible with Flutter DateTime)
    };

    functions.logger.info("Ranking calculation complete", {
      userId,
      response: {
        ...response,
        calculatedAt: "[ServerTimestamp]",
      },
    });

    return response;
  } catch (error) {
    functions.logger.error("Error calculating ranking", {
      userId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    // Re-throw HttpsError as-is, wrap other errors
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      "internal",
      "Failed to calculate ranking. Please try again."
    );
  }
}

/**
 * Cloud Function to calculate user's ranking across global and friends contexts (Story 302.2).
 *
 * This function requires cross-user queries which cannot be performed from the client
 * due to Firestore security rules. The Admin SDK is used to bypass rules securely.
 *
 * Security:
 * - Requires authentication
 * - User can only query their own ranking
 * - Returns only non-sensitive aggregated data
 * - Validates user existence before calculation
 * - Structured error handling with appropriate codes
 *
 * Performance:
 * - Uses Firestore count() aggregation queries
 * - Batch processes friends (handles > 10 friends)
 * - Indexed queries on eloRating and eloGamesPlayed
 *
 * Use cases:
 * - Monthly improvement chart ranking stats
 * - User profile ranking display
 * - Leaderboard comparisons
 */
export const calculateUserRanking = functions.https.onCall(
  calculateUserRankingHandler
);

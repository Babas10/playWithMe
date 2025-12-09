import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for getCompletedGames Cloud Function
 */
export interface GetCompletedGamesRequest {
  groupId?: string; // Optional - null/undefined means all groups
  userId?: string; // Optional - filter by player participation
  startDate?: string; // ISO date string
  endDate?: string; // ISO date string
  limit?: number; // Number of games to return (default: 20)
  lastGameId?: string; // For pagination - ID of last game from previous page
}

/**
 * Completed game data returned by the function
 */
export interface CompletedGameData {
  id: string;
  title: string;
  description?: string;
  groupId: string;
  createdBy: string;
  createdAt: FirebaseFirestore.Timestamp;
  scheduledAt: FirebaseFirestore.Timestamp;
  completedAt?: FirebaseFirestore.Timestamp;
  location: {
    name: string;
    address?: string;
    latitude?: number;
    longitude?: number;
  };
  status: string;
  playerIds: string[];
  teams?: {
    teamAPlayerIds: string[];
    teamBPlayerIds: string[];
  };
  result?: {
    games: Array<{
      setNumber: number;
      teamAScore: number;
      teamBScore: number;
      winner: string;
    }>;
    overallWinner: string;
  };
  eloCalculated: boolean;
}

/**
 * Response interface for getCompletedGames Cloud Function
 */
export interface GetCompletedGamesResponse {
  games: CompletedGameData[];
  hasMore: boolean;
}

/**
 * Handler function for getting completed games (exported for testing)
 *
 * Security:
 * - Validates user authentication
 * - For groupId queries: Verifies user is a member of the group
 * - For cross-group queries: Only returns games the user participated in
 * - Returns only completed games with pagination support
 * - Uses Admin SDK to bypass Firestore security rules
 *
 * @param data - Request data with optional filters
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to GetCompletedGamesResponse
 */
export async function getCompletedGamesHandler(
  data: GetCompletedGamesRequest,
  context: functions.https.CallableContext
): Promise<GetCompletedGamesResponse> {
  // Validate authentication
  if (!context.auth) {
    functions.logger.warn("Unauthenticated request to getCompletedGames");
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to view game history"
    );
  }

  const currentUserId = context.auth.uid;
  const {groupId, userId, startDate, endDate, limit = 20, lastGameId} = data;

  functions.logger.info("Fetching completed games", {
    currentUserId,
    groupId,
    userId,
    startDate,
    endDate,
    limit,
    lastGameId,
  });

  const db = admin.firestore();

  try {
    // If groupId is specified, verify user is a member
    if (groupId) {
      const groupDoc = await db.collection("groups").doc(groupId).get();

      if (!groupDoc.exists) {
        functions.logger.warn("Group not found", {
          currentUserId,
          groupId,
        });
        throw new functions.https.HttpsError(
          "not-found",
          "Group not found"
        );
      }

      const groupData = groupDoc.data();
      if (!groupData) {
        throw new functions.https.HttpsError(
          "internal",
          "Failed to read group data"
        );
      }

      const memberIds = groupData.memberIds || [];
      if (!memberIds.includes(currentUserId)) {
        functions.logger.warn("User not a member of group", {
          currentUserId,
          groupId,
        });
        throw new functions.https.HttpsError(
          "permission-denied",
          "You must be a member of this group to view its game history"
        );
      }
    }

    // Build query
    let query: FirebaseFirestore.Query = db.collection("games");

    // Filter by status (completed games only)
    query = query.where("status", "==", "completed");

    // Filter by groupId if specified
    if (groupId) {
      query = query.where("groupId", "==", groupId);
    }

    // For cross-group queries, filter by user participation
    // This is a security measure - users can only see games they played in
    if (!groupId || userId) {
      const filterUserId = userId || currentUserId;
      query = query.where("playerIds", "array-contains", filterUserId);
    }

    // Filter by date range
    if (startDate) {
      const start = admin.firestore.Timestamp.fromDate(new Date(startDate));
      query = query.where("completedAt", ">=", start);
    }
    if (endDate) {
      const end = admin.firestore.Timestamp.fromDate(new Date(endDate));
      query = query.where("completedAt", "<=", end);
    }

    // Order by completedAt (most recent first)
    query = query.orderBy("completedAt", "desc");

    // Handle pagination
    if (lastGameId) {
      const lastGameDoc = await db.collection("games").doc(lastGameId).get();
      if (lastGameDoc.exists) {
        query = query.startAfter(lastGameDoc);
      }
    }

    // Fetch limit + 1 to check if there are more results
    query = query.limit(limit + 1);

    const gamesSnapshot = await query.get();

    const hasMore = gamesSnapshot.docs.length > limit;
    const gameDocs = hasMore ?
      gamesSnapshot.docs.slice(0, limit) :
      gamesSnapshot.docs;

    const games: CompletedGameData[] = [];

    for (const doc of gameDocs) {
      if (doc.exists) {
        const gameData = doc.data();

        games.push({
          id: doc.id,
          title: gameData.title,
          description: gameData.description,
          groupId: gameData.groupId,
          createdBy: gameData.createdBy,
          createdAt: gameData.createdAt,
          scheduledAt: gameData.scheduledAt,
          completedAt: gameData.completedAt,
          location: gameData.location,
          status: gameData.status,
          playerIds: gameData.playerIds || [],
          teams: gameData.teams,
          result: gameData.result,
          eloCalculated: gameData.eloCalculated ?? false,
        });
      }
    }

    functions.logger.info("Completed games fetched successfully", {
      currentUserId,
      groupId,
      userId,
      gamesCount: games.length,
      hasMore,
    });

    return {games, hasMore};
  } catch (error) {
    // Re-throw HttpsError as-is
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Log and wrap unexpected errors
    functions.logger.error("Error fetching completed games", {
      currentUserId,
      groupId,
      userId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    throw new functions.https.HttpsError(
      "internal",
      "Failed to fetch completed games"
    );
  }
}

/**
 * Cloud Function to securely fetch completed games with pagination.
 *
 * This function allows users to retrieve their game history with flexible filtering:
 * - By group: Returns completed games for a specific group (requires membership)
 * - Cross-group: Returns all completed games the user participated in (any group)
 * - By date range: Filter games by completion date
 * - By player: Filter to specific player's games
 *
 * Security:
 * - Requires authentication
 * - For group-specific queries: Validates user is a member
 * - For cross-group queries: Automatically filters to user's own games only
 * - Uses Admin SDK to bypass security rules (centralized permission check)
 *
 * Pagination:
 * - Returns up to `limit` games (default: 20)
 * - Provides `hasMore` flag to indicate if more results exist
 * - Use `lastGameId` to fetch next page
 *
 * Usage from Flutter:
 * ```dart
 * final callable = FirebaseFunctions.instance.httpsCallable('getCompletedGames');
 * final result = await callable.call({
 *   'groupId': 'group-123', // optional
 *   'userId': 'user-456',   // optional
 *   'limit': 20,
 *   'lastGameId': 'game-789' // for pagination
 * });
 * ```
 */
export const getCompletedGames = functions.https.onCall(
  getCompletedGamesHandler
);

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for getGamesForGroup Cloud Function
 */
export interface GetGamesForGroupRequest {
  groupId: string;
}

/**
 * Game data returned by the function
 */
export interface GameData {
  id: string;
  title: string;
  description?: string;
  groupId: string;
  createdBy: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  scheduledAt: FirebaseFirestore.Timestamp;
  startedAt?: FirebaseFirestore.Timestamp;
  endedAt?: FirebaseFirestore.Timestamp;
  location: {
    name: string;
    address?: string;
    latitude?: number;
    longitude?: number;
    description?: string;
  };
  status: string;
  maxPlayers: number;
  minPlayers: number;
  playerIds: string[];
  waitlistIds: string[];
  allowWaitlist: boolean;
  allowPlayerInvites: boolean;
  visibility: string;
  notes?: string;
  equipment?: string[];
  gameType?: string;
  skillLevel?: string;
  scores?: Array<{
    playerId: string;
    score: number;
  }>;
  winnerId?: string;
  estimatedDuration?: number;
  weatherDependent?: boolean;
  weatherNotes?: string;
}

/**
 * Response interface for getGamesForGroup Cloud Function
 */
export interface GetGamesForGroupResponse {
  games: GameData[];
}

/**
 * Handler function for getting games for a specific group (exported for testing)
 *
 * Security:
 * - Validates user authentication
 * - Verifies user is a member of the group
 * - Returns all games for the group (upcoming and past)
 * - Uses Admin SDK to bypass Firestore security rules
 *
 * @param data - Request data containing groupId
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to GetGamesForGroupResponse
 */
export async function getGamesForGroupHandler(
  data: GetGamesForGroupRequest,
  context: functions.https.CallableContext
): Promise<GetGamesForGroupResponse> {
  // Validate authentication
  if (!context.auth) {
    functions.logger.warn("Unauthenticated request to getGamesForGroup");
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to view games"
    );
  }

  const currentUserId = context.auth.uid;
  const {groupId} = data;

  // Validate required parameters
  if (!groupId || typeof groupId !== "string") {
    functions.logger.warn("Missing or invalid groupId", {
      currentUserId,
      groupId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "groupId is required and must be a string"
    );
  }

  functions.logger.info("Fetching games for group", {
    currentUserId,
    groupId,
  });

  const db = admin.firestore();

  try {
    // Verify group exists and user is a member
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
      functions.logger.error("Group document has no data", {
        currentUserId,
        groupId,
      });
      throw new functions.https.HttpsError(
        "internal",
        "Failed to read group data"
      );
    }

    // Check if user is a member of the group
    const memberIds = groupData.memberIds || [];
    if (!memberIds.includes(currentUserId)) {
      functions.logger.warn("User not a member of group", {
        currentUserId,
        groupId,
      });
      throw new functions.https.HttpsError(
        "permission-denied",
        "You must be a member of this group to view its games"
      );
    }

    // Query all games for this group, ordered by scheduled time
    const gamesSnapshot = await db
      .collection("games")
      .where("groupId", "==", groupId)
      .orderBy("scheduledAt", "asc")
      .get();

    const games: GameData[] = [];

    for (const doc of gamesSnapshot.docs) {
      if (doc.exists) {
        const gameData = doc.data();

        // Map Firestore document to GameData interface
        games.push({
          id: doc.id,
          title: gameData.title,
          description: gameData.description,
          groupId: gameData.groupId,
          createdBy: gameData.createdBy,
          createdAt: gameData.createdAt,
          updatedAt: gameData.updatedAt,
          scheduledAt: gameData.scheduledAt,
          startedAt: gameData.startedAt,
          endedAt: gameData.endedAt,
          location: gameData.location,
          status: gameData.status,
          maxPlayers: gameData.maxPlayers,
          minPlayers: gameData.minPlayers,
          playerIds: gameData.playerIds || [],
          waitlistIds: gameData.waitlistIds || [],
          allowWaitlist: gameData.allowWaitlist ?? true,
          allowPlayerInvites: gameData.allowPlayerInvites ?? true,
          visibility: gameData.visibility || "group",
          notes: gameData.notes,
          equipment: gameData.equipment,
          gameType: gameData.gameType,
          skillLevel: gameData.skillLevel,
          scores: gameData.scores,
          winnerId: gameData.winnerId,
          estimatedDuration: gameData.estimatedDuration,
          weatherDependent: gameData.weatherDependent,
          weatherNotes: gameData.weatherNotes,
        });
      }
    }

    functions.logger.info("Games fetched successfully", {
      currentUserId,
      groupId,
      gamesCount: games.length,
    });

    return {games};
  } catch (error) {
    // Re-throw HttpsError as-is
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Log and wrap unexpected errors
    functions.logger.error("Error fetching games for group", {
      currentUserId,
      groupId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    throw new functions.https.HttpsError(
      "internal",
      "Failed to fetch games for group"
    );
  }
}

/**
 * Cloud Function to securely fetch all games for a specific group.
 *
 * This function allows group members to retrieve all games (upcoming and past)
 * for a group they belong to. The function validates group membership before
 * returning any data.
 *
 * Security:
 * - Requires authentication
 * - Validates user is a member of the group
 * - Uses Admin SDK to bypass security rules (centralized permission check)
 * - Returns complete game data for client-side filtering and sorting
 *
 * Usage:
 * - Alternative to direct Firestore snapshots for one-time data fetch
 * - Firestore security rules also allow direct .snapshots() queries filtered by groupId
 * - This function provides a callable alternative when direct queries are not suitable
 * - Useful for batch operations or when additional server-side validation is needed
 *
 * Note: The primary method for real-time game updates is Firestore snapshots
 * (see FirestoreGameRepository.getGamesForGroup). This function serves as
 * a complementary approach for specific use cases.
 */
export const getGamesForGroup = functions.https.onCall(getGamesForGroupHandler);

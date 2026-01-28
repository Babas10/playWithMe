import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for getUpcomingGamesForUser Cloud Function
 */
export interface GetUpcomingGamesForUserRequest {
  // No parameters needed - uses authenticated user's ID
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
 * Response interface for getUpcomingGamesForUser Cloud Function
 */
export interface GetUpcomingGamesForUserResponse {
  games: GameData[];
}

/**
 * Handler function for getting upcoming games for the authenticated user
 *
 * Security:
 * - Validates user authentication
 * - Returns only games where user is in playerIds
 * - Filters for future games (scheduledAt > now)
 * - Excludes cancelled games
 * - Uses Admin SDK to bypass Firestore security rules
 *
 * @param data - Request data (empty - uses auth context)
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to GetUpcomingGamesForUserResponse
 */
export async function getUpcomingGamesForUserHandler(
  data: GetUpcomingGamesForUserRequest,
  context: functions.https.CallableContext
): Promise<GetUpcomingGamesForUserResponse> {
  // Validate authentication
  if (!context.auth) {
    functions.logger.warn("Unauthenticated request to getUpcomingGamesForUser");
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to view games"
    );
  }

  const currentUserId = context.auth.uid;

  functions.logger.info("Fetching upcoming games for user", {
    currentUserId,
  });

  const db = admin.firestore();

  try {
    // Query games where user is a player and scheduled in the future
    const now = admin.firestore.Timestamp.now();
    const gamesSnapshot = await db
      .collection("games")
      .where("playerIds", "array-contains", currentUserId)
      .where("scheduledAt", ">", now)
      .orderBy("scheduledAt", "asc")
      .get();

    const games: GameData[] = [];

    for (const doc of gamesSnapshot.docs) {
      if (doc.exists) {
        const gameData = doc.data();

        // Exclude cancelled games
        if (gameData.status === "cancelled") {
          continue;
        }

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

    functions.logger.info("Upcoming games fetched successfully", {
      currentUserId,
      gamesCount: games.length,
    });

    return {games};
  } catch (error) {
    // Re-throw HttpsError as-is
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Log and wrap unexpected errors
    functions.logger.error("Error fetching upcoming games for user", {
      currentUserId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    throw new functions.https.HttpsError(
      "internal",
      "Failed to fetch upcoming games"
    );
  }
}

/**
 * Cloud Function to securely fetch upcoming games for the authenticated user.
 *
 * This function allows users to retrieve all their upcoming games (where they
 * are in the playerIds list). Games are filtered to show only future games
 * (scheduledAt > now) and exclude cancelled games.
 *
 * Security:
 * - Requires authentication
 * - Returns only games where user is a participant (playerIds)
 * - Uses Admin SDK to bypass security rules (efficient query)
 * - Filters for future games only
 * - Excludes cancelled games
 *
 * Usage:
 * - Used by homepage to display next upcoming game
 * - Returns games sorted by scheduledAt ascending (chronologically)
 * - Client can take the first game to display as "Next Game"
 *
 * Example:
 * ```dart
 * final callable = FirebaseFunctions.instance.httpsCallable('getUpcomingGamesForUser');
 * final result = await callable.call();
 * final games = result.data['games'] as List;
 * final nextGame = games.isNotEmpty ? games.first : null;
 * ```
 */
export const getUpcomingGamesForUser = functions.https.onCall(
  getUpcomingGamesForUserHandler
);

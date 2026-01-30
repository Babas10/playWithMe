import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for getUpcomingTrainingSessionsForUser Cloud Function
 */
export interface GetUpcomingTrainingSessionsForUserRequest {
  // No parameters needed - uses authenticated user's ID
}

/**
 * Training session data returned by the function
 */
export interface TrainingSessionData {
  id: string;
  groupId: string;
  createdBy: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt?: FirebaseFirestore.Timestamp;
  title: string;
  description?: string;
  startTime: FirebaseFirestore.Timestamp;
  endTime: FirebaseFirestore.Timestamp;
  location: {
    name: string;
    address?: string;
    latitude?: number;
    longitude?: number;
    description?: string;
  };
  status: string;
  maxParticipants: number;
  minParticipants: number;
  participantIds: string[];
  notes?: string;
  parentSessionId?: string;
  recurrenceRule?: {
    frequency: string;
    interval: number;
    daysOfWeek?: number[];
    endDate?: FirebaseFirestore.Timestamp;
    maxOccurrences?: number;
  };
  cancelledAt?: FirebaseFirestore.Timestamp;
  cancelledBy?: string;
}

/**
 * Response interface for getUpcomingTrainingSessionsForUser Cloud Function
 */
export interface GetUpcomingTrainingSessionsForUserResponse {
  sessions: TrainingSessionData[];
}

/**
 * Handler function for getting upcoming training sessions for the authenticated user
 *
 * This function returns upcoming training sessions from ALL groups the user
 * is a member of, regardless of whether they have joined the session.
 * This helps promote training sessions and encourages participation.
 *
 * Security:
 * - Validates user authentication
 * - Returns sessions from groups where user is a member
 * - Filters for future sessions (startTime > now)
 * - Excludes cancelled sessions
 * - Uses Admin SDK to bypass Firestore security rules
 *
 * @param data - Request data (empty - uses auth context)
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to GetUpcomingTrainingSessionsForUserResponse
 */
export async function getUpcomingTrainingSessionsForUserHandler(
  data: GetUpcomingTrainingSessionsForUserRequest,
  context: functions.https.CallableContext
): Promise<GetUpcomingTrainingSessionsForUserResponse> {
  // Validate authentication
  if (!context.auth) {
    functions.logger.warn(
      "Unauthenticated request to getUpcomingTrainingSessionsForUser"
    );
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to view training sessions"
    );
  }

  const currentUserId = context.auth.uid;

  functions.logger.info("Fetching upcoming training sessions for user", {
    currentUserId,
  });

  const db = admin.firestore();

  try {
    // Step 1: Get all groups the user is a member of
    const groupsSnapshot = await db
      .collection("groups")
      .where("memberIds", "array-contains", currentUserId)
      .get();

    if (groupsSnapshot.empty) {
      functions.logger.info("User is not a member of any groups", {
        currentUserId,
      });
      return {sessions: []};
    }

    const groupIds = groupsSnapshot.docs.map((doc) => doc.id);

    functions.logger.info("Found groups for user", {
      currentUserId,
      groupCount: groupIds.length,
      groupIds,
    });

    // Step 2: Query training sessions from those groups
    // Firestore 'in' query is limited to 30 values, so we may need to batch
    const now = admin.firestore.Timestamp.now();
    const allSessions: TrainingSessionData[] = [];

    // Process in batches of 30 (Firestore 'in' query limit)
    const batchSize = 30;
    for (let i = 0; i < groupIds.length; i += batchSize) {
      const batchGroupIds = groupIds.slice(i, i + batchSize);

      const sessionsSnapshot = await db
        .collection("trainingSessions")
        .where("groupId", "in", batchGroupIds)
        .where("startTime", ">", now)
        .where("status", "==", "scheduled")
        .orderBy("startTime", "asc")
        .get();

      for (const doc of sessionsSnapshot.docs) {
        if (doc.exists) {
          const sessionData = doc.data();

          // Map Firestore document to TrainingSessionData interface
          allSessions.push({
            id: doc.id,
            groupId: sessionData.groupId,
            createdBy: sessionData.createdBy,
            createdAt: sessionData.createdAt,
            updatedAt: sessionData.updatedAt,
            title: sessionData.title,
            description: sessionData.description,
            startTime: sessionData.startTime,
            endTime: sessionData.endTime,
            location: sessionData.location,
            status: sessionData.status,
            maxParticipants: sessionData.maxParticipants,
            minParticipants: sessionData.minParticipants,
            participantIds: sessionData.participantIds || [],
            notes: sessionData.notes,
            parentSessionId: sessionData.parentSessionId,
            recurrenceRule: sessionData.recurrenceRule,
            cancelledAt: sessionData.cancelledAt,
            cancelledBy: sessionData.cancelledBy,
          });
        }
      }
    }

    // Sort all sessions by startTime (in case we had multiple batches)
    allSessions.sort((a, b) => {
      return a.startTime.toMillis() - b.startTime.toMillis();
    });

    functions.logger.info("Upcoming training sessions fetched successfully", {
      currentUserId,
      sessionsCount: allSessions.length,
    });

    return {sessions: allSessions};
  } catch (error) {
    // Re-throw HttpsError as-is
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Log and wrap unexpected errors
    functions.logger.error(
      "Error fetching upcoming training sessions for user",
      {
        currentUserId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      }
    );

    throw new functions.https.HttpsError(
      "internal",
      "Failed to fetch upcoming training sessions"
    );
  }
}

/**
 * Cloud Function to securely fetch upcoming training sessions for the
 * authenticated user.
 *
 * This function returns upcoming training sessions from ALL groups the user
 * is a member of, regardless of whether they have joined the session yet.
 * This is designed to help promote training sessions and encourage participation.
 *
 * Security:
 * - Requires authentication
 * - Returns sessions from groups where user is a member (memberIds)
 * - Uses Admin SDK to bypass security rules (efficient query)
 * - Filters for future sessions only (startTime > now)
 * - Only returns scheduled sessions (excludes cancelled/completed)
 *
 * Usage:
 * - Used by homepage to display next upcoming training session
 * - Returns sessions sorted by startTime ascending (chronologically)
 * - Client can take the first session to display as "Next Training Session"
 *
 * Example:
 * ```dart
 * final callable = FirebaseFunctions.instance
 *     .httpsCallable('getUpcomingTrainingSessionsForUser');
 * final result = await callable.call();
 * final sessions = result.data['sessions'] as List;
 * final nextSession = sessions.isNotEmpty ? sessions.first : null;
 * ```
 */
export const getUpcomingTrainingSessionsForUser = functions.https.onCall(
  getUpcomingTrainingSessionsForUserHandler
);

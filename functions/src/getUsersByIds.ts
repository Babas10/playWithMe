import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for getUsersByIds Cloud Function
 */
export interface GetUsersByIdsRequest {
  userIds: string[];
}

/**
 * User data returned by the function (public data only)
 */
export interface PublicUserData {
  uid: string;
  displayName: string | null;
  email: string;
  photoUrl: string | null;
}

/**
 * Response interface for getUsersByIds Cloud Function
 */
export interface GetUsersByIdsResponse {
  users: PublicUserData[];
}

/**
 * Handler function for getting users by IDs (exported for testing)
 *
 * @param data - Request data containing array of user IDs
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to GetUsersByIdsResponse
 */
export async function getUsersByIdsHandler(
  data: GetUsersByIdsRequest,
  context: functions.https.CallableContext
): Promise<GetUsersByIdsResponse> {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to fetch users"
    );
  }

  const {userIds} = data;

  // Validate required parameters
  if (!userIds || !Array.isArray(userIds)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "userIds is required and must be an array"
    );
  }

  // Limit to prevent abuse
  if (userIds.length > 100) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Maximum 100 users can be fetched at once"
    );
  }

  // Return empty array if no IDs provided
  if (userIds.length === 0) {
    return {users: []};
  }

  const db = admin.firestore();
  const users: PublicUserData[] = [];

  try {
    // Firestore 'in' queries are limited to 10 items per batch
    const batchSize = 10;

    for (let i = 0; i < userIds.length; i += batchSize) {
      const batch = userIds.slice(i, i + batchSize);

      const snapshot = await db
        .collection("users")
        .where(admin.firestore.FieldPath.documentId(), "in", batch)
        .get();

      for (const doc of snapshot.docs) {
        if (doc.exists) {
          const userData = doc.data();

          // Return only public/non-sensitive data
          users.push({
            uid: doc.id,
            displayName: userData.displayName || null,
            email: userData.email || "",
            photoUrl: userData.photoUrl || null,
          });
        }
      }
    }

    return {users};
  } catch (error) {
    console.error("Error fetching users:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to fetch users"
    );
  }
}

/**
 * Cloud Function to securely fetch multiple users by their IDs.
 *
 * This function allows fetching public user data for multiple users,
 * which is needed for displaying group member lists.
 *
 * Security:
 * - Requires authentication
 * - Returns only public/non-sensitive user data
 * - Uses Admin SDK to bypass security rules
 * - Limited to 100 users per request to prevent abuse
 */
export const getUsersByIds = functions.https.onCall(getUsersByIdsHandler);

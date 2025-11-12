// Cloud Function for searching users with smart filtering
// Story 11.12: Search Users via Cloud Function
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

interface SearchUsersRequest {
  query: string;
}

interface UserResult {
  uid: string;
  displayName: string | null;
  email: string;
  photoUrl?: string | null;
}

interface SearchUsersResponse {
  users: UserResult[];
}

/**
 * Handler function for searching users (exported for testing)
 *
 * Searches users by email or displayName and filters out:
 * - The current user (self)
 * - Already connected friends
 * - Users with pending friend requests
 *
 * @param data - Object containing { query: string }
 * @param context - Authentication context
 * @returns Object with { users: UserResult[] }
 */
export async function searchUsersHandler(
  data: SearchUsersRequest,
  context: functions.https.CallableContext
): Promise<SearchUsersResponse> {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to search for users"
    );
  }

  // Validate input
  if (!data || typeof data.query !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Query parameter is required and must be a string"
    );
  }

  // Normalize query
  const query = data.query.toLowerCase().trim();

  // Validate minimum query length (per Story 11.12 requirements)
  if (query.length < 3) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Query must be at least 3 characters long"
    );
  }

  const currentUserId = context.auth.uid;
  const db = admin.firestore();

  try {
    // Get current user's friendIds to filter out existing friends
    const currentUserDoc = await db.collection("users").doc(currentUserId).get();
    const friendIds = currentUserDoc.data()?.friendIds || [];

    // Get pending friend requests to filter them out
    const pendingRequestIds = new Set<string>();

    const pendingQuery = await db
      .collection("friendships")
      .where("status", "==", "pending")
      .get();

    for (const doc of pendingQuery.docs) {
      const data = doc.data();
      // If current user is involved in this pending request, add the other user
      if (data.initiatorId === currentUserId) {
        pendingRequestIds.add(data.recipientId);
      } else if (data.recipientId === currentUserId) {
        pendingRequestIds.add(data.initiatorId);
      }
    }

    // Search users collection
    // Note: This is a basic implementation. For production, consider:
    // - Using Algolia or Elasticsearch for better search performance
    // - Implementing pagination for large result sets
    // - Adding fuzzy search capabilities
    const usersSnapshot = await db.collection("users").get();

    const results: UserResult[] = [];

    for (const doc of usersSnapshot.docs) {
      const userData = doc.data();
      const userId = doc.id;

      // Skip if user is self
      if (userId === currentUserId) {
        continue;
      }

      // Skip if already friends
      if (friendIds.includes(userId)) {
        continue;
      }

      // Skip if has pending request
      if (pendingRequestIds.has(userId)) {
        continue;
      }

      // Check if email or displayName matches query
      const email = (userData.email || "").toLowerCase();
      const displayName = (userData.displayName || "").toLowerCase();

      if (email.includes(query) || displayName.includes(query)) {
        results.push({
          uid: userId,
          displayName: userData.displayName || null,
          email: userData.email,
          photoUrl: userData.photoUrl || null,
        });
      }

      // Limit results to prevent huge response sizes
      if (results.length >= 20) {
        break;
      }
    }

    functions.logger.info("Search users completed", {
      userId: currentUserId,
      query: query,
      resultCount: results.length,
    });

    return {
      users: results,
    };
  } catch (error) {
    functions.logger.error("Error searching users", {
      userId: currentUserId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    // Check if it's a permission error
    if ((error as any).code === "permission-denied") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You don't have permission to search for users"
      );
    }

    // Generic error
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred while searching for users"
    );
  }
}

/**
 * Cloud Function to search for users with smart filtering.
 *
 * This function provides a secure way to search users while automatically
 * filtering out users that shouldn't be shown (self, friends, pending requests).
 *
 * Following Epic 11's Cloud Function-first architecture.
 */
export const searchUsers = functions.https.onCall(searchUsersHandler);

// Cloud Function for searching users by email securely
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {checkFriendship} from "./friendships";

interface SearchUserByEmailRequest {
  email: string;
}

interface SearchUserByEmailResponse {
  found: boolean;
  user?: {
    uid: string;
    displayName: string | null;
    email: string;
    photoUrl?: string | null;
  };
  isFriend?: boolean;
  hasPendingRequest?: boolean;
  error?: string;
}

/**
 * Handler function for searching users by email (exported for testing)
 *
 * @param data - Object containing { email: string }
 * @param context - Authentication context
 * @returns Object with { found: boolean, user?: {...}, error?: string }
 */
export async function searchUserByEmailHandler(
  data: SearchUserByEmailRequest,
  context: functions.https.CallableContext
): Promise<SearchUserByEmailResponse> {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to search for users"
    );
  }

  // Validate input
  if (!data || typeof data.email !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Email parameter is required and must be a string"
    );
  }

  // Normalize email
  const email = data.email.toLowerCase().trim();

  if (!email) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Email cannot be empty"
    );
  }

  // Basic email format validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid email format"
    );
  }

  try {
    // Query Firestore for user with matching email
    const db = admin.firestore();
    const usersRef = db.collection("users");
    const querySnapshot = await usersRef
      .where("email", "==", email)
      .limit(1)
      .get();

    // User not found
    if (querySnapshot.empty) {
      return {
        found: false,
      };
    }

    // User found - return non-sensitive data only
    const userDoc = querySnapshot.docs[0];
    const userData = userDoc.data();
    const foundUserId = userDoc.id;
    const currentUserId = context.auth.uid;

    // Check friendship status if users are different
    let isFriend = false;
    let hasPendingRequest = false;

    if (foundUserId !== currentUserId) {
      try {
        // Story 11.16: Use checkFriendship helper from social graph API
        // This enforces the architectural boundary - no direct friendship queries
        isFriend = await checkFriendship(currentUserId, foundUserId);

        // If not friends, check for pending requests
        if (!isFriend) {
          const friendshipsRef = db.collection("friendships");

          // Check for pending friendship requests only
          const pendingQuery = await friendshipsRef
            .where("status", "==", "pending")
            .get();

          for (const doc of pendingQuery.docs) {
            const data = doc.data();
            const involves =
              (data.initiatorId === currentUserId &&
                data.recipientId === foundUserId) ||
              (data.initiatorId === foundUserId &&
                data.recipientId === currentUserId);

            if (involves) {
              hasPendingRequest = true;
              break;
            }
          }
        }
      } catch (friendshipError) {
        // Log error but don't fail the main function
        console.error("Error checking friendship status:", friendshipError);
        // Continue without friendship status
      }
    }

    return {
      found: true,
      user: {
        uid: foundUserId,
        displayName: userData.displayName || null,
        email: userData.email,
        photoUrl: userData.photoUrl || null,
      },
      isFriend,
      hasPendingRequest,
    };
  } catch (error) {
    console.error("Error searching for user:", error);

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
      "An error occurred while searching for the user"
    );
  }
}

/**
 * Cloud Function to search for a user by email address.
 *
 * This function provides a secure way to look up users without exposing
 * the entire /users collection to client-side queries.
 */
export const searchUserByEmail = functions.https.onCall(searchUserByEmailHandler);

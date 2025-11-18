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

  const currentUserId = context.auth.uid;

  // Normalize email
  const email = data.email.toLowerCase().trim();

  if (!email) {
    functions.logger.warn("Empty email provided", {
      currentUserId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Email cannot be empty"
    );
  }

  // Basic email format validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    functions.logger.warn("Invalid email format", {
      currentUserId,
      emailLength: email.length,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid email format"
    );
  }

  functions.logger.info("Searching user by email", {
    currentUserId,
    emailDomain: email.split("@")[1],
  });

  try{
    // Query Firestore for user with matching email
    const db = admin.firestore();
    const usersRef = db.collection("users");
    const querySnapshot = await usersRef
      .where("email", "==", email)
      .limit(1)
      .get();

    // User not found
    if (querySnapshot.empty) {
      functions.logger.info("User not found by email", {
        currentUserId,
        emailDomain: email.split("@")[1],
      });
      return {
        found: false,
      };
    }

    // User found - return non-sensitive data only
    const userDoc = querySnapshot.docs[0];
    const userData = userDoc.data();
    const foundUserId = userDoc.id;

    functions.logger.debug("User found by email", {
      currentUserId,
      foundUserId,
    });

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
        functions.logger.error("Error checking friendship status", {
          currentUserId,
          foundUserId,
          error: friendshipError instanceof Error ? friendshipError.message : String(friendshipError),
        });
        // Continue without friendship status
      }
    }

    functions.logger.info("User search completed successfully", {
      currentUserId,
      foundUserId,
      isFriend,
      hasPendingRequest,
    });

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
    functions.logger.error("Error searching for user", {
      currentUserId,
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

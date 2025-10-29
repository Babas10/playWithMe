// Cloud Function for searching users by email securely
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

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

    return {
      found: true,
      user: {
        uid: userDoc.id,
        displayName: userData.displayName || null,
        email: userData.email,
        photoUrl: userData.photoUrl || null,
      },
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

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for getPublicUserProfile Cloud Function
 */
export interface GetPublicUserProfileRequest {
  userId: string;
}

/**
 * Public user profile data (non-sensitive fields only)
 */
export interface PublicUserProfile {
  uid: string;
  displayName: string | null;
  email: string;
  photoUrl: string | null;
  firstName: string | null;
  lastName: string | null;
}

/**
 * Response interface for getPublicUserProfile Cloud Function
 */
export interface GetPublicUserProfileResponse {
  user: PublicUserProfile | null;
}

/**
 * Handler function for getting public user profile (exported for testing)
 *
 * @param data - Request data containing user ID
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to GetPublicUserProfileResponse
 */
export async function getPublicUserProfileHandler(
  data: GetPublicUserProfileRequest,
  context: functions.https.CallableContext
): Promise<GetPublicUserProfileResponse> {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to fetch user profiles"
    );
  }

  const currentUserId = context.auth.uid;
  const {userId} = data;

  // Validate required parameters
  if (!userId || typeof userId !== "string") {
    functions.logger.warn("Missing or invalid userId", {
      currentUserId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "userId is required and must be a string"
    );
  }

  functions.logger.info("Fetching public user profile", {
    currentUserId,
    requestedUserId: userId,
  });

  const db = admin.firestore();

  try {
    const userDoc = await db.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      functions.logger.warn("User not found", {
        currentUserId,
        requestedUserId: userId,
      });
      return {user: null};
    }

    const userData = userDoc.data();

    if (!userData) {
      functions.logger.warn("User document has no data", {
        currentUserId,
        requestedUserId: userId,
      });
      return {user: null};
    }

    // Return only public/non-sensitive data
    const publicProfile: PublicUserProfile = {
      uid: userDoc.id,
      displayName: userData.displayName || null,
      email: userData.email || "",
      photoUrl: userData.photoUrl || null,
      firstName: userData.firstName || null,
      lastName: userData.lastName || null,
    };

    functions.logger.info("Public user profile fetched successfully", {
      currentUserId,
      requestedUserId: userId,
    });

    return {user: publicProfile};
  } catch (error) {
    functions.logger.error("Error fetching public user profile", {
      currentUserId,
      requestedUserId: userId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to fetch user profile"
    );
  }
}

/**
 * Cloud Function to securely fetch a public user profile by user ID.
 *
 * This function allows fetching public user data for any user,
 * which is needed for displaying partner profiles, user details, etc.
 *
 * Security:
 * - Requires authentication
 * - Returns only public/non-sensitive user data
 * - Uses Admin SDK to bypass security rules
 * - Does NOT return sensitive fields (privacy settings, tokens, etc.)
 *
 * Use cases:
 * - Partner detail page
 * - User profile viewing
 * - Friend profile display
 */
export const getPublicUserProfile = functions.https.onCall(
  getPublicUserProfileHandler
);

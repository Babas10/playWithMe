import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for checkPendingInvitation Cloud Function
 */
export interface CheckPendingInvitationRequest {
  targetUserId: string;
  groupId: string;
}

/**
 * Response interface for checkPendingInvitation Cloud Function
 */
export interface CheckPendingInvitationResponse {
  exists: boolean;
}

/**
 * Handler function for checking pending invitations (exported for testing)
 *
 * @param data - Request data containing targetUserId and groupId
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to CheckPendingInvitationResponse
 */
export async function checkPendingInvitationHandler(
  data: CheckPendingInvitationRequest,
  context: functions.https.CallableContext
): Promise<CheckPendingInvitationResponse> {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to check for pending invitations"
    );
  }

  const currentUserId = context.auth.uid;

  // Validate required parameters
  const {targetUserId, groupId} = data;

  if (!targetUserId || typeof targetUserId !== "string") {
    functions.logger.warn("Missing or invalid targetUserId", {
      currentUserId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "targetUserId is required and must be a string"
    );
  }

  if (!groupId || typeof groupId !== "string") {
    functions.logger.warn("Missing or invalid groupId", {
      currentUserId,
      targetUserId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "groupId is required and must be a string"
    );
  }

  functions.logger.info("Checking pending invitation", {
    currentUserId,
    targetUserId,
    groupId,
  });

  try {
    // Query Firestore using Admin SDK (bypasses security rules)
    const db = admin.firestore();
    const invitationsRef = db
      .collection("users")
      .doc(targetUserId)
      .collection("invitations");

    const snapshot = await invitationsRef
      .where("groupId", "==", groupId)
      .where("status", "==", "pending")
      .limit(1)
      .get();

    const exists = !snapshot.empty;

    functions.logger.info("Pending invitation check result", {
      currentUserId,
      targetUserId,
      groupId,
      exists,
    });

    // Return only whether invitation exists (no sensitive data)
    return {
      exists,
    };
  } catch (error) {
    functions.logger.error("Error checking pending invitation", {
      currentUserId,
      targetUserId,
      groupId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to check for pending invitation"
    );
  }
}

/**
 * Cloud Function to securely check if a user has a pending invitation to a group.
 *
 * This function provides a secure way to check for duplicate invitations without
 * exposing the invitations subcollection to client-side queries.
 *
 * Security:
 * - Requires authentication (any authenticated user can call)
 * - Uses Admin SDK to query Firestore (bypasses security rules)
 * - Returns only a boolean (no sensitive data exposed)
 */
export const checkPendingInvitation = functions.https.onCall(checkPendingInvitationHandler);

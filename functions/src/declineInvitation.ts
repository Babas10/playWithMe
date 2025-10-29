import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for declineInvitation Cloud Function
 */
export interface DeclineInvitationRequest {
  invitationId: string;
}

/**
 * Response interface for declineInvitation Cloud Function
 */
export interface DeclineInvitationResponse {
  success: boolean;
  message: string;
}

/**
 * Handler function for declining invitations (exported for testing)
 *
 * @param data - Request data containing invitationId
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to DeclineInvitationResponse
 */
export async function declineInvitationHandler(
  data: DeclineInvitationRequest,
  context: functions.https.CallableContext
): Promise<DeclineInvitationResponse> {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to decline invitations"
    );
  }

  const userId = context.auth.uid;
  const {invitationId} = data;

  // Validate required parameters
  if (!invitationId || typeof invitationId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "invitationId is required and must be a string"
    );
  }

  const db = admin.firestore();

  try {
    // Get the invitation
    const invitationRef = db
      .collection("users")
      .doc(userId)
      .collection("invitations")
      .doc(invitationId);

    const invitationDoc = await invitationRef.get();

    if (!invitationDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Invitation not found"
      );
    }

    const invitationData = invitationDoc.data();

    // Verify invitation is pending
    if (invitationData?.status !== "pending") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Invitation is not pending"
      );
    }

    // Verify invitation is for the authenticated user
    if (invitationData.invitedUserId !== userId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "This invitation is not for you"
      );
    }

    // Update invitation status
    await invitationRef.update({
      status: "declined",
      respondedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      message: `Declined invitation to ${invitationData.groupName}`,
    };
  } catch (error) {
    // Re-throw HttpsErrors as-is
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Log unexpected errors
    console.error("Error declining invitation:", error);

    // Throw generic error for unexpected failures
    throw new functions.https.HttpsError(
      "internal",
      "Failed to decline invitation"
    );
  }
}

/**
 * Cloud Function to securely decline a group invitation.
 *
 * This function handles:
 * 1. Verifying the invitation exists and is pending
 * 2. Updating the invitation status to 'declined'
 * 3. Setting the respondedAt timestamp
 *
 * Security:
 * - Requires authentication
 * - Uses Admin SDK to bypass security rules
 * - Validates invitation ownership
 */
export const declineInvitation = functions.https.onCall(declineInvitationHandler);

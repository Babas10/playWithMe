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
    functions.logger.warn("Missing or invalid invitationId", {
      userId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "invitationId is required and must be a string"
    );
  }

  functions.logger.info("Declining invitation", {
    userId,
    invitationId,
  });

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
      functions.logger.warn("Invitation not found", {
        userId,
        invitationId,
      });
      throw new functions.https.HttpsError(
        "not-found",
        "Invitation not found"
      );
    }

    const invitationData = invitationDoc.data();

    // Verify invitation is pending
    if (invitationData?.status !== "pending") {
      functions.logger.warn("Invitation is not pending", {
        userId,
        invitationId,
        currentStatus: invitationData?.status,
      });
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Invitation is not pending"
      );
    }

    // Verify invitation is for the authenticated user
    if (invitationData.invitedUserId !== userId) {
      functions.logger.warn("Invitation ownership mismatch", {
        userId,
        invitationId,
        invitedUserId: invitationData.invitedUserId,
      });
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

    functions.logger.info("Invitation declined successfully", {
      userId,
      invitationId,
      groupName: invitationData.groupName,
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
    functions.logger.error("Error declining invitation", {
      userId,
      invitationId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

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

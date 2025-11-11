import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {checkFriendship} from "./friendships";

/**
 * Request interface for acceptInvitation Cloud Function
 */
export interface AcceptInvitationRequest {
  invitationId: string;
}

/**
 * Response interface for acceptInvitation Cloud Function
 */
export interface AcceptInvitationResponse {
  success: boolean;
  groupId: string;
  message: string;
}

/**
 * Handler function for accepting invitations (exported for testing)
 *
 * @param data - Request data containing invitationId
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to AcceptInvitationResponse
 */
export async function acceptInvitationHandler(
  data: AcceptInvitationRequest,
  context: functions.https.CallableContext
): Promise<AcceptInvitationResponse> {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to accept invitations"
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

    // Story 11.4: Always validate friendship (no backward compatibility)
    const inviterId = invitationData.invitedBy;
    const areFriends = await checkFriendship(inviterId, userId);

    if (!areFriends) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You can only accept invitations from friends. Please add them as a friend first."
      );
    }

    const groupId = invitationData.groupId;
    const groupRef = db.collection("groups").doc(groupId);

    // Use a batch write for atomicity
    const batch = db.batch();

    // Update invitation status
    batch.update(invitationRef, {
      status: "accepted",
      respondedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Add user to group members
    batch.update(groupRef, {
      memberIds: admin.firestore.FieldValue.arrayUnion(userId),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastActivity: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Commit the batch
    await batch.commit();

    return {
      success: true,
      groupId: groupId,
      message: `Successfully joined ${invitationData.groupName}`,
    };
  } catch (error) {
    // Re-throw HttpsErrors as-is
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Log unexpected errors
    console.error("Error accepting invitation:", error);

    // Throw generic error for unexpected failures
    throw new functions.https.HttpsError(
      "internal",
      "Failed to accept invitation"
    );
  }
}

/**
 * Cloud Function to securely accept a group invitation.
 *
 * This function handles the atomic operation of:
 * 1. Verifying the invitation exists and is pending
 * 2. Validating friendship between inviter and invitee (Story 11.4)
 * 3. Adding the user to the group's memberIds
 * 4. Updating the invitation status to 'accepted'
 * 5. Updating group metadata (updatedAt, lastActivity)
 *
 * Security:
 * - Requires authentication
 * - Uses Admin SDK to bypass security rules
 * - Validates invitation ownership
 * - Validates friendship (Story 11.4 - mandatory for all invitations)
 * - Atomic batch operation for data consistency
 */
export const acceptInvitation = functions.https.onCall(acceptInvitationHandler);

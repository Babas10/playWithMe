import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for leaveGroup Cloud Function
 */
export interface LeaveGroupRequest {
  groupId: string;
}

/**
 * Response interface for leaveGroup Cloud Function
 */
export interface LeaveGroupResponse {
  success: boolean;
  message: string;
}

/**
 * Handler function for leaving a group (exported for testing)
 *
 * @param data - Request data containing groupId
 * @param context - Firebase Functions context with auth information
 * @returns Promise resolving to LeaveGroupResponse
 */
export async function leaveGroupHandler(
  data: LeaveGroupRequest,
  context: functions.https.CallableContext
): Promise<LeaveGroupResponse> {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to leave a group"
    );
  }

  const userId = context.auth.uid;
  const {groupId} = data;

  // Validate required parameters
  if (!groupId || typeof groupId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "groupId is required and must be a string"
    );
  }

  const db = admin.firestore();

  try {
    const groupRef = db.collection("groups").doc(groupId);
    const groupDoc = await groupRef.get();

    // Verify group exists
    if (!groupDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Group not found"
      );
    }

    const groupData = groupDoc.data();

    // Verify user is a member
    if (!groupData?.memberIds || !groupData.memberIds.includes(userId)) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "You are not a member of this group"
      );
    }

    // Check if user is an admin
    const isAdmin = groupData.adminIds && groupData.adminIds.includes(userId);

    // If user is the only admin, prevent leaving
    if (isAdmin && groupData.adminIds.length <= 1) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Cannot leave group as the last admin. Promote another member to admin first."
      );
    }

    // Use a batch write for atomicity
    const batch = db.batch();

    // Remove user from group members
    batch.update(groupRef, {
      memberIds: admin.firestore.FieldValue.arrayRemove(userId),
      // If user is admin, also remove from adminIds
      ...(isAdmin && {
        adminIds: admin.firestore.FieldValue.arrayRemove(userId),
      }),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastActivity: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Commit the batch
    await batch.commit();

    return {
      success: true,
      message: `Successfully left ${groupData.name}`,
    };
  } catch (error) {
    // Re-throw HttpsErrors as-is
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Log unexpected errors
    console.error("Error leaving group:", error);

    // Throw generic error for unexpected failures
    throw new functions.https.HttpsError(
      "internal",
      "Failed to leave group"
    );
  }
}

/**
 * Cloud Function to securely leave a group.
 *
 * This function handles the atomic operation of:
 * 1. Verifying the user is a member of the group
 * 2. Checking if user is the last admin (prevents leaving)
 * 3. Removing the user from the group's memberIds
 * 4. Removing the user from adminIds if they are an admin
 * 5. Updating group metadata (updatedAt, lastActivity)
 *
 * Security:
 * - Requires authentication
 * - Uses Admin SDK to bypass security rules
 * - Validates group membership
 * - Prevents last admin from leaving
 * - Atomic batch operation for data consistency
 */
export const leaveGroup = functions.https.onCall(leaveGroupHandler);

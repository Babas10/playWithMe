// Cloud Function for revoking group invite links
// Epic 17 — Story 17.3
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {
  RevokeGroupInviteRequest,
  RevokeGroupInviteResponse,
  InviteData,
  GroupData,
} from "./types";

// ============================================================================
// Cloud Function Handler
// ============================================================================

/**
 * Revoke an existing invite link so it can no longer be used.
 *
 * @param {RevokeGroupInviteRequest} data - The request data.
 * @param {functions.https.CallableContext} context - The callable context.
 * @return {Promise<RevokeGroupInviteResponse>} The revoke response.
 */
export async function revokeGroupInviteHandler(
  data: RevokeGroupInviteRequest,
  context: functions.https.CallableContext
): Promise<RevokeGroupInviteResponse> {
  // 1. Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to revoke an invite link."
    );
  }

  const uid = context.auth.uid;

  // 2. Validate input parameters
  if (!data || typeof data.groupId !== "string" || !data.groupId.trim()) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'groupId' is required and must be a non-empty string."
    );
  }

  if (typeof data.inviteId !== "string" || !data.inviteId.trim()) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'inviteId' is required and must be a non-empty string."
    );
  }

  const {groupId, inviteId} = data;

  functions.logger.info("[revokeGroupInvite] Revoking invite", {
    uid,
    groupId,
    inviteId,
  });

  try {
    const db = admin.firestore();

    // 3. Fetch invite document
    const inviteRef = db
      .collection("groups")
      .doc(groupId)
      .collection("invites")
      .doc(inviteId);
    const inviteDoc = await inviteRef.get();

    if (!inviteDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "The invite does not exist."
      );
    }

    const inviteData = inviteDoc.data() as InviteData;

    // 4. Check if already revoked
    if (inviteData.revoked) {
      throw new functions.https.HttpsError(
        "already-exists",
        "This invite is already revoked."
      );
    }

    // 5. Fetch group document to check permissions
    const groupDoc = await db.collection("groups").doc(groupId).get();
    if (!groupDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "The group does not exist."
      );
    }

    const groupData = groupDoc.data() as GroupData;

    // 6. Validate permission: admin, creator, or invite creator
    const isGroupAdmin =
      (groupData.adminIds || []).includes(uid) ||
      groupData.createdBy === uid;
    const isInviteCreator = inviteData.createdBy === uid;

    if (!isGroupAdmin && !isInviteCreator) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You do not have permission to revoke this invite."
      );
    }

    // 7. Batch write: revoke invite + deactivate token
    const tokenRef = db.collection("invite_tokens").doc(inviteData.token);
    const batch = db.batch();

    batch.update(inviteRef, {revoked: true});
    batch.update(tokenRef, {active: false});

    await batch.commit();

    functions.logger.info("[revokeGroupInvite] Invite revoked", {
      uid,
      groupId,
      inviteId,
      tokenPrefix: inviteData.token.substring(0, 8) + "...",
    });

    return {success: true};
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("[revokeGroupInvite] Error", {
      uid,
      groupId,
      inviteId,
      error: error instanceof Error ? error.message : String(error),
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to revoke invite link. Please try again later."
    );
  }
}

export const revokeGroupInvite = functions.https.onCall(
  revokeGroupInviteHandler
);

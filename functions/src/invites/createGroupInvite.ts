// Cloud Function for creating group invite links
// Epic 17 — Story 17.3
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import {
  CreateGroupInviteRequest,
  CreateGroupInviteResponse,
  GroupData,
} from "./types";

// ============================================================================
// Constants
// ============================================================================

const BASE_URL = "https://playwithme.app/invite";

// ============================================================================
// Cloud Function Handler
// ============================================================================

/**
 * Generate a new shareable invite link for a group.
 *
 * @param {CreateGroupInviteRequest} data - The request data.
 * @param {functions.https.CallableContext} context - The callable context.
 * @return {Promise<CreateGroupInviteResponse>} The invite response.
 */
export async function createGroupInviteHandler(
  data: CreateGroupInviteRequest,
  context: functions.https.CallableContext
): Promise<CreateGroupInviteResponse> {
  // 1. Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to create an invite link."
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

  if (
    data.expiresInHours !== undefined &&
    data.expiresInHours !== null &&
    (typeof data.expiresInHours !== "number" || data.expiresInHours <= 0)
  ) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'expiresInHours' must be a positive number."
    );
  }

  if (
    data.usageLimit !== undefined &&
    data.usageLimit !== null &&
    (typeof data.usageLimit !== "number" ||
      data.usageLimit <= 0 ||
      !Number.isInteger(data.usageLimit))
  ) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'usageLimit' must be a positive integer."
    );
  }

  const {groupId} = data;

  functions.logger.info("[createGroupInvite] Creating invite", {
    uid,
    groupId,
    expiresInHours: data.expiresInHours ?? "never",
    usageLimit: data.usageLimit ?? "unlimited",
  });

  try {
    const db = admin.firestore();

    // 3. Fetch group document
    const groupDoc = await db.collection("groups").doc(groupId).get();
    if (!groupDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "The group does not exist."
      );
    }

    const groupData = groupDoc.data() as GroupData;

    // 4. Validate user is a member
    if (!groupData.memberIds.includes(uid)) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You must be a member of the group to create an invite link."
      );
    }

    // 5. Validate invite permission
    const isAdmin =
      (groupData.adminIds || []).includes(uid) ||
      groupData.createdBy === uid;

    if (!groupData.allowMembersToInviteOthers && !isAdmin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You do not have permission to create invite links for this group."
      );
    }

    // 6. Validate group is not at capacity
    if (groupData.memberIds.length >= groupData.maxMembers) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "This group is at capacity and cannot accept new members."
      );
    }

    // 7. Generate secure random token (32 chars, URL-safe base64)
    const token = crypto.randomBytes(24).toString("base64url");

    // 8. Calculate expiresAt
    let expiresAt: Date | null = null;
    if (data.expiresInHours) {
      expiresAt = new Date(
        Date.now() + data.expiresInHours * 60 * 60 * 1000
      );
    }

    // 9. Atomic batch write: invite doc + token lookup
    const inviteRef = db
      .collection("groups")
      .doc(groupId)
      .collection("invites")
      .doc();
    const inviteId = inviteRef.id;
    const tokenRef = db.collection("invite_tokens").doc(token);

    const batch = db.batch();

    batch.set(inviteRef, {
      token,
      createdBy: uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: expiresAt ?
        admin.firestore.Timestamp.fromDate(expiresAt) :
        null,
      revoked: false,
      usageLimit: data.usageLimit ?? null,
      usageCount: 0,
      groupId,
      inviteType: "group_link",
    });

    batch.set(tokenRef, {
      groupId,
      inviteId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      active: true,
    });

    await batch.commit();

    // 10. Construct deep link URL
    const deepLinkUrl = `${BASE_URL}/${token}`;

    functions.logger.info("[createGroupInvite] Invite created", {
      uid,
      groupId,
      inviteId,
      tokenPrefix: token.substring(0, 8) + "...",
    });

    return {
      success: true,
      inviteId,
      token,
      deepLinkUrl,
      expiresAt: expiresAt ? expiresAt.toISOString() : null,
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("[createGroupInvite] Error", {
      uid,
      groupId,
      error: error instanceof Error ? error.message : String(error),
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to create invite link. Please try again later."
    );
  }
}

export const createGroupInvite = functions.https.onCall(
  createGroupInviteHandler
);

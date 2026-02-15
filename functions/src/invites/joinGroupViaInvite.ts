// Cloud Function for joining a group via invite token
// Epic 17 — Story 17.3, 17.9 (Idempotent Group Join Logic)
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {
  JoinGroupViaInviteRequest,
  JoinGroupViaInviteResponse,
  TokenLookupData,
  InviteData,
  GroupData,
} from "./types";

// ============================================================================
// Cloud Function Handler
// ============================================================================

/**
 * Join the authenticated user to the group associated with the invite token.
 * Uses a Firestore transaction for atomicity and race condition prevention.
 *
 * @param {JoinGroupViaInviteRequest} data - The request data.
 * @param {functions.https.CallableContext} context - The callable context.
 * @return {Promise<JoinGroupViaInviteResponse>} The join response.
 */
export async function joinGroupViaInviteHandler(
  data: JoinGroupViaInviteRequest,
  context: functions.https.CallableContext
): Promise<JoinGroupViaInviteResponse> {
  // 1. Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to join a group."
    );
  }

  const uid = context.auth.uid;

  // 2. Validate token input
  if (!data || typeof data.token !== "string" || !data.token.trim()) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'token' is required and must be a non-empty string."
    );
  }

  const {token} = data;

  functions.logger.info("[joinGroupViaInvite] Join attempt", {
    uid,
    tokenPrefix: token.substring(0, 8) + "...",
  });

  try {
    const db = admin.firestore();

    // Look up token first (outside transaction for the ref)
    const tokenRef = db.collection("invite_tokens").doc(token);
    const tokenDoc = await tokenRef.get();

    if (!tokenDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "This invite link does not exist."
      );
    }

    const tokenData = tokenDoc.data() as TokenLookupData;

    if (!tokenData.active) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "This invite link is no longer active."
      );
    }

    const inviteRef = db
      .collection("groups")
      .doc(tokenData.groupId)
      .collection("invites")
      .doc(tokenData.inviteId);
    const groupRef = db.collection("groups").doc(tokenData.groupId);

    let alreadyMember = false;
    let groupName = "";

    // 3. Run Firestore transaction
    await db.runTransaction(async (transaction) => {
      // Reads must come before writes in transactions
      const inviteDoc = await transaction.get(inviteRef);
      const groupDoc = await transaction.get(groupRef);

      // Validate invite exists
      if (!inviteDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "This invite link does not exist."
        );
      }

      const inviteData = inviteDoc.data() as InviteData;

      // Validate invite not revoked
      if (inviteData.revoked) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "This invite link has been revoked."
        );
      }

      // Validate invite not expired
      if (inviteData.expiresAt) {
        const expiresAtDate = inviteData.expiresAt.toDate();
        if (expiresAtDate <= new Date()) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "This invite link has expired."
          );
        }
      }

      // Validate group exists
      if (!groupDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "The group associated with this invite no longer exists."
        );
      }

      const groupData = groupDoc.data() as GroupData;
      groupName = groupData.name;

      // Idempotency check: if user is already a member, return immediately
      // without checking usage limit or capacity — re-joining is always a no-op
      if (groupData.memberIds.includes(uid)) {
        alreadyMember = true;
        return; // No writes needed
      }

      // Validate usage limit not reached (only for new joins)
      if (
        inviteData.usageLimit !== null &&
        inviteData.usageCount >= inviteData.usageLimit
      ) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "This invite link has reached its usage limit."
        );
      }

      // Check group capacity (only for new joins)
      if (groupData.memberIds.length >= groupData.maxMembers) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "This group is at capacity and cannot accept new members."
        );
      }

      // Transaction writes
      transaction.update(groupRef, {
        memberIds: admin.firestore.FieldValue.arrayUnion(uid),
        lastActivity: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.update(inviteRef, {
        usageCount: admin.firestore.FieldValue.increment(1),
      });
    });

    if (alreadyMember) {
      functions.logger.info("[joinGroupViaInvite] User already member", {
        uid,
        groupId: tokenData.groupId,
      });
    } else {
      functions.logger.info("[joinGroupViaInvite] User joined group", {
        uid,
        groupId: tokenData.groupId,
        inviteId: tokenData.inviteId,
      });
    }

    return {
      success: true,
      groupId: tokenData.groupId,
      groupName,
      alreadyMember,
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("[joinGroupViaInvite] Error", {
      uid,
      error: error instanceof Error ? error.message : String(error),
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to join group. Please try again later."
    );
  }
}

export const joinGroupViaInvite = functions.https.onCall(
  joinGroupViaInviteHandler
);

// Cloud Function for validating invite tokens
// Epic 17 — Story 17.3
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {
  ValidateInviteTokenRequest,
  ValidateInviteTokenResponse,
  TokenLookupData,
  InviteData,
  GroupData,
} from "./types";

// ============================================================================
// Cloud Function Handler
// ============================================================================

/**
 * Validate an invite token and return group information for the pre-join screen.
 *
 * @param {ValidateInviteTokenRequest} data - The request data.
 * @param {functions.https.CallableContext} context - The callable context.
 * @return {Promise<ValidateInviteTokenResponse>} The validation response.
 */
export async function validateInviteTokenHandler(
  data: ValidateInviteTokenRequest,
  context: functions.https.CallableContext
): Promise<ValidateInviteTokenResponse> {
  // 1. Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to validate an invite link."
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

  functions.logger.info("[validateInviteToken] Validating token", {
    uid,
    tokenPrefix: token.substring(0, 8) + "...",
  });

  try {
    const db = admin.firestore();

    // 3. Fetch token lookup document
    const tokenDoc = await db.collection("invite_tokens").doc(token).get();
    if (!tokenDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "This invite link does not exist."
      );
    }

    const tokenData = tokenDoc.data() as TokenLookupData;

    // 4. Check token is active
    if (!tokenData.active) {
      functions.logger.warn("[validateInviteToken] Token inactive", {
        uid,
        reason: "inactive",
      });
      throw new functions.https.HttpsError(
        "failed-precondition",
        "This invite link is no longer active."
      );
    }

    // 5. Fetch invite document
    const inviteDoc = await db
      .collection("groups")
      .doc(tokenData.groupId)
      .collection("invites")
      .doc(tokenData.inviteId)
      .get();

    if (!inviteDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "This invite link does not exist."
      );
    }

    const inviteData = inviteDoc.data() as InviteData;

    // 6. Validate invite is not revoked
    if (inviteData.revoked) {
      functions.logger.warn("[validateInviteToken] Token invalid", {
        uid,
        reason: "revoked",
      });
      throw new functions.https.HttpsError(
        "failed-precondition",
        "This invite link has been revoked."
      );
    }

    // 7. Validate invite is not expired
    if (inviteData.expiresAt) {
      const expiresAtDate = inviteData.expiresAt.toDate();
      if (expiresAtDate <= new Date()) {
        functions.logger.warn("[validateInviteToken] Token invalid", {
          uid,
          reason: "expired",
        });
        throw new functions.https.HttpsError(
          "failed-precondition",
          "This invite link has expired."
        );
      }
    }

    // 8. Validate usage limit not reached
    if (
      inviteData.usageLimit !== null &&
      inviteData.usageCount >= inviteData.usageLimit
    ) {
      functions.logger.warn("[validateInviteToken] Token invalid", {
        uid,
        reason: "usage_limit_reached",
      });
      throw new functions.https.HttpsError(
        "failed-precondition",
        "This invite link has reached its usage limit."
      );
    }

    // 9. Fetch group document
    const groupDoc = await db
      .collection("groups")
      .doc(tokenData.groupId)
      .get();

    if (!groupDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "The group associated with this invite no longer exists."
      );
    }

    const groupData = groupDoc.data() as GroupData;

    // 10. Fetch inviter profile
    const inviterDoc = await db
      .collection("users")
      .doc(inviteData.createdBy)
      .get();

    let inviterName = "Unknown";
    let inviterPhotoUrl: string | undefined;

    if (inviterDoc.exists) {
      const inviterData = inviterDoc.data()!;
      inviterName =
        inviterData.displayName || inviterData.email || "Unknown";
      inviterPhotoUrl = inviterData.photoUrl || undefined;
    }

    // 11. Calculate remaining uses
    const remainingUses =
      inviteData.usageLimit !== null ?
        inviteData.usageLimit - inviteData.usageCount :
        null;

    functions.logger.info("[validateInviteToken] Token valid", {
      uid,
      groupId: tokenData.groupId,
      inviteId: tokenData.inviteId,
    });

    const response: ValidateInviteTokenResponse = {
      valid: true,
      groupId: tokenData.groupId,
      groupName: groupData.name,
      groupMemberCount: groupData.memberIds.length,
      inviterName,
      expiresAt: inviteData.expiresAt ?
        inviteData.expiresAt.toDate().toISOString() :
        null,
      remainingUses,
    };

    if (groupData.description) {
      response.groupDescription = groupData.description;
    }
    if (groupData.photoUrl) {
      response.groupPhotoUrl = groupData.photoUrl;
    }
    if (inviterPhotoUrl) {
      response.inviterPhotoUrl = inviterPhotoUrl;
    }

    return response;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("[validateInviteToken] Error", {
      uid,
      error: error instanceof Error ? error.message : String(error),
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to validate invite link. Please try again later."
    );
  }
}

export const validateInviteToken = functions.https.onCall(
  validateInviteTokenHandler
);

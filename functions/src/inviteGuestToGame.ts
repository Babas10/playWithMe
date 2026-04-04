import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for inviteGuestToGame Cloud Function
 */
export interface InviteGuestToGameRequest {
  gameId: string;
  inviteeId: string;
}

/**
 * Response interface for inviteGuestToGame Cloud Function
 */
export interface InviteGuestToGameResponse {
  success: boolean;
  invitationId: string;
}

/**
 * Handler function for inviteGuestToGame (exported for unit testing).
 *
 * Lets a game creator invite a player from one of their other groups to join
 * the game as a guest. The invitee must share at least one group with the
 * caller (shared-group trust boundary).
 *
 * Logic:
 * 1. Validate auth + inputs
 * 2. Load game — verify caller is the creator
 * 3. Verify invitee not already in playerIds or guestPlayerIds
 * 4. Verify no pending invitation already exists for (gameId, inviteeId)
 * 5. Load all groups where caller is a member
 * 6. Verify invitee is a member of at least one of those groups
 * 7. Atomically create the gameInvitations document
 * 8. Return { success: true, invitationId }
 */
export async function inviteGuestToGameHandler(
  data: InviteGuestToGameRequest,
  context: functions.https.CallableContext
): Promise<InviteGuestToGameResponse> {
  // ── 1. Auth ──────────────────────────────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to invite guests to a game."
    );
  }

  const callerId = context.auth.uid;
  const { gameId, inviteeId } = data;

  functions.logger.info("[inviteGuestToGame] Start", { callerId, gameId, inviteeId });

  // ── 2. Input validation ──────────────────────────────────────────────────
  if (!gameId || typeof gameId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'gameId' is required and must be a string."
    );
  }
  if (!inviteeId || typeof inviteeId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'inviteeId' is required and must be a string."
    );
  }
  if (inviteeId === callerId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "You cannot invite yourself to a game."
    );
  }

  const db = admin.firestore();

  try {
    // ── 3. Load game — verify caller is creator ───────────────────────────
    const gameDoc = await db.collection("games").doc(gameId).get();

    if (!gameDoc.exists) {
      functions.logger.warn("[inviteGuestToGame] Game not found", { callerId, gameId });
      throw new functions.https.HttpsError("not-found", "Game not found.");
    }

    const game = gameDoc.data()!;

    if (game.createdBy !== callerId) {
      functions.logger.warn("[inviteGuestToGame] Caller is not game creator", {
        callerId,
        createdBy: game.createdBy,
        gameId,
      });
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only the game creator can invite guests."
      );
    }

    // ── 4. Invitee not already a player or guest ──────────────────────────
    const playerIds: string[] = game.playerIds ?? [];
    const guestPlayerIds: string[] = game.guestPlayerIds ?? [];

    if (playerIds.includes(inviteeId) || guestPlayerIds.includes(inviteeId)) {
      functions.logger.warn("[inviteGuestToGame] Invitee already in game", {
        callerId,
        gameId,
        inviteeId,
      });
      throw new functions.https.HttpsError(
        "already-exists",
        "This player is already participating in the game."
      );
    }

    // ── 5. No duplicate pending invitation ───────────────────────────────
    const existingInvitation = await db
      .collection("gameInvitations")
      .where("gameId", "==", gameId)
      .where("inviteeId", "==", inviteeId)
      .where("status", "==", "pending")
      .limit(1)
      .get();

    if (!existingInvitation.empty) {
      functions.logger.warn("[inviteGuestToGame] Pending invitation already exists", {
        callerId,
        gameId,
        inviteeId,
      });
      throw new functions.https.HttpsError(
        "already-exists",
        "A pending invitation already exists for this player and game."
      );
    }

    // ── 6. Shared-group trust boundary ────────────────────────────────────
    // Load all groups where the caller is a member, then check the invitee
    // is a member of at least one of those groups.
    const callerGroupsSnapshot = await db
      .collection("groups")
      .where("memberIds", "array-contains", callerId)
      .get();

    const sharedGroup = callerGroupsSnapshot.docs.find((doc) => {
      const members: string[] = doc.data().memberIds ?? [];
      return members.includes(inviteeId);
    });

    if (!sharedGroup) {
      functions.logger.warn("[inviteGuestToGame] No shared group found", {
        callerId,
        inviteeId,
        gameId,
      });
      throw new functions.https.HttpsError(
        "permission-denied",
        "You can only invite players who share at least one group with you."
      );
    }

    functions.logger.info("[inviteGuestToGame] Shared group found, creating invitation", {
      callerId,
      inviteeId,
      gameId,
      sharedGroupId: sharedGroup.id,
    });

    // ── 7. Atomically create the gameInvitations document ─────────────────
    const invitationRef = db.collection("gameInvitations").doc();

    await invitationRef.set({
      gameId,
      groupId: game.groupId,
      inviteeId,
      inviterId: callerId,
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: game.scheduledAt ?? null,
    });

    functions.logger.info("[inviteGuestToGame] Invitation created successfully", {
      callerId,
      inviteeId,
      gameId,
      invitationId: invitationRef.id,
    });

    // ── 8. Return ─────────────────────────────────────────────────────────
    return { success: true, invitationId: invitationRef.id };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("[inviteGuestToGame] Unexpected error", {
      callerId,
      gameId,
      inviteeId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    throw new functions.https.HttpsError(
      "internal",
      "Failed to send game invitation. Please try again."
    );
  }
}

/**
 * Callable Cloud Function — inviteGuestToGame (Story 28.2)
 *
 * Lets the game creator invite a player from one of their other groups to
 * join the game as a guest. Enforces:
 *  - Creator-only access
 *  - Shared-group trust boundary (no cold invites to strangers)
 *  - No duplicate active invitations
 *  - No re-invite of a player already in the game
 */
export const inviteGuestToGame = functions
  .region("europe-west6")
  .https.onCall(inviteGuestToGameHandler);

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for acceptGameGuestInvitation Cloud Function
 */
export interface AcceptGameGuestInvitationRequest {
  invitationId: string;
}

/**
 * Response interface for acceptGameGuestInvitation Cloud Function
 */
export interface AcceptGameGuestInvitationResponse {
  success: boolean;
}

/** Game statuses that prevent a guest from joining */
const INACTIVE_GAME_STATUSES = new Set(["completed", "cancelled"]);

/**
 * Handler for acceptGameGuestInvitation (exported for unit testing).
 *
 * Atomically:
 *  - Verifies the invitation is pending and belongs to the caller
 *  - Verifies the game is still active and not full
 *  - Adds inviteeId to game.playerIds (guest players are treated as regular players)
 *  - Sets invitation status to "accepted"
 *
 * Idempotent: calling again on an already-accepted invitation returns success.
 */
export async function acceptGameGuestInvitationHandler(
  data: AcceptGameGuestInvitationRequest,
  context: functions.https.CallableContext
): Promise<AcceptGameGuestInvitationResponse> {
  // ── 1. Auth ──────────────────────────────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to accept a game invitation."
    );
  }

  const callerId = context.auth.uid;
  const { invitationId } = data;

  functions.logger.info("[acceptGameGuestInvitation] Start", { callerId, invitationId });

  // ── 2. Input validation ──────────────────────────────────────────────────
  if (!invitationId || typeof invitationId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'invitationId' is required and must be a string."
    );
  }

  const db = admin.firestore();

  try {
    const invitationRef = db.collection("gameInvitations").doc(invitationId);

    // ── 3. Load invitation ─────────────────────────────────────────────────
    const invitationDoc = await invitationRef.get();

    if (!invitationDoc.exists) {
      functions.logger.warn("[acceptGameGuestInvitation] Invitation not found", {
        callerId,
        invitationId,
      });
      throw new functions.https.HttpsError("not-found", "Invitation not found.");
    }

    const invitation = invitationDoc.data()!;

    // Ownership check
    if (invitation.inviteeId !== callerId) {
      functions.logger.warn("[acceptGameGuestInvitation] Caller is not the invitee", {
        callerId,
        inviteeId: invitation.inviteeId,
        invitationId,
      });
      throw new functions.https.HttpsError(
        "permission-denied",
        "This invitation is not yours to accept."
      );
    }

    // Idempotency: already accepted → return success
    if (invitation.status === "accepted") {
      functions.logger.info("[acceptGameGuestInvitation] Already accepted — idempotent", {
        callerId,
        invitationId,
      });
      return { success: true };
    }

    // Must be pending
    if (invitation.status !== "pending") {
      functions.logger.warn("[acceptGameGuestInvitation] Invitation not pending", {
        callerId,
        invitationId,
        status: invitation.status,
      });
      throw new functions.https.HttpsError(
        "failed-precondition",
        `Invitation cannot be accepted (current status: ${invitation.status}).`
      );
    }

    // ── 4. Transaction: capacity check + atomic write ──────────────────────
    await db.runTransaction(async (tx) => {
      const gameRef = db.collection("games").doc(invitation.gameId);
      const [currentInvDoc, gameDoc] = await Promise.all([
        tx.get(invitationRef),
        tx.get(gameRef),
      ]);

      // Re-check invitation status inside transaction
      if (!currentInvDoc.exists || currentInvDoc.data()!.status !== "pending") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Invitation is no longer pending."
        );
      }

      if (!gameDoc.exists) {
        throw new functions.https.HttpsError("not-found", "The game no longer exists.");
      }

      const game = gameDoc.data()!;

      // Game must still be active
      if (INACTIVE_GAME_STATUSES.has(game.status)) {
        functions.logger.warn("[acceptGameGuestInvitation] Game is no longer active", {
          callerId,
          invitationId,
          gameId: invitation.gameId,
          gameStatus: game.status,
        });
        throw new functions.https.HttpsError(
          "failed-precondition",
          "The game is no longer accepting players."
        );
      }

      // Capacity check
      const playerIds: string[] = game.playerIds ?? [];
      const maxPlayers: number = game.maxPlayers ?? 4;

      if (playerIds.length >= maxPlayers) {
        functions.logger.warn("[acceptGameGuestInvitation] Game is full", {
          callerId,
          invitationId,
          gameId: invitation.gameId,
          currentCount: playerIds.length,
          maxPlayers,
        });
        throw new functions.https.HttpsError(
          "failed-precondition",
          "The game is already full."
        );
      }

      // Atomic writes — guest players join playerIds like any regular player
      tx.update(gameRef, {
        playerIds: admin.firestore.FieldValue.arrayUnion(callerId),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      tx.update(invitationRef, {
        status: "accepted",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    functions.logger.info("[acceptGameGuestInvitation] Accepted successfully", {
      callerId,
      invitationId,
      gameId: invitation.gameId,
    });

    return { success: true };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("[acceptGameGuestInvitation] Unexpected error", {
      callerId,
      invitationId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    throw new functions.https.HttpsError(
      "internal",
      "Failed to accept game invitation. Please try again."
    );
  }
}

/**
 * Callable Cloud Function — acceptGameGuestInvitation (Story 28.4)
 *
 * Lets the invited player accept a cross-group game invitation.
 * Atomically adds them to guestPlayerIds and marks the invitation accepted.
 * Re-checks capacity inside the transaction to prevent race conditions.
 */
export const acceptGameGuestInvitation = functions
  .region("europe-west6")
  .https.onCall(acceptGameGuestInvitationHandler);

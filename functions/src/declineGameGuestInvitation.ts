import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for declineGameGuestInvitation Cloud Function
 */
export interface DeclineGameGuestInvitationRequest {
  invitationId: string;
}

/**
 * Response interface for declineGameGuestInvitation Cloud Function
 */
export interface DeclineGameGuestInvitationResponse {
  success: boolean;
}

/**
 * Handler for declineGameGuestInvitation (exported for unit testing).
 *
 * Updates the invitation status to "declined".
 *
 * Idempotent: calling again on an already-declined invitation returns success.
 */
export async function declineGameGuestInvitationHandler(
  data: DeclineGameGuestInvitationRequest,
  context: functions.https.CallableContext
): Promise<DeclineGameGuestInvitationResponse> {
  // ── 1. Auth ──────────────────────────────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to decline a game invitation."
    );
  }

  const callerId = context.auth.uid;
  const { invitationId } = data;

  functions.logger.info("[declineGameGuestInvitation] Start", { callerId, invitationId });

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
      functions.logger.warn("[declineGameGuestInvitation] Invitation not found", {
        callerId,
        invitationId,
      });
      throw new functions.https.HttpsError("not-found", "Invitation not found.");
    }

    const invitation = invitationDoc.data()!;

    // Ownership check
    if (invitation.inviteeId !== callerId) {
      functions.logger.warn("[declineGameGuestInvitation] Caller is not the invitee", {
        callerId,
        inviteeId: invitation.inviteeId,
        invitationId,
      });
      throw new functions.https.HttpsError(
        "permission-denied",
        "This invitation is not yours to decline."
      );
    }

    // Idempotency: already declined → return success
    if (invitation.status === "declined") {
      functions.logger.info("[declineGameGuestInvitation] Already declined — idempotent", {
        callerId,
        invitationId,
      });
      return { success: true };
    }

    // Must be pending
    if (invitation.status !== "pending") {
      functions.logger.warn("[declineGameGuestInvitation] Invitation not pending", {
        callerId,
        invitationId,
        status: invitation.status,
      });
      throw new functions.https.HttpsError(
        "failed-precondition",
        `Invitation cannot be declined (current status: ${invitation.status}).`
      );
    }

    // ── 4. Update invitation status ────────────────────────────────────────
    await invitationRef.update({
      status: "declined",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info("[declineGameGuestInvitation] Declined successfully", {
      callerId,
      invitationId,
    });

    return { success: true };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("[declineGameGuestInvitation] Unexpected error", {
      callerId,
      invitationId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    throw new functions.https.HttpsError(
      "internal",
      "Failed to decline game invitation. Please try again."
    );
  }
}

/**
 * Callable Cloud Function — declineGameGuestInvitation (Story 28.4)
 *
 * Lets the invited player decline a cross-group game invitation.
 * Only updates the invitation status — does not touch the game document.
 */
export const declineGameGuestInvitation = functions
  .region("europe-west6")
  .https.onCall(declineGameGuestInvitationHandler);

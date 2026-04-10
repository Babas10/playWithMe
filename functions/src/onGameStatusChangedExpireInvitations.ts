import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/** Terminal game statuses that should expire all pending invitations */
const TERMINAL_STATUSES = new Set(["completed", "cancelled", "aborted"]);

/** Maximum documents per Firestore batch write */
const BATCH_SIZE = 500;

/**
 * Handler for onGameStatusChangedExpireInvitations (exported for unit testing).
 *
 * Expires all pending gameInvitations for a game when it reaches a terminal
 * status (completed / cancelled / aborted).
 *
 * Idempotent: only pending invitations are queried, so a second run produces
 * zero writes.
 */
export async function onGameStatusChangedExpireInvitationsHandler(
  change: functions.Change<functions.firestore.DocumentSnapshot>,
  context: functions.EventContext
): Promise<null> {
  const before = change.before.data();
  const after = change.after.data();
  const gameId = context.params.gameId;

  // ── 1. Guard: only act when status changes to a terminal value ────────────
  if (!before || !after) return null;

  const previousStatus: string = before.status ?? "";
  const newStatus: string = after.status ?? "";

  if (previousStatus === newStatus) return null;
  if (!TERMINAL_STATUSES.has(newStatus)) return null;

  functions.logger.info(
    "[onGameStatusChangedExpireInvitations] Game reached terminal status — expiring pending invitations",
    { gameId, previousStatus, newStatus }
  );

  const db = admin.firestore();

  // ── 2. Query all pending invitations for this game ────────────────────────
  const pendingSnapshot = await db
    .collection("gameInvitations")
    .where("gameId", "==", gameId)
    .where("status", "==", "pending")
    .get();

  if (pendingSnapshot.empty) {
    functions.logger.info(
      "[onGameStatusChangedExpireInvitations] No pending invitations to expire",
      { gameId }
    );
    return null;
  }

  const expiredAt = admin.firestore.FieldValue.serverTimestamp();
  const totalDocs = pendingSnapshot.docs.length;

  // ── 3. Expire invitations atomically in chunks ────────────────────────────
  // Use a transaction per chunk so we re-read each invitation before writing.
  // This closes a race with acceptGameGuestInvitation: without the re-read, an
  // invitation accepted between our query (step 2) and this write would have
  // its status silently overwritten from "accepted" back to "expired".
  let expiredCount = 0;

  for (let i = 0; i < pendingSnapshot.docs.length; i += BATCH_SIZE) {
    const chunk = pendingSnapshot.docs.slice(i, i + BATCH_SIZE);

    await db.runTransaction(async (t) => {
      const freshDocs = await Promise.all(chunk.map((doc) => t.get(doc.ref)));

      for (const freshDoc of freshDocs) {
        // Skip any invitation no longer pending (e.g. accepted between the
        // outer query and this transaction read).
        if (!freshDoc.exists || freshDoc.data()?.status !== "pending") continue;

        t.update(freshDoc.ref, {
          status: "expired",
          updatedAt: expiredAt,
        });
        expiredCount++;
      }
    });
  }

  // ── 4. Clear pendingInviteeIds on the game document ──────────────────────
  // The game is in a terminal state — unconditionally set to [] rather than
  // computing which IDs to remove, so this is a single idempotent write.
  await db.collection("games").doc(gameId).update({
    pendingInviteeIds: [],
    updatedAt: expiredAt,
  });

  functions.logger.info(
    "[onGameStatusChangedExpireInvitations] Done",
    { gameId, expiredCount, totalDocs }
  );

  return null;
}

/**
 * Firestore trigger — onGameStatusChangedExpireInvitations (Story 28.5)
 *
 * Fires on every update to a games/{gameId} document.
 * When the status changes to "completed", "cancelled", or "aborted",
 * all pending gameInvitations for that game are batch-updated to "expired".
 *
 * Idempotent: already-expired invitations are excluded by the query filter.
 * Handles > 500 invitations via chunked batch writes.
 */
export const onGameStatusChangedExpireInvitations = functions
  .region("europe-west6")
  .firestore.document("games/{gameId}")
  .onUpdate(onGameStatusChangedExpireInvitationsHandler);

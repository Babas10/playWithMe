// Deletes all chat messages from games/{gameId}/messages when a game transitions to completed.
// Story 14.16: In-game chat message cleanup on game completion.
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const BATCH_SIZE = 500;

/**
 * Exported handler for unit-testability (decoupled from the trigger registration).
 */
export async function onGameCompletedDeleteChatMessagesHandler(
  change: functions.Change<functions.firestore.DocumentSnapshot>,
  context: functions.EventContext
): Promise<null> {
  const before = change.before.data();
  const after = change.after.data();
  const gameId = context.params.gameId;

  // Guard: only act when status transitions TO completed
  if (!before || !after) return null;
  if (before.status === "completed" || after.status !== "completed") return null;

  functions.logger.info(`[deleteChatMessages] Game ${gameId} completed — deleting chat messages`);

  const db = admin.firestore();
  const messagesRef = db.collection("games").doc(gameId).collection("messages");

  let totalDeleted = 0;

  // Delete in batches of 500 (Firestore batch limit)
  while (true) {
    const snapshot = await messagesRef.limit(BATCH_SIZE).get();

    if (snapshot.empty) break;

    const batch = db.batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    totalDeleted += snapshot.docs.length;

    // If we got fewer than BATCH_SIZE docs, we're done
    if (snapshot.docs.length < BATCH_SIZE) break;
  }

  functions.logger.info(
    `[deleteChatMessages] Deleted ${totalDeleted} chat messages for game ${gameId}`
  );

  return null;
}

/**
 * Firestore trigger: fires on any update to a game document.
 * Only acts when status transitions to "completed".
 */
export const onGameCompletedDeleteChatMessages = functions
  .region("europe-west6")
  .firestore.document("games/{gameId}")
  .onUpdate(onGameCompletedDeleteChatMessagesHandler);

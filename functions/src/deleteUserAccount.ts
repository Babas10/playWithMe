import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Callable Cloud Function: deleteUserAccount
 *
 * Permanently deletes a user's account and all associated data.
 * Triggered by the authenticated user themselves (user-initiated deletion).
 *
 * Cascade order:
 * 1. Remove user from all groups (memberIds array)
 * 2. Delete all friendship documents (sent and received)
 * 3. Delete the Firestore user document
 * 4. Delete the Firebase Auth user (last — triggers deleteUserDocument Auth trigger)
 *
 * Story 27.1 — Apple Guideline 5.1.1(v) compliance
 */
export const deleteUserAccount = functions
  .region("europe-west6")
  .https.onCall(async (_data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to delete your account."
      );
    }

    const uid = context.auth.uid;
    const db = admin.firestore();

    functions.logger.info(`[deleteUserAccount] Starting account deletion for uid=${uid}`);

    // 1. Remove user from all groups
    const groupsSnap = await db
      .collection("groups")
      .where("memberIds", "array-contains", uid)
      .get();

    if (!groupsSnap.empty) {
      const groupBatch = db.batch();
      groupsSnap.docs.forEach((doc) => {
        groupBatch.update(doc.ref, {
          memberIds: admin.firestore.FieldValue.arrayRemove(uid),
        });
      });
      await groupBatch.commit();
      functions.logger.info(
        `[deleteUserAccount] Removed user from ${groupsSnap.size} group(s)`
      );
    }

    // 2. Delete all friendship documents
    const [sentSnap, receivedSnap] = await Promise.all([
      db.collection("friendships").where("requesterId", "==", uid).get(),
      db.collection("friendships").where("receiverId", "==", uid).get(),
    ]);

    const allFriendshipDocs = [...sentSnap.docs, ...receivedSnap.docs];
    if (allFriendshipDocs.length > 0) {
      const friendBatch = db.batch();
      allFriendshipDocs.forEach((doc) => friendBatch.delete(doc.ref));
      await friendBatch.commit();
      functions.logger.info(
        `[deleteUserAccount] Deleted ${allFriendshipDocs.length} friendship document(s)`
      );
    }

    // 3. Delete Firestore user document
    await db.collection("users").doc(uid).delete();
    functions.logger.info(`[deleteUserAccount] Deleted Firestore user document`);

    // 4. Delete Firebase Auth user (this is the point of no return)
    await admin.auth().deleteUser(uid);
    functions.logger.info(`[deleteUserAccount] Firebase Auth user deleted — account fully removed`);

    return { success: true };
  });

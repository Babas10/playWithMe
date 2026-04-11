import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Callable Cloud Function: deleteUserAccount
 *
 * Permanently deletes a user's account and all associated data.
 * Triggered by the authenticated user themselves (user-initiated deletion).
 *
 * Cascade order:
 * 1. Load all groups the user belongs to
 * 2. Handle admin orphaning: promote another member or delete empty groups
 * 3. Delete group invite links created by the user (+ invite_tokens lookup docs)
 * 4. Remove user from all groups (memberIds + adminIds)
 * 5. Delete all game invitations sent or received by the user
 * 6. Delete all friendship documents (sent and received)
 * 7. Delete avatar from Cloud Storage (non-fatal if missing)
 * 8. Delete the Firestore user document
 * 9. Delete the Firebase Auth user (point of no return)
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

    functions.logger.info(
      `[deleteUserAccount] Starting account deletion for uid=${uid}`
    );

    // ── 1. Load all groups where user is a member ──────────────────────────
    const groupsSnap = await db
      .collection("groups")
      .where("memberIds", "array-contains", uid)
      .get();

    // ── 2. Handle admin orphaning ──────────────────────────────────────────
    // For each group where the user is the sole admin:
    //   • If other members exist → promote the first non-admin member to admin
    //   • If no other members remain → delete the group entirely
    const groupsToDelete: FirebaseFirestore.DocumentReference[] = [];
    const promotionBatch = db.batch();
    let promotionBatchHasOps = false;

    for (const groupDoc of groupsSnap.docs) {
      const data = groupDoc.data();
      const adminIds: string[] = data.adminIds ?? [];
      const memberIds: string[] = data.memberIds ?? [];
      const createdBy: string = data.createdBy;

      const isOnlyAdmin =
        adminIds.includes(uid) &&
        adminIds.filter((id) => id !== uid).length === 0;
      const isCreator = createdBy === uid;

      if (!isOnlyAdmin && !isCreator) continue;

      const otherMembers = memberIds.filter((id) => id !== uid);

      if (otherMembers.length === 0) {
        // Nobody left — schedule group for deletion
        groupsToDelete.push(groupDoc.ref);
        functions.logger.info(
          `[deleteUserAccount] Group ${groupDoc.id} will be deleted (no remaining members)`
        );
      } else {
        // Promote first available member
        const newAdmin = otherMembers[0];
        promotionBatch.update(groupDoc.ref, {
          adminIds: admin.firestore.FieldValue.arrayUnion(newAdmin),
          ...(isCreator ? { createdBy: newAdmin } : {}),
        });
        promotionBatchHasOps = true;
        functions.logger.info(
          `[deleteUserAccount] Promoting uid=${newAdmin} to admin in group ${groupDoc.id}`
        );
      }
    }

    if (promotionBatchHasOps) {
      await promotionBatch.commit();
    }

    for (const groupRef of groupsToDelete) {
      await groupRef.delete();
      functions.logger.info(
        `[deleteUserAccount] Deleted empty group ${groupRef.id}`
      );
    }

    // ── 3. Delete group invite links created by this user ─────────────────
    // Query each group's invites subcollection directly rather than using
    // collectionGroup, which requires a COLLECTION_GROUP-scoped index.
    // This is safe since invite links can only be created within groups the
    // user belongs to.
    const allInviteDocs: FirebaseFirestore.QueryDocumentSnapshot[] = [];
    for (const groupDoc of groupsSnap.docs) {
      const invitesSnap = await db
        .collection("groups")
        .doc(groupDoc.id)
        .collection("invites")
        .where("createdBy", "==", uid)
        .get();
      allInviteDocs.push(...invitesSnap.docs);
    }

    if (allInviteDocs.length > 0) {
      const inviteBatch = db.batch();
      for (const inviteDoc of allInviteDocs) {
        const token: string | undefined = inviteDoc.data().token;
        inviteBatch.delete(inviteDoc.ref);
        if (token) {
          inviteBatch.delete(db.collection("invite_tokens").doc(token));
        }
      }
      await inviteBatch.commit();
      functions.logger.info(
        `[deleteUserAccount] Deleted ${allInviteDocs.length} group invite link(s)`
      );
    }

    // ── 4. Remove user from all groups (memberIds + adminIds) ──────────────
    const survivingGroups = groupsSnap.docs.filter(
      (doc) => !groupsToDelete.some((ref) => ref.id === doc.id)
    );

    if (survivingGroups.length > 0) {
      const groupBatch = db.batch();
      survivingGroups.forEach((doc) => {
        groupBatch.update(doc.ref, {
          memberIds: admin.firestore.FieldValue.arrayRemove(uid),
          adminIds: admin.firestore.FieldValue.arrayRemove(uid),
        });
      });
      await groupBatch.commit();
      functions.logger.info(
        `[deleteUserAccount] Removed user from ${survivingGroups.length} group(s)`
      );
    }

    // ── 5. Delete game invitations ─────────────────────────────────────────
    // Delete invitations where the user is the inviter or the invitee.
    // When the user is the invitee, also remove them from pendingInviteeIds
    // on the game document so the game stays consistent.
    const [sentGameInvites, receivedGameInvites] = await Promise.all([
      db.collection("gameInvitations").where("inviterId", "==", uid).get(),
      db.collection("gameInvitations").where("inviteeId", "==", uid).get(),
    ]);

    const allGameInvites = [
      ...sentGameInvites.docs,
      ...receivedGameInvites.docs,
    ];

    if (allGameInvites.length > 0) {
      const gameInviteBatch = db.batch();
      const gameIdsToClean = new Set<string>();

      allGameInvites.forEach((doc) => {
        gameInviteBatch.delete(doc.ref);
        // Track games where the deleted user was a pending invitee
        if (doc.data().inviteeId === uid) {
          const gameId: string = doc.data().gameId;
          if (gameId) gameIdsToClean.add(gameId);
        }
      });

      // Remove uid from pendingInviteeIds on affected game documents
      gameIdsToClean.forEach((gameId) => {
        gameInviteBatch.update(db.collection("games").doc(gameId), {
          pendingInviteeIds: admin.firestore.FieldValue.arrayRemove(uid),
        });
      });

      await gameInviteBatch.commit();
      functions.logger.info(
        `[deleteUserAccount] Deleted ${allGameInvites.length} game invitation(s), ` +
          `cleaned pendingInviteeIds on ${gameIdsToClean.size} game(s)`
      );
    }

    // ── 6. Delete all friendship documents ────────────────────────────────
    const [sentFriendships, receivedFriendships] = await Promise.all([
      db.collection("friendships").where("initiatorId", "==", uid).get(),
      db.collection("friendships").where("recipientId", "==", uid).get(),
    ]);

    const allFriendshipDocs = [...sentFriendships.docs, ...receivedFriendships.docs];
    if (allFriendshipDocs.length > 0) {
      const friendBatch = db.batch();
      allFriendshipDocs.forEach((doc) => friendBatch.delete(doc.ref));
      await friendBatch.commit();
      functions.logger.info(
        `[deleteUserAccount] Deleted ${allFriendshipDocs.length} friendship document(s)`
      );
    }

    // ── 7. Delete avatar from Cloud Storage ───────────────────────────────
    // Storage path: avatars/{uid}/
    // Non-fatal: a missing avatar must not block account deletion.
    try {
      const bucket = admin.storage().bucket();
      await bucket.deleteFiles({ prefix: `avatars/${uid}/` });
      functions.logger.info(
        `[deleteUserAccount] Deleted avatar files from Storage`
      );
    } catch (storageError) {
      functions.logger.warn(
        `[deleteUserAccount] Could not delete avatar files (non-fatal)`,
        { storageError }
      );
    }

    // ── 8. Delete Firestore user document ─────────────────────────────────
    await db.collection("users").doc(uid).delete();
    functions.logger.info(
      `[deleteUserAccount] Deleted Firestore user document`
    );

    // ── 9. Delete Firebase Auth user (point of no return) ─────────────────
    await admin.auth().deleteUser(uid);
    functions.logger.info(
      `[deleteUserAccount] Firebase Auth user deleted — account fully removed`
    );

    return { success: true };
  });

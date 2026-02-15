// Scheduled function to delete unverified accounts past the 30-day deadline.
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const BATCH_SIZE = 500;

/**
 * Whether the function runs in dry-run mode (logs only, no deletions).
 * Set to false after validating dry-run output on each environment.
 */
const DRY_RUN = true;

/**
 * Scheduled Cloud Function: cleanupUnverifiedAccounts
 *
 * Runs daily at 3:00 AM UTC (1 hour after updateAccountStatuses).
 * Queries users where:
 *   - accountStatus == 'scheduledForDeletion'
 *   - deletionScheduledAt < now
 *
 * For each user:
 *   1. Remove from all groups (memberIds, adminIds)
 *   2. Cancel pending invitations
 *   3. Delete user document from Firestore
 *   4. Delete Firebase Auth account (Admin SDK)
 *   5. Log deletion for audit
 *
 * Safety:
 *   - Dry-run mode for initial deployment (logs only, no deletions)
 *   - Batch processing (max 500 per run)
 *   - Structured logging for every operation
 *
 * Story 17.8.4: Scheduled Cloud Functions for Account Cleanup (#481)
 */
export const cleanupUnverifiedAccounts = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    functions.logger.info(
      "[cleanupUnverifiedAccounts] Starting scheduled run",
      {
        timestamp: now.toDate().toISOString(),
        dryRun: DRY_RUN,
      }
    );

    try {
      const snapshot = await db.collection("users")
        .where("accountStatus", "==", "scheduledForDeletion")
        .where("deletionScheduledAt", "<", now)
        .limit(BATCH_SIZE)
        .get();

      if (snapshot.empty) {
        functions.logger.info(
          "[cleanupUnverifiedAccounts] No accounts to delete"
        );
        return null;
      }

      functions.logger.info(
        "[cleanupUnverifiedAccounts] Found accounts to delete",
        {count: snapshot.size, dryRun: DRY_RUN}
      );

      let deletedCount = 0;
      let errorCount = 0;

      for (const doc of snapshot.docs) {
        const uid = doc.id;
        let email = "unknown";

        try {
          const userData = doc.data();
          email = userData.email || "unknown";

          functions.logger.info(
            "[cleanupUnverifiedAccounts] Processing account",
            {
              uid,
              email,
              accountStatus: userData.accountStatus,
              createdAt:
                userData.createdAt?.toDate?.()?.toISOString(),
              deletionScheduledAt:
                userData.deletionScheduledAt?.toDate?.()
                  ?.toISOString(),
              dryRun: DRY_RUN,
            }
          );

          if (DRY_RUN) {
            functions.logger.info(
              "[cleanupUnverifiedAccounts] [DRY-RUN] " +
              "Would delete account",
              {uid, email}
            );
            deletedCount++;
            continue;
          }

          await deleteUserAccount(db, uid);
          deletedCount++;

          functions.logger.info(
            "[cleanupUnverifiedAccounts] " +
            "Successfully deleted account",
            {uid, email}
          );
        } catch (userError: unknown) {
          errorCount++;
          const errorMsg = userError instanceof Error ?
            userError.message : String(userError);
          functions.logger.error(
            "[cleanupUnverifiedAccounts] " +
            "Failed to delete account",
            {
              uid,
              email,
              error: errorMsg,
            }
          );
          // Continue processing other accounts
        }
      }

      functions.logger.info(
        "[cleanupUnverifiedAccounts] Completed",
        {
          processed: snapshot.size,
          deleted: deletedCount,
          errors: errorCount,
          dryRun: DRY_RUN,
        }
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ?
        error.message : String(error);
      functions.logger.error(
        "[cleanupUnverifiedAccounts] Error during execution",
        {
          error: errorMessage,
          stack: error instanceof Error ? error.stack : undefined,
        }
      );
      throw error;
    }

    return null;
  });

/**
 * Deletes a user account and all associated data.
 *
 * Steps:
 * 1. Remove from all groups (memberIds, adminIds)
 * 2. Cancel pending invitations
 * 3. Update friendships to 'declined'
 * 4. Delete user document
 * 5. Delete Firebase Auth account
 *
 * @param {admin.firestore.Firestore} db - Firestore instance
 * @param {string} uid - User ID to delete
 */
async function deleteUserAccount(
  db: admin.firestore.Firestore,
  uid: string
): Promise<void> {
  const batch = db.batch();

  // 1. Remove from group memberships (memberIds)
  const memberGroups = await db.collection("groups")
    .where("memberIds", "array-contains", uid)
    .get();

  for (const groupDoc of memberGroups.docs) {
    batch.update(groupDoc.ref, {
      memberIds: admin.firestore.FieldValue.arrayRemove(uid),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // 2. Remove from group admin roles (adminIds)
  const adminGroups = await db.collection("groups")
    .where("adminIds", "array-contains", uid)
    .get();

  for (const groupDoc of adminGroups.docs) {
    batch.update(groupDoc.ref, {
      adminIds: admin.firestore.FieldValue.arrayRemove(uid),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  functions.logger.info(
    "[cleanupUnverifiedAccounts] Removing from groups",
    {
      uid,
      memberGroups: memberGroups.size,
      adminGroups: adminGroups.size,
    }
  );

  // 3. Cancel pending invitations (sent by or to the user)
  const sentInvitations = await db.collection("invitations")
    .where("invitedBy", "==", uid)
    .where("status", "==", "pending")
    .get();

  const receivedInvitations = await db.collection("invitations")
    .where("invitedUserId", "==", uid)
    .where("status", "==", "pending")
    .get();

  for (const invDoc of sentInvitations.docs) {
    batch.delete(invDoc.ref);
  }
  for (const invDoc of receivedInvitations.docs) {
    batch.delete(invDoc.ref);
  }

  functions.logger.info(
    "[cleanupUnverifiedAccounts] Cancelling invitations",
    {
      uid,
      sent: sentInvitations.size,
      received: receivedInvitations.size,
    }
  );

  // 4. Update friendships to 'declined' (audit trail)
  const friendshipsAsInitiator = await db.collection("friendships")
    .where("initiatorId", "==", uid)
    .get();

  const friendshipsAsRecipient = await db.collection("friendships")
    .where("recipientId", "==", uid)
    .get();

  for (const doc of friendshipsAsInitiator.docs) {
    batch.update(doc.ref, {
      status: "declined",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  for (const doc of friendshipsAsRecipient.docs) {
    batch.update(doc.ref, {
      status: "declined",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  functions.logger.info(
    "[cleanupUnverifiedAccounts] Updating friendships",
    {
      uid,
      friendships:
        friendshipsAsInitiator.size + friendshipsAsRecipient.size,
    }
  );

  // 5. Delete user document
  const userRef = db.collection("users").doc(uid);
  batch.delete(userRef);

  // Commit all Firestore changes
  await batch.commit();

  // 6. Delete Firebase Auth account
  try {
    await admin.auth().deleteUser(uid);
    functions.logger.info(
      "[cleanupUnverifiedAccounts] Deleted Auth account",
      {uid}
    );
  } catch (authError: unknown) {
    const errorMsg = authError instanceof Error ?
      authError.message : String(authError);
    // Log but don't throw — Firestore cleanup succeeded
    functions.logger.warn(
      "[cleanupUnverifiedAccounts] " +
      "Failed to delete Auth account (may not exist)",
      {uid, error: errorMsg}
    );
  }
}

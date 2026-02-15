// Scheduled function to transition unverified accounts from pendingVerification
// to restricted after grace period expiration (7 days).
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const BATCH_SIZE = 500;

/**
 * Scheduled Cloud Function: updateAccountStatuses
 *
 * Runs daily at 2:00 AM UTC.
 * Queries users where:
 *   - emailVerifiedAt == null
 *   - gracePeriodExpiresAt < now
 *   - accountStatus == 'pendingVerification'
 *
 * Updates:
 *   - accountStatus -> 'restricted'
 *   - deletionScheduledAt -> 30 days from account creation (createdAt)
 *
 * Story 17.8.4: Scheduled Cloud Functions for Account Cleanup (#481)
 */
export const updateAccountStatuses = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    functions.logger.info(
      "[updateAccountStatuses] Starting scheduled run",
      {timestamp: now.toDate().toISOString()}
    );

    try {
      const snapshot = await db.collection("users")
        .where("accountStatus", "==", "pendingVerification")
        .where("emailVerifiedAt", "==", null)
        .where("gracePeriodExpiresAt", "<", now)
        .limit(BATCH_SIZE)
        .get();

      if (snapshot.empty) {
        functions.logger.info(
          "[updateAccountStatuses] No accounts to transition"
        );
        return null;
      }

      functions.logger.info(
        "[updateAccountStatuses] Found accounts to transition",
        {count: snapshot.size}
      );

      const batch = db.batch();
      const transitionedUserIds: string[] = [];

      for (const doc of snapshot.docs) {
        const data = doc.data();
        const createdAt = data.createdAt as admin.firestore.Timestamp;

        // Compute deletionScheduledAt: 30 days from account creation
        const deletionDate = new Date(
          createdAt.toDate().getTime() + 30 * 24 * 60 * 60 * 1000
        );

        batch.update(doc.ref, {
          accountStatus: "restricted",
          deletionScheduledAt:
            admin.firestore.Timestamp.fromDate(deletionDate),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        transitionedUserIds.push(doc.id);

        functions.logger.info(
          "[updateAccountStatuses] Transitioning account",
          {
            uid: doc.id,
            previousStatus: "pendingVerification",
            newStatus: "restricted",
            createdAt: createdAt.toDate().toISOString(),
            deletionScheduledAt: deletionDate.toISOString(),
          }
        );
      }

      await batch.commit();

      functions.logger.info(
        "[updateAccountStatuses] Completed successfully",
        {
          transitioned: transitionedUserIds.length,
          userIds: transitionedUserIds,
        }
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ?
        error.message : String(error);
      functions.logger.error(
        "[updateAccountStatuses] Error during execution",
        {
          error: errorMessage,
          stack: error instanceof Error ? error.stack : undefined,
        }
      );
      throw error;
    }

    return null;
  });

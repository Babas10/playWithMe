// Scheduled function to transition unverified accounts from pendingVerification
// to restricted after grace period expiration (7 days).
// Also acts as a safety net: if Firebase Auth shows emailVerified=true but
// Firestore was never synced, marks the account active instead of restricting.
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
 * For each matching user:
 *   - Checks Firebase Auth to detect the isEmailVerified sync gap.
 *   - If Auth shows emailVerified=true  → syncs Firestore to active.
 *   - If Auth shows emailVerified=false → restricts account and schedules deletion.
 *
 * Story 17.8.4: Scheduled Cloud Functions for Account Cleanup (#481)
 * Issue #729: Safety-net for isEmailVerified sync gap
 */
export const updateAccountStatuses = functions.region('europe-west6').pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    const db = admin.firestore();
    const auth = admin.auth();
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
      const restrictedUserIds: string[] = [];
      const syncedUserIds: string[] = [];

      for (const doc of snapshot.docs) {
        const data = doc.data();
        const createdAt = data.createdAt as admin.firestore.Timestamp;

        // Safety net (Issue #729): check Firebase Auth before restricting.
        // A user may have verified their email but the Firestore sync was missed.
        let authVerified = false;
        try {
          const authUser = await auth.getUser(doc.id);
          authVerified = authUser.emailVerified;
        } catch (authError) {
          // Auth record missing or lookup failed — treat as unverified and restrict.
          functions.logger.warn(
            "[updateAccountStatuses] Could not fetch Auth record, restricting",
            {
              uid: doc.id,
              error: authError instanceof Error ?
                authError.message : String(authError),
            }
          );
        }

        if (authVerified) {
          // Sync gap: user verified in Auth but Firestore was never updated.
          batch.update(doc.ref, {
            isEmailVerified: true,
            accountStatus: "active",
            emailVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          syncedUserIds.push(doc.id);
          functions.logger.info(
            "[updateAccountStatuses] Syncing verified account (gap fix)",
            {
              uid: doc.id,
              previousStatus: "pendingVerification",
              newStatus: "active",
            }
          );
        } else {
          // Truly unverified: restrict and schedule deletion.
          const deletionDate = new Date(
            createdAt.toDate().getTime() + 30 * 24 * 60 * 60 * 1000
          );
          batch.update(doc.ref, {
            accountStatus: "restricted",
            deletionScheduledAt:
              admin.firestore.Timestamp.fromDate(deletionDate),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          restrictedUserIds.push(doc.id);
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
      }

      await batch.commit();

      functions.logger.info(
        "[updateAccountStatuses] Completed successfully",
        {
          restricted: restrictedUserIds.length,
          syncedToActive: syncedUserIds.length,
          restrictedIds: restrictedUserIds,
          syncedIds: syncedUserIds,
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

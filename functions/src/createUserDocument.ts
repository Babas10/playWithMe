// Cloud Functions for managing user lifecycle: creation and deletion
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Firebase Auth onCreate trigger that runs when a new user is created.
 * Automatically creates a corresponding user document in the Firestore 'users' collection.
 *
 * This ensures data integrity for features that depend on user profiles existing,
 * such as friend requests, group invitations, and user search.
 *
 * Features:
 * - Idempotent: Checks if document exists before creating
 * - Works with all signup flows: email/password, OAuth (Google, Apple)
 * - Initializes profile with predictable structure
 * - Comprehensive logging for monitoring and debugging
 */
export const createUserDocument = functions.region('europe-west6').auth.user().onCreate(async (user) => {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(user.uid);

  try {
    functions.logger.info(`Auth onCreate trigger fired for user ${user.uid}`, {
      email: user.email,
      displayName: user.displayName,
      providers: user.providerData.map(p => p.providerId),
    });

    // Determine signup method for logging
    const signupMethod = user.providerData.map(p => p.providerId).join(", ") || "email";

    // Compute grace period expiration (7 days from now)
    const now = new Date();
    const gracePeriodExpiresAt = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    const isVerified = user.emailVerified || false;

    // Build the complete canonical document once.
    //
    // Note: displayName is intentionally omitted when null/empty so that a concurrent
    // updateUserNames call (which sets displayName from firstName+lastName) is not
    // silently overwritten back to null by this trigger. For OAuth providers
    // (Google, Apple) displayName is available from Auth and is written normally.
    //
    // This single source of truth is reused for both the new-doc path (set with
    // merge:true) and the race-condition patch path (fill in any missing/null fields).
    const canonicalData: Record<string, unknown> = {
      // Core identity
      email: user.email || "",
      ...(user.displayName ? { displayName: user.displayName } : {}),
      photoUrl: user.photoURL || null,

      // Auth metadata
      isEmailVerified: isVerified,

      // Account status fields (Story 17.8.2)
      emailVerifiedAt: isVerified
        ? admin.firestore.FieldValue.serverTimestamp()
        : null,
      accountStatus: isVerified ? "active" : "pendingVerification",
      gracePeriodExpiresAt: admin.firestore.Timestamp.fromDate(gracePeriodExpiresAt),
      deletionScheduledAt: null,

      // Timestamps
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),

      // Social graph (initialized empty)
      friendIds: [],
      groupIds: [],

      // Stats
      eloRating: 1200,
      gamesPlayed: 0,
      gamesWon: 0,
      gamesLost: 0,
      eloGamesPlayed: 0,
      eloPeak: 1200,
    };

    // Idempotency / race-condition guard: the doc may already exist when
    // updateUserNames (called during onboarding) wins the race against this trigger.
    // In that case the doc is typically incomplete (missing eloRating, accountStatus,
    // createdAt, groupIds, etc.). We backfill every canonical field that is absent
    // or null rather than returning early, so the schema is always complete.
    const existingDoc = await userRef.get();
    if (existingDoc.exists) {
      const existing = existingDoc.data() ?? {};
      const patch: Record<string, unknown> = {};

      // A field is considered "missing" when it is absent, null, or an empty string.
      // An empty string is used as the sentinel for a missing email address, so we
      // treat it the same as null/undefined to ensure the real email is backfilled.
      const isMissing = (v: unknown) => v === undefined || v === null || v === "";

      for (const [key, value] of Object.entries(canonicalData)) {
        // Patch only when the field is missing in the existing doc AND the canonical
        // default is meaningful (non-null/non-empty). This avoids null→null no-op
        // updates for fields like deletionScheduledAt or emailVerifiedAt that are
        // intentionally null for unverified users.
        if (isMissing(existing[key]) && value !== null && value !== "") {
          patch[key] = value;
        }
      }

      if (Object.keys(patch).length > 0) {
        patch.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        await userRef.update(patch);
        functions.logger.info(`Backfilled missing fields on existing user document`, {
          uid: user.uid,
          fields: Object.keys(patch),
        });
      } else {
        functions.logger.info(`User document already complete for ${user.uid}, no patch needed`, { uid: user.uid });
      }
      return;
    }

    // New user: write the full canonical document.
    // merge:true preserves any fields already written by updateUserNames
    // (firstName, lastName, gender, displayName) if it somehow ran first.
    await userRef.set(canonicalData, {merge: true});

    functions.logger.info(`Successfully created Firestore user document`, {
      uid: user.uid,
      email: user.email,
      signupMethod: signupMethod,
      hasDisplayName: !!user.displayName,
      hasPhoto: !!user.photoURL,
    });

  } catch (error) {
    // Log error with full context for debugging
    functions.logger.error(`Failed to create Firestore user document`, {
      uid: user.uid,
      email: user.email,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    // Don't throw - we don't want to block user creation in Auth
    // The client-side registration has a fallback that will retry
    // Monitoring alerts should be set up for this error condition
  }
});

/**
 * Firebase Auth onDelete trigger that runs when a user account is deleted.
 * Automatically cleans up the user's Firestore document and related data.
 *
 * This ensures proper lifecycle hygiene and prevents orphaned data.
 *
 * Cleanup actions:
 * - Deletes user document from 'users' collection
 * - Removes user from all friendships (declined status for audit trail)
 * - Removes user from all group memberships
 * - Deletes pending invitations sent by or to the user
 *
 * Note: This is a best-effort cleanup. Some data may be retained for audit purposes.
 */
export const deleteUserDocument = functions.region('europe-west6').auth.user().onDelete(async (user) => {
  const db = admin.firestore();

  // Note: Using batch instead of transaction for cleanup operations
  // Rationale: This is a best-effort cleanup where we want to delete/update
  // multiple unrelated collections. Transactions would be overkill and could
  // fail more easily due to contention on multiple document paths.
  // The batch ensures all-or-nothing writes within the 500 document limit.
  const batch = db.batch();

  try {
    functions.logger.info(`Auth onDelete trigger fired for user ${user.uid}`, {
      email: user.email,
      displayName: user.displayName,
    });

    // 1. Delete user document
    const userRef = db.collection("users").doc(user.uid);
    const userDoc = await userRef.get();

    if (userDoc.exists) {
      batch.delete(userRef);
      functions.logger.info(`Scheduled deletion of user document for ${user.uid}`);
    } else {
      functions.logger.warn(`User document does not exist for ${user.uid}, skipping deletion`);
    }

    // 2. Handle friendships - set to 'declined' for audit trail
    const friendshipsAsInitiator = await db.collection("friendships")
      .where("initiatorId", "==", user.uid)
      .get();

    const friendshipsAsRecipient = await db.collection("friendships")
      .where("recipientId", "==", user.uid)
      .get();

    friendshipsAsInitiator.docs.forEach(doc => {
      batch.update(doc.ref, {
        status: "declined",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    friendshipsAsRecipient.docs.forEach(doc => {
      batch.update(doc.ref, {
        status: "declined",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    functions.logger.info(`Scheduled ${friendshipsAsInitiator.size + friendshipsAsRecipient.size} friendship updates`);

    // 3. Delete pending invitations
    const sentInvitations = await db.collection("invitations")
      .where("invitedBy", "==", user.uid)
      .where("status", "==", "pending")
      .get();

    const receivedInvitations = await db.collection("invitations")
      .where("invitedUserId", "==", user.uid)
      .where("status", "==", "pending")
      .get();

    sentInvitations.docs.forEach(doc => batch.delete(doc.ref));
    receivedInvitations.docs.forEach(doc => batch.delete(doc.ref));

    functions.logger.info(`Scheduled deletion of ${sentInvitations.size + receivedInvitations.size} pending invitations`);

    // 4. Remove from group memberships
    // Note: Groups have memberIds arrays that need to be updated
    const groups = await db.collection("groups")
      .where("memberIds", "array-contains", user.uid)
      .get();

    groups.docs.forEach(doc => {
      batch.update(doc.ref, {
        memberIds: admin.firestore.FieldValue.arrayRemove(user.uid),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    functions.logger.info(`Scheduled removal from ${groups.size} groups`);

    // Commit all changes in batch
    await batch.commit();

    functions.logger.info(`Successfully cleaned up data for deleted user ${user.uid}`, {
      userDocDeleted: userDoc.exists,
      friendshipsUpdated: friendshipsAsInitiator.size + friendshipsAsRecipient.size,
      invitationsDeleted: sentInvitations.size + receivedInvitations.size,
      groupsUpdated: groups.size,
    });

  } catch (error) {
    functions.logger.error(`Failed to clean up data for deleted user ${user.uid}`, {
      uid: user.uid,
      email: user.email,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    // Don't throw - cleanup failure shouldn't block account deletion
    // Manual cleanup may be required, which should trigger monitoring alerts
  }
});

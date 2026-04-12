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

    // Idempotency check: Verify document doesn't already exist.
    // When the doc already exists it was created by a concurrent updateUserNames call
    // (which fires before this trigger). In that case we only patch the email field if
    // it is missing — a defence against any remaining ordering edge cases.
    const existingDoc = await userRef.get();
    if (existingDoc.exists) {
      // Patch any required bool fields that may be missing when updateUserNames
      // won the race and created the document before this trigger fired.
      const existingData = existingDoc.data() ?? {};
      const patch: Record<string, unknown> = {};

      if (!existingData.email && user.email) {
        patch.email = user.email;
      }
      if (existingData.isEmailVerified === undefined || existingData.isEmailVerified === null) {
        patch.isEmailVerified = user.emailVerified || false;
      }

      if (Object.keys(patch).length > 0) {
        patch.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        await userRef.update(patch);
        functions.logger.info(`Patched missing fields on existing user document`, { uid: user.uid, patch: Object.keys(patch) });
      } else {
        functions.logger.info(`User document already exists for ${user.uid}, skipping creation`, { uid: user.uid });
      }
      return;
    }

    // Determine signup method for logging
    const signupMethod = user.providerData.map(p => p.providerId).join(", ") || "email";

    // Compute grace period expiration (7 days from now)
    const now = new Date();
    const gracePeriodExpiresAt = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    const isVerified = user.emailVerified || false;

    // Create user document with complete profile structure
    // Note: displayName is intentionally omitted when null so that a concurrent
    // updateUserNames call (which sets displayName from firstName+lastName) is not
    // silently overwritten back to null by this trigger. For OAuth providers
    // (Google, Apple) displayName is available from Auth and is written normally.
    const userData: Record<string, unknown> = {
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
      // Note: These arrays are managed by Cloud Functions for friends/groups features
      friendIds: [],
      groupIds: [],

      // Stats
      eloRating: 1200,
      gamesPlayed: 0,
      wins: 0,
      losses: 0,
    };

    // Use merge: true so that if updateUserNames already wrote firstName/lastName/gender
    // before this trigger fired, those fields are preserved rather than overwritten.
    await userRef.set(userData, {merge: true});

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

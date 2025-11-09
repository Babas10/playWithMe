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
 * - Works with all signup flows: email/password, OAuth (Google, Apple), anonymous
 * - Initializes profile with predictable structure
 * - Comprehensive logging for monitoring and debugging
 */
export const createUserDocument = functions.auth.user().onCreate(async (user) => {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(user.uid);

  try {
    functions.logger.info(`Auth onCreate trigger fired for user ${user.uid}`, {
      email: user.email,
      displayName: user.displayName,
      providers: user.providerData.map(p => p.providerId),
      isAnonymous: user.providerData.length === 0,
    });

    // Idempotency check: Verify document doesn't already exist
    // This handles cases where client-side code created the document first
    const existingDoc = await userRef.get();
    if (existingDoc.exists) {
      functions.logger.info(`User document already exists for ${user.uid}, skipping creation`, {
        uid: user.uid,
        email: user.email,
      });
      return;
    }

    // Determine signup method for logging
    const signupMethod = user.providerData.length === 0
      ? "anonymous"
      : user.providerData.map(p => p.providerId).join(", ");

    // Create user document with complete profile structure
    const userData = {
      // Core identity
      email: user.email || "",
      displayName: user.displayName || null,
      photoUrl: user.photoURL || null,

      // Auth metadata
      isEmailVerified: user.emailVerified || false,
      isAnonymous: user.providerData.length === 0,

      // Timestamps
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),

      // Social graph (initialized empty)
      // Note: These arrays are managed by Cloud Functions for friends/groups features
      friendIds: [],
      groupIds: [],
    };

    await userRef.set(userData);

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
export const deleteUserDocument = functions.auth.user().onDelete(async (user) => {
  const db = admin.firestore();
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

// Cloud Functions for managing friendships in the social graph
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// ============================================================================
// Type Definitions
// ============================================================================

interface UserProfile {
  uid: string;
  displayName: string | null;
  email: string;
  photoUrl?: string | null;
  isEmailVerified?: boolean;
  isAnonymous?: boolean;
  createdAt?: string | null;
  lastSignInAt?: string | null;
}

interface SendFriendRequestRequest {
  targetUserId: string;
}

interface SendFriendRequestResponse {
  success: boolean;
  friendshipId: string;
}

interface AcceptFriendRequestRequest {
  friendshipId: string;
}

interface AcceptFriendRequestResponse {
  success: boolean;
}

interface DeclineFriendRequestRequest {
  friendshipId: string;
}

interface DeclineFriendRequestResponse {
  success: boolean;
}

interface RemoveFriendRequest {
  friendshipId: string;
}

interface RemoveFriendResponse {
  success: boolean;
}

interface GetFriendsRequest {
  userId?: string;
}

interface GetFriendsResponse {
  friends: UserProfile[];
}

interface CheckFriendshipStatusRequest {
  userId: string;
}

interface CheckFriendshipStatusResponse {
  isFriend: boolean;
  hasPendingRequest: boolean;
  requestDirection?: "sent" | "received";
}

interface FriendshipRequest {
  id: string;
  initiatorId: string;
  initiatorName: string;
  recipientId: string;
  recipientName: string;
  status: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

interface GetFriendshipRequestsResponse {
  receivedRequests: FriendshipRequest[];
  sentRequests: FriendshipRequest[];
}

interface VerifyFriendshipRequest {
  initiatorId: string;
  recipientId: string;
}

interface VerifyFriendshipResponse {
  areFriends: boolean;
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Check if a user exists in Firestore
 */
async function userExists(userId: string): Promise<boolean> {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(userId).get();
  return userDoc.exists;
}

/**
 * Get user profile data
 */
async function getUserProfile(userId: string): Promise<UserProfile | null> {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(userId).get();

  if (!userDoc.exists) {
    return null;
  }

  const userData = userDoc.data()!;
  return {
    uid: userDoc.id,
    displayName: userData.displayName || null,
    email: userData.email,
    photoUrl: userData.photoUrl || null,
  };
}

/**
 * Check if a friendship exists between two users (in either direction)
 */
async function findExistingFriendship(
  userId1: string,
  userId2: string
): Promise<FirebaseFirestore.QueryDocumentSnapshot | null> {
  const db = admin.firestore();
  const friendshipsRef = db.collection("friendships");

  // Check direction 1: userId1 -> userId2
  const query1 = await friendshipsRef
    .where("initiatorId", "==", userId1)
    .where("recipientId", "==", userId2)
    .limit(1)
    .get();

  if (!query1.empty) {
    return query1.docs[0];
  }

  // Check direction 2: userId2 -> userId1
  const query2 = await friendshipsRef
    .where("initiatorId", "==", userId2)
    .where("recipientId", "==", userId1)
    .limit(1)
    .get();

  if (!query2.empty) {
    return query2.docs[0];
  }

  return null;
}

// ============================================================================
// Function 1: Send Friend Request
// ============================================================================

/**
 * Handler for sending a friend request
 */
export async function sendFriendRequestHandler(
  data: SendFriendRequestRequest,
  context: functions.https.CallableContext
): Promise<SendFriendRequestResponse> {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to send friend requests"
    );
  }

  const currentUserId = context.auth.uid;

  // Validate input
  if (!data || typeof data.targetUserId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "targetUserId is required and must be a string"
    );
  }

  const { targetUserId } = data;

  functions.logger.info("Sending friend request", {
    from: currentUserId,
    to: targetUserId,
  });

  // Cannot friend yourself
  if (currentUserId === targetUserId) {
    functions.logger.warn("Attempt to send friend request to self", {
      userId: currentUserId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "You cannot send a friend request to yourself"
    );
  }

  try {
    // Check if target user exists
    const targetExists = await userExists(targetUserId);
    if (!targetExists) {
      functions.logger.warn("Target user not found", {
        from: currentUserId,
        targetUserId,
      });
      throw new functions.https.HttpsError(
        "not-found",
        "The user you're trying to add doesn't exist"
      );
    }

    functions.logger.debug("Target user exists, checking for existing friendship", {
      from: currentUserId,
      to: targetUserId,
    });

    // Check for existing friendship
    const existingFriendship = await findExistingFriendship(
      currentUserId,
      targetUserId
    );

    if (existingFriendship) {
      const friendshipData = existingFriendship.data();
      const status = friendshipData.status;

      functions.logger.warn("Existing friendship found", {
        from: currentUserId,
        to: targetUserId,
        friendshipId: existingFriendship.id,
        status,
      });

      if (status === "accepted") {
        throw new functions.https.HttpsError(
          "already-exists",
          "You are already friends with this user"
        );
      }

      if (status === "pending") {
        throw new functions.https.HttpsError(
          "already-exists",
          "A friend request already exists between you and this user"
        );
      }

      // If declined, allow creating a new request
      // (old declined friendship stays for audit trail)
      functions.logger.info("Previous friendship was declined, allowing new request", {
        from: currentUserId,
        to: targetUserId,
      });
    }

    // Get user profiles for denormalized names
    const initiatorProfile = await getUserProfile(currentUserId);
    const recipientProfile = await getUserProfile(targetUserId);

    if (!initiatorProfile || !recipientProfile) {
      functions.logger.error("Failed to retrieve user profiles", {
        from: currentUserId,
        to: targetUserId,
        hasInitiator: !!initiatorProfile,
        hasRecipient: !!recipientProfile,
      });
      throw new functions.https.HttpsError(
        "internal",
        "Failed to retrieve user profiles"
      );
    }

    // Create new friendship document
    const db = admin.firestore();
    const friendshipRef = await db.collection("friendships").add({
      initiatorId: currentUserId,
      recipientId: targetUserId,
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      initiatorName: initiatorProfile.displayName || initiatorProfile.email,
      recipientName: recipientProfile.displayName || recipientProfile.email,
    });

    functions.logger.info("Friend request created successfully", {
      from: currentUserId,
      to: targetUserId,
      friendshipId: friendshipRef.id,
    });

    return {
      success: true,
      friendshipId: friendshipRef.id,
    };
  } catch (error) {
    // Re-throw HttpsError
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("Error sending friend request", {
      from: currentUserId,
      to: targetUserId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to send friend request"
    );
  }
}

/**
 * Cloud Function to send a friend request
 */
export const sendFriendRequest = functions.https.onCall(
  sendFriendRequestHandler
);

// ============================================================================
// Function 2: Accept Friend Request
// ============================================================================

/**
 * Handler for accepting a friend request
 */
export async function acceptFriendRequestHandler(
  data: AcceptFriendRequestRequest,
  context: functions.https.CallableContext
): Promise<AcceptFriendRequestResponse> {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to accept friend requests"
    );
  }

  const currentUserId = context.auth.uid;

  // Validate input
  if (!data || typeof data.friendshipId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "friendshipId is required and must be a string"
    );
  }

  const { friendshipId } = data;

  try {
    const db = admin.firestore();
    const friendshipRef = db.collection("friendships").doc(friendshipId);

    // Use transaction to ensure consistency
    await db.runTransaction(async (transaction) => {
      const friendshipDoc = await transaction.get(friendshipRef);

      if (!friendshipDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Friend request not found"
        );
      }

      const friendshipData = friendshipDoc.data()!;

      // Caller must be the recipient
      if (friendshipData.recipientId !== currentUserId) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "You can only accept friend requests sent to you"
        );
      }

      // Friendship must be in pending status
      if (friendshipData.status !== "pending") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          `Cannot accept friend request with status: ${friendshipData.status}`
        );
      }

      // Update status to accepted
      transaction.update(friendshipRef, {
        status: "accepted",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return {
      success: true,
    };
  } catch (error) {
    // Re-throw HttpsError
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    console.error("Error accepting friend request:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to accept friend request"
    );
  }
}

/**
 * Cloud Function to accept a friend request
 */
export const acceptFriendRequest = functions.https.onCall(
  acceptFriendRequestHandler
);

// ============================================================================
// Function 3: Decline Friend Request
// ============================================================================

/**
 * Handler for declining a friend request
 */
export async function declineFriendRequestHandler(
  data: DeclineFriendRequestRequest,
  context: functions.https.CallableContext
): Promise<DeclineFriendRequestResponse> {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to decline friend requests"
    );
  }

  const currentUserId = context.auth.uid;

  // Validate input
  if (!data || typeof data.friendshipId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "friendshipId is required and must be a string"
    );
  }

  const { friendshipId } = data;

  try {
    const db = admin.firestore();
    const friendshipRef = db.collection("friendships").doc(friendshipId);

    // Use transaction to ensure consistency
    await db.runTransaction(async (transaction) => {
      const friendshipDoc = await transaction.get(friendshipRef);

      if (!friendshipDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Friend request not found"
        );
      }

      const friendshipData = friendshipDoc.data()!;

      // Caller must be the recipient
      if (friendshipData.recipientId !== currentUserId) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "You can only decline friend requests sent to you"
        );
      }

      // Friendship must be in pending status
      if (friendshipData.status !== "pending") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          `Cannot decline friend request with status: ${friendshipData.status}`
        );
      }

      // Update status to declined (kept for audit trail)
      transaction.update(friendshipRef, {
        status: "declined",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return {
      success: true,
    };
  } catch (error) {
    // Re-throw HttpsError
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    console.error("Error declining friend request:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to decline friend request"
    );
  }
}

/**
 * Cloud Function to decline a friend request
 */
export const declineFriendRequest = functions.https.onCall(
  declineFriendRequestHandler
);

// ============================================================================
// Function 4: Remove Friend
// ============================================================================

/**
 * Handler for removing a friend (deletes friendship document)
 */
export async function removeFriendHandler(
  data: RemoveFriendRequest,
  context: functions.https.CallableContext
): Promise<RemoveFriendResponse> {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to remove friends"
    );
  }

  const currentUserId = context.auth.uid;

  // Validate input
  if (!data || typeof data.friendshipId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "friendshipId is required and must be a string"
    );
  }

  const { friendshipId } = data;

  try {
    const db = admin.firestore();
    const friendshipRef = db.collection("friendships").doc(friendshipId);
    const friendshipDoc = await friendshipRef.get();

    if (!friendshipDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Friendship not found"
      );
    }

    const friendshipData = friendshipDoc.data()!;

    // Caller must be either initiator or recipient
    if (
      friendshipData.initiatorId !== currentUserId &&
      friendshipData.recipientId !== currentUserId
    ) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You can only remove your own friendships"
      );
    }

    // Delete the friendship document
    await friendshipRef.delete();

    return {
      success: true,
    };
  } catch (error) {
    // Re-throw HttpsError
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    console.error("Error removing friend:", error);
    throw new functions.https.HttpsError("internal", "Failed to remove friend");
  }
}

/**
 * Cloud Function to remove a friend
 */
export const removeFriend = functions.https.onCall(removeFriendHandler);

// ============================================================================
// Function 5: Get Friends
// ============================================================================

/**
 * Handler for getting a user's friends list
 */
export async function getFriendsHandler(
  data: GetFriendsRequest,
  context: functions.https.CallableContext
): Promise<GetFriendsResponse> {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to get friends list"
    );
  }

  const currentUserId = context.auth.uid;

  // Default to current user if userId not provided
  const targetUserId = data?.userId || currentUserId;

  // Users can only get their own friends list (privacy)
  if (targetUserId !== currentUserId) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "You can only view your own friends list"
    );
  }

  try {
    functions.logger.info("Getting friends list", {
      userId: targetUserId,
    });

    const db = admin.firestore();
    const friendshipsRef = db.collection("friendships");

    // Get friendships where user is initiator (accepted only)
    const asInitiatorQuery = friendshipsRef
      .where("initiatorId", "==", targetUserId)
      .where("status", "==", "accepted")
      .get();

    // Get friendships where user is recipient (accepted only)
    const asRecipientQuery = friendshipsRef
      .where("recipientId", "==", targetUserId)
      .where("status", "==", "accepted")
      .get();

    // Execute both queries in parallel
    const [asInitiatorSnapshot, asRecipientSnapshot] = await Promise.all([
      asInitiatorQuery,
      asRecipientQuery,
    ]);

    functions.logger.debug("Friendships query results", {
      userId: targetUserId,
      asInitiator: asInitiatorSnapshot.size,
      asRecipient: asRecipientSnapshot.size,
    });

    // Collect friend user IDs
    const friendUserIds = new Set<string>();

    asInitiatorSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      friendUserIds.add(data.recipientId);
    });

    asRecipientSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      friendUserIds.add(data.initiatorId);
    });

    // If no friends, return empty array
    if (friendUserIds.size === 0) {
      functions.logger.info("No friends found", {
        userId: targetUserId,
      });
      return {
        friends: [],
      };
    }

    functions.logger.debug("Found friend user IDs", {
      userId: targetUserId,
      friendCount: friendUserIds.size,
      friendIds: Array.from(friendUserIds),
    });

    // Fetch friend profiles
    const friendProfiles: UserProfile[] = [];
    const usersRef = db.collection("users");

    // Firestore 'in' query limited to 10 items, so batch if needed
    const friendIdsArray = Array.from(friendUserIds);
    for (let i = 0; i < friendIdsArray.length; i += 10) {
      const batch = friendIdsArray.slice(i, i + 10);
      const usersSnapshot = await usersRef
        .where(admin.firestore.FieldPath.documentId(), "in", batch)
        .get();

      usersSnapshot.docs.forEach((doc) => {
        const userData = doc.data();
        friendProfiles.push({
          uid: doc.id,
          displayName: userData.displayName || null,
          email: userData.email,
          photoUrl: userData.photoUrl || null,
          isEmailVerified: userData.isEmailVerified || false,
          isAnonymous: userData.isAnonymous || false,
          // Convert Firestore Timestamps to ISO8601 strings for Flutter
          createdAt: userData.createdAt?.toDate().toISOString() || null,
          lastSignInAt: userData.lastSignInAt?.toDate().toISOString() || null,
        });
      });
    }

    functions.logger.info("Successfully retrieved friends list", {
      userId: targetUserId,
      friendCount: friendProfiles.length,
    });

    return {
      friends: friendProfiles,
    };
  } catch (error) {
    // Re-throw HttpsError
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("Error getting friends list", {
      userId: targetUserId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to retrieve friends list"
    );
  }
}

/**
 * Cloud Function to get a user's friends list
 */
export const getFriends = functions.https.onCall(getFriendsHandler);

// ============================================================================
// Function 6: Check Friendship Status
// ============================================================================

/**
 * Handler for checking friendship status with another user
 */
export async function checkFriendshipStatusHandler(
  data: CheckFriendshipStatusRequest,
  context: functions.https.CallableContext
): Promise<CheckFriendshipStatusResponse> {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to check friendship status"
    );
  }

  const currentUserId = context.auth.uid;

  // Validate input
  if (!data || typeof data.userId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "userId is required and must be a string"
    );
  }

  const { userId } = data;

  // Cannot check friendship with yourself
  if (currentUserId === userId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Cannot check friendship status with yourself"
    );
  }

  try {
    // Find existing friendship
    const existingFriendship = await findExistingFriendship(
      currentUserId,
      userId
    );

    if (!existingFriendship) {
      return {
        isFriend: false,
        hasPendingRequest: false,
      };
    }

    const friendshipData = existingFriendship.data();
    const status = friendshipData.status;

    if (status === "accepted") {
      return {
        isFriend: true,
        hasPendingRequest: false,
      };
    }

    if (status === "pending") {
      // Determine direction
      const isSent = friendshipData.initiatorId === currentUserId;
      return {
        isFriend: false,
        hasPendingRequest: true,
        requestDirection: isSent ? "sent" : "received",
      };
    }

    // Status is "declined" - treat as no relationship
    return {
      isFriend: false,
      hasPendingRequest: false,
    };
  } catch (error) {
    // Re-throw HttpsError
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    console.error("Error checking friendship status:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to check friendship status"
    );
  }
}

/**
 * Cloud Function to check friendship status with another user
 */
export const checkFriendshipStatus = functions.https.onCall(
  checkFriendshipStatusHandler
);

// ============================================================================
// Function 7: Get Friendship Requests
// ============================================================================

/**
 * Handler for getting all pending friend requests for the authenticated user
 * Returns both received requests (where user is recipient) and sent requests (where user is initiator)
 */
export async function getFriendshipRequestsHandler(
  data: unknown,
  context: functions.https.CallableContext
): Promise<GetFriendshipRequestsResponse> {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to view friend requests"
    );
  }

  const currentUserId = context.auth.uid;

  try {
    functions.logger.info("Getting friendship requests", {
      userId: currentUserId,
    });

    const db = admin.firestore();
    const friendshipsRef = db.collection("friendships");

    // Query for received requests (where user is recipient)
    const receivedQuery = await friendshipsRef
      .where("recipientId", "==", currentUserId)
      .where("status", "==", "pending")
      .get();

    // Query for sent requests (where user is initiator)
    const sentQuery = await friendshipsRef
      .where("initiatorId", "==", currentUserId)
      .where("status", "==", "pending")
      .get();

    // Map received requests to response format
    const receivedRequests: FriendshipRequest[] = receivedQuery.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        initiatorId: data.initiatorId,
        initiatorName: data.initiatorName,
        recipientId: data.recipientId,
        recipientName: data.recipientName,
        status: data.status,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      };
    });

    // Map sent requests to response format
    const sentRequests: FriendshipRequest[] = sentQuery.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        initiatorId: data.initiatorId,
        initiatorName: data.initiatorName,
        recipientId: data.recipientId,
        recipientName: data.recipientName,
        status: data.status,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      };
    });

    functions.logger.info("Successfully retrieved friendship requests", {
      userId: currentUserId,
      receivedCount: receivedRequests.length,
      sentCount: sentRequests.length,
    });

    return {
      receivedRequests,
      sentRequests,
    };
  } catch (error) {
    functions.logger.error("Error getting friendship requests", {
      userId: currentUserId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    throw new functions.https.HttpsError(
      "internal",
      "Failed to retrieve friend requests"
    );
  }
}

/**
 * Cloud Function to get all pending friendship requests for the authenticated user
 */
export const getFriendshipRequests = functions.https.onCall(
  getFriendshipRequestsHandler
);

// ============================================================================
// Firestore Triggers for Friend Cache Maintenance (Story 11.6)
// ============================================================================

/**
 * Trigger: Update both users' friend caches when a friendship is accepted
 *
 * This function:
 * 1. Detects when a friendship status changes to "accepted"
 * 2. Updates both users' cached friendIds arrays
 * 3. Increments both users' friendCount
 * 4. Updates friendsLastUpdated timestamp
 *
 * Performance: Uses batched writes to minimize Firestore operations
 */
export const onFriendRequestAccepted = functions.firestore
  .document("friendships/{friendshipId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger when status changes to "accepted"
    if (before.status !== "accepted" && after.status === "accepted") {
      const initiatorId = after.initiatorId;
      const recipientId = after.recipientId;

      functions.logger.info("Friendship accepted, updating caches", {
        friendshipId: context.params.friendshipId,
        initiatorId,
        recipientId,
      });

      try {
        const db = admin.firestore();
        const batch = db.batch();

        // Update initiator's cache
        const initiatorRef = db.collection("users").doc(initiatorId);
        batch.update(initiatorRef, {
          friendIds: admin.firestore.FieldValue.arrayUnion(recipientId),
          friendCount: admin.firestore.FieldValue.increment(1),
          friendsLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update recipient's cache
        const recipientRef = db.collection("users").doc(recipientId);
        batch.update(recipientRef, {
          friendIds: admin.firestore.FieldValue.arrayUnion(initiatorId),
          friendCount: admin.firestore.FieldValue.increment(1),
          friendsLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        await batch.commit();

        functions.logger.info("Friend caches updated successfully", {
          friendshipId: context.params.friendshipId,
          initiatorId,
          recipientId,
        });
      } catch (error) {
        functions.logger.error("Failed to update friend caches", {
          friendshipId: context.params.friendshipId,
          error: error instanceof Error ? error.message : String(error),
          stack: error instanceof Error ? error.stack : undefined,
        });
        // Don't throw - this is a background trigger
        // The cache will be stale but can be refreshed later
      }
    }
  });

/**
 * Trigger: Remove friend IDs from both users' caches when a friendship is deleted
 *
 * This function:
 * 1. Detects when a friendship document is deleted
 * 2. Removes each user's ID from the other's cached friendIds array
 * 3. Decrements both users' friendCount
 * 4. Updates friendsLastUpdated timestamp
 *
 * Performance: Uses batched writes to minimize Firestore operations
 */
export const onFriendRemoved = functions.firestore
  .document("friendships/{friendshipId}")
  .onDelete(async (snap, context) => {
    const data = snap.data();

    // Only process if friendship was accepted
    if (data.status === "accepted") {
      const initiatorId = data.initiatorId;
      const recipientId = data.recipientId;

      functions.logger.info("Friendship removed, updating caches", {
        friendshipId: context.params.friendshipId,
        initiatorId,
        recipientId,
      });

      try {
        const db = admin.firestore();
        const batch = db.batch();

        // Update initiator's cache
        const initiatorRef = db.collection("users").doc(initiatorId);
        batch.update(initiatorRef, {
          friendIds: admin.firestore.FieldValue.arrayRemove(recipientId),
          friendCount: admin.firestore.FieldValue.increment(-1),
          friendsLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update recipient's cache
        const recipientRef = db.collection("users").doc(recipientId);
        batch.update(recipientRef, {
          friendIds: admin.firestore.FieldValue.arrayRemove(initiatorId),
          friendCount: admin.firestore.FieldValue.increment(-1),
          friendsLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        await batch.commit();

        functions.logger.info("Friend caches updated after removal", {
          friendshipId: context.params.friendshipId,
          initiatorId,
          recipientId,
        });
      } catch (error) {
        functions.logger.error("Failed to update friend caches after removal", {
          friendshipId: context.params.friendshipId,
          error: error instanceof Error ? error.message : String(error),
          stack: error instanceof Error ? error.stack : undefined,
        });
        // Don't throw - this is a background trigger
      }
    }
  });

// ============================================================================
// Function 8: Get Friendships (Story 11.13)
// ============================================================================

interface FriendshipWithUser {
  id: string;
  otherUser: UserProfile;
  status: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  // Additional context fields
  isInitiator: boolean; // True if current user initiated the friendship
}

interface GetFriendshipsRequest {
  status: "pending" | "accepted" | "declined";
}

interface GetFriendshipsResponse {
  friendships: FriendshipWithUser[];
}

/**
 * Handler for getting friendships by status with denormalized user info
 * Story 11.13: Unified function to replace getFriends and getFriendshipRequests
 */
export async function getFriendshipsHandler(
  data: GetFriendshipsRequest,
  context: functions.https.CallableContext
): Promise<GetFriendshipsResponse> {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to get friendships"
    );
  }

  const currentUserId = context.auth.uid;

  // Validate input
  if (!data || !data.status) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "status is required and must be one of: pending, accepted, declined"
    );
  }

  const { status } = data;

  // Validate status value
  if (!["pending", "accepted", "declined"].includes(status)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "status must be one of: pending, accepted, declined"
    );
  }

  try {
    functions.logger.info("Getting friendships by status", {
      userId: currentUserId,
      status,
    });

    const db = admin.firestore();
    const friendshipsRef = db.collection("friendships");

    // Get friendships where user is initiator with specified status
    const asInitiatorQuery = friendshipsRef
      .where("initiatorId", "==", currentUserId)
      .where("status", "==", status)
      .get();

    // Get friendships where user is recipient with specified status
    const asRecipientQuery = friendshipsRef
      .where("recipientId", "==", currentUserId)
      .where("status", "==", status)
      .get();

    // Execute both queries in parallel
    const [asInitiatorSnapshot, asRecipientSnapshot] = await Promise.all([
      asInitiatorQuery,
      asRecipientQuery,
    ]);

    functions.logger.debug("Friendships query results", {
      userId: currentUserId,
      status,
      asInitiator: asInitiatorSnapshot.size,
      asRecipient: asRecipientSnapshot.size,
    });

    // Collect friendship data with the other user's ID
    const friendshipsData: Array<{
      id: string;
      otherUserId: string;
      status: string;
      createdAt: FirebaseFirestore.Timestamp;
      updatedAt: FirebaseFirestore.Timestamp;
      isInitiator: boolean;
    }> = [];

    // Process friendships where current user is initiator
    asInitiatorSnapshot.docs.forEach((doc) => {
      const docData = doc.data();
      friendshipsData.push({
        id: doc.id,
        otherUserId: docData.recipientId,
        status: docData.status,
        createdAt: docData.createdAt,
        updatedAt: docData.updatedAt,
        isInitiator: true,
      });
    });

    // Process friendships where current user is recipient
    asRecipientSnapshot.docs.forEach((doc) => {
      const docData = doc.data();
      friendshipsData.push({
        id: doc.id,
        otherUserId: docData.initiatorId,
        status: docData.status,
        createdAt: docData.createdAt,
        updatedAt: docData.updatedAt,
        isInitiator: false,
      });
    });

    // If no friendships, return empty array
    if (friendshipsData.length === 0) {
      functions.logger.info("No friendships found", {
        userId: currentUserId,
        status,
      });
      return {
        friendships: [],
      };
    }

    functions.logger.debug("Found friendships", {
      userId: currentUserId,
      status,
      count: friendshipsData.length,
    });

    // Fetch user profiles for all "other users"
    const otherUserIds = friendshipsData.map((f) => f.otherUserId);
    const userProfiles = new Map<string, UserProfile>();
    const usersRef = db.collection("users");

    // Firestore 'in' query limited to 10 items, so batch if needed
    for (let i = 0; i < otherUserIds.length; i += 10) {
      const batch = otherUserIds.slice(i, i + 10);
      const usersSnapshot = await usersRef
        .where(admin.firestore.FieldPath.documentId(), "in", batch)
        .get();

      usersSnapshot.docs.forEach((doc) => {
        const userData = doc.data();
        userProfiles.set(doc.id, {
          uid: doc.id,
          displayName: userData.displayName || null,
          email: userData.email,
          photoUrl: userData.photoUrl || null,
          isEmailVerified: userData.isEmailVerified || false,
          isAnonymous: userData.isAnonymous || false,
          createdAt: userData.createdAt?.toDate().toISOString() || null,
          lastSignInAt: userData.lastSignInAt?.toDate().toISOString() || null,
        });
      });
    }

    // Build response with denormalized user info
    const friendshipsWithUsers: FriendshipWithUser[] = friendshipsData.map((friendship) => {
      const otherUser = userProfiles.get(friendship.otherUserId);

      // If user profile not found, use a placeholder
      // This shouldn't happen in normal circumstances
      const userProfile: UserProfile = otherUser || {
        uid: friendship.otherUserId,
        displayName: null,
        email: "unknown@example.com",
        photoUrl: null,
        isEmailVerified: false,
        isAnonymous: false,
        createdAt: null,
        lastSignInAt: null,
      };

      return {
        id: friendship.id,
        otherUser: userProfile,
        status: friendship.status,
        createdAt: friendship.createdAt,
        updatedAt: friendship.updatedAt,
        isInitiator: friendship.isInitiator,
      };
    });

    functions.logger.info("Successfully retrieved friendships with user info", {
      userId: currentUserId,
      status,
      count: friendshipsWithUsers.length,
    });

    return {
      friendships: friendshipsWithUsers,
    };
  } catch (error) {
    // Re-throw HttpsError
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("Error getting friendships", {
      userId: currentUserId,
      status,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to retrieve friendships"
    );
  }
}

/**
 * Cloud Function to get friendships by status with denormalized user info
 * Story 11.13: Unified function to replace getFriends and getFriendshipRequests
 */
export const getFriendships = functions.https.onCall(getFriendshipsHandler);

// ============================================================================
// Helper Functions (Story 11.4)
// ============================================================================

/**
 * Check if two users are friends
 *
 * Validates bidirectional friendship by querying for accepted friendships
 * in either direction (A→B or B→A).
 *
 * Performance: Uses cached friendIds from Story 11.6 for O(1) lookup
 *
 * @param userAId - First user's ID
 * @param userBId - Second user's ID
 * @returns true if users are friends, false otherwise
 */
export async function checkFriendship(
  userAId: string,
  userBId: string
): Promise<boolean> {
  try {
    const db = admin.firestore();

    // Story 11.6: Use cached friendIds for fast lookup
    const userADoc = await db.collection("users").doc(userAId).get();

    if (!userADoc.exists) {
      return false;
    }

    const userData = userADoc.data();
    const friendIds = userData?.friendIds || [];

    // Check if userB is in userA's cached friendIds
    return friendIds.includes(userBId);
  } catch (error) {
    functions.logger.error("Error checking friendship", {
      userAId,
      userBId,
      error: error instanceof Error ? error.message : String(error),
    });
    return false; // Fail closed - deny if error
  }
}

// ============================================================================
// Story 11.14: Group Validation via Social Graph
// ============================================================================

/**
 * Cloud Function handler for verifying friendship between two users
 *
 * This function is called by the Groups layer to validate that users
 * are friends before allowing group invitations or membership changes.
 * It enforces the architectural boundary: Groups query the social graph
 * via this API, they do not manage friendships directly.
 *
 * @param data - Request containing initiatorId and recipientId
 * @param context - Firebase callable context with auth info
 * @returns Response indicating whether the users are friends
 */
export async function verifyFriendshipHandler(
  data: VerifyFriendshipRequest,
  context: functions.https.CallableContext
): Promise<VerifyFriendshipResponse> {
  // Validate authentication
  if (!context.auth) {
    functions.logger.warn("Unauthenticated verifyFriendship attempt");
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to verify friendships"
    );
  }

  const {initiatorId, recipientId} = data;

  // Validate required parameters
  if (!initiatorId || typeof initiatorId !== "string") {
    functions.logger.warn("Missing or invalid initiatorId", {
      userId: context.auth.uid,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'initiatorId' is required and must be a string"
    );
  }

  if (!recipientId || typeof recipientId !== "string") {
    functions.logger.warn("Missing or invalid recipientId", {
      userId: context.auth.uid,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'recipientId' is required and must be a string"
    );
  }

  functions.logger.info("Verifying friendship", {
    initiatorId,
    recipientId,
    requesterId: context.auth.uid,
  });

  // Use existing checkFriendship helper from Story 11.4
  // which leverages cached friendIds from Story 11.6 for O(1) performance
  // Note: checkFriendship is designed to fail closed (return false on error)
  const areFriends = await checkFriendship(initiatorId, recipientId);

  functions.logger.info("Friendship verification complete", {
    initiatorId,
    recipientId,
    areFriends,
  });

  return {areFriends};
}

/**
 * Cloud Function: Verify friendship between two users
 * Story 11.14: Enables Groups layer to validate member invitations
 * via the social graph API
 */
export const verifyFriendship = functions.https.onCall(
  verifyFriendshipHandler
);

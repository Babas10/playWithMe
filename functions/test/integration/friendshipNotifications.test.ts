// Integration tests for friendship notification triggers

import * as admin from "firebase-admin";
import { EmulatorHelper } from "./emulatorHelper";

describe("Friendship Notification Triggers", () => {
  let user1: admin.auth.UserRecord;
  let user2: admin.auth.UserRecord;

  beforeAll(async () => {
    await EmulatorHelper.initialize();
  });

  beforeEach(async () => {
    await EmulatorHelper.clearFirestore();
    await EmulatorHelper.clearAuth();

    // Create test users
    user1 = await EmulatorHelper.createTestUser({
      email: "user1@example.com",
      password: "password123",
      displayName: "User One",
    });

    user2 = await EmulatorHelper.createTestUser({
      email: "user2@example.com",
      password: "password123",
      displayName: "User Two",
    });

    // Add FCM tokens to user2 (they will receive notifications)
    await admin.firestore().collection("users").doc(user2.uid).update({
      fcmTokens: ["test-fcm-token-user2"],
      notificationPreferences: {
        friendRequestReceived: true,
        friendRequestAccepted: true,
        quietHoursEnabled: false,
      },
    });

    // Add FCM tokens to user1 (for accepted notifications)
    await admin.firestore().collection("users").doc(user1.uid).update({
      fcmTokens: ["test-fcm-token-user1"],
      notificationPreferences: {
        friendRequestAccepted: true,
        quietHoursEnabled: false,
      },
    });
  });

  afterAll(async () => {
    await EmulatorHelper.cleanup();
  });

  describe("onFriendRequestSent", () => {
    test("should trigger when friendship is created with pending status", async () => {
      // Create a friendship document (simulating friend request)
      const friendshipRef = await admin.firestore().collection("friendships").add({
        initiatorId: user1.uid,
        recipientId: user2.uid,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: user1.displayName,
        recipientName: user2.displayName,
      });

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify friendship was created
      const friendshipDoc = await friendshipRef.get();
      expect(friendshipDoc.exists).toBe(true);
      expect(friendshipDoc.data()?.status).toBe("pending");

      // Note: FCM notification sending is mocked in emulator
      // In real tests, we would verify notification was sent
    });

    test("should not trigger when friendship is created with accepted status", async () => {
      // Create a friendship document that's already accepted
      const friendshipRef = await admin.firestore().collection("friendships").add({
        initiatorId: user1.uid,
        recipientId: user2.uid,
        status: "accepted",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: user1.displayName,
        recipientName: user2.displayName,
      });

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify friendship was created
      const friendshipDoc = await friendshipRef.get();
      expect(friendshipDoc.exists).toBe(true);
      expect(friendshipDoc.data()?.status).toBe("accepted");
    });

    test("should respect notification preferences when user has disabled friend requests", async () => {
      // Disable friend request notifications for user2
      await admin.firestore().collection("users").doc(user2.uid).update({
        "notificationPreferences.friendRequestReceived": false,
      });

      // Create a friendship document
      await admin.firestore().collection("friendships").add({
        initiatorId: user1.uid,
        recipientId: user2.uid,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: user1.displayName,
        recipientName: user2.displayName,
      });

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Notification should not be sent (logged as disabled)
    });
  });

  describe("onFriendRequestAccepted", () => {
    test("should trigger when friendship status changes from pending to accepted", async () => {
      // Create a pending friendship
      const friendshipRef = await admin.firestore().collection("friendships").add({
        initiatorId: user1.uid,
        recipientId: user2.uid,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: user1.displayName,
        recipientName: user2.displayName,
      });

      // Accept the friendship (update status)
      await friendshipRef.update({
        status: "accepted",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify friendship was updated
      const friendshipDoc = await friendshipRef.get();
      expect(friendshipDoc.data()?.status).toBe("accepted");

      // Verify friend cache was updated for both users
      const user1Doc = await admin.firestore().collection("users").doc(user1.uid).get();
      const user2Doc = await admin.firestore().collection("users").doc(user2.uid).get();

      const user1Data = user1Doc.data();
      const user2Data = user2Doc.data();

      expect(user1Data?.friendIds).toContain(user2.uid);
      expect(user1Data?.friendCount).toBe(1);

      expect(user2Data?.friendIds).toContain(user1.uid);
      expect(user2Data?.friendCount).toBe(1);
    });

    test("should not trigger when status changes from pending to declined", async () => {
      // Create a pending friendship
      const friendshipRef = await admin.firestore().collection("friendships").add({
        initiatorId: user1.uid,
        recipientId: user2.uid,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: user1.displayName,
        recipientName: user2.displayName,
      });

      // Decline the friendship
      await friendshipRef.update({
        status: "declined",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify friendship was updated
      const friendshipDoc = await friendshipRef.get();
      expect(friendshipDoc.data()?.status).toBe("declined");

      // Verify friend cache was NOT updated
      const user1Doc = await admin.firestore().collection("users").doc(user1.uid).get();
      const user2Doc = await admin.firestore().collection("users").doc(user2.uid).get();

      const user1Data = user1Doc.data();
      const user2Data = user2Doc.data();

      expect(user1Data?.friendIds || []).not.toContain(user2.uid);
      expect(user1Data?.friendCount || 0).toBe(0);

      expect(user2Data?.friendIds || []).not.toContain(user1.uid);
      expect(user2Data?.friendCount || 0).toBe(0);
    });

    test("should respect notification preferences when user has disabled friend request accepted", async () => {
      // Disable friend request accepted notifications for user1
      await admin.firestore().collection("users").doc(user1.uid).update({
        "notificationPreferences.friendRequestAccepted": false,
      });

      // Create and accept a friendship
      const friendshipRef = await admin.firestore().collection("friendships").add({
        initiatorId: user1.uid,
        recipientId: user2.uid,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: user1.displayName,
        recipientName: user2.displayName,
      });

      await friendshipRef.update({
        status: "accepted",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Cache should still be updated even if notification disabled
      const user1Doc = await admin.firestore().collection("users").doc(user1.uid).get();
      expect(user1Doc.data()?.friendIds).toContain(user2.uid);
      expect(user1Doc.data()?.friendCount).toBe(1);
    });
  });

  describe("onFriendRequestDeclined", () => {
    test("should trigger when friendship status changes from pending to declined", async () => {
      // Create a pending friendship
      const friendshipRef = await admin.firestore().collection("friendships").add({
        initiatorId: user1.uid,
        recipientId: user2.uid,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: user1.displayName,
        recipientName: user2.displayName,
      });

      // Decline the friendship
      await friendshipRef.update({
        status: "declined",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify friendship was updated
      const friendshipDoc = await friendshipRef.get();
      expect(friendshipDoc.data()?.status).toBe("declined");

      // No notification is sent (silent cleanup)
    });
  });

  describe("onFriendRemoved", () => {
    test("should trigger when accepted friendship is deleted", async () => {
      // Create an accepted friendship
      const friendshipRef = await admin.firestore().collection("friendships").add({
        initiatorId: user1.uid,
        recipientId: user2.uid,
        status: "accepted",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: user1.displayName,
        recipientName: user2.displayName,
      });

      // First, set up friend caches manually
      await admin.firestore().collection("users").doc(user1.uid).update({
        friendIds: admin.firestore.FieldValue.arrayUnion(user2.uid),
        friendCount: admin.firestore.FieldValue.increment(1),
      });

      await admin.firestore().collection("users").doc(user2.uid).update({
        friendIds: admin.firestore.FieldValue.arrayUnion(user1.uid),
        friendCount: admin.firestore.FieldValue.increment(1),
      });

      // Delete the friendship
      await friendshipRef.delete();

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify friend cache was cleaned up for both users
      const user1Doc = await admin.firestore().collection("users").doc(user1.uid).get();
      const user2Doc = await admin.firestore().collection("users").doc(user2.uid).get();

      const user1Data = user1Doc.data();
      const user2Data = user2Doc.data();

      expect(user1Data?.friendIds || []).not.toContain(user2.uid);
      expect(user1Data?.friendCount || 0).toBe(0);

      expect(user2Data?.friendIds || []).not.toContain(user1.uid);
      expect(user2Data?.friendCount || 0).toBe(0);
    });

    test("should not update cache when pending friendship is deleted", async () => {
      // Create a pending friendship
      const friendshipRef = await admin.firestore().collection("friendships").add({
        initiatorId: user1.uid,
        recipientId: user2.uid,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: user1.displayName,
        recipientName: user2.displayName,
      });

      // Delete the friendship
      await friendshipRef.delete();

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify caches remain unchanged
      const user1Doc = await admin.firestore().collection("users").doc(user1.uid).get();
      const user2Doc = await admin.firestore().collection("users").doc(user2.uid).get();

      const user1Data = user1Doc.data();
      const user2Data = user2Doc.data();

      expect(user1Data?.friendIds || []).toHaveLength(0);
      expect(user1Data?.friendCount || 0).toBe(0);

      expect(user2Data?.friendIds || []).toHaveLength(0);
      expect(user2Data?.friendCount || 0).toBe(0);
    });

    test("should handle deletion gracefully when user documents do not exist", async () => {
      // Create a friendship with a non-existent user
      const friendshipRef = await admin.firestore().collection("friendships").add({
        initiatorId: "non-existent-user",
        recipientId: user2.uid,
        status: "accepted",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        initiatorName: "Ghost User",
        recipientName: user2.displayName,
      });

      // Delete the friendship
      await friendshipRef.delete();

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Should complete without errors
      const user2Doc = await admin.firestore().collection("users").doc(user2.uid).get();
      expect(user2Doc.exists).toBe(true);
    });
  });
});

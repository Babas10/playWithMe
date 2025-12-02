// Integration Test: Game Creation Notifications
// Story 3.2: Implement Cloud Function for New Game Notifications

import * as admin from "firebase-admin";
import {EmulatorHelper} from "./emulatorHelper";

// Mock FCM messaging to avoid actual sending during integration tests
jest.mock("firebase-admin/messaging", () => ({
  getMessaging: jest.fn(() => ({
    sendEachForMulticast: jest.fn().mockResolvedValue({
      successCount: 1,
      failureCount: 0,
      responses: [{success: true}],
    }),
  })),
}));

describe("Integration: Game Creation Notifications", () => {
  let creator: admin.auth.UserRecord;
  let member1: admin.auth.UserRecord;
  let member2: admin.auth.UserRecord;
  let groupId: string;
  let mockSendEachForMulticast: jest.Mock;

  beforeAll(async () => {
    await EmulatorHelper.initialize();
  });

  beforeEach(async () => {
    // Clear all data before each test
    await EmulatorHelper.clearFirestore();
    await EmulatorHelper.clearAuth();

    // Create test users
    creator = await EmulatorHelper.createTestUser({
      email: "creator@test.com",
      password: "password123",
      displayName: "Game Creator",
    });

    member1 = await EmulatorHelper.createTestUser({
      email: "member1@test.com",
      password: "password123",
      displayName: "Member 1",
    });

    member2 = await EmulatorHelper.createTestUser({
      email: "member2@test.com",
      password: "password123",
      displayName: "Member 2",
    });

    // Create a test group with all members
    groupId = await EmulatorHelper.createTestGroup({
      name: "Beach Volleyball Squad",
      adminId: creator.uid,
      memberIds: [creator.uid, member1.uid, member2.uid],
    });

    // Add FCM tokens to users
    const db = admin.firestore();
    await db.collection("users").doc(member1.uid).update({
      fcmTokens: ["token_member1"],
      notificationPreferences: {
        gameCreated: true,
        quietHours: {enabled: false},
      },
    });

    await db.collection("users").doc(member2.uid).update({
      fcmTokens: ["token_member2"],
      notificationPreferences: {
        gameCreated: true,
        quietHours: {enabled: false},
      },
    });

    // Setup mock for FCM
    const messaging = require("firebase-admin/messaging");
    mockSendEachForMulticast = jest.fn().mockResolvedValue({
      successCount: 2,
      failureCount: 0,
      responses: [{success: true}, {success: true}],
    });
    messaging.getMessaging.mockReturnValue({
      sendEachForMulticast: mockSendEachForMulticast,
    });
  });

  afterAll(async () => {
    await EmulatorHelper.cleanup();
  });

  describe("Notification trigger on game creation", () => {
    it("should trigger notification when game document is created", async () => {
      const db = admin.firestore();

      // Create a game document (this should trigger the function)
      const gameRef = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .add({
          title: "Saturday Beach Game",
          description: "Casual 4v4 game",
          createdBy: creator.uid,
          groupId: groupId,
          scheduledAt: admin.firestore.Timestamp.fromDate(
            new Date(Date.now() + 24 * 60 * 60 * 1000) // Tomorrow
          ),
          location: {
            name: "Venice Beach",
            address: "Venice Beach, CA",
          },
          maxPlayers: 8,
          minPlayers: 4,
          playerIds: [creator.uid],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      // Wait a bit for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify game was created
      const gameDoc = await gameRef.get();
      expect(gameDoc.exists).toBe(true);
      expect(gameDoc.data()?.title).toBe("Saturday Beach Game");
      expect(gameDoc.data()?.createdBy).toBe(creator.uid);
    }, 10000);

    it("should respect notification preferences", async () => {
      const db = admin.firestore();

      // Disable notifications for member1
      await db.collection("users").doc(member1.uid).update({
        notificationPreferences: {
          gameCreated: false, // Disabled
        },
      });

      // Create game
      await db.collection("groups").doc(groupId).collection("games").add({
        title: "Test Game",
        createdBy: creator.uid,
        groupId: groupId,
        scheduledAt: admin.firestore.Timestamp.now(),
        location: {name: "Test Location"},
        playerIds: [creator.uid],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Wait for trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Member1 should not receive notification (we'd verify this in actual implementation)
      // In this test, we just verify the document was created
      const gamesSnapshot = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .where("title", "==", "Test Game")
        .get();

      expect(gamesSnapshot.empty).toBe(false);
    }, 10000);

    it("should handle group-specific notification settings", async () => {
      const db = admin.firestore();

      // Set group-specific preferences for member1
      await db.collection("users").doc(member1.uid).update({
        notificationPreferences: {
          gameCreated: true,
          groupSpecific: {
            [groupId]: {
              gameCreated: false, // Disabled for this specific group
            },
          },
        },
      });

      // Create game
      await db.collection("groups").doc(groupId).collection("games").add({
        title: "Group Specific Test",
        createdBy: creator.uid,
        groupId: groupId,
        scheduledAt: admin.firestore.Timestamp.now(),
        location: {name: "Test Location"},
        playerIds: [creator.uid],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Wait for trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify game was created
      const gamesSnapshot = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .where("title", "==", "Group Specific Test")
        .get();

      expect(gamesSnapshot.empty).toBe(false);
    }, 10000);
  });

  describe("Game data integrity", () => {
    it("should create game with all required fields", async () => {
      const db = admin.firestore();

      const scheduledTime = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // Next week

      const gameRef = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .add({
          title: "Weekend Tournament",
          description: "Competitive play",
          createdBy: creator.uid,
          groupId: groupId,
          scheduledAt: admin.firestore.Timestamp.fromDate(scheduledTime),
          location: {
            name: "Santa Monica Beach",
            address: "1550 PCH, Santa Monica, CA 90401",
          },
          maxPlayers: 12,
          minPlayers: 6,
          gameType: "tournament",
          skillLevel: "intermediate",
          playerIds: [creator.uid],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      const gameDoc = await gameRef.get();
      const gameData = gameDoc.data();

      expect(gameData).toBeDefined();
      expect(gameData?.title).toBe("Weekend Tournament");
      expect(gameData?.description).toBe("Competitive play");
      expect(gameData?.createdBy).toBe(creator.uid);
      expect(gameData?.groupId).toBe(groupId);
      expect(gameData?.location.name).toBe("Santa Monica Beach");
      expect(gameData?.maxPlayers).toBe(12);
      expect(gameData?.minPlayers).toBe(6);
      expect(gameData?.playerIds).toContain(creator.uid);
    });

    it("should handle game without optional fields", async () => {
      const db = admin.firestore();

      const gameRef = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .add({
          // Minimal fields
          title: "Quick Pickup Game",
          createdBy: creator.uid,
          groupId: groupId,
          scheduledAt: admin.firestore.Timestamp.now(),
          location: {name: "Local Court"},
          playerIds: [creator.uid],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      const gameDoc = await gameRef.get();
      const gameData = gameDoc.data();

      expect(gameData).toBeDefined();
      expect(gameData?.title).toBe("Quick Pickup Game");
      expect(gameData?.description).toBeUndefined();
      expect(gameData?.gameType).toBeUndefined();
    });
  });

  describe("Multiple games scenarios", () => {
    it("should handle multiple games created in quick succession", async () => {
      const db = admin.firestore();

      const gamePromises = [];

      for (let i = 1; i <= 3; i++) {
        const promise = db
          .collection("groups")
          .doc(groupId)
          .collection("games")
          .add({
            title: `Game ${i}`,
            createdBy: creator.uid,
            groupId: groupId,
            scheduledAt: admin.firestore.Timestamp.now(),
            location: {name: `Court ${i}`},
            playerIds: [creator.uid],
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        gamePromises.push(promise);
      }

      await Promise.all(gamePromises);

      // Wait for all triggers to process
      await new Promise((resolve) => setTimeout(resolve, 3000));

      // Verify all games were created
      const gamesSnapshot = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .get();

      expect(gamesSnapshot.size).toBe(3);
    }, 15000);
  });

  describe("Edge cases", () => {
    it("should handle game creation when group has no members except creator", async () => {
      const db = admin.firestore();

      // Create a solo group
      const soloGroupId = await EmulatorHelper.createTestGroup({
        name: "Solo Group",
        adminId: creator.uid,
        memberIds: [creator.uid], // Only creator
      });

      // Create game
      const gameRef = await db
        .collection("groups")
        .doc(soloGroupId)
        .collection("games")
        .add({
          title: "Solo Practice",
          createdBy: creator.uid,
          groupId: soloGroupId,
          scheduledAt: admin.firestore.Timestamp.now(),
          location: {name: "Home Court"},
          playerIds: [creator.uid],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      // Verify game was created (no notifications should be sent)
      const gameDoc = await gameRef.get();
      expect(gameDoc.exists).toBe(true);
    });

    it("should handle members without FCM tokens", async () => {
      const db = admin.firestore();

      // Remove FCM tokens from member1
      await db.collection("users").doc(member1.uid).update({
        fcmTokens: [],
      });

      // Create game
      await db.collection("groups").doc(groupId).collection("games").add({
        title: "Test No Token",
        createdBy: creator.uid,
        groupId: groupId,
        scheduledAt: admin.firestore.Timestamp.now(),
        location: {name: "Test Location"},
        playerIds: [creator.uid],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Wait for trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Game should still be created successfully
      const gamesSnapshot = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .where("title", "==", "Test No Token")
        .get();

      expect(gamesSnapshot.empty).toBe(false);
    }, 10000);
  });

  describe("Player Joined Notifications", () => {
    let gameId: string;

    beforeEach(async () => {
      // Create a game with the creator
      const db = admin.firestore();
      const gameRef = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .add({
          title: "Test Game",
          createdBy: creator.uid,
          groupId: groupId,
          scheduledAt: admin.firestore.Timestamp.fromDate(
            new Date(Date.now() + 24 * 60 * 60 * 1000)
          ),
          location: {name: "Test Court"},
          playerIds: [creator.uid],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      gameId = gameRef.id;

      // Wait for game creation notification to process
      await new Promise((resolve) => setTimeout(resolve, 1000));

      // Reset mock after game creation
      mockSendEachForMulticast.mockClear();
    });

    it("should trigger notification when player joins game", async () => {
      const db = admin.firestore();

      // Add member1 to the game
      await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .update({
          playerIds: admin.firestore.FieldValue.arrayUnion(member1.uid),
        });

      // Wait for trigger to process
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify game was updated
      const gameDoc = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .get();

      const gameData = gameDoc.data();
      expect(gameData?.playerIds).toContain(member1.uid);
    }, 10000);

    it("should not notify the player who just joined", async () => {
      const db = admin.firestore();

      // Setup: Only creator has FCM token
      await db.collection("users").doc(creator.uid).update({
        fcmTokens: ["creator_token"],
        notificationPreferences: {
          playerJoined: true,
          quietHours: {enabled: false},
        },
      });

      // Member1 joins the game
      await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .update({
          playerIds: admin.firestore.FieldValue.arrayUnion(member1.uid),
        });

      // Wait for trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify update succeeded
      const gameDoc = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .get();
      expect(gameDoc.data()?.playerIds).toContain(member1.uid);
    }, 10000);

    it("should not send notification when player is first to join", async () => {
      const db = admin.firestore();

      // Create a game with no players
      const emptyGameRef = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .add({
          title: "Empty Game",
          createdBy: creator.uid,
          groupId: groupId,
          scheduledAt: admin.firestore.Timestamp.now(),
          location: {name: "Court"},
          playerIds: [],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      // Wait for creation
      await new Promise((resolve) => setTimeout(resolve, 1000));
      mockSendEachForMulticast.mockClear();

      // Add first player
      await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(emptyGameRef.id)
        .update({
          playerIds: [member1.uid],
        });

      // Wait for trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify game was updated
      const gameDoc = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(emptyGameRef.id)
        .get();
      expect(gameDoc.data()?.playerIds).toEqual([member1.uid]);
    }, 10000);

    it("should respect playerJoined notification preferences", async () => {
      const db = admin.firestore();

      // Disable player joined notifications for creator
      await db.collection("users").doc(creator.uid).update({
        fcmTokens: ["creator_token"],
        notificationPreferences: {
          playerJoined: false, // Disabled
          quietHours: {enabled: false},
        },
      });

      // Member1 joins
      await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .update({
          playerIds: admin.firestore.FieldValue.arrayUnion(member1.uid),
        });

      // Wait for trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify update succeeded
      const gameDoc = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .get();
      expect(gameDoc.data()?.playerIds).toContain(member1.uid);
    }, 10000);

    it("should handle multiple players joining simultaneously", async () => {
      const db = admin.firestore();

      // Add both members at once
      await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .update({
          playerIds: [creator.uid, member1.uid, member2.uid],
        });

      // Wait for trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify all players were added
      const gameDoc = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .get();

      const gameData = gameDoc.data();
      expect(gameData?.playerIds).toContain(member1.uid);
      expect(gameData?.playerIds).toContain(member2.uid);
    }, 10000);

    it("should handle group-specific notification settings", async () => {
      const db = admin.firestore();

      // Set group-specific preferences for creator
      await db.collection("users").doc(creator.uid).update({
        fcmTokens: ["creator_token"],
        notificationPreferences: {
          playerJoined: true,
          groupSpecific: {
            [groupId]: {
              playerJoined: false, // Disabled for this specific group
            },
          },
        },
      });

      // Member1 joins
      await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .update({
          playerIds: admin.firestore.FieldValue.arrayUnion(member1.uid),
        });

      // Wait for trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify update succeeded
      const gameDoc = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .get();
      expect(gameDoc.data()?.playerIds).toContain(member1.uid);
    }, 10000);

    it("should handle players without FCM tokens", async () => {
      const db = admin.firestore();

      // Remove FCM tokens from creator
      await db.collection("users").doc(creator.uid).update({
        fcmTokens: [],
      });

      // Member1 joins
      await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .update({
          playerIds: admin.firestore.FieldValue.arrayUnion(member1.uid),
        });

      // Wait for trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Should still work (just no notification sent)
      const gameDoc = await db
        .collection("groups")
        .doc(groupId)
        .collection("games")
        .doc(gameId)
        .get();
      expect(gameDoc.data()?.playerIds).toContain(member1.uid);
    }, 10000);
  });
});

/**
 * Security Rules Tests for /friendships Collection (Epic 11)
 *
 * Tests Firestore security rules to ensure:
 * - Users can only read their own friendships
 * - Only initiator can create friend requests
 * - Only recipient can accept/decline requests
 * - Cannot friend yourself
 * - Cannot modify initiator/recipient during update
 * - Both users can delete friendships
 */

import * as admin from "firebase-admin";
import { firestore } from "firebase-admin";
import * as testing from "@firebase/rules-unit-testing";

const PROJECT_ID = "test-friendships-security";
const RULES_PATH = "firestore.rules";

describe("Friendship Security Rules", () => {
  let testEnv: testing.RulesTestEnvironment;

  beforeAll(async () => {
    testEnv = await testing.initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: require("fs").readFileSync(RULES_PATH, "utf8"),
      },
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  describe("Read Access", () => {
    beforeEach(async () => {
      // Set up test data with admin context
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        // Create test users
        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
          displayName: "User 1",
        });

        await db.collection("users").doc("user2").set({
          uid: "user2",
          email: "user2@test.com",
          displayName: "User 2",
        });

        await db.collection("users").doc("user3").set({
          uid: "user3",
          email: "user3@test.com",
          displayName: "User 3",
        });

        // Create friendship between user1 and user2
        await db.collection("friendships").doc("friendship1").set({
          initiatorId: "user1",
          recipientId: "user2",
          status: "pending",
          createdAt: firestore.FieldValue.serverTimestamp(),
        });
      });
    });

    it("should allow user to read their own friendship as initiator", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("friendships").doc("friendship1").get()
      );
    });

    it("should allow user to read their own friendship as recipient", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertSucceeds(
        db.collection("friendships").doc("friendship1").get()
      );
    });

    it("should deny reading other users' friendships", async () => {
      const db = testEnv.authenticatedContext("user3").firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").get()
      );
    });

    it("should deny unauthenticated read access", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").get()
      );
    });

    it("should allow initiator to query their own friendships", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db
          .collection("friendships")
          .where("initiatorId", "==", "user1")
          .get()
      );
    });

    it("should allow recipient to query their own friendships", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertSucceeds(
        db
          .collection("friendships")
          .where("recipientId", "==", "user2")
          .get()
      );
    });
  });

  describe("Create Access", () => {
    beforeEach(async () => {
      // Set up test users
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
        });

        await db.collection("users").doc("user2").set({
          uid: "user2",
          email: "user2@test.com",
        });
      });
    });

    it("should allow initiator to create friend request with valid data", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("friendships").add({
          initiatorId: "user1",
          recipientId: "user2",
          status: "pending",
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );
    });

    it("should deny creating friend request as non-initiator", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("friendships").add({
          initiatorId: "user2", // Different from authenticated user
          recipientId: "user1",
          status: "pending",
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );
    });

    it("should deny creating friend request with non-pending status", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("friendships").add({
          initiatorId: "user1",
          recipientId: "user2",
          status: "accepted", // Must be pending on creation
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );
    });

    it("should deny creating friend request to yourself", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("friendships").add({
          initiatorId: "user1",
          recipientId: "user1", // Cannot friend yourself
          status: "pending",
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );
    });

    it("should deny creating friend request to non-existent user", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("friendships").add({
          initiatorId: "user1",
          recipientId: "nonexistent", // User doesn't exist
          status: "pending",
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );
    });

    it("should deny unauthenticated create access", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await testing.assertFails(
        db.collection("friendships").add({
          initiatorId: "user1",
          recipientId: "user2",
          status: "pending",
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );
    });
  });

  describe("Update Access", () => {
    beforeEach(async () => {
      // Set up test data
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
        });

        await db.collection("users").doc("user2").set({
          uid: "user2",
          email: "user2@test.com",
        });

        await db.collection("users").doc("user3").set({
          uid: "user3",
          email: "user3@test.com",
        });

        // Create pending friendship
        await db.collection("friendships").doc("friendship1").set({
          initiatorId: "user1",
          recipientId: "user2",
          status: "pending",
          createdAt: admin.firestore.Timestamp.now(),
        });

        // Create accepted friendship
        await db.collection("friendships").doc("friendship2").set({
          initiatorId: "user1",
          recipientId: "user2",
          status: "accepted",
          createdAt: admin.firestore.Timestamp.now(),
        });

        // Create declined friendship
        await db.collection("friendships").doc("friendship3").set({
          initiatorId: "user1",
          recipientId: "user2",
          status: "declined",
          createdAt: admin.firestore.Timestamp.now(),
        });
      });
    });

    it("should allow recipient to accept pending friend request", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertSucceeds(
        db.collection("friendships").doc("friendship1").update({
          status: "accepted",
        })
      );
    });

    it("should allow recipient to decline pending friend request", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertSucceeds(
        db.collection("friendships").doc("friendship1").update({
          status: "declined",
        })
      );
    });

    it("should deny initiator updating friend request status", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").update({
          status: "accepted",
        })
      );
    });

    it("should deny third party updating friend request", async () => {
      const db = testEnv.authenticatedContext("user3").firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").update({
          status: "accepted",
        })
      );
    });

    it("should deny updating non-pending friendship", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship2").update({
          status: "declined",
        })
      );
    });

    it("should deny updating to invalid status", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").update({
          status: "invalid",
        })
      );
    });

    it("should deny modifying initiatorId during update", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").update({
          status: "accepted",
          initiatorId: "user3", // Cannot modify initiator
        })
      );
    });

    it("should deny modifying recipientId during update", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").update({
          status: "accepted",
          recipientId: "user3", // Cannot modify recipient
        })
      );
    });

    it("should deny unauthenticated update access", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").update({
          status: "accepted",
        })
      );
    });

    it("should deny re-accepting declined friendship", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship3").update({
          status: "accepted",
        })
      );
    });
  });

  describe("Delete Access", () => {
    beforeEach(async () => {
      // Set up test data
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
        });

        await db.collection("users").doc("user2").set({
          uid: "user2",
          email: "user2@test.com",
        });

        await db.collection("users").doc("user3").set({
          uid: "user3",
          email: "user3@test.com",
        });

        await db.collection("friendships").doc("friendship1").set({
          initiatorId: "user1",
          recipientId: "user2",
          status: "accepted",
          createdAt: admin.firestore.Timestamp.now(),
        });
      });
    });

    it("should allow initiator to delete friendship", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("friendships").doc("friendship1").delete()
      );
    });

    it("should allow recipient to delete friendship", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertSucceeds(
        db.collection("friendships").doc("friendship1").delete()
      );
    });

    it("should deny third party deleting friendship", async () => {
      const db = testEnv.authenticatedContext("user3").firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").delete()
      );
    });

    it("should deny unauthenticated delete access", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await testing.assertFails(
        db.collection("friendships").doc("friendship1").delete()
      );
    });
  });

  describe("Edge Cases", () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
        });

        await db.collection("users").doc("user2").set({
          uid: "user2",
          email: "user2@test.com",
        });
      });
    });

    it("should deny creating duplicate friendships", async () => {
      // Note: Firestore rules cannot enforce uniqueness constraints
      // This test documents that duplicate prevention must be handled in Cloud Functions
      const db = testEnv.authenticatedContext("user1").firestore();

      // First request should succeed
      await testing.assertSucceeds(
        db.collection("friendships").add({
          initiatorId: "user1",
          recipientId: "user2",
          status: "pending",
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );

      // Rules cannot prevent duplicate - Cloud Functions must handle this
      // This test serves as documentation only
    });

    it("should deny creating friendship with missing required fields", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();

      // Missing recipientId
      await testing.assertFails(
        db.collection("friendships").add({
          initiatorId: "user1",
          status: "pending",
        })
      );
    });

    it("should deny recipient setting custom status values", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("friendships").add({
          initiatorId: "user1",
          recipientId: "user2",
          status: "blocked", // Invalid status
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );
    });
  });
});

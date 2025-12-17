/**
 * Security Rules Tests for /users Collection
 *
 * Tests Firestore security rules to ensure:
 * - Users can only read/write their own documents
 * - friendIds and friendCount cannot be modified directly (managed by triggers)
 * - Core fields (uid, email, createdAt) cannot be modified
 * - Notification preferences can be updated
 */

import * as admin from "firebase-admin";
import { firestore } from "firebase-admin";
import * as testing from "@firebase/rules-unit-testing";

const PROJECT_ID = "test-users-security";
const RULES_PATH = "firestore.rules";

describe("User Security Rules", () => {
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
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
          displayName: "User 1",
          createdAt: admin.firestore.Timestamp.now(),
          friendIds: [],
          friendCount: 0,
        });

        await db.collection("users").doc("user2").set({
          uid: "user2",
          email: "user2@test.com",
          displayName: "User 2",
          createdAt: admin.firestore.Timestamp.now(),
          friendIds: [],
          friendCount: 0,
        });
      });
    });

    it("should allow user to read their own document", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(db.collection("users").doc("user1").get());
    });

    it("should deny reading other users' documents", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(db.collection("users").doc("user2").get());
    });

    it("should deny unauthenticated read access", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await testing.assertFails(db.collection("users").doc("user1").get());
    });

    // Story 11.7: Cloud Function-First Architecture
    // List queries are DENIED - clients must use searchUsers() Cloud Function
    it("should DENY querying users by email (must use Cloud Function)", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").where("email", "==", "user2@test.com").get()
      );
    });

    it("should DENY querying users by displayName (must use Cloud Function)", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").where("displayName", "==", "User 2").get()
      );
    });

    it("should DENY any list/collection query on users", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(db.collection("users").get());
    });
  });

  describe("Create Access", () => {
    it("should allow authenticated user to create their own document", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
          displayName: "User 1",
          createdAt: firestore.FieldValue.serverTimestamp(),
          friendIds: [],
          friendCount: 0,
        })
      );
    });

    it("should deny creating another user's document", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").doc("user2").set({
          uid: "user2",
          email: "user2@test.com",
          displayName: "User 2",
          createdAt: firestore.FieldValue.serverTimestamp(),
          friendIds: [],
          friendCount: 0,
        })
      );
    });

    it("should deny unauthenticated create access", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
          displayName: "User 1",
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );
    });
  });

  describe("Update Access - Allowed Fields", () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
          displayName: "User 1",
          photoUrl: null,
          createdAt: admin.firestore.Timestamp.now(),
          friendIds: [],
          friendCount: 0,
          notificationPreferences: {
            groupInvitations: true,
            friendRequestReceived: true,
          },
        });
      });
    });

    it("should allow updating displayName", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("users").doc("user1").update({
          displayName: "Updated Name",
        })
      );
    });

    it("should allow updating photoUrl", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("users").doc("user1").update({
          photoUrl: "https://example.com/photo.jpg",
        })
      );
    });

    it("should allow updating notification preferences", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("users").doc("user1").update({
          notificationPreferences: {
            groupInvitations: false,
            friendRequestReceived: true,
          },
        })
      );
    });

    it("should allow updating multiple allowed fields at once", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("users").doc("user1").update({
          displayName: "New Name",
          photoUrl: "https://example.com/new.jpg",
        })
      );
    });
  });

  describe("Update Access - Protected Fields (Epic 11)", () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
          displayName: "User 1",
          createdAt: admin.firestore.Timestamp.now(),
          friendIds: ["user2"],
          friendCount: 1,
        });
      });
    });

    it("should deny directly updating friendIds", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").update({
          friendIds: ["user2", "user3"], // Managed by Cloud Functions
        })
      );
    });

    it("should deny directly updating friendCount", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").update({
          friendCount: 2, // Managed by Cloud Functions
        })
      );
    });

    it("should deny updating friendIds even with other valid fields", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").update({
          displayName: "New Name",
          friendIds: ["user3"], // Mixed update should fail
        })
      );
    });

    it("should deny updating friendCount even with other valid fields", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").update({
          displayName: "New Name",
          friendCount: 5, // Mixed update should fail
        })
      );
    });
  });

  describe("Update Access - Core Protected Fields", () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
          displayName: "User 1",
          createdAt: admin.firestore.Timestamp.now(),
          friendIds: [],
          friendCount: 0,
        });
      });
    });

    it("should deny updating uid", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").update({
          uid: "hacked",
        })
      );
    });

    it("should deny updating email", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").update({
          email: "hacked@test.com",
        })
      );
    });

    it("should deny updating createdAt", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").update({
          createdAt: firestore.FieldValue.serverTimestamp(),
        })
      );
    });

    it("should deny updating other user's document", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").update({
          displayName: "Hacked",
        })
      );
    });

    it("should deny unauthenticated update access", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await testing.assertFails(
        db.collection("users").doc("user1").update({
          displayName: "Hacked",
        })
      );
    });
  });

  describe("FCM Token Management", () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
          displayName: "User 1",
          createdAt: admin.firestore.Timestamp.now(),
          fcmTokens: [],
        });
      });
    });

    it("should allow updating fcmTokens array", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("users").doc("user1").update({
          fcmTokens: firestore.FieldValue.arrayUnion("new-token"),
        })
      );
    });

    it("should allow removing fcmTokens", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db.collection("users").doc("user1").update({
          fcmTokens: firestore.FieldValue.arrayRemove("old-token"),
        })
      );
    });
  });

  describe("Preferences Subcollection", () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await db.collection("users").doc("user1").set({
          uid: "user1",
          email: "user1@test.com",
        });

        await db
          .collection("users")
          .doc("user1")
          .collection("preferences")
          .doc("locale")
          .set({
            language: "en",
            country: "US",
          });
      });
    });

    it("should allow user to read their own preferences", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db
          .collection("users")
          .doc("user1")
          .collection("preferences")
          .doc("locale")
          .get()
      );
    });

    it("should allow user to write their own preferences", async () => {
      const db = testEnv.authenticatedContext("user1").firestore();
      await testing.assertSucceeds(
        db
          .collection("users")
          .doc("user1")
          .collection("preferences")
          .doc("locale")
          .set({
            language: "fr",
            country: "FR",
          })
      );
    });

    it("should deny reading other users' preferences", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertFails(
        db
          .collection("users")
          .doc("user1")
          .collection("preferences")
          .doc("locale")
          .get()
      );
    });

    it("should deny writing other users' preferences", async () => {
      const db = testEnv.authenticatedContext("user2").firestore();
      await testing.assertFails(
        db
          .collection("users")
          .doc("user1")
          .collection("preferences")
          .doc("locale")
          .set({
            language: "hacked",
          })
      );
    });
  });
});

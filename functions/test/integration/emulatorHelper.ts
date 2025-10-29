// Firebase Emulator test helper for integration tests
import * as admin from "firebase-admin";
import * as functions from "firebase-functions-test";

// Emulator configuration
const FIRESTORE_EMULATOR_HOST = "localhost:8080";
const AUTH_EMULATOR_HOST = "localhost:9099";

export class EmulatorHelper {
  private static testEnv: ReturnType<typeof functions> | null = null;
  private static isInitialized = false;

  /**
   * Initialize Firebase Admin SDK with emulator configuration
   */
  static async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    // Set emulator environment variables
    process.env.FIRESTORE_EMULATOR_HOST = FIRESTORE_EMULATOR_HOST;
    process.env.FIREBASE_AUTH_EMULATOR_HOST = AUTH_EMULATOR_HOST;

    // Initialize Firebase Admin SDK
    if (!admin.apps.length) {
      admin.initializeApp({
        projectId: "playwithme-dev",
      });
    }

    // Initialize firebase-functions-test
    this.testEnv = functions({
      projectId: "playwithme-dev",
    });

    this.isInitialized = true;
  }

  /**
   * Clear all Firestore data
   */
  static async clearFirestore(): Promise<void> {
    const db = admin.firestore();

    // Delete all collections
    const collections = ["users", "groups"];

    for (const collectionName of collections) {
      const snapshot = await db.collection(collectionName).get();

      const batch = db.batch();
      let batchCount = 0;

      for (const doc of snapshot.docs) {
        // Delete subcollections first
        const invitationsSnapshot = await doc.ref.collection("invitations").get();
        for (const invDoc of invitationsSnapshot.docs) {
          batch.delete(invDoc.ref);
          batchCount++;

          if (batchCount >= 500) {
            await batch.commit();
            batchCount = 0;
          }
        }

        batch.delete(doc.ref);
        batchCount++;

        if (batchCount >= 500) {
          await batch.commit();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }
    }
  }

  /**
   * Clear all Auth users
   */
  static async clearAuth(): Promise<void> {
    const auth = admin.auth();

    try {
      const listUsersResult = await auth.listUsers();

      for (const user of listUsersResult.users) {
        await auth.deleteUser(user.uid);
      }
    } catch (error) {
      // Ignore errors if no users exist
      console.log("No auth users to clear");
    }
  }

  /**
   * Create a test user with both Auth and Firestore profile
   */
  static async createTestUser(data: {
    email: string;
    password: string;
    displayName: string;
    uid?: string;
  }): Promise<admin.auth.UserRecord> {
    const auth = admin.auth();
    const db = admin.firestore();

    // Create Auth user
    const userRecord = await auth.createUser({
      uid: data.uid,
      email: data.email,
      password: data.password,
      displayName: data.displayName,
      emailVerified: true,
    });

    // Create Firestore profile
    await db.collection("users").doc(userRecord.uid).set({
      email: data.email,
      displayName: data.displayName,
      photoUrl: null,
      isEmailVerified: true,
      isAnonymous: false,
      groupIds: [],
      gamesPlayed: 0,
      gamesWon: 0,
      totalScore: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return userRecord;
  }

  /**
   * Create a test group
   */
  static async createTestGroup(data: {
    name: string;
    adminId: string;
    memberIds?: string[];
  }): Promise<string> {
    const db = admin.firestore();

    const groupRef = await db.collection("groups").add({
      name: data.name,
      description: "",
      adminId: data.adminId,
      memberIds: data.memberIds || [data.adminId],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastActivity: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Add group to admin's groupIds
    await db.collection("users").doc(data.adminId).update({
      groupIds: admin.firestore.FieldValue.arrayUnion(groupRef.id),
    });

    return groupRef.id;
  }

  /**
   * Create a test invitation
   */
  static async createTestInvitation(data: {
    groupId: string;
    groupName: string;
    invitedUserId: string;
    invitedBy: string;
    status?: "pending" | "accepted" | "declined";
  }): Promise<string> {
    const db = admin.firestore();

    const invitationRef = await db
      .collection("users")
      .doc(data.invitedUserId)
      .collection("invitations")
      .add({
        groupId: data.groupId,
        groupName: data.groupName,
        invitedBy: data.invitedBy,
        invitedUserId: data.invitedUserId,
        status: data.status || "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return invitationRef.id;
  }

  /**
   * Get custom token for authentication
   */
  static async getCustomToken(uid: string): Promise<string> {
    const auth = admin.auth();
    return await auth.createCustomToken(uid);
  }

  /**
   * Cleanup and shutdown
   */
  static async cleanup(): Promise<void> {
    if (this.testEnv) {
      this.testEnv.cleanup();
      this.testEnv = null;
    }

    // Clear environment variables
    delete process.env.FIRESTORE_EMULATOR_HOST;
    delete process.env.FIREBASE_AUTH_EMULATOR_HOST;

    this.isInitialized = false;
  }
}

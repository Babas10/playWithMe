/**
 * Production Environment Cleanup Script
 *
 * This script:
 * 1. Deletes all documents from every Firestore collection in gatherli-prod
 * 2. Deletes all Firebase Auth users in gatherli-prod
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/clearProdEnvironment.ts
 *
 * ⚠️  WARNING: This will PERMANENTLY DELETE ALL DATA in the PRODUCTION environment!
 * ⚠️  This action is IRREVERSIBLE. Use only for testing with real users' consent.
 */

import * as admin from "firebase-admin";
import * as readline from "readline";

// Initialize Firebase Admin SDK — PRODUCTION ONLY
admin.initializeApp({
  projectId: "gatherli-prod",
});

const db = admin.firestore();
const auth = admin.auth();

// All top-level collections to delete
const COLLECTIONS = [
  "users",
  "groups",
  "games",
  "friendships",
  "invitations",
  "notifications",
  "trainingSessions",
  "operations",
  "groupInvites",
];

/**
 * Delete all documents in a collection (handles pagination for large sets)
 */
async function deleteCollection(collectionPath: string): Promise<number> {
  const collectionRef = db.collection(collectionPath);
  const batchSize = 500;
  let deletedCount = 0;

  const query = collectionRef.limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(query, resolve, reject);
  });

  async function deleteQueryBatch(
    query: FirebaseFirestore.Query,
    resolve: (value: number) => void,
    reject: (error: Error) => void
  ) {
    let snapshot;
    try {
      snapshot = await query.get();
    } catch (e) {
      // Collection doesn't exist or is empty — not an error
      resolve(deletedCount);
      return;
    }

    if (snapshot.size === 0) {
      resolve(deletedCount);
      return;
    }

    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    deletedCount += snapshot.size;

    process.nextTick(() => {
      deleteQueryBatch(query, resolve, reject);
    });
  }
}

/**
 * Delete all known subcollections under each user document
 */
async function deleteUserSubcollections(): Promise<void> {
  console.log("  🔍 Finding user subcollections...");
  const usersSnapshot = await db.collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    const h2hCount = await deleteCollection(`users/${userDoc.id}/headToHead`);
    if (h2hCount > 0) {
      console.log(`    ✅ Deleted ${h2hCount} head-to-head records for ${userDoc.id}`);
    }

    const ratingCount = await deleteCollection(`users/${userDoc.id}/ratingHistory`);
    if (ratingCount > 0) {
      console.log(`    ✅ Deleted ${ratingCount} rating history entries for ${userDoc.id}`);
    }
  }
}

/**
 * Clear all Firestore collections
 */
async function clearDatabase(): Promise<void> {
  console.log("\n🗑️  CLEARING FIRESTORE DATABASE\n");
  console.log("=".repeat(50));

  // Delete user subcollections first (must be done before deleting user docs)
  await deleteUserSubcollections();

  for (const collection of COLLECTIONS) {
    const count = await deleteCollection(collection);
    console.log(`  ✅ Deleted ${count} documents from '${collection}'`);
  }

  console.log("\n✅ Firestore cleared successfully!");
}

/**
 * Delete all Firebase Auth users
 */
async function clearAuthUsers(): Promise<void> {
  console.log("\n🗑️  CLEARING FIREBASE AUTH USERS\n");
  console.log("=".repeat(50));

  let deletedCount = 0;

  const listAllUsers = async (nextPageToken?: string): Promise<void> => {
    const listUsersResult = await auth.listUsers(1000, nextPageToken);

    for (const userRecord of listUsersResult.users) {
      try {
        await auth.deleteUser(userRecord.uid);
        deletedCount++;
      } catch (error) {
        console.warn(`  ⚠️  Failed to delete auth user ${userRecord.uid}:`, error);
      }
    }

    if (listUsersResult.pageToken) {
      await listAllUsers(listUsersResult.pageToken);
    }
  };

  await listAllUsers();
  console.log(`\n  ✅ Deleted ${deletedCount} auth users`);
}

/**
 * Prompt user for confirmation before proceeding
 */
async function confirm(question: string): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

/**
 * Main function
 */
async function clearProdEnvironment(): Promise<void> {
  console.log("\n");
  console.log("=".repeat(70));
  console.log("🚨  GATHERLI PRODUCTION ENVIRONMENT CLEANUP");
  console.log("=".repeat(70));
  console.log("\n⚠️  WARNING: You are about to PERMANENTLY DELETE ALL DATA in gatherli-prod!");
  console.log("⚠️  This includes ALL users, groups, games, friendships, and notifications.");
  console.log("⚠️  This action is IRREVERSIBLE.\n");

  const answer = await confirm('Type "DELETE PROD" to confirm, or anything else to abort: ');

  if (answer !== "DELETE PROD") {
    console.log("\n❌ Aborted. No data was deleted.\n");
    process.exit(0);
  }

  const startTime = Date.now();
  console.log("\n🚀 Starting cleanup...");

  try {
    await clearDatabase();
    await clearAuthUsers();

    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log("\n");
    console.log("=".repeat(70));
    console.log("✅  PRODUCTION ENVIRONMENT CLEARED");
    console.log("=".repeat(70));
    console.log(`\n  Total time: ${duration} seconds`);
    console.log("  All Firestore collections deleted");
    console.log("  All Firebase Auth users deleted\n");
  } catch (error) {
    console.error("\n❌ ERROR during cleanup:", error);
    throw error;
  }
}

// Safety guard — refuse to run against anything other than gatherli-prod
const projectId = admin.app().options.projectId;
if (projectId !== "gatherli-prod") {
  console.error("❌ ERROR: This script can only run on gatherli-prod!");
  console.error(`   Current project: ${projectId}`);
  process.exit(1);
}

clearProdEnvironment()
  .then(() => {
    console.log("✅ Script completed successfully");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Script failed:", error);
    process.exit(1);
  });

/**
 * Cleanup All Data
 *
 * Deletes all users, groups, games, and other data from Firestore and Firebase Auth.
 * Does NOT recreate anything - leaves the database completely empty.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/cleanupAll.ts
 */

import * as admin from "firebase-admin";

admin.initializeApp({
  projectId: "playwithme-dev",
});

const db = admin.firestore();

/**
 * Clear all Firestore collections
 */
async function clearFirestore() {
  console.log("\n🗑️  CLEARING FIRESTORE DATABASE\n");
  console.log("=".repeat(50));

  const collections = [
    "users",
    "groups",
    "games",
    "friendships",
    "invitations",
    "notifications",
  ];

  for (const collectionName of collections) {
    const snapshot = await db.collection(collectionName).get();

    // Delete user subcollections first
    if (collectionName === "users") {
      console.log("🔍 Finding user subcollections...");
      for (const userDoc of snapshot.docs) {
        // Delete headToHead subcollection
        const headToHeadSnapshot = await userDoc.ref
          .collection("headToHead")
          .get();
        if (!headToHeadSnapshot.empty) {
          const h2hBatch = db.batch();
          headToHeadSnapshot.docs.forEach((doc) => {
            h2hBatch.delete(doc.ref);
          });
          await h2hBatch.commit();
          console.log(
            `  ✅ Deleted ${headToHeadSnapshot.size} head-to-head records for user ${userDoc.id}`
          );
        }

        // Delete ratingHistory subcollection
        const ratingHistorySnapshot = await userDoc.ref
          .collection("ratingHistory")
          .get();
        if (!ratingHistorySnapshot.empty) {
          const rhBatch = db.batch();
          ratingHistorySnapshot.docs.forEach((doc) => {
            rhBatch.delete(doc.ref);
          });
          await rhBatch.commit();
          console.log(
            `  ✅ Deleted ${ratingHistorySnapshot.size} rating history records for user ${userDoc.id}`
          );
        }
      }
    }

    // Delete main collection documents
    if (!snapshot.empty) {
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`✅ Deleted ${snapshot.size} documents from '${collectionName}'`);
    } else {
      console.log(`✅ No documents to delete from '${collectionName}'`);
    }
  }

  console.log("\n✅ Database cleared successfully!\n");
}

/**
 * Clear all Firebase Auth users
 */
async function clearAuthUsers() {
  console.log("\n🗑️  CLEARING FIREBASE AUTH USERS\n");
  console.log("=".repeat(50));

  const listUsersResult = await admin.auth().listUsers();
  const uids = listUsersResult.users.map((user) => user.uid);

  if (uids.length > 0) {
    await admin.auth().deleteUsers(uids);
    console.log(`✅ Deleted ${uids.length} auth users`);
  } else {
    console.log("✅ No auth users to delete");
  }

  console.log();
}

/**
 * Main execution
 */
async function main() {
  const startTime = Date.now();

  console.log("=".repeat(70));
  console.log("🗑️  PLAYWITHME - DELETE ALL DATA");
  console.log("=".repeat(70));
  console.log("\n⚠️  WARNING: This will DELETE ALL DATA in the dev environment!\n");

  try {
    // Clear all data
    await clearFirestore();
    await clearAuthUsers();

    const duration = ((Date.now() - startTime) / 1000).toFixed(2);

    console.log("\n");
    console.log("=".repeat(70));
    console.log("🎉 CLEANUP COMPLETE!");
    console.log("=".repeat(70));
    console.log(`\n✅ Total time: ${duration} seconds\n`);
    console.log("Summary:");
    console.log(`  • All Firestore collections deleted`);
    console.log(`  • All Firebase Auth users deleted`);
    console.log(`  • Database is now completely empty\n`);
    console.log("✅ You can now create users manually through the app\n");
  } catch (error) {
    console.error("\n❌ Error:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err);
    process.exit(1);
  });

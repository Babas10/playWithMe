/**
 * Example Script - Template for Creating New Test Scripts
 *
 * This script demonstrates how to use testConfigLoader to access test user IDs
 * without hardcoding them.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/exampleScript.ts
 */

import * as admin from "firebase-admin";
import {
  getTestUser,
  getTestGroupId,
  getAllTestUserIds,
  printTestConfig,
} from "./testConfigLoader";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "playwithme-dev",
  });
}

async function exampleScript() {
  const db = admin.firestore();

  console.log("\n🏐 Example Script - Using testConfigLoader\n");
  console.log("=".repeat(50));

  try {
    // Method 1: Get specific users by index
    const test1 = getTestUser(0); // First user (index 0)
    const test2 = getTestUser(1); // Second user (index 1)
    const test3 = getTestUser(2); // Third user (index 2)

    console.log("\n📋 Retrieved test users:");
    console.log(`  Test1: ${test1.uid} (${test1.email})`);
    console.log(`  Test2: ${test2.uid} (${test2.email})`);
    console.log(`  Test3: ${test3.uid} (${test3.email})`);

    // Method 2: Get group ID
    const groupId = getTestGroupId();
    console.log(`\n🏐 Group ID: ${groupId}`);

    // Method 3: Get all user IDs
    const allUserIds = getAllTestUserIds();
    console.log(`\n👥 Total test users: ${allUserIds.length}`);

    // Example: Query Firestore using test user IDs
    console.log("\n🔍 Querying Firestore with test user IDs...");

    const test1Doc = await db.collection("users").doc(test1.uid).get();
    if (test1Doc.exists) {
      const userData = test1Doc.data();
      console.log(`\n✅ Found Test1 in Firestore:`);
      console.log(`   Display Name: ${userData?.displayName}`);
      console.log(`   Friends: ${userData?.friendCount || 0}`);
      console.log(`   Games Played: ${userData?.gamesPlayed || 0}`);
    }

    // Example: Query games for the group
    const gamesSnapshot = await db
      .collection("games")
      .where("groupId", "==", groupId)
      .get();

    console.log(`\n🎮 Games in test group: ${gamesSnapshot.size}`);
    gamesSnapshot.docs.forEach((doc, index) => {
      const game = doc.data();
      console.log(`   ${index + 1}. ${game.title} (${game.status})`);
    });

    // Example: Create a new game using test users
    console.log("\n🆕 Example: How to create a game with test users:");
    console.log(`
    const gameRef = await db.collection("games").add({
      title: "New Test Game",
      groupId: "${groupId}",
      createdBy: "${test1.uid}",
      playerIds: ["${test1.uid}", "${test2.uid}", "${test3.uid}"],
      scheduledAt: admin.firestore.Timestamp.now(),
      // ... other fields
    });
    `);

    console.log("\n✅ Example script completed successfully!\n");
  } catch (error: any) {
    console.error("\n❌ Error:", error.message);
    throw error;
  }
}

// Run the script
if (require.main === module) {
  exampleScript()
    .then(() => {
      console.log("👍 Script finished");
      process.exit(0);
    })
    .catch((error) => {
      console.error("💥 Script failed:", error);
      process.exit(1);
    });
}

export { exampleScript };

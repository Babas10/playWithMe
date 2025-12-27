/**
 * Setup Users and Group Only
 *
 * Creates test users and a single group without any games.
 * This allows testing game creation through the app.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupUsersAndGroup.ts
 */

import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp({
  projectId: "playwithme-dev",
});

const db = admin.firestore();

interface TestUser {
  uid: string;
  email: string;
  displayName: string;
  password: string;
}

/**
 * Clear all Firestore collections
 */
async function clearFirestore() {
  console.log("\n🗑️  CLEARING FIRESTORE DATABASE\n");
  console.log("=".repeat(50));

  const collections = ["users", "groups", "games", "friendships", "invitations", "notifications"];

  for (const collectionName of collections) {
    const snapshot = await db.collection(collectionName).get();

    // Delete user subcollections first
    if (collectionName === "users") {
      console.log("🔍 Finding user subcollections...");
      for (const userDoc of snapshot.docs) {
        const headToHeadSnapshot = await userDoc.ref.collection("headToHead").get();
        if (!headToHeadSnapshot.empty) {
          for (const h2hDoc of headToHeadSnapshot.docs) {
            await h2hDoc.ref.delete();
          }
          console.log(`  ✅ Deleted ${headToHeadSnapshot.size} head-to-head records for user ${userDoc.id}`);
        }
      }
    }

    // Delete main collection documents
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`✅ Deleted ${snapshot.size} documents from '${collectionName}'`);
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
 * Create test users
 */
async function createTestUsers(): Promise<TestUser[]> {
  console.log("\n👤 CREATING TEST USERS\n");
  console.log("=".repeat(50));

  const users: TestUser[] = [];
  const password = "test1010";

  for (let i = 1; i <= 10; i++) {
    const email = `test${i}@mysta.com`;
    const displayName = `Test${i}`;

    // Create Firebase Auth user
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName,
    });

    // Create Firestore user document
    await db.collection("users").doc(userRecord.uid).set({
      email,
      displayName,
      photoUrl: null,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      bio: "",
      location: null,
      gamesPlayed: 0,
      gamesWon: 0,
      gamesLost: 0,
      eloRating: 1600,
      eloGamesPlayed: 0,
      currentStreak: 0,
      longestWinStreak: 0,
      longestLoseStreak: 0,
      friendIds: [],
      groupIds: [],
      notificationSettings: {
        gameInvites: true,
        groupInvites: true,
        friendRequests: true,
        gameReminders: true,
      },
    });

    users.push({
      uid: userRecord.uid,
      email,
      displayName,
      password,
    });

    console.log(`✅ Created user: ${displayName} (${email})`);
  }

  console.log(`\n✅ Created ${users.length} test users\n`);
  return users;
}

/**
 * Create friendships between all users
 */
async function createFriendships(users: TestUser[]): Promise<void> {
  console.log("\n👥 CREATING FRIENDSHIPS\n");
  console.log("=".repeat(50));

  const batch = db.batch();
  let friendshipCount = 0;

  // Create friendships between all users (complete graph)
  for (let i = 0; i < users.length; i++) {
    for (let j = i + 1; j < users.length; j++) {
      const friendshipId = `${users[i].uid}_${users[j].uid}`;
      const friendshipRef = db.collection("friendships").doc(friendshipId);

      batch.set(friendshipRef, {
        initiatorId: users[i].uid,
        recipientId: users[j].uid,
        status: "accepted",
        createdAt: admin.firestore.Timestamp.now(),
        acceptedAt: admin.firestore.Timestamp.now(),
      });

      friendshipCount++;
    }
  }

  console.log(`Creating ${friendshipCount} friendships...`);
  await batch.commit();
  console.log(`✅ Created ${friendshipCount} friendships`);

  // Update friendIds cache for each user
  const userBatch = db.batch();
  for (const user of users) {
    const friendIds = users
      .filter((u) => u.uid !== user.uid)
      .map((u) => u.uid);

    userBatch.update(db.collection("users").doc(user.uid), {
      friendIds,
    });
  }

  await userBatch.commit();
  console.log(`✅ Updated friendIds cache for ${users.length} users\n`);
}

/**
 * Create test group
 */
async function createTestGroup(users: TestUser[]): Promise<string> {
  console.log("\n🏐 CREATING TEST GROUP\n");
  console.log("=".repeat(50));

  const groupRef = await db.collection("groups").add({
    name: "Beach Volleyball Squad",
    description: "Weekly beach volleyball games",
    photoUrl: null,
    createdBy: users[0].uid,
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
    memberIds: users.map((u) => u.uid),
    adminIds: [users[0].uid],
    settings: {
      visibility: "private",
      allowMemberInvites: true,
      requireApproval: false,
      maxMembers: 50,
    },
    stats: {
      totalMembers: users.length,
      totalGamesPlayed: 0,
      totalGamesScheduled: 0,
    },
    gameIds: [],
    lastActivity: admin.firestore.Timestamp.now(),
  });

  const groupId = groupRef.id;
  console.log(`✅ Created group: ${groupId}`);

  // Update users' groupIds
  const batch = db.batch();
  for (const user of users) {
    batch.update(db.collection("users").doc(user.uid), {
      groupIds: [groupId],
    });
  }
  await batch.commit();
  console.log(`✅ Added ${users.length} members to group\n`);

  return groupId;
}

/**
 * Export test configuration to JSON file
 */
async function exportTestConfig(
  users: TestUser[],
  groupId: string
): Promise<void> {
  console.log("\n📝 EXPORTING TEST CONFIGURATION\n");
  console.log("=".repeat(50));

  const config = {
    users: users.map((u) => ({
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
      password: u.password,
    })),
    groupId,
    timestamp: new Date().toISOString(),
  };

  const configPath = path.join(__dirname, "testConfig.json");
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));

  console.log(`✅ Exported test config to: ${configPath}`);
  console.log("\nTest User IDs:");
  users.forEach((user, index) => {
    console.log(`  ${index + 1}. ${user.displayName}: ${user.uid}`);
  });
  console.log(`\nGroup ID: ${groupId}`);
}

/**
 * Main execution
 */
async function main() {
  const startTime = Date.now();

  console.log("=".repeat(70));
  console.log("🏐 PLAYWITHME USERS & GROUP SETUP");
  console.log("=".repeat(70));
  console.log("\n⚠️  WARNING: This will DELETE ALL DATA in the dev environment!\n");

  try {
    // Step 1: Clear existing data
    await clearFirestore();
    await clearAuthUsers();

    // Step 2: Create test users
    const users = await createTestUsers();

    // Step 3: Create friendships
    await createFriendships(users);

    // Step 4: Create test group
    const groupId = await createTestGroup(users);

    // Step 5: Export configuration
    await exportTestConfig(users, groupId);

    const duration = ((Date.now() - startTime) / 1000).toFixed(2);

    console.log("\n\n");
    console.log("=".repeat(70));
    console.log("🎉 SETUP COMPLETE!");
    console.log("=".repeat(70));
    console.log(`\n✅ Total time: ${duration} seconds\n`);
    console.log("Summary:");
    console.log(`  • ${users.length} test users created`);
    console.log(`  • 45 friendships created`);
    console.log(`  • 1 test group created with ${users.length} members`);
    console.log(`  • 0 games created (create through the app)\n`);
    console.log("📋 Test credentials:");
    console.log("  Email: test1@mysta.com");
    console.log("  Password: test1010\n");
    console.log("📁 Test config exported to: functions/scripts/testConfig.json\n");
    console.log("✅ Script completed successfully");
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

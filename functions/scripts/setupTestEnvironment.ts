/**
 * Comprehensive Test Environment Setup Script
 *
 * This script:
 * 1. Clears the entire Firestore dev database
 * 2. Creates 10 test users (Firebase Auth + Firestore profiles)
 * 3. Sets up friendships between all users (My Community)
 * 4. Creates a test group with all users as members
 * 5. Creates multiple test games in the group
 * 6. Exports test user IDs to testConfig.json for other scripts
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupTestEnvironment.ts
 *
 * WARNING: This will DELETE ALL DATA in the dev environment!
 */

import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

// Initialize Firebase Admin SDK
admin.initializeApp({
  projectId: "playwithme-dev", // ⚠️ Only dev environment
});

const db = admin.firestore();
const auth = admin.auth();

// Test user data
const TEST_USERS = [
  { email: "test1@mysta.com", displayName: "Test1", firstName: "Test", lastName: "One" },
  { email: "test2@mysta.com", displayName: "Test2", firstName: "Test", lastName: "Two" },
  { email: "test3@mysta.com", displayName: "Test3", firstName: "Test", lastName: "Three" },
  { email: "test4@mysta.com", displayName: "Test4", firstName: "Test", lastName: "Four" },
  { email: "test5@mysta.com", displayName: "Test5", firstName: "Test", lastName: "Five" },
  { email: "test6@mysta.com", displayName: "Test6", firstName: "Test", lastName: "Six" },
  { email: "test7@mysta.com", displayName: "Test7", firstName: "Test", lastName: "Seven" },
  { email: "test8@mysta.com", displayName: "Test8", firstName: "Test", lastName: "Eight" },
  { email: "test9@mysta.com", displayName: "Test9", firstName: "Test", lastName: "Nine" },
  { email: "test10@mysta.com", displayName: "Test10", firstName: "Test", lastName: "Ten" },
];

const DEFAULT_PASSWORD = "test1010";

interface TestUser {
  uid: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
}

/**
 * Delete all documents in a collection
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
    const snapshot = await query.get();

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

    // Recurse on the next process tick to avoid stack overflow
    process.nextTick(() => {
      deleteQueryBatch(query, resolve, reject);
    });
  }
}

/**
 * Delete all subcollections for all users
 */
async function deleteUserSubcollections(): Promise<void> {
  console.log("🔍 Finding user subcollections...");
  const usersSnapshot = await db.collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    // Delete headToHead subcollection
    const h2hCount = await deleteCollection(`users/${userDoc.id}/headToHead`);
    if (h2hCount > 0) {
      console.log(`  ✅ Deleted ${h2hCount} head-to-head records for user ${userDoc.id}`);
    }

    // Delete ratingHistory subcollection
    const ratingCount = await deleteCollection(`users/${userDoc.id}/ratingHistory`);
    if (ratingCount > 0) {
      console.log(`  ✅ Deleted ${ratingCount} rating history entries for user ${userDoc.id}`);
    }
  }
}

/**
 * Clear the entire Firestore database
 */
async function clearDatabase(): Promise<void> {
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

  // Delete user subcollections first
  await deleteUserSubcollections();

  // Delete main collections
  for (const collection of collections) {
    const count = await deleteCollection(collection);
    console.log(`✅ Deleted ${count} documents from '${collection}'`);
  }

  console.log("\n✅ Database cleared successfully!\n");
}

/**
 * Delete all Firebase Auth users (except current admin)
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
        console.warn(`⚠️  Failed to delete user ${userRecord.uid}:`, error);
      }
    }

    if (listUsersResult.pageToken) {
      await listAllUsers(listUsersResult.pageToken);
    }
  };

  await listAllUsers();
  console.log(`✅ Deleted ${deletedCount} auth users\n`);
}

/**
 * Create a test user (Auth + Firestore profile)
 */
async function createTestUser(userData: typeof TEST_USERS[0]): Promise<TestUser> {
  // Create Firebase Auth user
  const userRecord = await auth.createUser({
    email: userData.email,
    password: DEFAULT_PASSWORD,
    displayName: userData.displayName,
    emailVerified: true,
  });

  // Create Firestore user profile
  const now = admin.firestore.Timestamp.now();
  await db.collection("users").doc(userRecord.uid).set({
    email: userData.email,
    displayName: userData.displayName,
    firstName: userData.firstName,
    lastName: userData.lastName,
    photoUrl: null,
    isEmailVerified: true,
    createdAt: now,
    lastSignInAt: now,
    updatedAt: now,
    isAnonymous: false,
    groupIds: [],
    gameIds: [],
    friendIds: [],
    friendCount: 0,
    notificationsEnabled: true,
    emailNotifications: true,
    pushNotifications: true,
    privacyLevel: "public",
    showEmail: true,
    showPhoneNumber: true,
    gamesPlayed: 0,
    gamesWon: 0,
    gamesLost: 0,
    totalScore: 0,
    currentStreak: 0,
    recentGameIds: [],
    teammateStats: {},
    eloRating: 1600.0,
    eloGamesPlayed: 0,
  });

  return {
    uid: userRecord.uid,
    email: userData.email,
    displayName: userData.displayName,
    firstName: userData.firstName,
    lastName: userData.lastName,
  };
}

/**
 * Create friendships between all users (everyone is friends with everyone)
 */
async function createFriendships(users: TestUser[]): Promise<void> {
  console.log("\n👥 CREATING FRIENDSHIPS\n");
  console.log("=".repeat(50));

  const friendships: Array<{
    initiatorId: string;
    recipientId: string;
    initiatorName: string;
    recipientName: string;
  }> = [];

  // Create all possible friendships (each user with every other user)
  for (let i = 0; i < users.length; i++) {
    for (let j = i + 1; j < users.length; j++) {
      friendships.push({
        initiatorId: users[i].uid,
        recipientId: users[j].uid,
        initiatorName: users[i].displayName,
        recipientName: users[j].displayName,
      });
    }
  }

  console.log(`Creating ${friendships.length} friendships...`);

  // Create friendship documents
  const batch = db.batch();
  const now = admin.firestore.Timestamp.now();

  for (const friendship of friendships) {
    const friendshipRef = db.collection("friendships").doc();
    batch.set(friendshipRef, {
      initiatorId: friendship.initiatorId,
      recipientId: friendship.recipientId,
      initiatorName: friendship.initiatorName,
      recipientName: friendship.recipientName,
      status: "accepted", // All friendships are pre-accepted
      createdAt: now,
      updatedAt: now,
    });
  }

  await batch.commit();

  // Update friendIds cache for each user
  for (const user of users) {
    const otherUserIds = users.filter((u) => u.uid !== user.uid).map((u) => u.uid);
    await db
      .collection("users")
      .doc(user.uid)
      .update({
        friendIds: otherUserIds,
        friendCount: otherUserIds.length,
        friendsLastUpdated: now,
      });
  }

  console.log(`✅ Created ${friendships.length} friendships`);
  console.log(`✅ Updated friendIds cache for ${users.length} users\n`);
}

/**
 * Create a test group with all users as members
 */
async function createTestGroup(users: TestUser[]): Promise<string> {
  console.log("\n🏐 CREATING TEST GROUP\n");
  console.log("=".repeat(50));

  const groupRef = db.collection("groups").doc();
  const creator = users[0]; // Alice is the creator
  const now = admin.firestore.Timestamp.now();

  await groupRef.set({
    name: "Beach Volleyball Crew",
    description: "Weekly beach volleyball games with friends!",
    photoUrl: null,
    createdBy: creator.uid,
    createdAt: now,
    updatedAt: now,
    memberIds: users.map((u) => u.uid),
    adminIds: [creator.uid],
    gameIds: [],
    privacy: "private",
    requiresApproval: false,
    maxMembers: 20,
    location: "Venice Beach, CA",
    allowMembersToCreateGames: true,
    allowMembersToInviteOthers: true,
    notifyMembersOfNewGames: true,
    totalGamesPlayed: 0,
    lastActivity: now,
  });

  // Update groupIds for all users
  const userBatch = db.batch();
  for (const user of users) {
    userBatch.update(db.collection("users").doc(user.uid), {
      groupIds: admin.firestore.FieldValue.arrayUnion(groupRef.id),
    });
  }
  await userBatch.commit();

  console.log(`✅ Created group: ${groupRef.id}`);
  console.log(`✅ Added ${users.length} members to group\n`);

  return groupRef.id;
}

/**
 * Create test games in the group
 */
async function createTestGames(groupId: string, users: TestUser[]): Promise<string[]> {
  console.log("\n🎮 CREATING TEST GAMES\n");
  console.log("=".repeat(50));

  const gameIds: string[] = [];
  const now = new Date();

  // Game 1: Completed game from 2 weeks ago (Alice & Bob vs Charlie & Diana)
  const game1Ref = db.collection("games").doc();
  const game1Date = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);

  // Create as scheduled first
  await game1Ref.set({
    title: "Sunday Morning Match",
    description: "Great weather for volleyball!",
    groupId: groupId,
    createdBy: users[0].uid,
    createdAt: admin.firestore.Timestamp.fromDate(game1Date),
    updatedAt: admin.firestore.Timestamp.fromDate(game1Date),
    scheduledAt: admin.firestore.Timestamp.fromDate(game1Date),
    location: {
      name: "Venice Beach Court 3",
      address: "1800 Ocean Front Walk, Venice, CA 90291",
      latitude: 33.985,
      longitude: -118.4695,
    },
    status: "scheduled",
    maxPlayers: 4,
    minPlayers: 4,
    playerIds: [users[0].uid, users[1].uid, users[2].uid, users[3].uid],
    waitlistIds: [],
    allowWaitlist: true,
    allowPlayerInvites: true,
    visibility: "group",
    equipment: ["net", "ball"],
    gameType: "beach_volleyball",
    skillLevel: "intermediate",
    weatherDependent: true,
    eloCalculated: false,
  });

  // Wait for the document to be fully created before updating
  await new Promise(resolve => setTimeout(resolve, 1000));

  // Update to completed - this triggers the Cloud Function
  await game1Ref.update({
    status: "completed",
    startedAt: admin.firestore.Timestamp.fromDate(game1Date),
    completedAt: admin.firestore.Timestamp.fromDate(game1Date),
    endedAt: admin.firestore.Timestamp.fromDate(
      new Date(game1Date.getTime() + 90 * 60 * 1000)
    ),
    teams: {
      teamAPlayerIds: [users[0].uid, users[1].uid],
      teamBPlayerIds: [users[2].uid, users[3].uid],
    },
    result: {
      games: [
        {
          gameNumber: 1,
          sets: [{ setNumber: 1, teamAPoints: 21, teamBPoints: 15 }],
          winner: "teamA",
        },
        {
          gameNumber: 2,
          sets: [{ setNumber: 1, teamAPoints: 21, teamBPoints: 18 }],
          winner: "teamA",
        },
      ],
      overallWinner: "teamA",
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  gameIds.push(game1Ref.id);
  console.log(`✅ Created completed game 1: ${game1Ref.id}`);

  // Game 2: Completed game from 1 week ago (Charlie & Diana vs Ethan & Fiona)
  const game2Ref = db.collection("games").doc();
  const game2Date = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  // Create as scheduled first
  await game2Ref.set({
    title: "Sunset Volleyball",
    description: "Evening game at sunset!",
    groupId: groupId,
    createdBy: users[2].uid,
    createdAt: admin.firestore.Timestamp.fromDate(game2Date),
    updatedAt: admin.firestore.Timestamp.fromDate(game2Date),
    scheduledAt: admin.firestore.Timestamp.fromDate(game2Date),
    location: {
      name: "Venice Beach Court 2",
      address: "1800 Ocean Front Walk, Venice, CA 90291",
      latitude: 33.985,
      longitude: -118.4695,
    },
    status: "scheduled",
    maxPlayers: 4,
    minPlayers: 4,
    playerIds: [users[2].uid, users[3].uid, users[4].uid, users[5].uid],
    waitlistIds: [],
    allowWaitlist: true,
    allowPlayerInvites: true,
    visibility: "group",
    equipment: ["net", "ball"],
    gameType: "beach_volleyball",
    skillLevel: "intermediate",
    weatherDependent: true,
    eloCalculated: false,
  });

  // Wait for the document to be fully created before updating
  await new Promise(resolve => setTimeout(resolve, 1000));

  // Update to completed - this triggers the Cloud Function
  await game2Ref.update({
    status: "completed",
    startedAt: admin.firestore.Timestamp.fromDate(game2Date),
    completedAt: admin.firestore.Timestamp.fromDate(game2Date),
    endedAt: admin.firestore.Timestamp.fromDate(
      new Date(game2Date.getTime() + 90 * 60 * 1000)
    ),
    teams: {
      teamAPlayerIds: [users[2].uid, users[3].uid],
      teamBPlayerIds: [users[4].uid, users[5].uid],
    },
    result: {
      games: [
        {
          gameNumber: 1,
          sets: [{ setNumber: 1, teamAPoints: 19, teamBPoints: 21 }],
          winner: "teamB",
        },
        {
          gameNumber: 2,
          sets: [{ setNumber: 1, teamAPoints: 21, teamBPoints: 23 }],
          winner: "teamB",
        },
      ],
      overallWinner: "teamB",
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  gameIds.push(game2Ref.id);
  console.log(`✅ Created completed game 2: ${game2Ref.id}`);

  // Game 3: Scheduled game for tomorrow
  const game3Ref = db.collection("games").doc();
  const game3Date = new Date(now.getTime() + 24 * 60 * 60 * 1000);
  await game3Ref.set({
    title: "Saturday Game",
    description: "Let's play!",
    groupId: groupId,
    createdBy: users[0].uid,
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
    scheduledAt: admin.firestore.Timestamp.fromDate(game3Date),
    location: {
      name: "Venice Beach Court 1",
      address: "1800 Ocean Front Walk, Venice, CA 90291",
      latitude: 33.985,
      longitude: -118.4695,
    },
    status: "scheduled",
    maxPlayers: 4,
    minPlayers: 4,
    playerIds: [users[0].uid, users[1].uid, users[6].uid, users[7].uid],
    waitlistIds: [],
    allowWaitlist: true,
    allowPlayerInvites: true,
    visibility: "group",
    equipment: ["net", "ball"],
    gameType: "beach_volleyball",
    skillLevel: "intermediate",
    eloCalculated: false,
    weatherDependent: true,
  });
  gameIds.push(game3Ref.id);
  console.log(`✅ Created scheduled game 3: ${game3Ref.id}`);

  // Game 4: Scheduled game for next week
  const game4Ref = db.collection("games").doc();
  const game4Date = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
  await game4Ref.set({
    title: "Next Week's Game",
    description: "Advanced level play",
    groupId: groupId,
    createdBy: users[4].uid,
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
    scheduledAt: admin.firestore.Timestamp.fromDate(game4Date),
    location: {
      name: "Santa Monica Beach",
      address: "380 Santa Monica Pier, Santa Monica, CA 90401",
      latitude: 34.0095,
      longitude: -118.4988,
    },
    status: "scheduled",
    maxPlayers: 4,
    minPlayers: 4,
    playerIds: [users[4].uid, users[5].uid, users[8].uid, users[9].uid],
    waitlistIds: [],
    allowWaitlist: true,
    allowPlayerInvites: true,
    visibility: "group",
    equipment: ["net", "ball"],
    gameType: "beach_volleyball",
    skillLevel: "advanced",
    eloCalculated: false,
    weatherDependent: true,
  });
  gameIds.push(game4Ref.id);
  console.log(`✅ Created scheduled game 4: ${game4Ref.id}`);

  // Update group with gameIds
  await db
    .collection("groups")
    .doc(groupId)
    .update({
      gameIds: gameIds,
      totalGamesPlayed: 2, // 2 completed games
    });

  console.log(`\n✅ Created ${gameIds.length} games\n`);

  return gameIds;
}

/**
 * Export test configuration to JSON file
 */
async function exportTestConfig(
  users: TestUser[],
  groupId: string,
  gameIds: string[]
): Promise<void> {
  console.log("\n📝 EXPORTING TEST CONFIGURATION\n");
  console.log("=".repeat(50));

  const config = {
    timestamp: new Date().toISOString(),
    users: users.map((u, index) => ({
      index: index,
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
      firstName: u.firstName,
      lastName: u.lastName,
      password: DEFAULT_PASSWORD,
    })),
    groupId: groupId,
    gameIds: gameIds,
    notes: {
      password: DEFAULT_PASSWORD,
      friendships: "All users are friends with each other",
      group: "All users are members of the test group",
      games: `${gameIds.length} games created (2 completed, 2 scheduled)`,
    },
  };

  const configPath = path.join(__dirname, "testConfig.json");
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));

  console.log(`✅ Exported test config to: ${configPath}`);
  console.log(`\nTest User IDs:`);
  users.forEach((u, i) => {
    console.log(`  ${i + 1}. ${u.displayName}: ${u.uid}`);
  });
  console.log(`\nGroup ID: ${groupId}`);
  console.log(`Game IDs: ${gameIds.join(", ")}\n`);
}

/**
 * Main setup function
 */
async function setupTestEnvironment() {
  const startTime = Date.now();

  console.log("\n");
  console.log("=".repeat(70));
  console.log("🏐 PLAYWITHME TEST ENVIRONMENT SETUP");
  console.log("=".repeat(70));
  console.log("\n⚠️  WARNING: This will DELETE ALL DATA in the dev environment!\n");

  try {
    // Step 1: Clear database
    await clearDatabase();
    await clearAuthUsers();

    // Step 2: Create test users
    console.log("\n👤 CREATING TEST USERS\n");
    console.log("=".repeat(50));
    const users: TestUser[] = [];
    for (const userData of TEST_USERS) {
      const user = await createTestUser(userData);
      users.push(user);
      console.log(`✅ Created user: ${user.displayName} (${user.email})`);
    }
    console.log(`\n✅ Created ${users.length} test users\n`);

    // Step 3: Create friendships
    await createFriendships(users);

    // Step 4: Create test group
    const groupId = await createTestGroup(users);

    // Step 5: Create test games
    const gameIds = await createTestGames(groupId, users);

    // Step 6: Export test configuration
    await exportTestConfig(users, groupId, gameIds);

    // Summary
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log("\n");
    console.log("=".repeat(70));
    console.log("🎉 TEST ENVIRONMENT SETUP COMPLETE!");
    console.log("=".repeat(70));
    console.log(`\n✅ Total time: ${duration} seconds\n`);
    console.log("Summary:");
    console.log(`  • ${users.length} test users created`);
    console.log(`  • ${(users.length * (users.length - 1)) / 2} friendships created`);
    console.log(`  • 1 test group created with ${users.length} members`);
    console.log(`  • ${gameIds.length} games created (2 completed, 2 scheduled)`);
    console.log(`\n📋 Test credentials:`);
    console.log(`  Email: ${users[0].email}`);
    console.log(`  Password: ${DEFAULT_PASSWORD}\n`);
    console.log(`📁 Test config exported to: functions/scripts/testConfig.json\n`);
  } catch (error) {
    console.error("\n❌ ERROR during setup:", error);
    throw error;
  }
}

// Confirm project before running
const projectId = admin.app().options.projectId;
if (projectId !== "playwithme-dev") {
  console.error("❌ ERROR: This script can only run on playwithme-dev!");
  console.error(`   Current project: ${projectId}`);
  process.exit(1);
}

// Run the script
setupTestEnvironment()
  .then(() => {
    console.log("✅ Script completed successfully");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Script failed:", error);
    process.exit(1);
  });

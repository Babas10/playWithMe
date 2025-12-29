/**
 * Role-Based Performance Test Environment Setup Script
 *
 * Based on setupTestEnvironment.ts core, this script creates test data
 * specifically for Story 301.9 (Role-Based Performance Analytics).
 *
 * Creates 8 users with varied ELO ratings and 13 games where test1:
 * - Weak-Link (lowest ELO on team): 4 games, 2 wins (50%)
 * - Carry (highest ELO on team): 6 games, 5 wins (83%)
 * - Balanced (tied/middle ELO): 3 games, 2 wins (67%)
 *
 * Expected insight for test1: "💪 Strong carry performance! You elevate your teammates."
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupRoleBasedTestEnvironment.ts
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
const DEFAULT_PASSWORD = "test1010";

// Test users with varied ELO ratings for role testing
const TEST_USERS = [
  { email: "test1@mysta.com", displayName: "Test1", firstName: "Test", lastName: "One", eloRating: 1600 },
  { email: "test2@mysta.com", displayName: "Test2", firstName: "Test", lastName: "Two", eloRating: 1800 },
  { email: "test3@mysta.com", displayName: "Test3", firstName: "Test", lastName: "Three", eloRating: 1700 },
  { email: "test4@mysta.com", displayName: "Test4", firstName: "Test", lastName: "Four", eloRating: 1500 },
  { email: "test5@mysta.com", displayName: "Test5", firstName: "Test", lastName: "Five", eloRating: 1900 },
  { email: "test6@mysta.com", displayName: "Test6", firstName: "Test", lastName: "Six", eloRating: 1400 },
  { email: "test7@mysta.com", displayName: "Test7", firstName: "Test", lastName: "Seven", eloRating: 1600 },
  { email: "test8@mysta.com", displayName: "Test8", firstName: "Test", lastName: "Eight", eloRating: 1300 },
];

interface TestUser {
  uid: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
  eloRating: number;
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
    const h2hCount = await deleteCollection(`users/${userDoc.id}/headToHead`);
    if (h2hCount > 0) {
      console.log(`  ✅ Deleted ${h2hCount} head-to-head records for user ${userDoc.id}`);
    }

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

  await deleteUserSubcollections();

  for (const collection of collections) {
    const count = await deleteCollection(collection);
    console.log(`✅ Deleted ${count} documents from '${collection}'`);
  }

  console.log("\n✅ Database cleared successfully!\n");
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
 * Create a test user
 */
async function createTestUser(userData: typeof TEST_USERS[0]): Promise<TestUser> {
  const userRecord = await auth.createUser({
    email: userData.email,
    password: DEFAULT_PASSWORD,
    displayName: userData.displayName,
    emailVerified: true,
  });

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
    eloRating: userData.eloRating,
    eloPeak: userData.eloRating,
    eloGamesPlayed: 0,
  });

  return {
    uid: userRecord.uid,
    email: userData.email,
    displayName: userData.displayName,
    firstName: userData.firstName,
    lastName: userData.lastName,
    eloRating: userData.eloRating,
  };
}

/**
 * Create friendships between all users
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

  const batch = db.batch();
  const now = admin.firestore.Timestamp.now();

  for (const friendship of friendships) {
    const friendshipRef = db.collection("friendships").doc();
    batch.set(friendshipRef, {
      initiatorId: friendship.initiatorId,
      recipientId: friendship.recipientId,
      initiatorName: friendship.initiatorName,
      recipientName: friendship.recipientName,
      status: "accepted",
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
 * Create test group
 */
async function createTestGroup(users: TestUser[]): Promise<string> {
  console.log("\n🏐 CREATING TEST GROUP\n");
  console.log("=".repeat(50));

  const groupRef = db.collection("groups").doc();
  const creator = users[0];
  const now = admin.firestore.Timestamp.now();

  await groupRef.set({
    name: "Role-Based Performance Testing",
    description: "Test group for role-based performance analytics",
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
 * Create a completed game for role testing
 */
async function createRoleTestGame(
  groupId: string,
  users: TestUser[],
  teamAIndices: number[],
  teamBIndices: number[],
  teamAWins: boolean,
  gameNumber: number,
  description: string
): Promise<string> {
  const gameRef = db.collection("games").doc();
  const gameDate = new Date(Date.now() - (14 - gameNumber) * 24 * 60 * 60 * 1000);

  // Create as scheduled first
  await gameRef.set({
    title: `Role Test Game ${gameNumber}`,
    description: description,
    groupId: groupId,
    createdBy: users[teamAIndices[0]].uid,
    createdAt: admin.firestore.Timestamp.fromDate(gameDate),
    updatedAt: admin.firestore.Timestamp.fromDate(gameDate),
    scheduledAt: admin.firestore.Timestamp.fromDate(gameDate),
    location: {
      name: "Venice Beach Court 1",
      address: "1800 Ocean Front Walk, Venice, CA 90291",
      latitude: 33.985,
      longitude: -118.4695,
    },
    status: "scheduled",
    maxPlayers: 4,
    minPlayers: 4,
    playerIds: [...teamAIndices, ...teamBIndices].map((i) => users[i].uid),
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

  // Wait for document to be created
  await new Promise((resolve) => setTimeout(resolve, 1000));

  // Update to completed - this triggers Cloud Functions
  await gameRef.update({
    status: "completed",
    startedAt: admin.firestore.Timestamp.fromDate(gameDate),
    completedAt: admin.firestore.Timestamp.fromDate(gameDate),
    endedAt: admin.firestore.Timestamp.fromDate(
      new Date(gameDate.getTime() + 90 * 60 * 1000)
    ),
    teams: {
      teamAPlayerIds: teamAIndices.map((i) => users[i].uid),
      teamBPlayerIds: teamBIndices.map((i) => users[i].uid),
    },
    result: {
      games: [
        {
          gameNumber: 1,
          sets: teamAWins
            ? [{ setNumber: 1, teamAPoints: 21, teamBPoints: 18 }]
            : [{ setNumber: 1, teamAPoints: 18, teamBPoints: 21 }],
          winner: teamAWins ? "teamA" : "teamB",
        },
        {
          gameNumber: 2,
          sets: teamAWins
            ? [{ setNumber: 1, teamAPoints: 21, teamBPoints: 19 }]
            : [{ setNumber: 1, teamAPoints: 19, teamBPoints: 21 }],
          winner: teamAWins ? "teamA" : "teamB",
        },
      ],
      overallWinner: teamAWins ? "teamA" : "teamB",
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return gameRef.id;
}

/**
 * Create all role test games
 */
async function createRoleTestGames(groupId: string, users: TestUser[]): Promise<string[]> {
  console.log("\n🎮 CREATING ROLE-BASED TEST GAMES\n");
  console.log("=".repeat(50));
  console.log("Focus: test1 (ELO: 1600) in different team roles\n");

  const gameIds: string[] = [];

  console.log("📉 Weak-Link Scenarios (test1 is lowest ELO on team):");

  // Game 1: test1 (1600) + test2 (1800) vs test3 (1700) + test4 (1500) - WIN
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 1],
      [2, 3],
      true,
      1,
      "Test1 weak-link with strong partner - WIN"
    )
  );
  console.log(`  ✅ Game 1: Test1(1600) + Test2(1800) vs Test3+Test4 - WIN`);

  // Game 2: test1 (1600) + test5 (1900) vs test2 (1800) + test3 (1700) - WIN
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 4],
      [1, 2],
      true,
      2,
      "Test1 weak-link with very strong partner - WIN"
    )
  );
  console.log(`  ✅ Game 2: Test1(1600) + Test5(1900) vs Test2+Test3 - WIN`);

  // Game 3: test1 (1600) + test3 (1700) vs test2 (1800) + test5 (1900) - LOSS
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 2],
      [1, 4],
      false,
      3,
      "Test1 weak-link against stronger opponents - LOSS"
    )
  );
  console.log(`  ✅ Game 3: Test1(1600) + Test3(1700) vs Test2+Test5 - LOSS`);

  // Game 4: test1 (1600) + test2 (1800) vs test5 (1900) + test4 (1500) - LOSS
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 1],
      [4, 3],
      false,
      4,
      "Test1 weak-link tough matchup - LOSS"
    )
  );
  console.log(`  ✅ Game 4: Test1(1600) + Test2(1800) vs Test5+Test4 - LOSS\n`);

  console.log("📈 Carry Scenarios (test1 is highest ELO on team):");

  // Games 5-7: test1 carrying weaker partners vs weak opponents - WIN
  for (let i = 0; i < 3; i++) {
    gameIds.push(
      await createRoleTestGame(
        groupId,
        users,
        [0, 3 + i],
        [5, 7],
        true,
        5 + i,
        `Test1 carrying weaker partner ${i + 1} - WIN`
      )
    );
    console.log(
      `  ✅ Game ${5 + i}: Test1(1600) + Test${4 + i}(${users[3 + i].eloRating}) vs Test6+Test8 - WIN`
    );
  }

  // Game 8: test1 (1600) + test4 (1500) vs test3 (1700) + test2 (1800) - LOSS
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 3],
      [2, 1],
      false,
      8,
      "Test1 carrying but facing stronger opponents - LOSS"
    )
  );
  console.log(`  ✅ Game 8: Test1(1600) + Test4(1500) vs Test3+Test2 - LOSS`);

  // Game 9: test1 (1600) + test6 (1400) vs test3 (1700) + test4 (1500) - WIN
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 5],
      [2, 3],
      true,
      9,
      "Test1 carrying against mid-tier opponents - WIN"
    )
  );
  console.log(`  ✅ Game 9: Test1(1600) + Test6(1400) vs Test3+Test4 - WIN`);

  // Game 10: test1 (1600) + test8 (1300) vs test4 (1500) + test6 (1400) - WIN
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 7],
      [3, 5],
      true,
      10,
      "Test1 carrying weakest partner - WIN"
    )
  );
  console.log(`  ✅ Game 10: Test1(1600) + Test8(1300) vs Test4+Test6 - WIN\n`);

  console.log("⚖️ Balanced Scenarios (test1 tied ELO with partner):");

  // Game 11: test1 (1600) + test7 (1600) vs test3 (1700) + test4 (1500) - WIN
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 6],
      [2, 3],
      true,
      11,
      "Test1 balanced matchup - WIN"
    )
  );
  console.log(`  ✅ Game 11: Test1(1600) + Test7(1600) vs Test3+Test4 - WIN`);

  // Game 12: test1 (1600) + test7 (1600) vs test3 (1700) + test6 (1400) - LOSS
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 6],
      [2, 5],
      false,
      12,
      "Test1 balanced matchup tough loss - LOSS"
    )
  );
  console.log(`  ✅ Game 12: Test1(1600) + Test7(1600) vs Test3+Test6 - LOSS`);

  // Game 13: test1 (1600) + test7 (1600) vs test4 (1500) + test6 (1400) - WIN
  gameIds.push(
    await createRoleTestGame(
      groupId,
      users,
      [0, 6],
      [3, 5],
      true,
      13,
      "Test1 balanced matchup - WIN"
    )
  );
  console.log(`  ✅ Game 13: Test1(1600) + Test7(1600) vs Test4+Test6 - WIN\n`);

  // Update group with gameIds
  await db.collection("groups").doc(groupId).update({
    gameIds: gameIds,
    totalGamesPlayed: gameIds.length,
  });

  console.log(`✅ Created ${gameIds.length} test games\n`);

  return gameIds;
}

/**
 * Export test configuration
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
      eloRating: u.eloRating,
    })),
    groupId: groupId,
    gameIds: gameIds,
    notes: {
      password: DEFAULT_PASSWORD,
      friendships: "All users are friends with each other",
      group: "All users are members of the test group",
      games: "13 completed games for role-based performance testing",
      scenario: "test1 plays in all three roles (weak-link, carry, balanced)",
      expectedResult: {
        weakLink: { games: 4, wins: 2, winRate: "50.0%" },
        carry: { games: 6, wins: 5, winRate: "83.3%" },
        balanced: { games: 3, wins: 2, winRate: "66.7%" },
        totalGames: 13,
        insight: "💪 Strong carry performance! You elevate your teammates.",
      },
    },
  };

  const configPath = path.join(__dirname, "testConfig.json");
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));

  console.log(`✅ Exported test config to: ${configPath}\n`);
}

/**
 * Main setup function
 */
async function setupTestEnvironment() {
  const startTime = Date.now();

  console.log("\n");
  console.log("=".repeat(70));
  console.log("🏐 ROLE-BASED PERFORMANCE TEST ENVIRONMENT SETUP");
  console.log("=".repeat(70));
  console.log("\n⚠️  WARNING: This will DELETE ALL DATA in the dev environment!\n");

  try {
    await clearDatabase();
    await clearAuthUsers();

    console.log("\n👤 CREATING TEST USERS\n");
    console.log("=".repeat(50));
    const users: TestUser[] = [];
    for (const userData of TEST_USERS) {
      const user = await createTestUser(userData);
      users.push(user);
      console.log(`✅ Created user: ${user.displayName} (${user.email}) - ELO: ${user.eloRating}`);
    }
    console.log(`\n✅ Created ${users.length} test users\n`);

    await createFriendships(users);
    const groupId = await createTestGroup(users);
    const gameIds = await createRoleTestGames(groupId, users);
    await exportTestConfig(users, groupId, gameIds);

    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log("\n");
    console.log("=".repeat(70));
    console.log("🎉 TEST ENVIRONMENT SETUP COMPLETE!");
    console.log("=".repeat(70));
    console.log(`\n✅ Total time: ${duration} seconds\n`);
    console.log("Summary:");
    console.log(`  • ${users.length} test users created with varied ELO ratings`);
    console.log(`  • ${(users.length * (users.length - 1)) / 2} friendships created`);
    console.log(`  • 1 test group created with ${users.length} members`);
    console.log(`  • ${gameIds.length} completed games created`);
    console.log(`\n📋 Expected Results for test1:`);
    console.log(`  • Weak-Link: 4 games, 2 wins (50%)`);
    console.log(`  • Carry: 6 games, 5 wins (83%)`);
    console.log(`  • Balanced: 3 games, 2 wins (67%)`);
    console.log(`  • Insight: "💪 Strong carry performance! You elevate your teammates."`);
    console.log(`\n📋 Test credentials:`);
    console.log(`  Email: ${users[0].email}`);
    console.log(`  Password: ${DEFAULT_PASSWORD}\n`);
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

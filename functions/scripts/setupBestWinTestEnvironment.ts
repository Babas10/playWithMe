/**
 * Best Win Tracking Test Environment Setup Script
 *
 * This script creates a complete isolated test environment for Story 301.6 (Best Win Tracking).
 *
 * What it does:
 * 1. Clears the entire Firestore dev database
 * 2. Clears all Firebase Auth users
 * 3. Creates 8 test users with controlled ELO ratings:
 *    - Test1 & Test2: 1200 ELO (our test subjects)
 *    - Test3 & Test4: 1300 ELO (moderate opponents)
 *    - Test5 & Test6: 1500 ELO (high-rated opponents)
 *    - Test7 & Test8: 1100 ELO (low-rated opponents)
 * 4. Sets up friendships between all users
 * 5. Creates a test group with all users as members
 * 6. Creates 4 test games to demonstrate best win tracking:
 *    - Game 1: Test1 & Test2 WIN vs Test3 & Test4 (1st best win)
 *    - Game 2: Test1 & Test2 WIN vs Test5 & Test6 (updates best win - higher ELO)
 *    - Game 3: Test1 & Test2 WIN vs Test7 & Test8 (does NOT update - lower ELO)
 *    - Game 4: Test1 & Test2 LOSE vs Test3 & Test4 (does NOT update - loss)
 * 7. Exports test config to testConfig.json
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupBestWinTestEnvironment.ts
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

// Test user data with specific ELO ratings
const TEST_USERS = [
  { email: "test1@mysta.com", displayName: "Test1", firstName: "Test", lastName: "One", eloRating: 1200 },
  { email: "test2@mysta.com", displayName: "Test2", firstName: "Test", lastName: "Two", eloRating: 1200 },
  { email: "test3@mysta.com", displayName: "Test3", firstName: "Test", lastName: "Three", eloRating: 1300 },
  { email: "test4@mysta.com", displayName: "Test4", firstName: "Test", lastName: "Four", eloRating: 1300 },
  { email: "test5@mysta.com", displayName: "Test5", firstName: "Test", lastName: "Five", eloRating: 1500 },
  { email: "test6@mysta.com", displayName: "Test6", firstName: "Test", lastName: "Six", eloRating: 1500 },
  { email: "test7@mysta.com", displayName: "Test7", firstName: "Test", lastName: "Seven", eloRating: 1100 },
  { email: "test8@mysta.com", displayName: "Test8", firstName: "Test", lastName: "Eight", eloRating: 1100 },
];

const DEFAULT_PASSWORD = "test1010";

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
 * Create a test user with specific ELO rating
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
    eloRating: userData.eloRating, // ✅ Set custom ELO rating
    eloPeak: userData.eloRating,
    eloGamesPlayed: 0,
    eloLastUpdated: now,
    bestWin: null, // ✅ Initialize with no best win
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
  const creator = users[0];
  const now = admin.firestore.Timestamp.now();

  await groupRef.set({
    name: "Best Win Test Group",
    description: "Test group for best win tracking feature",
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
    location: "Test Court",
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
 * Create a game document and immediately update to completed
 */
async function createAndCompleteGame(
  gameData: {
    title: string;
    groupId: string;
    createdBy: string;
    playerIds: string[];
    teams: {
      teamAPlayerIds: string[];
      teamBPlayerIds: string[];
    };
    result: {
      overallWinner: string;
      games: any[];
    };
  }
): Promise<string> {
  const now = admin.firestore.Timestamp.now();

  const scheduledGame = {
    title: gameData.title,
    groupId: gameData.groupId,
    createdBy: gameData.createdBy,
    status: "scheduled",
    scheduledAt: now,
    createdAt: now,
    updatedAt: now,
    location: {
      name: "Test Court",
      address: "123 Test St",
    },
    minPlayers: 4,
    maxPlayers: 4,
    playerIds: gameData.playerIds,
    waitlistIds: [],
    teams: null,
    result: null,
    eloCalculated: false,
  };

  const gameRef = await db.collection("games").add(scheduledGame);
  console.log(`  ✅ Created Scheduled Game: ${gameRef.id}`);

  await new Promise(resolve => setTimeout(resolve, 1000));

  await gameRef.update({
    status: "completed",
    teams: gameData.teams,
    result: gameData.result,
    completedAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
  });
  console.log(`  ✅ Updated Game ${gameRef.id} to Completed`);

  return gameRef.id;
}

/**
 * Create best win test games
 */
async function createBestWinTestGames(groupId: string, users: TestUser[]): Promise<string[]> {
  console.log("\n🎮 CREATING BEST WIN TEST GAMES\n");
  console.log("=".repeat(50));

  const gameIds: string[] = [];

  const test1 = users[0]; // 1200 ELO
  const test2 = users[1]; // 1200 ELO
  const test3 = users[2]; // 1300 ELO
  const test4 = users[3]; // 1300 ELO
  const test5 = users[4]; // 1500 ELO
  const test6 = users[5]; // 1500 ELO
  const test7 = users[6]; // 1100 ELO
  const test8 = users[7]; // 1100 ELO

  const teamTest1_Test2 = [test1.uid, test2.uid];
  const teamTest3_Test4 = [test3.uid, test4.uid];
  const teamTest5_Test6 = [test5.uid, test6.uid];
  const teamTest7_Test8 = [test7.uid, test8.uid];

  // ==========================================
  // GAME 1: Test1 & Test2 WIN vs Test3 & Test4 (Moderate ~1300 ELO)
  // Expected: Sets initial bestWin
  // ==========================================
  console.log(`\n🎮 Game 1: ${test1.displayName} & ${test2.displayName} WIN vs ${test3.displayName} & ${test4.displayName} (Moderate ~1300 ELO)`);
  console.log("  Expected: Sets bestWin (first win)");

  const game1Id = await createAndCompleteGame({
    title: "Best Win Test - Game 1 (First Win)",
    groupId: groupId,
    createdBy: test1.uid,
    playerIds: [test1.uid, test2.uid, test3.uid, test4.uid],
    teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest3_Test4 },
    result: {
      overallWinner: "teamA",
      games: [
        {
          gameNumber: 1,
          teamAScore: 21,
          teamBScore: 18,
          sets: [{ teamAPoints: 21, teamBPoints: 18, setNumber: 1 }],
          winner: "teamA",
        },
      ],
    },
  });
  gameIds.push(game1Id);

  console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
  await new Promise(resolve => setTimeout(resolve, 12000));

  // ==========================================
  // GAME 2: Test1 & Test2 WIN vs Test5 & Test6 (High-rated ~1500 ELO)
  // Expected: UPDATES bestWin
  // ==========================================
  console.log(`\n🎮 Game 2: ${test1.displayName} & ${test2.displayName} WIN vs ${test5.displayName} & ${test6.displayName} (High-rated ~1500 ELO)`);
  console.log("  Expected: UPDATES bestWin (opponent team ELO 1500 > 1300)");

  const game2Id = await createAndCompleteGame({
    title: "Best Win Test - Game 2 (Beat Higher-Rated)",
    groupId: groupId,
    createdBy: test1.uid,
    playerIds: [test1.uid, test2.uid, test5.uid, test6.uid],
    teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest5_Test6 },
    result: {
      overallWinner: "teamA",
      games: [
        {
          gameNumber: 1,
          teamAScore: 21,
          teamBScore: 19,
          sets: [{ teamAPoints: 21, teamBPoints: 19, setNumber: 1 }],
          winner: "teamA",
        },
      ],
    },
  });
  gameIds.push(game2Id);

  console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
  await new Promise(resolve => setTimeout(resolve, 12000));

  // ==========================================
  // GAME 3: Test1 & Test2 WIN vs Test7 & Test8 (Low-rated ~1100 ELO)
  // Expected: Does NOT update bestWin
  // ==========================================
  console.log(`\n🎮 Game 3: ${test1.displayName} & ${test2.displayName} WIN vs ${test7.displayName} & ${test8.displayName} (Low-rated ~1100 ELO)`);
  console.log("  Expected: Does NOT update bestWin (opponent team ELO 1100 < 1500)");

  const game3Id = await createAndCompleteGame({
    title: "Best Win Test - Game 3 (Beat Lower-Rated)",
    groupId: groupId,
    createdBy: test1.uid,
    playerIds: [test1.uid, test2.uid, test7.uid, test8.uid],
    teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest7_Test8 },
    result: {
      overallWinner: "teamA",
      games: [
        {
          gameNumber: 1,
          teamAScore: 21,
          teamBScore: 12,
          sets: [{ teamAPoints: 21, teamBPoints: 12, setNumber: 1 }],
          winner: "teamA",
        },
      ],
    },
  });
  gameIds.push(game3Id);

  console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
  await new Promise(resolve => setTimeout(resolve, 12000));

  // ==========================================
  // GAME 4: Test1 & Test2 LOSE vs Test3 & Test4
  // Expected: Does NOT affect bestWin
  // ==========================================
  console.log(`\n🎮 Game 4: ${test1.displayName} & ${test2.displayName} LOSE vs ${test3.displayName} & ${test4.displayName}`);
  console.log("  Expected: Does NOT affect bestWin (losses don't count)");

  const game4Id = await createAndCompleteGame({
    title: "Best Win Test - Game 4 (Loss)",
    groupId: groupId,
    createdBy: test1.uid,
    playerIds: [test1.uid, test2.uid, test3.uid, test4.uid],
    teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest3_Test4 },
    result: {
      overallWinner: "teamB",
      games: [
        {
          gameNumber: 1,
          teamAScore: 18,
          teamBScore: 21,
          sets: [{ teamAPoints: 18, teamBPoints: 21, setNumber: 1 }],
          winner: "teamB",
        },
      ],
    },
  });
  gameIds.push(game4Id);

  console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
  await new Promise(resolve => setTimeout(resolve, 12000));

  console.log(`\n✅ Created ${gameIds.length} best win test games\n`);

  return gameIds;
}

/**
 * Verify best win tracking results
 */
async function verifyBestWin(users: TestUser[]): Promise<void> {
  console.log("\n📊 VERIFYING BEST WIN TRACKING\n");
  console.log("=".repeat(50));

  const test1 = users[0];
  const test1Doc = await db.collection("users").doc(test1.uid).get();
  const test1Data = test1Doc.data();

  if (test1Data?.bestWin) {
    const bestWin = test1Data.bestWin;
    console.log("\n✅ Best Win Record Found:");
    console.log(`  Game Title:        ${bestWin.gameTitle}`);
    console.log(`  Opponent Team ELO: ${bestWin.opponentTeamElo.toFixed(1)} (Expected: ~1500)`);
    console.log(`  Opponent Avg ELO:  ${bestWin.opponentTeamAvgElo.toFixed(1)}`);
    console.log(`  ELO Gained:        +${bestWin.eloGained.toFixed(1)}`);
    console.log(`  Date:              ${bestWin.date.toDate().toLocaleString()}`);
    console.log(`  Game ID:           ${bestWin.gameId}`);

    if (bestWin.opponentTeamElo >= 1450 && bestWin.opponentTeamElo <= 1550) {
      console.log(`\n✅ PASS: Best win correctly shows Game 2 (vs ~1500 ELO opponents)`);
    } else {
      console.log(`\n⚠️  WARNING: Expected opponent team ELO ~1500, got ${bestWin.opponentTeamElo.toFixed(1)}`);
    }
  } else {
    console.log(`\n❌ FAIL: No bestWin found in ${test1.displayName}'s profile`);
  }

  console.log();
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
      eloRating: u.eloRating,
    })),
    groupId: groupId,
    gameIds: gameIds,
    notes: {
      password: DEFAULT_PASSWORD,
      friendships: "All users are friends with each other",
      group: "All users are members of the test group",
      games: `${gameIds.length} games created for best win tracking test`,
      scenario: "Test1 & Test2 win 3 games (vs 1300, 1500, 1100) and lose 1 game",
    },
  };

  const configPath = path.join(__dirname, "testConfig.json");
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));

  console.log(`✅ Exported test config to: ${configPath}\n`);
}

/**
 * Main setup function
 */
async function setupBestWinTestEnvironment() {
  const startTime = Date.now();

  console.log("\n");
  console.log("=".repeat(70));
  console.log("🏆 BEST WIN TRACKING TEST ENVIRONMENT SETUP");
  console.log("=".repeat(70));
  console.log("\n⚠️  WARNING: This will DELETE ALL DATA in the dev environment!\n");

  try {
    // Step 1: Clear database
    await clearDatabase();
    await clearAuthUsers();

    // Step 2: Create test users with specific ELO ratings
    console.log("\n👤 CREATING TEST USERS WITH CONTROLLED ELO RATINGS\n");
    console.log("=".repeat(50));
    const users: TestUser[] = [];
    for (const userData of TEST_USERS) {
      const user = await createTestUser(userData);
      users.push(user);
      console.log(`✅ Created user: ${user.displayName.padEnd(10)} (${user.email.padEnd(25)}) ELO: ${user.eloRating}`);
    }
    console.log(`\n✅ Created ${users.length} test users with controlled ELO ratings\n`);

    // Step 3: Create friendships
    await createFriendships(users);

    // Step 4: Create test group
    const groupId = await createTestGroup(users);

    // Step 5: Create best win test games
    const gameIds = await createBestWinTestGames(groupId, users);

    // Step 6: Verify results
    await verifyBestWin(users);

    // Step 7: Export test configuration
    await exportTestConfig(users, groupId, gameIds);

    // Summary
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log("\n");
    console.log("=".repeat(70));
    console.log("🎉 BEST WIN TEST ENVIRONMENT SETUP COMPLETE!");
    console.log("=".repeat(70));
    console.log(`\n✅ Total time: ${duration} seconds\n`);
    console.log("Summary:");
    console.log(`  • ${users.length} test users created with controlled ELO ratings`);
    console.log(`  • ${(users.length * (users.length - 1)) / 2} friendships created`);
    console.log(`  • 1 test group created with ${users.length} members`);
    console.log(`  • ${gameIds.length} games created to test best win tracking`);
    console.log(`\n📋 Test Results:`);
    console.log(`  Game 1: Won vs ~1300 ELO → Sets initial bestWin`);
    console.log(`  Game 2: Won vs ~1500 ELO → Updates bestWin (higher opponent)`);
    console.log(`  Game 3: Won vs ~1100 ELO → Keeps bestWin from Game 2 (lower opponent)`);
    console.log(`  Game 4: Lost            → bestWin unchanged (losses don't count)`);
    console.log(`\n💡 Login credentials:`);
    console.log(`  Email:    ${users[0].email}`);
    console.log(`  Password: ${DEFAULT_PASSWORD}`);
    console.log(`\n📁 Test config exported to: functions/scripts/testConfig.json`);
    console.log(`\n🔍 Check the PerformanceOverviewCard in ${users[0].displayName}'s profile to see the best win!\n`);
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
setupBestWinTestEnvironment()
  .then(() => {
    console.log("✅ Script completed successfully");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Script failed:", error);
    process.exit(1);
  });

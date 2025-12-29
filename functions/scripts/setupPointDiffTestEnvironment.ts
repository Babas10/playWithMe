/**
 * Average Point Differential Test Environment Setup Script
 *
 * This script creates a complete isolated test environment for Story 301.7 (Average Point Differential Tracking).
 *
 * What it does:
 * 1. Clears the entire Firestore dev database
 * 2. Clears all Firebase Auth users
 * 3. Creates 8 test users with controlled ELO ratings (all 1200)
 * 4. Sets up friendships between all users
 * 5. Creates a test group with all users as members
 * 6. Creates 4 test games with different point differential scenarios:
 *    - Game 1: Test1 & Test2 WIN 2-0 (close sets: 21-19, 21-18)
 *    - Game 2: Test1 & Test2 WIN 2-1 (mixed: 21-17, 18-21, 15-13)
 *    - Game 3: Test1 & Test2 LOSE 1-2 (close loss: 21-19, 18-21, 13-15)
 *    - Game 4: Test1 & Test2 LOSE 0-2 (bad loss: 17-21, 15-21)
 * 7. Calculates expected point differential:
 *    - Total: (+2+3) + (+4-3+2) + (+2-3-2) + (-4-6) = -5 points over 10 sets
 *    - Average: -5 / 10 = -0.5 points per set
 * 8. Exports test config to testConfig.json
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupPointDiffTestEnvironment.ts
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

// Test user data (all with same ELO to isolate point diff metric)
const TEST_USERS = [
  { email: "test1@mysta.com", displayName: "Test1", firstName: "Test", lastName: "One", eloRating: 1200 },
  { email: "test2@mysta.com", displayName: "Test2", firstName: "Test", lastName: "Two", eloRating: 1200 },
  { email: "test3@mysta.com", displayName: "Test3", firstName: "Test", lastName: "Three", eloRating: 1200 },
  { email: "test4@mysta.com", displayName: "Test4", firstName: "Test", lastName: "Four", eloRating: 1200 },
  { email: "test5@mysta.com", displayName: "Test5", firstName: "Test", lastName: "Five", eloRating: 1200 },
  { email: "test6@mysta.com", displayName: "Test6", firstName: "Test", lastName: "Six", eloRating: 1200 },
  { email: "test7@mysta.com", displayName: "Test7", firstName: "Test", lastName: "Seven", eloRating: 1200 },
  { email: "test8@mysta.com", displayName: "Test8", firstName: "Test", lastName: "Eight", eloRating: 1200 },
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
    eloLastUpdated: now,
    pointStats: null, // ✅ Initialize with no point stats
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
    name: "Point Diff Test Group",
    description: "Test group for average point differential tracking",
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
 * Create point differential test games
 */
async function createPointDiffTestGames(groupId: string, users: TestUser[]): Promise<string[]> {
  console.log("\n🎮 CREATING POINT DIFFERENTIAL TEST GAMES\n");
  console.log("=".repeat(50));

  const gameIds: string[] = [];

  const test1 = users[0];
  const test2 = users[1];
  const test3 = users[2];
  const test4 = users[3];
  const test5 = users[4];
  const test6 = users[5];
  const test7 = users[6];
  const test8 = users[7];

  const teamTest1_Test2 = [test1.uid, test2.uid];
  const teamTest3_Test4 = [test3.uid, test4.uid];
  const teamTest5_Test6 = [test5.uid, test6.uid];
  const teamTest7_Test8 = [test7.uid, test8.uid];

  // ==========================================
  // GAME 1: Test1 & Test2 WIN 2-0 (Close sets: 21-19, 21-18)
  // Point Differential: +2, +3 = +5 over 2 sets
  // ==========================================
  console.log(`\n🎮 Game 1: ${test1.displayName} & ${test2.displayName} WIN 2-0 vs ${test3.displayName} & ${test4.displayName}`);
  console.log("  Sets: 21-19 (+2), 21-18 (+3)");
  console.log("  Expected: +5 points over 2 sets");

  const game1Id = await createAndCompleteGame({
    title: "Point Diff Test - Game 1 (Close Win)",
    groupId: groupId,
    createdBy: test1.uid,
    playerIds: [test1.uid, test2.uid, test3.uid, test4.uid],
    teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest3_Test4 },
    result: {
      overallWinner: "teamA",
      games: [
        {
          gameNumber: 1,
          sets: [
            { teamAPoints: 21, teamBPoints: 19, setNumber: 1 },
            { teamAPoints: 21, teamBPoints: 18, setNumber: 2 },
          ],
          winner: "teamA",
        },
      ],
    },
  });
  gameIds.push(game1Id);

  console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
  await new Promise(resolve => setTimeout(resolve, 12000));

  // ==========================================
  // GAME 2: Test1 & Test2 WIN 2-1 (Mixed: 21-17, 18-21, 15-13)
  // Point Differential: +4, -3, +2 = +3 over 3 sets
  // ==========================================
  console.log(`\n🎮 Game 2: ${test1.displayName} & ${test2.displayName} WIN 2-1 vs ${test5.displayName} & ${test6.displayName}`);
  console.log("  Sets: 21-17 (+4), 18-21 (-3), 15-13 (+2)");
  console.log("  Expected: +3 points over 3 sets");

  const game2Id = await createAndCompleteGame({
    title: "Point Diff Test - Game 2 (Hard-Fought Win)",
    groupId: groupId,
    createdBy: test1.uid,
    playerIds: [test1.uid, test2.uid, test5.uid, test6.uid],
    teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest5_Test6 },
    result: {
      overallWinner: "teamA",
      games: [
        {
          gameNumber: 1,
          sets: [
            { teamAPoints: 21, teamBPoints: 17, setNumber: 1 },
            { teamAPoints: 18, teamBPoints: 21, setNumber: 2 },
            { teamAPoints: 15, teamBPoints: 13, setNumber: 3 },
          ],
          winner: "teamA",
        },
      ],
    },
  });
  gameIds.push(game2Id);

  console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
  await new Promise(resolve => setTimeout(resolve, 12000));

  // ==========================================
  // GAME 3: Test1 & Test2 LOSE 1-2 (Close Loss: 21-19, 18-21, 13-15)
  // Point Differential: +2, -3, -2 = -3 over 3 sets
  // ==========================================
  console.log(`\n🎮 Game 3: ${test1.displayName} & ${test2.displayName} LOSE 1-2 vs ${test7.displayName} & ${test8.displayName}`);
  console.log("  Sets: 21-19 (+2), 18-21 (-3), 13-15 (-2)");
  console.log("  Expected: -3 points over 3 sets");

  const game3Id = await createAndCompleteGame({
    title: "Point Diff Test - Game 3 (Close Loss)",
    groupId: groupId,
    createdBy: test1.uid,
    playerIds: [test1.uid, test2.uid, test7.uid, test8.uid],
    teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest7_Test8 },
    result: {
      overallWinner: "teamB",
      games: [
        {
          gameNumber: 1,
          sets: [
            { teamAPoints: 21, teamBPoints: 19, setNumber: 1 },
            { teamAPoints: 18, teamBPoints: 21, setNumber: 2 },
            { teamAPoints: 13, teamBPoints: 15, setNumber: 3 },
          ],
          winner: "teamB",
        },
      ],
    },
  });
  gameIds.push(game3Id);

  console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
  await new Promise(resolve => setTimeout(resolve, 12000));

  // ==========================================
  // GAME 4: Test1 & Test2 LOSE 0-2 (Bad Loss: 17-21, 15-21)
  // Point Differential: -4, -6 = -10 over 2 sets
  // ==========================================
  console.log(`\n🎮 Game 4: ${test1.displayName} & ${test2.displayName} LOSE 0-2 vs ${test3.displayName} & ${test4.displayName}`);
  console.log("  Sets: 17-21 (-4), 15-21 (-6)");
  console.log("  Expected: -10 points over 2 sets");

  const game4Id = await createAndCompleteGame({
    title: "Point Diff Test - Game 4 (Bad Loss)",
    groupId: groupId,
    createdBy: test1.uid,
    playerIds: [test1.uid, test2.uid, test3.uid, test4.uid],
    teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest3_Test4 },
    result: {
      overallWinner: "teamB",
      games: [
        {
          gameNumber: 1,
          sets: [
            { teamAPoints: 17, teamBPoints: 21, setNumber: 1 },
            { teamAPoints: 15, teamBPoints: 21, setNumber: 2 },
          ],
          winner: "teamB",
        },
      ],
    },
  });
  gameIds.push(game4Id);

  console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
  await new Promise(resolve => setTimeout(resolve, 12000));

  // ==========================================
  // GAME 5: Test1 & Test2 WIN 2-1 (Competitive Win: 21-18, 19-21, 21-17)
  // Point Differential: +3, -2, +4 = +5 over 3 sets (2 wins, 1 loss)
  // ==========================================
  console.log(`\n🎮 Game 5: ${test1.displayName} & ${test2.displayName} WIN 2-1 vs ${test5.displayName} & ${test6.displayName}`);
  console.log("  Sets: 21-18 (+3), 19-21 (-2), 21-17 (+4)");
  console.log("  Expected: +7 over 3 sets (2 winning sets, 1 losing set)");

  const game5Id = await createAndCompleteGame({
    title: "Point Diff Test - Game 5 (Competitive Win)",
    groupId: groupId,
    createdBy: test1.uid,
    playerIds: [test1.uid, test2.uid, test5.uid, test6.uid],
    teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest5_Test6 },
    result: {
      overallWinner: "teamA",
      games: [
        {
          gameNumber: 1,
          sets: [
            { teamAPoints: 21, teamBPoints: 18, setNumber: 1 },
            { teamAPoints: 19, teamBPoints: 21, setNumber: 2 },
            { teamAPoints: 21, teamBPoints: 17, setNumber: 3 },
          ],
          winner: "teamA",
        },
      ],
    },
  });
  gameIds.push(game5Id);

  console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
  await new Promise(resolve => setTimeout(resolve, 12000));

  console.log(`\n✅ Created ${gameIds.length} point differential test games\n`);

  return gameIds;
}

/**
 * Verify point differential tracking results
 */
async function verifyPointDiff(users: TestUser[]): Promise<void> {
  console.log("\n📊 VERIFYING POINT DIFFERENTIAL TRACKING\n");
  console.log("=".repeat(50));

  const test1 = users[0];
  const test1Doc = await db.collection("users").doc(test1.uid).get();
  const test1Data = test1Doc.data();

  console.log("\n📈 Expected Calculation (Wins vs Losses):");
  console.log("  Game 1: WIN 2-0");
  console.log("    Set 1: 21-19 (+2), Set 2: 21-18 (+3)");
  console.log("    Winning sets: 2 sets, +5 total diff");
  console.log("  Game 2: WIN 2-1");
  console.log("    Set 1: 21-17 (+4), Set 2: 18-21 (-3), Set 3: 15-13 (+2)");
  console.log("    Winning sets: 2 sets, +6 total diff");
  console.log("    Losing sets:  1 set,  -3 total diff");
  console.log("  Game 3: LOSE 1-2");
  console.log("    Set 1: 21-19 (+2), Set 2: 18-21 (-3), Set 3: 13-15 (-2)");
  console.log("    Winning sets: 1 set,  +2 total diff");
  console.log("    Losing sets:  2 sets, -5 total diff");
  console.log("  Game 4: LOSE 0-2");
  console.log("    Set 1: 17-21 (-4), Set 2: 15-21 (-6)");
  console.log("    Losing sets:  2 sets, -10 total diff");
  console.log("  Game 5: WIN 2-1");
  console.log("    Set 1: 21-18 (+3), Set 2: 19-21 (-2), Set 3: 21-17 (+4)");
  console.log("    Winning sets: 2 sets, +7 total diff");
  console.log("    Losing sets:  1 set,  -2 total diff");
  console.log("  ────────────────────────────────────────────────────");
  console.log("  WINNING SETS: 7 sets, +20 total → +2.9 avg per winning set");
  console.log("  LOSING SETS:  6 sets, -20 total → -3.3 avg per losing set");

  if (test1Data?.pointStats) {
    const pointStats = test1Data.pointStats;
    console.log("\n✅ Point Stats Found:");
    console.log(`  Winning Sets Count:      ${pointStats.winningSetsCount}`);
    console.log(`  Total Diff in Wins:      +${pointStats.totalDiffInWinningSets}`);
    console.log(`  Losing Sets Count:       ${pointStats.losingSetsCount}`);
    console.log(`  Total Diff in Losses:    ${pointStats.totalDiffInLosingSets}`);

    const avgWins = pointStats.winningSetsCount > 0
      ? (pointStats.totalDiffInWinningSets / pointStats.winningSetsCount)
      : 0;
    const avgLosses = pointStats.losingSetsCount > 0
      ? (pointStats.totalDiffInLosingSets / pointStats.losingSetsCount)
      : 0;

    console.log(`  Avg Diff in Wins:        +${avgWins.toFixed(1)} per set`);
    console.log(`  Avg Diff in Losses:      ${avgLosses.toFixed(1)} per set`);

    const expectedWinningDiff = 20;
    const expectedWinningSets = 7;
    const expectedLosingDiff = -20;
    const expectedLosingSets = 6;

    if (
      pointStats.winningSetsCount === expectedWinningSets &&
      pointStats.totalDiffInWinningSets === expectedWinningDiff &&
      pointStats.losingSetsCount === expectedLosingSets &&
      pointStats.totalDiffInLosingSets === expectedLosingDiff
    ) {
      console.log(`\n✅ PASS: Point differential correctly calculated!`);
      console.log(`  Expected: 7 winning sets (+20 total, +2.9 avg)`);
      console.log(`  Actual:   ${pointStats.winningSetsCount} winning sets (+${pointStats.totalDiffInWinningSets} total, +${avgWins.toFixed(1)} avg)`);
      console.log(`  Expected: 6 losing sets (-20 total, -3.3 avg)`);
      console.log(`  Actual:   ${pointStats.losingSetsCount} losing sets (${pointStats.totalDiffInLosingSets} total, ${avgLosses.toFixed(1)} avg)`);
    } else {
      console.log(`\n⚠️  WARNING: Point differential mismatch`);
      console.log(`  Expected: 7 winning sets with +20 total (+2.9 avg)`);
      console.log(`  Actual:   ${pointStats.winningSetsCount} winning sets with +${pointStats.totalDiffInWinningSets} total (+${avgWins.toFixed(1)} avg)`);
      console.log(`  Expected: 6 losing sets with -20 total (-3.3 avg)`);
      console.log(`  Actual:   ${pointStats.losingSetsCount} losing sets with ${pointStats.totalDiffInLosingSets} total (${avgLosses.toFixed(1)} avg)`);
    }
  } else {
    console.log(`\n❌ FAIL: No pointStats found in ${test1.displayName}'s profile`);
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
      games: `${gameIds.length} games created for point differential test`,
      scenario: "Test1 & Test2 play 5 games with varied point differentials (wins vs losses)",
      expectedResult: {
        winningSetsCount: 7,
        totalDiffInWinningSets: 20,
        avgDiffInWins: 2.9,
        losingSetsCount: 6,
        totalDiffInLosingSets: -20,
        avgDiffInLosses: -3.3,
        interpretation: "Player is competitive (+2.9 when winning, -3.3 when losing)",
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
async function setupPointDiffTestEnvironment() {
  const startTime = Date.now();

  console.log("\n");
  console.log("=".repeat(70));
  console.log("📊 AVERAGE POINT DIFFERENTIAL TEST ENVIRONMENT SETUP");
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
      console.log(`✅ Created user: ${user.displayName.padEnd(10)} (${user.email.padEnd(25)}) ELO: ${user.eloRating}`);
    }
    console.log(`\n✅ Created ${users.length} test users\n`);

    // Step 3: Create friendships
    await createFriendships(users);

    // Step 4: Create test group
    const groupId = await createTestGroup(users);

    // Step 5: Create point differential test games
    const gameIds = await createPointDiffTestGames(groupId, users);

    // Step 6: Verify results
    await verifyPointDiff(users);

    // Step 7: Export test configuration
    await exportTestConfig(users, groupId, gameIds);

    // Summary
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log("\n");
    console.log("=".repeat(70));
    console.log("🎉 POINT DIFFERENTIAL TEST ENVIRONMENT SETUP COMPLETE!");
    console.log("=".repeat(70));
    console.log(`\n✅ Total time: ${duration} seconds\n`);
    console.log("Summary:");
    console.log(`  • ${users.length} test users created`);
    console.log(`  • ${(users.length * (users.length - 1)) / 2} friendships created`);
    console.log(`  • 1 test group created with ${users.length} members`);
    console.log(`  • ${gameIds.length} games created with varied point differentials`);
    console.log(`\n📋 Test Scenarios (Wins vs Losses):`);
    console.log(`  Game 1: WIN 2-0  → 2 winning sets (+2, +3)`);
    console.log(`  Game 2: WIN 2-1  → 2 winning sets (+4, +2), 1 losing set (-3)`);
    console.log(`  Game 3: LOSE 1-2 → 1 winning set (+2), 2 losing sets (-3, -2)`);
    console.log(`  Game 4: LOSE 0-2 → 2 losing sets (-4, -6)`);
    console.log(`  Game 5: WIN 2-1  → 2 winning sets (+3, +4), 1 losing set (-2)`);
    console.log(`  ────────────────────────────────────────────────────────────`);
    console.log(`  WINNING SETS: 7 sets, +20 total → +2.9 avg per winning set`);
    console.log(`  LOSING SETS:  6 sets, -20 total → -3.3 avg per losing set`);
    console.log(`\n💡 Login credentials:`);
    console.log(`  Email:    ${users[0].email}`);
    console.log(`  Password: ${DEFAULT_PASSWORD}`);
    console.log(`\n📁 Test config exported to: functions/scripts/testConfig.json`);
    console.log(`\n🔍 Check the PerformanceOverviewCard in ${users[0].displayName}'s profile to see point differential!\n`);
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
setupPointDiffTestEnvironment()
  .then(() => {
    console.log("✅ Script completed successfully");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Script failed:", error);
    process.exit(1);
  });

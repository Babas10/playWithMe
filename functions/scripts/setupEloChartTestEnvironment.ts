/**
 * ELO Chart Test Environment Setup Script (Story 302.4)
 *
 * This script creates a COMPLETE test environment specifically for testing the
 * enhanced ELO progress chart.
 *
 * It performs the following steps (Self-Contained):
 * 1. Clears the entire dev database (Users, Groups, Games, etc.)
 * 2. Creates test users
 * 3. Creates a test group
 * 4. Creates a rich history of games distributed across:
 *    - Last 15 days (daily)
 *    - Last 30 days (daily)
 *    - Last 90 days (weekly)
 *    - Last 1 year (monthly)
 *    - All time (monthly)
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupEloChartTestEnvironment.ts
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

interface TestUser {
  uid: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
}

// ==========================================
// DB CLEANUP HELPERS
// ==========================================

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

async function deleteUserSubcollections(): Promise<void> {
  console.log("🔍 Finding user subcollections...");
  const usersSnapshot = await db.collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    await deleteCollection(`users/${userDoc.id}/headToHead`);
    await deleteCollection(`users/${userDoc.id}/ratingHistory`);
  }
}

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
}

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
    if (listUsersResult.pageToken) await listAllUsers(listUsersResult.pageToken);
  };

  await listAllUsers();
  console.log(`✅ Deleted ${deletedCount} auth users\n`);
}

// ==========================================
// SETUP HELPERS
// ==========================================

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

async function createFriendships(users: TestUser[]): Promise<void> {
  console.log("\n👥 CREATING FRIENDSHIPS\n");
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
    await db.collection("users").doc(user.uid).update({
      friendIds: otherUserIds,
      friendCount: otherUserIds.length,
      friendsLastUpdated: now,
    });
  }
  console.log(`✅ Created ${friendships.length} friendships`);
}

async function createTestGroup(users: TestUser[]): Promise<string> {
  console.log("\n🏐 CREATING TEST GROUP\n");
  const groupRef = db.collection("groups").doc();
  const creator = users[0];
  const now = admin.firestore.Timestamp.now();

  await groupRef.set({
    name: "Beach Volleyball Crew",
    description: "ELO Chart Test Group",
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

  return groupRef.id;
}

// ==========================================
// GAME CREATION LOGIC
// ==========================================

async function createCompletedGame(
  groupId: string,
  gameDate: Date,
  teamAPlayerIds: string[],
  teamBPlayerIds: string[],
  teamAWins: boolean,
  gameNumber: number
): Promise<string> {
  const gameRef = db.collection("games").doc();

  // Create as scheduled first
  await gameRef.set({
    title: `Test Game ${gameNumber}`,
    description: `ELO Chart Test Game #${gameNumber}`,
    groupId: groupId,
    createdBy: teamAPlayerIds[0],
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
    playerIds: [...teamAPlayerIds, ...teamBPlayerIds],
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
  await new Promise((resolve) => setTimeout(resolve, 500));

  // Update to completed - this triggers the Cloud Function for ELO calculation
  await gameRef.update({
    status: "completed",
    startedAt: admin.firestore.Timestamp.fromDate(gameDate),
    completedAt: admin.firestore.Timestamp.fromDate(gameDate),
    endedAt: admin.firestore.Timestamp.fromDate(
      new Date(gameDate.getTime() + 60 * 60 * 1000) // 1 hour later
    ),
    teams: {
      teamAPlayerIds: teamAPlayerIds,
      teamBPlayerIds: teamBPlayerIds,
    },
    result: {
      games: [
        {
          gameNumber: 1,
          sets: [
            {
              setNumber: 1,
              teamAPoints: teamAWins ? 21 : 18,
              teamBPoints: teamAWins ? 18 : 21,
            },
          ],
          winner: teamAWins ? "teamA" : "teamB",
        },
      ],
      overallWinner: teamAWins ? "teamA" : "teamB",
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return gameRef.id;
}

async function createEloChartTestGames(
  groupId: string,
  users: TestUser[]
): Promise<void> {
  console.log("\n🎮 CREATING ELO CHART TEST GAMES\n");
  console.log("=".repeat(50));

  const now = new Date();
  const gameIds: string[] = [];
  let gameNumber = 1;

  // Helper to create a game with test1 as a player
  const createGame = async (daysAgo: number, test1Wins: boolean) => {
    const gameDate = new Date(now.getTime() - daysAgo * 24 * 60 * 60 * 1000);

    // test1 is always in teamA, rotate opponents
    const teamAPlayerIds = [users[0].uid, users[1].uid];
    const opponentIndex = (gameNumber % 8) + 2; // Rotate through users 2-9
    const teamBPlayerIds = [
      users[opponentIndex].uid,
      users[opponentIndex === 9 ? 2 : opponentIndex + 1].uid,
    ];

    const gameId = await createCompletedGame(
      groupId,
      gameDate,
      teamAPlayerIds,
      teamBPlayerIds,
      test1Wins,
      gameNumber
    );

    gameIds.push(gameId);
    console.log(
      `✅ Game ${gameNumber}: ${gameDate.toLocaleDateString()} - ${
        test1Wins ? "Win" : "Loss"
      } (${daysAgo} days ago)`
    );
    gameNumber++;

    // Wait between games to allow Cloud Functions to process order
    await new Promise((resolve) => setTimeout(resolve, 1000));
  };

  console.log("\n📅 Creating games for LAST 15 DAYS (daily aggregation):");
  console.log("-".repeat(50));
  await createGame(1, true);
  await createGame(3, false);
  await createGame(5, true);
  await createGame(7, true);
  await createGame(9, false);
  await createGame(11, true);
  await createGame(13, true);
  await createGame(14, false);

  console.log("\n📅 Creating games for 15-30 DAYS AGO (daily aggregation):");
  console.log("-".repeat(50));
  await createGame(16, true);
  await createGame(19, false);
  await createGame(22, true);
  await createGame(26, true);
  await createGame(29, false);

  console.log("\n📅 Creating games for 30-90 DAYS AGO (weekly aggregation):");
  console.log("-".repeat(50));
  for (let daysAgo = 35; daysAgo <= 85; daysAgo += 5) {
    const shouldWin = Math.random() > 0.4;
    await createGame(daysAgo, shouldWin);
  }

  console.log("\n📅 Creating games for 90-365 DAYS AGO (monthly aggregation):");
  console.log("-".repeat(50));
  for (let daysAgo = 100; daysAgo <= 350; daysAgo += 15) {
    const shouldWin = Math.random() > 0.45;
    await createGame(daysAgo, shouldWin);
  }

  console.log("\n📅 Creating games for BEYOND 1 YEAR (all-time):");
  console.log("-".repeat(50));
  for (let monthsAgo = 13; monthsAgo <= 20; monthsAgo++) {
    const daysAgo = monthsAgo * 30;
    const shouldWin = Math.random() > 0.5;
    await createGame(daysAgo, shouldWin);
  }

  console.log("\n✅ Created total of " + gameIds.length + " games\n");

  await db.collection("groups").doc(groupId).update({
    gameIds: admin.firestore.FieldValue.arrayUnion(...gameIds),
    totalGamesPlayed: admin.firestore.FieldValue.increment(gameIds.length),
  });
}

async function exportTestConfig(
  users: TestUser[],
  groupId: string,
  gameIds: string[] = []
): Promise<void> {
  console.log("\n📝 EXPORTING TEST CONFIGURATION\n");
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
      description: "ELO Chart Test Environment",
    },
  };

  const configPath = path.join(__dirname, "testConfig.json");
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  console.log(`✅ Exported test config to: ${configPath}`);
}

// ==========================================
// MAIN
// ==========================================

async function setupEloChartTestEnvironment() {
  const startTime = Date.now();

  console.log("\n");
  console.log("=".repeat(70));
  console.log("📈 ELO CHART TEST ENVIRONMENT SETUP");
  console.log("=".repeat(70));
  console.log("\n⚠️  WARNING: This will DELETE ALL DATA in the dev environment!\n");

  try {
    // 1. Clear Data
    await clearDatabase();
    await clearAuthUsers();

    // 2. Create Users
    console.log("\n👤 CREATING TEST USERS\n");
    const users: TestUser[] = [];
    for (const userData of TEST_USERS) {
      const user = await createTestUser(userData);
      users.push(user);
      console.log(`✅ Created user: ${user.displayName} (${user.email})`);
    }

    // 3. Create Friendships
    await createFriendships(users);

    // 4. Create Group
    const groupId = await createTestGroup(users);

    // 5. Create ELO Chart Test Games
    await createEloChartTestGames(groupId, users);

    // Give Cloud Functions time to process final games
    console.log("⏳ Waiting for Cloud Functions to process...");
    await new Promise((resolve) => setTimeout(resolve, 5000));

    // 6. Fix Rating History Timestamps (CRITICAL FOR CHART TEST)
    // Cloud Functions use serverTimestamp(), so all entries have "now" as timestamp.
    // We must manually backdate them to match the game dates.
    console.log("\n🔧 FIXING RATING HISTORY TIMESTAMPS\n");
    const userIds = users.map(u => u.uid);
    await fixRatingHistoryTimestamps(userIds);

    // 7. Export Config
    await exportTestConfig(users, groupId);

    // Summary
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log("\n");
    console.log("=".repeat(70));
    console.log("🎉 ELO CHART TEST SETUP COMPLETE!");
    console.log("=".repeat(70));
    console.log(`\n✅ Total time: ${duration} seconds`);
    console.log("\n📱 To test:");
    console.log("  1. Login as test1@mysta.com");
    console.log("  2. Go to Profile page");
    console.log("  3. Scroll to 'Momentum & Consistency' card");
    console.log("  4. Check the Enhanced ELO Chart with all time periods populated!\n");

  } catch (error) {
    console.error("\n❌ ERROR during setup:", error);
    throw error;
  }
}

async function fixRatingHistoryTimestamps(userIds: string[]): Promise<void> {
  let updatedCount = 0;
  
  for (const userId of userIds) {
    const historySnapshot = await db.collection(`users/${userId}/ratingHistory`).get();
    
    if (historySnapshot.empty) continue;

    const batch = db.batch();
    
    // Get all game IDs from history
    const gameIds = historySnapshot.docs.map(doc => doc.data().gameId);
    
    // Fetch all games in parallel (chunks of 10 due to 'in' limit)
    const gameDocs: FirebaseFirestore.DocumentSnapshot[] = [];
    for (let i = 0; i < gameIds.length; i += 10) {
      const chunk = gameIds.slice(i, i + 10);
      const gamesSnapshot = await db.collection('games')
        .where(admin.firestore.FieldPath.documentId(), 'in', chunk)
        .get();
      gameDocs.push(...gamesSnapshot.docs);
    }
    
    const gameMap = new Map(gameDocs.map(doc => [doc.id, doc.data()]));

    for (const doc of historySnapshot.docs) {
      const gameId = doc.data().gameId;
      const gameData = gameMap.get(gameId);
      
      if (gameData && gameData.completedAt) {
        batch.update(doc.ref, {
          timestamp: gameData.completedAt
        });
        updatedCount++;
      }
    }
    
    await batch.commit();
  }
  
  console.log(`✅ Backdated ${updatedCount} rating history entries to match game completion dates.`);
}

// Confirm project before running
const projectId = admin.app().options.projectId;
if (projectId !== "playwithme-dev") {
  console.error("❌ ERROR: This script can only run on playwithme-dev!");
  process.exit(1);
}

setupEloChartTestEnvironment()
  .then(() => {
    console.log("✅ Script completed successfully");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Script failed:", error);
    process.exit(1);
  });

/**
 * Training Session Test Environment Setup Script (Story 15.6)
 *
 * This script creates a COMPLETE test environment specifically for testing
 * training session participation tracking.
 *
 * It performs the following steps (Self-Contained):
 * 1. Clears the entire dev database (Users, Groups, Training Sessions, etc.)
 * 2. Creates test users
 * 3. Creates a test group
 * 4. Creates training sessions with various statuses:
 *    - Upcoming scheduled sessions
 *    - Ongoing sessions
 *    - Completed sessions with participation history
 *    - Cancelled sessions
 *    - Sessions at capacity
 * 5. Simulates user participation (join/leave operations)
 * 6. Creates realistic participation patterns
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupTrainingSessionTestEnvironment.ts
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

async function deleteTrainingSessionSubcollections(): Promise<void> {
  console.log("🔍 Finding training session subcollections...");
  const sessionsSnapshot = await db.collection("trainingSessions").get();

  for (const sessionDoc of sessionsSnapshot.docs) {
    await deleteCollection(`trainingSessions/${sessionDoc.id}/participants`);
  }
  console.log(`✅ Deleted participants subcollections from ${sessionsSnapshot.size} training sessions`);
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
    "trainingSessions",
    "users",
    "groups",
    "games",
    "friendships",
    "invitations",
    "notifications",
    "groupActivities",
  ];

  await deleteTrainingSessionSubcollections();
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
  const creator = users[0]; // Test1
  const now = admin.firestore.Timestamp.now();

  await groupRef.set({
    name: "Beach Volleyball Training",
    description: "Training session test group - All skill levels welcome",
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
// TRAINING SESSION CREATION LOGIC
// ==========================================

async function createTrainingSession(
  groupId: string,
  createdBy: string,
  title: string,
  description: string,
  startTime: Date,
  endTime: Date,
  maxParticipants: number,
  minParticipants: number,
  status: "scheduled" | "completed" | "cancelled",
  sessionNumber: number
): Promise<string> {
  const sessionRef = db.collection("trainingSessions").doc();

  await sessionRef.set({
    groupId: groupId,
    title: title,
    description: description,
    location: {
      name: "Venice Beach Court 2",
      address: "1800 Ocean Front Walk, Venice, CA 90291",
      latitude: 33.985,
      longitude: -118.4695,
    },
    startTime: admin.firestore.Timestamp.fromDate(startTime),
    endTime: admin.firestore.Timestamp.fromDate(endTime),
    minParticipants: minParticipants,
    maxParticipants: maxParticipants,
    createdBy: createdBy,
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
    status: status,
    participantIds: [], // Will be updated when users join
    notes: `Training session #${sessionNumber}`,
    recurrenceRule: null,
    parentSessionId: null,
  });

  console.log(
    `✅ Session ${sessionNumber}: ${title} - ${status} (${startTime.toLocaleDateString()})`
  );

  return sessionRef.id;
}

async function addParticipantToSession(
  sessionId: string,
  userId: string,
  joinedAt: Date,
  status: "joined" | "left"
): Promise<void> {
  const participantRef = db
    .collection("trainingSessions")
    .doc(sessionId)
    .collection("participants")
    .doc(userId);

  await participantRef.set({
    userId: userId,
    joinedAt: admin.firestore.Timestamp.fromDate(joinedAt),
    status: status,
  });

  // Update denormalized participantIds array (only for 'joined' status)
  if (status === "joined") {
    await db.collection("trainingSessions").doc(sessionId).update({
      participantIds: admin.firestore.FieldValue.arrayUnion(userId),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
}

async function createTrainingSessionsWithParticipation(
  groupId: string,
  users: TestUser[]
): Promise<string[]> {
  console.log("\n🏋️ CREATING TRAINING SESSIONS WITH PARTICIPATION\n");
  console.log("=".repeat(50));

  const now = new Date();
  const sessionIds: string[] = [];
  const creator = users[0]; // Test1 creates the sessions
  let sessionNumber = 1;

  // Helper to create session with participants
  const createSessionWithParticipants = async (
    daysFromNow: number,
    title: string,
    description: string,
    maxParticipants: number,
    participantUserIds: string[],
    leftUserIds: string[] = [],
    status: "scheduled" | "completed" | "cancelled" = "scheduled"
  ) => {
    const startTime = new Date(now.getTime() + daysFromNow * 24 * 60 * 60 * 1000);
    const endTime = new Date(startTime.getTime() + 2 * 60 * 60 * 1000); // 2 hours

    const sessionId = await createTrainingSession(
      groupId,
      creator.uid,
      title,
      description,
      startTime,
      endTime,
      maxParticipants,
      2,
      status,
      sessionNumber
    );

    // Add participants
    for (const userId of participantUserIds) {
      const joinTime = new Date(startTime.getTime() - 24 * 60 * 60 * 1000); // Joined 1 day before
      await addParticipantToSession(sessionId, userId, joinTime, "joined");
    }

    // Add users who left
    for (const userId of leftUserIds) {
      const joinTime = new Date(startTime.getTime() - 48 * 60 * 60 * 1000); // Joined 2 days before
      await addParticipantToSession(sessionId, userId, joinTime, "left");
    }

    sessionIds.push(sessionId);
    sessionNumber++;

    return sessionId;
  };

  console.log("\n📅 Creating UPCOMING TRAINING SESSIONS:");
  console.log("-".repeat(50));

  // Session 1: Tomorrow - Basics session with 5 participants
  await createSessionWithParticipants(
    1,
    "Fundamentals Training",
    "Focus on serving, passing, and setting basics",
    10,
    [users[1].uid, users[2].uid, users[3].uid, users[4].uid, users[5].uid]
  );

  // Session 2: In 3 days - Advanced session with 3 participants
  await createSessionWithParticipants(
    3,
    "Advanced Techniques",
    "Blocking, spiking, and defensive strategies",
    8,
    [users[1].uid, users[3].uid, users[6].uid]
  );

  // Session 3: In 5 days - Full capacity session (8/8)
  await createSessionWithParticipants(
    5,
    "Team Strategy Session",
    "Working on team coordination and communication",
    8,
    [users[1].uid, users[2].uid, users[3].uid, users[4].uid, users[5].uid, users[6].uid, users[7].uid, users[8].uid]
  );

  // Session 4: In 7 days - Session with someone who left
  await createSessionWithParticipants(
    7,
    "Conditioning & Fitness",
    "Physical conditioning and endurance training",
    12,
    [users[1].uid, users[2].uid, users[5].uid, users[7].uid],
    [users[9].uid] // Maya joined but then left
  );

  // Session 5: In 10 days - Small group session
  await createSessionWithParticipants(
    10,
    "One-on-One Coaching",
    "Personalized skill development",
    4,
    [users[1].uid, users[3].uid]
  );

  console.log("\n📅 Creating COMPLETED TRAINING SESSIONS (Past):");
  console.log("-".repeat(50));

  // Session 6: 2 days ago - Completed session with good attendance
  await createSessionWithParticipants(
    -2,
    "Serving Masterclass",
    "Advanced serving techniques and practice",
    10,
    [users[1].uid, users[2].uid, users[3].uid, users[4].uid, users[5].uid, users[6].uid, users[7].uid],
    [],
    "completed"
  );

  // Session 7: 5 days ago - Completed session with some dropouts
  await createSessionWithParticipants(
    -5,
    "Game Situations Practice",
    "Simulating real game scenarios",
    12,
    [users[1].uid, users[2].uid, users[4].uid, users[6].uid, users[8].uid],
    [users[3].uid, users[7].uid], // These users left before session
    "completed"
  );

  // Session 8: 10 days ago - Completed session
  await createSessionWithParticipants(
    -10,
    "Defense Workshop",
    "Digging, diving, and court coverage",
    8,
    [users[1].uid, users[2].uid, users[3].uid, users[5].uid, users[8].uid],
    [],
    "completed"
  );

  // Session 9: 15 days ago - Completed with high participation
  await createSessionWithParticipants(
    -15,
    "Tournament Prep",
    "Preparing for upcoming tournament",
    15,
    [users[1].uid, users[2].uid, users[3].uid, users[4].uid, users[5].uid, users[6].uid, users[7].uid, users[8].uid, users[9].uid],
    [],
    "completed"
  );

  // Session 10: 20 days ago - Completed session
  await createSessionWithParticipants(
    -20,
    "Beginner Basics",
    "Introduction to beach volleyball",
    10,
    [users[2].uid, users[4].uid, users[5].uid, users[7].uid, users[9].uid],
    [users[6].uid],
    "completed"
  );

  console.log("\n📅 Creating CANCELLED TRAINING SESSIONS:");
  console.log("-".repeat(50));

  // Session 11: 3 days ago - Cancelled due to weather
  await createSessionWithParticipants(
    -3,
    "Outdoor Skills Practice",
    "Cancelled due to rain",
    12,
    [users[1].uid, users[3].uid, users[5].uid],
    [],
    "cancelled"
  );

  // Session 12: In 14 days - Cancelled (planned but cancelled early)
  await createSessionWithParticipants(
    14,
    "Advanced Tournament Tactics",
    "Cancelled - Coach unavailable",
    10,
    [],
    [],
    "cancelled"
  );

  console.log("\n✅ Created total of " + sessionIds.length + " training sessions\n");

  return sessionIds;
}

async function exportTestConfig(
  users: TestUser[],
  groupId: string,
  sessionIds: string[] = []
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
    sessionIds: sessionIds,
    notes: {
      password: DEFAULT_PASSWORD,
      description: "Training Session Test Environment",
      testScenarios: [
        "Upcoming sessions with various participation levels",
        "Completed sessions with attendance history",
        "Cancelled sessions",
        "Full capacity session (8/8)",
        "Sessions with users who joined and left",
        "Small group and large group sessions",
      ],
    },
  };

  const configPath = path.join(__dirname, "trainingTestConfig.json");
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  console.log(`✅ Exported test config to: ${configPath}`);
}

// ==========================================
// MAIN
// ==========================================

async function setupTrainingSessionTestEnvironment() {
  const startTime = Date.now();

  console.log("\n");
  console.log("=".repeat(70));
  console.log("🏋️ TRAINING SESSION TEST ENVIRONMENT SETUP");
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

    // 5. Create Training Sessions with Participation
    const sessionIds = await createTrainingSessionsWithParticipation(groupId, users);

    // 6. Export Config
    await exportTestConfig(users, groupId, sessionIds);

    // Summary
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log("\n");
    console.log("=".repeat(70));
    console.log("🎉 TRAINING SESSION TEST SETUP COMPLETE!");
    console.log("=".repeat(70));
    console.log(`\n✅ Total time: ${duration} seconds`);
    console.log("\n📱 To test:");
    console.log("  1. Login as test1@mysta.com (or test2-10@mysta.com)");
    console.log("  2. Password: test1010");
    console.log("  3. Navigate to the Training Sessions section");
    console.log("  4. View upcoming, completed, and cancelled sessions");
    console.log("  5. Test join/leave functionality");
    console.log("  6. Check participant lists and capacity limits\n");
    console.log("\n📊 Test Data Summary:");
    console.log("  - 10 users (Test1-Test10)");
    console.log("  - 1 group with all users as members");
    console.log("  - 12 training sessions:");
    console.log("    • 5 upcoming sessions");
    console.log("    • 5 completed sessions");
    console.log("    • 2 cancelled sessions");
    console.log("  - Various participation patterns:");
    console.log("    • Full capacity session");
    console.log("    • Sessions with users who left");
    console.log("    • Different attendance levels\n");

  } catch (error) {
    console.error("\n❌ ERROR during setup:", error);
    throw error;
  }
}

// Confirm project before running
const projectId = admin.app().options.projectId;
if (projectId !== "playwithme-dev") {
  console.error("❌ ERROR: This script can only run on playwithme-dev!");
  process.exit(1);
}

setupTrainingSessionTestEnvironment()
  .then(() => {
    console.log("✅ Script completed successfully");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Script failed:", error);
    process.exit(1);
  });

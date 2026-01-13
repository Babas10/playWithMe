/**
 * Training Session Test Environment Setup Script (Story 15.6, 15.7, 15.8)
 *
 * This script creates a COMPLETE test environment specifically for testing
 * training session participation tracking, exercise management, and feedback.
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
 * 7. Adds exercises to training sessions (Story 15.7):
 *    - Upcoming sessions with editable exercises
 *    - Completed sessions with locked (read-only) exercises
 *    - Various exercise types and durations
 * 8. Adds feedback to completed sessions (Story 15.8):
 *    - Partial feedback coverage (some participants submitted)
 *    - Full feedback coverage (all participants submitted)
 *    - Empty feedback state (no feedback yet)
 *    - Mix of ratings and optional comments
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupTrainingSessionTestEnvironment.ts
 */

import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";
import * as crypto from "crypto";

// Initialize Firebase Admin SDK
admin.initializeApp({
  projectId: "playwithme-dev", // ⚠️ Only dev environment
});

const db = admin.firestore();
const auth = admin.auth();

const DEFAULT_PASSWORD = "test1010";

// Salt for participant hash (must match Cloud Functions)
const PARTICIPANT_HASH_SALT = process.env.PARTICIPANT_HASH_SALT || "playwithme-feedback-salt-v1";

/**
 * Generate anonymous participant hash
 * Hash = SHA256(sessionId + userId + salt)
 * Must match the hash generation in submitTrainingFeedback Cloud Function
 */
function generateParticipantHash(sessionId: string, userId: string): string {
  const data = `${sessionId}:${userId}:${PARTICIPANT_HASH_SALT}`;
  return crypto.createHash("sha256").update(data).digest("hex");
}

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
    await deleteCollection(`trainingSessions/${sessionDoc.id}/exercises`);
    await deleteCollection(`trainingSessions/${sessionDoc.id}/feedback`);
  }
  console.log(`✅ Deleted subcollections from ${sessionsSnapshot.size} training sessions`);
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

// ==========================================
// FEEDBACK CREATION LOGIC (Story 15.8)
// ==========================================

/**
 * Add feedback to a training session
 * Schema must match the Cloud Function (submitTrainingFeedback)
 */
async function addFeedbackToSession(
  sessionId: string,
  userId: string,
  exercisesQuality: number,
  trainingIntensity: number,
  coachingClarity: number,
  comment: string | null
): Promise<void> {
  // Generate anonymous participant hash (same as Cloud Function)
  const participantHash = generateParticipantHash(sessionId, userId);

  const feedbackRef = db
    .collection("trainingSessions")
    .doc(sessionId)
    .collection("feedback")
    .doc(); // Auto-generate document ID (don't use userId)

  await feedbackRef.set({
    exercisesQuality: exercisesQuality,
    trainingIntensity: trainingIntensity,
    coachingClarity: coachingClarity,
    comment: comment,
    participantHash: participantHash,
    submittedAt: admin.firestore.Timestamp.now(),
  });
}

async function addFeedbackToCompletedSessions(
  sessionIds: string[],
  users: TestUser[]
): Promise<void> {
  console.log("\n💬 ADDING FEEDBACK TO COMPLETED SESSIONS\n");
  console.log("=".repeat(50));

  let feedbackCount = 0;

  // Session 6 (Serving Masterclass - index 5): Multiple feedback entries
  // Participants: users[1-7]
  await addFeedbackToSession(sessionIds[5], users[1].uid, 5, 5, 5, "Excellent session! Really improved my serve accuracy.");
  await addFeedbackToSession(sessionIds[5], users[2].uid, 4, 4, 4, "Great drills, could use more time on topspin serves.");
  await addFeedbackToSession(sessionIds[5], users[3].uid, 5, 4, 5, null); // No comment, just ratings
  await addFeedbackToSession(sessionIds[5], users[4].uid, 5, 3, 5, "Very helpful coach. Would love more sessions like this!");
  // users[5], users[6], users[7] haven't submitted feedback yet
  feedbackCount += 4;
  console.log(`✅ Session 6 (Serving Masterclass): 4/7 participants submitted feedback`);

  // Session 7 (Game Situations - index 6): Some feedback
  // Participants: users[1], users[2], users[4], users[6], users[8]
  await addFeedbackToSession(sessionIds[6], users[1].uid, 5, 5, 4, "Loved the competitive drills!");
  await addFeedbackToSession(sessionIds[6], users[2].uid, 4, 5, 3, "Session was good but a bit too intense for beginners.");
  await addFeedbackToSession(sessionIds[6], users[8].uid, 4, 4, 4, null);
  // users[4] and users[6] haven't submitted feedback
  feedbackCount += 3;
  console.log(`✅ Session 7 (Game Situations): 3/5 participants submitted feedback`);

  // Session 8 (Defense Workshop - index 7): Full feedback from all participants
  // Participants: users[1], users[2], users[3], users[5], users[8]
  await addFeedbackToSession(sessionIds[7], users[1].uid, 5, 5, 5, "Best defensive training I've had!");
  await addFeedbackToSession(sessionIds[7], users[2].uid, 5, 4, 5, "Coach explained techniques really well.");
  await addFeedbackToSession(sessionIds[7], users[3].uid, 4, 4, 4, "Great session, my digging improved a lot.");
  await addFeedbackToSession(sessionIds[7], users[5].uid, 5, 5, 5, null);
  await addFeedbackToSession(sessionIds[7], users[8].uid, 4, 4, 5, "Very practical drills that I can use in games.");
  feedbackCount += 5;
  console.log(`✅ Session 8 (Defense Workshop): 5/5 participants submitted feedback`);

  // Session 9 (Tournament Prep - index 8): Mixed feedback
  // Participants: users[1-9]
  await addFeedbackToSession(sessionIds[8], users[1].uid, 5, 5, 5, "Perfect prep for the tournament!");
  await addFeedbackToSession(sessionIds[8], users[3].uid, 4, 4, 4, "Good intensity and focus on game situations.");
  await addFeedbackToSession(sessionIds[8], users[5].uid, 5, 4, 5, null);
  await addFeedbackToSession(sessionIds[8], users[7].uid, 3, 4, 3, "Could have been longer, felt rushed.");
  // users[2], users[4], users[6], users[8], users[9] haven't submitted feedback
  feedbackCount += 4;
  console.log(`✅ Session 9 (Tournament Prep): 4/9 participants submitted feedback`);

  // Session 10 (Beginner Basics - index 9): No feedback yet
  // Participants: users[2], users[4], users[5], users[7], users[9]
  // All participants haven't submitted feedback - this tests the empty feedback state
  console.log(`✅ Session 10 (Beginner Basics): 0/5 participants submitted feedback (empty state)`);

  console.log(`\n✅ Total feedback entries created: ${feedbackCount}`);
}

// ==========================================
// EXERCISE CREATION LOGIC (Story 15.7)
// ==========================================

async function addExerciseToSession(
  sessionId: string,
  name: string,
  description: string | null,
  durationMinutes: number | null
): Promise<void> {
  const exerciseRef = db
    .collection("trainingSessions")
    .doc(sessionId)
    .collection("exercises")
    .doc();

  await exerciseRef.set({
    name: name,
    description: description,
    durationMinutes: durationMinutes,
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: null,
  });
}

async function addExercisesToSessions(sessionIds: string[]): Promise<void> {
  console.log("\n🏋️ ADDING EXERCISES TO TRAINING SESSIONS\n");
  console.log("=".repeat(50));

  // Define exercise sets for different types of sessions
  const basicExercises = [
    { name: "Warm-up & Stretching", description: "Dynamic stretching and mobility work", duration: 15 },
    { name: "Serving Practice", description: "Focus on consistent serves and accuracy", duration: 30 },
    { name: "Passing Drills", description: "Platform passing and communication", duration: 25 },
    { name: "Setting Technique", description: "Hand positioning and ball control", duration: 20 },
    { name: "Cool Down", description: "Static stretching and recovery", duration: 10 },
  ];

  const advancedExercises = [
    { name: "Jump Serve Training", description: "Power serving technique", duration: 25 },
    { name: "Blocking Mechanics", description: "Timing, footwork, and hand positioning", duration: 30 },
    { name: "Spiking Drills", description: "Approach, jump, and hitting technique", duration: 30 },
    { name: "Defensive Positioning", description: "Court coverage and reading the hitter", duration: 25 },
    { name: "Game Situations", description: "Scrimmage with specific scenarios", duration: 30 },
  ];

  const teamExercises = [
    { name: "Partner Communication", description: "Calling the ball and court awareness", duration: 20 },
    { name: "Transition Drills", description: "Moving from defense to offense", duration: 25 },
    { name: "Team Serves", description: "Serve receive formations", duration: 20 },
    { name: "Offensive Systems", description: "Set plays and rotations", duration: 30 },
    { name: "Match Play", description: "Full team scrimmage", duration: 45 },
  ];

  const conditioningExercises = [
    { name: "Sprint Intervals", description: "Short burst running for explosiveness", duration: 15 },
    { name: "Jump Training", description: "Vertical leap and plyometrics", duration: 20 },
    { name: "Core Strength", description: "Planks, rotations, and stability", duration: 15 },
    { name: "Agility Ladder", description: "Footwork and coordination drills", duration: 15 },
    { name: "Endurance Circuit", description: "Mixed cardio and strength exercises", duration: 25 },
  ];

  const coachingExercises = [
    { name: "Video Analysis", description: "Review technique with slow-motion video", duration: 20 },
    { name: "Individual Skills Assessment", description: "One-on-one evaluation", duration: 30 },
    { name: "Personalized Drills", description: "Custom exercises based on assessment", duration: 40 },
    { name: "Mental Game Discussion", description: "Strategy and decision-making", duration: 20 },
  ];

  let exerciseCount = 0;

  // Session 1 (Tomorrow - Fundamentals): Basic exercises
  for (const ex of basicExercises) {
    await addExerciseToSession(sessionIds[0], ex.name, ex.description, ex.duration);
    exerciseCount++;
  }
  console.log(`✅ Session 1: Added ${basicExercises.length} basic exercises`);

  // Session 2 (In 3 days - Advanced): Advanced exercises
  for (const ex of advancedExercises) {
    await addExerciseToSession(sessionIds[1], ex.name, ex.description, ex.duration);
    exerciseCount++;
  }
  console.log(`✅ Session 2: Added ${advancedExercises.length} advanced exercises`);

  // Session 3 (In 5 days - Team Strategy): Team exercises
  for (const ex of teamExercises) {
    await addExerciseToSession(sessionIds[2], ex.name, ex.description, ex.duration);
    exerciseCount++;
  }
  console.log(`✅ Session 3: Added ${teamExercises.length} team exercises`);

  // Session 4 (In 7 days - Conditioning): Conditioning exercises
  for (const ex of conditioningExercises) {
    await addExerciseToSession(sessionIds[3], ex.name, ex.description, ex.duration);
    exerciseCount++;
  }
  console.log(`✅ Session 4: Added ${conditioningExercises.length} conditioning exercises`);

  // Session 5 (In 10 days - Coaching): Personalized exercises
  for (const ex of coachingExercises) {
    await addExerciseToSession(sessionIds[4], ex.name, ex.description, ex.duration);
    exerciseCount++;
  }
  console.log(`✅ Session 5: Added ${coachingExercises.length} coaching exercises`);

  // Session 6 (Completed - Serving): Add exercises to show they're locked
  await addExerciseToSession(sessionIds[5], "Serve Placement Drills", "Target zones on the court", 25);
  await addExerciseToSession(sessionIds[5], "Float Serve Technique", "Practicing consistent float serves", 20);
  await addExerciseToSession(sessionIds[5], "Topspin Serve", "Advanced serving with spin", 15);
  exerciseCount += 3;
  console.log(`✅ Session 6 (Completed): Added 3 exercises (locked, read-only)`);

  // Session 7 (Completed - Game Situations): Some exercises
  await addExerciseToSession(sessionIds[6], "2v2 Mini Games", "Quick competitive drills", 30);
  await addExerciseToSession(sessionIds[6], "Pressure Situations", "Practicing under game pressure", 25);
  exerciseCount += 2;
  console.log(`✅ Session 7 (Completed): Added 2 exercises (locked)`);

  // Session 8 (Completed - Defense): No exercises (shows variety)
  console.log(`✅ Session 8 (Completed): No exercises (empty case)`);

  console.log(`\n✅ Total exercises created: ${exerciseCount}`);
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
        "Sessions with exercises (fundamentals, advanced, team, conditioning, coaching)",
        "Completed sessions with locked exercises (read-only)",
        "Sessions with and without exercises",
        "Completed sessions with feedback (partial and full coverage)",
        "Feedback with ratings and optional comments",
        "Empty feedback state (session with no feedback yet)",
        "Test feedback button visibility (only for participants)",
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

    // 6. Add Exercises to Training Sessions (Story 15.7)
    await addExercisesToSessions(sessionIds);

    // 7. Add Feedback to Completed Sessions (Story 15.8)
    await addFeedbackToCompletedSessions(sessionIds, users);

    // 8. Export Config
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
    console.log("  6. Check participant lists and capacity limits");
    console.log("  7. Test feedback on completed sessions:");
    console.log("     • See feedback button only if you participated");
    console.log("     • Submit feedback (rating + optional comment)");
    console.log("     • View aggregated feedback (after submission)");
    console.log("     • Some sessions already have partial feedback\n");
    console.log("\n📊 Test Data Summary:");
    console.log("  - 10 users (Test1-Test10)");
    console.log("  - 1 group with all users as members");
    console.log("  - 12 training sessions:");
    console.log("    • 5 upcoming sessions (with exercises)");
    console.log("    • 5 completed sessions (3 with locked exercises)");
    console.log("    • 2 cancelled sessions");
    console.log("  - Various participation patterns:");
    console.log("    • Full capacity session");
    console.log("    • Sessions with users who left");
    console.log("    • Different attendance levels");
    console.log("  - Exercise management (Story 15.7):");
    console.log("    • Upcoming sessions with editable exercises");
    console.log("    • Completed sessions with read-only exercises");
    console.log("    • Mix of sessions with/without exercises");
    console.log("    • Different exercise types: basic, advanced, team, conditioning");
    console.log("  - Feedback entries (Story 15.8):");
    console.log("    • 16 feedback entries across 4 completed sessions");
    console.log("    • Session 6: 4/7 participants submitted (partial feedback)");
    console.log("    • Session 7: 3/5 participants submitted (partial feedback)");
    console.log("    • Session 8: 5/5 participants submitted (full feedback)");
    console.log("    • Session 9: 4/9 participants submitted (partial feedback)");
    console.log("    • Session 10: 0/5 participants submitted (empty state)");
    console.log("    • Mix of ratings (3-5 stars) and comments (some null)\n");

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

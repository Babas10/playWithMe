/**
 * Full Test Environment Setup Script
 *
 * One-shot script that creates a complete, realistic test environment covering
 * all major Gatherli features: community/friendships, groups, games (past + future),
 * ELO rating history, training sessions (past + future), exercises, and feedback.
 *
 * What gets created:
 *  - 10 test users (test1@mysta.com … test10@mysta.com / password: test1010)
 *  - 45 accepted friendships (complete social graph)
 *  - 1 group with all 10 members
 *  - 12 past completed games  → triggers ELO Cloud Functions + rating history
 *  - 3 future scheduled games (tomorrow / +5 days / +2 weeks)
 *  - 5 past training sessions (completed, with exercises + feedback)
 *  - 3 future training sessions (scheduled, with exercises)
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupFullTestEnvironment.ts
 *
 * WARNING: Deletes ALL data in gatherli-dev before seeding!
 */

import * as admin from "firebase-admin";
import * as crypto from "crypto";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp({ projectId: "gatherli-dev" });

const db   = admin.firestore();
const auth = admin.auth();

const DEFAULT_PASSWORD       = "test1010";
const PARTICIPANT_HASH_SALT  = process.env.PARTICIPANT_HASH_SALT || "gatherli-feedback-salt-v1";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface TestUser {
  uid: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
}

// ---------------------------------------------------------------------------
// Test Users
// ---------------------------------------------------------------------------

const TEST_USERS = [
  { email: "test1@mysta.com",  displayName: "Test1",  firstName: "Test", lastName: "One"   },
  { email: "test2@mysta.com",  displayName: "Test2",  firstName: "Test", lastName: "Two"   },
  { email: "test3@mysta.com",  displayName: "Test3",  firstName: "Test", lastName: "Three" },
  { email: "test4@mysta.com",  displayName: "Test4",  firstName: "Test", lastName: "Four"  },
  { email: "test5@mysta.com",  displayName: "Test5",  firstName: "Test", lastName: "Five"  },
  { email: "test6@mysta.com",  displayName: "Test6",  firstName: "Test", lastName: "Six"   },
  { email: "test7@mysta.com",  displayName: "Test7",  firstName: "Test", lastName: "Seven" },
  { email: "test8@mysta.com",  displayName: "Test8",  firstName: "Test", lastName: "Eight" },
  { email: "test9@mysta.com",  displayName: "Test9",  firstName: "Test", lastName: "Nine"  },
  { email: "test10@mysta.com", displayName: "Test10", firstName: "Test", lastName: "Ten"   },
];

// ---------------------------------------------------------------------------
// Helpers — database cleanup
// ---------------------------------------------------------------------------

async function deleteCollection(collectionPath: string): Promise<number> {
  const ref   = db.collection(collectionPath);
  const query = ref.limit(500);
  let deleted = 0;

  return new Promise((resolve, reject) => {
    async function batch(q: FirebaseFirestore.Query) {
      const snap = await q.get();
      if (snap.size === 0) { resolve(deleted); return; }
      const b = db.batch();
      snap.docs.forEach((d) => b.delete(d.ref));
      await b.commit();
      deleted += snap.size;
      process.nextTick(() => batch(q));
    }
    batch(query).catch(reject);
  });
}

async function clearDatabase(): Promise<void> {
  console.log("\n🗑️  CLEARING DATABASE\n" + "=".repeat(50));

  // Subcollections first
  const sessions = await db.collection("trainingSessions").get();
  for (const doc of sessions.docs) {
    await deleteCollection(`trainingSessions/${doc.id}/participants`);
    await deleteCollection(`trainingSessions/${doc.id}/exercises`);
    await deleteCollection(`trainingSessions/${doc.id}/feedback`);
  }
  const users = await db.collection("users").get();
  for (const doc of users.docs) {
    await deleteCollection(`users/${doc.id}/headToHead`);
    await deleteCollection(`users/${doc.id}/ratingHistory`);
  }

  const collections = [
    "trainingSessions", "users", "groups", "games",
    "friendships", "invitations", "notifications", "groupActivities",
  ];
  for (const col of collections) {
    const n = await deleteCollection(col);
    console.log(`  ✅ Deleted ${n} docs from '${col}'`);
  }
}

async function clearAuthUsers(): Promise<void> {
  console.log("\n🗑️  CLEARING AUTH USERS\n" + "=".repeat(50));
  let n = 0;
  const del = async (token?: string) => {
    const result = await auth.listUsers(1000, token);
    for (const u of result.users) {
      try { await auth.deleteUser(u.uid); n++; } catch { /* ignore */ }
    }
    if (result.pageToken) await del(result.pageToken);
  };
  await del();
  console.log(`  ✅ Deleted ${n} auth users`);
}

// ---------------------------------------------------------------------------
// Helpers — user / social graph
// ---------------------------------------------------------------------------

async function createTestUser(data: typeof TEST_USERS[0]): Promise<TestUser> {
  const record = await auth.createUser({
    email: data.email,
    password: DEFAULT_PASSWORD,
    displayName: data.displayName,
    emailVerified: true,
  });
  const now = admin.firestore.Timestamp.now();
  await db.collection("users").doc(record.uid).set({
    email: data.email,
    displayName: data.displayName,
    firstName: data.firstName,
    lastName: data.lastName,
    photoUrl: null,
    isEmailVerified: true,
    createdAt: now, lastSignInAt: now, updatedAt: now,
    isAnonymous: false,
    groupIds: [], gameIds: [], friendIds: [], friendCount: 0,
    notificationsEnabled: true, emailNotifications: true, pushNotifications: true,
    privacyLevel: "public", showEmail: true, showPhoneNumber: true,
    gamesPlayed: 0, gamesWon: 0, gamesLost: 0, totalScore: 0,
    currentStreak: 0, recentGameIds: [], teammateStats: {},
    eloRating: 1600.0, eloGamesPlayed: 0,
  });
  return { uid: record.uid, email: data.email, displayName: data.displayName,
           firstName: data.firstName, lastName: data.lastName };
}

async function createFriendships(users: TestUser[]): Promise<void> {
  console.log("\n👥 CREATING FRIENDSHIPS\n" + "=".repeat(50));
  const now   = admin.firestore.Timestamp.now();
  const batch = db.batch();
  let count   = 0;

  for (let i = 0; i < users.length; i++) {
    for (let j = i + 1; j < users.length; j++) {
      const ref = db.collection("friendships").doc();
      batch.set(ref, {
        initiatorId:   users[i].uid,
        recipientId:   users[j].uid,
        initiatorName: users[i].displayName,
        recipientName: users[j].displayName,
        status: "accepted", createdAt: now, updatedAt: now,
      });
      count++;
    }
  }
  await batch.commit();

  for (const user of users) {
    const friends = users.filter((u) => u.uid !== user.uid).map((u) => u.uid);
    await db.collection("users").doc(user.uid).update({
      friendIds: friends, friendCount: friends.length, friendsLastUpdated: now,
    });
  }
  console.log(`  ✅ Created ${count} friendships`);
}

async function createGroup(users: TestUser[]): Promise<string> {
  console.log("\n🏐 CREATING GROUP\n" + "=".repeat(50));
  const now = admin.firestore.Timestamp.now();
  const ref = db.collection("groups").doc();

  await ref.set({
    name: "Venice Beach Crew",
    description: "Weekly beach volleyball games and training with friends!",
    photoUrl: null,
    createdBy: users[0].uid,
    createdAt: now, updatedAt: now,
    memberIds: users.map((u) => u.uid),
    adminIds:  [users[0].uid],
    gameIds:   [],
    privacy: "private", requiresApproval: false, maxMembers: 20,
    location: "Venice Beach, CA",
    allowMembersToCreateGames: true, allowMembersToInviteOthers: true,
    notifyMembersOfNewGames: true,
    totalGamesPlayed: 0, lastActivity: now,
  });

  const batch = db.batch();
  for (const user of users) {
    batch.update(db.collection("users").doc(user.uid), {
      groupIds: admin.firestore.FieldValue.arrayUnion(ref.id),
    });
  }
  await batch.commit();
  console.log(`  ✅ Group created: ${ref.id} (${users.length} members)`);
  return ref.id;
}

// ---------------------------------------------------------------------------
// Helpers — games
// ---------------------------------------------------------------------------

async function createCompletedGame(
  groupId: string,
  gameDate: Date,
  teamA: string[],
  teamB: string[],
  teamAWins: boolean,
  label: string
): Promise<string> {
  const ref = db.collection("games").doc();

  await ref.set({
    title: label,
    description: "Gatherli full-environment test game",
    groupId,
    createdBy: teamA[0],
    createdAt: admin.firestore.Timestamp.fromDate(gameDate),
    updatedAt: admin.firestore.Timestamp.fromDate(gameDate),
    scheduledAt: admin.firestore.Timestamp.fromDate(gameDate),
    location: {
      name: "Venice Beach Court 3",
      address: "1800 Ocean Front Walk, Venice, CA 90291",
      latitude: 33.985, longitude: -118.4695,
    },
    status: "scheduled",
    maxPlayers: 4, minPlayers: 4,
    playerIds: [...teamA, ...teamB],
    waitlistIds: [],
    allowWaitlist: true, allowPlayerInvites: true,
    visibility: "group",
    equipment: ["net", "ball"],
    gameType: "beach_volleyball", skillLevel: "intermediate",
    weatherDependent: true, eloCalculated: false,
  });

  await new Promise((r) => setTimeout(r, 500));

  await ref.update({
    status: "completed",
    startedAt:   admin.firestore.Timestamp.fromDate(gameDate),
    completedAt: admin.firestore.Timestamp.fromDate(gameDate),
    endedAt:     admin.firestore.Timestamp.fromDate(new Date(gameDate.getTime() + 90 * 60_000)),
    teams: { teamAPlayerIds: teamA, teamBPlayerIds: teamB },
    result: {
      games: [{
        gameNumber: 1,
        sets: [{ setNumber: 1,
          teamAPoints: teamAWins ? 21 : 17,
          teamBPoints: teamAWins ? 17 : 21 }],
        winner: teamAWins ? "teamA" : "teamB",
      }],
      overallWinner: teamAWins ? "teamA" : "teamB",
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await new Promise((r) => setTimeout(r, 1000));
  return ref.id;
}

async function createFutureGame(
  groupId: string,
  daysFromNow: number,
  title: string,
  playerIds: string[],
  createdBy: string,
  skillLevel: string = "intermediate"
): Promise<string> {
  const ref  = db.collection("games").doc();
  const date = new Date(Date.now() + daysFromNow * 24 * 60 * 60_000);

  await ref.set({
    title,
    description: "Join us for a great game!",
    groupId,
    createdBy,
    createdAt:   admin.firestore.Timestamp.now(),
    updatedAt:   admin.firestore.Timestamp.now(),
    scheduledAt: admin.firestore.Timestamp.fromDate(date),
    location: {
      name: "Venice Beach Court 1",
      address: "1800 Ocean Front Walk, Venice, CA 90291",
      latitude: 33.985, longitude: -118.4695,
    },
    status: "scheduled",
    maxPlayers: 4, minPlayers: 4,
    playerIds,
    waitlistIds: [],
    allowWaitlist: true, allowPlayerInvites: true,
    visibility: "group",
    equipment: ["net", "ball"],
    gameType: "beach_volleyball", skillLevel,
    weatherDependent: true, eloCalculated: false,
  });

  return ref.id;
}

async function fixRatingHistoryTimestamps(userIds: string[]): Promise<void> {
  let fixed = 0;
  for (const userId of userIds) {
    const histSnap = await db.collection(`users/${userId}/ratingHistory`).get();
    if (histSnap.empty) continue;

    const gameIds = histSnap.docs.map((d) => d.data().gameId as string);
    const gameDocs: FirebaseFirestore.DocumentSnapshot[] = [];
    for (let i = 0; i < gameIds.length; i += 10) {
      const snap = await db.collection("games")
        .where(admin.firestore.FieldPath.documentId(), "in", gameIds.slice(i, i + 10))
        .get();
      gameDocs.push(...snap.docs);
    }
    const gameMap = new Map(gameDocs.map((d) => [d.id, d.data()]));

    const batch = db.batch();
    for (const doc of histSnap.docs) {
      const game = gameMap.get(doc.data().gameId);
      if (game?.completedAt) {
        batch.update(doc.ref, { timestamp: game.completedAt });
        fixed++;
      }
    }
    await batch.commit();
  }
  console.log(`  ✅ Backdated ${fixed} rating history entries to match game dates`);
}

// ---------------------------------------------------------------------------
// Helpers — training sessions
// ---------------------------------------------------------------------------

function participantHash(sessionId: string, userId: string): string {
  return crypto.createHash("sha256")
    .update(`${sessionId}:${userId}:${PARTICIPANT_HASH_SALT}`)
    .digest("hex");
}

async function createTrainingSession(
  groupId: string,
  createdBy: string,
  title: string,
  description: string,
  startTime: Date,
  endTime: Date,
  maxParticipants: number,
  status: "scheduled" | "completed" | "cancelled",
  participantIds: string[],
  leftIds: string[] = []
): Promise<string> {
  const ref = db.collection("trainingSessions").doc();
  const now = admin.firestore.Timestamp.now();

  await ref.set({
    groupId, title, description,
    location: {
      name: "Venice Beach Court 2",
      address: "1800 Ocean Front Walk, Venice, CA 90291",
      latitude: 33.985, longitude: -118.4695,
    },
    startTime:      admin.firestore.Timestamp.fromDate(startTime),
    endTime:        admin.firestore.Timestamp.fromDate(endTime),
    minParticipants: 2,
    maxParticipants,
    createdBy,
    createdAt: now, updatedAt: now,
    status,
    participantIds,
    notes: null,
    recurrenceRule: null,
    parentSessionId: null,
  });

  // Write participants subcollection
  for (const uid of participantIds) {
    await db.collection("trainingSessions").doc(ref.id)
      .collection("participants").doc(uid).set({
        userId: uid,
        joinedAt: admin.firestore.Timestamp.fromDate(
          new Date(startTime.getTime() - 24 * 60 * 60_000)
        ),
        status: "joined",
      });
  }
  for (const uid of leftIds) {
    await db.collection("trainingSessions").doc(ref.id)
      .collection("participants").doc(uid).set({
        userId: uid,
        joinedAt: admin.firestore.Timestamp.fromDate(
          new Date(startTime.getTime() - 48 * 60 * 60_000)
        ),
        status: "left",
      });
  }

  return ref.id;
}

async function addExercise(
  sessionId: string, name: string, description: string | null, durationMinutes: number | null
): Promise<void> {
  const now = admin.firestore.Timestamp.now();
  await db.collection("trainingSessions").doc(sessionId)
    .collection("exercises").doc().set({
      name, description, durationMinutes,
      createdAt: now, updatedAt: null,
    });
}

async function addFeedback(
  sessionId: string, userId: string,
  exercisesQuality: number, trainingIntensity: number,
  coachingClarity: number, comment: string | null
): Promise<void> {
  await db.collection("trainingSessions").doc(sessionId)
    .collection("feedback").doc().set({
      exercisesQuality, trainingIntensity, coachingClarity, comment,
      participantHash: participantHash(sessionId, userId),
      submittedAt: admin.firestore.Timestamp.now(),
    });
}

// ---------------------------------------------------------------------------
// Orchestration — games
// ---------------------------------------------------------------------------

async function seedPastGames(groupId: string, users: TestUser[]): Promise<string[]> {
  console.log("\n🎮 CREATING PAST COMPLETED GAMES (for ELO history)\n" + "=".repeat(50));

  const now    = Date.now();
  const gameIds: string[] = [];
  const U      = users;

  // test1 (U[0]) appears in 10 of the 12 games for testing purposes.
  // Games 6 and 10 are the two where test1 does not play.
  const schedule: [string[], string[], boolean, number, string][] = [
    [[U[0].uid, U[1].uid], [U[2].uid, U[3].uid], true,  90, "Spring Open"],       // test1 ✓
    [[U[0].uid, U[2].uid], [U[4].uid, U[5].uid], false, 75, "May Doubles"],       // test1 ✓
    [[U[0].uid, U[5].uid], [U[6].uid, U[7].uid], true,  60, "June Clash"],        // test1 ✓
    [[U[0].uid, U[3].uid], [U[8].uid, U[9].uid], true,  45, "July Cup"],          // test1 ✓
    [[U[0].uid, U[2].uid], [U[3].uid, U[5].uid], true,  30, "August Rally"],      // test1 ✓
    [[U[1].uid, U[6].uid], [U[4].uid, U[7].uid], true,  22, "Late Summer"],       // no test1
    [[U[0].uid, U[9].uid], [U[2].uid, U[8].uid], false, 18, "Comeback Game"],     // test1 ✓
    [[U[0].uid, U[4].uid], [U[1].uid, U[3].uid], true,  14, "Two Weeks Ago"],     // test1 ✓
    [[U[0].uid, U[6].uid], [U[5].uid, U[7].uid], true,  10, "Mid-Month"],         // test1 ✓
    [[U[3].uid, U[4].uid], [U[8].uid, U[9].uid], false,  7, "Last Week"],         // no test1
    [[U[0].uid, U[4].uid], [U[2].uid, U[6].uid], true,   4, "Four Days Ago"],     // test1 ✓
    [[U[0].uid, U[7].uid], [U[1].uid, U[9].uid], false,  2, "Two Days Ago"],      // test1 ✓
  ];

  for (const [teamA, teamB, aWins, daysAgo, label] of schedule) {
    const date = new Date(now - daysAgo * 24 * 60 * 60_000);
    const id   = await createCompletedGame(groupId, date, teamA, teamB, aWins, label);
    gameIds.push(id);
    console.log(`  ✅ ${label} (${daysAgo}d ago) — ${aWins ? "Team A" : "Team B"} won`);
  }

  return gameIds;
}

async function seedFutureGames(groupId: string, users: TestUser[]): Promise<string[]> {
  console.log("\n📅 CREATING FUTURE SCHEDULED GAMES\n" + "=".repeat(50));

  const ids: string[] = [];
  const U = users;

  // Game 1: Tomorrow
  ids.push(await createFutureGame(
    groupId, 1, "Weekend Warm-Up",
    [U[0].uid, U[1].uid, U[2].uid, U[3].uid], U[0].uid
  ));
  console.log(`  ✅ Weekend Warm-Up (tomorrow)`);

  // Game 2: In 5 days
  ids.push(await createFutureGame(
    groupId, 5, "Mid-Week Match",
    [U[4].uid, U[5].uid, U[6].uid, U[7].uid], U[4].uid
  ));
  console.log(`  ✅ Mid-Week Match (+5 days)`);

  // Game 3: In 2 weeks
  ids.push(await createFutureGame(
    groupId, 14, "Bi-Weekly Showdown",
    [U[0].uid, U[8].uid, U[3].uid, U[9].uid], U[0].uid, "advanced"
  ));
  console.log(`  ✅ Bi-Weekly Showdown (+14 days)`);

  return ids;
}

// ---------------------------------------------------------------------------
// Orchestration — training sessions
// ---------------------------------------------------------------------------

async function seedPastTrainingSessions(groupId: string, users: TestUser[]): Promise<string[]> {
  console.log("\n🏋️  CREATING PAST TRAINING SESSIONS\n" + "=".repeat(50));

  const now = Date.now();
  const U   = users;
  const ids: string[] = [];

  const make = (daysAgo: number, title: string, desc: string,
                participants: string[], leftIds: string[] = []) => {
    const start = new Date(now - daysAgo * 24 * 60 * 60_000);
    const end   = new Date(start.getTime() + 2 * 60 * 60_000);
    return createTrainingSession(
      groupId, U[0].uid, title, desc, start, end, 10,
      "completed", participants, leftIds
    );
  };

  ids.push(await make(20, "Beginner Basics",
    "Introduction to beach volleyball fundamentals",
    [U[1].uid, U[4].uid, U[5].uid, U[7].uid, U[9].uid], [U[6].uid]));
  console.log(`  ✅ Beginner Basics (20 days ago)`);

  ids.push(await make(15, "Tournament Prep",
    "Preparing for upcoming tournament — high intensity",
    [U[1].uid, U[2].uid, U[3].uid, U[4].uid, U[5].uid, U[6].uid, U[7].uid, U[8].uid, U[9].uid]));
  console.log(`  ✅ Tournament Prep (15 days ago)`);

  ids.push(await make(10, "Defense Workshop",
    "Digging, diving, and court coverage",
    [U[1].uid, U[2].uid, U[3].uid, U[5].uid, U[8].uid]));
  console.log(`  ✅ Defense Workshop (10 days ago)`);

  ids.push(await make(5, "Game Situations",
    "Simulating real match scenarios under pressure",
    [U[1].uid, U[2].uid, U[4].uid, U[6].uid, U[8].uid],
    [U[3].uid, U[7].uid]));
  console.log(`  ✅ Game Situations (5 days ago)`);

  ids.push(await make(2, "Serving Masterclass",
    "Advanced serving techniques: float, topspin, jump serve",
    [U[1].uid, U[2].uid, U[3].uid, U[4].uid, U[5].uid, U[6].uid, U[7].uid]));
  console.log(`  ✅ Serving Masterclass (2 days ago)`);

  return ids;
}

async function seedFutureTrainingSessions(groupId: string, users: TestUser[]): Promise<string[]> {
  console.log("\n📅 CREATING FUTURE TRAINING SESSIONS\n" + "=".repeat(50));

  const now = Date.now();
  const U   = users;
  const ids: string[] = [];

  const make = (daysFromNow: number, title: string, desc: string,
                participants: string[], maxParticipants: number) => {
    const start = new Date(now + daysFromNow * 24 * 60 * 60_000);
    const end   = new Date(start.getTime() + 2 * 60 * 60_000);
    return createTrainingSession(
      groupId, U[0].uid, title, desc, start, end,
      maxParticipants, "scheduled", participants
    );
  };

  ids.push(await make(1, "Fundamentals Training",
    "Focus on serving, passing, and setting basics",
    [U[1].uid, U[2].uid, U[3].uid, U[4].uid, U[5].uid], 10));
  console.log(`  ✅ Fundamentals Training (tomorrow)`);

  ids.push(await make(4, "Advanced Techniques",
    "Blocking, spiking, and full defensive strategies",
    [U[1].uid, U[3].uid, U[6].uid], 8));
  console.log(`  ✅ Advanced Techniques (+4 days)`);

  ids.push(await make(9, "Team Strategy Session",
    "Court coordination, rotations, and set plays",
    [U[1].uid, U[2].uid, U[3].uid, U[4].uid, U[5].uid, U[6].uid, U[7].uid, U[8].uid], 8));
  console.log(`  ✅ Team Strategy Session (+9 days)`);

  return ids;
}

async function addExercisesToSessions(
  pastIds: string[], futureIds: string[]
): Promise<void> {
  console.log("\n🏋️  ADDING EXERCISES\n" + "=".repeat(50));

  // Future sessions get editable exercises
  const fundamentals = [
    ["Warm-up & Stretching", "Dynamic stretching and mobility work", 15],
    ["Serving Practice",     "Consistent serves and placement accuracy", 30],
    ["Passing Drills",       "Platform passing and communication",        25],
    ["Setting Technique",    "Hand positioning and ball control",          20],
    ["Cool Down",            "Static stretching and recovery",            10],
  ] as [string, string, number][];

  for (const [n, d, dur] of fundamentals) {
    await addExercise(futureIds[0], n, d, dur);
  }
  console.log(`  ✅ Session "Fundamentals" — ${fundamentals.length} exercises`);

  const advanced = [
    ["Jump Serve Training",    "Power serving technique and jump approach", 25],
    ["Blocking Mechanics",     "Timing, footwork, and hand positioning",    30],
    ["Spiking Drills",         "Approach, jump, and hitting technique",     30],
    ["Defensive Positioning",  "Court coverage and reading the hitter",     25],
    ["Scrimmage",              "Competitive points with coaching stops",    30],
  ] as [string, string, number][];

  for (const [n, d, dur] of advanced) {
    await addExercise(futureIds[1], n, d, dur);
  }
  console.log(`  ✅ Session "Advanced Techniques" — ${advanced.length} exercises`);

  const team = [
    ["Partner Communication", "Calling the ball and court awareness", 20],
    ["Transition Drills",     "Moving from defense to offense",       25],
    ["Offensive Systems",     "Set plays and rotations",              30],
    ["Match Play",            "Full team scrimmage",                  45],
  ] as [string, string, number][];

  for (const [n, d, dur] of team) {
    await addExercise(futureIds[2], n, d, dur);
  }
  console.log(`  ✅ Session "Team Strategy" — ${team.length} exercises`);

  // Past completed sessions get locked exercises
  const servingExercises = [
    ["Serve Placement Drills", "Target zones on the court",                  25],
    ["Float Serve Technique",  "Practising consistent low-trajectory serves", 20],
    ["Topspin Serve",          "Advanced serving with forward spin",          15],
  ] as [string, string, number][];

  for (const [n, d, dur] of servingExercises) {
    await addExercise(pastIds[4], n, d, dur); // Serving Masterclass
  }
  console.log(`  ✅ Session "Serving Masterclass" — ${servingExercises.length} locked exercises`);

  const gameExercises = [
    ["2v2 Mini Games",      "Quick competitive points",              30],
    ["Pressure Situations", "Practising decision-making under pressure", 25],
  ] as [string, string, number][];

  for (const [n, d, dur] of gameExercises) {
    await addExercise(pastIds[3], n, d, dur); // Game Situations
  }
  console.log(`  ✅ Session "Game Situations" — ${gameExercises.length} locked exercises`);
}

async function addFeedbackToSessions(
  pastIds: string[], users: TestUser[]
): Promise<void> {
  console.log("\n💬 ADDING FEEDBACK TO COMPLETED SESSIONS\n" + "=".repeat(50));

  const U = users;

  // Serving Masterclass — partial feedback (4/7)
  await addFeedback(pastIds[4], U[1].uid, 5, 5, 5, "Really improved my serve accuracy!");
  await addFeedback(pastIds[4], U[2].uid, 4, 4, 4, "Great drills, loved the topspin focus.");
  await addFeedback(pastIds[4], U[3].uid, 5, 4, 5, null);
  await addFeedback(pastIds[4], U[4].uid, 5, 3, 5, "Very helpful. Would love more sessions like this!");
  console.log(`  ✅ Serving Masterclass — 4/7 feedback entries`);

  // Game Situations — partial feedback (3/5)
  await addFeedback(pastIds[3], U[1].uid, 5, 5, 4, "Loved the competitive drills!");
  await addFeedback(pastIds[3], U[2].uid, 4, 5, 3, "Bit intense for beginners but great.");
  await addFeedback(pastIds[3], U[8].uid, 4, 4, 4, null);
  console.log(`  ✅ Game Situations — 3/5 feedback entries`);

  // Defense Workshop — full feedback (5/5)
  await addFeedback(pastIds[2], U[1].uid, 5, 5, 5, "Best defensive training I've had!");
  await addFeedback(pastIds[2], U[2].uid, 5, 4, 5, "Coach explained techniques very clearly.");
  await addFeedback(pastIds[2], U[3].uid, 4, 4, 4, "My digging improved a lot.");
  await addFeedback(pastIds[2], U[5].uid, 5, 5, 5, null);
  await addFeedback(pastIds[2], U[8].uid, 4, 4, 5, "Very practical drills.");
  console.log(`  ✅ Defense Workshop — 5/5 feedback entries (complete)`);

  // Tournament Prep — mixed feedback (4/9)
  await addFeedback(pastIds[1], U[1].uid, 5, 5, 5, "Perfect prep for the tournament!");
  await addFeedback(pastIds[1], U[3].uid, 4, 4, 4, "Good intensity and game-situation focus.");
  await addFeedback(pastIds[1], U[5].uid, 5, 4, 5, null);
  await addFeedback(pastIds[1], U[7].uid, 3, 4, 3, "Could have been longer, felt rushed.");
  console.log(`  ✅ Tournament Prep — 4/9 feedback entries`);

  // Beginner Basics — no feedback yet (empty state)
  console.log(`  ✅ Beginner Basics — 0 feedback entries (empty state)`);
}

// ---------------------------------------------------------------------------
// Config export
// ---------------------------------------------------------------------------

async function exportConfig(
  users: TestUser[],
  groupId: string,
  pastGameIds: string[],
  futureGameIds: string[],
  pastSessionIds: string[],
  futureSessionIds: string[]
): Promise<void> {
  const config = {
    timestamp: new Date().toISOString(),
    project: "gatherli-dev",
    credentials: { password: DEFAULT_PASSWORD },
    users: users.map((u, i) => ({
      index: i + 1,
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
    })),
    groupId,
    games: {
      past:   pastGameIds,
      future: futureGameIds,
    },
    trainingSessions: {
      past:   pastSessionIds,
      future: futureSessionIds,
    },
  };

  const p = path.join(__dirname, "testConfig.json");
  fs.writeFileSync(p, JSON.stringify(config, null, 2));
  console.log(`\n  ✅ Config saved to ${p}`);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const t0 = Date.now();

  console.log("\n" + "=".repeat(70));
  console.log("🏐 GATHERLI — FULL TEST ENVIRONMENT SETUP");
  console.log("=".repeat(70));
  console.log("\n⚠️  WARNING: All data in gatherli-dev will be deleted!\n");

  // 1. Clear
  await clearDatabase();
  await clearAuthUsers();

  // 2. Users
  console.log("\n👤 CREATING USERS\n" + "=".repeat(50));
  const users: TestUser[] = [];
  for (const d of TEST_USERS) {
    const u = await createTestUser(d);
    users.push(u);
    console.log(`  ✅ ${u.displayName} (${u.email})`);
  }

  // 3. Social graph
  await createFriendships(users);

  // 4. Group
  const groupId = await createGroup(users);

  // 5. Past games (triggers ELO cloud functions)
  const pastGameIds = await seedPastGames(groupId, users);

  // 6. Wait for Cloud Functions to process ELO, then backdate timestamps
  console.log("\n⏳ Waiting 8s for Cloud Functions to process ELO...");
  await new Promise((r) => setTimeout(r, 8000));
  console.log("\n🔧 FIXING RATING HISTORY TIMESTAMPS\n" + "=".repeat(50));
  await fixRatingHistoryTimestamps(users.map((u) => u.uid));

  // 7. Future games
  const futureGameIds = await seedFutureGames(groupId, users);

  // 8. Update group game list
  const allGameIds = [...pastGameIds, ...futureGameIds];
  await db.collection("groups").doc(groupId).update({
    gameIds: allGameIds,
    totalGamesPlayed: pastGameIds.length,
    lastActivity: admin.firestore.FieldValue.serverTimestamp(),
  });

  // 9. Past training sessions
  const pastSessionIds = await seedPastTrainingSessions(groupId, users);

  // 10. Future training sessions
  const futureSessionIds = await seedFutureTrainingSessions(groupId, users);

  // 11. Exercises
  await addExercisesToSessions(pastSessionIds, futureSessionIds);

  // 12. Feedback
  await addFeedbackToSessions(pastSessionIds, users);

  // 13. Export
  console.log("\n📝 EXPORTING CONFIG\n" + "=".repeat(50));
  await exportConfig(users, groupId, pastGameIds, futureGameIds, pastSessionIds, futureSessionIds);

  // Summary
  const secs = ((Date.now() - t0) / 1000).toFixed(1);
  console.log("\n" + "=".repeat(70));
  console.log("🎉 FULL ENVIRONMENT READY  (" + secs + "s)");
  console.log("=".repeat(70));
  console.log(`
📋 Credentials
   Email:    test1@mysta.com  (or test2 … test10)
   Password: ${DEFAULT_PASSWORD}

📊 Data created
   • 10 users + 45 friendships
   • 1 group  (Venice Beach Crew)
   • ${pastGameIds.length} past completed games  → ELO history populated
   • ${futureGameIds.length} future scheduled games
       - Weekend Warm-Up    (tomorrow)
       - Mid-Week Match     (+5 days)
       - Bi-Weekly Showdown (+14 days)
   • ${pastSessionIds.length} past training sessions (completed, with exercises + feedback)
   • ${futureSessionIds.length} future training sessions (upcoming, with exercises)
       - Fundamentals Training  (tomorrow)
       - Advanced Techniques    (+4 days)
       - Team Strategy Session  (+9 days)

📱 Quick test flow
   1. Log in as test1@mysta.com
   2. Community tab  → see 9 friends
   3. Groups tab     → open "Venice Beach Crew"
   4. Games tab      → upcoming games + history
   5. Training tab   → upcoming sessions + join one
   6. Profile tab    → ELO chart with historical data
`);
}

// Guard: dev only
const pid = admin.app().options.projectId;
if (pid !== "gatherli-dev") {
  console.error(`❌ This script only runs on gatherli-dev (current: ${pid})`);
  process.exit(1);
}

main()
  .then(() => process.exit(0))
  .catch((e) => { console.error("❌ Error:", e); process.exit(1); });

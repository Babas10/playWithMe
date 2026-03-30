/**
 * Access Environment Setup Script
 *
 * Creates a dedicated Google Play / App Store review account with realistic
 * data so reviewers can access all app features without needing to sign up.
 *
 * What gets created:
 *  - 5 access accounts (access[1-5]@gatherli.org / password: Access2026)
 *  - 10 accepted friendships (complete social graph)
 *  - 1 group "Zurich Volleyball Club"
 *  - 4 past completed games (with ELO history)
 *  - 2 future scheduled games
 *  - 2 past completed training sessions (with exercises + feedback)
 *  - 1 future scheduled training session (with exercises)
 *
 * The reviewer should log in as:
 *   Email:    access1@gatherli.org
 *   Password: Access2026
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupAccessEnvironment.ts
 *
 * ⚠️  Runs against gatherli-PROD. Does NOT delete existing data.
 * Use cleanupAccessEnvironment.ts to remove everything created here.
 */

import * as admin from "firebase-admin";
import * as crypto from "crypto";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp({ projectId: "gatherli-prod" });

const db   = admin.firestore();
const auth = admin.auth();

const DEFAULT_PASSWORD      = "Access2026";
const PARTICIPANT_HASH_SALT = process.env.PARTICIPANT_HASH_SALT || "gatherli-feedback-salt-v1";
const ACCESS_TAG            = true;

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface AccessUser {
  uid: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
}

// ---------------------------------------------------------------------------
// Users
// ---------------------------------------------------------------------------

const ACCESS_USERS = [
  { email: "access1@gatherli.org", displayName: "Alex",   firstName: "Alex",   lastName: "Martin"  },
  { email: "access2@gatherli.org", displayName: "Jordan", firstName: "Jordan", lastName: "Smith"   },
  { email: "access3@gatherli.org", displayName: "Sam",    firstName: "Sam",    lastName: "Taylor"  },
  { email: "access4@gatherli.org", displayName: "Casey",  firstName: "Casey",  lastName: "Wilson"  },
  { email: "access5@gatherli.org", displayName: "Morgan", firstName: "Morgan", lastName: "Brown"   },
];

// ---------------------------------------------------------------------------
// Locations
// ---------------------------------------------------------------------------

const LOCATIONS = {
  letten: {
    name: "Flussbad Letten",
    address: "Lettensteg 10, 8037 Zürich",
    latitude: 47.3854,
    longitude: 8.5316,
  },
  allmend: {
    name: "Sportanlage Allmend",
    address: "Allmendstrasse 55, 8045 Zürich",
    latitude: 47.3454,
    longitude: 8.5266,
  },
};

// ---------------------------------------------------------------------------
// Helpers — users & social graph
// ---------------------------------------------------------------------------

async function createAccessUser(data: typeof ACCESS_USERS[0]): Promise<AccessUser> {
  // Delete existing user with same email if present (idempotent re-run)
  try {
    const existing = await auth.getUserByEmail(data.email);
    await auth.deleteUser(existing.uid);
    const snap = await db.collection("users").where("email", "==", data.email).limit(1).get();
    if (!snap.empty) await snap.docs[0].ref.delete();
  } catch { /* not found — fine */ }

  const record = await auth.createUser({
    email:         data.email,
    password:      DEFAULT_PASSWORD,
    displayName:   data.displayName,
    emailVerified: true,
  });

  const now = admin.firestore.Timestamp.now();
  await db.collection("users").doc(record.uid).set({
    email:              data.email,
    displayName:        data.displayName,
    firstName:          data.firstName,
    lastName:           data.lastName,
    photoUrl:           null,
    isEmailVerified:    true,
    createdAt: now, lastSignInAt: now, updatedAt: now,
    isAnonymous:        false,
    groupIds: [], gameIds: [], friendIds: [], friendCount: 0,
    notificationsEnabled: true, emailNotifications: true, pushNotifications: true,
    privacyLevel: "public", showEmail: true, showPhoneNumber: true,
    gamesPlayed: 0, gamesWon: 0, gamesLost: 0, totalScore: 0,
    currentStreak: 0, recentGameIds: [], teammateStats: {},
    eloRating: 1600.0, eloGamesPlayed: 0,
    accessData: ACCESS_TAG,
  });

  return {
    uid: record.uid, email: data.email,
    displayName: data.displayName, firstName: data.firstName, lastName: data.lastName,
  };
}

async function createFriendships(users: AccessUser[]): Promise<void> {
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
        accessData: ACCESS_TAG,
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

async function createGroup(users: AccessUser[]): Promise<string> {
  console.log("\n🏐 CREATING GROUP\n" + "=".repeat(50));
  const now = admin.firestore.Timestamp.now();
  const ref = db.collection("groups").doc();

  await ref.set({
    name:        "Zurich Volleyball Club",
    description: "Casual beach volleyball group meeting weekly at Letten and Allmend.",
    photoUrl:    null,
    createdBy:   users[0].uid, // Alex
    createdAt: now, updatedAt: now,
    memberIds:   users.map((u) => u.uid),
    adminIds:    [users[0].uid],
    gameIds:     [],
    privacy: "private", requiresApproval: false, maxMembers: 20,
    location: "Zürich, Switzerland",
    allowMembersToCreateGames: true, allowMembersToInviteOthers: true,
    notifyMembersOfNewGames: true,
    totalGamesPlayed: 0, lastActivity: now,
    accessData: ACCESS_TAG,
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
  sets: { teamAPoints: number; teamBPoints: number }[],
  title: string,
  location: typeof LOCATIONS[keyof typeof LOCATIONS],
  createdBy: string
): Promise<string> {
  const ref = db.collection("games").doc();
  const teamAWins =
    sets.filter((s) => s.teamAPoints > s.teamBPoints).length >
    sets.filter((s) => s.teamBPoints > s.teamAPoints).length;

  await ref.set({
    title,
    description: "Great game with the crew!",
    groupId, createdBy,
    createdAt:   admin.firestore.Timestamp.fromDate(gameDate),
    updatedAt:   admin.firestore.Timestamp.fromDate(gameDate),
    scheduledAt: admin.firestore.Timestamp.fromDate(gameDate),
    location,
    status: "scheduled",
    maxPlayers: 4, minPlayers: 4,
    playerIds: [...teamA, ...teamB],
    waitlistIds: [],
    allowWaitlist: true, allowPlayerInvites: true,
    visibility: "group",
    equipment: ["net", "ball"],
    gameType: "beach_volleyball", skillLevel: "intermediate",
    weatherDependent: true, eloCalculated: false,
    accessData: ACCESS_TAG,
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
        sets: sets.map((s, i) => ({
          setNumber: i + 1,
          teamAPoints: s.teamAPoints,
          teamBPoints: s.teamBPoints,
        })),
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
  description: string,
  playerIds: string[],
  createdBy: string,
  location: typeof LOCATIONS[keyof typeof LOCATIONS]
): Promise<string> {
  const ref  = db.collection("games").doc();
  const date = new Date(Date.now() + daysFromNow * 24 * 60 * 60_000);

  await ref.set({
    title, description,
    groupId, createdBy,
    createdAt:   admin.firestore.Timestamp.now(),
    updatedAt:   admin.firestore.Timestamp.now(),
    scheduledAt: admin.firestore.Timestamp.fromDate(date),
    location,
    status: "scheduled",
    maxPlayers: 4, minPlayers: 4,
    playerIds,
    waitlistIds: [],
    allowWaitlist: true, allowPlayerInvites: true,
    visibility: "group",
    equipment: ["net", "ball"],
    gameType: "beach_volleyball", skillLevel: "intermediate",
    weatherDependent: true, eloCalculated: false,
    accessData: ACCESS_TAG,
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
  console.log(`  ✅ Backdated ${fixed} rating history entries`);
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
  location: typeof LOCATIONS[keyof typeof LOCATIONS]
): Promise<string> {
  const ref = db.collection("trainingSessions").doc();
  const now = admin.firestore.Timestamp.now();

  await ref.set({
    groupId, title, description, location,
    startTime:       admin.firestore.Timestamp.fromDate(startTime),
    endTime:         admin.firestore.Timestamp.fromDate(endTime),
    minParticipants: 3,
    maxParticipants,
    createdBy,
    createdAt: now, updatedAt: now,
    status,
    participantIds,
    notes: null, recurrenceRule: null, parentSessionId: null,
    accessData: ACCESS_TAG,
  });

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

  return ref.id;
}

async function addExercise(
  sessionId: string, name: string, description: string, durationMinutes: number
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
// Orchestration
// ---------------------------------------------------------------------------

async function seedPastGames(groupId: string, U: AccessUser[]): Promise<string[]> {
  console.log("\n🎮 CREATING PAST COMPLETED GAMES\n" + "=".repeat(50));

  const now  = Date.now();
  const ids: string[] = [];

  const schedule = [
    {
      teamA: [U[0].uid, U[1].uid], teamB: [U[2].uid, U[3].uid],
      sets: [{ teamAPoints: 21, teamBPoints: 17 }],
      daysAgo: 21, title: "Sunday Game at Letten",
      loc: LOCATIONS.letten, createdBy: U[0].uid,
    },
    {
      teamA: [U[0].uid, U[2].uid], teamB: [U[1].uid, U[4].uid],
      sets: [{ teamAPoints: 18, teamBPoints: 21 }],
      daysAgo: 14, title: "Wednesday Evening at Allmend",
      loc: LOCATIONS.allmend, createdBy: U[0].uid,
    },
    {
      teamA: [U[0].uid, U[3].uid], teamB: [U[2].uid, U[4].uid],
      sets: [{ teamAPoints: 21, teamBPoints: 19 }, { teamAPoints: 15, teamBPoints: 21 }, { teamAPoints: 15, teamBPoints: 12 }],
      daysAgo: 7, title: "Best of 3 at Letten",
      loc: LOCATIONS.letten, createdBy: U[0].uid,
    },
    {
      teamA: [U[1].uid, U[4].uid], teamB: [U[0].uid, U[2].uid],
      sets: [{ teamAPoints: 21, teamBPoints: 15 }],
      daysAgo: 2, title: "Saturday Doubles at Allmend",
      loc: LOCATIONS.allmend, createdBy: U[1].uid,
    },
  ];

  for (const g of schedule) {
    const date = new Date(now - g.daysAgo * 24 * 60 * 60_000);
    const id = await createCompletedGame(
      groupId, date, g.teamA, g.teamB, g.sets, g.title, g.loc, g.createdBy
    );
    ids.push(id);
    const winner =
      g.sets.filter((s) => s.teamAPoints > s.teamBPoints).length >
      g.sets.filter((s) => s.teamBPoints > s.teamAPoints).length
        ? "Team A" : "Team B";
    console.log(`  ✅ ${g.title} (${g.daysAgo}d ago) — ${winner} won`);
  }

  return ids;
}

async function seedFutureGames(groupId: string, U: AccessUser[]): Promise<string[]> {
  console.log("\n📅 CREATING FUTURE SCHEDULED GAMES\n" + "=".repeat(50));

  const ids: string[] = [];

  ids.push(await createFutureGame(
    groupId, 3,
    "Weekend Game at Letten",
    "Saturday afternoon doubles — come join us!",
    [U[0].uid, U[1].uid, U[2].uid, U[3].uid], U[0].uid,
    LOCATIONS.letten
  ));
  console.log(`  ✅ Weekend Game at Letten (+3 days)`);

  ids.push(await createFutureGame(
    groupId, 10,
    "Allmend Evening Game",
    "Classic Wednesday session. All levels welcome.",
    [U[0].uid, U[2].uid, U[3].uid, U[4].uid], U[0].uid,
    LOCATIONS.allmend
  ));
  console.log(`  ✅ Allmend Evening Game (+10 days)`);

  return ids;
}

async function seedPastTrainingSessions(groupId: string, U: AccessUser[]): Promise<string[]> {
  console.log("\n🏋️  CREATING PAST TRAINING SESSIONS\n" + "=".repeat(50));

  const now = Date.now();
  const ids: string[] = [];

  const make = (
    daysAgo: number, title: string, desc: string,
    participants: string[],
    loc: typeof LOCATIONS[keyof typeof LOCATIONS]
  ) => {
    const start = new Date(now - daysAgo * 24 * 60 * 60_000);
    const end   = new Date(start.getTime() + 2 * 60 * 60_000);
    return createTrainingSession(groupId, U[0].uid, title, desc, start, end, 8, "completed", participants, loc);
  };

  ids.push(await make(
    15, "Serving & Passing Basics",
    "Improve your serve consistency and platform passing technique.",
    [U[0].uid, U[1].uid, U[2].uid, U[3].uid, U[4].uid],
    LOCATIONS.letten
  ));
  console.log(`  ✅ Serving & Passing Basics (15 days ago)`);

  ids.push(await make(
    5, "Attack & Defense Drills",
    "Work on your approach, spike, and defensive positioning.",
    [U[0].uid, U[1].uid, U[2].uid, U[4].uid],
    LOCATIONS.allmend
  ));
  console.log(`  ✅ Attack & Defense Drills (5 days ago)`);

  return ids;
}

async function seedFutureTrainingSessions(groupId: string, U: AccessUser[]): Promise<string[]> {
  console.log("\n📅 CREATING FUTURE TRAINING SESSION\n" + "=".repeat(50));

  const now   = Date.now();
  const start = new Date(now + 5 * 24 * 60 * 60_000);
  const end   = new Date(start.getTime() + 2 * 60 * 60_000);

  const id = await createTrainingSession(
    groupId, U[0].uid,
    "Tactics & Communication",
    "On-court communication, rotations, and decision-making under pressure.",
    start, end, 8, "scheduled",
    [U[0].uid, U[1].uid, U[2].uid, U[3].uid],
    LOCATIONS.letten
  );
  console.log(`  ✅ Tactics & Communication (+5 days)`);

  return [id];
}

async function addExercisesToSessions(pastIds: string[], futureIds: string[]): Promise<void> {
  console.log("\n🏋️  ADDING EXERCISES\n" + "=".repeat(50));

  // Past session 0 — Serving & Passing Basics
  const serveExercises: [string, string, number][] = [
    ["Warm-up & Mobility",     "Dynamic stretching and arm circles",                         15],
    ["Platform Passing Pairs", "Two-person passing — focus on platform angle and quiet arms", 25],
    ["Float Serve Lines",      "Target zones: deep corners and seam",                         25],
    ["Serve Receive Drill",    "Coach serves, player passes to target zone",                  20],
    ["Cool Down",              "Static stretching",                                           10],
  ];
  for (const [n, d, dur] of serveExercises) await addExercise(pastIds[0], n, d, dur);
  console.log(`  ✅ Serving & Passing Basics — ${serveExercises.length} exercises`);

  // Past session 1 — Attack & Defense
  const attackExercises: [string, string, number][] = [
    ["Approach Footwork",  "3-step approach without ball — build muscle memory",     15],
    ["Attack from Feed",   "Setter tosses, attacker reads and hits",                 30],
    ["Defensive Digging",  "Coach hits, player digs to setter position",             25],
    ["Scrimmage",          "Competitive points focusing on transition play",          30],
  ];
  for (const [n, d, dur] of attackExercises) await addExercise(pastIds[1], n, d, dur);
  console.log(`  ✅ Attack & Defense Drills — ${attackExercises.length} exercises`);

  // Future session — Tactics & Communication
  const tacticsExercises: [string, string, number][] = [
    ["Ball Calling Drill",      "Two players, one ball — practice calling clearly",    15],
    ["Rotation Walkthrough",    "Walk through offensive and defensive rotations",      25],
    ["Decision-Making Game",    "Quick-fire situations — call it before the coach",    20],
    ["Full Tactical Scrimmage", "Apply rotations and calls in live play",              45],
  ];
  for (const [n, d, dur] of tacticsExercises) await addExercise(futureIds[0], n, d, dur);
  console.log(`  ✅ Tactics & Communication — ${tacticsExercises.length} exercises`);
}

async function addFeedbackToSessions(pastIds: string[], U: AccessUser[]): Promise<void> {
  console.log("\n💬 ADDING FEEDBACK TO COMPLETED SESSIONS\n" + "=".repeat(50));

  // Session 0 — Serving & Passing Basics
  await addFeedback(pastIds[0], U[0].uid, 5, 3, 5, "Really helpful fundamentals session!");
  await addFeedback(pastIds[0], U[1].uid, 4, 3, 4, "Good pace, would love more serve receive.");
  await addFeedback(pastIds[0], U[2].uid, 5, 4, 5, null);
  console.log(`  ✅ Serving & Passing Basics — 3 feedback entries`);

  // Session 1 — Attack & Defense
  await addFeedback(pastIds[1], U[0].uid, 5, 5, 5, "Scrimmage at the end was great!");
  await addFeedback(pastIds[1], U[1].uid, 4, 5, 4, "Intense but worth it.");
  console.log(`  ✅ Attack & Defense Drills — 2 feedback entries`);
}

// ---------------------------------------------------------------------------
// Config export
// ---------------------------------------------------------------------------

async function exportConfig(
  users: AccessUser[],
  groupId: string,
  pastGameIds: string[],
  futureGameIds: string[],
  pastSessionIds: string[],
  futureSessionIds: string[]
): Promise<void> {
  const config = {
    timestamp: new Date().toISOString(),
    project:   "gatherli-prod",
    warning:   "ACCESS DATA — run cleanupAccessEnvironment.ts to delete everything here",
    credentials: { password: DEFAULT_PASSWORD },
    reviewerLogin: {
      email:    "access1@gatherli.org",
      password: DEFAULT_PASSWORD,
    },
    users: users.map((u, i) => ({
      index: i + 1, uid: u.uid,
      email: u.email, displayName: u.displayName,
    })),
    groupId,
    games:            { past: pastGameIds, future: futureGameIds },
    trainingSessions: { past: pastSessionIds, future: futureSessionIds },
  };

  const p = path.join(__dirname, "accessConfig.json");
  fs.writeFileSync(p, JSON.stringify(config, null, 2));
  console.log(`\n  ✅ Config saved → ${p}`);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main(): Promise<void> {
  const t0 = Date.now();

  console.log("\n" + "=".repeat(70));
  console.log("🔑 GATHERLI — ACCESS ENVIRONMENT SETUP  (gatherli-PROD)");
  console.log("=".repeat(70));
  console.log("\n⚠️  This script adds data to PRODUCTION but does NOT delete existing data.");
  console.log("    Run cleanupAccessEnvironment.ts when done.\n");

  console.log("\n👤 CREATING USERS\n" + "=".repeat(50));
  const users: AccessUser[] = [];
  for (const d of ACCESS_USERS) {
    const u = await createAccessUser(d);
    users.push(u);
    console.log(`  ✅ ${u.displayName} (${u.email})`);
  }

  await createFriendships(users);
  const groupId = await createGroup(users);

  const pastGameIds = await seedPastGames(groupId, users);

  console.log("\n⏳ Waiting 10s for ELO Cloud Functions to process...");
  await new Promise((r) => setTimeout(r, 10000));

  console.log("\n🔧 BACKDATING RATING HISTORY TIMESTAMPS\n" + "=".repeat(50));
  await fixRatingHistoryTimestamps(users.map((u) => u.uid));

  const futureGameIds    = await seedFutureGames(groupId, users);
  const pastSessionIds   = await seedPastTrainingSessions(groupId, users);
  const futureSessionIds = await seedFutureTrainingSessions(groupId, users);

  await addExercisesToSessions(pastSessionIds, futureSessionIds);
  await addFeedbackToSessions(pastSessionIds, users);

  const allGameIds = [...pastGameIds, ...futureGameIds];
  await db.collection("groups").doc(groupId).update({
    gameIds: allGameIds,
    totalGamesPlayed: pastGameIds.length,
    lastActivity: admin.firestore.FieldValue.serverTimestamp(),
  });

  await exportConfig(users, groupId, pastGameIds, futureGameIds, pastSessionIds, futureSessionIds);

  const secs = ((Date.now() - t0) / 1000).toFixed(1);
  console.log("\n" + "=".repeat(70));
  console.log(`🔑 ACCESS ENVIRONMENT READY  (${secs}s)`);
  console.log("=".repeat(70));
  console.log(`
📋 Reviewer login
   Email:    access1@gatherli.org
   Password: ${DEFAULT_PASSWORD}

📊 Data created
   • 5 users + 10 friendships
   • 1 group  "Zurich Volleyball Club"
   • ${pastGameIds.length} past completed games  → ELO history populated
   • ${futureGameIds.length} future scheduled games
   • ${pastSessionIds.length} past training sessions (with exercises + feedback)
   • ${futureSessionIds.length} future training session (with exercises)

🧹 Cleanup
   cd functions && npx ts-node scripts/cleanupAccessEnvironment.ts
`);
}

// Guard: prod only
const pid = admin.app().options.projectId;
if (pid !== "gatherli-prod") {
  console.error(`❌ This script targets gatherli-prod (current: ${pid})`);
  process.exit(1);
}

main()
  .then(() => process.exit(0))
  .catch((e) => { console.error("❌ Error:", e); process.exit(1); });

/**
 * Screenshot Environment Setup Script
 *
 * Creates a realistic, visually rich dataset in gatherli-PROD for taking
 * App Store and Play Store screenshots. Does NOT wipe existing production data —
 * it only adds new documents tagged with { screenshotData: true } so the
 * companion cleanup script can remove them precisely.
 *
 * What gets created:
 *  - 10 screenshot accounts ({name}@gatherli.org / password: Test1010)
 *  - 45 accepted friendships (complete social graph)
 *  - 1 group "Zurich Beach Crew"
 *  - 10 past completed games → triggers ELO Cloud Functions
 *  - 3 future scheduled games
 *  - 4 past completed training sessions (with exercises + feedback)
 *  - 3 future scheduled training sessions (with exercises)
 *
 * Locations used: Letten · Allmend · Sihlhölzli (Zurich)
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupScreenshotEnvironment.ts
 *
 * ⚠️  Runs against gatherli-PROD. Does NOT delete existing data.
 * Use cleanupScreenshotEnvironment.ts to remove everything created here.
 */

import * as admin from "firebase-admin";
import * as crypto from "crypto";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp({ projectId: "gatherli-prod" });

const db   = admin.firestore();
const auth = admin.auth();

const DEFAULT_PASSWORD      = "Test1010";
const PARTICIPANT_HASH_SALT = process.env.PARTICIPANT_HASH_SALT || "gatherli-feedback-salt-v1";
const SCREENSHOT_TAG        = true; // marker written to every created document

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface ScreenshotUser {
  uid: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
}

// ---------------------------------------------------------------------------
// Users
// ---------------------------------------------------------------------------

const SCREENSHOT_USERS = [
  { email: "marco@gatherli.org",    displayName: "Marco",    firstName: "Marco",    lastName: "Rossi"    },
  { email: "vincente@gatherli.org", displayName: "Vincente", firstName: "Vincente", lastName: "García"   },
  { email: "chak@gatherli.org",     displayName: "Chak",     firstName: "Chak",     lastName: "Patel"    },
  { email: "victor@gatherli.org",   displayName: "Victor",   firstName: "Victor",   lastName: "Müller"   },
  { email: "etienne@gatherli.org",  displayName: "Etienne",  firstName: "Etienne",  lastName: "Dubois"   },
  { email: "felix@gatherli.org",    displayName: "Felix",    firstName: "Felix",    lastName: "Weber"    },
  { email: "roberto@gatherli.org",  displayName: "Roberto",  firstName: "Roberto",  lastName: "Ferrari"  },
  { email: "thomas@gatherli.org",   displayName: "Thomas",   firstName: "Thomas",   lastName: "Keller"   },
  { email: "luca@gatherli.org",     displayName: "Luca",     firstName: "Luca",     lastName: "Bianchi"  },
  { email: "sara@gatherli.org",     displayName: "Sara",     firstName: "Sara",     lastName: "Schmid"   },
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
  sihlhoelzli: {
    name: "Sportanlage Sihlhölzli",
    address: "Manessestrasse 59, 8003 Zürich",
    latitude: 47.3623,
    longitude: 8.5194,
  },
};

// ---------------------------------------------------------------------------
// Helpers — users & social graph
// ---------------------------------------------------------------------------

async function createScreenshotUser(data: typeof SCREENSHOT_USERS[0]): Promise<ScreenshotUser> {
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
    screenshotData: SCREENSHOT_TAG,
  });

  return {
    uid: record.uid, email: data.email,
    displayName: data.displayName, firstName: data.firstName, lastName: data.lastName,
  };
}

async function createFriendships(users: ScreenshotUser[]): Promise<void> {
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
        screenshotData: SCREENSHOT_TAG,
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

async function createGroup(users: ScreenshotUser[]): Promise<string> {
  console.log("\n🏐 CREATING GROUP\n" + "=".repeat(50));
  const now = admin.firestore.Timestamp.now();
  const ref = db.collection("groups").doc();

  await ref.set({
    name:        "Zurich Beach Crew",
    description: "Weekly beach volleyball at Letten, Allmend & Sihlhölzli. All levels welcome!",
    photoUrl:    null,
    createdBy:   users[4].uid, // Etienne
    createdAt: now, updatedAt: now,
    memberIds:   users.map((u) => u.uid),
    adminIds:    [users[4].uid],
    gameIds:     [],
    privacy: "private", requiresApproval: false, maxMembers: 20,
    location: "Zürich, Switzerland",
    allowMembersToCreateGames: true, allowMembersToInviteOthers: true,
    notifyMembersOfNewGames: true,
    totalGamesPlayed: 0, lastActivity: now,
    screenshotData: SCREENSHOT_TAG,
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
  const ref     = db.collection("games").doc();
  const teamAWins = sets.filter((s) => s.teamAPoints > s.teamBPoints).length >
                    sets.filter((s) => s.teamBPoints > s.teamAPoints).length;

  await ref.set({
    title,
    description: "Great game with the crew!",
    groupId,
    createdBy,
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
    screenshotData: SCREENSHOT_TAG,
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
  location: typeof LOCATIONS[keyof typeof LOCATIONS],
  skillLevel = "intermediate"
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
    gameType: "beach_volleyball", skillLevel,
    weatherDependent: true, eloCalculated: false,
    screenshotData: SCREENSHOT_TAG,
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
    screenshotData: SCREENSHOT_TAG,
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
// Orchestration — past games
// ---------------------------------------------------------------------------

async function seedPastGames(groupId: string, U: ScreenshotUser[]): Promise<string[]> {
  console.log("\n🎮 CREATING PAST COMPLETED GAMES\n" + "=".repeat(50));

  const now = Date.now();
  const ids: string[] = [];

  const schedule: {
    teamA: string[]; teamB: string[];
    sets: { teamAPoints: number; teamBPoints: number }[];
    daysAgo: number; title: string;
    loc: typeof LOCATIONS[keyof typeof LOCATIONS];
    createdBy: string;
  }[] = [
    {
      teamA: [U[4].uid, U[0].uid], teamB: [U[1].uid, U[5].uid],
      sets: [{ teamAPoints: 21, teamBPoints: 18 }],
      daysAgo: 60, title: "Sunday Doubles at Letten",
      loc: LOCATIONS.letten, createdBy: U[4].uid,
    },
    {
      teamA: [U[2].uid, U[3].uid], teamB: [U[6].uid, U[7].uid],
      sets: [{ teamAPoints: 21, teamBPoints: 15 }],
      daysAgo: 52, title: "Allmend Evening Match",
      loc: LOCATIONS.allmend, createdBy: U[2].uid,
    },
    {
      teamA: [U[4].uid, U[8].uid], teamB: [U[0].uid, U[9].uid],
      sets: [{ teamAPoints: 17, teamBPoints: 21 }],
      daysAgo: 45, title: "Wednesday Game at Sihlhölzli",
      loc: LOCATIONS.sihlhoelzli, createdBy: U[4].uid,
    },
    {
      teamA: [U[1].uid, U[5].uid], teamB: [U[2].uid, U[6].uid],
      sets: [{ teamAPoints: 21, teamBPoints: 19 }, { teamAPoints: 18, teamBPoints: 21 }, { teamAPoints: 15, teamBPoints: 12 }],
      daysAgo: 38, title: "Best of 3 at Letten",
      loc: LOCATIONS.letten, createdBy: U[1].uid,
    },
    {
      teamA: [U[4].uid, U[3].uid], teamB: [U[7].uid, U[8].uid],
      sets: [{ teamAPoints: 21, teamBPoints: 14 }],
      daysAgo: 30, title: "Saturday Morning Game",
      loc: LOCATIONS.allmend, createdBy: U[4].uid,
    },
    {
      teamA: [U[0].uid, U[9].uid], teamB: [U[1].uid, U[4].uid],
      sets: [{ teamAPoints: 19, teamBPoints: 21 }],
      daysAgo: 23, title: "Crew Classic at Sihlhölzli",
      loc: LOCATIONS.sihlhoelzli, createdBy: U[0].uid,
    },
    {
      teamA: [U[4].uid, U[6].uid], teamB: [U[2].uid, U[5].uid],
      sets: [{ teamAPoints: 21, teamBPoints: 16 }],
      daysAgo: 18, title: "Thursday Showdown",
      loc: LOCATIONS.letten, createdBy: U[4].uid,
    },
    {
      teamA: [U[3].uid, U[7].uid], teamB: [U[8].uid, U[9].uid],
      sets: [{ teamAPoints: 15, teamBPoints: 21 }],
      daysAgo: 12, title: "Allmend Sunday Game",
      loc: LOCATIONS.allmend, createdBy: U[3].uid,
    },
    {
      teamA: [U[4].uid, U[1].uid], teamB: [U[0].uid, U[3].uid],
      sets: [{ teamAPoints: 21, teamBPoints: 17 }],
      daysAgo: 6, title: "Mid-Week Match at Letten",
      loc: LOCATIONS.letten, createdBy: U[4].uid,
    },
    {
      teamA: [U[5].uid, U[2].uid], teamB: [U[6].uid, U[4].uid],
      sets: [{ teamAPoints: 18, teamBPoints: 21 }],
      daysAgo: 2, title: "Last Game at Sihlhölzli",
      loc: LOCATIONS.sihlhoelzli, createdBy: U[5].uid,
    },
  ];

  for (const g of schedule) {
    const date = new Date(now - g.daysAgo * 24 * 60 * 60_000);
    const id = await createCompletedGame(
      groupId, date, g.teamA, g.teamB, g.sets, g.title, g.loc, g.createdBy
    );
    ids.push(id);
    const winner = g.sets.filter((s) => s.teamAPoints > s.teamBPoints).length >
                   g.sets.filter((s) => s.teamBPoints > s.teamAPoints).length
                   ? "Team A" : "Team B";
    console.log(`  ✅ ${g.title} (${g.daysAgo}d ago) — ${winner} won`);
  }

  return ids;
}

// ---------------------------------------------------------------------------
// Orchestration — future games
// ---------------------------------------------------------------------------

async function seedFutureGames(groupId: string, U: ScreenshotUser[]): Promise<string[]> {
  console.log("\n📅 CREATING FUTURE SCHEDULED GAMES\n" + "=".repeat(50));

  const ids: string[] = [];

  ids.push(await createFutureGame(
    groupId, 2,
    "Weekend Doubles at Letten",
    "Come join us for a great Saturday morning session at Letten!",
    [U[4].uid, U[0].uid, U[1].uid, U[5].uid], U[4].uid,
    LOCATIONS.letten
  ));
  console.log(`  ✅ Weekend Doubles at Letten (+2 days)`);

  ids.push(await createFutureGame(
    groupId, 6,
    "Allmend Evening Game",
    "Classic Wednesday evening game. Bring water!",
    [U[2].uid, U[3].uid, U[6].uid, U[7].uid], U[2].uid,
    LOCATIONS.allmend
  ));
  console.log(`  ✅ Allmend Evening Game (+6 days)`);

  ids.push(await createFutureGame(
    groupId, 14,
    "Sihlhölzli Sunday Championship",
    "Monthly title match — all members welcome to watch!",
    [U[4].uid, U[8].uid, U[9].uid, U[1].uid], U[4].uid,
    LOCATIONS.sihlhoelzli, "advanced"
  ));
  console.log(`  ✅ Sihlhölzli Sunday Championship (+14 days)`);

  return ids;
}

// ---------------------------------------------------------------------------
// Orchestration — training sessions
// ---------------------------------------------------------------------------

async function seedPastTrainingSessions(groupId: string, U: ScreenshotUser[]): Promise<string[]> {
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
    return createTrainingSession(
      groupId, U[4].uid, title, desc, start, end, 10, "completed", participants, loc
    );
  };

  ids.push(await make(
    28, "Passing & Serving Fundamentals",
    "Back to basics — perfect your platform pass and find your serve consistency.",
    [U[0].uid, U[1].uid, U[2].uid, U[4].uid, U[5].uid, U[8].uid],
    LOCATIONS.letten
  ));
  console.log(`  ✅ Passing & Serving Fundamentals (28 days ago)`);

  ids.push(await make(
    18, "Block & Defense Workshop",
    "Focus on reading the attacker, timing your block, and covering court efficiently.",
    [U[0].uid, U[2].uid, U[3].uid, U[4].uid, U[6].uid, U[7].uid, U[9].uid],
    LOCATIONS.allmend
  ));
  console.log(`  ✅ Block & Defense Workshop (18 days ago)`);

  ids.push(await make(
    9, "Attack & Transition Drills",
    "Improve your approach, snap, and the transition from defense to attack.",
    [U[1].uid, U[2].uid, U[4].uid, U[5].uid, U[6].uid],
    LOCATIONS.sihlhoelzli
  ));
  console.log(`  ✅ Attack & Transition Drills (9 days ago)`);

  ids.push(await make(
    3, "Match Simulation",
    "Full competitive sets with coaching stops — simulate tournament pressure.",
    [U[0].uid, U[1].uid, U[3].uid, U[4].uid, U[7].uid, U[8].uid, U[9].uid],
    LOCATIONS.letten
  ));
  console.log(`  ✅ Match Simulation (3 days ago)`);

  return ids;
}

async function seedFutureTrainingSessions(groupId: string, U: ScreenshotUser[]): Promise<string[]> {
  console.log("\n📅 CREATING FUTURE TRAINING SESSIONS\n" + "=".repeat(50));

  const now = Date.now();
  const ids: string[] = [];

  const make = (
    daysFromNow: number, title: string, desc: string,
    participants: string[], maxParticipants: number,
    loc: typeof LOCATIONS[keyof typeof LOCATIONS]
  ) => {
    const start = new Date(now + daysFromNow * 24 * 60 * 60_000);
    const end   = new Date(start.getTime() + 2 * 60 * 60_000);
    return createTrainingSession(
      groupId, U[4].uid, title, desc, start, end,
      maxParticipants, "scheduled", participants, loc
    );
  };

  ids.push(await make(
    3, "Serving Masterclass",
    "Master float, topspin, and jump serves with targeted drills.",
    [U[0].uid, U[1].uid, U[4].uid, U[5].uid, U[8].uid], 10,
    LOCATIONS.allmend
  ));
  console.log(`  ✅ Serving Masterclass (+3 days)`);

  ids.push(await make(
    7, "Communication & Tactics",
    "Improve on-court communication, rotations, and split-second decision making.",
    [U[2].uid, U[3].uid, U[4].uid, U[6].uid, U[7].uid, U[9].uid], 8,
    LOCATIONS.sihlhoelzli
  ));
  console.log(`  ✅ Communication & Tactics (+7 days)`);

  ids.push(await make(
    12, "Open Training",
    "Open session — bring your friends, work on your game, have fun.",
    [U[0].uid, U[1].uid, U[2].uid, U[3].uid, U[4].uid], 12,
    LOCATIONS.letten
  ));
  console.log(`  ✅ Open Training (+12 days)`);

  return ids;
}

async function addExercisesToSessions(
  pastIds: string[], futureIds: string[]
): Promise<void> {
  console.log("\n🏋️  ADDING EXERCISES\n" + "=".repeat(50));

  // Past session 0 — Passing & Serving Fundamentals
  const passingExercises: [string, string, number][] = [
    ["Warm-up & Mobility",      "Dynamic stretching, arm circles, hip openers",             15],
    ["Platform Passing Basics",  "Pairs passing — focus on platform angle and quiet arms",   25],
    ["Serve Receive Lines",      "3-person pepper drill with serve receive rotation",         25],
    ["Float Serve Practice",     "Target zones: deep corners and seam between defenders",     20],
    ["Cool Down & Stretching",   "Static stretching and cool down",                          10],
  ];
  for (const [n, d, dur] of passingExercises) await addExercise(pastIds[0], n, d, dur);
  console.log(`  ✅ Passing & Serving Fundamentals — ${passingExercises.length} exercises`);

  // Past session 1 — Block & Defense Workshop
  const defenseExercises: [string, string, number][] = [
    ["Footwork & Positioning",   "Defensive stance, lateral movement, and recovery steps",   20],
    ["Block Timing Drill",       "Attack from box — focus on hands over the net",             25],
    ["Digging Lines",            "Coach hits, player digs to setter position",                25],
    ["Cover & Transition",       "Partner attacks, one blocks, one covers — rotate",          20],
    ["Competitive Defence Sets", "Full defensive points with coach feedback",                 25],
  ];
  for (const [n, d, dur] of defenseExercises) await addExercise(pastIds[1], n, d, dur);
  console.log(`  ✅ Block & Defense Workshop — ${defenseExercises.length} exercises`);

  // Past session 2 — Attack & Transition
  const attackExercises: [string, string, number][] = [
    ["Approach Footwork",        "3-step and 4-step approach without ball",                  15],
    ["Wall Spiking",             "Approach, jump, snap — consistent arm swing",              20],
    ["Attack from Feed",         "Setter tosses, attacker reads and hits",                   30],
    ["Defence to Attack",        "Dig → set → attack in continuous flow",                    25],
    ["Scrimmage",                "Competitive points focusing on transition",                 30],
  ];
  for (const [n, d, dur] of attackExercises) await addExercise(pastIds[2], n, d, dur);
  console.log(`  ✅ Attack & Transition Drills — ${attackExercises.length} exercises`);

  // Past session 3 — Match Simulation
  const matchExercises: [string, string, number][] = [
    ["Warm-up Pepper",           "Partner rally — build rhythm and timing",                  15],
    ["Pressure Serving",         "Serve with score consequence — must land in target",        20],
    ["Competitive Sets to 15",   "Full sets with coaching stops on key decisions",            45],
    ["Cool Down",                "Team debrief and stretching",                              10],
  ];
  for (const [n, d, dur] of matchExercises) await addExercise(pastIds[3], n, d, dur);
  console.log(`  ✅ Match Simulation — ${matchExercises.length} exercises`);

  // Future session 0 — Serving Masterclass
  const servingExercises: [string, string, number][] = [
    ["Float Serve Mechanics",    "Grip, contact point, and follow-through for float serve",  25],
    ["Topspin Serve Technique",  "Brushing contact, wrist snap, and target practice",        25],
    ["Jump Serve Introduction",  "Approach, toss placement, and power transfer",             25],
    ["Serve Pressure Game",      "Competitive serving with score — first to 10 wins",        25],
  ];
  for (const [n, d, dur] of servingExercises) await addExercise(futureIds[0], n, d, dur);
  console.log(`  ✅ Serving Masterclass — ${servingExercises.length} exercises`);

  // Future session 1 — Communication & Tactics
  const tacticsExercises: [string, string, number][] = [
    ["Ball Calling Drill",       "Two players, one ball — practice calling clearly",         15],
    ["Rotation Patterns",        "Walk through offensive and defensive rotations",           25],
    ["Decision-Making Game",     "Quick-fire situations — call it before the coach does",    20],
    ["Full Tactical Scrimmage",  "Apply rotations and calls in live play",                   45],
  ];
  for (const [n, d, dur] of tacticsExercises) await addExercise(futureIds[1], n, d, dur);
  console.log(`  ✅ Communication & Tactics — ${tacticsExercises.length} exercises`);

  // Future session 2 — Open Training
  const openExercises: [string, string, number][] = [
    ["Free Warm-up",             "Individual warm-up at own pace",                           15],
    ["Skill Focus Stations",     "Rotate between serving, passing, and setting stations",    40],
    ["Free Play",                "Casual games — pick your partner and play",                60],
  ];
  for (const [n, d, dur] of openExercises) await addExercise(futureIds[2], n, d, dur);
  console.log(`  ✅ Open Training — ${openExercises.length} exercises`);
}

async function addFeedbackToSessions(
  pastIds: string[], U: ScreenshotUser[]
): Promise<void> {
  console.log("\n💬 ADDING FEEDBACK TO COMPLETED SESSIONS\n" + "=".repeat(50));

  // Session 0 — Passing & Serving Fundamentals
  await addFeedback(pastIds[0], U[0].uid, 5, 3, 5, "Really helped me clean up my platform technique!");
  await addFeedback(pastIds[0], U[1].uid, 4, 3, 4, "Good pace for a fundamentals session.");
  await addFeedback(pastIds[0], U[2].uid, 5, 4, 5, null);
  await addFeedback(pastIds[0], U[5].uid, 4, 3, 4, "Would love more serve receive next time.");
  console.log(`  ✅ Passing & Serving Fundamentals — 4 feedback entries`);

  // Session 1 — Block & Defense Workshop
  await addFeedback(pastIds[1], U[0].uid, 5, 5, 5, "Best training session we've had. My blocking timing improved a lot!");
  await addFeedback(pastIds[1], U[2].uid, 5, 4, 5, "Great drills. The cover & transition exercise was super useful.");
  await addFeedback(pastIds[1], U[3].uid, 4, 5, 4, null);
  await addFeedback(pastIds[1], U[6].uid, 5, 5, 5, "Loved the competitive defence sets at the end.");
  await addFeedback(pastIds[1], U[7].uid, 4, 4, 4, "Solid session, well organised.");
  console.log(`  ✅ Block & Defense Workshop — 5 feedback entries`);

  // Session 2 — Attack & Transition
  await addFeedback(pastIds[2], U[1].uid, 5, 5, 4, "My approach finally clicks. Thanks for the individual feedback!");
  await addFeedback(pastIds[2], U[2].uid, 4, 5, 4, "Intense but worth it. Scrimmage at the end was fire.");
  await addFeedback(pastIds[2], U[5].uid, 5, 4, 5, null);
  console.log(`  ✅ Attack & Transition Drills — 3 feedback entries`);

  // Session 3 — Match Simulation
  await addFeedback(pastIds[3], U[0].uid, 5, 5, 5, "Game-like pressure is exactly what we needed before the next tournament.");
  await addFeedback(pastIds[3], U[1].uid, 5, 5, 4, "Loved the coaching stops — really made me think.");
  await addFeedback(pastIds[3], U[3].uid, 4, 5, 4, null);
  await addFeedback(pastIds[3], U[7].uid, 5, 5, 5, "Best format for this group. Let's do it monthly.");
  await addFeedback(pastIds[3], U[8].uid, 4, 4, 4, "Good session. Pressure serving drill was tough but fun.");
  console.log(`  ✅ Match Simulation — 5 feedback entries`);
}

// ---------------------------------------------------------------------------
// Config export
// ---------------------------------------------------------------------------

async function exportConfig(
  users: ScreenshotUser[],
  groupId: string,
  pastGameIds: string[],
  futureGameIds: string[],
  pastSessionIds: string[],
  futureSessionIds: string[]
): Promise<void> {
  const config = {
    timestamp:   new Date().toISOString(),
    project:     "gatherli-prod",
    warning:     "SCREENSHOT DATA — run cleanupScreenshotEnvironment.ts to delete everything here",
    credentials: { password: DEFAULT_PASSWORD },
    users: users.map((u, i) => ({
      index: i + 1, uid: u.uid,
      email: u.email, displayName: u.displayName,
    })),
    groupId,
    games:            { past: pastGameIds, future: futureGameIds },
    trainingSessions: { past: pastSessionIds, future: futureSessionIds },
  };

  const p = path.join(__dirname, "screenshotConfig.json");
  fs.writeFileSync(p, JSON.stringify(config, null, 2));
  console.log(`\n  ✅ Config saved → ${p}`);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const t0 = Date.now();

  console.log("\n" + "=".repeat(70));
  console.log("📸 GATHERLI — SCREENSHOT ENVIRONMENT SETUP  (gatherli-PROD)");
  console.log("=".repeat(70));
  console.log("\n⚠️  This script adds data to PRODUCTION but does NOT delete existing data.");
  console.log("    Run cleanupScreenshotEnvironment.ts when screenshots are done.\n");

  console.log("\n👤 CREATING USERS\n" + "=".repeat(50));
  const users: ScreenshotUser[] = [];
  for (const d of SCREENSHOT_USERS) {
    const u = await createScreenshotUser(d);
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
  console.log(`📸 SCREENSHOT ENVIRONMENT READY  (${secs}s)`);
  console.log("=".repeat(70));
  console.log(`
📋 Login credentials
   Email:    etienne@gatherli.org
   Password: ${DEFAULT_PASSWORD}
   (or any {name}@gatherli.org account)

📊 Data created
   • 10 users + 45 friendships
   • 1 group  "Zurich Beach Crew"
   • ${pastGameIds.length} past completed games  → ELO history populated
   • ${futureGameIds.length} future scheduled games
   • ${pastSessionIds.length} past training sessions (with exercises + feedback)
   • ${futureSessionIds.length} future training sessions (with exercises)

📍 Locations used
   • Flussbad Letten, Zürich
   • Sportanlage Allmend, Zürich
   • Sportanlage Sihlhölzli, Zürich

🧹 Cleanup
   cd functions && npx ts-node scripts/cleanupScreenshotEnvironment.ts
`);
}

// Guard: prod only for this script
const pid = admin.app().options.projectId;
if (pid !== "gatherli-prod") {
  console.error(`❌ This script targets gatherli-prod (current: ${pid})`);
  process.exit(1);
}

main()
  .then(() => process.exit(0))
  .catch((e) => { console.error("❌ Error:", e); process.exit(1); });

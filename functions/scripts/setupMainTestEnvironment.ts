/**
 * Main Test Environment Setup Script
 *
 * The canonical seeding script for gatherli-dev.  Replaces the need to run
 * multiple environment scripts separately.  Outputs to testConfig.json so
 * every other script in this folder that uses testConfigLoader.ts continues
 * to work unchanged.
 *
 * What gets created
 * ─────────────────
 *  15 test users
 *    test1–5   → gender: male    (test1@mysta.com … test5@mysta.com)
 *    test6–10  → gender: female  (test6@mysta.com … test10@mysta.com)
 *    test11–15 → gender: none    (test11@mysta.com … test15@mysta.com)
 *
 *  105 accepted friendships (complete social graph)
 *
 *  1 group with all 15 members
 *
 *  Past completed games  (spread over ~6 months so ELO chart has history)
 *    12 male-only games   → ELO changes for test1–5
 *    12 female-only games → ELO changes for test6–10
 *    10 mixed games       → NO ELO change (skipped by Cloud Function)
 *
 *  4 future scheduled games (one male, one female, one mixed, one open)
 *
 * Expected outcome
 * ────────────────
 *  test1  – strong record  → ELO well above 1200
 *  test5  – weak record    → ELO well below 1200
 *  test6  – strong record  → ELO well above 1200
 *  test10 – weak record    → ELO well below 1200
 *  test11–15 → ELO stays flat at 1200 (only played mixed games)
 *  Mixed-game eloUpdates field stays empty / eloCalculated skipped
 *
 * Usage
 * ─────
 *   cd functions
 *   npx ts-node scripts/setupMainTestEnvironment.ts
 *
 * ⚠️  WARNING: Deletes ALL data in gatherli-dev before seeding!
 */

import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp({ projectId: "gatherli-dev" });

const db   = admin.firestore();
const auth = admin.auth();

const DEFAULT_PASSWORD = "test1010";

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

type Gender        = "male" | "female" | "none";
type GameGenderType = "male" | "female" | "mix";

interface TestUser {
  uid:         string;
  email:       string;
  displayName: string;
  firstName:   string;
  lastName:    string;
  gender:      Gender;
}

// ─────────────────────────────────────────────────────────────────────────────
// User definitions
// ─────────────────────────────────────────────────────────────────────────────

const TEST_USERS: Omit<TestUser, "uid">[] = [
  // Male users (test1–5)
  { email: "test1@mysta.com",  displayName: "Test1",  firstName: "Test", lastName: "One",      gender: "male"   },
  { email: "test2@mysta.com",  displayName: "Test2",  firstName: "Test", lastName: "Two",      gender: "male"   },
  { email: "test3@mysta.com",  displayName: "Test3",  firstName: "Test", lastName: "Three",    gender: "male"   },
  { email: "test4@mysta.com",  displayName: "Test4",  firstName: "Test", lastName: "Four",     gender: "male"   },
  { email: "test5@mysta.com",  displayName: "Test5",  firstName: "Test", lastName: "Five",     gender: "male"   },
  // Female users (test6–10)
  { email: "test6@mysta.com",  displayName: "Test6",  firstName: "Test", lastName: "Six",      gender: "female" },
  { email: "test7@mysta.com",  displayName: "Test7",  firstName: "Test", lastName: "Seven",    gender: "female" },
  { email: "test8@mysta.com",  displayName: "Test8",  firstName: "Test", lastName: "Eight",    gender: "female" },
  { email: "test9@mysta.com",  displayName: "Test9",  firstName: "Test", lastName: "Nine",     gender: "female" },
  { email: "test10@mysta.com", displayName: "Test10", firstName: "Test", lastName: "Ten",      gender: "female" },
  // No-gender users (test11–15)
  { email: "test11@mysta.com", displayName: "Test11", firstName: "Test", lastName: "Eleven",   gender: "none"   },
  { email: "test12@mysta.com", displayName: "Test12", firstName: "Test", lastName: "Twelve",   gender: "none"   },
  { email: "test13@mysta.com", displayName: "Test13", firstName: "Test", lastName: "Thirteen", gender: "none"   },
  { email: "test14@mysta.com", displayName: "Test14", firstName: "Test", lastName: "Fourteen", gender: "none"   },
  { email: "test15@mysta.com", displayName: "Test15", firstName: "Test", lastName: "Fifteen",  gender: "none"   },
];

// ─────────────────────────────────────────────────────────────────────────────
// Database cleanup
// ─────────────────────────────────────────────────────────────────────────────

async function deleteCollection(collectionPath: string): Promise<number> {
  const ref   = db.collection(collectionPath);
  const query = ref.limit(500);
  let deleted = 0;

  return new Promise((resolve, reject) => {
    async function batchDelete(q: FirebaseFirestore.Query) {
      const snap = await q.get();
      if (snap.size === 0) { resolve(deleted); return; }
      const b = db.batch();
      snap.docs.forEach((d) => b.delete(d.ref));
      await b.commit();
      deleted += snap.size;
      process.nextTick(() => batchDelete(q));
    }
    batchDelete(query).catch(reject);
  });
}

async function clearDatabase(): Promise<void> {
  console.log("\n🗑️  CLEARING DATABASE\n" + "=".repeat(50));

  // Delete user subcollections first
  const userSnap = await db.collection("users").get();
  for (const doc of userSnap.docs) {
    await deleteCollection(`users/${doc.id}/headToHead`);
    await deleteCollection(`users/${doc.id}/ratingHistory`);
  }

  // Delete training session subcollections
  const sessionSnap = await db.collection("trainingSessions").get();
  for (const doc of sessionSnap.docs) {
    await deleteCollection(`trainingSessions/${doc.id}/participants`);
    await deleteCollection(`trainingSessions/${doc.id}/exercises`);
    await deleteCollection(`trainingSessions/${doc.id}/feedback`);
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

// ─────────────────────────────────────────────────────────────────────────────
// Users & social graph
// ─────────────────────────────────────────────────────────────────────────────

async function createTestUser(data: Omit<TestUser, "uid">): Promise<TestUser> {
  const record = await auth.createUser({
    email:         data.email,
    password:      DEFAULT_PASSWORD,
    displayName:   data.displayName,
    emailVerified: true,
  });
  const now = admin.firestore.Timestamp.now();
  await db.collection("users").doc(record.uid).set({
    email:                data.email,
    displayName:          data.displayName,
    firstName:            data.firstName,
    lastName:             data.lastName,
    gender:               data.gender,
    photoUrl:             null,
    isEmailVerified:      true,
    createdAt:            now,
    lastSignInAt:         now,
    updatedAt:            now,
    isAnonymous:          false,
    accountStatus:        "active",
    groupIds:             [],
    gameIds:              [],
    friendIds:            [],
    friendCount:          0,
    notificationsEnabled: true,
    emailNotifications:   true,
    pushNotifications:    true,
    privacyLevel:         "public",
    showEmail:            true,
    showPhoneNumber:      true,
    gamesPlayed:          0,
    gamesWon:             0,
    gamesLost:            0,
    totalScore:           0,
    currentStreak:        0,
    recentGameIds:        [],
    teammateStats:        {},
    eloRating:            1200.0,
    eloGamesPlayed:       0,
  });
  return { uid: record.uid, ...data };
}

async function createFriendships(users: TestUser[]): Promise<void> {
  console.log("\n👥 CREATING FRIENDSHIPS\n" + "=".repeat(50));
  const now   = admin.firestore.Timestamp.now();
  let   count = 0;

  const pairs: [TestUser, TestUser][] = [];
  for (let i = 0; i < users.length; i++) {
    for (let j = i + 1; j < users.length; j++) {
      pairs.push([users[i], users[j]]);
    }
  }

  for (let start = 0; start < pairs.length; start += 400) {
    const batch = db.batch();
    for (const [a, b] of pairs.slice(start, start + 400)) {
      const ref = db.collection("friendships").doc();
      batch.set(ref, {
        initiatorId:   a.uid, recipientId:   b.uid,
        initiatorName: a.displayName, recipientName: b.displayName,
        status: "accepted", createdAt: now, updatedAt: now,
      });
      count++;
    }
    await batch.commit();
  }

  // Update friend caches
  for (const user of users) {
    const friends = users.filter((u) => u.uid !== user.uid).map((u) => u.uid);
    await db.collection("users").doc(user.uid).update({
      friendIds: friends, friendCount: friends.length, friendsLastUpdated: now,
    });
  }
  console.log(`  ✅ Created ${count} friendships (complete social graph)`);
}

async function createGroup(users: TestUser[]): Promise<string> {
  console.log("\n🏐 CREATING GROUP\n" + "=".repeat(50));
  const now = admin.firestore.Timestamp.now();
  const ref = db.collection("groups").doc();

  await ref.set({
    name:        "Venice Beach All-Stars",
    description: "Mixed crew of male, female, and open players — main dev test environment.",
    photoUrl:    null,
    createdBy:   users[0].uid,
    createdAt:   now, updatedAt: now,
    memberIds:   users.map((u) => u.uid),
    adminIds:    [users[0].uid],
    gameIds:     [],
    privacy:              "private",
    requiresApproval:     false,
    maxMembers:           20,
    location:             "Venice Beach, CA",
    allowMembersToCreateGames:    true,
    allowMembersToInviteOthers:   true,
    notifyMembersOfNewGames:      true,
    totalGamesPlayed:     0,
    lastActivity:         now,
  });

  const batch = db.batch();
  for (const user of users) {
    batch.update(db.collection("users").doc(user.uid), {
      groupIds: admin.firestore.FieldValue.arrayUnion(ref.id),
    });
  }
  await batch.commit();
  console.log(`  ✅ Group "${ref.id}" created with ${users.length} members`);
  return ref.id;
}

// ─────────────────────────────────────────────────────────────────────────────
// Games
// ─────────────────────────────────────────────────────────────────────────────

async function createCompletedGame(
  groupId:       string,
  gameDate:      Date,
  teamA:         string[],
  teamB:         string[],
  teamAWins:     boolean,
  label:         string,
  genderType:    GameGenderType,
  teamAScore     = teamAWins ? 21 : 17,
  teamBScore     = teamAWins ? 17 : 21,
): Promise<string> {
  const ref = db.collection("games").doc();

  await ref.set({
    title:        label,
    description:  "Main test environment game",
    groupId,
    gameGenderType: genderType,
    createdBy:    teamA[0],
    createdAt:    admin.firestore.Timestamp.fromDate(gameDate),
    updatedAt:    admin.firestore.Timestamp.fromDate(gameDate),
    scheduledAt:  admin.firestore.Timestamp.fromDate(gameDate),
    location: {
      name:      "Venice Beach Court 3",
      address:   "1800 Ocean Front Walk, Venice, CA 90291",
      latitude:  33.985, longitude: -118.4695,
    },
    status:           "scheduled",
    maxPlayers:        4, minPlayers: 4,
    playerIds:        [...teamA, ...teamB],
    waitlistIds:      [],
    allowWaitlist:    true, allowPlayerInvites: true,
    visibility:       "group",
    equipment:        ["net", "ball"],
    gameType:         "beach_volleyball",
    skillLevel:       "intermediate",
    weatherDependent: true,
    eloCalculated:    false,
  });

  // Allow Cloud Functions time to see the "scheduled" creation before we mark complete
  await new Promise((r) => setTimeout(r, 400));

  await ref.update({
    status:      "completed",
    startedAt:   admin.firestore.Timestamp.fromDate(gameDate),
    completedAt: admin.firestore.Timestamp.fromDate(gameDate),
    endedAt:     admin.firestore.Timestamp.fromDate(
      new Date(gameDate.getTime() + 90 * 60_000)
    ),
    teams: { teamAPlayerIds: teamA, teamBPlayerIds: teamB },
    result: {
      games: [{
        gameNumber: 1,
        sets: [{ setNumber: 1, teamAPoints: teamAScore, teamBPoints: teamBScore }],
        winner: teamAWins ? "teamA" : "teamB",
      }],
      overallWinner: teamAWins ? "teamA" : "teamB",
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Give the ELO Cloud Function time to process before the next game
  await new Promise((r) => setTimeout(r, 800));
  return ref.id;
}

async function createFutureGame(
  groupId:    string,
  daysFromNow: number,
  title:      string,
  playerIds:  string[],
  createdBy:  string,
  genderType: GameGenderType,
): Promise<string> {
  const ref  = db.collection("games").doc();
  const date = new Date(Date.now() + daysFromNow * 24 * 60 * 60_000);

  await ref.set({
    title,
    description:      "Upcoming game — join us!",
    groupId,
    gameGenderType:   genderType,
    createdBy,
    createdAt:        admin.firestore.Timestamp.now(),
    updatedAt:        admin.firestore.Timestamp.now(),
    scheduledAt:      admin.firestore.Timestamp.fromDate(date),
    location: {
      name:     "Venice Beach Court 1",
      address:  "1800 Ocean Front Walk, Venice, CA 90291",
      latitude: 33.985, longitude: -118.4695,
    },
    status:           "scheduled",
    maxPlayers:        4, minPlayers: 4,
    playerIds,
    waitlistIds:      [],
    allowWaitlist:    true, allowPlayerInvites: true,
    visibility:       "group",
    equipment:        ["net", "ball"],
    gameType:         "beach_volleyball",
    skillLevel:       "intermediate",
    weatherDependent: true,
    eloCalculated:    false,
  });

  return ref.id;
}

// ─────────────────────────────────────────────────────────────────────────────
// Game schedules
// ─────────────────────────────────────────────────────────────────────────────

/**
 * 12 male-only games spread over ~6 months.
 *
 * Win/loss pattern designed so ELO diverges clearly:
 *   test1 — dominant performer   → highest ELO
 *   test2 — strong               → above average
 *   test3 — balanced             → near 1200
 *   test4 — below average        → slightly below 1200
 *   test5 — consistently loses   → lowest ELO
 */
async function seedMaleGames(groupId: string, M: TestUser[]): Promise<string[]> {
  const now = Date.now();
  const ids: string[] = [];

  // [teamA, teamB, teamAWins, daysAgo, label, scoreA, scoreB]
  const schedule: [TestUser[], TestUser[], boolean, number, string, number, number][] = [
    // 6 months ago
    [[M[0], M[1]], [M[2], M[3]], true,  180, "Men's League #1",   21, 14],
    [[M[0], M[2]], [M[3], M[4]], true,  165, "Men's League #2",   21, 15],
    // 4 months ago
    [[M[1], M[2]], [M[3], M[4]], true,  120, "Men's League #3",   21, 16],
    [[M[0], M[3]], [M[1], M[4]], true,  105, "Men's League #4",   21, 12],
    // 3 months ago
    [[M[2], M[4]], [M[0], M[1]], false,  90, "Men's League #5",   17, 21],
    [[M[3], M[4]], [M[0], M[2]], false,  75, "Men's League #6",   16, 21],
    // 2 months ago
    [[M[0], M[1]], [M[3], M[4]], true,   60, "Men's League #7",   21, 13],
    [[M[1], M[2]], [M[3], M[4]], true,   50, "Men's League #8",   21, 18],
    // 1 month ago
    [[M[0], M[2]], [M[3], M[4]], true,   35, "Men's League #9",   21, 11],
    [[M[1], M[3]], [M[2], M[4]], true,   25, "Men's League #10",  21, 17],
    // 2 weeks ago
    [[M[0], M[1]], [M[2], M[4]], true,   14, "Men's Playoffs SF", 21, 15],
    // 1 week ago
    [[M[0], M[2]], [M[1], M[3]], true,    7, "Men's Playoffs F",  21, 16],
  ];

  for (const [tA, tB, aWins, daysAgo, label, sA, sB] of schedule) {
    const date = new Date(now - daysAgo * 24 * 60 * 60_000);
    const id   = await createCompletedGame(
      groupId, date,
      tA.map((u) => u.uid), tB.map((u) => u.uid),
      aWins, label, "male", sA, sB,
    );
    ids.push(id);
    console.log(`  ✅ [♂ male]   ${label.padEnd(22)} ${daysAgo}d ago  ${aWins ? "Team A" : "Team B"} won  ${sA}–${sB}`);
  }
  return ids;
}

/**
 * 12 female-only games spread over ~6 months.
 *
 * Win/loss pattern:
 *   test6  — dominant   → highest ELO
 *   test7  — strong     → above average
 *   test8  — balanced   → near 1200
 *   test9  — below avg  → slightly below 1200
 *   test10 — loses most → lowest ELO
 */
async function seedFemaleGames(groupId: string, F: TestUser[]): Promise<string[]> {
  const now = Date.now();
  const ids: string[] = [];

  const schedule: [TestUser[], TestUser[], boolean, number, string, number, number][] = [
    [[F[0], F[1]], [F[2], F[3]], true,  175, "Women's League #1",   21, 13],
    [[F[0], F[2]], [F[3], F[4]], true,  160, "Women's League #2",   21, 14],
    [[F[1], F[2]], [F[3], F[4]], true,  115, "Women's League #3",   21, 15],
    [[F[0], F[3]], [F[1], F[4]], true,  100, "Women's League #4",   21, 11],
    [[F[2], F[4]], [F[0], F[1]], false,  85, "Women's League #5",   16, 21],
    [[F[3], F[4]], [F[0], F[2]], false,  70, "Women's League #6",   15, 21],
    [[F[0], F[1]], [F[3], F[4]], true,   55, "Women's League #7",   21, 12],
    [[F[1], F[2]], [F[3], F[4]], true,   45, "Women's League #8",   21, 17],
    [[F[0], F[2]], [F[3], F[4]], true,   32, "Women's League #9",   21, 10],
    [[F[1], F[3]], [F[2], F[4]], true,   22, "Women's League #10",  21, 16],
    [[F[0], F[1]], [F[2], F[4]], true,   11, "Women's Playoffs SF", 21, 14],
    [[F[0], F[2]], [F[1], F[3]], true,    5, "Women's Playoffs F",  21, 15],
  ];

  for (const [tA, tB, aWins, daysAgo, label, sA, sB] of schedule) {
    const date = new Date(now - daysAgo * 24 * 60 * 60_000);
    const id   = await createCompletedGame(
      groupId, date,
      tA.map((u) => u.uid), tB.map((u) => u.uid),
      aWins, label, "female", sA, sB,
    );
    ids.push(id);
    console.log(`  ✅ [♀ female] ${label.padEnd(22)} ${daysAgo}d ago  ${aWins ? "Team A" : "Team B"} won  ${sA}–${sB}`);
  }
  return ids;
}

/**
 * 10 mixed games across 4 months.
 *
 * Every game has at least one player from a different gender group,
 * so gameGenderType = 'mix' → Cloud Function skips ELO entirely.
 * test11–15 (none) participate in every mixed game — their ELO never changes.
 */
async function seedMixedGames(
  groupId: string, M: TestUser[], F: TestUser[], N: TestUser[]
): Promise<string[]> {
  const now = Date.now();
  const ids: string[] = [];

  // [teamA, teamB, teamAWins, daysAgo, label]
  const schedule: [TestUser[], TestUser[], boolean, number, string][] = [
    // Cross-gender pairs — clearly mixed
    [[M[0], F[0]], [N[0], N[1]], true,  155, "Mixed Open #1"],
    [[M[1], F[1]], [N[2], N[3]], false, 140, "Mixed Open #2"],
    [[M[2], N[0]], [F[2], N[1]], true,  125, "Mixed Open #3"],
    [[M[3], N[1]], [F[3], N[2]], false, 110, "Mixed Open #4"],
    // none-users together — still mix because at least one none+other mix
    [[N[0], N[1]], [M[4], F[4]], true,   95, "Open Doubles #1"],
    [[N[2], N[3]], [M[0], F[0]], false,  80, "Open Doubles #2"],
    [[N[4], M[1]], [F[1], N[0]], true,   65, "Open Doubles #3"],
    // Late-season mixed
    [[M[2], F[2]], [N[1], N[2]], false,  42, "Mixed Friday #1"],
    [[M[4], N[4]], [F[0], F[1]], true,   21, "Mixed Friday #2"],
    [[M[0], F[3]], [N[3], N[4]], false,   8, "Mixed Friday #3"],
  ];

  for (const [tA, tB, aWins, daysAgo, label] of schedule) {
    const date = new Date(now - daysAgo * 24 * 60 * 60_000);
    const id   = await createCompletedGame(
      groupId, date,
      tA.map((u) => u.uid), tB.map((u) => u.uid),
      aWins, label, "mix",
    );
    ids.push(id);
    console.log(`  ✅ [○ mix]    ${label.padEnd(22)} ${daysAgo}d ago  ${aWins ? "Team A" : "Team B"} won  ← ELO skipped`);
  }
  return ids;
}

async function seedFutureGames(
  groupId: string, M: TestUser[], F: TestUser[], N: TestUser[]
): Promise<string[]> {
  console.log("\n📅 CREATING FUTURE SCHEDULED GAMES\n" + "=".repeat(50));
  const ids: string[] = [];

  const games: [number, string, string[], string, GameGenderType][] = [
    [2,  "Men's Weekend Cup",   [M[0].uid, M[1].uid, M[2].uid, M[3].uid], M[0].uid, "male"],
    [6,  "Women's Weekend Cup", [F[0].uid, F[1].uid, F[2].uid, F[3].uid], F[0].uid, "female"],
    [12, "Mixed Open Tourney",  [M[0].uid, F[0].uid, N[0].uid, N[1].uid], M[0].uid, "mix"],
    [20, "All-Stars Friendly",  [M[1].uid, F[1].uid, N[2].uid, M[2].uid], M[1].uid, "mix"],
  ];

  for (const [days, title, playerIds, createdBy, genderType] of games) {
    const id = await createFutureGame(groupId, days, title, playerIds, createdBy, genderType);
    ids.push(id);
    const tag = genderType === "male" ? "♂ male" : genderType === "female" ? "♀ female" : "○ mix";
    console.log(`  ✅ [${tag}] ${title} (+${days} days)`);
  }
  return ids;
}

// ─────────────────────────────────────────────────────────────────────────────
// Rating history timestamp backfill
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Config export  (updates testConfig.json used by testConfigLoader.ts)
// ─────────────────────────────────────────────────────────────────────────────

async function exportConfig(
  users:          TestUser[],
  groupId:        string,
  maleGameIds:    string[],
  femaleGameIds:  string[],
  mixedGameIds:   string[],
  futureGameIds:  string[],
): Promise<void> {
  const config = {
    timestamp:   new Date().toISOString(),
    project:     "gatherli-dev",
    script:      "setupMainTestEnvironment",
    credentials: { password: DEFAULT_PASSWORD },
    users: users.map((u, i) => ({
      index:       i + 1,
      uid:         u.uid,
      email:       u.email,
      displayName: u.displayName,
      gender:      u.gender,
    })),
    groupId,
    games: {
      past:   [...maleGameIds, ...femaleGameIds, ...mixedGameIds],
      future: futureGameIds,
      // Broken down by gender type for convenience
      male:   maleGameIds,
      female: femaleGameIds,
      mixed:  mixedGameIds,
    },
  };

  // Write to testConfig.json so testConfigLoader.ts keeps working
  const mainConfigPath = path.join(__dirname, "testConfig.json");
  fs.writeFileSync(mainConfigPath, JSON.stringify(config, null, 2));
  console.log(`  ✅ testConfig.json updated → ${mainConfigPath}`);

  // Also write a dedicated copy
  const dedicatedPath = path.join(__dirname, "mainTestConfig.json");
  fs.writeFileSync(dedicatedPath, JSON.stringify(config, null, 2));
  console.log(`  ✅ mainTestConfig.json saved → ${dedicatedPath}`);
}

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────

async function main() {
  const t0 = Date.now();

  console.log("\n" + "=".repeat(70));
  console.log("🏐 GATHERLI — MAIN TEST ENVIRONMENT SETUP");
  console.log("=".repeat(70));
  console.log(`
Users (15 total)
  ♂ test1–5    → gender: male   (ELO changes from male-only games)
  ♀ test6–10   → gender: female (ELO changes from female-only games)
  ○ test11–15  → gender: none   (ELO always stays flat — only mixed games)

Games (34 completed + 4 future)
  12 male-only games    → ELO changes for test1–5
  12 female-only games  → ELO changes for test6–10
  10 mixed games        → NO ELO change (Cloud Function skips)
   4 future games       → one male, one female, two mixed

⚠️  WARNING: All data in gatherli-dev will be deleted!\n`);

  // 1. Clear
  await clearDatabase();
  await clearAuthUsers();

  // 2. Users
  console.log("\n👤 CREATING USERS\n" + "=".repeat(50));
  const users: TestUser[] = [];
  for (const d of TEST_USERS) {
    const u = await createTestUser(d);
    users.push(u);
    const tag = u.gender === "male" ? "♂" : u.gender === "female" ? "♀" : "○";
    console.log(`  ✅ ${tag} ${u.displayName.padEnd(8)} ${u.email}`);
  }

  const males   = users.slice(0,  5);  // test1–5
  const females = users.slice(5,  10); // test6–10
  const nones   = users.slice(10, 15); // test11–15

  // 3. Social graph
  await createFriendships(users);

  // 4. Group
  const groupId = await createGroup(users);

  // 5. Past completed games
  console.log("\n🎮 CREATING PAST COMPLETED GAMES\n" + "=".repeat(50));
  console.log("  [Male games]");
  const maleGameIds   = await seedMaleGames(groupId, males);

  console.log("\n  [Female games]");
  const femaleGameIds = await seedFemaleGames(groupId, females);

  console.log("\n  [Mixed games]");
  const mixedGameIds  = await seedMixedGames(groupId, males, females, nones);

  // 6. Wait for Cloud Functions to finish ELO processing
  console.log("\n⏳ Waiting 15s for Cloud Functions to process ELO updates...");
  await new Promise((r) => setTimeout(r, 15_000));

  // 7. Backdate rating history timestamps so ELO chart shows history over time
  console.log("\n🔧 FIXING RATING HISTORY TIMESTAMPS\n" + "=".repeat(50));
  await fixRatingHistoryTimestamps(users.map((u) => u.uid));

  // 8. Future games
  const futureGameIds = await seedFutureGames(groupId, males, females, nones);

  // 9. Update group game list & stats
  const allGameIds = [...maleGameIds, ...femaleGameIds, ...mixedGameIds, ...futureGameIds];
  await db.collection("groups").doc(groupId).update({
    gameIds:          allGameIds,
    totalGamesPlayed: maleGameIds.length + femaleGameIds.length + mixedGameIds.length,
    lastActivity:     admin.firestore.FieldValue.serverTimestamp(),
  });

  // 10. Export config
  console.log("\n📝 EXPORTING CONFIG\n" + "=".repeat(50));
  await exportConfig(users, groupId, maleGameIds, femaleGameIds, mixedGameIds, futureGameIds);

  // 11. Print final ELO ratings
  console.log("\n📊 FINAL ELO RATINGS\n" + "=".repeat(50));
  const rows: string[] = [];
  for (const user of users) {
    const doc = await db.collection("users").doc(user.uid).get();
    const elo = (doc.data()?.eloRating ?? 1200).toFixed(1);
    const tag = user.gender === "male" ? "♂" : user.gender === "female" ? "♀" : "○";
    const changed = doc.data()?.eloRating !== 1200 ? " ◀ changed" : "";
    rows.push(`  ${tag} ${user.displayName.padEnd(8)} ELO ${elo.padStart(7)}${changed}`);
  }
  rows.forEach((r) => console.log(r));

  const secs = ((Date.now() - t0) / 1000).toFixed(1);
  console.log("\n" + "=".repeat(70));
  console.log(`🎉 MAIN TEST ENVIRONMENT READY  (${secs}s)`);
  console.log("=".repeat(70));
  console.log(`
📋 Credentials
   Email:    test1@mysta.com  (or test2–test15)
   Password: ${DEFAULT_PASSWORD}

👥 Users
   ♂ test1–5   (male)   — 12 male-only games → ELO diverged
   ♀ test6–10  (female) — 12 female-only games → ELO diverged
   ○ test11–15 (none)   — 10 mixed games only → ELO flat at 1200

🎮 Games
   ${maleGameIds.length} male-only games   (Men's League #1–10 + Playoffs)
   ${femaleGameIds.length} female-only games (Women's League #1–10 + Playoffs)
   ${mixedGameIds.length} mixed games       (Mixed Open, Open Doubles, Mixed Friday)
   ${futureGameIds.length} future games      (upcoming scheduled)

📱 Suggested test flows
   • Log in as test1@mysta.com  → high ELO, rich chart history
   • Log in as test5@mysta.com  → low ELO (lost most male games)
   • Log in as test11@mysta.com → flat ELO chart (mixed games only)
   • Open a "Men's League" game → eloCalculated=true, eloUpdates populated
   • Open a "Mixed Open" game   → eloCalculated=true, eloUpdates empty {}
   • Check Stats page           → see gender ELO separation clearly
`);
}

// Guard: dev only
const pid = admin.app().options.projectId;
if (pid !== "gatherli-dev") {
  console.error(`❌ This script only runs on gatherli-dev (got: ${pid})`);
  process.exit(1);
}

main()
  .then(() => process.exit(0))
  .catch((e) => { console.error("❌ Fatal error:", e); process.exit(1); });

/**
 * Gender Test Environment Setup Script (Story 26.10)
 *
 * Creates a complete test environment that demonstrates:
 *  - Gender classification on users (male / female / none)
 *  - Game gender types: male-only, female-only, and mixed
 *  - ELO divergence after gender-specific games
 *  - Mixed games that do NOT trigger ELO changes
 *
 * What gets created:
 *  - 15 test users:
 *      test1–5   → gender: 'male'   (test1@mysta.com … test5@mysta.com)
 *      test6–10  → gender: 'female' (test6@mysta.com … test10@mysta.com)
 *      test11–15 → gender: 'none'   (test11@mysta.com … test15@mysta.com)
 *  - 105 accepted friendships (complete social graph)
 *  - 1 group with all 15 members
 *  - 5 completed male-only games   → ELO changes for test1–5
 *  - 5 completed female-only games → ELO changes for test6–10
 *  - 5 completed mixed games       → no ELO change (skipped by Cloud Function)
 *  - 3 future scheduled games (one of each type)
 *
 * Expected outcome after seeding:
 *  - test1–5 have diverged ELO ratings (wins → above 1200, losses → below 1200)
 *  - test6–10 have diverged ELO ratings
 *  - test11–15 stay at 1200 (only played mixed games)
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/setupGenderTestEnvironment.ts
 *
 * WARNING: Deletes ALL data in gatherli-dev before seeding!
 */

import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp({ projectId: "gatherli-dev" });

const db   = admin.firestore();
const auth = admin.auth();

const DEFAULT_PASSWORD = "test1010";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type Gender = "male" | "female" | "none";

interface TestUser {
  uid: string;
  email: string;
  displayName: string;
  firstName: string;
  lastName: string;
  gender: Gender;
}

// ---------------------------------------------------------------------------
// User definitions
// ---------------------------------------------------------------------------

const TEST_USERS: { email: string; displayName: string; firstName: string; lastName: string; gender: Gender }[] = [
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

  const users = await db.collection("users").get();
  for (const doc of users.docs) {
    await deleteCollection(`users/${doc.id}/headToHead`);
    await deleteCollection(`users/${doc.id}/ratingHistory`);
  }
  const sessions = await db.collection("trainingSessions").get();
  for (const doc of sessions.docs) {
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

// ---------------------------------------------------------------------------
// Helpers — users / social graph
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
    gender: data.gender,
    photoUrl: null,
    isEmailVerified: true,
    createdAt: now, lastSignInAt: now, updatedAt: now,
    isAnonymous: false,
    accountStatus: "active",
    groupIds: [], gameIds: [], friendIds: [], friendCount: 0,
    notificationsEnabled: true, emailNotifications: true, pushNotifications: true,
    privacyLevel: "public", showEmail: true, showPhoneNumber: true,
    gamesPlayed: 0, gamesWon: 0, gamesLost: 0, totalScore: 0,
    currentStreak: 0, recentGameIds: [], teammateStats: {},
    eloRating: 1200.0, eloGamesPlayed: 0,
  });
  return { uid: record.uid, ...data };
}

async function createFriendships(users: TestUser[]): Promise<void> {
  console.log("\n👥 CREATING FRIENDSHIPS\n" + "=".repeat(50));
  const now   = admin.firestore.Timestamp.now();
  let count   = 0;

  // Write in batches of 500
  const pairs: [TestUser, TestUser][] = [];
  for (let i = 0; i < users.length; i++) {
    for (let j = i + 1; j < users.length; j++) {
      pairs.push([users[i], users[j]]);
    }
  }

  for (let start = 0; start < pairs.length; start += 400) {
    const batch = db.batch();
    const chunk = pairs.slice(start, start + 400);
    for (const [a, b] of chunk) {
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
  console.log(`  ✅ Created ${count} friendships`);
}

async function createGroup(users: TestUser[]): Promise<string> {
  console.log("\n🏐 CREATING GROUP\n" + "=".repeat(50));
  const now = admin.firestore.Timestamp.now();
  const ref = db.collection("groups").doc();

  await ref.set({
    name: "Venice Beach Mixed Crew",
    description: "A diverse crew of male, female, and open players — testing mixed vs non-mixed games.",
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
  label: string,
): Promise<string> {
  const ref = db.collection("games").doc();

  await ref.set({
    title: label,
    description: "Gender test environment game",
    groupId,
    createdBy: teamA[0],
    createdAt:   admin.firestore.Timestamp.fromDate(gameDate),
    updatedAt:   admin.firestore.Timestamp.fromDate(gameDate),
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
          teamBPoints: teamAWins ? 17 : 21,
        }],
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
    gameType: "beach_volleyball", skillLevel: "intermediate",
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
  console.log(`  ✅ Backdated ${fixed} rating history entries`);
}

// ---------------------------------------------------------------------------
// Orchestration — past games
// ---------------------------------------------------------------------------

async function seedMaleGames(groupId: string, M: TestUser[]): Promise<string[]> {
  // M = male users [0..4]
  const now  = Date.now();
  const ids: string[] = [];

  const schedule: [TestUser[], TestUser[], boolean, number, string][] = [
    [[M[0], M[1]], [M[2], M[3]], true,  80, "Men's Cup #1"],
    [[M[0], M[2]], [M[1], M[4]], false, 65, "Men's Cup #2"],
    [[M[1], M[3]], [M[2], M[4]], true,  50, "Men's Cup #3"],
    [[M[0], M[4]], [M[1], M[2]], true,  35, "Men's Cup #4"],
    [[M[2], M[3]], [M[0], M[4]], false, 20, "Men's Cup #5"],
  ];

  for (const [tA, tB, aWins, daysAgo, label] of schedule) {
    const date = new Date(now - daysAgo * 24 * 60 * 60_000);
    const id   = await createCompletedGame(
      groupId, date,
      tA.map((u) => u.uid), tB.map((u) => u.uid),
      aWins, label,
    );
    ids.push(id);
    console.log(`  ✅ [male]   ${label} (${daysAgo}d ago) — ${aWins ? "Team A" : "Team B"} won`);
  }
  return ids;
}

async function seedFemaleGames(groupId: string, F: TestUser[]): Promise<string[]> {
  // F = female users [0..4]
  const now  = Date.now();
  const ids: string[] = [];

  const schedule: [TestUser[], TestUser[], boolean, number, string][] = [
    [[F[0], F[1]], [F[2], F[3]], true,  75, "Women's Cup #1"],
    [[F[0], F[2]], [F[1], F[4]], false, 60, "Women's Cup #2"],
    [[F[1], F[3]], [F[2], F[4]], true,  45, "Women's Cup #3"],
    [[F[0], F[4]], [F[1], F[2]], true,  30, "Women's Cup #4"],
    [[F[2], F[3]], [F[0], F[4]], false, 15, "Women's Cup #5"],
  ];

  for (const [tA, tB, aWins, daysAgo, label] of schedule) {
    const date = new Date(now - daysAgo * 24 * 60 * 60_000);
    const id   = await createCompletedGame(
      groupId, date,
      tA.map((u) => u.uid), tB.map((u) => u.uid),
      aWins, label,
    );
    ids.push(id);
    console.log(`  ✅ [female] ${label} (${daysAgo}d ago) — ${aWins ? "Team A" : "Team B"} won`);
  }
  return ids;
}

async function seedMixedGames(
  groupId: string, M: TestUser[], F: TestUser[], N: TestUser[]
): Promise<string[]> {
  // Mixed = any combination of genders → no ELO change
  const now  = Date.now();
  const ids: string[] = [];

  // teamA, teamB, aWins, daysAgo, label
  const schedule: [TestUser[], TestUser[], boolean, number, string][] = [
    [[M[0], F[0]], [N[0], N[1]], true,  70, "Mixed Friendly #1"],  // male+female vs none+none
    [[M[1], F[1]], [N[2], F[2]], true,  55, "Mixed Friendly #2"],  // male+female vs none+female
    [[M[2], N[0]], [F[3], N[1]], false, 40, "Mixed Friendly #3"],  // male+none vs female+none
    [[M[3], N[2]], [F[4], N[3]], true,  25, "Mixed Friendly #4"],  // male+none vs female+none
    [[M[4], N[4]], [F[0], F[1]], false, 10, "Mixed Friendly #5"],  // male+none vs female+female
  ];

  for (const [tA, tB, aWins, daysAgo, label] of schedule) {
    const date = new Date(now - daysAgo * 24 * 60 * 60_000);
    const id   = await createCompletedGame(
      groupId, date,
      tA.map((u) => u.uid), tB.map((u) => u.uid),
      aWins, label,
    );
    ids.push(id);
    console.log(`  ✅ [mix]    ${label} (${daysAgo}d ago) — ${aWins ? "Team A" : "Team B"} won  ← ELO skipped`);
  }
  return ids;
}

async function seedFutureGames(
  groupId: string, M: TestUser[], F: TestUser[], N: TestUser[]
): Promise<string[]> {
  console.log("\n📅 CREATING FUTURE SCHEDULED GAMES\n" + "=".repeat(50));
  const ids: string[] = [];

  ids.push(await createFutureGame(
    groupId, 1, "Men's Showdown",
    [M[0].uid, M[1].uid, M[2].uid, M[3].uid], M[0].uid,
  ));
  console.log(`  ✅ [male]   Men's Showdown (tomorrow)`);

  ids.push(await createFutureGame(
    groupId, 5, "Women's Match",
    [F[0].uid, F[1].uid, F[2].uid, F[3].uid], F[0].uid,
  ));
  console.log(`  ✅ [female] Women's Match (+5 days)`);

  ids.push(await createFutureGame(
    groupId, 14, "Mixed Open",
    [M[0].uid, F[0].uid, N[0].uid, N[1].uid], M[0].uid,
  ));
  console.log(`  ✅ [mix]    Mixed Open (+14 days)`);

  return ids;
}

// ---------------------------------------------------------------------------
// Config export
// ---------------------------------------------------------------------------

async function exportConfig(
  users: TestUser[],
  groupId: string,
  maleGameIds: string[],
  femaleGameIds: string[],
  mixedGameIds: string[],
  futureGameIds: string[],
): Promise<void> {
  const config = {
    timestamp: new Date().toISOString(),
    project: "gatherli-dev",
    script: "setupGenderTestEnvironment",
    credentials: { password: DEFAULT_PASSWORD },
    users: users.map((u, i) => ({
      index: i + 1,
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
      gender: u.gender,
    })),
    groupId,
    games: {
      male:   maleGameIds,
      female: femaleGameIds,
      mixed:  mixedGameIds,
      future: futureGameIds,
    },
  };

  const p = path.join(__dirname, "genderTestConfig.json");
  fs.writeFileSync(p, JSON.stringify(config, null, 2));
  console.log(`\n  ✅ Config saved to ${p}`);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const t0 = Date.now();

  console.log("\n" + "=".repeat(70));
  console.log("🏐 GATHERLI — GENDER TEST ENVIRONMENT SETUP (Story 26.10)");
  console.log("=".repeat(70));
  console.log(`
Users:
  test1–5   → male   (ELO affected by male games)
  test6–10  → female (ELO affected by female games)
  test11–15 → none   (ELO never changes — only play mixed games)

Games:
  5 male-only games   → ELO changes for test1–5
  5 female-only games → ELO changes for test6–10
  5 mixed games       → NO ELO change (skipped by Cloud Function)
  3 future games      → one of each type

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
    const genderTag = u.gender === "male" ? "♂" : u.gender === "female" ? "♀" : "○";
    console.log(`  ✅ ${genderTag} ${u.displayName} (${u.email})`);
  }

  const males   = users.slice(0, 5);   // test1–5
  const females = users.slice(5, 10);  // test6–10
  const nones   = users.slice(10, 15); // test11–15

  // 3. Social graph
  await createFriendships(users);

  // 4. Group
  const groupId = await createGroup(users);

  // 5. Past games — each set triggers Cloud Functions (ELO for male/female, skip for mix)
  console.log("\n🎮 CREATING PAST COMPLETED GAMES\n" + "=".repeat(50));
  const maleGameIds   = await seedMaleGames(groupId, males);
  const femaleGameIds = await seedFemaleGames(groupId, females);
  const mixedGameIds  = await seedMixedGames(groupId, males, females, nones);

  // 6. Wait for Cloud Functions to process ELO
  console.log("\n⏳ Waiting 10s for Cloud Functions to process ELO...");
  await new Promise((r) => setTimeout(r, 10_000));

  // 7. Backdate rating history timestamps
  console.log("\n🔧 FIXING RATING HISTORY TIMESTAMPS\n" + "=".repeat(50));
  await fixRatingHistoryTimestamps(users.map((u) => u.uid));

  // 8. Future games
  const futureGameIds = await seedFutureGames(groupId, males, females, nones);

  // 9. Update group game list
  const allGameIds = [...maleGameIds, ...femaleGameIds, ...mixedGameIds, ...futureGameIds];
  await db.collection("groups").doc(groupId).update({
    gameIds: allGameIds,
    totalGamesPlayed: maleGameIds.length + femaleGameIds.length + mixedGameIds.length,
    lastActivity: admin.firestore.FieldValue.serverTimestamp(),
  });

  // 10. Export config
  console.log("\n📝 EXPORTING CONFIG\n" + "=".repeat(50));
  await exportConfig(users, groupId, maleGameIds, femaleGameIds, mixedGameIds, futureGameIds);

  // 11. Print final ELO ratings
  console.log("\n📊 FINAL ELO RATINGS\n" + "=".repeat(50));
  for (const user of users) {
    const doc = await db.collection("users").doc(user.uid).get();
    const elo = (doc.data()?.eloRating ?? 1200).toFixed(0);
    const genderTag = user.gender === "male" ? "♂" : user.gender === "female" ? "♀" : "○";
    const changed = doc.data()?.eloRating !== 1200 ? " ←" : "";
    console.log(`  ${genderTag} ${user.displayName.padEnd(8)} ELO: ${elo}${changed}`);
  }

  // Summary
  const secs = ((Date.now() - t0) / 1000).toFixed(1);
  console.log("\n" + "=".repeat(70));
  console.log("🎉 GENDER TEST ENVIRONMENT READY  (" + secs + "s)");
  console.log("=".repeat(70));
  console.log(`
📋 Credentials
   Email:    test1@mysta.com  (or test2–test15)
   Password: ${DEFAULT_PASSWORD}

👥 Users
   ♂ test1–5   (male)   → ELO diverged after 5 male-only games
   ♀ test6–10  (female) → ELO diverged after 5 female-only games
   ○ test11–15 (none)   → ELO stays at 1200 (only mixed games played)

🎮 Games created
   ${maleGameIds.length} male-only games   (Men's Cup #1–5)     → ELO changes
   ${femaleGameIds.length} female-only games (Women's Cup #1–5)  → ELO changes
   ${mixedGameIds.length} mixed games       (Mixed Friendly #1–5) → NO ELO change
   ${futureGameIds.length} future games      (one of each type)

📱 Suggested test flows
   • Log in as test1@mysta.com  → profile ELO chart shows rating history
   • Log in as test11@mysta.com → profile ELO chart is flat (mixed games only)
   • Open any "Mixed Friendly" game → eloCalculated=true, eloUpdates={}
   • Open any "Men's Cup" game      → eloCalculated=true, eloUpdates has values
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

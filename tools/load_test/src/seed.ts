// Idempotent test data seeder for gatherli-dev.
// All documents use deterministic IDs prefixed with "load-test-" for easy cleanup.

import * as admin from "firebase-admin";

const USER_COUNT = 5;
const GROUP_COUNT = 2;
const GAMES_PER_GROUP = 10; // 5 upcoming, 5 completed

export function testUserId(n: number): string {
  return `load-test-user-${n}`;
}

export function testGroupId(n: number): string {
  return `load-test-group-${n}`;
}

export function testGameId(groupN: number, gameN: number): string {
  return `load-test-game-g${groupN}-${gameN}`;
}

export async function seedTestData(db: admin.firestore.Firestore): Promise<void> {
  console.log("🌱 Seeding test data in gatherli-dev...");

  const batch = db.batch();
  const now = admin.firestore.Timestamp.now();
  const memberIds = Array.from({ length: USER_COUNT }, (_, i) => testUserId(i + 1));

  // ── Users ────────────────────────────────────────────────────────────────
  for (let i = 1; i <= USER_COUNT; i++) {
    const uid = testUserId(i);
    const ref = db.collection("users").doc(uid);
    batch.set(
      ref,
      {
        uid,
        email: `load-test-user-${i}@gatherli-dev.test`,
        displayName: `Load Test User ${i}`,
        createdAt: now,
        gamesPlayed: 0,
        gamesWon: 0,
        eloRating: 1000,
        _loadTest: true,
      },
      { merge: true }
    );
  }

  // ── Friendship links (all pairs) ─────────────────────────────────────────
  for (let i = 1; i <= USER_COUNT; i++) {
    for (let j = i + 1; j <= USER_COUNT; j++) {
      const friendshipId = `load-test-friendship-${i}-${j}`;
      const ref = db.collection("friendships").doc(friendshipId);
      batch.set(
        ref,
        {
          users: [testUserId(i), testUserId(j)],
          status: "accepted",
          createdAt: now,
          _loadTest: true,
        },
        { merge: true }
      );
    }
  }

  // ── Groups & Games ────────────────────────────────────────────────────────
  for (let g = 1; g <= GROUP_COUNT; g++) {
    const groupId = testGroupId(g);
    const groupRef = db.collection("groups").doc(groupId);
    batch.set(
      groupRef,
      {
        name: `Load Test Group ${g}`,
        memberIds,
        adminIds: [testUserId(1)],
        createdBy: testUserId(1),
        createdAt: now,
        sport: "volleyball",
        _loadTest: true,
      },
      { merge: true }
    );

    for (let n = 1; n <= GAMES_PER_GROUP; n++) {
      const gameId = testGameId(g, n);
      const isUpcoming = n <= 5;
      const scheduledAt = isUpcoming
        ? admin.firestore.Timestamp.fromDate(
            new Date(Date.now() + n * 24 * 60 * 60 * 1000)
          )
        : admin.firestore.Timestamp.fromDate(
            new Date(Date.now() - n * 24 * 60 * 60 * 1000)
          );

      const gameRef = db.collection("games").doc(gameId);
      batch.set(
        gameRef,
        {
          title: `Load Test Game G${g}-${n}`,
          groupId,
          createdBy: testUserId(1),
          createdAt: now,
          updatedAt: now,
          scheduledAt,
          status: isUpcoming ? "scheduled" : "completed",
          playerIds: memberIds,
          waitlistIds: [],
          maxPlayers: 10,
          minPlayers: 2,
          location: { name: "Load Test Court" },
          allowWaitlist: true,
          allowPlayerInvites: true,
          visibility: "group",
          _loadTest: true,
        },
        { merge: true }
      );
    }
  }

  await batch.commit();
  console.log(
    `✅ Seeded: ${USER_COUNT} users, ${GROUP_COUNT} groups, ` +
    `${GROUP_COUNT * GAMES_PER_GROUP} games, friendship links`
  );
}

export async function cleanupTestData(db: admin.firestore.Firestore): Promise<void> {
  console.log("🧹 Cleaning up load-test documents...");

  const collections = ["users", "friendships", "groups", "games"];
  for (const col of collections) {
    const snap = await db
      .collection(col)
      .where("_loadTest", "==", true)
      .get();

    const batch = db.batch();
    snap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    console.log(`  Deleted ${snap.size} documents from ${col}`);
  }

  console.log("✅ Cleanup complete");
}

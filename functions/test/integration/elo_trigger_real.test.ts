import * as admin from "firebase-admin";
import { EmulatorHelper } from "./emulatorHelper";

describe("Integration: ELO Trigger Real", () => {
  let player1: admin.auth.UserRecord;
  let player2: admin.auth.UserRecord;
  let player3: admin.auth.UserRecord;
  let player4: admin.auth.UserRecord;
  let groupId: string;

  beforeAll(async () => {
    await EmulatorHelper.initialize();
  });

  beforeEach(async () => {
    await EmulatorHelper.clearFirestore();
    await EmulatorHelper.clearAuth();

    // Create 4 test users with initial ELO 1200
    player1 = await EmulatorHelper.createTestUser({
      email: "p1@test.com", password: "password", displayName: "P1"
    });
    player2 = await EmulatorHelper.createTestUser({
      email: "p2@test.com", password: "password", displayName: "P2"
    });
    player3 = await EmulatorHelper.createTestUser({
      email: "p3@test.com", password: "password", displayName: "P3"
    });
    player4 = await EmulatorHelper.createTestUser({
      email: "p4@test.com", password: "password", displayName: "P4"
    });

    // Ensure they have default ELO (createTestUser might set 0 or missing, let's explicit update)
    const db = admin.firestore();
    const updateElo = { eloRating: 1200, gamesPlayed: 0 };
    await Promise.all([
      db.collection("users").doc(player1.uid).update(updateElo),
      db.collection("users").doc(player2.uid).update(updateElo),
      db.collection("users").doc(player3.uid).update(updateElo),
      db.collection("users").doc(player4.uid).update(updateElo),
    ]);

    groupId = await EmulatorHelper.createTestGroup({
      name: "Test Group", adminId: player1.uid, memberIds: [player1.uid, player2.uid, player3.uid, player4.uid]
    });
  });

  afterAll(async () => {
    await EmulatorHelper.cleanup();
  });

  test("should update ELO ratings when game is completed", async () => {
    const db = admin.firestore();

    // Create a game in 'verification' status first
    const gameRef = await db.collection("games").add({
      title: "Test Game",
      groupId: groupId,
      createdBy: player1.uid,
      status: "verification",
      teams: {
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
      },
      result: {
        overallWinner: "teamA", // Team A wins
        games: [], // simplified
      },
      eloCalculated: false,
    });

    // Update status to 'completed' to trigger the function
    await gameRef.update({
      status: "completed",
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Poll for changes
    // Wait up to 5 seconds
    let processed = false;
    for (let i = 0; i < 10; i++) {
      await new Promise(r => setTimeout(r, 500));
      const doc = await gameRef.get();
      if (doc.data()?.eloCalculated === true) {
        processed = true;
        break;
      }
    }

    expect(processed).toBe(true);

    // Verify ratings
    // Team A (P1, P2) won. Expect > 1200.
    // Team B (P3, P4) lost. Expect < 1200.
    const p1Doc = await db.collection("users").doc(player1.uid).get();
    const p3Doc = await db.collection("users").doc(player3.uid).get();

    expect(p1Doc.data()?.eloRating).toBeGreaterThan(1200);
    expect(p3Doc.data()?.eloRating).toBeLessThan(1200);
    expect(p1Doc.data()?.gamesPlayed).toBe(1);
    expect(p1Doc.data()?.wins).toBe(1);
    expect(p3Doc.data()?.losses).toBe(1);
  }, 10000); // 10s timeout
});

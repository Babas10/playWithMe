// Integration Test: Nemesis Detection
// Story 301.8: Automatic Nemesis/Rival Detection

import * as admin from "firebase-admin";
import { EmulatorHelper } from "./emulatorHelper";

describe("Integration: Nemesis Detection", () => {
  let player1: admin.auth.UserRecord;
  let player2: admin.auth.UserRecord;
  let player3: admin.auth.UserRecord;
  let player4: admin.auth.UserRecord;
  let groupId: string;

  beforeAll(async () => {
    await EmulatorHelper.initialize();
  });

  beforeEach(async () => {
    // Clear all data before each test
    await EmulatorHelper.clearFirestore();
    await EmulatorHelper.clearAuth();

    // Create 4 test users
    player1 = await EmulatorHelper.createTestUser({
      email: "player1@test.com",
      password: "password123",
      displayName: "Player One",
    });

    player2 = await EmulatorHelper.createTestUser({
      email: "player2@test.com",
      password: "password123",
      displayName: "Player Two",
    });

    player3 = await EmulatorHelper.createTestUser({
      email: "player3@test.com",
      password: "password123",
      displayName: "Player Three",
    });

    player4 = await EmulatorHelper.createTestUser({
      email: "player4@test.com",
      password: "password123",
      displayName: "Player Four",
    });

    // Create a test group
    groupId = await EmulatorHelper.createTestGroup({
      name: "Beach Volleyball Team",
      adminId: player1.uid,
      memberIds: [player1.uid, player2.uid, player3.uid, player4.uid],
    });

    // Initialize ELO ratings (default 1200)
    const db = admin.firestore();
    const defaultData = {
      eloRating: 1200.0,
      eloGamesPlayed: 0,
      eloPeak: 1200.0,
      gamesPlayed: 0,
      wins: 0,
      losses: 0,
    };

    await Promise.all([
      db.collection("users").doc(player1.uid).update(defaultData),
      db.collection("users").doc(player2.uid).update(defaultData),
      db.collection("users").doc(player3.uid).update(defaultData),
      db.collection("users").doc(player4.uid).update(defaultData),
    ]);
  });

  afterAll(async () => {
    await EmulatorHelper.cleanup();
  });

  /**
   * Helper to create a scheduled game first, then update it to completed.
   * This properly triggers the onGameStatusChanged Cloud Function.
   */
  async function createAndCompleteGame(options: {
    teamAPlayerIds: string[];
    teamBPlayerIds: string[];
    overallWinner: "teamA" | "teamB";
    games: any[];
  }): Promise<string> {
    const db = admin.firestore();

    // Step 1: Create as scheduled
    const gameRef = db.collection("games").doc();
    await gameRef.set({
      title: "Test Game",
      description: "Integration test",
      groupId: groupId,
      createdBy: player1.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      scheduledAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - 60 * 60 * 1000)
      ),
      location: { name: "Test Beach", address: "123 Beach Rd" },
      status: "scheduled",
      maxPlayers: 4,
      sport: "volleyball",
    });

    // Wait for document to exist
    await new Promise((resolve) => setTimeout(resolve, 500));

    // Step 2: Update to completed (triggers Cloud Function)
    await gameRef.update({
      status: "completed",
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
      teams: {
        teamAPlayerIds: options.teamAPlayerIds,
        teamBPlayerIds: options.teamBPlayerIds,
      },
      result: {
        overallWinner: options.overallWinner,
        games: options.games,
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return gameRef.id;
  }

  /**
   * Wait for Cloud Functions to process (h2h updates + nemesis calculation)
   */
  async function waitForCloudFunctions(delayMs: number = 3000) {
    await new Promise((resolve) => setTimeout(resolve, delayMs));
  }

  it("should calculate nemesis after 3 losses to same opponent", async () => {
    const db = admin.firestore();

    // Player 1 & Player 2 (Team A) vs Player 3 & Player 4 (Team B)
    // Team B wins 3 times

    // Game 1: Team B wins
    await createAndCompleteGame({
      teamAPlayerIds: [player1.uid, player2.uid],
      teamBPlayerIds: [player3.uid, player4.uid],
      overallWinner: "teamB",
      games: [
        {
          gameNumber: 1,
          teamAScore: 19,
          teamBScore: 21,
          winner: "teamB",
        },
      ],
    });

    await waitForCloudFunctions(2000);

    // Game 2: Team B wins again
    await createAndCompleteGame({
      teamAPlayerIds: [player1.uid, player2.uid],
      teamBPlayerIds: [player3.uid, player4.uid],
      overallWinner: "teamB",
      games: [
        {
          gameNumber: 1,
          teamAScore: 18,
          teamBScore: 21,
          winner: "teamB",
        },
      ],
    });

    await waitForCloudFunctions(2000);

    // Game 3: Team B wins third time (should trigger nemesis)
    await createAndCompleteGame({
      teamAPlayerIds: [player1.uid, player2.uid],
      teamBPlayerIds: [player3.uid, player4.uid],
      overallWinner: "teamB",
      games: [
        {
          gameNumber: 1,
          teamAScore: 17,
          teamBScore: 21,
          winner: "teamB",
        },
      ],
    });

    // Wait for all Cloud Functions to complete
    await waitForCloudFunctions(5000);

    // Check Player 1's nemesis
    const player1Doc = await db.collection("users").doc(player1.uid).get();
    const player1Data = player1Doc.data();

    expect(player1Data?.nemesis).toBeDefined();
    expect(player1Data?.nemesis.gamesLost).toBeGreaterThanOrEqual(3);
    expect(player1Data?.nemesis.gamesPlayed).toBeGreaterThanOrEqual(3);

    // Nemesis should be one of the opposing players
    const nemesisId = player1Data?.nemesis.opponentId;
    expect([player3.uid, player4.uid]).toContain(nemesisId);

    // Check Player 2's nemesis (also lost 3 times)
    const player2Doc = await db.collection("users").doc(player2.uid).get();
    const player2Data = player2Doc.data();

    expect(player2Data?.nemesis).toBeDefined();
    expect(player2Data?.nemesis.gamesLost).toBeGreaterThanOrEqual(3);
  });

  it("should NOT set nemesis with fewer than 3 games", async () => {
    const db = admin.firestore();

    // Only 2 games - not enough for nemesis

    // Game 1: Team B wins
    await createAndCompleteGame({
      teamAPlayerIds: [player1.uid, player2.uid],
      teamBPlayerIds: [player3.uid, player4.uid],
      overallWinner: "teamB",
      games: [
        {
          gameNumber: 1,
          teamAScore: 19,
          teamBScore: 21,
          winner: "teamB",
        },
      ],
    });

    await waitForCloudFunctions(2000);

    // Game 2: Team B wins again
    await createAndCompleteGame({
      teamAPlayerIds: [player1.uid, player2.uid],
      teamBPlayerIds: [player3.uid, player4.uid],
      overallWinner: "teamB",
      games: [
        {
          gameNumber: 1,
          teamAScore: 18,
          teamBScore: 21,
          winner: "teamB",
        },
      ],
    });

    await waitForCloudFunctions(3000);

    // Check Player 1's nemesis (should be null - only 2 games)
    const player1Doc = await db.collection("users").doc(player1.uid).get();
    const player1Data = player1Doc.data();

    expect(player1Data?.nemesis).toBeNull();
  });

  it("should update nemesis when opponent changes", async () => {
    const db = admin.firestore();

    // Player 1 loses 3 times to Player 3 (nemesis)
    for (let i = 0; i < 3; i++) {
      await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamB",
        games: [
          {
            gameNumber: 1,
            teamAScore: 18,
            teamBScore: 21,
            winner: "teamB",
          },
        ],
      });
      await waitForCloudFunctions(2000);
    }

    // Check initial nemesis
    let player1Doc = await db.collection("users").doc(player1.uid).get();
    let player1Data = player1Doc.data();
    const initialNemesisId = player1Data?.nemesis?.opponentId;

    expect(initialNemesisId).toBeDefined();
    expect([player3.uid, player4.uid]).toContain(initialNemesisId);

    // Now Player 1 loses 4 times to Player 4 (new nemesis)
    for (let i = 0; i < 4; i++) {
      await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player4.uid, player3.uid],
        overallWinner: "teamB",
        games: [
          {
            gameNumber: 1,
            teamAScore: 17,
            teamBScore: 21,
            winner: "teamB",
          },
        ],
      });
      await waitForCloudFunctions(2000);
    }

    // Check updated nemesis
    player1Doc = await db.collection("users").doc(player1.uid).get();
    player1Data = player1Doc.data();
    const updatedNemesisId = player1Data?.nemesis?.opponentId;

    // Nemesis should have changed to the opponent with more losses
    expect(updatedNemesisId).toBeDefined();
    expect(player1Data?.nemesis?.gamesLost).toBeGreaterThanOrEqual(4);
  });

  it("should clear nemesis when no opponent has 3+ games", async () => {
    const db = admin.firestore();

    // Manually set a nemesis
    await db.collection("users").doc(player1.uid).update({
      nemesis: {
        opponentId: player3.uid,
        opponentName: "Player Three",
        gamesLost: 5,
        gamesWon: 1,
        gamesPlayed: 6,
        winRate: 16.67,
      },
    });

    // Manually delete all h2h records
    const h2hSnapshot = await db
      .collection("users")
      .doc(player1.uid)
      .collection("headToHead")
      .get();

    const batch = db.batch();
    h2hSnapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    // Trigger nemesis recalculation by creating an h2h record with only 1 game
    await db
      .collection("users")
      .doc(player1.uid)
      .collection("headToHead")
      .doc(player3.uid)
      .set({
        userId: player1.uid,
        opponentId: player3.uid,
        opponentName: "Player Three",
        gamesPlayed: 1,
        gamesWon: 0,
        gamesLost: 1,
        pointsScored: 19,
        pointsAllowed: 21,
        eloChange: -16,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

    await waitForCloudFunctions(3000);

    // Nemesis should be cleared (no opponent with 3+ games)
    const player1Doc = await db.collection("users").doc(player1.uid).get();
    const player1Data = player1Doc.data();

    expect(player1Data?.nemesis).toBeNull();
  });

  it("should handle tiebreaker correctly (most total games)", async () => {
    const db = admin.firestore();

    // Player 1 loses 3 times to Player 3 (3 total games)
    for (let i = 0; i < 3; i++) {
      await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamB",
        games: [
          {
            gameNumber: 1,
            teamAScore: 18,
            teamBScore: 21,
            winner: "teamB",
          },
        ],
      });
      await waitForCloudFunctions(2000);
    }

    // Player 1 wins 2, loses 3 to Player 4 (5 total games - more than Player 3)
    for (let i = 0; i < 5; i++) {
      await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player4.uid, player3.uid],
        overallWinner: i < 2 ? "teamA" : "teamB", // Win first 2, lose last 3
        games: [
          {
            gameNumber: 1,
            teamAScore: i < 2 ? 21 : 18,
            teamBScore: i < 2 ? 19 : 21,
            winner: i < 2 ? "teamA" : "teamB",
          },
        ],
      });
      await waitForCloudFunctions(2000);
    }

    // Check nemesis (should be Player 4 - tied on losses but more total games)
    const player1Doc = await db.collection("users").doc(player1.uid).get();
    const player1Data = player1Doc.data();

    expect(player1Data?.nemesis).toBeDefined();
    // With tiebreaker, should prefer opponent with most total matchups
    expect(player1Data?.nemesis.gamesLost).toBe(3);
    expect(player1Data?.nemesis.gamesPlayed).toBeGreaterThanOrEqual(3);
  });
});

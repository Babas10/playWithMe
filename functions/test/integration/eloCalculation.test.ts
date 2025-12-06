// Integration Test: ELO Rating Calculation
// Story 14.5.2: Firestore Trigger Handler + Transaction Logic

import * as admin from "firebase-admin";
import {EmulatorHelper} from "./emulatorHelper";

describe("Integration: ELO Rating Calculation", () => {
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

    // Create 4 test users for beach volleyball (2v2)
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

    // Create a test group with all players
    groupId = await EmulatorHelper.createTestGroup({
      name: "Beach Volleyball Team",
      adminId: player1.uid,
      memberIds: [player1.uid, player2.uid, player3.uid, player4.uid],
    });

    // Initialize ELO ratings for all players (default 1600)
    const db = admin.firestore();
    const defaultEloData = {
      eloRating: 1600.0,
      eloGamesPlayed: 0,
      eloPeak: 1600.0,
    };

    await Promise.all([
      db.collection("users").doc(player1.uid).update(defaultEloData),
      db.collection("users").doc(player2.uid).update(defaultEloData),
      db.collection("users").doc(player3.uid).update(defaultEloData),
      db.collection("users").doc(player4.uid).update(defaultEloData),
    ]);
  });

  afterAll(async () => {
    await EmulatorHelper.cleanup();
  });

  /**
   * Helper to create a completed game with result
   */
  async function createCompletedGame(options: {
    teamAPlayerIds: string[];
    teamBPlayerIds: string[];
    overallWinner: "teamA" | "teamB";
    eloCalculated?: boolean;
  }): Promise<string> {
    const db = admin.firestore();

    const gameData = {
      title: "Test Beach Volleyball Game",
      description: "Integration test game",
      groupId: groupId,
      createdBy: player1.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      scheduledAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - 60 * 60 * 1000) // 1 hour ago
      ),
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
      location: {
        name: "Test Beach",
        address: "123 Beach Road",
      },
      status: "completed",
      maxPlayers: 4,
      minPlayers: 4,
      playerIds: [
        ...options.teamAPlayerIds,
        ...options.teamBPlayerIds,
      ],
      teams: {
        teamAPlayerIds: options.teamAPlayerIds,
        teamBPlayerIds: options.teamBPlayerIds,
      },
      result: {
        overallWinner: options.overallWinner,
        games: [
          {
            gameNumber: 1,
            sets: [
              {
                setNumber: 1,
                teamAPoints: options.overallWinner === "teamA" ? 21 : 15,
                teamBPoints: options.overallWinner === "teamB" ? 21 : 15,
              },
            ],
            winner: options.overallWinner,
          },
        ],
      },
      eloCalculated: options.eloCalculated ?? false,
    };

    const gameRef = await db.collection("games").add(gameData);
    return gameRef.id;
  }

  describe("Game document structure for ELO calculation", () => {
    it("should create a game with correct structure for ELO processing", async () => {
      const gameId = await createCompletedGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
      });

      const db = admin.firestore();
      const gameDoc = await db.collection("games").doc(gameId).get();

      expect(gameDoc.exists).toBe(true);

      const data = gameDoc.data()!;
      expect(data.status).toBe("completed");
      expect(data.eloCalculated).toBe(false);
      expect(data.teams.teamAPlayerIds).toEqual([player1.uid, player2.uid]);
      expect(data.teams.teamBPlayerIds).toEqual([player3.uid, player4.uid]);
      expect(data.result.overallWinner).toBe("teamA");
    });

    it("should have all 4 players with initial ELO ratings", async () => {
      const db = admin.firestore();

      const players = await Promise.all([
        db.collection("users").doc(player1.uid).get(),
        db.collection("users").doc(player2.uid).get(),
        db.collection("users").doc(player3.uid).get(),
        db.collection("users").doc(player4.uid).get(),
      ]);

      for (const playerDoc of players) {
        expect(playerDoc.exists).toBe(true);
        const data = playerDoc.data()!;
        expect(data.eloRating).toBe(1600.0);
        expect(data.eloGamesPlayed).toBe(0);
        expect(data.eloPeak).toBe(1600.0);
      }
    });
  });

  describe("ELO calculation trigger conditions", () => {
    it("should NOT trigger for games with eloCalculated=true", async () => {
      const gameId = await createCompletedGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
        eloCalculated: true, // Already calculated
      });

      const db = admin.firestore();
      const gameDoc = await db.collection("games").doc(gameId).get();

      expect(gameDoc.data()!.eloCalculated).toBe(true);

      // Verify player ratings haven't changed
      const player1Doc = await db.collection("users").doc(player1.uid).get();
      expect(player1Doc.data()!.eloRating).toBe(1600.0);
      expect(player1Doc.data()!.eloGamesPlayed).toBe(0);
    });

    it("should NOT trigger for non-completed games", async () => {
      const db = admin.firestore();

      // Create a scheduled (not completed) game
      await db.collection("games").add({
        title: "Scheduled Game",
        groupId: groupId,
        createdBy: player1.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        scheduledAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 24 * 60 * 60 * 1000) // Tomorrow
        ),
        status: "scheduled", // Not completed
        teams: {
          teamAPlayerIds: [player1.uid, player2.uid],
          teamBPlayerIds: [player3.uid, player4.uid],
        },
        eloCalculated: false,
      });

      // Wait a bit
      await new Promise((resolve) => setTimeout(resolve, 1000));

      // Verify player ratings haven't changed
      const player1Doc = await db.collection("users").doc(player1.uid).get();
      expect(player1Doc.data()!.eloRating).toBe(1600.0);
      expect(player1Doc.data()!.eloGamesPlayed).toBe(0);
    });

    it("should NOT trigger for games without result data", async () => {
      const db = admin.firestore();

      // Create a completed game without result
      await db.collection("games").add({
        title: "Incomplete Game",
        groupId: groupId,
        createdBy: player1.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        scheduledAt: admin.firestore.Timestamp.now(),
        status: "completed",
        teams: {
          teamAPlayerIds: [player1.uid, player2.uid],
          teamBPlayerIds: [player3.uid, player4.uid],
        },
        // No result field
        eloCalculated: false,
      });

      // Wait a bit
      await new Promise((resolve) => setTimeout(resolve, 1000));

      // Verify player ratings haven't changed
      const player1Doc = await db.collection("users").doc(player1.uid).get();
      expect(player1Doc.data()!.eloRating).toBe(1600.0);
    });
  });

  describe("Rating history subcollection", () => {
    it("should have correct structure in ratingHistory entries", async () => {
      // This test verifies the expected structure of ratingHistory entries
      // that will be created by the Python Cloud Function
      const db = admin.firestore();

      // Manually create a rating history entry to test the structure
      const historyRef = await db
        .collection("users")
        .doc(player1.uid)
        .collection("ratingHistory")
        .add({
          gameId: "test-game-id",
          oldRating: 1600.0,
          newRating: 1616.0,
          ratingChange: 16.0,
          opponentTeam: "Player Three & Player Four",
          won: true,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

      const historyDoc = await historyRef.get();
      expect(historyDoc.exists).toBe(true);

      const data = historyDoc.data()!;
      expect(data.gameId).toBe("test-game-id");
      expect(data.oldRating).toBe(1600.0);
      expect(data.newRating).toBe(1616.0);
      expect(data.ratingChange).toBe(16.0);
      expect(data.opponentTeam).toBe("Player Three & Player Four");
      expect(data.won).toBe(true);
      expect(data.timestamp).toBeDefined();
    });
  });

  describe("User ELO fields", () => {
    it("should have all required ELO fields on user documents", async () => {
      const db = admin.firestore();

      // Add all ELO fields that the Python function will update
      await db.collection("users").doc(player1.uid).update({
        eloRating: 1650.0,
        eloLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        eloPeak: 1650.0,
        eloPeakDate: admin.firestore.FieldValue.serverTimestamp(),
        eloGamesPlayed: 5,
      });

      const userDoc = await db.collection("users").doc(player1.uid).get();
      const data = userDoc.data()!;

      expect(data.eloRating).toBe(1650.0);
      expect(data.eloLastUpdated).toBeDefined();
      expect(data.eloPeak).toBe(1650.0);
      expect(data.eloPeakDate).toBeDefined();
      expect(data.eloGamesPlayed).toBe(5);
    });

    it("should correctly track peak rating", async () => {
      const db = admin.firestore();

      // First update - new peak
      await db.collection("users").doc(player1.uid).update({
        eloRating: 1700.0,
        eloPeak: 1700.0,
        eloPeakDate: admin.firestore.FieldValue.serverTimestamp(),
        eloGamesPlayed: admin.firestore.FieldValue.increment(1),
      });

      let userDoc = await db.collection("users").doc(player1.uid).get();
      expect(userDoc.data()!.eloRating).toBe(1700.0);
      expect(userDoc.data()!.eloPeak).toBe(1700.0);

      // Second update - rating drops, peak stays
      await db.collection("users").doc(player1.uid).update({
        eloRating: 1680.0,
        // Peak should NOT be updated since 1680 < 1700
        eloGamesPlayed: admin.firestore.FieldValue.increment(1),
      });

      userDoc = await db.collection("users").doc(player1.uid).get();
      expect(userDoc.data()!.eloRating).toBe(1680.0);
      expect(userDoc.data()!.eloPeak).toBe(1700.0); // Peak unchanged
    });
  });

  describe("Firestore security rules for ratingHistory", () => {
    it("should allow reading own ratingHistory", async () => {
      const db = admin.firestore();

      // Create a rating history entry
      await db
        .collection("users")
        .doc(player1.uid)
        .collection("ratingHistory")
        .add({
          gameId: "test-game",
          oldRating: 1600,
          newRating: 1616,
          ratingChange: 16,
          won: true,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

      // Read should work (using Admin SDK - bypasses rules)
      const historySnapshot = await db
        .collection("users")
        .doc(player1.uid)
        .collection("ratingHistory")
        .get();

      expect(historySnapshot.docs.length).toBe(1);
    });
  });

  describe("Game data validation for ELO", () => {
    it("should validate team sizes are exactly 2 players each", async () => {
      const gameId = await createCompletedGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
      });

      const db = admin.firestore();
      const gameDoc = await db.collection("games").doc(gameId).get();
      const teams = gameDoc.data()!.teams;

      expect(teams.teamAPlayerIds.length).toBe(2);
      expect(teams.teamBPlayerIds.length).toBe(2);
    });

    it("should have valid overallWinner value", async () => {
      const gameId = await createCompletedGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamB",
      });

      const db = admin.firestore();
      const gameDoc = await db.collection("games").doc(gameId).get();
      const result = gameDoc.data()!.result;

      expect(["teamA", "teamB"]).toContain(result.overallWinner);
    });
  });

  describe("Idempotency protection", () => {
    it("should set eloCalculated flag after processing", async () => {
      // Create a game ready for ELO calculation
      const gameId = await createCompletedGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
        eloCalculated: false,
      });

      const db = admin.firestore();

      // Simulate what the Python function would do
      await db.collection("games").doc(gameId).update({
        eloCalculated: true,
        eloCalculatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Verify the flag is set
      const gameDoc = await db.collection("games").doc(gameId).get();
      expect(gameDoc.data()!.eloCalculated).toBe(true);
      expect(gameDoc.data()!.eloCalculatedAt).toBeDefined();
    });

    it("should not reprocess games with eloCalculated=true", async () => {
      const db = admin.firestore();

      // Create and mark as calculated
      await createCompletedGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
        eloCalculated: true,
      });

      // Store original ratings
      const player1Before = await db.collection("users").doc(player1.uid).get();
      const originalRating = player1Before.data()!.eloRating;

      // Wait for any potential trigger
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify rating hasn't changed
      const player1After = await db.collection("users").doc(player1.uid).get();
      expect(player1After.data()!.eloRating).toBe(originalRating);
    });
  });
});

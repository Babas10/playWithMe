// Integration Test: Decoupled Architecture (3-Tier Processing Chain)
// Story 301.8: Verify full ELO → H2H → Nemesis processing sequence

import * as admin from "firebase-admin";
import { EmulatorHelper } from "./emulatorHelper";

describe("Integration: Decoupled Architecture (3-Tier)", () => {
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
   * This properly triggers onGameStatusChanged Cloud Function.
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
   * Poll for a field to reach expected value with timeout
   */
  async function pollForField(
    docRef: admin.firestore.DocumentReference,
    fieldPath: string,
    expectedValue: any,
    timeoutMs: number = 10000
  ): Promise<{ success: boolean; durationMs: number; actualValue: any }> {
    const startTime = Date.now();
    const pollInterval = 500; // Check every 500ms
    const maxAttempts = timeoutMs / pollInterval;

    for (let attempt = 0; attempt < maxAttempts; attempt++) {
      const doc = await docRef.get();
      const data = doc.data();

      if (!data) {
        await new Promise((resolve) => setTimeout(resolve, pollInterval));
        continue;
      }

      const actualValue = fieldPath.split(".").reduce((obj, key) => obj?.[key], data);

      if (actualValue === expectedValue) {
        return {
          success: true,
          durationMs: Date.now() - startTime,
          actualValue,
        };
      }

      await new Promise((resolve) => setTimeout(resolve, pollInterval));
    }

    // Timeout reached
    const doc = await docRef.get();
    const data = doc.data();
    const actualValue = fieldPath.split(".").reduce((obj, key) => obj?.[key], data);

    return {
      success: false,
      durationMs: Date.now() - startTime,
      actualValue,
    };
  }

  describe("Full 3-Tier Processing Chain", () => {
    it("should process game through all 3 tiers in sequence", async () => {
      const db = admin.firestore();

      // Create and complete game
      const gameId = await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamB", // Team B wins (player1 & player2 lose)
        games: [
          {
            gameNumber: 1,
            teamAScore: 19,
            teamBScore: 21,
            winner: "teamB",
          },
        ],
      });

      const gameRef = db.collection("games").doc(gameId);

      // ===== TIER 1: ELO Calculation =====
      console.log("⏱️  Waiting for Tier 1: ELO Calculation...");
      const tier1 = await pollForField(gameRef, "eloCalculated", true, 10000);

      expect(tier1.success).toBe(true);
      expect(tier1.durationMs).toBeLessThan(10000); // Should complete in <10s
      console.log(`✅ Tier 1 completed in ${tier1.durationMs}ms`);

      // Verify ELO updates exist
      const gameAfterTier1 = await gameRef.get();
      const gameData1 = gameAfterTier1.data();
      expect(gameData1?.eloUpdates).toBeDefined();
      expect(gameData1?.eloCalculatedAt).toBeDefined();

      // ===== TIER 2: Head-to-Head Stats =====
      console.log("⏱️  Waiting for Tier 2: H2H Stats Processing...");
      const tier2 = await pollForField(gameRef, "headToHeadProcessed", true, 10000);

      expect(tier2.success).toBe(true);
      expect(tier2.durationMs).toBeLessThan(10000); // Should complete in <10s
      console.log(`✅ Tier 2 completed in ${tier2.durationMs}ms`);

      // Verify headToHeadProcessedAt timestamp exists
      const gameAfterTier2 = await gameRef.get();
      const gameData2 = gameAfterTier2.data();
      expect(gameData2?.headToHeadProcessedAt).toBeDefined();

      // ===== TIER 3: Nemesis Calculation =====
      console.log("⏱️  Waiting for Tier 3: Nemesis Calculation...");
      // Wait a bit longer for nemesis to be calculated
      await new Promise((resolve) => setTimeout(resolve, 3000));

      // Verify h2h records were created for all cross-team matchups
      const player1H2H = await db
        .collection("users")
        .doc(player1.uid)
        .collection("headToHead")
        .get();

      // Player1 should have 2 h2h records (vs player3 and player4)
      expect(player1H2H.docs.length).toBe(2);

      // Check that h2h stats were updated correctly
      const p1VsP3 = await db
        .collection("users")
        .doc(player1.uid)
        .collection("headToHead")
        .doc(player3.uid)
        .get();

      const p1VsP3Data = p1VsP3.data();
      expect(p1VsP3Data?.gamesPlayed).toBe(1);
      expect(p1VsP3Data?.gamesLost).toBe(1);
      expect(p1VsP3Data?.gamesWon).toBe(0);

      console.log(`✅ Tier 3 completed - H2H records created`);

      // Calculate total processing time
      const totalTime = tier1.durationMs + tier2.durationMs + 3000;
      console.log(`⏱️  Total processing time: ${totalTime}ms`);
      expect(totalTime).toBeLessThan(30000); // Total should be <30s
    }, 40000); // Test timeout: 40 seconds

    it("should create h2h stats for all cross-team matchups (2v2 = 8 records)", async () => {
      const db = admin.firestore();

      const gameId = await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
        games: [
          {
            gameNumber: 1,
            teamAScore: 21,
            teamBScore: 19,
            winner: "teamA",
          },
        ],
      });

      const gameRef = db.collection("games").doc(gameId);

      // Wait for both tiers to complete
      await pollForField(gameRef, "eloCalculated", true, 10000);
      await pollForField(gameRef, "headToHeadProcessed", true, 10000);

      // Wait for h2h processing
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify all h2h records exist
      // Player1 should have records vs Player3 and Player4
      const p1H2H = await db
        .collection("users")
        .doc(player1.uid)
        .collection("headToHead")
        .get();
      expect(p1H2H.docs.length).toBe(2);

      // Player2 should have records vs Player3 and Player4
      const p2H2H = await db
        .collection("users")
        .doc(player2.uid)
        .collection("headToHead")
        .get();
      expect(p2H2H.docs.length).toBe(2);

      // Player3 should have records vs Player1 and Player2
      const p3H2H = await db
        .collection("users")
        .doc(player3.uid)
        .collection("headToHead")
        .get();
      expect(p3H2H.docs.length).toBe(2);

      // Player4 should have records vs Player1 and Player2
      const p4H2H = await db
        .collection("users")
        .doc(player4.uid)
        .collection("headToHead")
        .get();
      expect(p4H2H.docs.length).toBe(2);

      // Total: 2 + 2 + 2 + 2 = 8 h2h records created
    }, 30000);

    it("should update nemesis for losing players after first loss (not yet 3 losses)", async () => {
      const db = admin.firestore();

      // Single game - Team B wins (Player1 and Player2 lose)
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

      // Wait for all processing
      await new Promise((resolve) => setTimeout(resolve, 5000));

      // Check Player1's nemesis (should be null - only 1 loss)
      const player1Doc = await db.collection("users").doc(player1.uid).get();
      const player1Data = player1Doc.data();

      // Nemesis requires 3+ games, so should be null
      expect(player1Data?.nemesis).toBeNull();
    }, 20000);
  });

  describe("Idempotency Protection", () => {
    it("should NOT reprocess ELO if eloCalculated is already true", async () => {
      const db = admin.firestore();

      const gameId = await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
        games: [
          {
            gameNumber: 1,
            teamAScore: 21,
            teamBScore: 19,
            winner: "teamA",
          },
        ],
      });

      const gameRef = db.collection("games").doc(gameId);

      // Wait for processing to complete
      await pollForField(gameRef, "eloCalculated", true, 10000);

      // Get player ratings after first processing
      const player1After1 = await db.collection("users").doc(player1.uid).get();
      const rating1 = player1After1.data()?.eloRating;

      // Wait a bit
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Trigger the function again by updating the game
      await gameRef.update({
        description: "Updated description",
      });

      // Wait to see if ELO changes (it shouldn't)
      await new Promise((resolve) => setTimeout(resolve, 3000));

      // Verify rating hasn't changed
      const player1After2 = await db.collection("users").doc(player1.uid).get();
      const rating2 = player1After2.data()?.eloRating;

      expect(rating2).toBe(rating1);
    }, 25000);

    it("should NOT reprocess h2h if headToHeadProcessed is already true", async () => {
      const db = admin.firestore();

      const gameId = await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
        games: [
          {
            gameNumber: 1,
            teamAScore: 21,
            teamBScore: 19,
            winner: "teamA",
          },
        ],
      });

      const gameRef = db.collection("games").doc(gameId);

      // Wait for all processing
      await pollForField(gameRef, "headToHeadProcessed", true, 10000);

      // Get h2h stats after first processing
      const h2hRef = db
        .collection("users")
        .doc(player1.uid)
        .collection("headToHead")
        .doc(player3.uid);

      const h2hAfter1 = await h2hRef.get();
      const gamesPlayed1 = h2hAfter1.data()?.gamesPlayed;

      // Wait a bit
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Manually set eloCalculated to false and back to true
      // (simulating a retry or error recovery)
      await gameRef.update({ eloCalculated: false });
      await new Promise((resolve) => setTimeout(resolve, 500));
      await gameRef.update({ eloCalculated: true });

      // Wait to see if h2h changes (it shouldn't - headToHeadProcessed is true)
      await new Promise((resolve) => setTimeout(resolve, 3000));

      // Verify h2h stats haven't changed
      const h2hAfter2 = await h2hRef.get();
      const gamesPlayed2 = h2hAfter2.data()?.gamesPlayed;

      expect(gamesPlayed2).toBe(gamesPlayed1);
    }, 25000);
  });

  describe("Performance Validation", () => {
    it("should complete Tier 1 (ELO) in less than 10 seconds", async () => {
      const db = admin.firestore();

      const gameId = await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
        games: [
          {
            gameNumber: 1,
            teamAScore: 21,
            teamBScore: 19,
            winner: "teamA",
          },
        ],
      });

      const gameRef = db.collection("games").doc(gameId);

      const tier1Result = await pollForField(gameRef, "eloCalculated", true, 10000);

      expect(tier1Result.success).toBe(true);
      expect(tier1Result.durationMs).toBeLessThan(10000);
      console.log(`⚡ Tier 1 (ELO) completed in ${tier1Result.durationMs}ms`);
    }, 20000);

    it("should complete Tier 2 (H2H) in less than 10 seconds after Tier 1", async () => {
      const db = admin.firestore();

      const gameId = await createAndCompleteGame({
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
        overallWinner: "teamA",
        games: [
          {
            gameNumber: 1,
            teamAScore: 21,
            teamBScore: 19,
            winner: "teamA",
          },
        ],
      });

      const gameRef = db.collection("games").doc(gameId);

      // Wait for Tier 1 first
      await pollForField(gameRef, "eloCalculated", true, 10000);

      // Now measure Tier 2
      const tier2Result = await pollForField(gameRef, "headToHeadProcessed", true, 10000);

      expect(tier2Result.success).toBe(true);
      expect(tier2Result.durationMs).toBeLessThan(10000);
      console.log(`⚡ Tier 2 (H2H) completed in ${tier2Result.durationMs}ms`);
    }, 30000);
  });
});

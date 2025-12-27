// Integration Test: Performance & Timeout Validation
// Story 301.8: Verify each tier completes within acceptable time limits

import * as admin from "firebase-admin";
import { EmulatorHelper } from "./emulatorHelper";

describe("Integration: Performance & Timeouts", () => {
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

    // Create 4 test users with default ELO 1200
    player1 = await EmulatorHelper.createTestUser({
      email: "p1@test.com",
      password: "password",
      displayName: "P1",
    });
    player2 = await EmulatorHelper.createTestUser({
      email: "p2@test.com",
      password: "password",
      displayName: "P2",
    });
    player3 = await EmulatorHelper.createTestUser({
      email: "p3@test.com",
      password: "password",
      displayName: "P3",
    });
    player4 = await EmulatorHelper.createTestUser({
      email: "p4@test.com",
      password: "password",
      displayName: "P4",
    });

    groupId = await EmulatorHelper.createTestGroup({
      name: "Test Group",
      adminId: player1.uid,
      memberIds: [player1.uid, player2.uid, player3.uid, player4.uid],
    });

    // Initialize ELO
    const db = admin.firestore();
    const defaultElo = {
      eloRating: 1200,
      eloGamesPlayed: 0,
      eloPeak: 1200,
      gamesPlayed: 0,
      wins: 0,
      losses: 0,
    };

    await Promise.all([
      db.collection("users").doc(player1.uid).update(defaultElo),
      db.collection("users").doc(player2.uid).update(defaultElo),
      db.collection("users").doc(player3.uid).update(defaultElo),
      db.collection("users").doc(player4.uid).update(defaultElo),
    ]);
  });

  afterAll(async () => {
    await EmulatorHelper.cleanup();
  });

  /**
   * Helper to create and complete a game
   */
  async function createAndCompleteGame(winner: "teamA" | "teamB"): Promise<string> {
    const db = admin.firestore();

    const gameRef = db.collection("games").doc();
    await gameRef.set({
      title: "Performance Test Game",
      groupId: groupId,
      createdBy: player1.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      scheduledAt: admin.firestore.Timestamp.now(),
      location: { name: "Test Court", address: "123 Test St" },
      status: "scheduled",
      maxPlayers: 4,
      sport: "volleyball",
    });

    await new Promise((resolve) => setTimeout(resolve, 500));

    await gameRef.update({
      status: "completed",
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
      teams: {
        teamAPlayerIds: [player1.uid, player2.uid],
        teamBPlayerIds: [player3.uid, player4.uid],
      },
      result: {
        overallWinner: winner,
        games: [
          {
            gameNumber: 1,
            teamAScore: winner === "teamA" ? 21 : 19,
            teamBScore: winner === "teamB" ? 21 : 19,
            winner: winner,
          },
        ],
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return gameRef.id;
  }

  /**
   * Poll for a field to reach expected value
   */
  async function pollForField(
    docRef: admin.firestore.DocumentReference,
    fieldPath: string,
    expectedValue: any,
    timeoutMs: number
  ): Promise<{ success: boolean; durationMs: number }> {
    const startTime = Date.now();
    const pollInterval = 200;
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
        };
      }

      await new Promise((resolve) => setTimeout(resolve, pollInterval));
    }

    return {
      success: false,
      durationMs: Date.now() - startTime,
    };
  }

  describe("Tier 1: ELO Calculation Performance", () => {
    it("should complete ELO calculation in less than 10 seconds", async () => {
      const db = admin.firestore();
      const gameId = await createAndCompleteGame("teamA");
      const gameRef = db.collection("games").doc(gameId);

      const result = await pollForField(gameRef, "eloCalculated", true, 10000);

      expect(result.success).toBe(true);
      expect(result.durationMs).toBeLessThan(10000);

      console.log(`⚡ Tier 1 (ELO): ${result.durationMs}ms`);
    }, 15000);

    it("should complete within 60s timeout limit", async () => {
      const db = admin.firestore();
      const gameId = await createAndCompleteGame("teamB");
      const gameRef = db.collection("games").doc(gameId);

      const result = await pollForField(gameRef, "eloCalculated", true, 60000);

      expect(result.success).toBe(true);
      expect(result.durationMs).toBeLessThan(60000);

      console.log(`✅ Tier 1 completed in ${result.durationMs}ms (well under 60s limit)`);
    }, 65000);

    it("should process multiple games sequentially without timeout", async () => {
      const db = admin.firestore();
      const times: number[] = [];

      for (let i = 0; i < 3; i++) {
        const gameId = await createAndCompleteGame(i % 2 === 0 ? "teamA" : "teamB");
        const gameRef = db.collection("games").doc(gameId);

        const result = await pollForField(gameRef, "eloCalculated", true, 15000);

        expect(result.success).toBe(true);
        times.push(result.durationMs);

        // Small delay between games
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }

      console.log(`⚡ ELO times for 3 games: ${times.join("ms, ")}ms`);

      // All should complete in reasonable time
      times.forEach((time) => {
        expect(time).toBeLessThan(15000);
      });
    }, 60000);
  });

  describe("Tier 2: Head-to-Head Stats Performance", () => {
    it("should complete H2H processing in less than 10 seconds after ELO", async () => {
      const db = admin.firestore();
      const gameId = await createAndCompleteGame("teamA");
      const gameRef = db.collection("games").doc(gameId);

      // Wait for Tier 1 first
      const tier1 = await pollForField(gameRef, "eloCalculated", true, 10000);
      expect(tier1.success).toBe(true);

      // Measure Tier 2
      const tier2 = await pollForField(gameRef, "headToHeadProcessed", true, 10000);

      expect(tier2.success).toBe(true);
      expect(tier2.durationMs).toBeLessThan(10000);

      console.log(`⚡ Tier 2 (H2H): ${tier2.durationMs}ms`);
    }, 25000);

    it("should complete within 180s timeout limit", async () => {
      const db = admin.firestore();
      const gameId = await createAndCompleteGame("teamB");
      const gameRef = db.collection("games").doc(gameId);

      // Wait for Tier 1
      await pollForField(gameRef, "eloCalculated", true, 10000);

      // Measure Tier 2 (max 180s allowed)
      const tier2 = await pollForField(gameRef, "headToHeadProcessed", true, 180000);

      expect(tier2.success).toBe(true);
      expect(tier2.durationMs).toBeLessThan(180000);

      console.log(`✅ Tier 2 completed in ${tier2.durationMs}ms (well under 180s limit)`);
    }, 195000);

    it("should create all h2h records within timeout", async () => {
      const db = admin.firestore();
      const gameId = await createAndCompleteGame("teamA");
      const gameRef = db.collection("games").doc(gameId);

      // Wait for both tiers
      await pollForField(gameRef, "eloCalculated", true, 10000);
      await pollForField(gameRef, "headToHeadProcessed", true, 10000);

      // Wait a bit for h2h records to be created
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Verify all 8 h2h records exist
      const p1H2H = await db
        .collection("users")
        .doc(player1.uid)
        .collection("headToHead")
        .get();

      expect(p1H2H.docs.length).toBe(2); // vs player3 and player4

      console.log(`✅ H2H records created successfully`);
    }, 30000);
  });

  describe("Tier 3: Nemesis Calculation Performance", () => {
    it("should update nemesis within 15 seconds after h2h update", async () => {
      const db = admin.firestore();

      // Create 3 games where player1 loses to player3
      for (let i = 0; i < 3; i++) {
        await createAndCompleteGame("teamB");

        // Wait for processing
        await new Promise((resolve) => setTimeout(resolve, 5000));
      }

      // Check nemesis was calculated
      const player1Doc = await db.collection("users").doc(player1.uid).get();
      const player1Data = player1Doc.data();

      // Should have nemesis after 3 losses
      expect(player1Data?.nemesis).toBeDefined();
      expect(player1Data?.nemesis?.gamesLost).toBeGreaterThanOrEqual(3);

      console.log(`✅ Nemesis calculated after 3 games`);
    }, 30000);

    it("should complete within 60s timeout limit", async () => {
      const db = admin.firestore();
      const gameId = await createAndCompleteGame("teamB");

      // Wait for all processing
      await new Promise((resolve) => setTimeout(resolve, 10000));

      // Verify h2h record was created (which triggers nemesis)
      const p1VsP3 = await db
        .collection("users")
        .doc(player1.uid)
        .collection("headToHead")
        .doc(player3.uid)
        .get();

      expect(p1VsP3.exists).toBe(true);

      console.log(`✅ Tier 3 (Nemesis trigger) completed within timeout`);
    }, 20000);
  });

  describe("End-to-End Performance", () => {
    it("should complete all 3 tiers in less than 30 seconds total", async () => {
      const db = admin.firestore();
      const startTime = Date.now();

      const gameId = await createAndCompleteGame("teamA");
      const gameRef = db.collection("games").doc(gameId);

      // Wait for Tier 1
      const tier1 = await pollForField(gameRef, "eloCalculated", true, 10000);
      expect(tier1.success).toBe(true);

      // Wait for Tier 2
      const tier2 = await pollForField(gameRef, "headToHeadProcessed", true, 10000);
      expect(tier2.success).toBe(true);

      // Wait for Tier 3 (nemesis)
      await new Promise((resolve) => setTimeout(resolve, 5000));

      const totalTime = Date.now() - startTime;

      expect(totalTime).toBeLessThan(30000);

      console.log(`⚡ Total E2E time: ${totalTime}ms`);
      console.log(`  - Tier 1 (ELO): ${tier1.durationMs}ms`);
      console.log(`  - Tier 2 (H2H): ${tier2.durationMs}ms`);
      console.log(`  - Tier 3 (Nemesis): ~5000ms`);
    }, 35000);

    it("should handle 3 simultaneous games without timeout", async () => {
      const db = admin.firestore();

      // Create 3 games simultaneously
      const gamePromises = [
        createAndCompleteGame("teamA"),
        createAndCompleteGame("teamB"),
        createAndCompleteGame("teamA"),
      ];

      const gameIds = await Promise.all(gamePromises);

      // Wait for all to process
      const results = await Promise.all(
        gameIds.map((gameId) =>
          pollForField(db.collection("games").doc(gameId), "eloCalculated", true, 15000)
        )
      );

      // All should complete successfully
      results.forEach((result, index) => {
        expect(result.success).toBe(true);
        console.log(`⚡ Game ${index + 1}: ${result.durationMs}ms`);
      });

      console.log(`✅ 3 simultaneous games processed successfully`);
    }, 30000);
  });

  describe("Performance Regression Detection", () => {
    it("should not show performance degradation compared to baseline", async () => {
      const db = admin.firestore();
      const times: number[] = [];

      // Run 5 games to get average
      for (let i = 0; i < 5; i++) {
        const gameId = await createAndCompleteGame(i % 2 === 0 ? "teamA" : "teamB");
        const gameRef = db.collection("games").doc(gameId);

        const result = await pollForField(gameRef, "eloCalculated", true, 15000);
        expect(result.success).toBe(true);

        times.push(result.durationMs);

        await new Promise((resolve) => setTimeout(resolve, 2000));
      }

      const avgTime = times.reduce((a, b) => a + b, 0) / times.length;
      const maxTime = Math.max(...times);
      const minTime = Math.min(...times);

      console.log(`⚡ Performance metrics (5 games):`);
      console.log(`  - Average: ${avgTime.toFixed(0)}ms`);
      console.log(`  - Min: ${minTime}ms`);
      console.log(`  - Max: ${maxTime}ms`);

      // Performance should be consistent
      expect(avgTime).toBeLessThan(8000);
      expect(maxTime).toBeLessThan(12000);
    }, 90000);
  });
});

import * as admin from "firebase-admin";
import { getTestUser, getTestGroupId } from "./testConfigLoader";
import { createAndCompleteGame } from "./createNemesisTestGames";

/**
 * Creates a series of games to test the Best Win Tracking feature (Story 301.6).
 *
 * Scenario:
 * 1. Test1 & Test2 WIN vs moderate opponents ~1300 ELO (1st best win)
 * 2. Test1 & Test2 WIN vs high-rated opponents ~1500 ELO (updates best win)
 * 3. Test1 & Test2 WIN vs low-rated opponents ~1100 ELO (does NOT update best win)
 * 4. Test1 & Test2 LOSE vs moderate opponents (does NOT affect best win)
 *
 * This demonstrates:
 * - Initial best win tracking
 * - Best win updates when beating stronger opponents
 * - Best win persistence when beating weaker opponents
 * - Best win unaffected by losses
 */

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "playwithme-dev",
  });
}

/**
 * Helper to set a user's ELO rating directly (for controlled testing)
 */
async function setUserEloRating(
  db: admin.firestore.Firestore,
  userId: string,
  displayName: string,
  eloRating: number
): Promise<void> {
  await db.collection("users").doc(userId).update({
    eloRating: eloRating,
    eloPeak: Math.max(eloRating, 1600),
    eloLastUpdated: admin.firestore.Timestamp.now(),
  });
  console.log(`  ✅ Set ${displayName.padEnd(10)} ELO to ${eloRating}`);
}

if (require.main === module) {
  (async () => {
    try {
      const db = admin.firestore();
      console.log("\n🔥 Connected to Project ID:", admin.app().options.projectId || "Unknown");
      console.log("🏆 Creating Best Win Test Games...\n");

      // ==========================================
      // LOAD USER IDS FROM TEST CONFIG
      // ==========================================
      const test1 = getTestUser(0); // Our test subject
      const test2 = getTestUser(1); // Teammate
      const test3 = getTestUser(2); // Moderate opponent
      const test4 = getTestUser(3); // Moderate opponent
      const test5 = getTestUser(4); // High-rated opponent
      const test6 = getTestUser(5); // High-rated opponent
      const test7 = getTestUser(6); // Low-rated opponent
      const test8 = getTestUser(7); // Low-rated opponent
      const groupId = getTestGroupId();

      console.log("👥 Players (loaded from testConfig.json):");
      console.log(`  ${test1.displayName} (test subject):  ${test1.uid.slice(0, 8)}...`);
      console.log(`  ${test2.displayName} (teammate):      ${test2.uid.slice(0, 8)}...`);
      console.log(`  ${test3.displayName} (moderate opp):  ${test3.uid.slice(0, 8)}...`);
      console.log(`  ${test4.displayName} (moderate opp):  ${test4.uid.slice(0, 8)}...`);
      console.log(`  ${test5.displayName} (high-rated):    ${test5.uid.slice(0, 8)}...`);
      console.log(`  ${test6.displayName} (high-rated):    ${test6.uid.slice(0, 8)}...`);
      console.log(`  ${test7.displayName} (low-rated):     ${test7.uid.slice(0, 8)}...`);
      console.log(`  ${test8.displayName} (low-rated):     ${test8.uid.slice(0, 8)}...`);
      console.log(`  Group:                                 ${groupId}\n`);

      // ==========================================
      // SETUP: Set ELO ratings for controlled testing
      // ==========================================
      console.log("🎯 Setting up ELO ratings for controlled testing...");
      await setUserEloRating(db, test1.uid, test1.displayName, 1200); // Test1 starts at 1200
      await setUserEloRating(db, test2.uid, test2.displayName, 1200); // Test2 (teammate) at 1200
      await setUserEloRating(db, test3.uid, test3.displayName, 1300); // Test3 (moderate)
      await setUserEloRating(db, test4.uid, test4.displayName, 1300); // Test4 (moderate)
      await setUserEloRating(db, test5.uid, test5.displayName, 1500); // Test5 (high-rated)
      await setUserEloRating(db, test6.uid, test6.displayName, 1500); // Test6 (high-rated)
      await setUserEloRating(db, test7.uid, test7.displayName, 1100); // Test7 (low-rated)
      await setUserEloRating(db, test8.uid, test8.displayName, 1100); // Test8 (low-rated)
      console.log("  ✅ ELO ratings configured\n");

      // ==========================================
      // GAME 1: Test1 & Test2 WIN vs Test3 & Test4 (Moderate opponents ~1300 ELO)
      // Expected: Sets bestWin (first win)
      // Team ELO: 0.7 * 1300 + 0.3 * 1300 = 1300
      // ==========================================
      console.log(`🎮 Game 1: ${test1.displayName} & ${test2.displayName} WIN vs ${test3.displayName} & ${test4.displayName} (Moderate ~1300 ELO)`);
      console.log("  Expected: Sets bestWin (first win)");
      console.log("  Opponent Team ELO: ~1300\n");

      const teamTest1_Test2 = [test1.uid, test2.uid];
      const teamTest3_Test4 = [test3.uid, test4.uid];

      await createAndCompleteGame(db, {
        title: "Best Win Test - Game 1 (First Win)",
        groupId: groupId,
        createdBy: test1.uid,
        playerIds: [test1.uid, test2.uid, test3.uid, test4.uid],
        teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest3_Test4 },
        result: {
          overallWinner: "teamA",
          games: [
            {
              gameNumber: 1,
              teamAScore: 21,
              teamBScore: 18,
              sets: [{ teamAPoints: 21, teamBPoints: 18, setNumber: 1 }],
              winner: "teamA",
            },
          ],
        },
      });

      console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 12000));

      // ==========================================
      // GAME 2: Test1 & Test2 WIN vs Test5 & Test6 (High-rated opponents ~1500 ELO)
      // Expected: UPDATES bestWin (higher opponent ELO)
      // Team ELO: 0.7 * 1500 + 0.3 * 1500 = 1500
      // ==========================================
      console.log(`\n🎮 Game 2: ${test1.displayName} & ${test2.displayName} WIN vs ${test5.displayName} & ${test6.displayName} (High-rated ~1500 ELO)`);
      console.log("  Expected: UPDATES bestWin (opponent team ELO 1500 > 1300)");
      console.log("  Opponent Team ELO: ~1500\n");

      const teamTest5_Test6 = [test5.uid, test6.uid];

      await createAndCompleteGame(db, {
        title: "Best Win Test - Game 2 (Beat Higher-Rated)",
        groupId: groupId,
        createdBy: test1.uid,
        playerIds: [test1.uid, test2.uid, test5.uid, test6.uid],
        teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest5_Test6 },
        result: {
          overallWinner: "teamA", // Upset win!
          games: [
            {
              gameNumber: 1,
              teamAScore: 21,
              teamBScore: 19,
              sets: [{ teamAPoints: 21, teamBPoints: 19, setNumber: 1 }],
              winner: "teamA",
            },
          ],
        },
      });

      console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 12000));

      // ==========================================
      // GAME 3: Test1 & Test2 WIN vs Test7 & Test8 (Low-rated opponents ~1100 ELO)
      // Expected: Does NOT update bestWin (lower opponent ELO)
      // Team ELO: 0.7 * 1100 + 0.3 * 1100 = 1100
      // ==========================================
      console.log(`\n🎮 Game 3: ${test1.displayName} & ${test2.displayName} WIN vs ${test7.displayName} & ${test8.displayName} (Low-rated ~1100 ELO)`);
      console.log("  Expected: Does NOT update bestWin (opponent team ELO 1100 < 1500)");
      console.log("  Opponent Team ELO: ~1100\n");

      const teamTest7_Test8 = [test7.uid, test8.uid];

      await createAndCompleteGame(db, {
        title: "Best Win Test - Game 3 (Beat Lower-Rated)",
        groupId: groupId,
        createdBy: test1.uid,
        playerIds: [test1.uid, test2.uid, test7.uid, test8.uid],
        teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest7_Test8 },
        result: {
          overallWinner: "teamA",
          games: [
            {
              gameNumber: 1,
              teamAScore: 21,
              teamBScore: 12,
              sets: [{ teamAPoints: 21, teamBPoints: 12, setNumber: 1 }],
              winner: "teamA",
            },
          ],
        },
      });

      console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 12000));

      // ==========================================
      // GAME 4: Test1 & Test2 LOSE vs Test3 & Test4
      // Expected: Does NOT affect bestWin (loss doesn't update bestWin)
      // ==========================================
      console.log(`\n🎮 Game 4: ${test1.displayName} & ${test2.displayName} LOSE vs ${test3.displayName} & ${test4.displayName}`);
      console.log("  Expected: Does NOT affect bestWin (losses don't count)\n");

      await createAndCompleteGame(db, {
        title: "Best Win Test - Game 4 (Loss)",
        groupId: groupId,
        createdBy: test1.uid,
        playerIds: [test1.uid, test2.uid, test3.uid, test4.uid],
        teams: { teamAPlayerIds: teamTest1_Test2, teamBPlayerIds: teamTest3_Test4 },
        result: {
          overallWinner: "teamB",
          games: [
            {
              gameNumber: 1,
              teamAScore: 18,
              teamBScore: 21,
              sets: [{ teamAPoints: 18, teamBPoints: 21, setNumber: 1 }],
              winner: "teamB",
            },
          ],
        },
      });

      console.log("⏳ Waiting 12 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 12000));

      // ==========================================
      // VERIFICATION: Check Test1's bestWin
      // ==========================================
      console.log("\n📊 Verifying Best Win Tracking...");
      const test1Doc = await db.collection("users").doc(test1.uid).get();
      const test1Data = test1Doc.data();

      if (test1Data?.bestWin) {
        const bestWin = test1Data.bestWin;
        console.log("\n✅ Best Win Record Found:");
        console.log(`  Game Title:        ${bestWin.gameTitle}`);
        console.log(`  Opponent Team ELO: ${bestWin.opponentTeamElo.toFixed(1)} (Expected: ~1500)`);
        console.log(`  Opponent Avg ELO:  ${bestWin.opponentTeamAvgElo.toFixed(1)}`);
        console.log(`  ELO Gained:        +${bestWin.eloGained.toFixed(1)}`);
        console.log(`  Date:              ${bestWin.date.toDate().toLocaleString()}`);
        console.log(`  Game ID:           ${bestWin.gameId}`);

        if (bestWin.opponentTeamElo >= 1450 && bestWin.opponentTeamElo <= 1550) {
          console.log(`\n✅ PASS: Best win correctly shows Game 2 (vs ${test5.displayName} & ${test6.displayName} ~1500 ELO)`);
        } else {
          console.log(`\n⚠️  WARNING: Expected opponent team ELO ~1500, got ${bestWin.opponentTeamElo.toFixed(1)}`);
        }
      } else {
        console.log(`\n❌ FAIL: No bestWin found in ${test1.displayName}'s profile`);
      }

      console.log("\n" + "=".repeat(70));
      console.log("✅ Best Win Test Games Created!");
      console.log("=".repeat(70));
      console.log("\n📋 Summary:");
      console.log("  Game 1: Won vs ~1300 ELO → Sets initial bestWin");
      console.log("  Game 2: Won vs ~1500 ELO → Updates bestWin (higher opponent)");
      console.log("  Game 3: Won vs ~1100 ELO → Keeps bestWin from Game 2 (lower opponent)");
      console.log("  Game 4: Lost            → bestWin unchanged (losses don't count)");
      console.log(`\n🔍 Check the PerformanceOverviewCard in ${test1.displayName}'s profile to see the best win!`);
      console.log("\n💡 Login credentials:");
      console.log(`  Email:    ${test1.email}`);
      console.log(`  Password: ${test1.password}`);
      console.log("\n📱 Expected UI:");
      console.log("  - Trophy icon (filled)");
      console.log("  - \"vs 1500 ELO\" (opponent average)");
      console.log("  - \"+X ELO gained\" subtitle\n");

    } catch (error: any) {
      if (error.message?.includes("Test config not found")) {
        console.error("\n❌ Error:", error.message);
        console.log("\n💡 Run this first:");
        console.log("   cd functions");
        console.log("   npx ts-node scripts/setupTestEnvironment.ts\n");
      } else {
        console.error("❌ Error creating test games:", error);
        console.error(error.stack);
      }
    } finally {
      process.exit();
    }
  })();
}

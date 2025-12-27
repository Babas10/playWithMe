import * as admin from "firebase-admin";
import { getTestUser, getTestGroupId, printTestConfig } from "./testConfigLoader";

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "playwithme-dev",
  });
}

/**
 * Creates a game document in Firestore scheduled at NOW (not 1 hour from now).
 * First creates it as 'scheduled', then updates to 'completed' to trigger lifecycle events.
 */
async function createAndCompleteGame(
  db: admin.firestore.Firestore,
  gameData: {
    title: string;
    groupId: string;
    createdBy: string;
    playerIds: string[];
    teams: {
      teamAPlayerIds: string[];
      teamBPlayerIds: string[];
    };
    result: {
      overallWinner: string;
      games: any[];
    };
    minPlayers?: number;
    maxPlayers?: number;
  }
): Promise<string> {
  const now = admin.firestore.Timestamp.now();

  const scheduledGame = {
    title: gameData.title,
    groupId: gameData.groupId,
    createdBy: gameData.createdBy,
    status: "scheduled",
    scheduledAt: now, // ✅ FIXED: Schedule at NOW, not 1 hour from now
    createdAt: now,
    updatedAt: now,
    location: {
      name: "Test Court",
      address: "123 Test St",
    },
    minPlayers: gameData.minPlayers || 4,
    maxPlayers: gameData.maxPlayers || 4,
    playerIds: gameData.playerIds,
    waitlistIds: [],
    teams: null,
    result: null,
    eloCalculated: false,
  };

  // 1. Create Game (Scheduled)
  const gameRef = await db.collection("games").add(scheduledGame);
  console.log(`✅ Created Scheduled Game: ${gameRef.id}`);

  // Wait for the document to be fully created before updating (ensures Cloud Function triggers)
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 2. Update to Completed with Results
  await gameRef.update({
    status: "completed",
    teams: gameData.teams,
    result: gameData.result,
    completedAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
    // eloCalculated remains false to trigger ELO function
  });
  console.log(`✅ Updated Game ${gameRef.id} to Completed`);

  return gameRef.id;
}

/**
 * Creates a series of games to test the Nemesis feature.
 *
 * Scenario:
 * - User1 and User2 play against User3 and User4
 * - User1 LOSES 5 games and WINS 1 game against User3
 * - User1 LOSES 2 games and WINS 1 game against User4
 * - Result: User3 should be User1's nemesis (5 losses > 2 losses)
 *
 * This creates enough data for the nemesis detection algorithm to work:
 * - Minimum 3 games against an opponent
 * - User3 will be detected as nemesis for User1
 */
if (require.main === module) {
  (async () => {
    try {
      const db = admin.firestore();
      console.log("\n🔥 Connected to Project ID:", admin.app().options.projectId || "Unknown");
      console.log("📊 Creating Nemesis Test Games...\n");

      // ==========================================
      // LOAD USER IDS FROM TEST CONFIG
      // ==========================================
      const user1 = getTestUser(0); // Alice (will have nemesis)
      const user2 = getTestUser(1); // Bob (teammate)
      const user3 = getTestUser(2); // Charlie (nemesis - most losses)
      const user4 = getTestUser(3); // Diana (opponent - fewer losses)
      const groupId = getTestGroupId();

      const user1_uid = user1.uid;
      const user2_uid = user2.uid;
      const user3_uid = user3.uid;
      const user4_uid = user4.uid;

      const playerUids = [user1_uid, user2_uid, user3_uid, user4_uid];
      const teamA = [user1_uid, user2_uid]; // You and your teammate
      const teamB_Nemesis = [user3_uid, user4_uid]; // Opponents (User3 will be nemesis)

      console.log("👥 Players (loaded from testConfig.json):");
      console.log(`  User1 (you):       ${user1.displayName} (${user1_uid})`);
      console.log(`  User2 (teammate):  ${user2.displayName} (${user2_uid})`);
      console.log(`  User3 (nemesis):   ${user3.displayName} (${user3_uid})`);
      console.log(`  User4 (opponent):  ${user4.displayName} (${user4_uid})`);
      console.log(`  Group:             ${groupId}\n`);

      // ==========================================
      // GAME 1: Team A LOSES to Team B
      // User1 loses to User3 (1st loss)
      // ==========================================
      console.log("🎮 Game 1: Team A LOSES to Team B (User1 loses to User3)");
      await createAndCompleteGame(db, {
        title: "Nemesis Test Game 1",
        groupId: groupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamA, teamBPlayerIds: teamB_Nemesis },
        result: {
          overallWinner: "teamB",
          games: [
            {
              gameNumber: 1,
              teamAScore: 15,
              teamBScore: 21,
              sets: [{ teamAPoints: 15, teamBPoints: 21, setNumber: 1 }],
              winner: "teamB",
            },
          ],
        },
      });

      // Wait for Cloud Function to complete ELO calculation (same players)
      console.log("⏳ Waiting 10 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 10000));

      // ==========================================
      // GAME 2: Team A LOSES to Team B
      // User1 loses to User3 (2nd loss)
      // ==========================================
      console.log("\n🎮 Game 2: Team A LOSES to Team B (User1 loses to User3)");
      await createAndCompleteGame(db, {
        title: "Nemesis Test Game 2",
        groupId: groupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamA, teamBPlayerIds: teamB_Nemesis },
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

      // Wait for Cloud Function to complete ELO calculation (same players)
      console.log("⏳ Waiting 10 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 10000));

      // ==========================================
      // GAME 3: Team A LOSES to Team B
      // User1 loses to User3 (3rd loss - THRESHOLD MET!)
      // ==========================================
      console.log("\n🎮 Game 3: Team A LOSES to Team B (User1 loses to User3 - 3+ games threshold met!)");
      await createAndCompleteGame(db, {
        title: "Nemesis Test Game 3",
        groupId: groupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamA, teamBPlayerIds: teamB_Nemesis },
        result: {
          overallWinner: "teamB",
          games: [
            {
              gameNumber: 1,
              teamAScore: 19,
              teamBScore: 21,
              sets: [{ teamAPoints: 19, teamBPoints: 21, setNumber: 1 }],
              winner: "teamB",
            },
          ],
        },
      });

      // Wait for Cloud Function to complete ELO calculation (same players)
      console.log("⏳ Waiting 10 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 10000));

      // ==========================================
      // GAME 4: Team A WINS against Team B
      // User1 WINS against User3 (1 win)
      // ==========================================
      console.log("\n🎮 Game 4: Team A WINS against Team B (User1 gets 1 win against User3)");
      await createAndCompleteGame(db, {
        title: "Nemesis Test Game 4 - Win",
        groupId: groupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamA, teamBPlayerIds: teamB_Nemesis },
        result: {
          overallWinner: "teamA",
          games: [
            {
              gameNumber: 1,
              teamAScore: 21,
              teamBScore: 15,
              sets: [{ teamAPoints: 21, teamBPoints: 15, setNumber: 1 }],
              winner: "teamA",
            },
          ],
        },
      });

      // Wait for Cloud Function to complete ELO calculation (same players)
      console.log("⏳ Waiting 10 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 10000));

      // ==========================================
      // GAME 5: Team A LOSES to Team B
      // User1 loses to User3 (4th loss)
      // ==========================================
      console.log("\n🎮 Game 5: Team A LOSES to Team B (User1 loses to User3 again)");
      await createAndCompleteGame(db, {
        title: "Nemesis Test Game 5",
        groupId: groupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamA, teamBPlayerIds: teamB_Nemesis },
        result: {
          overallWinner: "teamB",
          games: [
            {
              gameNumber: 1,
              teamAScore: 17,
              teamBScore: 21,
              sets: [{ teamAPoints: 17, teamBPoints: 21, setNumber: 1 }],
              winner: "teamB",
            },
          ],
        },
      });

      // Wait for Cloud Function to complete ELO calculation (same players)
      console.log("⏳ Waiting 10 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 10000));

      // ==========================================
      // GAME 6: Team A LOSES to Team B
      // User1 loses to User3 (5th loss)
      // ==========================================
      console.log("\n🎮 Game 6: Team A LOSES to Team B (User1 loses to User3 - 5th loss!)");
      await createAndCompleteGame(db, {
        title: "Nemesis Test Game 6",
        groupId: groupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamA, teamBPlayerIds: teamB_Nemesis },
        result: {
          overallWinner: "teamB",
          games: [
            {
              gameNumber: 1,
              teamAScore: 16,
              teamBScore: 21,
              sets: [{ teamAPoints: 16, teamBPoints: 21, setNumber: 1 }],
              winner: "teamB",
            },
          ],
        },
      });

      console.log("\n✅ All Nemesis Test Games Created!\n");
      console.log("📊 Expected Results:");
      console.log(`  ${user1.displayName} record vs ${user3.displayName}: 1W - 5L (6 matchups, 16.7% win rate)`);
      console.log(`  ${user3.displayName} should be ${user1.displayName}'s nemesis ✅`);
      console.log(`\n🔍 Check the RivalsCard in ${user1.displayName}'s profile to see the nemesis!`);
      console.log(`\n💡 Login credentials:`);
      console.log(`  Email: ${user1.email}`);
      console.log(`  Password: ${user1.password}\n`);

    } catch (error: any) {
      if (error.message?.includes("Test config not found")) {
        console.error("\n❌ Error:", error.message);
        console.log("\n💡 Run this first:");
        console.log("   cd functions");
        console.log("   npx ts-node scripts/setupTestEnvironment.ts\n");
      } else {
        console.error("❌ Error creating test games:", error);
      }
    } finally {
      process.exit();
    }
  })();
}

export { createAndCompleteGame };

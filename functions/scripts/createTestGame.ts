import * as admin from "firebase-admin";
import { getTestUser, getTestGroupId } from "./testConfigLoader";

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
    admin.initializeApp({
        projectId: "playwithme-dev"
    });
}

/**
 * Creates a game document in Firestore.
 * First creates it as 'scheduled', then updates to 'completed' to trigger lifecycle events.
 */
export async function createAndCompleteGame(
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
    teams: null, // Teams usually assigned later or at creation, let's say null for scheduled
    result: null,
    eloCalculated: false,
  };

  // 1. Create Game (Scheduled)
  const gameRef = await db.collection("games").add(scheduledGame);
  console.log(`Created Scheduled Game: ${gameRef.id}`);

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
  console.log(`Updated Game ${gameRef.id} to Completed`);

  return gameRef.id;
}

if (require.main === module) {
  (async () => {
    try {
      const db = admin.firestore();
      console.log("\n🔥 Connected to Project ID:", admin.app().options.projectId || "Unknown");
      console.log("📊 Creating Test Game Scenarios...\n");

      // Load test users from config
      const user1 = getTestUser(0); // Alice
      const user2 = getTestUser(1); // Bob
      const user3 = getTestUser(2); // Charlie
      const user4 = getTestUser(3); // Diana
      const specifiedGroupId = getTestGroupId();

      const user1_uid = user1.uid;
      const user2_uid = user2.uid;
      const user3_uid = user3.uid;
      const user4_uid = user4.uid;

      const playerUids = [user1_uid, user2_uid, user3_uid, user4_uid];
      const teamAPlayers = [user1_uid, user2_uid];
      const teamBPlayers = [user3_uid, user4_uid];

      console.log("👥 Players (loaded from testConfig.json):");
      console.log(`  ${user1.displayName}: ${user1_uid}`);
      console.log(`  ${user2.displayName}: ${user2_uid}`);
      console.log(`  ${user3.displayName}: ${user3_uid}`);
      console.log(`  ${user4.displayName}: ${user4_uid}`);
      console.log(`  Group: ${specifiedGroupId}\n`);

      // --- Scenario A: 1 Game, 1 Set, 1 Result (Standard) ---
      console.log("\n--- Running Scenario A ---");
      await createAndCompleteGame(db, {
        title: "Scenario A: Single Set Match",
        groupId: specifiedGroupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamAPlayers, teamBPlayerIds: teamBPlayers },
        result: {
          overallWinner: "teamA",
          games: [
            {
              gameNumber: 1,
              teamAScore: 21,
              teamBScore: 19,
              sets: [{ teamAPoints: 21, teamBPoints: 19, setNumber: 1 }],
              winner: "teamA"
            }
          ],
        },
      });

      // Wait for Cloud Function to complete ELO calculation (same players)
      console.log("⏳ Waiting 10 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 10000));

      // --- Scenario B: Best of 3 (2-1 sets) ---
      console.log("\n--- Running Scenario B ---");
      await createAndCompleteGame(db, {
        title: "Scenario B: Best of 3 Match",
        groupId: specifiedGroupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamAPlayers, teamBPlayerIds: teamBPlayers },
        result: {
          overallWinner: "teamA",
          games: [
            {
              gameNumber: 1,
              teamAScore: 54, // 21 + 18 + 15
              teamBScore: 48, // 15 + 21 + 12
              sets: [
                { teamAPoints: 21, teamBPoints: 15, setNumber: 1 }, // A wins
                { teamAPoints: 18, teamBPoints: 21, setNumber: 2 }, // B wins
                { teamAPoints: 15, teamBPoints: 12, setNumber: 3 }  // A wins (short set)
              ],
              winner: "teamA"
            }
          ],
        },
      });

      // Wait for Cloud Function to complete ELO calculation (same players)
      console.log("⏳ Waiting 10 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 10000));

      // --- Scenario C: 5 Games of 1 Set (Play Session) ---
      console.log("\n--- Running Scenario C ---");
      await createAndCompleteGame(db, {
        title: "Scenario C: 5 Single Games Session",
        groupId: specifiedGroupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamAPlayers, teamBPlayerIds: teamBPlayers },
        result: {
          overallWinner: "teamA", // A wins 3-2
          games: [
            { gameNumber: 1, teamAScore: 21, teamBScore: 19, sets: [{ teamAPoints: 21, teamBPoints: 19, setNumber: 1 }], winner: "teamA" },
            { gameNumber: 2, teamAScore: 15, teamBScore: 21, sets: [{ teamAPoints: 15, teamBPoints: 21, setNumber: 1 }], winner: "teamB" },
            { gameNumber: 3, teamAScore: 21, teamBScore: 10, sets: [{ teamAPoints: 21, teamBPoints: 10, setNumber: 1 }], winner: "teamA" },
            { gameNumber: 4, teamAScore: 20, teamBScore: 22, sets: [{ teamAPoints: 20, teamBPoints: 22, setNumber: 1 }], winner: "teamB" },
            { gameNumber: 5, teamAScore: 21, teamBScore: 18, sets: [{ teamAPoints: 21, teamBPoints: 18, setNumber: 1 }], winner: "teamA" },
          ],
        },
      });

      // Wait for Cloud Function to complete ELO calculation (same players)
      console.log("⏳ Waiting 10 seconds for Cloud Function to complete...");
      await new Promise(resolve => setTimeout(resolve, 10000));

      // --- Scenario D: 2 Games, Each Best of 3 (2-1 sets) ---
      console.log("\n--- Running Scenario D ---");
      await createAndCompleteGame(db, {
        title: "Scenario D: 2 Best-of-3 Matches",
        groupId: specifiedGroupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamAPlayers, teamBPlayerIds: teamBPlayers },
        result: {
          overallWinner: "teamB", // B wins 2-0 in matches
          games: [
            {
              gameNumber: 1,
              teamAScore: 46, // 21 + 15 + 10
              teamBScore: 55, // 19 + 21 + 15
              sets: [
                { teamAPoints: 21, teamBPoints: 19, setNumber: 1 },
                { teamAPoints: 15, teamBPoints: 21, setNumber: 2 },
                { teamAPoints: 10, teamBPoints: 15, setNumber: 3 } // B wins
              ],
              winner: "teamB"
            },
            {
              gameNumber: 2,
              teamAScore: 51, // 18 + 21 + 12
              teamBScore: 55, // 21 + 19 + 15
              sets: [
                { teamAPoints: 18, teamBPoints: 21, setNumber: 1 },
                { teamAPoints: 21, teamBPoints: 19, setNumber: 2 },
                { teamAPoints: 12, teamBPoints: 15, setNumber: 3 } // B wins
              ],
              winner: "teamB"
            }
          ],
        },
      });

      console.log("\n✅ All Test Game Scenarios Created!\n");

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
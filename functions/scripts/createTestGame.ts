import * as admin from "firebase-admin";

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

  // Simulate a small delay or just update immediately
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
      console.log("Connected to Project ID:", admin.app().options.projectId || "Unknown");

      const user1_uid = "I1rVhwkQTyXL1iyBLSDNQPPiFnY2"; 
      const user2_uid = "UqxXx3SdnGSMxUehOtuwMJaglvM2"; 
      const user3_uid = "tdIxTUx9V0Z9gYGuOovsrsr8MMJ3"; 
      const user4_uid = "xauayf2DGXcGlASNhZDhBVGR7Rr1"; 
      const specifiedGroupId = "9RScLpdoeiG5UHKMD8tB";

      const playerUids = [user1_uid, user2_uid, user3_uid, user4_uid];
      const teamAPlayers = [user1_uid, user2_uid];
      const teamBPlayers = [user3_uid, user4_uid];

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
              sets: [{ teamAPoints: 21, teamBPoints: 19, setNumber: 1 }],
              winner: "teamA"
            }
          ],
        },
      });

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
            { gameNumber: 1, sets: [{ teamAPoints: 21, teamBPoints: 19, setNumber: 1 }], winner: "teamA" },
            { gameNumber: 2, sets: [{ teamAPoints: 15, teamBPoints: 21, setNumber: 1 }], winner: "teamB" },
            { gameNumber: 3, sets: [{ teamAPoints: 21, teamBPoints: 10, setNumber: 1 }], winner: "teamA" },
            { gameNumber: 4, sets: [{ teamAPoints: 20, teamBPoints: 22, setNumber: 1 }], winner: "teamB" },
            { gameNumber: 5, sets: [{ teamAPoints: 21, teamBPoints: 18, setNumber: 1 }], winner: "teamA" },
          ],
        },
      });

      // --- Scenario D: 2 Games, Each Best of 3 (2-1 sets) ---
      console.log("\n--- Running Scenario D ---");
      await createAndCompleteGame(db, {
        title: "Scenario D: 2 Best-of-3 Matches",
        groupId: specifiedGroupId,
        createdBy: user1_uid,
        playerIds: playerUids,
        teams: { teamAPlayerIds: teamAPlayers, teamBPlayerIds: teamBPlayers },
        result: {
          overallWinner: "teamB", // B wins 2-0 in matches (or 1-1 tied? let's say tied 1-1, but overallWinner field forces one)
          // Wait, 'overallWinner' in GameResult usually implies who won more games.
          // If we have 2 games, and it's 1-1, 'overallWinner' logic might be ambiguous in the model or just whoever won last?
          // Let's make Team B win both matches for clarity.
          games: [
            {
              gameNumber: 1,
              sets: [
                { teamAPoints: 21, teamBPoints: 19, setNumber: 1 },
                { teamAPoints: 15, teamBPoints: 21, setNumber: 2 },
                { teamAPoints: 10, teamBPoints: 15, setNumber: 3 } // B wins
              ],
              winner: "teamB"
            },
            {
              gameNumber: 2,
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

    } catch (error) {
      console.error("Error creating test games:", error);
    } finally {
      process.exit();
    }
  })();
}
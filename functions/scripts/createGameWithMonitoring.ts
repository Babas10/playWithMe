import * as admin from "firebase-admin";
import { getTestUser, getTestGroupId } from "./testConfigLoader";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "gatherli-dev",
  });
}

/**
 * Creates a single test game and monitors its processing
 */
async function createGameWithMonitoring() {
  const db = admin.firestore();

  console.log("\n🎮 CREATING TEST GAME WITH MONITORING\n");
  console.log("=".repeat(60));

  // Load test users
  const user1 = getTestUser(0);
  const user2 = getTestUser(1);
  const user3 = getTestUser(2);
  const user4 = getTestUser(3);
  const groupId = getTestGroupId();

  const teamA = [user1.uid, user2.uid];
  const teamB = [user3.uid, user4.uid];

  console.log("\n👥 Players:");
  console.log(`  Team A: ${user1.displayName}, ${user2.displayName}`);
  console.log(`  Team B: ${user3.displayName}, ${user4.displayName}`);
  console.log(`  Group: ${groupId}\n`);

  // Step 1: Create as scheduled
  console.log("📝 Step 1: Creating game as 'scheduled'...");
  const gameRef = db.collection("games").doc();
  const gameId = gameRef.id;

  await gameRef.set({
    title: "Debug Test Game",
    groupId: groupId,
    createdBy: user1.uid,
    status: "scheduled",
    scheduledAt: admin.firestore.Timestamp.now(),
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
    location: {
      name: "Test Court",
      address: "123 Test St",
    },
    minPlayers: 4,
    maxPlayers: 4,
    playerIds: [user1.uid, user2.uid, user3.uid, user4.uid],
    waitlistIds: [],
    eloCalculated: false,
  });

  console.log(`✅ Game created with ID: ${gameId}`);
  console.log(`   Status: scheduled`);

  // Wait a moment
  console.log("\n⏳ Waiting 2 seconds before updating to completed...");
  await new Promise((resolve) => setTimeout(resolve, 2000));

  // Step 2: Update to completed
  console.log("\n📝 Step 2: Updating game to 'completed'...");
  console.log("   This should trigger onGameStatusChanged Cloud Function");

  const beforeUpdate = Date.now();

  await gameRef.update({
    status: "completed",
    startedAt: admin.firestore.Timestamp.now(),
    completedAt: admin.firestore.Timestamp.now(),
    teams: {
      teamAPlayerIds: teamA,
      teamBPlayerIds: teamB,
    },
    result: {
      overallWinner: "teamA",
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
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`✅ Game updated to completed`);
  console.log(`   Time: ${new Date().toISOString()}`);

  // Monitor the game document for changes
  console.log("\n⏰ Monitoring game for ELO calculation...");
  console.log("   Checking every 2 seconds for up to 30 seconds\n");

  let attempts = 0;
  const maxAttempts = 15; // 30 seconds total

  while (attempts < maxAttempts) {
    attempts++;
    await new Promise((resolve) => setTimeout(resolve, 2000));

    const gameDoc = await gameRef.get();
    const gameData = gameDoc.data();

    const elapsed = Math.floor((Date.now() - beforeUpdate) / 1000);
    console.log(`[${elapsed}s] Checking... (attempt ${attempts}/${maxAttempts})`);

    if (!gameData) {
      console.log("   ❌ Game document not found!");
      break;
    }

    // Check eloCalculated
    if (gameData.eloCalculated === true) {
      console.log(`   ✅ eloCalculated: true`);
    } else {
      console.log(`   ⏳ eloCalculated: ${gameData.eloCalculated || false}`);
    }

    // Check eloUpdates
    if (gameData.eloUpdates !== undefined) {
      const isEmpty = JSON.stringify(gameData.eloUpdates) === "{}";
      if (isEmpty) {
        console.log(`   ⚠️  eloUpdates: {} (EMPTY - this is the bug!)`);
      } else {
        const playerCount = Object.keys(gameData.eloUpdates).length;
        console.log(`   ✅ eloUpdates: ${playerCount} players updated`);

        // Show first player's update
        const firstPlayerId = Object.keys(gameData.eloUpdates)[0];
        const update = gameData.eloUpdates[firstPlayerId];
        console.log(
          `      Example: ${update.previousRating} → ${update.newRating} (${update.change > 0 ? "+" : ""}${update.change})`
        );
      }
    } else {
      console.log(`   ⏳ eloUpdates: undefined (not yet processed)`);
    }

    // If processed successfully, we're done
    if (
      gameData.eloCalculated === true &&
      gameData.eloUpdates &&
      Object.keys(gameData.eloUpdates).length > 0
    ) {
      console.log("\n🎉 SUCCESS! ELO calculation completed");
      console.log(`   Total time: ${elapsed} seconds`);

      // Check one player's stats
      const playerId = teamA[0];
      const playerDoc = await db.collection("users").doc(playerId).get();
      const playerData = playerDoc.data();

      console.log(`\n👤 Player Stats (${user1.displayName}):`);
      console.log(`   ELO Rating: ${playerData?.eloRating || "N/A"}`);
      console.log(`   Games Played: ${playerData?.gamesPlayed || 0}`);
      console.log(`   Wins: ${playerData?.wins || 0}`);
      console.log(`   Losses: ${playerData?.losses || 0}`);

      return;
    }

    // If we see empty eloUpdates, that's the bug
    if (gameData.eloUpdates && JSON.stringify(gameData.eloUpdates) === "{}") {
      console.log("\n❌ BUG DETECTED: Empty eloUpdates object");
      console.log("   This prevents the Cloud Function from running");
      console.log("   (idempotency check sees truthy empty object)");
      return;
    }
  }

  console.log("\n⏱️  Timeout reached after 30 seconds");
  console.log("   Cloud Function did not complete processing");
  console.log("\n💡 Next steps:");
  console.log("   1. Check Cloud Function logs:");
  console.log(`      firebase functions:log --only onGameStatusChanged --project gatherli-dev`);
  console.log("\n   2. Check if function is running:");
  console.log(`      firebase functions:list --project gatherli-dev | grep onGameStatusChanged`);
}

if (require.main === module) {
  createGameWithMonitoring()
    .then(() => {
      console.log("\n✅ Monitoring complete\n");
      process.exit(0);
    })
    .catch((error) => {
      console.error("❌ Error:", error);
      process.exit(1);
    });
}

export { createGameWithMonitoring };

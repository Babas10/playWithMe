import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "playwithme-dev",
  });
}

/**
 * Debug script to check if games are being processed correctly
 * and diagnose why ELO might not be calculating
 */
async function debugGameProcessing() {
  const db = admin.firestore();

  console.log("\n🔍 DEBUGGING GAME PROCESSING\n");
  console.log("=".repeat(60));

  // Get all completed games
  const gamesSnapshot = await db
    .collection("games")
    .where("status", "==", "completed")
    .limit(10)
    .get();

  if (gamesSnapshot.empty) {
    console.log("❌ No completed games found");
    return;
  }

  console.log(`\n📊 Found ${gamesSnapshot.size} completed games\n`);

  for (const gameDoc of gamesSnapshot.docs) {
    const game = gameDoc.data();
    const gameId = gameDoc.id;

    console.log("\n" + "─".repeat(60));
    console.log(`Game ID: ${gameId}`);
    console.log(`Title: ${game.title || "Untitled"}`);
    console.log(`Created: ${game.createdAt?.toDate?.() || "Unknown"}`);
    console.log(`Completed: ${game.completedAt?.toDate?.() || "Unknown"}`);

    // Check critical fields
    console.log("\n🔍 Critical Fields:");
    console.log(`  status: ${game.status}`);
    console.log(`  eloCalculated: ${game.eloCalculated}`);
    console.log(`  eloUpdates exists: ${game.eloUpdates !== undefined}`);

    if (game.eloUpdates !== undefined) {
      const isEmpty = JSON.stringify(game.eloUpdates) === "{}";
      console.log(`  eloUpdates empty: ${isEmpty}`);
      if (!isEmpty) {
        console.log(`  eloUpdates keys: ${Object.keys(game.eloUpdates).length} players`);
      }
    }

    // Check teams
    console.log("\n👥 Teams:");
    if (game.teams) {
      console.log(`  Team A: ${game.teams.teamAPlayerIds?.length || 0} players`);
      console.log(`  Team B: ${game.teams.teamBPlayerIds?.length || 0} players`);
      if (game.teams.teamAPlayerIds) {
        console.log(`    ${game.teams.teamAPlayerIds.join(", ")}`);
      }
      if (game.teams.teamBPlayerIds) {
        console.log(`    ${game.teams.teamBPlayerIds.join(", ")}`);
      }
    } else {
      console.log("  ❌ No teams data");
    }

    // Check result
    console.log("\n🏆 Result:");
    if (game.result) {
      console.log(`  Overall Winner: ${game.result.overallWinner || "N/A"}`);
      console.log(`  Games: ${game.result.games?.length || 0}`);

      if (game.result.games && game.result.games.length > 0) {
        game.result.games.forEach((g: any, idx: number) => {
          console.log(`\n  Game ${idx + 1}:`);
          console.log(`    Winner: ${g.winner}`);
          console.log(`    teamAScore: ${g.teamAScore !== undefined ? g.teamAScore : "❌ MISSING"}`);
          console.log(`    teamBScore: ${g.teamBScore !== undefined ? g.teamBScore : "❌ MISSING"}`);
          console.log(`    Sets: ${g.sets?.length || 0}`);
        });
      }
    } else {
      console.log("  ❌ No result data");
    }

    // Diagnosis
    console.log("\n🩺 Diagnosis:");
    const issues: string[] = [];

    if (!game.teams) {
      issues.push("Missing teams data");
    }
    if (!game.result) {
      issues.push("Missing result data");
    }
    if (!game.result?.games || game.result.games.length === 0) {
      issues.push("Missing games array in result");
    }
    if (game.result?.games) {
      game.result.games.forEach((g: any, idx: number) => {
        if (g.teamAScore === undefined) {
          issues.push(`Game ${idx + 1} missing teamAScore`);
        }
        if (g.teamBScore === undefined) {
          issues.push(`Game ${idx + 1} missing teamBScore`);
        }
        if (!g.winner) {
          issues.push(`Game ${idx + 1} missing winner`);
        }
      });
    }

    if (game.eloUpdates && JSON.stringify(game.eloUpdates) === "{}") {
      issues.push("Empty eloUpdates object (idempotency check will skip)");
    }

    if (game.eloCalculated === true && game.eloUpdates && Object.keys(game.eloUpdates).length > 0) {
      console.log("  ✅ ELO PROCESSED SUCCESSFULLY");
    } else if (issues.length > 0) {
      console.log("  ❌ ISSUES FOUND:");
      issues.forEach((issue) => console.log(`     - ${issue}`));
    } else {
      console.log("  ⏳ Waiting for Cloud Function to process");
    }

    // Check if Cloud Function should have run
    const timeSinceCompletion = Date.now() - (game.completedAt?.toDate?.()?.getTime() || 0);
    const secondsSince = Math.floor(timeSinceCompletion / 1000);
    console.log(`\n⏰ Time since completion: ${secondsSince} seconds`);

    if (secondsSince > 30 && !game.eloCalculated) {
      console.log("  ⚠️  Cloud Function should have run by now!");
      console.log("  💡 Check Firebase logs: firebase functions:log --only onGameStatusChanged");
    }
  }

  console.log("\n" + "=".repeat(60));
  console.log("\n💡 Next Steps:");
  console.log("  1. Check Cloud Function logs:");
  console.log("     firebase functions:log --only onGameStatusChanged --project playwithme-dev");
  console.log("\n  2. Monitor logs in real-time:");
  console.log("     firebase functions:log --only onGameStatusChanged --project playwithme-dev --follow");
  console.log("\n  3. Check if function is deployed:");
  console.log("     firebase functions:list --project playwithme-dev");
  console.log("");
}

if (require.main === module) {
  debugGameProcessing()
    .then(() => {
      console.log("\n✅ Debug complete\n");
      process.exit(0);
    })
    .catch((error) => {
      console.error("❌ Error:", error);
      process.exit(1);
    });
}

export { debugGameProcessing };

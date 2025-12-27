/**
 * Check Nemesis Data Script
 *
 * Quick diagnostic script to check nemesis detection data in Firestore.
 * Useful for debugging nemesis feature and head-to-head stats.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/checkNemesis.ts
 *
 * Optional: Pass user index as argument (defaults to 0 = Alice)
 *   npx ts-node scripts/checkNemesis.ts 1  # Check Bob (index 1)
 */

import * as admin from "firebase-admin";
import { getTestUser, getAllTestUserIds } from "./testConfigLoader";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "playwithme-dev",
  });
}

const db = admin.firestore();

async function checkNemesis(userIndex: number = 0) {
  try {
    // Load user from test config
    const user = getTestUser(userIndex);
    const userId = user.uid;

    console.log("\n🔍 Checking Nemesis Data");
    console.log("=".repeat(60));
    console.log(`User: ${user.displayName} (${user.email})`);
    console.log(`UID: ${userId}`);
    console.log("=".repeat(60));

    // 1. Check user document for nemesis field
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();

    console.log("\n1️⃣ User Document - Nemesis Field:");
    if (userData && userData.nemesis) {
      console.log("✅ Nemesis exists!");
      console.log(JSON.stringify(userData.nemesis, null, 2));
    } else {
      console.log("❌ No nemesis field found in user document");
      console.log("   This is normal if the user hasn't played enough games yet.");
    }

    // 2. Check head-to-head subcollection
    console.log("\n2️⃣ Head-to-Head Stats:");
    const h2hSnapshot = await db
      .collection("users")
      .doc(userId)
      .collection("headToHead")
      .get();

    if (h2hSnapshot.empty) {
      console.log("❌ No head-to-head records found!");
      console.log("   Run createNemesisTestGames.ts to create test data.");
    } else {
      console.log(`✅ Found ${h2hSnapshot.size} head-to-head records:\n`);

      // Sort by games played (descending)
      const h2hStats = h2hSnapshot.docs.map((doc) => ({
        opponentId: doc.id,
        ...doc.data(),
      }));

      h2hStats.sort((a: any, b: any) => (b.gamesPlayed || 0) - (a.gamesPlayed || 0));

      h2hStats.forEach((stats: any) => {
        const gamesPlayed = stats.gamesPlayed || 0;
        const gamesWon = stats.gamesWon || 0;
        const gamesLost = stats.gamesLost || 0;
        const winRate =
          gamesPlayed > 0 ? ((gamesWon / gamesPlayed) * 100).toFixed(1) : 0;
        const opponentName = stats.opponentName || "Unknown";

        console.log(`  Opponent: ${opponentName} (${stats.opponentId})`);
        console.log(
          `    Games: ${gamesPlayed} (${gamesWon}W - ${gamesLost}L)`
        );
        console.log(`    Win Rate: ${winRate}%`);

        if (stats.largestVictoryMargin !== undefined) {
          console.log(`    Biggest Win: +${stats.largestVictoryMargin} points`);
        }
        if (stats.largestDefeatMargin !== undefined) {
          console.log(`    Worst Loss: -${stats.largestDefeatMargin} points`);
        }
        if (stats.pointDifferential !== undefined) {
          console.log(`    Point Differential: ${stats.pointDifferential > 0 ? "+" : ""}${stats.pointDifferential}`);
        }
        console.log("");
      });
    }

    // 3. Check completed games
    console.log("3️⃣ Completed Games:");
    const gamesSnapshot = await db
      .collection("games")
      .where("status", "==", "completed")
      .where("playerIds", "array-contains", userId)
      .orderBy("completedAt", "desc")
      .limit(10)
      .get();

    console.log(`✅ Found ${gamesSnapshot.size} completed games\n`);
    gamesSnapshot.forEach((doc) => {
      const game = doc.data();
      console.log(`  Game: ${doc.id}`);
      console.log(`    Title: ${game.title || "Untitled"}`);
      console.log(`    Status: ${game.status}`);
      console.log(`    ELO Calculated: ${game.eloCalculated}`);
      console.log(
        `    Completed At: ${
          game.completedAt ? game.completedAt.toDate() : "N/A"
        }`
      );
      if (game.teams) {
        console.log(`    Team A: ${game.teams.teamAPlayerIds?.join(", ")}`);
        console.log(`    Team B: ${game.teams.teamBPlayerIds?.join(", ")}`);
      }
      if (game.result) {
        console.log(`    Winner: ${game.result.overallWinner}`);
      }
      console.log("");
    });

    // 4. Summary and Diagnosis
    console.log("=".repeat(60));
    console.log("\n💡 Diagnosis:");

    if (!userData?.nemesis && h2hSnapshot.size === 0) {
      console.log("  ❌ No nemesis or H2H data found");
      console.log("     → Run createNemesisTestGames.ts to create test data");
    } else if (!userData?.nemesis && h2hSnapshot.size > 0) {
      console.log("  ⚠️  H2H stats exist but no nemesis detected");
      console.log("     → Need at least 3 games against one opponent");
      console.log("     → Nemesis only set if win rate < 50%");
    } else if (userData?.nemesis) {
      console.log("  ✅ Nemesis feature working correctly!");
    }

    if (gamesSnapshot.size > 0) {
      const allCalculated = gamesSnapshot.docs.every(
        (doc) => doc.data().eloCalculated === true
      );
      if (allCalculated) {
        console.log("  ✅ All games have been processed by stats tracking");
      } else {
        console.log("  ⚠️  Some games not yet processed (eloCalculated = false)");
        console.log("     → Stats tracking Cloud Function may need to run");
      }
    }

    console.log("\n");
  } catch (error: any) {
    if (error.message?.includes("Test config not found")) {
      console.error("\n❌ Error:", error.message);
      console.log("\n💡 Run this first:");
      console.log("   cd functions");
      console.log("   npx ts-node scripts/setupTestEnvironment.ts\n");
    } else {
      throw error;
    }
  }
}

// Run the script
if (require.main === module) {
  // Allow passing user index as command line argument
  const userIndex = process.argv[2] ? parseInt(process.argv[2], 10) : 0;

  if (isNaN(userIndex) || userIndex < 0 || userIndex > 9) {
    console.error("❌ Invalid user index. Must be 0-9.");
    console.log("\nUsage: npx ts-node scripts/checkNemesis.ts [userIndex]");
    console.log("Example: npx ts-node scripts/checkNemesis.ts 0  # Check Alice");
    console.log("         npx ts-node scripts/checkNemesis.ts 1  # Check Bob");
    process.exit(1);
  }

  checkNemesis(userIndex)
    .then(() => process.exit(0))
    .catch((err) => {
      console.error("\n❌ Error:", err);
      process.exit(1);
    });
}

export { checkNemesis };

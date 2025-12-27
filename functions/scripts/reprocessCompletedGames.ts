/**
 * Reprocess Completed Games
 *
 * This script retroactively processes all completed games that have eloCalculated=false
 * by triggering a status update that will invoke the Cloud Function.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/reprocessCompletedGames.ts
 */

import * as admin from "firebase-admin";

admin.initializeApp({
  projectId: "playwithme-dev",
});

const db = admin.firestore();

async function reprocessCompletedGames() {
  console.log("\n🔄 Reprocessing completed games...\n");
  console.log("=".repeat(60));

  // Find all completed games with eloCalculated=false
  const gamesSnapshot = await db
    .collection("games")
    .where("status", "==", "completed")
    .where("eloCalculated", "==", false)
    .get();

  console.log(`\nFound ${gamesSnapshot.size} completed games to process\n`);

  if (gamesSnapshot.size === 0) {
    console.log("✅ All games already processed!\n");
    return;
  }

  let processedCount = 0;
  let errorCount = 0;

  for (const doc of gamesSnapshot.docs) {
    const gameData = doc.data();

    try {
      console.log(`Processing: ${gameData.title} (${doc.id})`);

      // Trigger the Cloud Function by updating the status
      // We'll set it to "verification" first, then back to "completed"
      // This causes the onUpdate trigger to fire

      await doc.ref.update({
        status: "verification",
        updatedAt: admin.firestore.Timestamp.now(),
      });

      // Wait a moment
      await new Promise((resolve) => setTimeout(resolve, 500));

      // Update back to completed - this will trigger the Cloud Function
      await doc.ref.update({
        status: "completed",
        updatedAt: admin.firestore.Timestamp.now(),
      });

      console.log(`  ✅ Triggered processing for ${doc.id}`);
      processedCount++;

      // Wait 2 seconds between games to avoid overwhelming Cloud Functions
      await new Promise((resolve) => setTimeout(resolve, 2000));
    } catch (error) {
      console.error(`  ❌ Error processing ${doc.id}:`, error);
      errorCount++;
    }
  }

  console.log("\n" + "=".repeat(60));
  console.log(`\n✅ Processing complete!`);
  console.log(`   Triggered: ${processedCount} games`);
  console.log(`   Errors: ${errorCount} games`);
  console.log(`\n💡 Wait a few seconds, then check if eloCalculated=true`);
  console.log(`   Run: node scripts/checkGameStats.js\n`);
}

reprocessCompletedGames()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("\n❌ Error:", err);
    process.exit(1);
  });

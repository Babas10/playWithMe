import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

// Initialize Firebase Admin SDK
admin.initializeApp({
  projectId: "playwithme-dev",
});

const db = admin.firestore();

async function checkEloHistory() {
  // Load config to get user ID
  const configPath = path.join(__dirname, "testConfig.json");
  if (!fs.existsSync(configPath)) {
    console.error("❌ testConfig.json not found!");
    process.exit(1);
  }
  const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
  const testUser = config.users.find((u: any) => u.email === "test1@mysta.com");

  if (!testUser) {
    console.error("❌ Test user 1 not found in config!");
    process.exit(1);
  }

  console.log(`Checking rating history for ${testUser.displayName} (${testUser.uid})...`);

  // Check User Document
  const userDoc = await db.collection("users").doc(testUser.uid).get();
  console.log("User Document Data:");
  console.log(`  eloRating: ${userDoc.data()?.eloRating}`);
  console.log(`  eloGamesPlayed: ${userDoc.data()?.eloGamesPlayed}`);

  // Check Rating History
  const historySnapshot = await db
    .collection(`users/${testUser.uid}/ratingHistory`)
    .orderBy("timestamp", "desc")
    .get();

  console.log(`
Found ${historySnapshot.size} rating history entries.`);

  if (historySnapshot.empty) {
    console.log("❌ No history found! Cloud Function might have failed or hasn't run yet.");
  } else {
    historySnapshot.docs.forEach((doc, index) => {
      const data = doc.data();
      const date = (data.timestamp as admin.firestore.Timestamp).toDate();
      console.log(`  ${index + 1}. [${date.toISOString()}] Game: ${data.gameId} | Rating: ${data.oldRating} -> ${data.newRating} (${data.ratingChange > 0 ? '+' : ''}${data.ratingChange})`);
    });
  }
}

checkEloHistory()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });

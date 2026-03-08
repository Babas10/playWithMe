import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp({ projectId: "gatherli-dev" });
const db = admin.firestore();

async function run() {
  const config = JSON.parse(
    fs.readFileSync(path.join(__dirname, "testConfig.json"), "utf8")
  );

  console.log("\n📊 USER ELO & STREAK STATUS\n" + "=".repeat(60));
  console.log("User      | ELO    | Games | Streak");
  console.log("-".repeat(60));

  for (const u of config.users) {
    const doc  = await db.collection("users").doc(u.uid).get();
    const data = doc.data();
    if (!data) { console.log(`${u.displayName}: NOT FOUND`); continue; }
    const elo     = String(data.eloRating ?? "?").padEnd(7);
    const played  = String(data.eloGamesPlayed ?? "?").padEnd(5);
    const streak  = data.currentStreak ?? "?";
    console.log(`${u.displayName.padEnd(10)}| ${elo} | ${played} | ${streak}`);
  }

  process.exit(0);
}

run().catch((e) => { console.error(e); process.exit(1); });

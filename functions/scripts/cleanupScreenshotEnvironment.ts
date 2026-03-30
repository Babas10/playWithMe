/**
 * Screenshot Environment Cleanup Script
 *
 * Reads screenshotConfig.json (written by setupScreenshotEnvironment.ts) and
 * deletes every document, subcollection, and Auth account that was created for
 * screenshots — without touching any other production data.
 *
 * What gets deleted (in safe order):
 *  - trainingSessions/{id}/participants  (subcollection)
 *  - trainingSessions/{id}/exercises     (subcollection)
 *  - trainingSessions/{id}/feedback      (subcollection)
 *  - trainingSessions/{id}               (documents)
 *  - games/{id}                          (documents)
 *  - groups/{groupId}                    (document)
 *  - friendships tagged screenshotData   (documents)
 *  - users/{uid}/ratingHistory           (subcollection)
 *  - users/{uid}                         (documents)
 *  - Firebase Auth accounts              (by UID)
 *  - screenshotConfig.json               (local file)
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/cleanupScreenshotEnvironment.ts
 *
 * ⚠️  Runs against gatherli-PROD. Only deletes screenshot-tagged data.
 */

import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp({ projectId: "gatherli-prod" });

const db   = admin.firestore();
const auth = admin.auth();

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface ScreenshotConfig {
  timestamp: string;
  project: string;
  users: { index: number; uid: string; email: string; displayName: string }[];
  groupId: string;
  games: { past: string[]; future: string[] };
  trainingSessions: { past: string[]; future: string[] };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

async function deleteSubcollection(
  docPath: string,
  subcollectionName: string
): Promise<number> {
  const snap = await db.collection(`${docPath}/${subcollectionName}`).get();
  if (snap.empty) return 0;

  const BATCH_SIZE = 400;
  let deleted = 0;
  for (let i = 0; i < snap.docs.length; i += BATCH_SIZE) {
    const batch = db.batch();
    snap.docs.slice(i, i + BATCH_SIZE).forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    deleted += Math.min(BATCH_SIZE, snap.docs.length - i);
  }
  return deleted;
}

async function deleteDocsInBatches(refs: FirebaseFirestore.DocumentReference[]): Promise<void> {
  const BATCH_SIZE = 400;
  for (let i = 0; i < refs.length; i += BATCH_SIZE) {
    const batch = db.batch();
    refs.slice(i, i + BATCH_SIZE).forEach((ref) => batch.delete(ref));
    await batch.commit();
  }
}

// ---------------------------------------------------------------------------
// Deletion steps
// ---------------------------------------------------------------------------

async function deleteTrainingSessions(config: ScreenshotConfig): Promise<void> {
  console.log("\n🏋️  DELETING TRAINING SESSIONS\n" + "=".repeat(50));

  const allIds = [...config.trainingSessions.past, ...config.trainingSessions.future];

  let totalParticipants = 0;
  let totalExercises    = 0;
  let totalFeedback     = 0;

  for (const id of allIds) {
    const docPath = `trainingSessions/${id}`;
    totalParticipants += await deleteSubcollection(docPath, "participants");
    totalExercises    += await deleteSubcollection(docPath, "exercises");
    totalFeedback     += await deleteSubcollection(docPath, "feedback");
  }

  const refs = allIds.map((id) => db.collection("trainingSessions").doc(id));
  await deleteDocsInBatches(refs);

  console.log(`  ✅ Deleted ${allIds.length} training sessions`);
  console.log(`     └─ ${totalParticipants} participants, ${totalExercises} exercises, ${totalFeedback} feedback entries`);
}

async function deleteGames(config: ScreenshotConfig): Promise<void> {
  console.log("\n🎮 DELETING GAMES\n" + "=".repeat(50));

  const allIds = [...config.games.past, ...config.games.future];
  const refs   = allIds.map((id) => db.collection("games").doc(id));
  await deleteDocsInBatches(refs);

  console.log(`  ✅ Deleted ${allIds.length} games (${config.games.past.length} past, ${config.games.future.length} future)`);
}

async function deleteGroup(config: ScreenshotConfig): Promise<void> {
  console.log("\n🏐 DELETING GROUP\n" + "=".repeat(50));

  await db.collection("groups").doc(config.groupId).delete();

  console.log(`  ✅ Deleted group ${config.groupId}`);
}

async function deleteFriendships(config: ScreenshotConfig): Promise<void> {
  console.log("\n👥 DELETING FRIENDSHIPS\n" + "=".repeat(50));

  // Query by screenshotData tag — avoids touching non-screenshot friendships
  const snap = await db.collection("friendships")
    .where("screenshotData", "==", true)
    .get();

  if (snap.empty) {
    console.log("  ℹ️  No screenshot friendships found");
    return;
  }

  const refs = snap.docs.map((d) => d.ref);
  await deleteDocsInBatches(refs);

  console.log(`  ✅ Deleted ${refs.length} friendships`);
}

async function deleteUserRatingHistory(config: ScreenshotConfig): Promise<void> {
  console.log("\n📊 DELETING RATING HISTORY\n" + "=".repeat(50));

  let total = 0;
  for (const user of config.users) {
    const deleted = await deleteSubcollection(`users/${user.uid}`, "ratingHistory");
    total += deleted;
  }

  console.log(`  ✅ Deleted ${total} rating history entries across ${config.users.length} users`);
}

async function deleteUserDocuments(config: ScreenshotConfig): Promise<void> {
  console.log("\n👤 DELETING USER DOCUMENTS\n" + "=".repeat(50));

  const refs = config.users.map((u) => db.collection("users").doc(u.uid));
  await deleteDocsInBatches(refs);

  console.log(`  ✅ Deleted ${refs.length} user documents`);
}

async function deleteAuthAccounts(config: ScreenshotConfig): Promise<void> {
  console.log("\n🔐 DELETING AUTH ACCOUNTS\n" + "=".repeat(50));

  const uids = config.users.map((u) => u.uid);
  const result = await auth.deleteUsers(uids);

  if (result.errors.length > 0) {
    for (const err of result.errors) {
      console.warn(`  ⚠️  Failed to delete UID ${uids[err.index]}: ${err.error.message}`);
    }
  }

  const deleted = uids.length - result.errors.length;
  console.log(`  ✅ Deleted ${deleted}/${uids.length} Auth accounts`);
}

function deleteConfigFile(): void {
  console.log("\n🗑️  DELETING CONFIG FILE\n" + "=".repeat(50));

  const p = path.join(__dirname, "screenshotConfig.json");
  if (fs.existsSync(p)) {
    fs.unlinkSync(p);
    console.log(`  ✅ Deleted screenshotConfig.json`);
  } else {
    console.log(`  ℹ️  screenshotConfig.json not found — skipping`);
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main(): Promise<void> {
  const t0 = Date.now();

  console.log("\n" + "=".repeat(70));
  console.log("🧹 GATHERLI — SCREENSHOT ENVIRONMENT CLEANUP  (gatherli-PROD)");
  console.log("=".repeat(70));

  // Load config
  const configPath = path.join(__dirname, "screenshotConfig.json");
  if (!fs.existsSync(configPath)) {
    console.error("\n❌ screenshotConfig.json not found.");
    console.error("   Run setupScreenshotEnvironment.ts first, or restore the file.");
    process.exit(1);
  }

  const config: ScreenshotConfig = JSON.parse(fs.readFileSync(configPath, "utf-8"));

  if (config.project !== "gatherli-prod") {
    console.error(`\n❌ Config project mismatch: expected gatherli-prod, got "${config.project}"`);
    process.exit(1);
  }

  console.log(`\n📋 Config loaded`);
  console.log(`   Created:  ${config.timestamp}`);
  console.log(`   Users:    ${config.users.length}`);
  console.log(`   Group:    ${config.groupId}`);
  console.log(`   Games:    ${config.games.past.length + config.games.future.length}`);
  console.log(`   Sessions: ${config.trainingSessions.past.length + config.trainingSessions.future.length}`);
  console.log(`\n⚠️  Deleting all screenshot data from PRODUCTION...\n`);

  // Execute deletions in dependency order (children before parents)
  await deleteTrainingSessions(config);
  await deleteGames(config);
  await deleteGroup(config);
  await deleteFriendships(config);
  await deleteUserRatingHistory(config);
  await deleteUserDocuments(config);
  await deleteAuthAccounts(config);
  deleteConfigFile();

  const secs = ((Date.now() - t0) / 1000).toFixed(1);
  console.log("\n" + "=".repeat(70));
  console.log(`🧹 CLEANUP COMPLETE  (${secs}s)`);
  console.log("=".repeat(70));
  console.log(`
📊 Summary
   • ${config.trainingSessions.past.length + config.trainingSessions.future.length} training sessions + subcollections deleted
   • ${config.games.past.length + config.games.future.length} games deleted
   • 1 group deleted
   • Screenshot friendships deleted
   • ${config.users.length} user documents + rating histories deleted
   • ${config.users.length} Auth accounts deleted
   • screenshotConfig.json removed

✅ Production is back to its original state.
`);
}

// Guard: prod only
const pid = admin.app().options.projectId;
if (pid !== "gatherli-prod") {
  console.error(`❌ This script targets gatherli-prod (current: ${pid})`);
  process.exit(1);
}

main()
  .then(() => process.exit(0))
  .catch((e) => { console.error("❌ Error:", e); process.exit(1); });

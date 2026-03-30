/**
 * Access Environment Cleanup Script
 *
 * Reads accessConfig.json (written by setupAccessEnvironment.ts) and deletes
 * every document, subcollection, and Auth account created for app review —
 * without touching any other production data.
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/cleanupAccessEnvironment.ts
 *
 * ⚠️  Runs against gatherli-PROD. Only deletes access-tagged data.
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

interface AccessConfig {
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

async function deleteSubcollection(docPath: string, subcollectionName: string): Promise<number> {
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

async function deleteTrainingSessions(config: AccessConfig): Promise<void> {
  console.log("\n🏋️  DELETING TRAINING SESSIONS\n" + "=".repeat(50));

  const allIds = [...config.trainingSessions.past, ...config.trainingSessions.future];
  let totalParticipants = 0, totalExercises = 0, totalFeedback = 0;

  for (const id of allIds) {
    const docPath = `trainingSessions/${id}`;
    totalParticipants += await deleteSubcollection(docPath, "participants");
    totalExercises    += await deleteSubcollection(docPath, "exercises");
    totalFeedback     += await deleteSubcollection(docPath, "feedback");
  }

  await deleteDocsInBatches(allIds.map((id) => db.collection("trainingSessions").doc(id)));
  console.log(`  ✅ Deleted ${allIds.length} training sessions`);
  console.log(`     └─ ${totalParticipants} participants, ${totalExercises} exercises, ${totalFeedback} feedback entries`);
}

async function deleteGames(config: AccessConfig): Promise<void> {
  console.log("\n🎮 DELETING GAMES\n" + "=".repeat(50));

  const allIds = [...config.games.past, ...config.games.future];
  await deleteDocsInBatches(allIds.map((id) => db.collection("games").doc(id)));
  console.log(`  ✅ Deleted ${allIds.length} games`);
}

async function deleteGroup(config: AccessConfig): Promise<void> {
  console.log("\n🏐 DELETING GROUP\n" + "=".repeat(50));

  await db.collection("groups").doc(config.groupId).delete();
  console.log(`  ✅ Deleted group ${config.groupId}`);
}

async function deleteFriendships(): Promise<void> {
  console.log("\n👥 DELETING FRIENDSHIPS\n" + "=".repeat(50));

  const snap = await db.collection("friendships").where("accessData", "==", true).get();
  if (snap.empty) { console.log("  ℹ️  No access friendships found"); return; }

  await deleteDocsInBatches(snap.docs.map((d) => d.ref));
  console.log(`  ✅ Deleted ${snap.docs.length} friendships`);
}

async function deleteUserRatingHistory(config: AccessConfig): Promise<void> {
  console.log("\n📊 DELETING RATING HISTORY\n" + "=".repeat(50));

  let total = 0;
  for (const user of config.users) {
    total += await deleteSubcollection(`users/${user.uid}`, "ratingHistory");
  }
  console.log(`  ✅ Deleted ${total} rating history entries`);
}

async function deleteUserDocuments(config: AccessConfig): Promise<void> {
  console.log("\n👤 DELETING USER DOCUMENTS\n" + "=".repeat(50));

  await deleteDocsInBatches(config.users.map((u) => db.collection("users").doc(u.uid)));
  console.log(`  ✅ Deleted ${config.users.length} user documents`);
}

async function deleteAuthAccounts(config: AccessConfig): Promise<void> {
  console.log("\n🔐 DELETING AUTH ACCOUNTS\n" + "=".repeat(50));

  const uids   = config.users.map((u) => u.uid);
  const result = await auth.deleteUsers(uids);

  for (const err of result.errors) {
    console.warn(`  ⚠️  Failed to delete UID ${uids[err.index]}: ${err.error.message}`);
  }
  console.log(`  ✅ Deleted ${uids.length - result.errors.length}/${uids.length} Auth accounts`);
}

function deleteConfigFile(): void {
  console.log("\n🗑️  DELETING CONFIG FILE\n" + "=".repeat(50));

  const p = path.join(__dirname, "accessConfig.json");
  if (fs.existsSync(p)) {
    fs.unlinkSync(p);
    console.log(`  ✅ Deleted accessConfig.json`);
  } else {
    console.log(`  ℹ️  accessConfig.json not found — skipping`);
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main(): Promise<void> {
  const t0 = Date.now();

  console.log("\n" + "=".repeat(70));
  console.log("🧹 GATHERLI — ACCESS ENVIRONMENT CLEANUP  (gatherli-PROD)");
  console.log("=".repeat(70));

  const configPath = path.join(__dirname, "accessConfig.json");
  if (!fs.existsSync(configPath)) {
    console.error("\n❌ accessConfig.json not found.");
    console.error("   Run setupAccessEnvironment.ts first, or restore the file.");
    process.exit(1);
  }

  const config: AccessConfig = JSON.parse(fs.readFileSync(configPath, "utf-8"));

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
  console.log(`\n⚠️  Deleting all access data from PRODUCTION...\n`);

  await deleteTrainingSessions(config);
  await deleteGames(config);
  await deleteGroup(config);
  await deleteFriendships();
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
   • Access friendships deleted
   • ${config.users.length} user documents + rating histories deleted
   • ${config.users.length} Auth accounts deleted
   • accessConfig.json removed

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

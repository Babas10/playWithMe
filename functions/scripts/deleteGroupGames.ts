import * as admin from "firebase-admin";
import { getTestGroupId } from "./testConfigLoader";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
    admin.initializeApp({
        projectId: "playwithme-dev"
    });
}

// Load group ID from test config (or specify manually if needed)
let TARGET_GROUP_ID: string;
try {
  TARGET_GROUP_ID = getTestGroupId();
  console.log("✅ Loaded group ID from testConfig.json");
} catch (error) {
  // Fallback: you can specify a group ID manually if testConfig.json doesn't exist
  TARGET_GROUP_ID = "SPECIFY_YOUR_GROUP_ID_HERE";
  console.log("⚠️  Using manually specified group ID (testConfig.json not found)");
}

async function deleteGroupGames() {
  const db = admin.firestore();
  console.log(`Connected to Project ID: ${admin.app().options.projectId || "Unknown"}`);
  console.log(`Deleting all games for Group ID: ${TARGET_GROUP_ID}...`);

  try {
    const gamesQuery = await db.collection("games")
      .where("groupId", "==", TARGET_GROUP_ID)
      .get();

    if (gamesQuery.empty) {
      console.log("No games found for this group.");
      return;
    }

    const batch = db.batch();
    let count = 0;

    gamesQuery.docs.forEach((doc) => {
      batch.delete(doc.ref);
      count++;
    });

    await batch.commit();
    console.log(`Successfully deleted ${count} games.`);

  } catch (error) {
    console.error("Error deleting games:", error);
  } finally {
    process.exit();
  }
}

if (require.main === module) {
  deleteGroupGames();
}

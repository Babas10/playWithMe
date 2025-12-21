import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
    admin.initializeApp({
        projectId: "playwithme-dev"
    });
}

const TARGET_GROUP_ID = "9RScLpdoeiG5UHKMD8tB"; // "test2" group ID

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

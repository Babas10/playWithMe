import * as admin from "firebase-admin";
import { getTestUser, getTestGroupId } from "./testConfigLoader";

admin.initializeApp({
  projectId: "playwithme-dev",
});

async function createSingleTestGame() {
  const db = admin.firestore();

  const user1 = getTestUser(0);
  const user2 = getTestUser(1);
  const user3 = getTestUser(2);
  const user4 = getTestUser(3);
  const groupId = getTestGroupId();

  console.log("\n🎮 Creating a single test game to trigger Cloud Functions...\n");

  // Create game as scheduled first
  const gameRef = db.collection("games").doc();
  await gameRef.set({
    title: "Test Game for ELO",
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

  console.log(`✅ Created scheduled game: ${gameRef.id}`);

  // Wait a bit, then update to completed
  await new Promise(resolve => setTimeout(resolve, 2000));

  await gameRef.update({
    status: "completed",
    teams: {
      teamAPlayerIds: [user1.uid, user2.uid],
      teamBPlayerIds: [user3.uid, user4.uid],
    },
    result: {
      overallWinner: "teamA",
      games: [
        {
          gameNumber: 1,
          sets: [{ teamAPoints: 21, teamBPoints: 15, setNumber: 1 }],
          winner: "teamA",
        },
      ],
    },
    completedAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
  });

  console.log(`✅ Updated game to completed: ${gameRef.id}`);
  console.log(`\n⏳ Waiting 10 seconds for Cloud Function to process...`);

  await new Promise(resolve => setTimeout(resolve, 10000));

  // Check if ELO was calculated
  const updatedGame = await gameRef.get();
  const gameData = updatedGame.data();

  console.log(`\n📊 Game Status:`);
  console.log(`   eloCalculated: ${gameData?.eloCalculated}`);
  console.log(`   eloUpdates: ${gameData?.eloUpdates ? 'YES' : 'NO'}`);

  if (gameData?.eloCalculated) {
    console.log(`\n✅ SUCCESS! ELO was calculated by Cloud Function`);
  } else {
    console.log(`\n❌ ELO not calculated yet. Check Cloud Function logs:`);
    console.log(`   firebase functions:log --project playwithme-dev`);
  }

  console.log('\n');
}

createSingleTestGame()
  .then(() => process.exit(0))
  .catch(err => {
    console.error('Error:', err);
    process.exit(1);
  });

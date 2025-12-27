const admin = require('firebase-admin');

admin.initializeApp({
  projectId: 'playwithme-dev'
});

const db = admin.firestore();

async function checkLatest() {
  const gamesSnapshot = await db.collection('games')
    .where('status', '==', 'completed')
    .get();
  
  if (gamesSnapshot.empty) {
    console.log('No completed games found');
    return;
  }
  
  const games = gamesSnapshot.docs
    .map(doc => ({ id: doc.id, ...doc.data() }))
    .sort((a, b) => {
      const aTime = a.completedAt?.toDate?.()?.getTime() || 0;
      const bTime = b.completedAt?.toDate?.()?.getTime() || 0;
      return bTime - aTime;
    });
  
  const latest = games[0];
  
  console.log('\n=== LATEST COMPLETED GAME ===');
  console.log('ID:', latest.id);
  console.log('Title:', latest.title);
  console.log('Completed:', latest.completedAt?.toDate());
  console.log('\n--- ELO Status ---');
  console.log('eloCalculated:', latest.eloCalculated);
  console.log('eloUpdates present:', latest.eloUpdates !== undefined);
  
  if (latest.eloUpdates !== undefined) {
    const isEmpty = JSON.stringify(latest.eloUpdates) === '{}';
    console.log('eloUpdates empty?:', isEmpty);
    if (!isEmpty) {
      console.log('eloUpdates:', JSON.stringify(latest.eloUpdates, null, 2));
    }
  }
  
  console.log('\n--- Teams ---');
  console.log('Team A:', latest.teams?.teamAPlayerIds);
  console.log('Team B:', latest.teams?.teamBPlayerIds);
  
  console.log('\n--- Result ---');
  console.log('Winner:', latest.result?.overallWinner);
  
  console.log('\n--- DIAGNOSIS ---');
  if (latest.eloCalculated && latest.eloUpdates && Object.keys(latest.eloUpdates).length > 0) {
    console.log('✅ SUCCESS! ELO calculated');
  } else if (latest.eloUpdates && JSON.stringify(latest.eloUpdates) === '{}') {
    console.log('❌ FAILED: Empty eloUpdates object');
  } else if (!latest.eloUpdates) {
    console.log('⏳ No eloUpdates field - waiting for Cloud Function');
  } else {
    console.log('❓ Unknown state');
  }
  console.log('========================================\n');
}

checkLatest().then(() => process.exit(0)).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});

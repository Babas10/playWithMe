import * as admin from 'firebase-admin';

// Initialize Firebase Admin for REAL project
admin.initializeApp({
  projectId: 'playwithme-dev'
});

const db = admin.firestore();
const auth = admin.auth();

const USERS = [
  { email: 'test1@mysta.com', displayName: 'Test Player 1', password: 'password123' },
  { email: 'test2@mysta.com', displayName: 'Test Player 2', password: 'password123' },
  { email: 'test3@mysta.com', displayName: 'Test Player 3', password: 'password123' },
  { email: 'test4@mysta.com', displayName: 'Test Player 4', password: 'password123' },
];

async function getOrCreateUser(userData: any) {
  try {
    const userRecord = await auth.getUserByEmail(userData.email);
    console.log(`User ${userData.email} found: ${userRecord.uid}`);
    return userRecord;
  } catch (error: any) {
    if (error.code === 'auth/user-not-found') {
      const userRecord = await auth.createUser(userData);
      console.log(`Created user ${userData.email}: ${userRecord.uid}`);
      return userRecord;
    }
    throw error;
  }
}

async function main() {
  try {
    console.log('Connecting to REAL project: playwithme-dev...');

    // 1. Get Users
    console.log('Verifying users...');
    const users = await Promise.all(USERS.map(getOrCreateUser));
    const userIds = users.map(u => u.uid);

    // 2. Find Group "Test2"
    console.log('Finding group "Test2"...');
    const groupQuery = await db.collection('groups').where('name', '==', 'Test2').get();
    
    if (groupQuery.empty) {
        console.error('❌ Group "Test2" not found!');
        return;
    }
    
    const groupDoc = groupQuery.docs[0];
    const groupId = groupDoc.id;
    const groupData = groupDoc.data();
    console.log(`Found group: ${groupData.name} (${groupId})`);

    // Ensure users are members
    const currentMembers = groupData.memberIds || [];
    const newMembers = userIds.filter(uid => !currentMembers.includes(uid));
    
    if (newMembers.length > 0) {
        console.log(`Adding ${newMembers.length} missing users to group...`);
        await db.collection('groups').doc(groupId).update({
            memberIds: admin.firestore.FieldValue.arrayUnion(...newMembers)
        });
        
        // Also update users' groupIds
        const batch = db.batch();
        newMembers.forEach(uid => {
            batch.update(db.collection('users').doc(uid), {
                groupIds: admin.firestore.FieldValue.arrayUnion(groupId)
            });
        });
        await batch.commit();
        console.log('Updated memberships.');
    }

    // 3. Create Game (Scheduled for 1 minute from now)
    const now = new Date();
    const scheduledTime = new Date(now.getTime() + 60000); // 1 minute later

    console.log(`Creating game scheduled for ${scheduledTime.toISOString()}...`);
    
    const gameRef = await db.collection('games').add({
      title: 'ELO Test Game (Real Dev) - Test2',
      groupId: groupId,
      createdBy: userIds[0],
      status: 'scheduled',
      scheduledAt: admin.firestore.Timestamp.fromDate(scheduledTime),
      maxPlayers: 4,
      minPlayers: 4,
      playerIds: userIds,
      teams: {
        teamAPlayerIds: [userIds[0], userIds[1]],
        teamBPlayerIds: [userIds[2], userIds[3]],
      },
      location: {
        name: 'Dev Test Court',
        address: 'Cloud City',
        latitude: 34.0,
        longitude: -118.0,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      visibility: 'group',
      gameType: 'beach_volleyball',
      skillLevel: 'mixed',
      allowWaitlist: true,
      eloCalculated: false,
    });

    console.log(`\n✅ REAL Game Created Successfully in playwithme-dev!`);
    console.log(`Game ID: ${gameRef.id}`);
    console.log(`Group ID: ${groupId}`);
    console.log(`Time: ${scheduledTime.toLocaleTimeString()}`);

  } catch (error) {
    console.error('Error:', error);
  }
}

main();

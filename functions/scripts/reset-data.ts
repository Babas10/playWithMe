/**
 * Story 11.4: Data Reset Script
 *
 * This script deletes all existing data from Firestore to enable a clean implementation
 * of friendship validation for group invitations without backward compatibility code.
 *
 * WARNING: This is a destructive operation. Only run on dev environment!
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/reset-data.ts
 */

import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK
admin.initializeApp({
  projectId: 'playwithme-dev', // ⚠️ Only dev environment
});

async function resetFirestoreData() {
  const db = admin.firestore();

  console.log('🗑️  Starting data reset for playwithme-dev...\n');

  try {
    // 1. Delete all friendships
    console.log('📋 Deleting friendships collection...');
    const friendshipsSnapshot = await db.collection('friendships').get();
    const friendshipDeletes = friendshipsSnapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(friendshipDeletes);
    console.log(`✅ Deleted ${friendshipsSnapshot.size} friendship documents\n`);

    // 2. Delete all groups
    console.log('📋 Deleting groups collection...');
    const groupsSnapshot = await db.collection('groups').get();
    const groupDeletes = groupsSnapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(groupDeletes);
    console.log(`✅ Deleted ${groupsSnapshot.size} group documents\n`);

    // 3. Delete all user documents (and their subcollections)
    console.log('📋 Deleting users collection...');
    const usersSnapshot = await db.collection('users').get();
    const userIds: string[] = [];

    for (const userDoc of usersSnapshot.docs) {
      userIds.push(userDoc.id); // Save user IDs for Auth deletion

      // Delete invitations subcollection
      const invitationsSnapshot = await userDoc.ref.collection('invitations').get();
      const invitationDeletes = invitationsSnapshot.docs.map(doc => doc.ref.delete());
      await Promise.all(invitationDeletes);

      // Delete user document
      await userDoc.ref.delete();
    }

    console.log(`✅ Deleted ${usersSnapshot.size} user documents (including subcollections)\n`);

    // 4. Delete ALL Firebase Authentication users (not just those with Firestore docs)
    console.log('📋 Deleting ALL Firebase Authentication users...');
    let authDeleteCount = 0;
    let authErrorCount = 0;

    // Get ALL auth users (not just those with Firestore documents)
    const listUsersResult = await admin.auth().listUsers();
    const allAuthUsers = listUsersResult.users;

    console.log(`   Found ${allAuthUsers.length} total auth users to delete...`);

    for (const userRecord of allAuthUsers) {
      try {
        await admin.auth().deleteUser(userRecord.uid);
        authDeleteCount++;
      } catch (error: any) {
        console.warn(`⚠️  Failed to delete auth user ${userRecord.uid} (${userRecord.email}): ${error.message}`);
        authErrorCount++;
      }
    }

    console.log(`✅ Deleted ${authDeleteCount} Firebase Auth users`);
    if (authErrorCount > 0) {
      console.log(`⚠️  ${authErrorCount} auth users could not be deleted\n`);
    } else {
      console.log('');
    }

    console.log('✅ Data reset complete!\n');
    console.log('📝 Next steps:');
    console.log('   1. Register 3-5 NEW test users via the app (old accounts are deleted)');
    console.log('   2. Have them send friend requests to each other');
    console.log('   3. Accept friend requests');
    console.log('   4. Create test groups');
    console.log('   5. Verify friendship validation works\n');

  } catch (error) {
    console.error('❌ Error during data reset:', error);
    throw error;
  }
}

// Confirm before running
const projectId = admin.app().options.projectId;
if (projectId !== 'playwithme-dev') {
  console.error('❌ ERROR: This script can only run on playwithme-dev!');
  console.error(`   Current project: ${projectId}`);
  process.exit(1);
}

console.log(`⚠️  WARNING: You are about to delete ALL data from ${projectId}`);
console.log('   This operation cannot be undone!\n');

// Run the reset
resetFirestoreData()
  .then(() => {
    console.log('🎉 Script completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Script failed:', error);
    process.exit(1);
  });

/**
 * Backfill Friend Cache Script
 *
 * This script populates the friendIds cache for all existing accepted friendships.
 *
 * Context:
 * - The onFriendshipCacheUpdate trigger was not deployed until PR #195
 * - Any friendships accepted before that trigger was deployed have status="accepted"
 *   but the users' friendIds arrays were never updated
 * - This script finds all accepted friendships and updates both users' caches
 *
 * Usage:
 *   cd functions
 *   npx ts-node scripts/backfill-friend-cache.ts
 */

import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK
admin.initializeApp({
  projectId: 'playwithme-dev', // ⚠️ Only dev environment
});

async function backfillFriendCache() {
  const db = admin.firestore();

  console.log('🔄 Starting friend cache backfill for playwithme-dev...\n');

  try {
    // 1. Get all accepted friendships
    console.log('📋 Fetching all accepted friendships...');
    const friendshipsSnapshot = await db
      .collection('friendships')
      .where('status', '==', 'accepted')
      .get();

    console.log(`✅ Found ${friendshipsSnapshot.size} accepted friendships\n`);

    if (friendshipsSnapshot.size === 0) {
      console.log('ℹ️  No accepted friendships to backfill');
      return;
    }

    // 2. Build a map of userId -> friendIds
    const userFriends = new Map<string, Set<string>>();

    for (const doc of friendshipsSnapshot.docs) {
      const data = doc.data();
      const initiatorId = data.initiatorId as string;
      const recipientId = data.recipientId as string;

      // Add each user to the other's friend list
      if (!userFriends.has(initiatorId)) {
        userFriends.set(initiatorId, new Set());
      }
      if (!userFriends.has(recipientId)) {
        userFriends.set(recipientId, new Set());
      }

      userFriends.get(initiatorId)!.add(recipientId);
      userFriends.get(recipientId)!.add(initiatorId);
    }

    console.log(`👥 Found ${userFriends.size} users with friends\n`);

    // 3. Check current state of each user's cache
    console.log('🔍 Checking current cache state...\n');
    let usersNeedingUpdate = 0;

    for (const [userId, friendSet] of userFriends.entries()) {
      const userDoc = await db.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        console.log(`⚠️  User ${userId} document not found, skipping`);
        continue;
      }

      const userData = userDoc.data()!;
      const currentFriendIds = userData.friendIds || [];
      const expectedFriendIds = Array.from(friendSet);

      // Check if cache needs updating
      const needsUpdate =
        currentFriendIds.length !== expectedFriendIds.length ||
        !expectedFriendIds.every((id: string) => currentFriendIds.includes(id));

      if (needsUpdate) {
        usersNeedingUpdate++;
        console.log(`📝 User ${userId}:`);
        console.log(`   Current cache: ${currentFriendIds.length} friends`);
        console.log(`   Expected: ${expectedFriendIds.length} friends`);
      }
    }

    console.log(`\n✅ ${usersNeedingUpdate} users need cache updates\n`);

    if (usersNeedingUpdate === 0) {
      console.log('🎉 All caches are already up to date!');
      return;
    }

    // 4. Update user caches in batches
    console.log('🔄 Updating user caches...\n');

    const batch = db.batch();
    let updateCount = 0;

    for (const [userId, friendSet] of userFriends.entries()) {
      const userRef = db.collection('users').doc(userId);
      const friendIds = Array.from(friendSet);

      batch.update(userRef, {
        friendIds: friendIds,
        friendCount: friendIds.length,
        friendsLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      updateCount++;
      console.log(`✅ Queued update for user ${userId} (${friendIds.length} friends)`);
    }

    // Commit all updates
    await batch.commit();
    console.log(`\n🎉 Successfully updated ${updateCount} user caches!\n`);

    // 5. Verify updates
    console.log('🔍 Verifying updates...\n');
    let verifiedCount = 0;

    for (const [userId, friendSet] of userFriends.entries()) {
      const userDoc = await db.collection('users').doc(userId).get();
      const userData = userDoc.data()!;
      const cachedFriendIds = userData.friendIds || [];

      if (cachedFriendIds.length === friendSet.size) {
        verifiedCount++;
      } else {
        console.warn(`⚠️  Verification failed for ${userId}: expected ${friendSet.size}, got ${cachedFriendIds.length}`);
      }
    }

    console.log(`✅ Verified ${verifiedCount}/${userFriends.size} user caches\n`);
    console.log('🎉 Friend cache backfill complete!\n');

  } catch (error) {
    console.error('❌ Error during backfill:', error);
    throw error;
  }
}

// Safety check
const projectId = admin.app().options.projectId;
if (projectId !== 'playwithme-dev') {
  console.error('❌ ERROR: This script can only run on playwithme-dev!');
  console.error(`   Current project: ${projectId}`);
  process.exit(1);
}

console.log(`⚠️  Running backfill on ${projectId}\n`);

// Run the backfill
backfillFriendCache()
  .then(() => {
    console.log('✅ Script completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Script failed:', error);
    process.exit(1);
  });

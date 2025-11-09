/**
 * Backfill Script: Create Firestore user documents for existing Firebase Auth users
 *
 * This script ensures all users in Firebase Auth have corresponding Firestore documents.
 * Run this once after deploying the createUserDocument Cloud Function to fix existing users.
 *
 * Usage:
 *   npx ts-node scripts/backfill-user-documents.ts <project-id>
 *
 * Example:
 *   npx ts-node scripts/backfill-user-documents.ts playwithme-dev
 */

import * as admin from "firebase-admin";

async function backfillUserDocuments(projectId: string) {
  // Initialize Firebase Admin with explicit project
  process.env.GOOGLE_CLOUD_PROJECT = projectId;
  admin.initializeApp({
    projectId: projectId,
  });

  const auth = admin.auth();
  const db = admin.firestore();
  const usersRef = db.collection("users");

  console.log(`\n🔄 Starting user document backfill for project: ${projectId}\n`);

  let processedCount = 0;
  let createdCount = 0;
  let skippedCount = 0;
  let errorCount = 0;

  try {
    // List all users (pagination handled automatically)
    const listUsersResult = await auth.listUsers(1000);

    for (const userRecord of listUsersResult.users) {
      processedCount++;

      try {
        // Check if Firestore document exists
        const userDocRef = usersRef.doc(userRecord.uid);
        const userDoc = await userDocRef.get();

        if (userDoc.exists) {
          console.log(`  ⏭️  User ${userRecord.uid} (${userRecord.email}) - Document exists, skipping`);
          skippedCount++;
        } else {
          // Create missing document
          await userDocRef.set({
            email: userRecord.email || "",
            displayName: userRecord.displayName || null,
            photoUrl: userRecord.photoURL || null,
            isEmailVerified: userRecord.emailVerified || false,
            isAnonymous: userRecord.providerData.length === 0,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          console.log(`  ✅ User ${userRecord.uid} (${userRecord.email}) - Document created`);
          createdCount++;
        }
      } catch (error) {
        console.error(`  ❌ User ${userRecord.uid} (${userRecord.email}) - Error:`, error);
        errorCount++;
      }
    }

    console.log(`\n📊 Backfill Summary:`);
    console.log(`   Total users processed: ${processedCount}`);
    console.log(`   Documents created: ${createdCount}`);
    console.log(`   Documents skipped (already exist): ${skippedCount}`);
    console.log(`   Errors: ${errorCount}`);
    console.log(`\n✅ Backfill complete!\n`);

  } catch (error) {
    console.error("\n❌ Backfill failed:", error);
    process.exit(1);
  }

  process.exit(0);
}

// Get project ID from command line
const projectId = process.argv[2];

if (!projectId) {
  console.error("\n❌ Error: Project ID required");
  console.log("\nUsage:");
  console.log("  npx ts-node scripts/backfill-user-documents.ts <project-id>");
  console.log("\nExample:");
  console.log("  npx ts-node scripts/backfill-user-documents.ts playwithme-dev\n");
  process.exit(1);
}

backfillUserDocuments(projectId);

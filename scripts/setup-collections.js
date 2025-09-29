// Script to create initial Firestore collections with placeholder documents
// Run with: node scripts/setup-collections.js

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// Note: Make sure to set GOOGLE_APPLICATION_CREDENTIALS environment variable
// pointing to your service account key file

admin.initializeApp({
  projectId: process.env.PROJECT_ID || 'playwithme-dev'
});

const db = admin.firestore();

async function createInitialCollections() {
  console.log('🔥 Creating initial Firestore collections...');

  try {
    // Create users collection with a placeholder document
    await db.collection('users').doc('_placeholder').set({
      _description: 'User profiles and settings collection',
      _created: admin.firestore.FieldValue.serverTimestamp(),
      _placeholder: true
    });
    console.log('✅ Created users collection');

    // Create groups collection with a placeholder document
    await db.collection('groups').doc('_placeholder').set({
      _description: 'Volleyball groups collection',
      _created: admin.firestore.FieldValue.serverTimestamp(),
      _placeholder: true
    });
    console.log('✅ Created groups collection');

    // Create games collection with a placeholder document
    await db.collection('games').doc('_placeholder').set({
      _description: 'Volleyball games collection',
      _created: admin.firestore.FieldValue.serverTimestamp(),
      _placeholder: true
    });
    console.log('✅ Created games collection');

    console.log('🎉 All collections created successfully!');

  } catch (error) {
    console.error('❌ Error creating collections:', error);
  }

  process.exit(0);
}

createInitialCollections();
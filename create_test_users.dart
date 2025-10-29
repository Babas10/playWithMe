// Script to manually create Firestore user documents for testing
// Run with: dart run create_test_users.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/firebase_options_provider.dart';

Future<void> main() async {
  print('🔧 Creating test user documents in Firestore...\n');

  try {
    // Initialize Firebase
    EnvironmentConfig.setEnvironment(Environment.dev);
    await Firebase.initializeApp(
      options: FirebaseOptionsProvider.getFirebaseOptions(),
    );

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    print('✅ Firebase initialized');
    print('📱 Project: ${Firebase.app().options.projectId}\n');

    // Get all Firebase Auth users
    print('Fetching Firebase Auth users...');

    // Get current authenticated user or list users
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      print('❌ No user is currently signed in.');
      print('Please run the app and sign in first, then run this script.\n');
      return;
    }

    print('Current user: ${currentUser.email}\n');

    // Create/Update Firestore document for current user
    print('Creating Firestore document for ${currentUser.email}...');

    final userData = {
      'email': currentUser.email!.toLowerCase(),
      'displayName': currentUser.displayName,
      'photoUrl': currentUser.photoURL,
      'isEmailVerified': currentUser.emailVerified,
      'isAnonymous': currentUser.isAnonymous,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .set(userData, SetOptions(merge: true));

    print('✅ User document created/updated!');
    print('   UID: ${currentUser.uid}');
    print('   Email: ${currentUser.email}');
    print('   Display Name: ${currentUser.displayName ?? "N/A"}\n');

    // Verify it was created
    print('Verifying document...');
    final doc = await firestore.collection('users').doc(currentUser.uid).get();

    if (doc.exists) {
      print('✅ Document verified in Firestore');
      print('   Data: ${doc.data()}\n');
    } else {
      print('❌ Document NOT found in Firestore\n');
    }

    // List all users in Firestore
    print('Listing all users in Firestore /users collection:');
    final usersSnapshot = await firestore.collection('users').get();

    if (usersSnapshot.docs.isEmpty) {
      print('❌ No users found in Firestore!\n');
    } else {
      print('Found ${usersSnapshot.docs.length} user(s):\n');
      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        print('  • ${data['email']} (${doc.id})');
        print('    Display Name: ${data['displayName'] ?? "N/A"}');
        print('    Created: ${data['createdAt']}\n');
      }
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}

// Helper class for setting up and managing Firebase Emulator in integration tests
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Helper class for Firebase Emulator integration testing
///
/// Provides utilities for:
/// - Initializing Firebase with emulator configuration
/// - Creating and authenticating test users
/// - Clearing Firestore data between tests
/// - Managing test state
class FirebaseEmulatorHelper {
  static bool _initialized = false;
  static const String _testProjectId = 'playwithme-dev';

  // Emulator host configuration
  static const String emulatorHost = 'localhost';
  static const int authPort = 9099;
  static const int firestorePort = 8080;
  static const int storagePort = 9199;

  /// Initialize Firebase with emulator configuration
  ///
  /// This should be called once in setUpAll() before running any tests.
  /// It configures Firebase to use the local emulator instead of production.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: _testProjectId,
        ),
      );

      // Connect to emulators
      FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, firestorePort);
      await FirebaseAuth.instance.useAuthEmulator(emulatorHost, authPort);

      _initialized = true;
      print('✅ Firebase Emulator initialized successfully');
    } catch (e) {
      print('⚠️  Firebase already initialized: $e');
      _initialized = true;
    }
  }

  /// Clear all Firestore data between tests
  ///
  /// This ensures test isolation by removing all documents from
  /// the specified collections. Call this in setUp() or tearDown().
  static Future<void> clearFirestore() async {
    final firestore = FirebaseFirestore.instance;

    // Collections to clear
    final collections = ['users', 'groups', 'games'];

    for (final collection in collections) {
      try {
        final snapshot = await firestore.collection(collection).get();
        for (final doc in snapshot.docs) {
          // Delete subcollections first
          await _deleteSubcollections(doc.reference);
          // Then delete the document
          await doc.reference.delete();
        }
      } catch (e) {
        print('⚠️  Error clearing collection $collection: $e');
      }
    }
  }

  /// Delete all subcollections of a document reference
  static Future<void> _deleteSubcollections(DocumentReference docRef) async {
    // Known subcollections
    final subcollections = ['invitations', 'preferences'];

    for (final subcollection in subcollections) {
      try {
        final snapshot = await docRef.collection(subcollection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        // Subcollection might not exist, that's okay
      }
    }
  }

  /// Create a test user in Firebase Auth Emulator
  ///
  /// Creates a new user account and optionally sets display name.
  /// Returns the created User object for further testing.
  static Future<User> createTestUser({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      return FirebaseAuth.instance.currentUser!;
    } catch (e) {
      throw Exception('Failed to create test user: $e');
    }
  }

  /// Create a user document in Firestore
  ///
  /// After creating a user in Auth, this creates the corresponding
  /// user document in the /users collection.
  static Future<void> createUserDocument({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'email': email,
      'displayName': displayName ?? 'Test User',
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'groupIds': [],
      'gameIds': [],
    });
  }

  /// Authenticate as a test user
  ///
  /// Signs in an existing test user with email and password.
  static Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign out current user
  ///
  /// Call this in tearDown() to ensure test isolation.
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('⚠️  Error signing out: $e');
    }
  }

  /// Get current authenticated user
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  /// Check if a user is currently authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Create a complete test user (Auth + Firestore document)
  ///
  /// Convenience method that creates both the auth user and Firestore document.
  static Future<User> createCompleteTestUser({
    required String email,
    required String password,
    String? displayName,
    String? photoUrl,
  }) async {
    final user = await createTestUser(
      email: email,
      password: password,
      displayName: displayName,
    );

    await createUserDocument(
      userId: user.uid,
      email: email,
      displayName: displayName ?? user.displayName,
      photoUrl: photoUrl,
    );

    return user;
  }

  /// Create a test group in Firestore
  ///
  /// Helper method to create a group for testing.
  static Future<String> createTestGroup({
    required String createdBy,
    required String name,
    String? description,
    List<String>? memberIds,
    List<String>? adminIds,
  }) async {
    final groupRef = FirebaseFirestore.instance.collection('groups').doc();

    await groupRef.set({
      'name': name,
      'description': description ?? 'Test group',
      'createdBy': createdBy,
      'memberIds': memberIds ?? [createdBy],
      'adminIds': adminIds ?? [createdBy],
      'gameIds': [],
      'privacy': 'private',
      'requiresApproval': false,
      'maxMembers': 20,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return groupRef.id;
  }

  /// Wait for Firestore to process writes
  ///
  /// Sometimes needed to ensure server-side operations complete.
  static Future<void> waitForFirestore() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Get Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;
}

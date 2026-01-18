// Integration test for registration flow
// Tests real Firebase Auth and Firestore interactions using Firebase Emulator

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/firebase_emulator_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FirebaseEmulatorHelper.initialize();
  });

  setUp(() async {
    await FirebaseEmulatorHelper.clearFirestore();
    await FirebaseEmulatorHelper.signOut();
  });

  tearDown(() async {
    await FirebaseEmulatorHelper.signOut();
  });

  group('Registration Flow - Successful Registration', () {
    test(
      'New user can register with valid email and password',
      () async {
        final testEmail = 'newuser@test.com';
        final testPassword = 'validPassword123';

        // 1. Verify user doesn't exist
        expect(FirebaseAuth.instance.currentUser, isNull);

        // 2. Register new user
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        // 3. Verify registration succeeded
        expect(userCredential.user, isNotNull);
        expect(userCredential.user?.email, equals(testEmail));
        expect(userCredential.user?.uid, isNotEmpty);

        // 4. Verify user is automatically signed in
        expect(FirebaseAuth.instance.currentUser, isNotNull);
        expect(FirebaseAuth.instance.currentUser?.email, equals(testEmail));
      },
    );

    test(
      'Registration creates user with correct email',
      () async {
        final testEmail = 'correctemail@test.com';
        final testPassword = 'password123';

        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        expect(userCredential.user?.email, equals(testEmail));
        expect(userCredential.user?.email, isNot(equals('wrong@test.com')));
      },
    );

    test(
      'Registration returns valid user credential with UID',
      () async {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'uidtest@test.com',
          password: 'password123',
        );

        expect(userCredential.user?.uid, isNotNull);
        expect(userCredential.user?.uid, isNotEmpty);
        expect(userCredential.user?.uid.length, greaterThan(10));
      },
    );
  });

  group('Registration Flow - Firestore Profile Creation', () {
    test(
      'User document is created in Firestore after registration',
      () async {
        final testEmail = 'firestoreuser@test.com';
        final testPassword = 'password123';
        final testDisplayName = 'Firestore User';

        // 1. Register user
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        final userId = userCredential.user!.uid;

        // 2. Create Firestore user document (simulating app behavior)
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': testEmail,
          'displayName': testDisplayName,
          'createdAt': FieldValue.serverTimestamp(),
          'groupIds': [],
          'gameIds': [],
          'isEmailVerified': false,
          'isAnonymous': false,
        });

        await FirebaseEmulatorHelper.waitForFirestore();

        // 3. Verify Firestore document exists
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        expect(userDoc.exists, isTrue);
        expect(userDoc.data()?['email'], equals(testEmail));
        expect(userDoc.data()?['displayName'], equals(testDisplayName));
      },
    );

    test(
      'User profile contains all required fields after creation',
      () async {
        final testEmail = 'completeprofile@test.com';
        final testPassword = 'password123';
        final testDisplayName = 'Complete Profile User';

        // 1. Register and create complete user profile
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        );

        await FirebaseEmulatorHelper.waitForFirestore();

        // 2. Verify all required fields
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.exists, isTrue);

        final data = userDoc.data()!;
        expect(data['email'], equals(testEmail));
        expect(data['displayName'], equals(testDisplayName));
        expect(data['createdAt'], isNotNull);
        expect(data['groupIds'], isA<List>());
        expect(data['gameIds'], isA<List>());
      },
    );

    test(
      'User profile groupIds and gameIds are initialized as empty arrays',
      () async {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'emptyarrays@test.com',
          password: 'password123',
          displayName: 'Empty Arrays User',
        );

        await FirebaseEmulatorHelper.waitForFirestore();

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['groupIds'], isEmpty);
        expect(userDoc.data()?['gameIds'], isEmpty);
      },
    );

    test(
      'Auth UID matches Firestore document ID',
      () async {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'matchingids@test.com',
          password: 'password123',
          displayName: 'Matching IDs User',
        );

        final authUid = user.uid;
        final firestoreUid = user.uid;

        // Verify document exists at the auth UID path
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(authUid)
            .get();

        expect(userDoc.exists, isTrue);
        expect(userDoc.id, equals(authUid));
        expect(userDoc.id, equals(firestoreUid));
      },
    );
  });

  group('Registration Flow - Email Validation', () {
    test(
      'Registration fails with invalid email format',
      () async {
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'notanemail',
            password: 'password123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );

    test(
      'Registration fails with empty email',
      () async {
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: '',
            password: 'password123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );

    test(
      'Registration fails with email missing domain',
      () async {
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'user@',
            password: 'password123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );

    test(
      'Registration fails with email missing username',
      () async {
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: '@test.com',
            password: 'password123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );

    test(
      'Registration succeeds with valid email containing plus sign',
      () async {
        // Plus addressing is valid email format
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'user+tag@test.com',
          password: 'password123',
        );

        expect(userCredential.user, isNotNull);
        expect(userCredential.user?.email, equals('user+tag@test.com'));
      },
    );
  });

  group('Registration Flow - Password Validation', () {
    test(
      'Registration fails with password less than 6 characters',
      () async {
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'shortpass@test.com',
            password: '12345',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );

    test(
      'Registration fails with empty password',
      () async {
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'emptypass@test.com',
            password: '',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );

    test(
      'Registration succeeds with exactly 6 character password',
      () async {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'sixchar@test.com',
          password: '123456',
        );

        expect(userCredential.user, isNotNull);
      },
    );

    test(
      'Registration succeeds with long password',
      () async {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'longpass@test.com',
          password: 'thisIsAVeryLongPasswordThatShouldStillWork123!@#',
        );

        expect(userCredential.user, isNotNull);
      },
    );

    test(
      'Registration succeeds with special characters in password',
      () async {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'specialpass@test.com',
          password: 'P@ssw0rd!#\$%',
        );

        expect(userCredential.user, isNotNull);
      },
    );
  });

  group('Registration Flow - Duplicate Email', () {
    test(
      'Registration fails when email already exists',
      () async {
        final testEmail = 'duplicate@test.com';
        final testPassword = 'password123';

        // 1. Register first user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        await FirebaseEmulatorHelper.signOut();

        // 2. Try to register with same email
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'differentPassword',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );

    test(
      'Duplicate email error contains appropriate error code',
      () async {
        final testEmail = 'duplicatecode@test.com';

        // Register first user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: 'password123',
        );

        await FirebaseEmulatorHelper.signOut();

        // Try to register with same email
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'password456',
          );
          fail('Expected FirebaseAuthException');
        } on FirebaseAuthException catch (e) {
          // Firebase uses 'email-already-in-use' code
          expect(e.code, equals('email-already-in-use'));
        }
      },
    );

    test(
      'Email comparison is case-insensitive',
      () async {
        // Register with lowercase email
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'casetest@test.com',
          password: 'password123',
        );

        await FirebaseEmulatorHelper.signOut();

        // Try to register with uppercase email
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'CASETEST@TEST.COM',
            password: 'password456',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );
  });

  group('Registration Flow - Display Name', () {
    test(
      'Display name can be set during registration',
      () async {
        final testEmail = 'displayname@test.com';
        final testPassword = 'password123';
        final testDisplayName = 'Test Display Name';

        // 1. Register user
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        // 2. Set display name
        await userCredential.user?.updateDisplayName(testDisplayName);
        await userCredential.user?.reload();

        // 3. Verify display name
        final currentUser = FirebaseAuth.instance.currentUser;
        expect(currentUser?.displayName, equals(testDisplayName));
      },
    );

    test(
      'Display name persists after re-authentication',
      () async {
        final testEmail = 'persistname@test.com';
        final testPassword = 'password123';
        final testDisplayName = 'Persistent Name';

        // 1. Register and set display name
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        await userCredential.user?.updateDisplayName(testDisplayName);

        // 2. Sign out and sign back in
        await FirebaseAuth.instance.signOut();
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        // 3. Verify display name persists
        final currentUser = FirebaseAuth.instance.currentUser;
        expect(currentUser?.displayName, equals(testDisplayName));
      },
    );
  });

  group('Registration Flow - Email Verification', () {
    test(
      'New user is created with unverified email',
      () async {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'unverified@test.com',
          password: 'password123',
        );

        // New users should have unverified email
        expect(userCredential.user?.emailVerified, isFalse);
      },
    );

    test(
      'Verification email can be sent after registration',
      () async {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'sendverify@test.com',
          password: 'password123',
        );

        // Should complete without error (emulator accepts the call)
        await expectLater(
          userCredential.user?.sendEmailVerification(),
          completes,
        );
      },
    );
  });

  group('Registration Flow - Error Messages', () {
    test(
      'Invalid email error has descriptive message',
      () async {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'invalid',
            password: 'password123',
          );
          fail('Expected FirebaseAuthException');
        } on FirebaseAuthException catch (e) {
          expect(e.message, isNotNull);
          expect(e.message, isNotEmpty);
        }
      },
    );

    test(
      'Weak password error has descriptive message',
      () async {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'weakpassmsg@test.com',
            password: '123',
          );
          fail('Expected FirebaseAuthException');
        } on FirebaseAuthException catch (e) {
          expect(e.message, isNotNull);
          expect(e.message, isNotEmpty);
          expect(e.code, equals('weak-password'));
        }
      },
    );
  });

  group('Registration Flow - Complete User Creation', () {
    test(
      'Complete registration flow creates auth user and Firestore document',
      () async {
        final testEmail = 'complete@test.com';
        final testPassword = 'password123';
        final testDisplayName = 'Complete User';

        // 1. Use helper to create complete user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        );

        await FirebaseEmulatorHelper.waitForFirestore();

        // 2. Verify auth user exists
        expect(FirebaseAuth.instance.currentUser, isNotNull);
        expect(FirebaseAuth.instance.currentUser?.uid, equals(user.uid));
        expect(FirebaseAuth.instance.currentUser?.email, equals(testEmail));

        // 3. Verify Firestore document exists
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.exists, isTrue);
        expect(userDoc.data()?['email'], equals(testEmail));
        expect(userDoc.data()?['displayName'], equals(testDisplayName));
      },
    );

    test(
      'Multiple users can register with unique emails',
      () async {
        // Register user 1
        final user1 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user1@test.com',
          password: 'password123',
          displayName: 'User One',
        );

        // Register user 2
        final user2 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user2@test.com',
          password: 'password123',
          displayName: 'User Two',
        );

        // Register user 3
        final user3 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user3@test.com',
          password: 'password123',
          displayName: 'User Three',
        );

        await FirebaseEmulatorHelper.waitForFirestore();

        // Verify all users exist in Firestore
        final user1Doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user1.uid)
            .get();
        final user2Doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user2.uid)
            .get();
        final user3Doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user3.uid)
            .get();

        expect(user1Doc.exists, isTrue);
        expect(user2Doc.exists, isTrue);
        expect(user3Doc.exists, isTrue);

        // Verify UIDs are unique
        expect(user1.uid, isNot(equals(user2.uid)));
        expect(user2.uid, isNot(equals(user3.uid)));
        expect(user1.uid, isNot(equals(user3.uid)));
      },
    );

    test(
      'User can query their own document after registration',
      () async {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'queryown@test.com',
          password: 'password123',
          displayName: 'Query User',
        );

        await FirebaseEmulatorHelper.waitForFirestore();

        // User should be able to read their own document
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.exists, isTrue);
        expect(userDoc.data()?['email'], equals('queryown@test.com'));
      },
    );
  });
}

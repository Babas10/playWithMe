// Integration test for authentication flow
// Tests real Firebase Auth interactions using Firebase Emulator

import 'dart:async';

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

  group('Authentication Flow - Login', () {
    test(
      'User can successfully login with valid credentials',
      () async {
        // 1. Create a test user
        final testEmail = 'valid@test.com';
        final testPassword = 'password123';

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Valid User',
        );

        // 2. Sign out to start fresh
        await FirebaseEmulatorHelper.signOut();
        expect(FirebaseEmulatorHelper.isAuthenticated, isFalse);

        // 3. Sign in with valid credentials
        final user = await FirebaseEmulatorHelper.signIn(
          email: testEmail,
          password: testPassword,
        );

        // 4. Verify authentication succeeded
        expect(user, isNotNull);
        expect(user.email, equals(testEmail));
        expect(FirebaseEmulatorHelper.isAuthenticated, isTrue);
        expect(FirebaseEmulatorHelper.currentUser?.uid, equals(user.uid));
      },
    );

    test(
      'Login fails with invalid email',
      () async {
        // 1. Create a test user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'real@test.com',
          password: 'password123',
          displayName: 'Real User',
        );

        await FirebaseEmulatorHelper.signOut();

        // 2. Try to sign in with wrong email
        expect(
          () async => await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'wrong@test.com',
            password: 'password123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );

        // 3. Verify user is still not authenticated
        expect(FirebaseEmulatorHelper.isAuthenticated, isFalse);
      },
    );

    test(
      'Login fails with invalid password',
      () async {
        // 1. Create a test user
        final testEmail = 'user@test.com';

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: 'correctpassword',
          displayName: 'Test User',
        );

        await FirebaseEmulatorHelper.signOut();

        // 2. Try to sign in with wrong password
        expect(
          () async => await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: testEmail,
            password: 'wrongpassword',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );

        // 3. Verify user is still not authenticated
        expect(FirebaseEmulatorHelper.isAuthenticated, isFalse);
      },
    );

    test(
      'Login fails with non-existent user',
      () async {
        // Try to sign in with non-existent user
        expect(
          () async => await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'nonexistent@test.com',
            password: 'anypassword',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );

        // Verify user is not authenticated
        expect(FirebaseEmulatorHelper.isAuthenticated, isFalse);
      },
    );
  });

  group('Authentication Flow - Logout', () {
    test(
      'User can successfully logout',
      () async {
        // 1. Create and sign in a test user
        final testEmail = 'logout@test.com';
        final testPassword = 'password123';

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Logout User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: testEmail,
          password: testPassword,
        );

        // 2. Verify user is authenticated
        expect(FirebaseEmulatorHelper.isAuthenticated, isTrue);

        // 3. Sign out
        await FirebaseEmulatorHelper.signOut();

        // 4. Verify user is no longer authenticated
        expect(FirebaseEmulatorHelper.isAuthenticated, isFalse);
        expect(FirebaseEmulatorHelper.currentUser, isNull);
      },
    );

    test(
      'Logout clears current user reference',
      () async {
        // 1. Create and sign in a test user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'clearuser@test.com',
          password: 'password123',
          displayName: 'Clear User',
        );

        await FirebaseEmulatorHelper.signOut();
        final user = await FirebaseEmulatorHelper.signIn(
          email: 'clearuser@test.com',
          password: 'password123',
        );

        final userId = user.uid;

        // 2. Verify current user exists
        expect(FirebaseAuth.instance.currentUser, isNotNull);
        expect(FirebaseAuth.instance.currentUser?.uid, equals(userId));

        // 3. Sign out
        await FirebaseAuth.instance.signOut();

        // 4. Verify current user is null
        expect(FirebaseAuth.instance.currentUser, isNull);
      },
    );
  });

  group('Authentication Flow - Auth State Changes', () {
    test(
      'Auth state stream emits null when user logs out',
      () async {
        // 1. Create and sign in a test user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'stream@test.com',
          password: 'password123',
          displayName: 'Stream User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'stream@test.com',
          password: 'password123',
        );

        // 2. Set up a completer to capture the auth state change
        final completer = Completer<User?>();
        late StreamSubscription<User?> subscription;

        // Skip the first emission (current state) and capture the next one
        var firstEmission = true;
        subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
          if (firstEmission) {
            firstEmission = false;
            return;
          }
          if (!completer.isCompleted) {
            completer.complete(user);
          }
        });

        // 3. Sign out
        await FirebaseAuth.instance.signOut();

        // 4. Wait for the auth state change
        final result = await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception('Auth state change timeout'),
        );

        // 5. Verify the emitted user is null
        expect(result, isNull);

        await subscription.cancel();
      },
    );

    test(
      'Auth state stream emits user when user logs in',
      () async {
        // 1. Create a test user but don't sign in
        final testEmail = 'statechange@test.com';
        final testPassword = 'password123';

        // First create the user (this signs them in)
        final createdUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'State Change User',
        );

        final expectedUid = createdUser.uid;

        // Sign out to start from unauthenticated state
        await FirebaseEmulatorHelper.signOut();
        expect(FirebaseAuth.instance.currentUser, isNull);

        // 2. Set up a completer to capture the auth state change
        final completer = Completer<User?>();
        late StreamSubscription<User?> subscription;

        // Skip the first emission (current null state) and capture the next one
        var firstEmission = true;
        subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
          if (firstEmission) {
            firstEmission = false;
            return;
          }
          if (!completer.isCompleted) {
            completer.complete(user);
          }
        });

        // 3. Sign in
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        // 4. Wait for the auth state change
        final result = await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception('Auth state change timeout'),
        );

        // 5. Verify the emitted user matches
        expect(result, isNotNull);
        expect(result?.uid, equals(expectedUid));
        expect(result?.email, equals(testEmail));

        await subscription.cancel();
      },
    );

    test(
      'Auth state changes propagate correctly through multiple login/logout cycles',
      () async {
        // 1. Create a test user
        final testEmail = 'cycles@test.com';
        final testPassword = 'password123';

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Cycles User',
        );

        await FirebaseEmulatorHelper.signOut();

        // 2. Collect auth state changes
        final authStates = <bool>[];
        final subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
          authStates.add(user != null);
        });

        // Wait for initial state
        await Future.delayed(const Duration(milliseconds: 100));

        // 3. Perform login/logout cycles
        // Cycle 1: Login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Cycle 1: Logout
        await FirebaseAuth.instance.signOut();
        await Future.delayed(const Duration(milliseconds: 100));

        // Cycle 2: Login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // 4. Verify we captured the state changes
        // Initial: false, Login: true, Logout: false, Login: true
        expect(authStates.length, greaterThanOrEqualTo(4));
        expect(authStates.first, isFalse); // Initial unauthenticated
        expect(authStates.last, isTrue); // Final authenticated

        await subscription.cancel();
      },
    );
  });

  group('Authentication Flow - Registration', () {
    test(
      'New user can register and is automatically signed in',
      () async {
        final testEmail = 'newuser@test.com';
        final testPassword = 'newpassword123';

        // 1. Verify user doesn't exist (not authenticated)
        expect(FirebaseAuth.instance.currentUser, isNull);

        // 2. Register new user
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        // 3. Verify user is created and automatically signed in
        expect(userCredential.user, isNotNull);
        expect(userCredential.user?.email, equals(testEmail));
        expect(FirebaseAuth.instance.currentUser, isNotNull);
        expect(FirebaseAuth.instance.currentUser?.uid, equals(userCredential.user?.uid));
      },
    );

    test(
      'Registration fails with already existing email',
      () async {
        final testEmail = 'existing@test.com';
        final testPassword = 'password123';

        // 1. Create first user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        await FirebaseEmulatorHelper.signOut();

        // 2. Try to register with same email
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'differentpassword',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );

    test(
      'Registration fails with invalid email format',
      () async {
        // Try to register with invalid email
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
      'Registration fails with weak password',
      () async {
        // Try to register with weak password (less than 6 characters)
        expect(
          () async => await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: 'weakpass@test.com',
            password: '123',
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );
  });

  group('Authentication Flow - Password Reset', () {
    test(
      'Password reset email can be sent for existing user',
      () async {
        // 1. Create a test user
        final testEmail = 'reset@test.com';

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: 'oldpassword123',
          displayName: 'Reset User',
        );

        await FirebaseEmulatorHelper.signOut();

        // 2. Request password reset (should not throw)
        await expectLater(
          FirebaseAuth.instance.sendPasswordResetEmail(email: testEmail),
          completes,
        );
      },
    );

    test(
      'Password reset request for non-existent email does not throw',
      () async {
        // Firebase Auth emulator may not throw for non-existent emails
        // (security best practice to not reveal if email exists)
        // This test verifies the call completes without error
        await expectLater(
          FirebaseAuth.instance.sendPasswordResetEmail(email: 'nonexistent@test.com'),
          completes,
        );
      },
    );
  });

  group('Authentication Flow - User Profile', () {
    test(
      'User can update display name after login',
      () async {
        // 1. Create and sign in a test user
        final testEmail = 'profile@test.com';
        final testPassword = 'password123';

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Original Name',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: testEmail,
          password: testPassword,
        );

        // 2. Update display name
        await FirebaseAuth.instance.currentUser?.updateDisplayName('New Name');
        await FirebaseAuth.instance.currentUser?.reload();

        // 3. Verify display name was updated
        final updatedUser = FirebaseAuth.instance.currentUser;
        expect(updatedUser?.displayName, equals('New Name'));
      },
    );

    test(
      'User can update photo URL after login',
      () async {
        // 1. Create and sign in a test user
        final testEmail = 'photo@test.com';
        final testPassword = 'password123';

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Photo User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: testEmail,
          password: testPassword,
        );

        // 2. Update photo URL
        const newPhotoUrl = 'https://example.com/photo.jpg';
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(newPhotoUrl);
        await FirebaseAuth.instance.currentUser?.reload();

        // 3. Verify photo URL was updated
        final updatedUser = FirebaseAuth.instance.currentUser;
        expect(updatedUser?.photoURL, equals(newPhotoUrl));
      },
    );
  });

  group('Authentication Flow - Session Persistence', () {
    test(
      'User remains authenticated after Firebase instance access',
      () async {
        // 1. Create and sign in a test user
        final testEmail = 'persist@test.com';
        final testPassword = 'password123';

        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Persist User',
        );

        final userId = user.uid;

        // 2. Access Firebase Auth instance multiple times
        final auth1 = FirebaseAuth.instance;
        final auth2 = FirebaseAuth.instance;
        final auth3 = FirebaseAuth.instance;

        // 3. Verify all instances return the same authenticated user
        expect(auth1.currentUser?.uid, equals(userId));
        expect(auth2.currentUser?.uid, equals(userId));
        expect(auth3.currentUser?.uid, equals(userId));
      },
    );

    test(
      'Auth state is consistent across FirebaseAuth instance',
      () async {
        // 1. Create and sign in a test user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'consistent@test.com',
          password: 'password123',
          displayName: 'Consistent User',
        );

        // 2. Check auth state from different entry points
        final currentUser = FirebaseAuth.instance.currentUser;
        final helperUser = FirebaseEmulatorHelper.currentUser;
        final isAuthenticated = FirebaseEmulatorHelper.isAuthenticated;

        // 3. Verify consistency
        expect(currentUser, isNotNull);
        expect(helperUser, isNotNull);
        expect(currentUser?.uid, equals(helperUser?.uid));
        expect(isAuthenticated, isTrue);
      },
    );
  });

  group('Authentication Flow - Error Handling', () {
    test(
      'FirebaseAuthException contains error code for invalid credentials',
      () async {
        // 1. Create a test user
        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'errorcode@test.com',
          password: 'password123',
          displayName: 'Error User',
        );

        await FirebaseEmulatorHelper.signOut();

        // 2. Try to sign in with wrong password
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'errorcode@test.com',
            password: 'wrongpassword',
          );
          fail('Expected FirebaseAuthException');
        } on FirebaseAuthException catch (e) {
          // 3. Verify error contains useful information
          expect(e.code, isNotEmpty);
          expect(e.message, isNotNull);
        }
      },
    );

    test(
      'FirebaseAuthException contains error code for user not found',
      () async {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'notfound@test.com',
            password: 'anypassword',
          );
          fail('Expected FirebaseAuthException');
        } on FirebaseAuthException catch (e) {
          expect(e.code, isNotEmpty);
          expect(e.message, isNotNull);
        }
      },
    );
  });
}

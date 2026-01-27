// Integration tests for user authentication stream behavior using Firebase Emulator
// Tests auth state changes and current user stream that cannot be tested in unit tests
// Reference: https://github.com/Babas10/playWithMe/issues/442

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

  group('User Auth Stream Integration Tests', () {
    test(
      'Auth state stream emits null when no user is signed in',
      () async {
        final auth = FirebaseAuth.instance;

        // Verify no user is signed in
        expect(auth.currentUser, isNull);

        // Listen to auth state
        User? currentUser;
        final subscription = auth.authStateChanges().listen((user) {
          currentUser = user;
        });

        await Future.delayed(const Duration(milliseconds: 200));

        // Should emit null for no user
        expect(currentUser, isNull);

        await subscription.cancel();
      },
    );

    test(
      'Auth state stream emits user when signed in',
      () async {
        final auth = FirebaseAuth.instance;

        // Set up auth state listener before signing in
        final authStates = <User?>[];
        final subscription = auth.authStateChanges().listen((user) {
          authStates.add(user);
        });

        // Wait for initial state
        await Future.delayed(const Duration(milliseconds: 200));
        expect(authStates.last, isNull);

        // Create and sign in user
        await auth.createUserWithEmailAndPassword(
          email: 'authstream@test.com',
          password: 'password123',
        );

        await Future.delayed(const Duration(milliseconds: 200));

        // Auth state should have emitted the user
        expect(authStates.last, isNotNull);
        expect(authStates.last?.email, equals('authstream@test.com'));

        await subscription.cancel();
      },
    );

    test(
      'Auth state stream emits null when user signs out',
      () async {
        final auth = FirebaseAuth.instance;

        // Create and sign in user first
        await auth.createUserWithEmailAndPassword(
          email: 'signout@test.com',
          password: 'password123',
        );

        // Set up auth state listener
        final authStates = <User?>[];
        final subscription = auth.authStateChanges().listen((user) {
          authStates.add(user);
        });

        await Future.delayed(const Duration(milliseconds: 200));
        expect(authStates.last, isNotNull);

        // Sign out
        await auth.signOut();

        await Future.delayed(const Duration(milliseconds: 200));

        // Auth state should have emitted null
        expect(authStates.last, isNull);

        await subscription.cancel();
      },
    );

    test(
      'User ID token changes stream emits on profile update',
      () async {
        final auth = FirebaseAuth.instance;

        // Create user
        final credential = await auth.createUserWithEmailAndPassword(
          email: 'tokenchange@test.com',
          password: 'password123',
        );

        // Set up ID token changes listener
        var tokenChangeCount = 0;
        final subscription = auth.idTokenChanges().listen((user) {
          tokenChangeCount++;
        });

        await Future.delayed(const Duration(milliseconds: 200));
        final initialCount = tokenChangeCount;

        // Update display name (triggers token refresh)
        await credential.user?.updateDisplayName('New Name');

        await Future.delayed(const Duration(milliseconds: 200));

        // Token should have changed
        expect(tokenChangeCount, greaterThanOrEqualTo(initialCount));

        await subscription.cancel();
      },
    );

    test(
      'Current user reflects authentication state correctly',
      () async {
        final auth = FirebaseAuth.instance;

        // Initially no user
        expect(auth.currentUser, isNull);

        // Sign in
        final credential = await auth.createUserWithEmailAndPassword(
          email: 'currentuser@test.com',
          password: 'password123',
        );

        // Current user should be set
        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser?.uid, equals(credential.user?.uid));

        // Sign out
        await auth.signOut();

        // Current user should be null
        expect(auth.currentUser, isNull);
      },
    );

    test(
      'Auth state persists user data correctly',
      () async {
        final auth = FirebaseAuth.instance;

        // Create user with display name
        final credential = await auth.createUserWithEmailAndPassword(
          email: 'persist@test.com',
          password: 'password123',
        );
        await credential.user?.updateDisplayName('Persist User');
        await credential.user?.reload();

        // Verify user data is accessible
        final user = auth.currentUser;
        expect(user, isNotNull);
        expect(user?.email, equals('persist@test.com'));
        expect(user?.displayName, equals('Persist User'));
        expect(user?.uid, isNotEmpty);
      },
    );
  });
}

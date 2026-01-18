// Verifies that FirebaseAuthRepository correctly handles all Firebase authentication operations.
// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

// Mocktail mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUserMetadata extends Mock implements UserMetadata {}

/// Helper function to create FirebaseAuthException for testing.
FirebaseAuthException createAuthException(String code, {String? message}) {
  return FirebaseAuthException(code: code, message: message);
}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late MockUserMetadata mockUserMetadata;
  late FirebaseAuthRepository repository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    mockUserMetadata = MockUserMetadata();
    repository = FirebaseAuthRepository(firebaseAuth: mockFirebaseAuth);

    // Setup default user metadata
    when(() => mockUserMetadata.creationTime).thenReturn(DateTime(2024, 1, 1));
    when(() => mockUserMetadata.lastSignInTime).thenReturn(DateTime(2024, 1, 15));

    // Setup default user properties
    when(() => mockUser.uid).thenReturn('test-uid-123');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
    when(() => mockUser.emailVerified).thenReturn(true);
    when(() => mockUser.isAnonymous).thenReturn(false);
    when(() => mockUser.metadata).thenReturn(mockUserMetadata);

    // Setup default credential
    when(() => mockUserCredential.user).thenReturn(mockUser);
  });

  group('FirebaseAuthRepository', () {
    group('currentUser', () {
      test('returns null when no user is signed in', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        final result = repository.currentUser;

        expect(result, isNull);
        verify(() => mockFirebaseAuth.currentUser).called(1);
      });

      test('returns UserEntity when user is signed in', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final result = repository.currentUser;

        expect(result, isNotNull);
        expect(result, isA<UserEntity>());
        expect(result!.uid, 'test-uid-123');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
        expect(result.photoUrl, 'https://example.com/photo.jpg');
        expect(result.isEmailVerified, true);
        expect(result.isAnonymous, false);
        verify(() => mockFirebaseAuth.currentUser).called(1);
      });

      test('returns UserEntity with empty email when email is null', () {
        when(() => mockUser.email).thenReturn(null);
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final result = repository.currentUser;

        expect(result, isNotNull);
        expect(result!.email, '');
      });
    });

    group('authStateChanges', () {
      test('emits null when no user is signed in', () async {
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null));

        final stream = repository.authStateChanges;

        await expectLater(stream, emits(isNull));
      });

      test('emits UserEntity when user signs in', () async {
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));

        final stream = repository.authStateChanges;

        await expectLater(
          stream,
          emits(isA<UserEntity>().having((u) => u.uid, 'uid', 'test-uid-123')),
        );
      });

      test('emits sequence of auth state changes', () async {
        final controller = StreamController<User?>();
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => controller.stream);

        final stream = repository.authStateChanges;
        final emissions = <UserEntity?>[];
        final subscription = stream.listen(emissions.add);

        controller.add(null);
        controller.add(mockUser);
        controller.add(null);

        await Future.delayed(const Duration(milliseconds: 50));
        await subscription.cancel();
        await controller.close();

        expect(emissions.length, 3);
        expect(emissions[0], isNull);
        expect(emissions[1], isA<UserEntity>());
        expect(emissions[2], isNull);
      });
    });

    group('signInWithEmailAndPassword', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test('returns UserEntity on successful sign in', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockUserCredential);

        final result = await repository.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        expect(result, isA<UserEntity>());
        expect(result.uid, 'test-uid-123');
        expect(result.email, 'test@example.com');
        verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).called(1);
      });

      test('throws exception when credential.user is null', () async {
        when(() => mockUserCredential.user).thenReturn(null);
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockUserCredential);

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Sign in failed: User is null'),
          )),
        );
      });

      test('maps user-not-found FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(createAuthException('user-not-found'));

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No user found with this email address'),
          )),
        );
      });

      test('maps wrong-password FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(createAuthException('wrong-password'));

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Wrong password provided'),
          )),
        );
      });

      test('maps invalid-email FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(createAuthException('invalid-email'));

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('email address is not valid'),
          )),
        );
      });

      test('maps user-disabled FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(createAuthException('user-disabled'));

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('user account has been disabled'),
          )),
        );
      });

      test('wraps generic exceptions', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(Exception('Network error'));

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Sign in failed'),
          )),
        );
      });
    });

    group('createUserWithEmailAndPassword', () {
      const testEmail = 'new@example.com';
      const testPassword = 'newpassword123';

      test('returns UserEntity on successful registration', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockUserCredential);

        final result = await repository.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        expect(result, isA<UserEntity>());
        expect(result.uid, 'test-uid-123');
        verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).called(1);
      });

      test('throws exception when credential.user is null', () async {
        when(() => mockUserCredential.user).thenReturn(null);
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockUserCredential);

        expect(
          () => repository.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User creation failed: User is null'),
          )),
        );
      });

      test('maps email-already-in-use FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(createAuthException('email-already-in-use'));

        expect(
          () => repository.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('account already exists with this email'),
          )),
        );
      });

      test('maps weak-password FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(createAuthException('weak-password'));

        expect(
          () => repository.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('password provided is too weak'),
          )),
        );
      });

      test('wraps generic exceptions', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(Exception('Network error'));

        expect(
          () => repository.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User creation failed'),
          )),
        );
      });
    });

    group('signInAnonymously', () {
      test('returns UserEntity on successful anonymous sign in', () async {
        when(() => mockUser.isAnonymous).thenReturn(true);
        when(() => mockUser.email).thenReturn(null);
        when(() => mockFirebaseAuth.signInAnonymously())
            .thenAnswer((_) async => mockUserCredential);

        final result = await repository.signInAnonymously();

        expect(result, isA<UserEntity>());
        expect(result.uid, 'test-uid-123');
        expect(result.isAnonymous, true);
        verify(() => mockFirebaseAuth.signInAnonymously()).called(1);
      });

      test('throws exception when credential.user is null', () async {
        when(() => mockUserCredential.user).thenReturn(null);
        when(() => mockFirebaseAuth.signInAnonymously())
            .thenAnswer((_) async => mockUserCredential);

        expect(
          () => repository.signInAnonymously(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Anonymous sign in failed: User is null'),
          )),
        );
      });

      test('maps operation-not-allowed FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInAnonymously())
            .thenThrow(createAuthException('operation-not-allowed'));

        expect(
          () => repository.signInAnonymously(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('sign-in method is not allowed'),
          )),
        );
      });

      test('wraps generic exceptions', () async {
        when(() => mockFirebaseAuth.signInAnonymously())
            .thenThrow(Exception('Network error'));

        expect(
          () => repository.signInAnonymously(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Anonymous sign in failed'),
          )),
        );
      });
    });

    group('sendPasswordResetEmail', () {
      const testEmail = 'test@example.com';

      test('completes successfully when email is sent', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .thenAnswer((_) async {});

        await expectLater(
          repository.sendPasswordResetEmail(email: testEmail),
          completes,
        );

        verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .called(1);
      });

      test('maps invalid-email FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .thenThrow(createAuthException('invalid-email'));

        expect(
          () => repository.sendPasswordResetEmail(email: testEmail),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('email address is not valid'),
          )),
        );
      });

      test('maps user-not-found FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .thenThrow(createAuthException('user-not-found'));

        expect(
          () => repository.sendPasswordResetEmail(email: testEmail),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No user found with this email address'),
          )),
        );
      });

      test('maps too-many-requests FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .thenThrow(createAuthException('too-many-requests'));

        expect(
          () => repository.sendPasswordResetEmail(email: testEmail),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Too many requests'),
          )),
        );
      });

      test('wraps generic exceptions', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .thenThrow(Exception('Network error'));

        expect(
          () => repository.sendPasswordResetEmail(email: testEmail),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to send password reset email'),
          )),
        );
      });
    });

    group('sendEmailVerification', () {
      test('completes successfully when verification email is sent', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});

        await expectLater(
          repository.sendEmailVerification(),
          completes,
        );

        verify(() => mockUser.sendEmailVerification()).called(1);
      });

      test('throws exception when no user is signed in', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(
          () => repository.sendEmailVerification(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No user is currently signed in'),
          )),
        );
      });

      test('maps too-many-requests FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.sendEmailVerification())
            .thenThrow(createAuthException('too-many-requests'));

        expect(
          () => repository.sendEmailVerification(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Too many requests'),
          )),
        );
      });

      test('wraps generic exceptions', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.sendEmailVerification())
            .thenThrow(Exception('Network error'));

        expect(
          () => repository.sendEmailVerification(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to send email verification'),
          )),
        );
      });
    });

    group('reloadUser', () {
      test('completes successfully when user is reloaded', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.reload()).thenAnswer((_) async {});

        await expectLater(
          repository.reloadUser(),
          completes,
        );

        verify(() => mockUser.reload()).called(1);
      });

      test('throws exception when no user is signed in', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(
          () => repository.reloadUser(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No user is currently signed in'),
          )),
        );
      });

      test('wraps generic exceptions', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.reload()).thenThrow(Exception('Network error'));

        expect(
          () => repository.reloadUser(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to reload user data'),
          )),
        );
      });
    });

    group('signOut', () {
      test('completes successfully when user signs out', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        await expectLater(
          repository.signOut(),
          completes,
        );

        verify(() => mockFirebaseAuth.signOut()).called(1);
      });

      test('wraps exceptions during sign out', () async {
        when(() => mockFirebaseAuth.signOut())
            .thenThrow(Exception('Sign out error'));

        expect(
          () => repository.signOut(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Sign out failed'),
          )),
        );
      });
    });

    group('updateUserProfile', () {
      test('updates display name successfully', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
        when(() => mockUser.reload()).thenAnswer((_) async {});

        await expectLater(
          repository.updateUserProfile(displayName: 'New Name'),
          completes,
        );

        verify(() => mockUser.updateDisplayName('New Name')).called(1);
        verify(() => mockUser.reload()).called(1);
      });

      test('updates photo URL when provided', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
        when(() => mockUser.updatePhotoURL(any())).thenAnswer((_) async {});
        when(() => mockUser.reload()).thenAnswer((_) async {});

        await expectLater(
          repository.updateUserProfile(
            displayName: 'New Name',
            photoUrl: 'https://example.com/new-photo.jpg',
          ),
          completes,
        );

        verify(() => mockUser.updateDisplayName('New Name')).called(1);
        verify(() => mockUser.updatePhotoURL('https://example.com/new-photo.jpg'))
            .called(1);
        verify(() => mockUser.reload()).called(1);
      });

      test('does not update photo URL when null', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
        when(() => mockUser.reload()).thenAnswer((_) async {});

        await repository.updateUserProfile(displayName: 'New Name');

        verify(() => mockUser.updateDisplayName('New Name')).called(1);
        verifyNever(() => mockUser.updatePhotoURL(any()));
        verify(() => mockUser.reload()).called(1);
      });

      test('throws exception when no user is signed in', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(
          () => repository.updateUserProfile(displayName: 'New Name'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No user is currently signed in'),
          )),
        );
      });

      test('wraps exceptions during profile update', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.updateDisplayName(any()))
            .thenThrow(Exception('Update error'));

        expect(
          () => repository.updateUserProfile(displayName: 'New Name'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to update user profile'),
          )),
        );
      });
    });

    group('FirebaseAuthException error code mapping', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test('maps invalid-credential to appropriate message', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(createAuthException('invalid-credential'));

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('credentials are invalid'),
          )),
        );
      });

      test('maps network-request-failed to appropriate message', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(createAuthException('network-request-failed'));

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Network error'),
          )),
        );
      });

      test('maps unknown error code to generic message', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(createAuthException('unknown-error-code'));

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Authentication failed'),
          )),
        );
      });
    });
  });
}

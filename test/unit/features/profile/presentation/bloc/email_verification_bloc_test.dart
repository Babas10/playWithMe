// Validates EmailVerificationBloc emits correct states during email verification flow

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_state.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late EmailVerificationBloc bloc;

  final testUser = UserEntity(
    uid: 'test-uid-123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: null,
    isEmailVerified: false,
    createdAt: DateTime(2024, 1, 1),
    lastSignInAt: DateTime(2024, 10, 1),
    isAnonymous: false,
  );

  final verifiedUser = testUser.copyWith(isEmailVerified: true);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => Stream<UserEntity?>.value(testUser));
  });

  tearDown(() {
    bloc.close();
  });

  group('EmailVerificationBloc', () {
    test('initial state is EmailVerificationInitial', () {
      bloc = EmailVerificationBloc(authRepository: mockAuthRepository);
      expect(bloc.state, equals(const EmailVerificationState.initial()));
    });

    group('CheckStatus Event', () {
      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, pending] when user is not verified',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.checkStatus()),
        expect: () => [
          const EmailVerificationState.loading(),
          EmailVerificationState.pending(
            email: testUser.email,
            emailSent: false,
            lastSentAt: null,
            resendCooldownSeconds: 0,
          ),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, verified] when user is already verified',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(verifiedUser);
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.checkStatus()),
        expect: () => [
          const EmailVerificationState.loading(),
          EmailVerificationState.verified(
            verifiedAt: verifiedUser.lastSignInAt,
          ),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, error] when user is null',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.checkStatus()),
        expect: () => [
          const EmailVerificationState.loading(),
          const EmailVerificationState.error(
            message: 'No user is currently signed in',
          ),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, error] when exception occurs',
        build: () {
          when(() => mockAuthRepository.currentUser)
              .thenThrow(Exception('Connection error'));
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.checkStatus()),
        expect: () => [
          const EmailVerificationState.loading(),
          const EmailVerificationState.error(
            message: 'Failed to check verification status: Exception: Connection error',
          ),
        ],
      );
    });

    group('SendVerificationEmail Event', () {
      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, emailSent, pending] when email sent successfully',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockAuthRepository.sendEmailVerification())
              .thenAnswer((_) async {});
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.sendVerificationEmail()),
        wait: const Duration(seconds: 3),
        expect: () => [
          const EmailVerificationState.loading(),
          isA<EmailVerificationEmailSent>()
              .having(
                (state) => state.email,
                'email',
                testUser.email,
              )
              .having(
                (state) => state.resendCooldownSeconds,
                'resendCooldownSeconds',
                60,
              ),
          isA<EmailVerificationPending>()
              .having(
                (state) => state.email,
                'email',
                testUser.email,
              )
              .having(
                (state) => state.emailSent,
                'emailSent',
                true,
              ),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.sendEmailVerification()).called(1);
        },
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, verified] when user is already verified',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(verifiedUser);
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.sendVerificationEmail()),
        expect: () => [
          const EmailVerificationState.loading(),
          EmailVerificationState.verified(
            verifiedAt: verifiedUser.lastSignInAt,
          ),
        ],
        verify: (_) {
          verifyNever(() => mockAuthRepository.sendEmailVerification());
        },
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [error] when user is null',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.sendVerificationEmail()),
        expect: () => [
          const EmailVerificationState.loading(),
          const EmailVerificationState.error(
            message: 'No user is currently signed in',
            email: null,
          ),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [error] when sendEmailVerification throws exception',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockAuthRepository.sendEmailVerification())
              .thenThrow(Exception('Failed to send email'));
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.sendVerificationEmail()),
        expect: () => [
          const EmailVerificationState.loading(),
          EmailVerificationState.error(
            message: 'Failed to send verification email: Exception: Failed to send email',
            email: testUser.email,
          ),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [error] with cooldown message when called too soon',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockAuthRepository.sendEmailVerification())
              .thenAnswer((_) async {});
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) async {
          // First send
          bloc.add(const EmailVerificationEvent.sendVerificationEmail());
          await Future.delayed(const Duration(seconds: 3));
          // Try to send again immediately
          bloc.add(const EmailVerificationEvent.sendVerificationEmail());
        },
        wait: const Duration(seconds: 1),
        skip: 2, // Skip first two states (loading and emailSent)
        expect: () => [
          isA<EmailVerificationPending>(), // State after first send
          isA<EmailVerificationError>() // Error from second send
              .having(
                (state) => state.message.contains('Please wait'),
                'contains cooldown message',
                true,
              ),
        ],
      );
    });

    group('RefreshStatus Event', () {
      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, verified] when user becomes verified',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(verifiedUser);
          when(() => mockAuthRepository.reloadUser())
              .thenAnswer((_) async {});
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.refreshStatus()),
        expect: () => [
          const EmailVerificationState.loading(),
          EmailVerificationState.verified(
            verifiedAt: verifiedUser.lastSignInAt,
          ),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.reloadUser()).called(1);
        },
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, pending] when user is still not verified',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockAuthRepository.reloadUser())
              .thenAnswer((_) async {});
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.refreshStatus()),
        expect: () => [
          const EmailVerificationState.loading(),
          EmailVerificationState.pending(
            email: testUser.email,
            emailSent: false,
            lastSentAt: null,
            resendCooldownSeconds: 0,
          ),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.reloadUser()).called(1);
        },
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, error] when user is null',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          when(() => mockAuthRepository.reloadUser())
              .thenAnswer((_) async {});
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.refreshStatus()),
        expect: () => [
          const EmailVerificationState.loading(),
          const EmailVerificationState.error(
            message: 'No user is currently signed in',
          ),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, error] when reloadUser throws exception',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockAuthRepository.reloadUser())
              .thenThrow(Exception('Network error'));
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.refreshStatus()),
        expect: () => [
          const EmailVerificationState.loading(),
          EmailVerificationState.error(
            message: 'Failed to refresh verification status: Exception: Network error',
            email: testUser.email,
          ),
        ],
      );
    });

    group('ResetError Event', () {
      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [pending] when user exists and is not verified',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.resetError()),
        expect: () => [
          EmailVerificationState.pending(
            email: testUser.email,
            emailSent: false,
            lastSentAt: null,
            resendCooldownSeconds: 0,
          ),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [verified] when user exists and is verified',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(verifiedUser);
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.resetError()),
        expect: () => [
          EmailVerificationState.verified(
            verifiedAt: verifiedUser.lastSignInAt,
          ),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [initial] when user is null',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) =>
            bloc.add(const EmailVerificationEvent.resetError()),
        expect: () => [
          const EmailVerificationState.initial(),
        ],
      );
    });

    group('Real-time Verification Updates', () {
      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'automatically emits verified when user becomes verified via auth state changes',
        build: () {
          when(() => mockAuthRepository.authStateChanges)
              .thenAnswer((_) => Stream<UserEntity?>.value(verifiedUser));
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        expect: () => [
          EmailVerificationState.verified(
            verifiedAt: verifiedUser.lastSignInAt,
          ),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'does not emit when user becomes unverified via auth state changes',
        build: () {
          when(() => mockAuthRepository.authStateChanges)
              .thenAnswer((_) => Stream<UserEntity?>.value(testUser));
          return EmailVerificationBloc(authRepository: mockAuthRepository);
        },
        expect: () => [],
      );
    });

    group('Cooldown Calculation', () {
      test('cooldown is 60 seconds after sending email', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        when(() => mockAuthRepository.sendEmailVerification())
            .thenAnswer((_) async {});

        bloc = EmailVerificationBloc(authRepository: mockAuthRepository);

        // Send email
        bloc.add(const EmailVerificationEvent.sendVerificationEmail());
        await Future.delayed(const Duration(milliseconds: 100));

        // Wait 3 seconds for transitions
        await Future.delayed(const Duration(seconds: 3));

        // Check status to verify cooldown
        bloc.add(const EmailVerificationEvent.checkStatus());
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify the state has a cooldown near 60 seconds (allow some variance)
        expect(
          bloc.state,
          isA<EmailVerificationPending>().having(
            (state) => state.resendCooldownSeconds,
            'resendCooldownSeconds',
            greaterThan(55),
          ),
        );
      });
    });
  });
}

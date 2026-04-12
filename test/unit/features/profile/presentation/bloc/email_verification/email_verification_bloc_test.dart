// Validates EmailVerificationBloc state transitions and Firestore sync on verification.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_state.dart';

import '../../../../auth/data/mock_auth_repository.dart';
import '../../../../../core/data/repositories/mock_user_repository.dart'
    hide TestUserData;

void main() {
  group('EmailVerificationBloc', () {
    late MockAuthRepository mockAuthRepository;
    late MockUserRepository mockUserRepository;
    late EmailVerificationBloc bloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockUserRepository = MockUserRepository();
      bloc = EmailVerificationBloc(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
    });

    tearDown(() {
      bloc.close();
      mockAuthRepository.dispose();
    });

    test('initial state is EmailVerificationState.initial', () {
      expect(bloc.state, const EmailVerificationState.initial());
    });

    // ── checkStatus ───────────────────────────────────────────────────────────

    group('checkStatus', () {
      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, pending] when user is not verified',
        setUp: () => mockAuthRepository.setCurrentUser(TestUserData.unverifiedUser),
        build: () => bloc,
        act: (b) => b.add(const EmailVerificationEvent.checkStatus()),
        expect: () => [
          const EmailVerificationState.loading(),
          isA<EmailVerificationPending>(),
        ],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits [loading, verified] when user is already verified',
        setUp: () => mockAuthRepository.setCurrentUser(TestUserData.testUser),
        build: () => bloc,
        act: (b) => b.add(const EmailVerificationEvent.checkStatus()),
        // skip: 1 — auth stream emits verified immediately on subscribe when
        // user is already verified; we only care about checkStatus states.
        skip: 1,
        expect: () => [
          const EmailVerificationState.loading(),
          isA<EmailVerificationVerified>(),
        ],
      );
    });

    // ── refreshStatus ─────────────────────────────────────────────────────────

    group('refreshStatus', () {
      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits verified and calls markEmailVerified when user has verified',
        setUp: () => mockAuthRepository.setCurrentUser(TestUserData.testUser),
        build: () => bloc,
        act: (b) => b.add(const EmailVerificationEvent.refreshStatus()),
        wait: const Duration(milliseconds: 50),
        // skip: 1 — auth stream emits verified before act (user already verified).
        skip: 1,
        expect: () => [
          const EmailVerificationState.loading(),
          isA<EmailVerificationVerified>(),
        ],
        verify: (_) {
          // ≥ 1: once from authStateChanged (stream), once from refreshStatus.
          expect(
            mockUserRepository.markEmailVerifiedCallCount,
            greaterThanOrEqualTo(1),
          );
        },
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'does not call markEmailVerified when user is still unverified',
        setUp: () => mockAuthRepository.setCurrentUser(TestUserData.unverifiedUser),
        build: () => bloc,
        act: (b) => b.add(const EmailVerificationEvent.refreshStatus()),
        wait: const Duration(milliseconds: 50),
        verify: (_) {
          expect(mockUserRepository.markEmailVerifiedCallCount, 0);
        },
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'still emits verified even when markEmailVerified throws',
        setUp: () {
          mockAuthRepository.setCurrentUser(TestUserData.testUser);
          mockUserRepository.markEmailVerifiedError = Exception('Firestore error');
        },
        build: () => bloc,
        act: (b) => b.add(const EmailVerificationEvent.refreshStatus()),
        wait: const Duration(milliseconds: 50),
        // skip: 1 — auth stream emits verified before act (user already verified).
        skip: 1,
        expect: () => [
          const EmailVerificationState.loading(),
          isA<EmailVerificationVerified>(),
        ],
      );
    });

    // ── authStateChanged ──────────────────────────────────────────────────────

    group('authStateChanged', () {
      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'emits verified and calls markEmailVerified when isVerified=true',
        build: () => bloc,
        act: (b) => b.add(
          const EmailVerificationEvent.authStateChanged(isVerified: true),
        ),
        wait: const Duration(milliseconds: 50),
        expect: () => [isA<EmailVerificationVerified>()],
        verify: (_) {
          expect(mockUserRepository.markEmailVerifiedCallCount, 1);
        },
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'does not emit or sync when isVerified=false',
        build: () => bloc,
        act: (b) => b.add(
          const EmailVerificationEvent.authStateChanged(isVerified: false),
        ),
        expect: () => <EmailVerificationState>[],
        verify: (_) {
          expect(mockUserRepository.markEmailVerifiedCallCount, 0);
        },
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'still emits verified even when markEmailVerified throws',
        setUp: () {
          mockUserRepository.markEmailVerifiedError = Exception('network error');
        },
        build: () => bloc,
        act: (b) => b.add(
          const EmailVerificationEvent.authStateChanged(isVerified: true),
        ),
        wait: const Duration(milliseconds: 50),
        expect: () => [isA<EmailVerificationVerified>()],
      );

      blocTest<EmailVerificationBloc, EmailVerificationState>(
        'syncs Firestore when auth stream emits a verified user',
        setUp: () => mockAuthRepository.setCurrentUser(null),
        build: () => EmailVerificationBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (b) async {
          b.add(const EmailVerificationEvent.checkStatus());
          await Future.delayed(const Duration(milliseconds: 30));
          mockAuthRepository.setCurrentUser(TestUserData.testUser);
        },
        wait: const Duration(milliseconds: 100),
        verify: (_) {
          expect(mockUserRepository.markEmailVerifiedCallCount, greaterThanOrEqualTo(1));
        },
      );
    });
  });
}

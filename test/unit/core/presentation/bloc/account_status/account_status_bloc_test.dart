// Validates AccountStatusBloc emits correct states for email verification grace period enforcement.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/entities/account_status.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_event.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  AccountStatusBloc buildBloc() {
    return AccountStatusBloc(authRepository: mockAuthRepository);
  }

  UserEntity createUser({
    bool isEmailVerified = false,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      isAnonymous: false,
    );
  }

  group('AccountStatusBloc', () {
    test('initial state is AccountStatusLoading', () {
      final bloc = buildBloc();
      expect(bloc.state, const AccountStatusLoading());
      bloc.close();
    });

    group('CheckAccountStatus', () {
      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits [AccountStatusActive] when user is null',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CheckAccountStatus()),
        expect: () => [const AccountStatusActive()],
      );

      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits [AccountStatusActive] when email is verified',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(
            createUser(isEmailVerified: true),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CheckAccountStatus()),
        expect: () => [const AccountStatusActive()],
      );

      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits [AccountStatusPending] when unverified and within grace period',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(
            createUser(
              isEmailVerified: false,
              createdAt: DateTime.now().subtract(const Duration(days: 3)),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CheckAccountStatus()),
        expect: () => [
          isA<AccountStatusPending>()
              .having((s) => s.daysRemaining, 'daysRemaining', 4)
              .having((s) => s.isDismissed, 'isDismissed', false),
        ],
      );

      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits [AccountStatusPending] with 7 days for new account',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(
            createUser(
              isEmailVerified: false,
              createdAt: DateTime.now(),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CheckAccountStatus()),
        expect: () => [
          isA<AccountStatusPending>()
              .having((s) => s.daysRemaining, 'daysRemaining', gracePeriodDays),
        ],
      );

      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits [AccountStatusPending] when createdAt is null',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(
            createUser(
              isEmailVerified: false,
              createdAt: null,
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CheckAccountStatus()),
        expect: () => [
          isA<AccountStatusPending>()
              .having((s) => s.daysRemaining, 'daysRemaining', gracePeriodDays),
        ],
      );

      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits [AccountStatusRestricted] when past grace period',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(
            createUser(
              isEmailVerified: false,
              createdAt: DateTime.now().subtract(const Duration(days: 15)),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CheckAccountStatus()),
        expect: () => [
          isA<AccountStatusRestricted>()
              .having((s) => s.daysUntilDeletion, 'daysUntilDeletion', 15),
        ],
      );

      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits [AccountStatusRestricted] with 0 days when past deletion period',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(
            createUser(
              isEmailVerified: false,
              createdAt: DateTime.now().subtract(const Duration(days: 31)),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CheckAccountStatus()),
        expect: () => [
          const AccountStatusRestricted(daysUntilDeletion: 0),
        ],
      );
    });

    group('AccountEmailVerified', () {
      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits [AccountStatusActive] when email is verified',
        build: buildBloc,
        act: (bloc) => bloc.add(const AccountEmailVerified()),
        expect: () => [const AccountStatusActive()],
      );
    });

    group('DismissAccountWarning', () {
      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits dismissed state when current state is pending',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(
            createUser(
              isEmailVerified: false,
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
          );
        },
        build: buildBloc,
        seed: () => const AccountStatusPending(
          daysRemaining: 5,
          isDismissed: false,
        ),
        act: (bloc) => bloc.add(const DismissAccountWarning()),
        expect: () => [
          const AccountStatusPending(
            daysRemaining: 5,
            isDismissed: true,
          ),
        ],
      );

      blocTest<AccountStatusBloc, AccountStatusState>(
        'does nothing when current state is active',
        build: buildBloc,
        seed: () => const AccountStatusActive(),
        act: (bloc) => bloc.add(const DismissAccountWarning()),
        expect: () => <AccountStatusState>[],
      );

      blocTest<AccountStatusBloc, AccountStatusState>(
        'does nothing when current state is loading',
        build: buildBloc,
        act: (bloc) => bloc.add(const DismissAccountWarning()),
        expect: () => <AccountStatusState>[],
      );
    });

    group('auth state listener', () {
      blocTest<AccountStatusBloc, AccountStatusState>(
        'emits [AccountStatusActive] when auth stream reports verified user',
        setUp: () {
          when(() => mockAuthRepository.authStateChanges).thenAnswer(
            (_) => Stream.value(
              createUser(isEmailVerified: true),
            ),
          );
        },
        build: buildBloc,
        expect: () => [const AccountStatusActive()],
      );
    });

    group('AccountStatusState equatable', () {
      test('AccountStatusLoading instances are equal', () {
        expect(
          const AccountStatusLoading(),
          equals(const AccountStatusLoading()),
        );
      });

      test('AccountStatusActive instances are equal', () {
        expect(
          const AccountStatusActive(),
          equals(const AccountStatusActive()),
        );
      });

      test('AccountStatusPending instances with same props are equal', () {
        expect(
          const AccountStatusPending(daysRemaining: 5, isDismissed: false),
          equals(
            const AccountStatusPending(daysRemaining: 5, isDismissed: false),
          ),
        );
      });

      test('AccountStatusPending instances with different props are not equal',
          () {
        expect(
          const AccountStatusPending(daysRemaining: 5, isDismissed: false),
          isNot(equals(
            const AccountStatusPending(daysRemaining: 3, isDismissed: false),
          )),
        );
      });

      test('AccountStatusRestricted instances with same props are equal', () {
        expect(
          const AccountStatusRestricted(daysUntilDeletion: 10),
          equals(const AccountStatusRestricted(daysUntilDeletion: 10)),
        );
      });
    });

    group('AccountStatusEvent equatable', () {
      test('CheckAccountStatus instances are equal', () {
        expect(
          const CheckAccountStatus(),
          equals(const CheckAccountStatus()),
        );
      });

      test('AccountEmailVerified instances are equal', () {
        expect(
          const AccountEmailVerified(),
          equals(const AccountEmailVerified()),
        );
      });

      test('DismissAccountWarning instances are equal', () {
        expect(
          const DismissAccountWarning(),
          equals(const DismissAccountWarning()),
        );
      });
    });

    group('AccountStatusStateX extension', () {
      test('loading state has null status', () {
        const state = AccountStatusLoading();
        expect(state.status, isNull);
      });

      test('active state has active status', () {
        const state = AccountStatusActive();
        expect(state.status, AccountStatus.active);
      });

      test('pending state has pendingVerification status', () {
        const state = AccountStatusPending(daysRemaining: 5);
        expect(state.status, AccountStatus.pendingVerification);
      });

      test('restricted state has restricted status', () {
        const state = AccountStatusRestricted(daysUntilDeletion: 10);
        expect(state.status, AccountStatus.restricted);
      });
    });

    group('AccountStatusPending copyWith', () {
      test('creates copy with updated isDismissed', () {
        const original = AccountStatusPending(
          daysRemaining: 5,
          isDismissed: false,
        );
        final copy = original.copyWith(isDismissed: true);
        expect(copy.daysRemaining, 5);
        expect(copy.isDismissed, true);
      });

      test('creates copy with updated daysRemaining', () {
        const original = AccountStatusPending(
          daysRemaining: 5,
          isDismissed: false,
        );
        final copy = original.copyWith(daysRemaining: 3);
        expect(copy.daysRemaining, 3);
        expect(copy.isDismissed, false);
      });

      test('creates identical copy when no params provided', () {
        const original = AccountStatusPending(
          daysRemaining: 5,
          isDismissed: true,
        );
        final copy = original.copyWith();
        expect(copy, equals(original));
      });
    });
  });
}

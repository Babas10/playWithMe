// Verifies that RegistrationBloc correctly handles registration events and emits appropriate states.
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_state.dart';
import '../../../data/mock_auth_repository.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  group('RegistrationBloc', () {
    late MockAuthRepository mockAuthRepository;
    late MockFirebaseAnalytics mockAnalytics;
    late RegistrationBloc registrationBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockAnalytics = MockFirebaseAnalytics();
      when(() => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          )).thenAnswer((_) async {});
      registrationBloc = RegistrationBloc(
        authRepository: mockAuthRepository,
        analytics: mockAnalytics,
      );
    });

    tearDown(() {
      registrationBloc.close();
      mockAuthRepository.dispose();
    });

    test('initial state is RegistrationInitial', () {
      expect(registrationBloc.state, const RegistrationInitial());
    });

    group('RegistrationSubmitted', () {
      const validFirstName = 'John';
      const validLastName = 'Doe';
      const validDisplayName = 'JohnD';
      const validEmail = 'test@example.com';
      const validPassword = 'Password1';
      const validGender = 'male';

      group('First Name Validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when first name is empty',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: '',
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('First name is required'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when first name is too short',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: 'J',
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('First name must be at least 2 characters'),
          ],
        );
      });

      group('Last Name Validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when last name is empty',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: '',
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Last name is required'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when last name is too short',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: 'D',
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Last name must be at least 2 characters'),
          ],
        );
      });

      group('Display Name Validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when display name is empty',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: '',
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Display name is required'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when display name is too short',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: 'JD',
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Display name must be at least 3 characters'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when display name exceeds 30 characters',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: 'A' * 31,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Display name must be at most 30 characters'),
          ],
        );
      });

      group('Email Validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when email is empty',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: '',
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Email cannot be empty'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when email is invalid format',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: 'invalid-email',
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Please enter a valid email address'),
          ],
        );
      });

      group('Password Validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when password is empty',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: '',
            confirmPassword: '',
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Password cannot be empty'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when password is less than 8 characters',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: 'Pass1',
            confirmPassword: 'Pass1',
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Password must be at least 8 characters'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when password has no uppercase',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: 'password1',
            confirmPassword: 'password1',
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Password must contain at least 1 uppercase letter'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when password has no number',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: 'Password',
            confirmPassword: 'Password',
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Password must contain at least 1 number'),
          ],
        );
      });

      group('Password Confirmation Validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when passwords do not match',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: 'DifferentPassword1',
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Passwords do not match'),
          ],
        );
      });

      group('Successful Registration', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationSuccess] when registration succeeds',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async => TestUserData.testUser,
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
          verify: (_) {
            verify(() => mockAnalytics.logEvent(name: 'onboarding_completed')).called(1);
          },
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'does not log onboarding_completed when registration fails',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async =>
                  throw Exception('Email already in use'),
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Email already in use'),
          ],
          verify: (_) {
            verifyNever(() => mockAnalytics.logEvent(name: 'onboarding_completed'));
          },
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'accepts email with plus addressing',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async => TestUserData.testUser,
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: 'test+tag@example.com',
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
        );
      });

      group('Registration Failure', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when repository throws',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async =>
                throw Exception('Email already in use'),
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Email already in use'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'strips Exception prefix from error message',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async =>
                throw Exception('Exception: Nested error'),
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Nested error'),
          ],
        );
      });

      group('Non-critical Failures', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationSuccess] even when display name update fails',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async => TestUserData.testUser,
            );
            mockAuthRepository.setUpdateUserProfileBehavior(
              ({String? displayName, String? photoUrl}) async =>
                throw Exception('Failed to update display name'),
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationSuccess] even when updateUserNames fails',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async => TestUserData.testUser,
            );
            mockAuthRepository.setUpdateUserNamesBehavior(
              ({required String firstName, required String lastName, String? gender}) async =>
                throw Exception('Failed to persist names'),
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationSuccess] even when email verification fails',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async => TestUserData.testUser,
            );
            mockAuthRepository.setSendEmailVerificationBehavior(
              () async => throw Exception('Failed to send verification'),
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            firstName: validFirstName,
            lastName: validLastName,
            displayName: validDisplayName,
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            gender: validGender,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
        );
      });
    });

    group('RegistrationFormReset', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationInitial] when form is reset',
        build: () => registrationBloc,
        act: (bloc) => bloc.add(const RegistrationFormReset()),
        expect: () => [
          const RegistrationInitial(),
        ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationInitial] after failure state',
        build: () => registrationBloc,
        seed: () => const RegistrationFailure('Some error'),
        act: (bloc) => bloc.add(const RegistrationFormReset()),
        expect: () => [
          const RegistrationInitial(),
        ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationInitial] after success state',
        build: () => registrationBloc,
        seed: () => const RegistrationSuccess(),
        act: (bloc) => bloc.add(const RegistrationFormReset()),
        expect: () => [
          const RegistrationInitial(),
        ],
      );
    });

    group('Event props', () {
      test('RegistrationSubmitted props contains all fields', () {
        const event = RegistrationSubmitted(
          firstName: 'John',
          lastName: 'Doe',
          displayName: 'JohnD',
          email: 'test@example.com',
          password: 'Password1',
          confirmPassword: 'Password1',
          gender: 'male',
        );
        expect(event.props, ['John', 'Doe', 'JohnD', 'test@example.com', 'Password1', 'Password1', 'male']);
      });

      test('RegistrationFormReset props is empty', () {
        const event = RegistrationFormReset();
        expect(event.props, isEmpty);
      });
    });

    group('State props', () {
      test('RegistrationInitial props is empty', () {
        const state = RegistrationInitial();
        expect(state.props, isEmpty);
      });

      test('RegistrationLoading props is empty', () {
        const state = RegistrationLoading();
        expect(state.props, isEmpty);
      });

      test('RegistrationSuccess props is empty', () {
        const state = RegistrationSuccess();
        expect(state.props, isEmpty);
      });

      test('RegistrationFailure props contains message', () {
        const state = RegistrationFailure('Error message');
        expect(state.props, ['Error message']);
      });
    });

    group('State equality', () {
      test('RegistrationInitial instances are equal', () {
        expect(const RegistrationInitial(), const RegistrationInitial());
      });

      test('RegistrationLoading instances are equal', () {
        expect(const RegistrationLoading(), const RegistrationLoading());
      });

      test('RegistrationSuccess instances are equal', () {
        expect(const RegistrationSuccess(), const RegistrationSuccess());
      });

      test('RegistrationFailure instances with same message are equal', () {
        expect(
          const RegistrationFailure('Error'),
          const RegistrationFailure('Error'),
        );
      });

      test('RegistrationFailure instances with different messages are not equal', () {
        expect(
          const RegistrationFailure('Error 1'),
          isNot(const RegistrationFailure('Error 2')),
        );
      });
    });

    group('Event equality', () {
      test('RegistrationSubmitted instances with same values are equal', () {
        expect(
          const RegistrationSubmitted(
            firstName: 'John',
            lastName: 'Doe',
            displayName: 'JohnD',
            email: 'test@example.com',
            password: 'Password1',
            confirmPassword: 'Password1',
            gender: 'male',
          ),
          const RegistrationSubmitted(
            firstName: 'John',
            lastName: 'Doe',
            displayName: 'JohnD',
            email: 'test@example.com',
            password: 'Password1',
            confirmPassword: 'Password1',
            gender: 'male',
          ),
        );
      });

      test('RegistrationSubmitted instances with different values are not equal', () {
        expect(
          const RegistrationSubmitted(
            firstName: 'John',
            lastName: 'Doe',
            displayName: 'JohnD',
            email: 'test1@example.com',
            password: 'Password1',
            confirmPassword: 'Password1',
            gender: 'male',
          ),
          isNot(const RegistrationSubmitted(
            firstName: 'John',
            lastName: 'Doe',
            displayName: 'JohnD',
            email: 'test2@example.com',
            password: 'Password1',
            confirmPassword: 'Password1',
            gender: 'male',
          )),
        );
      });

      test('RegistrationFormReset instances are equal', () {
        expect(const RegistrationFormReset(), const RegistrationFormReset());
      });
    });
  });
}

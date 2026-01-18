// Verifies that RegistrationBloc correctly handles registration events and emits appropriate states.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_state.dart';
import '../../../data/mock_auth_repository.dart';

void main() {
  group('RegistrationBloc', () {
    late MockAuthRepository mockAuthRepository;
    late RegistrationBloc registrationBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      registrationBloc = RegistrationBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      registrationBloc.close();
      mockAuthRepository.dispose();
    });

    test('initial state is RegistrationInitial', () {
      expect(registrationBloc.state, const RegistrationInitial());
    });

    group('RegistrationSubmitted', () {
      const validEmail = 'test@example.com';
      const validPassword = 'password123';
      const validDisplayName = 'Test User';

      group('Email Validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when email is empty',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: '',
            password: validPassword,
            confirmPassword: validPassword,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Email cannot be empty'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when email is only whitespace',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: '   ',
            password: validPassword,
            confirmPassword: validPassword,
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
            email: 'invalid-email',
            password: validPassword,
            confirmPassword: validPassword,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Please enter a valid email address'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when email has no domain',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: 'test@',
            password: validPassword,
            confirmPassword: validPassword,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Please enter a valid email address'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when email has no username',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: '@example.com',
            password: validPassword,
            confirmPassword: validPassword,
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
            email: validEmail,
            password: '',
            confirmPassword: '',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Password cannot be empty'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when password is only whitespace',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: validEmail,
            password: '   ',
            confirmPassword: '   ',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Password cannot be empty'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when password is less than 6 characters',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: validEmail,
            password: '12345',
            confirmPassword: '12345',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Password must be at least 6 characters long'),
          ],
        );
      });

      group('Password Confirmation Validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when passwords do not match',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: validEmail,
            password: validPassword,
            confirmPassword: 'differentpassword',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Passwords do not match'),
          ],
        );
      });

      group('Display Name Validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationFailure] when display name exceeds 50 characters',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(RegistrationSubmitted(
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            displayName: 'A' * 51,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Display name must be less than 50 characters'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'accepts display name with exactly 50 characters',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async => TestUserData.testUser,
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(RegistrationSubmitted(
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            displayName: 'A' * 50,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
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
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationSuccess] when registration succeeds with display name',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async => TestUserData.testUser,
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            displayName: validDisplayName,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationSuccess] when registration succeeds with empty display name',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async => TestUserData.testUser,
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            displayName: '',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'emits [RegistrationLoading, RegistrationSuccess] when registration succeeds with whitespace display name',
          setUp: () {
            mockAuthRepository.setCreateUserWithEmailAndPasswordBehavior(
              ({required String email, required String password}) async => TestUserData.testUser,
            );
          },
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            displayName: '   ',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'fails validation when email has leading/trailing whitespace',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: '  test@example.com  ',
            password: validPassword,
            confirmPassword: validPassword,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Please enter a valid email address'),
          ],
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
            email: 'test+tag@example.com',
            password: validPassword,
            confirmPassword: validPassword,
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
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
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
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
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
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
            displayName: validDisplayName,
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
            email: validEmail,
            password: validPassword,
            confirmPassword: validPassword,
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
          email: 'test@example.com',
          password: 'password',
          confirmPassword: 'password',
          displayName: 'Test',
        );
        expect(event.props, ['test@example.com', 'password', 'password', 'Test']);
      });

      test('RegistrationSubmitted props with null displayName', () {
        const event = RegistrationSubmitted(
          email: 'test@example.com',
          password: 'password',
          confirmPassword: 'password',
        );
        expect(event.props, ['test@example.com', 'password', 'password', null]);
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
            email: 'test@example.com',
            password: 'password',
            confirmPassword: 'password',
            displayName: 'Test',
          ),
          const RegistrationSubmitted(
            email: 'test@example.com',
            password: 'password',
            confirmPassword: 'password',
            displayName: 'Test',
          ),
        );
      });

      test('RegistrationSubmitted instances with different values are not equal', () {
        expect(
          const RegistrationSubmitted(
            email: 'test1@example.com',
            password: 'password',
            confirmPassword: 'password',
          ),
          isNot(const RegistrationSubmitted(
            email: 'test2@example.com',
            password: 'password',
            confirmPassword: 'password',
          )),
        );
      });

      test('RegistrationFormReset instances are equal', () {
        expect(const RegistrationFormReset(), const RegistrationFormReset());
      });
    });
  });
}

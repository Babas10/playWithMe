// Verifies that PasswordResetBloc correctly handles password reset events and emits appropriate states.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_state.dart';
import '../../../data/mock_auth_repository.dart';

void main() {
  group('PasswordResetBloc', () {
    late MockAuthRepository mockAuthRepository;
    late PasswordResetBloc passwordResetBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      passwordResetBloc = PasswordResetBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      passwordResetBloc.close();
      mockAuthRepository.dispose();
    });

    test('initial state is PasswordResetInitial', () {
      expect(passwordResetBloc.state, const PasswordResetInitial());
    });

    group('PasswordResetRequested', () {
      const validEmail = 'test@example.com';

      group('Email Validation', () {
        blocTest<PasswordResetBloc, PasswordResetState>(
          'emits [PasswordResetLoading, PasswordResetFailure] when email is empty',
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: '')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Email cannot be empty'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'emits [PasswordResetLoading, PasswordResetFailure] when email is only whitespace',
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: '   ')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Email cannot be empty'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'emits [PasswordResetLoading, PasswordResetFailure] when email is invalid format',
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: 'invalid-email')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Please enter a valid email address'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'emits [PasswordResetLoading, PasswordResetFailure] when email has no domain',
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: 'test@')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Please enter a valid email address'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'emits [PasswordResetLoading, PasswordResetFailure] when email has no username',
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: '@example.com')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Please enter a valid email address'),
          ],
        );
      });

      group('Successful Password Reset', () {
        blocTest<PasswordResetBloc, PasswordResetState>(
          'emits [PasswordResetLoading, PasswordResetSuccess] when password reset succeeds',
          setUp: () {
            mockAuthRepository.setSendPasswordResetEmailBehavior(
              ({required String email}) async {},
            );
          },
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: validEmail)),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetSuccess(validEmail),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'fails validation when email has leading/trailing whitespace',
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: '  test@example.com  ')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Please enter a valid email address'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'accepts email with plus addressing',
          setUp: () {
            mockAuthRepository.setSendPasswordResetEmailBehavior(
              ({required String email}) async {},
            );
          },
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: 'test+tag@example.com')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetSuccess('test+tag@example.com'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'accepts email with dots in username',
          setUp: () {
            mockAuthRepository.setSendPasswordResetEmailBehavior(
              ({required String email}) async {},
            );
          },
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: 'test.user@example.com')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetSuccess('test.user@example.com'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'accepts email with hyphen in username',
          setUp: () {
            mockAuthRepository.setSendPasswordResetEmailBehavior(
              ({required String email}) async {},
            );
          },
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: 'test-user@example.com')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetSuccess('test-user@example.com'),
          ],
        );
      });

      group('Password Reset Failure', () {
        blocTest<PasswordResetBloc, PasswordResetState>(
          'emits [PasswordResetLoading, PasswordResetFailure] when repository throws',
          setUp: () {
            mockAuthRepository.setSendPasswordResetEmailBehavior(
              ({required String email}) async => throw Exception('User not found'),
            );
          },
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: validEmail)),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('User not found'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'strips Exception prefix from error message',
          setUp: () {
            mockAuthRepository.setSendPasswordResetEmailBehavior(
              ({required String email}) async => throw Exception('Network error'),
            );
          },
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: validEmail)),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Network error'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'handles generic error message',
          setUp: () {
            mockAuthRepository.setSendPasswordResetEmailBehavior(
              ({required String email}) async => throw Exception('Something went wrong'),
            );
          },
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: validEmail)),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Something went wrong'),
          ],
        );
      });
    });

    group('PasswordResetFormReset', () {
      blocTest<PasswordResetBloc, PasswordResetState>(
        'emits [PasswordResetInitial] when form is reset',
        build: () => passwordResetBloc,
        act: (bloc) => bloc.add(const PasswordResetFormReset()),
        expect: () => [
          const PasswordResetInitial(),
        ],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'emits [PasswordResetInitial] after failure state',
        build: () => passwordResetBloc,
        seed: () => const PasswordResetFailure('Some error'),
        act: (bloc) => bloc.add(const PasswordResetFormReset()),
        expect: () => [
          const PasswordResetInitial(),
        ],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'emits [PasswordResetInitial] after success state',
        build: () => passwordResetBloc,
        seed: () => const PasswordResetSuccess('test@example.com'),
        act: (bloc) => bloc.add(const PasswordResetFormReset()),
        expect: () => [
          const PasswordResetInitial(),
        ],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'emits [PasswordResetInitial] after loading state',
        build: () => passwordResetBloc,
        seed: () => const PasswordResetLoading(),
        act: (bloc) => bloc.add(const PasswordResetFormReset()),
        expect: () => [
          const PasswordResetInitial(),
        ],
      );
    });

    group('Event props', () {
      test('PasswordResetRequested props contains email', () {
        const event = PasswordResetRequested(email: 'test@example.com');
        expect(event.props, ['test@example.com']);
      });

      test('PasswordResetFormReset props is empty', () {
        const event = PasswordResetFormReset();
        expect(event.props, isEmpty);
      });
    });

    group('State props', () {
      test('PasswordResetInitial props is empty', () {
        const state = PasswordResetInitial();
        expect(state.props, isEmpty);
      });

      test('PasswordResetLoading props is empty', () {
        const state = PasswordResetLoading();
        expect(state.props, isEmpty);
      });

      test('PasswordResetSuccess props contains email', () {
        const state = PasswordResetSuccess('test@example.com');
        expect(state.props, ['test@example.com']);
      });

      test('PasswordResetFailure props contains message', () {
        const state = PasswordResetFailure('Error message');
        expect(state.props, ['Error message']);
      });
    });

    group('State equality', () {
      test('PasswordResetInitial instances are equal', () {
        expect(const PasswordResetInitial(), const PasswordResetInitial());
      });

      test('PasswordResetLoading instances are equal', () {
        expect(const PasswordResetLoading(), const PasswordResetLoading());
      });

      test('PasswordResetSuccess instances with same email are equal', () {
        expect(
          const PasswordResetSuccess('test@example.com'),
          const PasswordResetSuccess('test@example.com'),
        );
      });

      test('PasswordResetSuccess instances with different emails are not equal', () {
        expect(
          const PasswordResetSuccess('test1@example.com'),
          isNot(const PasswordResetSuccess('test2@example.com')),
        );
      });

      test('PasswordResetFailure instances with same message are equal', () {
        expect(
          const PasswordResetFailure('Error'),
          const PasswordResetFailure('Error'),
        );
      });

      test('PasswordResetFailure instances with different messages are not equal', () {
        expect(
          const PasswordResetFailure('Error 1'),
          isNot(const PasswordResetFailure('Error 2')),
        );
      });
    });

    group('Event equality', () {
      test('PasswordResetRequested instances with same email are equal', () {
        expect(
          const PasswordResetRequested(email: 'test@example.com'),
          const PasswordResetRequested(email: 'test@example.com'),
        );
      });

      test('PasswordResetRequested instances with different emails are not equal', () {
        expect(
          const PasswordResetRequested(email: 'test1@example.com'),
          isNot(const PasswordResetRequested(email: 'test2@example.com')),
        );
      });

      test('PasswordResetFormReset instances are equal', () {
        expect(const PasswordResetFormReset(), const PasswordResetFormReset());
      });
    });
  });
}

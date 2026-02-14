// Validates InviteRegistrationBloc emits correct states for invite-based account creation and group joining.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGroupInviteLinkRepository extends Mock
    implements GroupInviteLinkRepository {}

class MockPendingInviteStorage extends Mock implements PendingInviteStorage {}

class FakeUserEntity extends Fake implements UserEntity {
  @override
  String get uid => 'user-123';

  @override
  String get email => 'test@example.com';
}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockGroupInviteLinkRepository mockInviteRepo;
  late MockPendingInviteStorage mockStorage;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockInviteRepo = MockGroupInviteLinkRepository();
    mockStorage = MockPendingInviteStorage();
  });

  InviteRegistrationBloc buildBloc() {
    return InviteRegistrationBloc(
      authRepository: mockAuthRepo,
      groupInviteLinkRepository: mockInviteRepo,
      pendingInviteStorage: mockStorage,
    );
  }

  const validEvent = InviteRegistrationSubmitted(
    fullName: 'John Doe',
    displayName: 'JohnD',
    email: 'john@example.com',
    password: 'Password1',
    confirmPassword: 'Password1',
    token: 'test-token',
  );

  const joinResult = (
    groupId: 'group-123',
    groupName: 'Beach Volleyball Crew',
    alreadyMember: false,
  );

  void stubSuccessfulRegistration() {
    when(() => mockAuthRepo.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => FakeUserEntity());
    when(() => mockAuthRepo.updateUserProfile(
          displayName: any(named: 'displayName'),
        )).thenAnswer((_) async {});
    when(() => mockAuthRepo.sendEmailVerification())
        .thenAnswer((_) async {});
    when(() => mockInviteRepo.joinGroupViaInvite(token: any(named: 'token')))
        .thenAnswer((_) async => joinResult);
    when(() => mockStorage.clear()).thenAnswer((_) async {});
  }

  group('InviteRegistrationBloc', () {
    test('initial state is InviteRegistrationInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const InviteRegistrationInitial());
      bloc.close();
    });

    group('InviteRegistrationSubmitted', () {
      group('successful flow', () {
        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits [creatingAccount, joiningGroup, success] on successful registration and join',
          setUp: stubSuccessfulRegistration,
          build: buildBloc,
          act: (bloc) => bloc.add(validEvent),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationJoiningGroup(),
            const InviteRegistrationSuccess(
              groupId: 'group-123',
              groupName: 'Beach Volleyball Crew',
            ),
          ],
          verify: (_) {
            verify(() => mockAuthRepo.createUserWithEmailAndPassword(
                  email: 'john@example.com',
                  password: 'Password1',
                )).called(1);
            verify(() => mockAuthRepo.updateUserProfile(
                  displayName: 'JohnD',
                )).called(1);
            verify(() => mockAuthRepo.sendEmailVerification()).called(1);
            verify(() =>
                    mockInviteRepo.joinGroupViaInvite(token: 'test-token'))
                .called(1);
            verify(() => mockStorage.clear()).called(1);
          },
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'succeeds even when display name update fails',
          setUp: () {
            when(() => mockAuthRepo.createUserWithEmailAndPassword(
                  email: any(named: 'email'),
                  password: any(named: 'password'),
                )).thenAnswer((_) async => FakeUserEntity());
            when(() => mockAuthRepo.updateUserProfile(
                  displayName: any(named: 'displayName'),
                )).thenThrow(Exception('Profile update failed'));
            when(() => mockAuthRepo.sendEmailVerification())
                .thenAnswer((_) async {});
            when(() =>
                    mockInviteRepo.joinGroupViaInvite(token: any(named: 'token')))
                .thenAnswer((_) async => joinResult);
            when(() => mockStorage.clear()).thenAnswer((_) async {});
          },
          build: buildBloc,
          act: (bloc) => bloc.add(validEvent),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationJoiningGroup(),
            const InviteRegistrationSuccess(
              groupId: 'group-123',
              groupName: 'Beach Volleyball Crew',
            ),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'succeeds even when email verification fails',
          setUp: () {
            when(() => mockAuthRepo.createUserWithEmailAndPassword(
                  email: any(named: 'email'),
                  password: any(named: 'password'),
                )).thenAnswer((_) async => FakeUserEntity());
            when(() => mockAuthRepo.updateUserProfile(
                  displayName: any(named: 'displayName'),
                )).thenAnswer((_) async {});
            when(() => mockAuthRepo.sendEmailVerification())
                .thenThrow(Exception('Verification failed'));
            when(() =>
                    mockInviteRepo.joinGroupViaInvite(token: any(named: 'token')))
                .thenAnswer((_) async => joinResult);
            when(() => mockStorage.clear()).thenAnswer((_) async {});
          },
          build: buildBloc,
          act: (bloc) => bloc.add(validEvent),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationJoiningGroup(),
            const InviteRegistrationSuccess(
              groupId: 'group-123',
              groupName: 'Beach Volleyball Crew',
            ),
          ],
        );
      });

      group('validation errors', () {
        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when full name is empty',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: '',
            displayName: 'JohnD',
            email: 'john@example.com',
            password: 'Password1',
            confirmPassword: 'Password1',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message: 'Full name is required'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when full name is too short',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: 'J',
            displayName: 'JohnD',
            email: 'john@example.com',
            password: 'Password1',
            confirmPassword: 'Password1',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message: 'Full name must be at least 2 characters'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when display name is empty',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: 'John Doe',
            displayName: '',
            email: 'john@example.com',
            password: 'Password1',
            confirmPassword: 'Password1',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message: 'Display name is required'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when display name is too short',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: 'John Doe',
            displayName: 'JD',
            email: 'john@example.com',
            password: 'Password1',
            confirmPassword: 'Password1',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message: 'Display name must be at least 3 characters'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when display name is too long',
          build: buildBloc,
          act: (bloc) => bloc.add(InviteRegistrationSubmitted(
            fullName: 'John Doe',
            displayName: 'A' * 31,
            email: 'john@example.com',
            password: 'Password1',
            confirmPassword: 'Password1',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message: 'Display name must be at most 30 characters'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when email is empty',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: 'John Doe',
            displayName: 'JohnD',
            email: '',
            password: 'Password1',
            confirmPassword: 'Password1',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message: 'Email is required'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when email is invalid',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: 'John Doe',
            displayName: 'JohnD',
            email: 'not-an-email',
            password: 'Password1',
            confirmPassword: 'Password1',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message: 'Please enter a valid email address'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when password is too short',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: 'John Doe',
            displayName: 'JohnD',
            email: 'john@example.com',
            password: 'Pass1',
            confirmPassword: 'Pass1',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message: 'Password must be at least 8 characters'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when password has no uppercase',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: 'John Doe',
            displayName: 'JohnD',
            email: 'john@example.com',
            password: 'password1',
            confirmPassword: 'password1',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message:
                    'Password must contain at least 1 uppercase letter'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when password has no number',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: 'John Doe',
            displayName: 'JohnD',
            email: 'john@example.com',
            password: 'Password',
            confirmPassword: 'Password',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message:
                    'Password must contain at least 1 number'),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when passwords do not match',
          build: buildBloc,
          act: (bloc) => bloc.add(const InviteRegistrationSubmitted(
            fullName: 'John Doe',
            displayName: 'JohnD',
            email: 'john@example.com',
            password: 'Password1',
            confirmPassword: 'Password2',
            token: 'test-token',
          )),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
                message: 'Passwords do not match'),
          ],
        );
      });

      group('Firebase errors', () {
        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure with email-already-in-use error',
          setUp: () {
            when(() => mockAuthRepo.createUserWithEmailAndPassword(
                  email: any(named: 'email'),
                  password: any(named: 'password'),
                )).thenThrow(
                Exception('email-already-in-use'));
          },
          build: buildBloc,
          act: (bloc) => bloc.add(validEvent),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
              message:
                  'An account with this email already exists. Try logging in instead.',
              errorCode: 'email-already-in-use',
            ),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure with weak-password error',
          setUp: () {
            when(() => mockAuthRepo.createUserWithEmailAndPassword(
                  email: any(named: 'email'),
                  password: any(named: 'password'),
                )).thenThrow(Exception('weak-password'));
          },
          build: buildBloc,
          act: (bloc) => bloc.add(validEvent),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
              message:
                  'Password is too weak. Use at least 8 characters.',
              errorCode: 'weak-password',
            ),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure with invalid-email error',
          setUp: () {
            when(() => mockAuthRepo.createUserWithEmailAndPassword(
                  email: any(named: 'email'),
                  password: any(named: 'password'),
                )).thenThrow(Exception('invalid-email'));
          },
          build: buildBloc,
          act: (bloc) => bloc.add(validEvent),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
              message: 'Please enter a valid email address.',
              errorCode: 'invalid-email',
            ),
          ],
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure with network error',
          setUp: () {
            when(() => mockAuthRepo.createUserWithEmailAndPassword(
                  email: any(named: 'email'),
                  password: any(named: 'password'),
                )).thenThrow(Exception('network-request-failed'));
          },
          build: buildBloc,
          act: (bloc) => bloc.add(validEvent),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationFailure(
              message:
                  'Unable to connect. Please check your connection and try again.',
              errorCode: 'network-request-failed',
            ),
          ],
        );
      });

      group('token expired during join', () {
        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits [creatingAccount, joiningGroup, tokenExpired] when token expires during join',
          setUp: () {
            when(() => mockAuthRepo.createUserWithEmailAndPassword(
                  email: any(named: 'email'),
                  password: any(named: 'password'),
                )).thenAnswer((_) async => FakeUserEntity());
            when(() => mockAuthRepo.updateUserProfile(
                  displayName: any(named: 'displayName'),
                )).thenAnswer((_) async {});
            when(() => mockAuthRepo.sendEmailVerification())
                .thenAnswer((_) async {});
            when(() =>
                    mockInviteRepo.joinGroupViaInvite(token: any(named: 'token')))
                .thenThrow(GroupInviteLinkException(
              'Token has expired',
              code: 'failed-precondition',
            ));
            when(() => mockStorage.clear()).thenAnswer((_) async {});
          },
          build: buildBloc,
          act: (bloc) => bloc.add(validEvent),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationJoiningGroup(),
            const InviteRegistrationTokenExpired(),
          ],
          verify: (_) {
            verify(() => mockStorage.clear()).called(1);
          },
        );

        blocTest<InviteRegistrationBloc, InviteRegistrationState>(
          'emits failure when join fails with non-precondition error',
          setUp: () {
            when(() => mockAuthRepo.createUserWithEmailAndPassword(
                  email: any(named: 'email'),
                  password: any(named: 'password'),
                )).thenAnswer((_) async => FakeUserEntity());
            when(() => mockAuthRepo.updateUserProfile(
                  displayName: any(named: 'displayName'),
                )).thenAnswer((_) async {});
            when(() => mockAuthRepo.sendEmailVerification())
                .thenAnswer((_) async {});
            when(() =>
                    mockInviteRepo.joinGroupViaInvite(token: any(named: 'token')))
                .thenThrow(GroupInviteLinkException(
              'Server error',
              code: 'internal',
            ));
            when(() => mockStorage.clear()).thenAnswer((_) async {});
          },
          build: buildBloc,
          act: (bloc) => bloc.add(validEvent),
          expect: () => [
            const InviteRegistrationCreatingAccount(),
            const InviteRegistrationJoiningGroup(),
            const InviteRegistrationFailure(
              message: 'Server error',
              errorCode: 'internal',
            ),
          ],
        );
      });
    });

    group('InviteRegistrationFormReset', () {
      blocTest<InviteRegistrationBloc, InviteRegistrationState>(
        'emits [initial] on form reset',
        build: buildBloc,
        seed: () => const InviteRegistrationFailure(
            message: 'Some error'),
        act: (bloc) => bloc.add(const InviteRegistrationFormReset()),
        expect: () => [const InviteRegistrationInitial()],
      );
    });
  });
}

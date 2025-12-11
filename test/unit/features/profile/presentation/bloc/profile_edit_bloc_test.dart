// Verifies that ProfileEditBloc handles profile editing with proper validation and state management

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_state.dart';

// Mocktail mocks
class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}

// Fake for testing
class FakeUserEntity extends Fake implements UserEntity {
  @override
  final String uid;
  @override
  final String email;

  FakeUserEntity({required this.uid, required this.email});
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late ProfileEditBloc profileEditBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
  });

  tearDown(() {
    profileEditBloc.close();
  });

  group('ProfileEditBloc', () {
    test('initial state is ProfileEditInitial', () {
      profileEditBloc = ProfileEditBloc(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
      expect(profileEditBloc.state, const ProfileEditState.initial());
    });

    group('ProfileEditStarted', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [loading, loaded] when started with valid data',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) => bloc.add(
          const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: 'https://example.com/photo.jpg',
          ),
        ),
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: 'https://example.com/photo.jpg',
            hasUnsavedChanges: false,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [loading, loaded] when started without photoUrl',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) => bloc.add(
          const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ),
        ),
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
        ],
      );
    });

    group('ProfileEditDisplayNameChanged', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with valid displayName and hasUnsavedChanges=true',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          // Initialize with original values
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          // Change display name
          bloc.add(const ProfileEditEvent.displayNameChanged('Jane Smith'));
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: 'Jane Smith',
            photoUrl: null,
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with error when displayName is too short',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('Jo'));
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: 'Jo',
            photoUrl: null,
            displayNameError: 'Display name must be at least 3 characters',
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with error when displayName is empty',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged(''));
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: '',
            photoUrl: null,
            displayNameError: 'Display name cannot be empty',
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with error when displayName is too long',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(ProfileEditEvent.displayNameChanged('A' * 51));
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          ProfileEditState.loaded(
            displayName: 'A' * 51,
            photoUrl: null,
            displayNameError: 'Display name must be less than 50 characters',
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with error when displayName contains invalid characters',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('John@Doe!'));
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: 'John@Doe!',
            photoUrl: null,
            displayNameError: 'Display name contains invalid characters',
            hasUnsavedChanges: true,
          ),
        ],
      );
    });

    group('ProfileEditPhotoUrlChanged', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with valid photoUrl and hasUnsavedChanges=true',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.photoUrlChanged(
            'https://example.com/photo.jpg',
          ));
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: 'https://example.com/photo.jpg',
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with null when photoUrl is empty string',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: 'https://example.com/old.jpg',
          ));
          bloc.add(const ProfileEditEvent.photoUrlChanged(''));
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: 'https://example.com/old.jpg',
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with error when photoUrl is invalid',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.photoUrlChanged('not-a-url'));
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: 'not-a-url',
            photoUrlError: 'URL must start with http:// or https://',
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded without error for valid https URL',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.photoUrlChanged(
            'https://example.com/photo',
          ));
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: 'https://example.com/photo',
            photoUrlError: null,
            hasUnsavedChanges: true,
          ),
        ],
      );
    });

    group('ProfileEditSaveRequested', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [saving, success] when save is successful',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(
            FakeUserEntity(uid: 'user123', email: 'test@example.com'),
          );
          when(() => mockUserRepository.updateUserProfile(
                any(),
                displayName: any(named: 'displayName'),
              )).thenAnswer((_) async {});
          when(() => mockAuthRepository.updateUserProfile(
                displayName: any(named: 'displayName'),
                photoUrl: any(named: 'photoUrl'),
              )).thenAnswer((_) async {});
          when(() => mockAuthRepository.reloadUser()).thenAnswer((_) async {});
        },
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('Jane Smith'));
          bloc.add(const ProfileEditEvent.saveRequested());
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: 'Jane Smith',
            photoUrl: null,
            hasUnsavedChanges: true,
          ),
          const ProfileEditState.saving(
            displayName: 'Jane Smith',
            photoUrl: null,
          ),
          const ProfileEditState.success(),
        ],
        verify: (_) {
          verify(() => mockUserRepository.updateUserProfile(
                'user123',
                displayName: 'Jane Smith',
              )).called(1);
          verify(() => mockAuthRepository.updateUserProfile(
                displayName: 'Jane Smith',
                photoUrl: null,
              )).called(1);
          verify(() => mockAuthRepository.reloadUser()).called(1);
        },
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits success immediately when no changes to save',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.saveRequested());
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.success(),
        ],
        verify: (_) {
          verifyNever(() => mockAuthRepository.updateUserProfile(
                displayName: any(named: 'displayName'),
                photoUrl: any(named: 'photoUrl'),
              ));
        },
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'does not save when validation errors exist',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('Jo'));
          bloc.add(const ProfileEditEvent.saveRequested());
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          // After displayNameChanged - validation error appears
          const ProfileEditState.loaded(
            displayName: 'Jo',
            photoUrl: null,
            displayNameError: 'Display name must be at least 3 characters',
            hasUnsavedChanges: true,
          ),
          // Note: saveRequested does not emit a new state because the state is identical
          // (BLoC deduplicates). The important thing is that updateUserProfile is never called.
        ],
        verify: (_) {
          verifyNever(() => mockAuthRepository.updateUserProfile(
                displayName: any(named: 'displayName'),
                photoUrl: any(named: 'photoUrl'),
              ));
        },
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [saving, error] when repository throws exception',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(
            FakeUserEntity(uid: 'user123', email: 'test@example.com'),
          );
          when(() => mockUserRepository.updateUserProfile(
                any(),
                displayName: any(named: 'displayName'),
              )).thenThrow(Exception('Network error'));
        },
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('Jane Smith'));
          bloc.add(const ProfileEditEvent.saveRequested());
        },
        expect: () => [
          const ProfileEditState.loading(),
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: false,
          ),
          const ProfileEditState.loaded(
            displayName: 'Jane Smith',
            photoUrl: null,
            hasUnsavedChanges: true,
          ),
          const ProfileEditState.saving(
            displayName: 'Jane Smith',
            photoUrl: null,
          ),
          const ProfileEditState.error(
            message: 'Network error',
            displayName: 'Jane Smith',
            photoUrl: null,
          ),
        ],
        verify: (_) {
          verify(() => mockUserRepository.updateUserProfile(
                'user123',
                displayName: 'Jane Smith',
              )).called(1);
          // authRepository.updateUserProfile should never be called since userRepository fails first
          verifyNever(() => mockAuthRepository.updateUserProfile(
                displayName: any(named: 'displayName'),
                photoUrl: any(named: 'photoUrl'),
              ));
        },
      );
    });

    group('ProfileEditCancelled', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits success when cancelled',
        build: () => ProfileEditBloc(
          authRepository: mockAuthRepository,
          userRepository: mockUserRepository,
        ),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: true,
        ),
        act: (bloc) => bloc.add(const ProfileEditEvent.cancelled()),
        expect: () => [
          const ProfileEditState.success(),
        ],
      );
    });
  });
}

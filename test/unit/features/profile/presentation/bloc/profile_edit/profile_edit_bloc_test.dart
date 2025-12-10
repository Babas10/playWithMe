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

// Mocktail mock for AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late ProfileEditBloc profileEditBloc;

  final testUser = const UserEntity(
    uid: 'test-uid-123',
    email: 'test@example.com',
    isEmailVerified: true,
    isAnonymous: false,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    
    // Default stubs
    when(() => mockAuthRepository.currentUser).thenReturn(testUser);
  });

  tearDown(() {
    profileEditBloc.close();
  });

  ProfileEditBloc buildBloc() {
    return ProfileEditBloc(
      authRepository: mockAuthRepository,
      userRepository: mockUserRepository,
    );
  }

  group('ProfileEditBloc', () {
    test('initial state is ProfileEditInitial', () {
      profileEditBloc = buildBloc();
      expect(profileEditBloc.state, const ProfileEditState.initial());
    });

    group('ProfileEditStarted', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [loading, loaded] when started with valid data',
        build: buildBloc,
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
        build: buildBloc,
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
        build: buildBloc,
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
        build: buildBloc,
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
        build: buildBloc,
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
        build: buildBloc,
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
        build: buildBloc,
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
        build: buildBloc,
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
        build: buildBloc,
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
        build: buildBloc,
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
        build: buildBloc,
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
          when(() => mockAuthRepository.updateUserProfile(
                displayName: any(named: 'displayName'),
                photoUrl: any(named: 'photoUrl'),
              )).thenAnswer((_) async {});
          when(() => mockUserRepository.updateUserProfile(
                any(), // uid
                displayName: any(named: 'displayName'),
              )).thenAnswer((_) async {});
          when(() => mockAuthRepository.reloadUser()).thenAnswer((_) async {});
        },
        build: buildBloc,
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
                'test-uid-123',
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
        build: buildBloc,
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
          verifyNever(() => mockUserRepository.updateUserProfile(
                any(),
                displayName: any(named: 'displayName'),
              ));
        },
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'does not save when validation errors exist',
        build: buildBloc,
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
          verifyNever(() => mockUserRepository.updateUserProfile(
                any(),
                displayName: any(named: 'displayName'),
              ));
        },
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [saving, error] when repository throws exception',
        setUp: () {
          when(() => mockUserRepository.updateUserProfile(
                any(),
                displayName: any(named: 'displayName'),
              )).thenThrow(Exception('Network error'));
        },
        build: buildBloc,
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
                'test-uid-123',
                displayName: 'Jane Smith',
              )).called(1);
        },
      );
    });

    group('ProfileEditCancelled', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits success when cancelled',
        build: buildBloc,
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
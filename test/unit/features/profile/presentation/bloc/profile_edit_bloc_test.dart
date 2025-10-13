// Verifies that ProfileEditBloc handles profile editing with proper validation and state management

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart' hide any;
import 'package:mocktail/mocktail.dart' as mocktail;
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_state.dart';

@GenerateMocks([AuthRepository])
import 'profile_edit_bloc_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProfileEditBloc profileEditBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  tearDown(() {
    profileEditBloc.close();
  });

  group('ProfileEditBloc', () {
    test('initial state is ProfileEditInitial', () {
      profileEditBloc = ProfileEditBloc(authRepository: mockAuthRepository);
      expect(profileEditBloc.state, const ProfileEditState.initial());
    });

    group('ProfileEditStarted', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [loading, loaded] when started with valid data',
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
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
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
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
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: false,
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
        skip: 2, // Skip loading and initial loaded states
        expect: () => [
          const ProfileEditState.loaded(
            displayName: 'Jane Smith',
            photoUrl: null,
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with error when displayName is too short',
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: false,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('Jo'));
        },
        skip: 2,
        expect: () => [
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
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: false,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged(''));
        },
        skip: 2,
        expect: () => [
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
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: false,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(ProfileEditEvent.displayNameChanged('A' * 51));
        },
        skip: 2,
        expect: () => [
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
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: false,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('John@Doe!'));
        },
        skip: 2,
        expect: () => [
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
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: false,
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
        skip: 2,
        expect: () => [
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: 'https://example.com/photo.jpg',
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with null when photoUrl is empty string',
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: 'https://example.com/old.jpg',
          hasUnsavedChanges: false,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: 'https://example.com/old.jpg',
          ));
          bloc.add(const ProfileEditEvent.photoUrlChanged(''));
        },
        skip: 2,
        expect: () => [
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: null,
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with error when photoUrl is invalid',
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: false,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.photoUrlChanged('not-a-url'));
        },
        skip: 2,
        expect: () => [
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: 'not-a-url',
            photoUrlError: 'Please enter a valid URL',
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits loaded with error when photoUrl does not point to image',
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: false,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.photoUrlChanged(
            'https://example.com/document.pdf',
          ));
        },
        skip: 2,
        expect: () => [
          const ProfileEditState.loaded(
            displayName: 'John Doe',
            photoUrl: 'https://example.com/document.pdf',
            photoUrlError: 'URL should point to an image file',
            hasUnsavedChanges: true,
          ),
        ],
      );
    });

    group('ProfileEditSaveRequested', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [saving, success] when save is successful',
        build: () {
          when(mockAuthRepository.updateUserProfile(
            displayName: mocktail.any(named: 'displayName'),
            photoUrl: mocktail.any(named: 'photoUrl'),
          )).thenAnswer((_) async => Future.value());
          when(mockAuthRepository.reloadUser()).thenAnswer((_) async => Future.value());
          return ProfileEditBloc(authRepository: mockAuthRepository);
        },
        seed: () => const ProfileEditState.loaded(
          displayName: 'Jane Smith',
          photoUrl: 'https://example.com/photo.jpg',
          hasUnsavedChanges: true,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('Jane Smith'));
          bloc.add(const ProfileEditEvent.photoUrlChanged(
            'https://example.com/photo.jpg',
          ));
          bloc.add(const ProfileEditEvent.saveRequested());
        },
        skip: 4, // Skip loading, loaded, and two field changes
        expect: () => [
          const ProfileEditState.saving(
            displayName: 'Jane Smith',
            photoUrl: 'https://example.com/photo.jpg',
          ),
          const ProfileEditState.success(),
        ],
        verify: (_) {
          verify(mockAuthRepository.updateUserProfile(
            displayName: 'Jane Smith',
            photoUrl: 'https://example.com/photo.jpg',
          )).called(1);
          verify(mockAuthRepository.reloadUser()).called(1);
        },
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits success immediately when no changes to save',
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'John Doe',
          photoUrl: null,
          hasUnsavedChanges: false,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.saveRequested());
        },
        skip: 2, // Skip loading and loaded
        expect: () => [
          const ProfileEditState.success(),
        ],
        verify: (_) {
          verifyNever(mockAuthRepository.updateUserProfile(
            displayName: mocktail.any(named: 'displayName'),
            photoUrl: mocktail.any(named: 'photoUrl'),
          ));
        },
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [loaded] with errors when save requested with invalid data',
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
        seed: () => const ProfileEditState.loaded(
          displayName: 'Jo',
          photoUrl: null,
          hasUnsavedChanges: true,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('Jo'));
          bloc.add(const ProfileEditEvent.saveRequested());
        },
        skip: 3, // Skip loading, loaded, and name change
        expect: () => [
          const ProfileEditState.loaded(
            displayName: 'Jo',
            photoUrl: null,
            displayNameError: 'Display name must be at least 3 characters',
            hasUnsavedChanges: true,
          ),
        ],
        verify: (_) {
          verifyNever(mockAuthRepository.updateUserProfile(
            displayName: mocktail.any(named: 'displayName'),
            photoUrl: mocktail.any(named: 'photoUrl'),
          ));
        },
      );

      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits [saving, error] when repository throws exception',
        build: () {
          when(mockAuthRepository.updateUserProfile(
            displayName: mocktail.any(named: 'displayName'),
            photoUrl: mocktail.any(named: 'photoUrl'),
          )).thenThrow(Exception('Network error'));
          return ProfileEditBloc(authRepository: mockAuthRepository);
        },
        seed: () => const ProfileEditState.loaded(
          displayName: 'Jane Smith',
          photoUrl: null,
          hasUnsavedChanges: true,
        ),
        act: (bloc) {
          bloc.add(const ProfileEditEvent.started(
            currentDisplayName: 'John Doe',
            currentPhotoUrl: null,
          ));
          bloc.add(const ProfileEditEvent.displayNameChanged('Jane Smith'));
          bloc.add(const ProfileEditEvent.saveRequested());
        },
        skip: 3, // Skip loading, loaded, and name change
        expect: () => [
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
      );
    });

    group('ProfileEditCancelled', () {
      blocTest<ProfileEditBloc, ProfileEditState>(
        'emits success when cancelled',
        build: () => ProfileEditBloc(authRepository: mockAuthRepository),
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

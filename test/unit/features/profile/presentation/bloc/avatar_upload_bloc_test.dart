// Verifies that AvatarUploadBloc handles avatar upload, deletion, and validation with proper state management

import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/repositories/image_storage_repository.dart';
import 'package:play_with_me/core/services/image_picker_service.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/avatar_upload/avatar_upload_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/avatar_upload/avatar_upload_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/avatar_upload/avatar_upload_state.dart';

// Mocktail mocks
class MockImageStorageRepository extends Mock implements ImageStorageRepository {}
class MockImagePickerService extends Mock implements ImagePickerService {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockFile extends Mock implements File {}

void main() {
  late MockImageStorageRepository mockImageStorageRepository;
  late MockImagePickerService mockImagePickerService;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockImageStorageRepository = MockImageStorageRepository();
    mockImagePickerService = MockImagePickerService();
    mockAuthRepository = MockAuthRepository();

    // Register fallback values
    registerFallbackValue(File(''));
    registerFallbackValue(ImageSource.gallery);
  });

  AvatarUploadBloc createBloc() {
    return AvatarUploadBloc(
      imageStorageRepository: mockImageStorageRepository,
      imagePickerService: mockImagePickerService,
      authRepository: mockAuthRepository,
    );
  }

  final testUser = UserEntity(
    uid: 'test-uid-123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: null,
    isEmailVerified: true,
    createdAt: DateTime(2024, 1, 1),
    lastSignInAt: DateTime(2024, 10, 1),
    isAnonymous: false,
  );

  group('AvatarUploadBloc', () {
    test('initial state is AvatarUploadInitial', () {
      final bloc = createBloc();
      expect(bloc.state, const AvatarUploadState.initial());
      bloc.close();
    });

    group('AvatarUploadStarted', () {
      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits initial state when started',
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.started()),
        expect: () => [
          const AvatarUploadState.initial(),
        ],
      );
    });

    group('AvatarUploadImageSourceSelected', () {
      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [picking, validating, picked] when image is selected and validated successfully',
        setUp: () {
          final testFile = File('test_avatar.jpg');
          when(() => mockImagePickerService.pickImage(
                source: any(named: 'source'),
                cropSquare: true,
              )).thenAnswer((_) async => testFile);
          when(() => mockImagePickerService.validateFileSize(
                any(),
                maxSizeInMB: 5,
              )).thenReturn(true);
          when(() => mockImagePickerService.validateFileExtension(any()))
              .thenReturn(true);
        },
        build: createBloc,
        act: (bloc) => bloc.add(
          const AvatarUploadEvent.imageSourceSelected(
            source: ImageSource.gallery,
          ),
        ),
        expect: () => [
          const AvatarUploadState.picking(),
          isA<AvatarUploadValidating>(),
          isA<AvatarUploadPicked>(),
        ],
      );

      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [picking, initial] when user cancels image selection',
        setUp: () {
          when(() => mockImagePickerService.pickImage(
                source: any(named: 'source'),
                cropSquare: true,
              )).thenAnswer((_) async => null);
        },
        build: createBloc,
        act: (bloc) => bloc.add(
          const AvatarUploadEvent.imageSourceSelected(
            source: ImageSource.camera,
          ),
        ),
        expect: () => [
          const AvatarUploadState.picking(),
          const AvatarUploadState.initial(),
        ],
      );

      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [picking, validationError] when image picker fails',
        setUp: () {
          when(() => mockImagePickerService.pickImage(
                source: any(named: 'source'),
                cropSquare: true,
              )).thenThrow(Exception('Picker failed'));
        },
        build: createBloc,
        act: (bloc) => bloc.add(
          const AvatarUploadEvent.imageSourceSelected(
            source: ImageSource.gallery,
          ),
        ),
        expect: () => [
          const AvatarUploadState.picking(),
          const AvatarUploadState.validationError(
            message: 'Failed to pick image: Picker failed',
          ),
        ],
      );
    });

    group('AvatarUploadImagePicked', () {
      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [validating, validationError] when file size is too large',
        setUp: () {
          when(() => mockImagePickerService.validateFileSize(
                any(),
                maxSizeInMB: 5,
              )).thenReturn(false);
        },
        build: createBloc,
        act: (bloc) => bloc.add(
          AvatarUploadEvent.imagePicked(imageFile: File('large_image.jpg')),
        ),
        expect: () => [
          isA<AvatarUploadValidating>(),
          const AvatarUploadState.validationError(
            message:
                'Image is too large. Please select an image smaller than 5MB.',
          ),
        ],
      );

      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [validating, validationError] when file extension is invalid',
        setUp: () {
          when(() => mockImagePickerService.validateFileSize(
                any(),
                maxSizeInMB: 5,
              )).thenReturn(true);
          when(() => mockImagePickerService.validateFileExtension(any()))
              .thenReturn(false);
        },
        build: createBloc,
        act: (bloc) => bloc.add(
          AvatarUploadEvent.imagePicked(imageFile: File('image.pdf')),
        ),
        expect: () => [
          isA<AvatarUploadValidating>(),
          const AvatarUploadState.validationError(
            message:
                'Invalid image format. Please select a JPG, PNG, or WebP image.',
          ),
        ],
      );

      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [validating, picked] when file is valid',
        setUp: () {
          when(() => mockImagePickerService.validateFileSize(
                any(),
                maxSizeInMB: 5,
              )).thenReturn(true);
          when(() => mockImagePickerService.validateFileExtension(any()))
              .thenReturn(true);
        },
        build: createBloc,
        act: (bloc) => bloc.add(
          AvatarUploadEvent.imagePicked(imageFile: File('valid_image.jpg')),
        ),
        expect: () => [
          isA<AvatarUploadValidating>(),
          isA<AvatarUploadPicked>(),
        ],
      );
    });

    group('AvatarUploadUploadRequested', () {
      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [uploading, uploadSuccess] when upload is successful',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockImageStorageRepository.uploadAvatar(
                userId: any(named: 'userId'),
                imageFile: any(named: 'imageFile'),
                onProgress: any(named: 'onProgress'),
              )).thenAnswer((_) async => 'https://example.com/avatar.jpg');
          when(() => mockAuthRepository.updateUserProfile(
                photoUrl: any(named: 'photoUrl'),
              )).thenAnswer((_) async {});
          when(() => mockAuthRepository.reloadUser()).thenAnswer((_) async {});
        },
        seed: () => AvatarUploadState.picked(imageFile: File('test_avatar.jpg')),
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.uploadRequested()),
        expect: () => [
          isA<AvatarUploadUploading>(),
          const AvatarUploadState.uploadSuccess(
            downloadUrl: 'https://example.com/avatar.jpg',
          ),
        ],
        verify: (_) {
          verify(() => mockImageStorageRepository.uploadAvatar(
                userId: testUser.uid,
                imageFile: any(named: 'imageFile'),
                onProgress: any(named: 'onProgress'),
              )).called(1);
          verify(() => mockAuthRepository.updateUserProfile(
                photoUrl: 'https://example.com/avatar.jpg',
              )).called(1);
          verify(() => mockAuthRepository.reloadUser()).called(1);
        },
      );

      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits uploadError when user is not authenticated',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
        },
        seed: () => AvatarUploadState.picked(imageFile: File('test_avatar.jpg')),
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.uploadRequested()),
        expect: () => [
          isA<AvatarUploadUploadError>().having(
            (state) => state.message,
            'message',
            'User not authenticated',
          ),
        ],
      );

      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [uploading, uploadError] when upload fails',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockImageStorageRepository.uploadAvatar(
                userId: any(named: 'userId'),
                imageFile: any(named: 'imageFile'),
                onProgress: any(named: 'onProgress'),
              )).thenThrow(Exception('Upload failed'));
        },
        seed: () => AvatarUploadState.picked(imageFile: File('test_avatar.jpg')),
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.uploadRequested()),
        expect: () => [
          isA<AvatarUploadUploading>(),
          isA<AvatarUploadUploadError>().having(
            (state) => state.message,
            'message',
            'Upload failed',
          ),
        ],
      );

      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'does not upload when no image is picked',
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.uploadRequested()),
        expect: () => [],
      );
    });

    group('AvatarUploadUploadCancelled', () {
      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits initial state when upload is cancelled',
        seed: () => AvatarUploadState.picked(imageFile: File('test_avatar.jpg')),
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.uploadCancelled()),
        expect: () => [
          const AvatarUploadState.initial(),
        ],
      );
    });

    group('AvatarUploadDeleteRequested', () {
      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [deleting, deleteSuccess] when deletion is successful',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockImageStorageRepository.deleteAvatar(
                userId: any(named: 'userId'),
              )).thenAnswer((_) async {});
          when(() => mockAuthRepository.updateUserProfile(
                photoUrl: null,
              )).thenAnswer((_) async {});
          when(() => mockAuthRepository.reloadUser()).thenAnswer((_) async {});
        },
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.deleteRequested()),
        expect: () => [
          const AvatarUploadState.deleting(),
          const AvatarUploadState.deleteSuccess(),
        ],
        verify: (_) {
          verify(() => mockImageStorageRepository.deleteAvatar(
                userId: testUser.uid,
              )).called(1);
          verify(() => mockAuthRepository.updateUserProfile(photoUrl: null))
              .called(1);
          verify(() => mockAuthRepository.reloadUser()).called(1);
        },
      );

      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits deleteError when user is not authenticated',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
        },
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.deleteRequested()),
        expect: () => [
          const AvatarUploadState.deleteError(
            message: 'User not authenticated',
          ),
        ],
      );

      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits [deleting, deleteError] when deletion fails',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);
          when(() => mockImageStorageRepository.deleteAvatar(
                userId: any(named: 'userId'),
              )).thenThrow(Exception('Delete failed'));
        },
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.deleteRequested()),
        expect: () => [
          const AvatarUploadState.deleting(),
          const AvatarUploadState.deleteError(
            message: 'Delete failed',
          ),
        ],
      );
    });

    group('AvatarUploadReset', () {
      blocTest<AvatarUploadBloc, AvatarUploadState>(
        'emits initial state when reset is triggered',
        seed: () => const AvatarUploadState.uploadSuccess(
          downloadUrl: 'https://example.com/avatar.jpg',
        ),
        build: createBloc,
        act: (bloc) => bloc.add(const AvatarUploadEvent.reset()),
        expect: () => [
          const AvatarUploadState.initial(),
        ],
      );
    });
  });
}

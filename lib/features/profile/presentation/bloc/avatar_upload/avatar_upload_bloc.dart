import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/image_storage_repository.dart';
import 'package:play_with_me/core/services/image_picker_service.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/avatar_upload/avatar_upload_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/avatar_upload/avatar_upload_state.dart';

/// BLoC for managing avatar upload with validation and state management
class AvatarUploadBloc extends Bloc<AvatarUploadEvent, AvatarUploadState> {
  final ImageStorageRepository _imageStorageRepository;
  final ImagePickerService _imagePickerService;
  final AuthRepository _authRepository;

  AvatarUploadBloc({
    required ImageStorageRepository imageStorageRepository,
    required ImagePickerService imagePickerService,
    required AuthRepository authRepository,
  })  : _imageStorageRepository = imageStorageRepository,
        _imagePickerService = imagePickerService,
        _authRepository = authRepository,
        super(const AvatarUploadState.initial()) {
    on<AvatarUploadStarted>(_onStarted);
    on<AvatarUploadImageSourceSelected>(_onImageSourceSelected);
    on<AvatarUploadImagePicked>(_onImagePicked);
    on<AvatarUploadUploadRequested>(_onUploadRequested);
    on<AvatarUploadUploadCancelled>(_onUploadCancelled);
    on<AvatarUploadDeleteRequested>(_onDeleteRequested);
    on<AvatarUploadReset>(_onReset);
  }

  /// Initialize the bloc
  void _onStarted(
    AvatarUploadStarted event,
    Emitter<AvatarUploadState> emit,
  ) {
    emit(const AvatarUploadState.initial());
  }

  /// Handle image source selection (camera or gallery)
  Future<void> _onImageSourceSelected(
    AvatarUploadImageSourceSelected event,
    Emitter<AvatarUploadState> emit,
  ) async {
    emit(const AvatarUploadState.picking());

    try {
      final imageFile = await _imagePickerService.pickImage(
        source: event.source,
        cropSquare: true,
      );

      if (imageFile == null) {
        // User cancelled picking
        emit(const AvatarUploadState.initial());
        return;
      }

      // Trigger validation
      add(AvatarUploadEvent.imagePicked(imageFile: imageFile));
    } catch (e) {
      emit(AvatarUploadState.validationError(
        message: 'Failed to pick image: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  /// Handle image picked event with validation
  void _onImagePicked(
    AvatarUploadImagePicked event,
    Emitter<AvatarUploadState> emit,
  ) {
    emit(AvatarUploadState.validating(imageFile: event.imageFile));

    // Validate file size (max 5MB)
    if (!_imagePickerService.validateFileSize(event.imageFile, maxSizeInMB: 5)) {
      emit(const AvatarUploadState.validationError(
        message: 'Image is too large. Please select an image smaller than 5MB.',
      ));
      return;
    }

    // Validate file extension
    if (!_imagePickerService.validateFileExtension(event.imageFile)) {
      emit(const AvatarUploadState.validationError(
        message: 'Invalid image format. Please select a JPG, PNG, or WebP image.',
      ));
      return;
    }

    // Image is valid, ready to upload
    emit(AvatarUploadState.picked(imageFile: event.imageFile));
  }

  /// Handle upload request
  Future<void> _onUploadRequested(
    AvatarUploadUploadRequested event,
    Emitter<AvatarUploadState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AvatarUploadPicked) {
      return; // No image to upload
    }

    final imageFile = currentState.imageFile;
    final currentUser = _authRepository.currentUser;

    if (currentUser == null) {
      emit(AvatarUploadState.uploadError(
        message: 'User not authenticated',
        imageFile: imageFile,
      ));
      return;
    }

    emit(AvatarUploadState.uploading(
      imageFile: imageFile,
      progress: 0.0,
    ));

    try {
      // Upload the image with progress tracking
      final downloadUrl = await _imageStorageRepository.uploadAvatar(
        userId: currentUser.uid,
        imageFile: imageFile,
        onProgress: (progress) {
          // Emit updated progress state
          if (!emit.isDone) {
            emit(AvatarUploadState.uploading(
              imageFile: imageFile,
              progress: progress,
            ));
          }
        },
      );

      // Update user profile with new photo URL
      await _authRepository.updateUserProfile(
        photoUrl: downloadUrl,
      );

      // Reload user data
      await _authRepository.reloadUser();

      emit(AvatarUploadState.uploadSuccess(downloadUrl: downloadUrl));
    } on ImageStorageException catch (e) {
      emit(AvatarUploadState.uploadError(
        message: e.message,
        imageFile: imageFile,
      ));
    } catch (e) {
      emit(AvatarUploadState.uploadError(
        message: e.toString().replaceAll('Exception: ', ''),
        imageFile: imageFile,
      ));
    }
  }

  /// Handle upload cancellation
  void _onUploadCancelled(
    AvatarUploadUploadCancelled event,
    Emitter<AvatarUploadState> emit,
  ) {
    emit(const AvatarUploadState.initial());
  }

  /// Handle delete request
  Future<void> _onDeleteRequested(
    AvatarUploadDeleteRequested event,
    Emitter<AvatarUploadState> emit,
  ) async {
    final currentUser = _authRepository.currentUser;

    if (currentUser == null) {
      emit(const AvatarUploadState.deleteError(
        message: 'User not authenticated',
      ));
      return;
    }

    emit(const AvatarUploadState.deleting());

    try {
      // Delete avatar from storage
      await _imageStorageRepository.deleteAvatar(userId: currentUser.uid);

      // Update user profile to remove photo URL
      await _authRepository.updateUserProfile(photoUrl: null);

      // Reload user data
      await _authRepository.reloadUser();

      emit(const AvatarUploadState.deleteSuccess());
    } on ImageStorageException catch (e) {
      emit(AvatarUploadState.deleteError(
        message: e.message,
      ));
    } catch (e) {
      emit(AvatarUploadState.deleteError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Handle reset
  void _onReset(
    AvatarUploadReset event,
    Emitter<AvatarUploadState> emit,
  ) {
    emit(const AvatarUploadState.initial());
  }
}

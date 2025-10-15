import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'avatar_upload_state.freezed.dart';

@freezed
class AvatarUploadState with _$AvatarUploadState {
  /// Initial state
  const factory AvatarUploadState.initial() = AvatarUploadInitial;

  /// State when picking an image
  const factory AvatarUploadState.picking() = AvatarUploadPicking;

  /// State when an image has been picked and is ready to upload
  const factory AvatarUploadState.picked({
    required File imageFile,
  }) = AvatarUploadPicked;

  /// State when validating the picked image
  const factory AvatarUploadState.validating({
    required File imageFile,
  }) = AvatarUploadValidating;

  /// State when validation fails
  const factory AvatarUploadState.validationError({
    required String message,
  }) = AvatarUploadValidationError;

  /// State when uploading the image
  const factory AvatarUploadState.uploading({
    required File imageFile,
    @Default(0.0) double progress,
  }) = AvatarUploadUploading;

  /// State when upload is successful
  const factory AvatarUploadState.uploadSuccess({
    required String downloadUrl,
  }) = AvatarUploadUploadSuccess;

  /// State when upload fails
  const factory AvatarUploadState.uploadError({
    required String message,
    File? imageFile,
  }) = AvatarUploadUploadError;

  /// State when deleting the current avatar
  const factory AvatarUploadState.deleting() = AvatarUploadDeleting;

  /// State when deletion is successful
  const factory AvatarUploadState.deleteSuccess() = AvatarUploadDeleteSuccess;

  /// State when deletion fails
  const factory AvatarUploadState.deleteError({
    required String message,
  }) = AvatarUploadDeleteError;
}

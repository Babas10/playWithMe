import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'avatar_upload_event.freezed.dart';

@freezed
class AvatarUploadEvent with _$AvatarUploadEvent {
  /// Event to initialize the avatar upload bloc
  const factory AvatarUploadEvent.started() = AvatarUploadStarted;

  /// Event to pick an image from the specified source
  const factory AvatarUploadEvent.imageSourceSelected({
    required ImageSource source,
  }) = AvatarUploadImageSourceSelected;

  /// Event when an image has been picked successfully
  const factory AvatarUploadEvent.imagePicked({
    required File imageFile,
  }) = AvatarUploadImagePicked;

  /// Event to upload the selected image
  const factory AvatarUploadEvent.uploadRequested() = AvatarUploadUploadRequested;

  /// Event to cancel the upload
  const factory AvatarUploadEvent.uploadCancelled() = AvatarUploadUploadCancelled;

  /// Event to delete the current avatar
  const factory AvatarUploadEvent.deleteRequested() = AvatarUploadDeleteRequested;

  /// Event to reset the upload state
  const factory AvatarUploadEvent.reset() = AvatarUploadReset;
}

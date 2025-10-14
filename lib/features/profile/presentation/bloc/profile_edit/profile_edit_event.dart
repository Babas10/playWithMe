import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_edit_event.freezed.dart';

@freezed
class ProfileEditEvent with _$ProfileEditEvent {
  /// Event to initialize the profile edit form with current user data
  const factory ProfileEditEvent.started({
    required String currentDisplayName,
    String? currentPhotoUrl,
  }) = ProfileEditStarted;

  /// Event when the display name field changes
  const factory ProfileEditEvent.displayNameChanged(String displayName) =
      ProfileEditDisplayNameChanged;

  /// Event when the photo URL field changes
  const factory ProfileEditEvent.photoUrlChanged(String photoUrl) =
      ProfileEditPhotoUrlChanged;

  /// Event to save the profile changes
  const factory ProfileEditEvent.saveRequested() = ProfileEditSaveRequested;

  /// Event to cancel editing and return to profile view
  const factory ProfileEditEvent.cancelled() = ProfileEditCancelled;
}

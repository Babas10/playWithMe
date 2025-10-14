import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_edit_state.freezed.dart';

@freezed
class ProfileEditState with _$ProfileEditState {
  /// Initial state before form is loaded
  const factory ProfileEditState.initial() = ProfileEditInitial;

  /// State when form is being loaded with current user data
  const factory ProfileEditState.loading() = ProfileEditLoading;

  /// State when form is loaded and ready for editing
  const factory ProfileEditState.loaded({
    required String displayName,
    String? photoUrl,
    String? displayNameError,
    String? photoUrlError,
    @Default(false) bool hasUnsavedChanges,
  }) = ProfileEditLoaded;

  /// State when profile changes are being saved
  const factory ProfileEditState.saving({
    required String displayName,
    String? photoUrl,
  }) = ProfileEditSaving;

  /// State when profile changes are successfully saved
  const factory ProfileEditState.success() = ProfileEditSuccess;

  /// State when an error occurs during saving
  const factory ProfileEditState.error({
    required String message,
    required String displayName,
    String? photoUrl,
  }) = ProfileEditError;
}

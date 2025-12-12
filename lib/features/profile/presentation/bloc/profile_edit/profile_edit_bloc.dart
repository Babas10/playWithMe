import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_state.dart';

/// BLoC for managing profile editing with validation and state management
class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  // Store original values to detect changes
  String _originalDisplayName = '';
  String? _originalPhotoUrl;

  // Current form values
  String _currentDisplayName = '';
  String? _currentPhotoUrl;

  ProfileEditBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(const ProfileEditState.initial()) {
    on<ProfileEditStarted>(_onStarted);
    on<ProfileEditDisplayNameChanged>(_onDisplayNameChanged);
    on<ProfileEditPhotoUrlChanged>(_onPhotoUrlChanged);
    on<ProfileEditSaveRequested>(_onSaveRequested);
    on<ProfileEditCancelled>(_onCancelled);
  }

  /// Initialize the form with current user data
  Future<void> _onStarted(
    ProfileEditStarted event,
    Emitter<ProfileEditState> emit,
  ) async {
    emit(const ProfileEditState.loading());

    // Store original values
    _originalDisplayName = event.currentDisplayName;
    _originalPhotoUrl = event.currentPhotoUrl;

    // Initialize current values
    _currentDisplayName = event.currentDisplayName;
    _currentPhotoUrl = event.currentPhotoUrl;

    emit(ProfileEditState.loaded(
      displayName: _currentDisplayName,
      photoUrl: _currentPhotoUrl,
      hasUnsavedChanges: false,
    ));
  }

  /// Handle display name changes with validation
  void _onDisplayNameChanged(
    ProfileEditDisplayNameChanged event,
    Emitter<ProfileEditState> emit,
  ) {
    _currentDisplayName = event.displayName;
    final error = _validateDisplayName(event.displayName);
    final hasChanges = _hasUnsavedChanges();

    emit(ProfileEditState.loaded(
      displayName: _currentDisplayName,
      photoUrl: _currentPhotoUrl,
      displayNameError: error,
      hasUnsavedChanges: hasChanges,
    ));
  }

  /// Handle photo URL changes with validation
  void _onPhotoUrlChanged(
    ProfileEditPhotoUrlChanged event,
    Emitter<ProfileEditState> emit,
  ) {
    _currentPhotoUrl = event.photoUrl.trim().isEmpty ? null : event.photoUrl.trim();
    final error = _validatePhotoUrl(_currentPhotoUrl);
    final hasChanges = _hasUnsavedChanges();

    emit(ProfileEditState.loaded(
      displayName: _currentDisplayName,
      photoUrl: _currentPhotoUrl,
      photoUrlError: error,
      hasUnsavedChanges: hasChanges,
    ));
  }

  /// Save the profile changes
  Future<void> _onSaveRequested(
    ProfileEditSaveRequested event,
    Emitter<ProfileEditState> emit,
  ) async {
    // Validate all fields before saving
    final displayNameError = _validateDisplayName(_currentDisplayName);
    final photoUrlError = _validatePhotoUrl(_currentPhotoUrl);

    if (displayNameError != null || photoUrlError != null) {
      emit(ProfileEditState.loaded(
        displayName: _currentDisplayName,
        photoUrl: _currentPhotoUrl,
        displayNameError: displayNameError,
        photoUrlError: photoUrlError,
        hasUnsavedChanges: true,
      ));
      return;
    }

    // Check if there are actually changes to save
    if (!_hasUnsavedChanges()) {
      emit(const ProfileEditState.success());
      return;
    }

    emit(ProfileEditState.saving(
      displayName: _currentDisplayName,
      photoUrl: _currentPhotoUrl,
    ));

    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        throw Exception('No user found');
      }

      // Update Firestore (source of truth)
      await _userRepository.updateUserProfile(
        user.uid,
        displayName: _currentDisplayName,
        photoUrl: _currentPhotoUrl,
      );

      // Also update Auth profile to keep them in sync
      await _authRepository.updateUserProfile(
        displayName: _currentDisplayName,
        photoUrl: _currentPhotoUrl,
      );

      // Reload user to get updated data
      await _authRepository.reloadUser();

      emit(const ProfileEditState.success());
    } catch (e) {
      emit(ProfileEditState.error(
        message: e.toString().replaceAll('Exception: ', ''),
        displayName: _currentDisplayName,
        photoUrl: _currentPhotoUrl,
      ));
    }
  }

  /// Handle cancellation
  void _onCancelled(
    ProfileEditCancelled event,
    Emitter<ProfileEditState> emit,
  ) {
    // Simply emit success to trigger navigation back
    emit(const ProfileEditState.success());
  }

  /// Validate display name
  /// Returns error message if invalid, null if valid
  String? _validateDisplayName(String displayName) {
    final trimmed = displayName.trim();

    if (trimmed.isEmpty) {
      return 'Display name cannot be empty';
    }

    if (trimmed.length < 3) {
      return 'Display name must be at least 3 characters';
    }

    if (trimmed.length > 50) {
      return 'Display name must be less than 50 characters';
    }

    // Check for valid characters (letters, numbers, spaces, basic punctuation)
    final validCharacters = RegExp(r'^[a-zA-Z0-9 ._-]+$');
    if (!validCharacters.hasMatch(trimmed)) {
      return 'Display name contains invalid characters';
    }

    return null;
  }

  /// Validate photo URL
  /// Returns error message if invalid, null if valid
  String? _validatePhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.trim().isEmpty) {
      return null; // Photo URL is optional
    }

    final trimmed = photoUrl.trim();

    // Basic URL validation - must start with http:// or https://
    final urlPattern = RegExp(
      r'^https?:\/\/',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(trimmed)) {
      return 'URL must start with http:// or https://';
    }

    // Must have at least some content after the protocol
    if (trimmed.length < 12) { // "https://a.co" is minimum
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Check if there are unsaved changes
  bool _hasUnsavedChanges() {
    return _currentDisplayName != _originalDisplayName ||
        _currentPhotoUrl != _originalPhotoUrl;
  }
}

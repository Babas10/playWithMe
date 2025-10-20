import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_state.dart';

/// BLoC for managing locale and regional preferences
class LocalePreferencesBloc
    extends Bloc<LocalePreferencesEvent, LocalePreferencesState> {
  final LocalePreferencesRepository _repository;

  // Store original values to detect changes
  LocalePreferencesEntity? _originalPreferences;

  // Current form values
  LocalePreferencesEntity? _currentPreferences;

  LocalePreferencesBloc({
    required LocalePreferencesRepository repository,
  })  : _repository = repository,
        super(const LocalePreferencesState.initial()) {
    on<LoadPreferences>(_onLoadPreferences);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateCountry>(_onUpdateCountry);
    on<SavePreferences>(_onSavePreferences);
    on<LoadFromFirestore>(_onLoadFromFirestore);
  }

  /// Load preferences from local storage
  Future<void> _onLoadPreferences(
    LoadPreferences event,
    Emitter<LocalePreferencesState> emit,
  ) async {
    emit(const LocalePreferencesState.loading());

    try {
      final preferences = await _repository.loadPreferences();

      // Update timezone to current device timezone
      final timeZone = _repository.getDeviceTimeZone();
      final updatedPreferences = LocalePreferencesEntity(
        locale: preferences.locale,
        country: preferences.country,
        timeZone: timeZone,
        lastSyncedAt: preferences.lastSyncedAt,
      );

      _originalPreferences = updatedPreferences;
      _currentPreferences = updatedPreferences;

      emit(LocalePreferencesState.loaded(
        preferences: updatedPreferences,
        hasUnsavedChanges: false,
      ));
    } catch (e) {
      emit(LocalePreferencesState.error(
        message: 'Failed to load preferences: $e',
      ));
    }
  }

  /// Update the selected language
  void _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<LocalePreferencesState> emit,
  ) {
    if (_currentPreferences == null) return;

    _currentPreferences = LocalePreferencesEntity(
      locale: event.locale,
      country: _currentPreferences!.country,
      timeZone: _currentPreferences!.timeZone,
      lastSyncedAt: _currentPreferences!.lastSyncedAt,
    );

    final hasChanges = _hasUnsavedChanges();

    emit(LocalePreferencesState.loaded(
      preferences: _currentPreferences!,
      hasUnsavedChanges: hasChanges,
    ));
  }

  /// Update the selected country
  void _onUpdateCountry(
    UpdateCountry event,
    Emitter<LocalePreferencesState> emit,
  ) {
    if (_currentPreferences == null) return;

    _currentPreferences = LocalePreferencesEntity(
      locale: _currentPreferences!.locale,
      country: event.country,
      timeZone: _currentPreferences!.timeZone,
      lastSyncedAt: _currentPreferences!.lastSyncedAt,
    );

    final hasChanges = _hasUnsavedChanges();

    emit(LocalePreferencesState.loaded(
      preferences: _currentPreferences!,
      hasUnsavedChanges: hasChanges,
    ));
  }

  /// Save preferences to local storage and Firestore
  Future<void> _onSavePreferences(
    SavePreferences event,
    Emitter<LocalePreferencesState> emit,
  ) async {
    if (_currentPreferences == null) return;

    // Check if there are actually changes to save
    if (!_hasUnsavedChanges()) {
      emit(const LocalePreferencesState.saved());
      return;
    }

    emit(LocalePreferencesState.saving(
      preferences: _currentPreferences!,
    ));

    try {
      // Update timezone before saving
      final timeZone = _repository.getDeviceTimeZone();
      final preferencesToSave = LocalePreferencesEntity(
        locale: _currentPreferences!.locale,
        country: _currentPreferences!.country,
        timeZone: timeZone,
        lastSyncedAt: DateTime.now(),
      );

      // Save to local storage
      await _repository.savePreferences(preferencesToSave);

      // Sync to Firestore
      await _repository.syncToFirestore(event.userId, preferencesToSave);

      // Update original preferences to the saved values
      _originalPreferences = preferencesToSave;
      _currentPreferences = preferencesToSave;

      // First emit saved state for listeners (shows success message)
      emit(const LocalePreferencesState.saved());

      // Then immediately emit loaded state so the app updates the locale
      emit(LocalePreferencesState.loaded(
        preferences: preferencesToSave,
        hasUnsavedChanges: false,
      ));
    } catch (e) {
      emit(LocalePreferencesState.error(
        message: 'Failed to save preferences: $e',
        preferences: _currentPreferences,
      ));
    }
  }

  /// Load preferences from Firestore
  Future<void> _onLoadFromFirestore(
    LoadFromFirestore event,
    Emitter<LocalePreferencesState> emit,
  ) async {
    emit(const LocalePreferencesState.loading());

    try {
      final preferences = await _repository.loadFromFirestore(event.userId);

      if (preferences != null) {
        // Update timezone to current device timezone
        final timeZone = _repository.getDeviceTimeZone();
        final updatedPreferences = LocalePreferencesEntity(
          locale: preferences.locale,
          country: preferences.country,
          timeZone: timeZone,
          lastSyncedAt: preferences.lastSyncedAt,
        );

        _originalPreferences = updatedPreferences;
        _currentPreferences = updatedPreferences;

        emit(LocalePreferencesState.loaded(
          preferences: updatedPreferences,
          hasUnsavedChanges: false,
        ));
      } else {
        // No Firestore preferences, load from local
        add(const LocalePreferencesEvent.loadPreferences());
      }
    } catch (e) {
      emit(LocalePreferencesState.error(
        message: 'Failed to load preferences from Firestore: $e',
      ));
    }
  }

  /// Check if there are unsaved changes
  bool _hasUnsavedChanges() {
    if (_originalPreferences == null || _currentPreferences == null) {
      return false;
    }

    return _currentPreferences!.locale != _originalPreferences!.locale ||
        _currentPreferences!.country != _originalPreferences!.country;
  }
}

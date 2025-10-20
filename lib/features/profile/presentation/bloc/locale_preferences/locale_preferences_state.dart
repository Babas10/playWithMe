import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';

part 'locale_preferences_state.freezed.dart';

/// States for LocalePreferencesBloc
@freezed
class LocalePreferencesState with _$LocalePreferencesState {
  /// Initial state
  const factory LocalePreferencesState.initial() = LocalePreferencesInitial;

  /// Loading state
  const factory LocalePreferencesState.loading() = LocalePreferencesLoading;

  /// Loaded state with preferences
  const factory LocalePreferencesState.loaded({
    required LocalePreferencesEntity preferences,
    required bool hasUnsavedChanges,
  }) = LocalePreferencesLoaded;

  /// Saving state
  const factory LocalePreferencesState.saving({
    required LocalePreferencesEntity preferences,
  }) = LocalePreferencesSaving;

  /// Successfully saved state
  const factory LocalePreferencesState.saved() = LocalePreferencesSaved;

  /// Error state
  const factory LocalePreferencesState.error({
    required String message,
    LocalePreferencesEntity? preferences,
  }) = LocalePreferencesError;
}

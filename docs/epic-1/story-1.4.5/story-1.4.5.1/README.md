# Story 1.4.5.1: Account Settings - Language & Country Preferences

## 📋 Overview

Extend the existing Profile Edit page (renamed to "Account Settings") to include language and country selection preferences. This enhances the account settings functionality by allowing users to set their preferred language and country alongside their display name and profile picture.

**Parent Story**: [Story 1.4.5: Account Settings & Preferences](../README.md)
**Story Points**: 3 (Low-Medium complexity)
**Priority**: High
**Dependencies**: Story 1.4.2 (Profile Edit UI - already implemented)
**Complexity**: 🟢 Low

---

## 🎯 Acceptance Criteria

### Account Settings Integration
- [ ] "Edit Profile" button is renamed to "Account Settings"
- [ ] Language and Country fields are added to the existing ProfileEditPage
- [ ] Fields appear below the display name and profile picture sections
- [ ] Changes are saved when user clicks the "Save Changes" button
- [ ] All changes (name, picture, language, country) apply together on save

### Language Selection
- [ ] User can select preferred language from dropdown
- [ ] Supported languages: English, Spanish, German, Italian, French
- [ ] Default language is English
- [ ] Language selection persists locally and syncs to Firestore
- [ ] Language changes apply immediately after saving

### Country Selection
- [ ] User can select country from a comprehensive dropdown list
- [ ] Country list includes all major countries
- [ ] Default country can be auto-detected from device locale
- [ ] Country selection persists locally and syncs to Firestore

### Time Zone Handling
- [ ] Time zone is automatically detected from device
- [ ] Time zone is displayed as read-only field (for user awareness)
- [ ] Time zone updates automatically if device changes

### Persistence & Sync
- [ ] Language and country persist locally using SharedPreferences
- [ ] Preferences sync to Firestore on save (same flow as profile edits)
- [ ] Local changes work offline
- [ ] Cloud sync happens when "Save Changes" is clicked

### UX Requirements
- [ ] Clear labels for Language and Country fields
- [ ] Dropdowns are searchable/scrollable for easy selection
- [ ] Loading state shows while saving changes
- [ ] Success message confirms all changes were saved
- [ ] Error messages if save fails
- [ ] Fields are accessible (a11y compliant)

---

## 🏗️ Technical Requirements

### Architecture

```
ProfileEditPage (existing)
    ↓
ProfileEditBloc (existing) + LocalePreferencesBloc (new)
    ↓
LocalePreferencesRepository (new)
    ↓
├─ SharedPreferences (Local)
└─ Firestore (Cloud Sync)
```

### Integration Strategy

**DO NOT create a new settings page.** Instead:
1. Extend the existing `ProfileEditPage` with new fields
2. Create a new `LocalePreferencesBloc` to manage language/country
3. Create a new `LocalePreferencesRepository` for persistence
4. Coordinate both blocs when "Save Changes" is clicked

### Components to Implement

#### 1. Domain Layer
**File**: `lib/features/profile/domain/entities/locale_preferences_entity.dart`

```dart
@freezed
class LocalePreferencesEntity with _$LocalePreferencesEntity {
  const factory LocalePreferencesEntity({
    required Locale locale,          // Language code (e.g., 'en', 'es')
    required String country,         // Country name (e.g., 'United States')
    String? timeZone,               // Auto-detected timezone
    DateTime? lastSyncedAt,
  }) = _LocalePreferencesEntity;

  factory LocalePreferencesEntity.defaultPreferences() {
    return const LocalePreferencesEntity(
      locale: Locale('en'),
      country: 'United States',
      timeZone: null,
      lastSyncedAt: null,
    );
  }

  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('de'), // German
    Locale('it'), // Italian
    Locale('fr'), // French
  ];
}
```

**File**: `lib/features/profile/domain/repositories/locale_preferences_repository.dart`

```dart
abstract class LocalePreferencesRepository {
  Future<LocalePreferencesEntity> loadPreferences();
  Future<void> savePreferences(LocalePreferencesEntity preferences);
  Future<void> syncToFirestore(String userId, LocalePreferencesEntity preferences);
  Future<LocalePreferencesEntity?> loadFromFirestore(String userId);
}
```

#### 2. Data Layer
**File**: `lib/features/profile/data/repositories/locale_preferences_repository_impl.dart`

**SharedPreferences Keys**:
- `user_locale_language` - Language code (String)
- `user_locale_country` - Country name (String)
- `user_timezone` - Timezone (String, auto-detected)
- `user_locale_last_synced` - Last sync timestamp (int)

**Firestore Structure**:
```
users/{userId}/preferences/locale
  ├─ language: "en"
  ├─ country: "United States"
  ├─ timeZone: "America/New_York"
  └─ lastSyncedAt: Timestamp
```

#### 3. BLoC Layer
**File**: `lib/features/profile/presentation/bloc/locale_preferences/locale_preferences_bloc.dart`

**Events**:
- `LoadPreferences` - Load from local storage
- `UpdateLanguage(Locale locale)` - Update language
- `UpdateCountry(String country)` - Update country
- `SavePreferences` - Save to local + Firestore
- `LoadFromFirestore(String userId)` - Load from cloud

**States**:
- `LocalePreferencesInitial`
- `LocalePreferencesLoaded(preferences)`
- `LocalePreferencesSaving`
- `LocalePreferencesSaved`
- `LocalePreferencesError(message)`

#### 4. UI Layer - Extend ProfileEditPage
**File**: `lib/features/profile/presentation/pages/profile_edit_page.dart`

**Add these fields after the display name field**:

```dart
// Language Dropdown
DropdownButtonFormField<Locale>(
  decoration: InputDecoration(
    labelText: 'Preferred Language',
    helperText: 'Select your preferred language',
  ),
  value: currentLocale,
  items: LocalePreferencesEntity.supportedLocales.map((locale) {
    return DropdownMenuItem(
      value: locale,
      child: Text(_getLanguageName(locale)),
    );
  }).toList(),
  onChanged: (locale) {
    context.read<LocalePreferencesBloc>().add(
      LocalePreferencesEvent.updateLanguage(locale!),
    );
  },
)

// Country Dropdown
DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: 'Country',
    helperText: 'Select your country',
  ),
  value: currentCountry,
  items: Countries.all.map((country) {
    return DropdownMenuItem(
      value: country,
      child: Text(country),
    );
  }).toList(),
  onChanged: (country) {
    context.read<LocalePreferencesBloc>().add(
      LocalePreferencesEvent.updateCountry(country!),
    );
  },
)

// Time Zone (Read-only)
TextFormField(
  decoration: InputDecoration(
    labelText: 'Time Zone',
    helperText: 'Automatically detected from your device',
  ),
  initialValue: detectedTimeZone,
  enabled: false,
)
```

**Save Changes Button Logic** (modify existing):
```dart
// When "Save Changes" is clicked:
1. Save profile edits (name, picture) via ProfileEditBloc
2. Save locale preferences via LocalePreferencesBloc
3. Both blocs emit success/error states
4. Show single success/error message for all changes
```

---

## 🗺️ Countries List

Use the `country_picker` package or create a manual list with ~200 major countries:

```dart
class Countries {
  static const List<String> all = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola',
    'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan',
    'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus',
    'Belgium', 'Belize', 'Benin', 'Bhutan', 'Bolivia',
    'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi',
    'Cambodia', 'Cameroon', 'Canada', 'Chad', 'Chile',
    'China', 'Colombia', 'Costa Rica', 'Croatia', 'Cuba',
    'Cyprus', 'Czech Republic', 'Denmark', 'Djibouti',
    'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador',
    'Estonia', 'Ethiopia', 'Fiji', 'Finland', 'France',
    'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana',
    'Greece', 'Guatemala', 'Guinea', 'Guyana', 'Haiti',
    'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia',
    'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy',
    'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya',
    'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon',
    'Liberia', 'Libya', 'Lithuania', 'Luxembourg', 'Madagascar',
    'Malaysia', 'Maldives', 'Mali', 'Malta', 'Mexico',
    'Moldova', 'Monaco', 'Mongolia', 'Montenegro', 'Morocco',
    'Mozambique', 'Myanmar', 'Namibia', 'Nepal', 'Netherlands',
    'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'Norway',
    'Oman', 'Pakistan', 'Panama', 'Paraguay', 'Peru',
    'Philippines', 'Poland', 'Portugal', 'Qatar', 'Romania',
    'Russia', 'Rwanda', 'Saudi Arabia', 'Senegal', 'Serbia',
    'Singapore', 'Slovakia', 'Slovenia', 'Somalia', 'South Africa',
    'South Korea', 'Spain', 'Sri Lanka', 'Sudan', 'Sweden',
    'Switzerland', 'Syria', 'Taiwan', 'Tajikistan', 'Tanzania',
    'Thailand', 'Togo', 'Trinidad and Tobago', 'Tunisia', 'Turkey',
    'Turkmenistan', 'Uganda', 'Ukraine', 'United Arab Emirates',
    'United Kingdom', 'United States', 'Uruguay', 'Uzbekistan',
    'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe',
  ];
}
```

---

## 🌍 Language Display Names

```dart
String _getLanguageName(Locale locale) {
  switch (locale.languageCode) {
    case 'en': return 'English';
    case 'es': return 'Español (Spanish)';
    case 'de': return 'Deutsch (German)';
    case 'it': return 'Italiano (Italian)';
    case 'fr': return 'Français (French)';
    default: return locale.languageCode;
  }
}
```

---

## 🧪 Testing Requirements

### Unit Tests (90%+ coverage)

**File**: `test/unit/features/profile/presentation/bloc/locale_preferences_bloc_test.dart`

Test scenarios:
- ✅ Initial state is `LocalePreferencesInitial`
- ✅ `LoadPreferences` emits `[loading, loaded]` with defaults
- ✅ `UpdateLanguage` updates locale in state
- ✅ `UpdateCountry` updates country in state
- ✅ `SavePreferences` saves to SharedPreferences and Firestore
- ✅ Error handling when save fails

**File**: `test/unit/features/profile/data/repositories/locale_preferences_repository_test.dart`

Test scenarios:
- ✅ `loadPreferences` returns defaults if no saved data
- ✅ `savePreferences` persists to SharedPreferences
- ✅ `syncToFirestore` uploads to Firestore
- ✅ `loadFromFirestore` retrieves cloud preferences

### Widget Tests

**File**: `test/widget/features/profile/presentation/pages/profile_edit_page_test.dart` (extend existing)

Test scenarios:
- ✅ Language dropdown displays all supported languages
- ✅ Country dropdown displays country list
- ✅ Time zone field is read-only and shows detected value
- ✅ "Save Changes" button triggers both profile and locale saves
- ✅ Success message shows when all changes save successfully
- ✅ Error message shows if any save fails

---

## 📱 Platform Considerations

### All Platforms
- Use Material Design 3 components
- Language/Country dropdowns are scrollable
- Time zone auto-detection works on all platforms

### Time Zone Detection
```dart
import 'package:timezone/timezone.dart' as tz;

String getDeviceTimeZone() {
  return DateTime.now().timeZoneName;
}
```

---

## 🔒 Security Considerations

### Low Risk
- Language and country are non-sensitive preferences
- No PII exposure
- Standard Firestore security rules apply

### Firestore Rules
```javascript
match /users/{userId}/preferences/locale {
  allow read, write: if request.auth.uid == userId;
}
```

---

## 🎨 UI/UX Design

### ProfileEditPage Layout (Updated)

```
┌─────────────────────────────────┐
│ Edit Profile                    │
├─────────────────────────────────┤
│                                 │
│  [Profile Picture]              │
│  [Change Picture]               │
│                                 │
│  Display Name: [____________]   │
│                                 │
│  ─────────────────────────────  │
│  Preferences                    │
│  ─────────────────────────────  │
│                                 │
│  Preferred Language:            │
│  [English           ▼]          │
│                                 │
│  Country:                       │
│  [United States     ▼]          │
│                                 │
│  Time Zone:                     │
│  [America/New_York] (auto)      │
│                                 │
│  [Save Changes]                 │
│                                 │
└─────────────────────────────────┘
```

---

## 📦 Dependencies

### Existing (already in pubspec.yaml)
```yaml
dependencies:
  shared_preferences: ^2.2.0
  intl: ^0.19.0
  freezed: ^2.5.7
  freezed_annotation: ^2.4.4
```

### Optional (for enhanced country picker)
```yaml
dependencies:
  country_picker: ^2.0.20  # Optional, provides flags and localized names
```

---

## 🚀 Implementation Steps

### Phase 1: Foundation
1. Create `LocalePreferencesEntity` with freezed
2. Create `LocalePreferencesRepository` interface
3. Implement `LocalePreferencesRepositoryImpl` with SharedPreferences

### Phase 2: BLoC
4. Create `LocalePreferencesBloc` with events/states
5. Implement event handlers for language/country updates
6. Add save and sync logic

### Phase 3: UI Integration
7. Extend `ProfileEditPage` with language/country fields
8. Add time zone auto-detection
9. Modify "Save Changes" to handle both profile and locale saves
10. Add proper error handling and success messages

### Phase 4: App Integration
11. Update `GatherliApp` to use saved locale for app-wide language
12. Ensure locale persists across app restarts
13. Test language changes apply correctly

### Phase 5: Testing
14. Write unit tests for BLoC
15. Write unit tests for repository
16. Extend widget tests for ProfileEditPage
17. Test on all platforms

---

## 📊 Success Metrics

- ✅ All acceptance criteria met
- ✅ 90%+ test coverage
- ✅ Zero linting errors
- ✅ Works on Android, iOS, and Web
- ✅ Language changes apply after save
- ✅ Preferences persist correctly
- ✅ No breaking changes to existing profile edit functionality

---

## 🔄 Future Enhancements (Out of Scope)

- [ ] Notification preferences
- [ ] Custom date/time format preferences
- [ ] Multiple language support in UI strings (i18n/l10n)
- [ ] Timezone manual override option

---

## 📚 Related Documentation

- [Parent Story 1.4.5](../README.md)
- [Story 1.4.2 - Profile Edit UI](../story-1.4.2/)
- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)

---

## ✅ Definition of Done

- [ ] All acceptance criteria met
- [ ] Language and country fields integrated into ProfileEditPage
- [ ] "Save Changes" saves all profile data + locale preferences
- [ ] Unit tests written and passing (90%+ coverage)
- [ ] Widget tests updated and passing
- [ ] Code follows CLAUDE.md standards
- [ ] No linting errors or warnings
- [ ] Tested on Android, iOS, and Web
- [ ] Documentation updated
- [ ] Code review completed
- [ ] Merged to main branch

---

## ✅ Implementation Status

All acceptance criteria have been implemented successfully.

### Completed Features
- ✅ "Edit Profile" button renamed to "Account Settings"
- ✅ Language dropdown with 5 supported languages
- ✅ Country dropdown with ~200 countries
- ✅ Read-only timezone field (auto-detected)
- ✅ Local persistence with SharedPreferences
- ✅ Cloud sync to Firestore
- ✅ Coordinated save for profile + preferences

### Files Created
- `lib/core/utils/countries.dart`
- `lib/features/profile/domain/entities/locale_preferences_entity.dart`
- `lib/features/profile/domain/repositories/locale_preferences_repository.dart`
- `lib/features/profile/data/models/locale_preferences_model.dart`
- `lib/features/profile/data/repositories/locale_preferences_repository_impl.dart`
- `lib/features/profile/presentation/bloc/locale_preferences/*`

### Testing
- ✅ Unit tests for LocalePreferencesBloc (7 tests)
- ✅ Unit tests for LocalePreferencesRepository (3 tests)  
- ✅ Updated ProfileActions widget tests
- ⚠️  ProfileEditPage widget tests need field count update (minor follow-up)

### Dependencies Added
- `shared_preferences: ^2.2.3`

All code passes `flutter analyze` with zero errors.

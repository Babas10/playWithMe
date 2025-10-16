# Story 1.4.5.1: Account Preferences

## 📋 Overview

Implement user personalization settings for non-security preferences such as theme, language, and notifications. This is the foundational substory of the Account Settings feature, focusing on local storage and immediate UI feedback.

**Parent Story**: [Story 1.4.5: Account Settings & Preferences](../README.md)
**Story Points**: 5 (Medium complexity)
**Priority**: High
**Dependencies**: None
**Complexity**: 🟢 Low

---

## 🎯 Acceptance Criteria

### Theme Settings
- [ ] User can toggle between Light / Dark / System theme
- [ ] Theme change applies immediately to entire app
- [ ] Selected theme persists across app restarts
- [ ] System theme respects device dark mode setting

### Language & Localization
- [ ] User can select preferred language from supported list
- [ ] User can choose region/country
- [ ] User can set time zone (defaults to device time zone)
- [ ] Language changes apply immediately where possible
- [ ] Locale preferences persist and sync

### Notification Preferences
- [ ] User can toggle email notifications on/off
- [ ] User can toggle push notifications on/off
- [ ] User can toggle in-app notifications on/off
- [ ] Each notification type has clear description
- [ ] Changes take effect immediately

### Persistence & Sync
- [ ] All preferences persist locally using SharedPreferences
- [ ] Preferences optionally sync to cloud on next login
- [ ] Local changes work offline
- [ ] Cloud sync happens in background without blocking UI

### UX Requirements
- [ ] Immediate visual feedback for all changes
- [ ] Clear labels and descriptions for each setting
- [ ] Settings screen is accessible (a11y compliant)
- [ ] Loading states for sync operations
- [ ] Error messages if sync fails

---

## 🏗️ Technical Requirements

### Architecture

```
UI Layer (Widgets)
    ↓
AccountPreferencesBloc
    ↓
AccountPreferencesRepository
    ↓
├─ SharedPreferences (Local)
└─ UserRepository (Optional Cloud Sync)
```

### Components to Implement

#### 1. BLoC Layer
**File**: `lib/features/profile/presentation/bloc/account_preferences/account_preferences_bloc.dart`

```dart
class AccountPreferencesBloc extends Bloc<AccountPreferencesEvent, AccountPreferencesState> {
  final AccountPreferencesRepository _preferencesRepository;
  final UserRepository? _userRepository; // Optional cloud sync

  // Events:
  // - LoadPreferences
  // - UpdateTheme(ThemeMode)
  // - UpdateLanguage(Locale)
  // - UpdateNotificationPreference(NotificationType, bool)
  // - SyncToCloud
}
```

**States**:
- `AccountPreferencesInitial`
- `AccountPreferencesLoaded(preferences)`
- `AccountPreferencesUpdating`
- `AccountPreferencesError(message)`
- `AccountPreferencesSyncing`
- `AccountPreferencesSynced`

#### 2. Repository Layer
**File**: `lib/features/profile/data/repositories/account_preferences_repository.dart`

```dart
abstract class AccountPreferencesRepository {
  Future<AccountPreferencesEntity> loadPreferences();
  Future<void> saveTheme(ThemeMode theme);
  Future<void> saveLanguage(Locale locale);
  Future<void> saveNotificationPreference(NotificationType type, bool enabled);
  Stream<AccountPreferencesEntity> watchPreferences();
}
```

**Implementation**: `AccountPreferencesRepositoryImpl`
- Uses `SharedPreferences` for local storage
- Keys: `user_theme`, `user_locale`, `notif_email`, `notif_push`, `notif_inapp`

#### 3. Domain Layer
**File**: `lib/features/profile/domain/entities/account_preferences_entity.dart`

```dart
@freezed
class AccountPreferencesEntity with _$AccountPreferencesEntity {
  const factory AccountPreferencesEntity({
    required ThemeMode theme,
    required Locale locale,
    required String? timeZone,
    required Map<NotificationType, bool> notificationPreferences,
    DateTime? lastSyncedAt,
  }) = _AccountPreferencesEntity;
}

enum NotificationType { email, push, inApp }
```

#### 4. UI Layer
**File**: `lib/features/profile/presentation/pages/account_preferences_page.dart`

Sections:
- **Appearance**: Theme toggle (Light/Dark/System)
- **Language & Region**: Language dropdown, Region dropdown, Time zone
- **Notifications**: Email, Push, In-app toggles with descriptions

---

## 🧪 Testing Requirements

### Unit Tests (90%+ coverage)
**File**: `test/unit/features/profile/presentation/bloc/account_preferences_bloc_test.dart`

Test scenarios:
- ✅ Initial state is `AccountPreferencesInitial`
- ✅ `LoadPreferences` emits `[loading, loaded]` when successful
- ✅ `UpdateTheme` saves theme and emits updated state
- ✅ `UpdateLanguage` saves locale and emits updated state
- ✅ `UpdateNotificationPreference` toggles notification type
- ✅ `SyncToCloud` uploads preferences to Firestore (if online)
- ✅ Error states emit properly when repository fails
- ✅ Multiple rapid updates are debounced/handled correctly

**File**: `test/unit/features/profile/data/repositories/account_preferences_repository_test.dart`

Test scenarios:
- ✅ `loadPreferences` returns defaults if no saved data
- ✅ `saveTheme` persists theme to SharedPreferences
- ✅ `saveLanguage` persists locale
- ✅ `watchPreferences` stream emits on changes

### Widget Tests
**File**: `test/widget/features/profile/presentation/pages/account_preferences_page_test.dart`

Test scenarios:
- ✅ Displays all preference sections
- ✅ Theme toggle switches theme mode
- ✅ Language dropdown shows supported languages
- ✅ Notification toggles update state
- ✅ Loading indicator shows during operations
- ✅ Error messages display when operations fail
- ✅ Accessibility labels are present

### Integration Tests (Optional)
**File**: `test/integration/features/profile/account_preferences_flow_test.dart`

Test scenarios:
- ✅ End-to-end preference update flow
- ✅ Theme changes apply to entire app
- ✅ Preferences persist across app restart

---

## 📱 Platform Considerations

### Android
- Use Material Design 3 components
- Support Android 6.0+ (API 23+)
- Handle notification permission requests (Android 13+)

### iOS
- Use Cupertino widgets where appropriate
- Support iOS 12.0+
- Respect iOS notification settings

### Web
- Theme persists in browser local storage
- No push notifications (use web push API if needed)
- Time zone detection from browser

---

## 🔒 Security Considerations

### Low Risk (Local Storage Only)
- No sensitive user data stored
- Preferences are non-critical
- No authentication required for local changes

### Cloud Sync (Optional)
- If syncing to Firestore, ensure:
  - User is authenticated
  - Preferences stored in user's document
  - No PII (personally identifiable information) exposed

---

## 🎨 UI/UX Design

### Theme Section
```
┌─────────────────────────────────┐
│ Appearance                      │
├─────────────────────────────────┤
│ Theme                           │
│ ○ Light  ○ Dark  ● System      │
└─────────────────────────────────┘
```

### Language Section
```
┌─────────────────────────────────┐
│ Language & Region               │
├─────────────────────────────────┤
│ Language:     [English ▼]       │
│ Region:       [United States ▼] │
│ Time Zone:    [Auto-detect ▼]   │
└─────────────────────────────────┘
```

### Notifications Section
```
┌─────────────────────────────────┐
│ Notifications                   │
├─────────────────────────────────┤
│ Email Notifications       [ON]  │
│ Push Notifications        [OFF] │
│ In-App Notifications      [ON]  │
└─────────────────────────────────┘
```

---

## 📦 Dependencies

### New Dependencies (add to `pubspec.yaml`)
```yaml
dependencies:
  shared_preferences: ^2.2.0
  intl: ^0.18.0  # For localization

dev_dependencies:
  shared_preferences_platform_interface: ^2.3.0  # For mocking
```

---

## 🚀 Implementation Steps

### Phase 1: Foundation
1. Create domain entities (`AccountPreferencesEntity`)
2. Implement repository interface and implementation
3. Set up SharedPreferences keys and defaults

### Phase 2: BLoC
4. Create BLoC with events and states
5. Implement event handlers
6. Add debouncing for rapid changes

### Phase 3: UI
7. Create AccountPreferencesPage widget
8. Implement theme toggle section
9. Implement language/region section
10. Implement notifications section

### Phase 4: Testing
11. Write unit tests for BLoC
12. Write unit tests for repository
13. Write widget tests for UI
14. Optional: Integration tests

### Phase 5: Integration
15. Integrate with main app theme provider
16. Connect to existing localization system
17. Test on all platforms

---

## 📊 Success Metrics

- ✅ All acceptance criteria met
- ✅ 90%+ test coverage
- ✅ Zero linting errors
- ✅ Works on Android, iOS, and Web
- ✅ Theme changes apply instantly
- ✅ Preferences persist correctly
- ✅ No performance issues

---

## 🔄 Future Enhancements

- [ ] More theme options (custom colors)
- [ ] Notification scheduling (quiet hours)
- [ ] Advanced localization (date/number formats)
- [ ] Sync status indicator
- [ ] Export/import preferences

---

## 📚 Related Documentation

- [Parent Story 1.4.5](../README.md)
- [Flutter Theming](https://docs.flutter.dev/cookbook/design/themes)
- [Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)

---

## ✅ Definition of Done

- [ ] All acceptance criteria met
- [ ] Unit tests written and passing (90%+ coverage)
- [ ] Widget tests written and passing
- [ ] Code follows CLAUDE.md standards
- [ ] No linting errors or warnings
- [ ] Tested on Android, iOS, and Web
- [ ] Documentation updated
- [ ] Code review completed
- [ ] Merged to main branch

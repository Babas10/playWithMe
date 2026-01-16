# Code Quality Scan Report

**Document Version**: 1.0
**Last Updated**: January 2026
**Story Reference**: Story 16.2 (#380)

---

## Executive Summary

| Category | Status | Issues Found |
|----------|--------|--------------|
| Error Handling | ⚠️ Needs Improvement | 15+ |
| Unused Code | ⚠️ Cleanup Needed | 21 |
| TODO Comments | ✅ Minimal | 1 |
| Loading States | ✅ Good | 100% coverage |
| Empty States | ✅ Good | 89% coverage |
| Error States | ✅ Good | 100% coverage |
| Null Safety | ✅ Good | No issues |
| Hardcoded Strings | ⚠️ No Localization | Many (expected) |

---

## Table of Contents

1. [Error Handling Issues](#1-error-handling-issues)
2. [Unused Code](#2-unused-code)
3. [TODO/FIXME Comments](#3-todofixme-comments)
4. [State Management (Loading/Empty/Error)](#4-state-management)
5. [Hardcoded Strings](#5-hardcoded-strings)
6. [Prioritized Issue List](#6-prioritized-issue-list)
7. [Recommendations](#7-recommendations)

---

## 1. Error Handling Issues

### 1.1 Generic Exception Throwing in Repositories

**Severity**: HIGH
**Files Affected**: 7 repositories

All repository implementations throw generic `Exception()` instead of custom exception types:

| Repository | Pattern Used | Issues |
|------------|--------------|--------|
| `firestore_training_session_repository.dart` | `throw Exception('Failed to...')` | 30+ instances |
| `firestore_game_repository.dart` | `throw Exception('Failed to...')` | 15+ instances |
| `firestore_exercise_repository.dart` | `throw Exception('Failed to...')` | 8+ instances |
| `firestore_user_repository.dart` | `throw Exception('Failed to...')` | 10+ instances |
| `firestore_group_repository.dart` | `throw Exception('Failed to...')` | 12+ instances |
| `firestore_invitation_repository.dart` | `throw Exception('Failed to...')` | 6+ instances |
| `firebase_image_storage_repository.dart` | `throw Exception('Failed to...')` | 4+ instances |

**Impact**: BLoCs cannot distinguish between different error types (permission-denied, not-found, network errors).

**Good Example** (existing pattern to follow):
```dart
// firestore_friend_repository.dart - FriendshipException
class FriendshipException implements Exception {
  final String message;
  final String? code;
  FriendshipException(this.message, {this.code});
}
```

### 1.2 Inconsistent BLoC Error Handling

**Severity**: MEDIUM

| BLoC | Issue | Location |
|------|-------|----------|
| `GameCreationBloc` | Single error code for all errors | Lines 158-163 |
| `GamesListBloc` | Stream errors silently swallowed | Lines 60-68 |
| `GameDetailsBloc` | Converts error to null | Lines 43-45 |
| `TrainingSessionCreationBloc` | Uses string matching for errors | Lines 224-244 |
| `ProfileEditBloc` | Uses string manipulation | Lines 143-149 |

**Example Issues**:

```dart
// GamesListBloc - Bad: Swallows error
onError: (error) {
  print('❌ GamesListBloc: Stream error: $error');
  add(const ActivityListUpdated(activities: [])); // Returns empty instead of error
},

// TrainingSessionCreationBloc - Bad: String matching
if (e.toString().contains('Creator is not a member')) {
  // Brittle string matching
}
```

**Good Example** (existing pattern to follow):
```dart
// TrainingSessionParticipationBloc - Proper handling
String _getFriendlyErrorMessage(FirebaseFunctionsException e) {
  switch (e.code) {
    case 'unauthenticated':
      return 'You must be logged in...';
    case 'permission-denied':
      return 'You don\'t have permission...';
    // ...
  }
}
```

---

## 2. Unused Code

### 2.1 Unused Imports (10 instances)

| File | Unused Import |
|------|---------------|
| `play_with_me_app.dart` | `firebase_service.dart` |
| `registration_bloc.dart` | `user_model.dart` |
| `games_list_page.dart` | `intl.dart`, `game_model.dart` |
| `head_to_head_bloc.dart` | `head_to_head_stats.dart`, `user_model.dart` |
| `head_to_head_page.dart` | `user_model.dart` |
| `profile_page.dart` | `game_history_bloc.dart` |
| `training_session_feedback_page.dart` | `service_locator.dart` |

### 2.2 Unused Fields/Variables (8 instances)

| File | Unused Element | Line |
|------|----------------|------|
| `registration_bloc.dart` | `_userRepository` field | 11 |
| `game_details_page.dart` | `canMarkCompleted` variable | 529 |
| `game_result_view_page.dart` | `change` variable | 326 |
| `record_results_page.dart` | `loadedState` variable | 99 |
| `training_session_list_item.dart` | `isCompleted` variable | 23 |
| `group_details_page.dart` | `isCurrentUserAdmin` variable | 437 |
| `group_details_page.dart` | `isProcessing` variable | 462 |
| `partner_detail_page.dart` | `theme` variable | 63 |
| `performance_overview_card.dart` | `theme` variable | 64 |
| `stats_loading_skeleton.dart` | `theme` variable | 159 |

### 2.3 Unused Methods (2 instances)

| File | Method | Line |
|------|--------|------|
| `group_details_page.dart` | `_handleMemberAction` | 228 |
| `performance_overview_card.dart` | `valueColor` parameter | 163 |

---

## 3. TODO/FIXME Comments

**Status**: ✅ Minimal (only 1 found)

| File | Line | Comment |
|------|------|---------|
| `full_elo_history_page.dart` | 225 | `// TODO: Navigate to game details (future enhancement)` |

---

## 4. State Management

### 4.1 Loading States

**Coverage**: 100% (27/27 pages)

All pages properly implement loading states using:
- `CircularProgressIndicator` for full-screen loading
- Button state flags (`isLoading`) for form submissions
- `StreamBuilder.connectionState` for async operations
- BLoC state checking (`state is Loading`)

### 4.2 Empty States

**Coverage**: 89% (24/27 pages)

| Pages WITHOUT Empty States | Reason |
|---------------------------|--------|
| `login_page.dart` | Form page - not needed |
| `registration_page.dart` | Form page - not needed |
| `password_reset_page.dart` | Form page - not needed |

All list-based pages properly implement empty states with:
- Custom empty widgets (e.g., `EmptyGroupList`)
- Icon + message + optional CTA button
- Consistent theming

### 4.3 Error States

**Coverage**: 100% (27/27 pages)

All pages implement error handling via:
- SnackBar for form submission errors
- Center widget with error icon + message + retry button
- AlertDialog for critical errors
- BLoC listener for state-based errors

---

## 5. Hardcoded Strings

**Status**: ⚠️ No Localization System

The app currently has no localization/i18n system. All user-facing strings are hardcoded in English:

**Examples**:
- `'Reset Password'`
- `'Login'`
- `'Create Account'`
- `'Successfully joined training session!'`
- Error messages in BLoCs

**Note**: This is expected for the current phase but should be addressed before international release.

---

## 6. Prioritized Issue List

### HIGH Priority (Breaking/Consistency)

| # | Issue | Files | Effort |
|---|-------|-------|--------|
| 1 | Create custom exception types for repositories | 7 files | Medium |
| 2 | Fix stream error swallowing in GamesListBloc | 1 file | Low |
| 3 | Fix error-to-null conversion in GameDetailsBloc | 1 file | Low |
| 4 | Add proper FirebaseFunctionsException handling to GameCreationBloc | 1 file | Medium |

### MEDIUM Priority (Code Quality)

| # | Issue | Files | Effort |
|---|-------|-------|--------|
| 5 | Remove unused imports | 7 files | Low |
| 6 | Remove unused variables/fields | 8 files | Low |
| 7 | Replace string matching with proper error codes | 1 file | Medium |
| 8 | Remove unused methods | 2 files | Low |

### LOW Priority (Future Enhancement)

| # | Issue | Files | Effort |
|---|-------|-------|--------|
| 9 | Add localization system | All | High |
| 10 | Add skeleton loaders for lists | ~5 files | Medium |
| 11 | Complete the TODO in full_elo_history_page | 1 file | Low |

---

## 7. Recommendations

### Immediate Actions

1. **Create Custom Exceptions** (Story 16.8.1)
   - Create `GameException`, `TrainingSessionException`, etc.
   - Follow `FriendshipException` pattern
   - Update repositories and BLoCs

2. **Fix Stream Error Handling** (Story 16.8.2)
   - GamesListBloc: Emit error state instead of empty
   - GameDetailsBloc: Emit error state instead of null

3. **Clean Up Unused Code** (Story 16.8.3)
   - Remove 10 unused imports
   - Remove 8 unused variables
   - Remove 2 unused methods

### Future Improvements

4. **Standardize Error Handling**
   - Create `ErrorHandlerMixin` for common patterns
   - Centralize error message generation

5. **Add Localization**
   - Implement `flutter_localizations`
   - Extract all user-facing strings
   - Support at least English and French

6. **Improve Loading UX**
   - Add skeleton loaders for list pages
   - Create reusable loading widgets

---

## Appendix: Files Requiring Changes

### By Priority

**HIGH**:
- `lib/features/games/presentation/bloc/games_list/games_list_bloc.dart`
- `lib/features/games/presentation/bloc/game_details/game_details_bloc.dart`
- `lib/features/games/presentation/bloc/game_creation/game_creation_bloc.dart`
- `lib/core/data/repositories/firestore_game_repository.dart`
- `lib/core/data/repositories/firestore_training_session_repository.dart`

**MEDIUM**:
- `lib/app/play_with_me_app.dart`
- `lib/features/auth/presentation/bloc/registration/registration_bloc.dart`
- `lib/features/games/presentation/pages/game_details_page.dart`
- `lib/features/games/presentation/pages/games_list_page.dart`
- `lib/features/groups/presentation/pages/group_details_page.dart`
- `lib/features/profile/presentation/bloc/head_to_head/head_to_head_bloc.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 2026 | Initial code quality scan |

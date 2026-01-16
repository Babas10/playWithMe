# Prioritized Test Backlog

**Story**: 16.3 - Test Coverage Analysis
**Date**: January 2026

This document provides an actionable prioritized list of tests to add to the PlayWithMe project.

---

## Priority 1: CRITICAL (Must Have)

These tests are essential for security and core functionality. They should be added immediately.

### Unit Tests

| # | Component | File to Create | Source File | Est. Tests |
|---|-----------|----------------|-------------|------------|
| 1 | AuthenticationBloc | `test/unit/features/auth/presentation/bloc/authentication/authentication_bloc_test.dart` | `lib/features/auth/presentation/bloc/authentication/authentication_bloc.dart` | 15-20 |
| 2 | FirebaseAuthRepository | `test/unit/features/auth/data/repositories/firebase_auth_repository_test.dart` | `lib/features/auth/data/repositories/firebase_auth_repository.dart` | 20-25 |
| 3 | FirestoreUserRepository | `test/unit/core/data/repositories/firestore_user_repository_test.dart` | `lib/core/data/repositories/firestore_user_repository.dart` | 25-30 |

### Integration Tests

| # | Flow | File to Create | Description |
|---|------|----------------|-------------|
| 1 | Authentication Flow | `integration_test/authentication_flow_test.dart` | Login, logout, session persistence |
| 2 | Registration Flow | `integration_test/registration_flow_test.dart` | Complete signup with profile creation |

---

## Priority 2: HIGH (Should Have Soon)

These tests cover core user-facing features.

### Unit Tests

| # | Component | File to Create | Source File |
|---|-----------|----------------|-------------|
| 1 | RegistrationBloc | `test/unit/features/auth/presentation/bloc/registration/registration_bloc_test.dart` | `lib/features/auth/presentation/bloc/registration/registration_bloc.dart` |
| 2 | PasswordResetBloc | `test/unit/features/auth/presentation/bloc/password_reset/password_reset_bloc_test.dart` | `lib/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart` |
| 3 | InvitationModel | `test/unit/core/data/models/invitation_model_test.dart` | `lib/core/data/models/invitation_model.dart` |
| 4 | FirestoreGameRepository | `test/unit/core/data/repositories/firestore_game_repository_test.dart` | `lib/core/data/repositories/firestore_game_repository.dart` |

### Widget Tests

| # | Page | File to Create | Source File |
|---|------|----------------|-------------|
| 1 | LoginPage | `test/widget/features/auth/presentation/pages/login_page_test.dart` | `lib/features/auth/presentation/pages/login_page.dart` |
| 2 | RegistrationPage | `test/widget/features/auth/presentation/pages/registration_page_test.dart` | `lib/features/auth/presentation/pages/registration_page.dart` |
| 3 | GameCreationPage | `test/widget/features/games/presentation/pages/game_creation_page_test.dart` | `lib/features/games/presentation/pages/game_creation_page.dart` |
| 4 | GroupCreationPage | `test/widget/features/groups/presentation/pages/group_creation_page_test.dart` | `lib/features/groups/presentation/pages/group_creation_page.dart` |
| 5 | GroupDetailsPage | `test/widget/features/groups/presentation/pages/group_details_page_test.dart` | `lib/features/groups/presentation/pages/group_details_page.dart` |
| 6 | GamesListPage | `test/widget/features/games/presentation/pages/games_list_page_test.dart` | `lib/features/games/presentation/pages/games_list_page.dart` |

### Integration Tests

| # | Flow | File to Create | Description |
|---|------|----------------|-------------|
| 1 | Group Creation | `integration_test/group_creation_flow_test.dart` | Create group, verify in Firestore |
| 2 | Game Creation | `integration_test/game_creation_flow_test.dart` | Create game within group |

---

## Priority 3: MEDIUM (Nice to Have)

These tests improve coverage for important but non-critical features.

### Unit Tests

| # | Component | File to Create | Source File |
|---|-----------|----------------|-------------|
| 1 | TrainingSessionModel | `test/unit/core/data/models/training_session_model_test.dart` | `lib/core/data/models/training_session_model.dart` |
| 2 | TeammateStats | `test/unit/core/data/models/teammate_stats_test.dart` | `lib/core/data/models/teammate_stats.dart` |
| 3 | HeadToHeadStats | `test/unit/core/data/models/head_to_head_stats_test.dart` | `lib/core/data/models/head_to_head_stats.dart` |
| 4 | UserRanking | `test/unit/core/data/models/user_ranking_test.dart` | `lib/core/data/models/user_ranking.dart` |
| 5 | BestEloRecord | `test/unit/core/data/models/best_elo_record_test.dart` | `lib/core/data/models/best_elo_record.dart` |
| 6 | RatingHistoryEntry | `test/unit/core/data/models/rating_history_entry_test.dart` | `lib/core/data/models/rating_history_entry.dart` |

### Widget Tests

| # | Page | File to Create | Source File |
|---|------|----------------|-------------|
| 1 | AddFriendPage | `test/widget/features/friends/presentation/pages/add_friend_page_test.dart` | `lib/features/friends/presentation/pages/add_friend_page.dart` |
| 2 | PendingInvitationsPage | `test/widget/features/invitations/presentation/pages/pending_invitations_page_test.dart` | `lib/features/invitations/presentation/pages/pending_invitations_page.dart` |
| 3 | PasswordResetPage | `test/widget/features/auth/presentation/pages/password_reset_page_test.dart` | `lib/features/auth/presentation/pages/password_reset_page.dart` |
| 4 | GameHistoryScreen | `test/widget/features/games/presentation/pages/game_history_screen_test.dart` | `lib/features/games/presentation/pages/game_history_screen.dart` |

### Integration Tests

| # | Flow | File to Create | Description |
|---|------|----------------|-------------|
| 1 | Profile Management | `integration_test/profile_management_test.dart` | Edit profile, upload avatar |

---

## Priority 4: LOW (Future Enhancement)

These tests can be added as time permits.

### Unit Tests

| # | Component | File to Create |
|---|-----------|----------------|
| 1 | FirestoreTrainingSessionRepository | `test/unit/core/data/repositories/firestore_training_session_repository_test.dart` |
| 2 | FirestoreTrainingFeedbackRepository | `test/unit/core/data/repositories/firestore_training_feedback_repository_test.dart` |
| 3 | TrainingSessionParticipantModel | `test/unit/core/data/models/training_session_participant_model_test.dart` |
| 4 | TrainingFeedbackModel | `test/unit/core/data/models/training_feedback_model_test.dart` |
| 5 | GroupActivityItem | `test/unit/core/data/models/group_activity_item_test.dart` |
| 6 | FriendshipEntity | `test/unit/core/domain/entities/friendship_entity_test.dart` |
| 7 | UserSearchResult | `test/unit/core/domain/entities/user_search_result_test.dart` |
| 8 | LocalePreferencesEntity | `test/unit/features/profile/domain/entities/locale_preferences_entity_test.dart` |
| 9 | LocalePreferencesModel | `test/unit/features/profile/data/models/locale_preferences_model_test.dart` |

### Widget Tests

| # | Page | File to Create |
|---|------|----------------|
| 1 | TrainingSessionCreationPage | `test/widget/features/training/presentation/pages/training_session_creation_page_test.dart` |
| 2 | TrainingSessionDetailsPage | `test/widget/features/training/presentation/pages/training_session_details_page_test.dart` |
| 3 | TrainingSessionFeedbackPage | `test/widget/features/training/presentation/pages/training_session_feedback_page_test.dart` |
| 4 | FullEloHistoryPage | `test/widget/features/profile/presentation/pages/full_elo_history_page_test.dart` |
| 5 | HeadToHeadPage | `test/widget/features/profile/presentation/pages/head_to_head_page_test.dart` |
| 6 | PartnerDetailPage | `test/widget/features/profile/presentation/pages/partner_detail_page_test.dart` |

### Integration Tests

| # | Flow | File to Create |
|---|------|----------------|
| 1 | Training Session Flow | `integration_test/training_session_flow_test.dart` |
| 2 | Notification Settings | `integration_test/notification_settings_test.dart` |

---

## Skipped Tests to Fix

These are existing tests that are skipped and need to be addressed.

| # | File | Test | Action Required |
|---|------|------|-----------------|
| 1 | `group_list_page_widget_test.dart:152` | Dynamic stream updates | Create issue or fix timing |
| 2 | `invite_member_page_test.dart:135` | Unspecified | Add issue reference |
| 3 | `friend_selector_widget_test.dart:37` | Unspecified | Add issue reference |
| 4 | `game_details_page_test.dart:105,305` | Unspecified | Add issue reference |

---

## Repository Tests Needing Improvement

These repositories have tests but need more coverage.

| Repository | Current Coverage | Target |
|------------|------------------|--------|
| FirestoreGroupRepository | 17% | 80% |
| FirestoreExerciseRepository | 11% | 80% |
| GameModel | 55% | 80% |

---

## Suggested Implementation Order

### Sprint 1: Critical Security
1. AuthenticationBloc unit tests
2. FirebaseAuthRepository unit tests
3. FirestoreUserRepository unit tests
4. Authentication integration test

### Sprint 2: Core Features
1. RegistrationBloc unit tests
2. PasswordResetBloc unit tests
3. LoginPage widget test
4. RegistrationPage widget test
5. Registration integration test

### Sprint 3: Game & Group Features
1. FirestoreGameRepository unit tests
2. GameCreationPage widget test
3. GroupCreationPage widget test
4. GroupDetailsPage widget test
5. Game/Group creation integration tests

### Sprint 4: Polish & Completion
1. Remaining widget tests
2. Model tests for stats
3. Fix skipped tests
4. Improve low-coverage repositories

---

## Notes

- All tests should follow the patterns in `CLAUDE.md` Section 4 (Testing)
- Unit tests should use `mocktail` for mocking
- BLoC tests should use `bloc_test` package
- Integration tests should use Firebase Emulator
- Each test file must start with a one-line purpose comment

---

*Generated as part of Story 16.3: Test Coverage Analysis*

# Story 0.3.1 Substories: Test Failure Remediation

**Parent Story:** [Story 0.3.1: Test Failures Remediation](./TEST_FAILURES_REMEDIATION.md)

## Overview

After systematic analysis of the remaining 50 test failures, they have been categorized into 7 targeted substories for individual resolution. Each substory addresses a specific root cause and can be worked on independently.

## Current Status

- **Total Failing Tests:** 50
- **Test Files Affected:** 6
- **Substories Created:** 7
- **Priority Levels:** P1 (Critical) → P4 (Low)

## Substory Breakdown

---

### Story 0.3.1.1: Fix Firebase Options Provider Configuration Tests
**Priority:** P1 (Critical) | **Failing Tests:** 8

**Root Cause:** Firebase test expectations use outdated `.appspot.com` URLs, but actual configuration returns `.firebasestorage.app` URLs.

**Affected Tests:**
- `FirebaseOptionsProvider getFirebaseOptions returns dev options when environment is dev`
- `FirebaseOptionsProvider getFirebaseOptions returns staging options when environment is stg`
- `FirebaseOptionsProvider getFirebaseOptions returns prod options when environment is prod`
- `FirebaseOptionsProvider validateConfiguration returns false when configuration has placeholder values`
- `FirebaseOptionsProvider validateConfiguration detects placeholder values correctly`
- `FirebaseOptionsProvider getConfigurationSummary returns correct summary for dev environment`
- `FirebaseOptionsProvider getConfigurationSummary returns correct summary for staging environment`
- `FirebaseOptionsProvider getConfigurationSummary returns correct summary for production environment`

**File:** `test/core/services/firebase_options_provider_test.dart`

**Fix Required:** Update test expectations to match current Firebase configuration format.

**Estimated Effort:** 1-2 hours

---

### Story 0.3.1.2: Fix Firebase Integration Test Environment Validation
**Priority:** P4 (Low) | **Failing Tests:** 1

**Root Cause:** Integration test expecting StateError when Firebase is not properly initialized, but actual behavior differs.

**Affected Tests:**
- `Firebase integration tests should fail appropriately when Firebase not initialized`

**File:** `test/firebase_integration_test.dart`

**Fix Required:** Align test expectations with actual Firebase behavior or improve error handling.

**Estimated Effort:** 30 minutes

---

### Story 0.3.1.3: Fix UserModel Duplicate Game Prevention Logic
**Priority:** P1 (Critical) | **Failing Tests:** 1

**Root Cause:** Logic bug in `UserModel.addGame()` method - duplicates are not being prevented correctly.

**Affected Tests:**
- `UserModel Update methods addGame does not add duplicate game`

**File:** `test/core/data/models/user_model_test.dart`

**Fix Required:** Fix the duplicate prevention logic in the `addGame` method implementation.

**Expected:** `['game1', 'game2']`
**Actual:** `['game1', 'game2', 'game1']`

**Estimated Effort:** 30 minutes

---

### Story 0.3.1.4: Fix Authentication BLoC Mock Setup and Test Infrastructure
**Priority:** P2 (High) | **Failing Tests:** 5

**Root Cause:** Mockito configuration issues with AuthenticationBloc tests.

**Affected Tests:**
- `AuthenticationBloc AppStarted emits Unauthenticated when no user`
- `AuthenticationBloc AppStarted emits Authenticated when user exists`
- `AuthenticationBloc UserChanged emits Authenticated when user exists`
- `AuthenticationBloc UserChanged emits Unauthenticated when user is null`
- `AuthenticationBloc LoggedOut emits Unauthenticated and calls signOut`

**File:** `test/core/presentation/bloc/authentication/authentication_bloc_test.dart`

**Fix Required:** Update mock setup to use custom MockAuthRepository API instead of Mockito `when()` syntax.

**Estimated Effort:** 2-3 hours

---

### Story 0.3.1.5: Fix Password Reset BLoC Mock Setup and State Equality
**Priority:** P2 (High) | **Failing Tests:** 26

**Root Cause:** Multiple issues including Mockito setup problems and BLoC state equality comparison failures.

**Affected Tests:** 26 tests in password reset functionality including:
- `PasswordResetBloc emits [PasswordResetLoading, PasswordResetSuccess] when reset succeeds`
- `PasswordResetBloc emits [PasswordResetLoading, PasswordResetFailure] when reset fails`
- Various email validation and error handling tests

**File:** `test/features/auth/presentation/bloc/password_reset/password_reset_bloc_test.dart`

**Fix Required:**
1. Update Mockito configuration to use custom mock API
2. Fix state equality issues in BLoC state comparisons
3. Ensure proper error message handling

**Estimated Effort:** 4-5 hours

---

### Story 0.3.1.6: Fix Login BLoC State Emission and Error Handling
**Priority:** P3 (Medium) | **Failing Tests:** 4

**Root Cause:** BLoC state emission timing issues and error handling mismatches.

**Affected Tests:**
- `LoginBloc LoginWithEmailAndPasswordSubmitted emits [LoginFailure] when email format is invalid`
- `LoginBloc LoginAnonymouslySubmitted emits [LoginLoading, LoginFailure] when anonymous login fails`
- `LoginBloc LoginAnonymouslySubmitted handles anonymous login repository errors correctly`
- `LoginBloc Complex scenarios handles rapid consecutive login attempts`

**File:** `test/features/auth/presentation/bloc/login/login_bloc_test.dart`

**Fix Required:** Fix state emission timing and error message handling logic.

**Estimated Effort:** 2-3 hours

---

### Story 0.3.1.7: Fix Registration BLoC State Management and Error Handling
**Priority:** P3 (Medium) | **Failing Tests:** 5

**Root Cause:** State emission timing issues and business logic mismatches in registration flow.

**Affected Tests:**
- `RegistrationBloc RegistrationSubmitted Repository error handling handles repository error: Exception: Weak password`
- `RegistrationBloc RegistrationSubmitted Repository error handling handles repository error: Exception: Network error`
- `RegistrationBloc RegistrationFormReset can reset from any state`
- `RegistrationBloc Complex scenarios handles rapid consecutive registration attempts`
- Various error handling edge cases

**File:** `test/features/auth/presentation/bloc/registration/registration_bloc_test.dart`

**Fix Required:** Fix state management timing and error message processing logic.

**Estimated Effort:** 2-3 hours

---

## Implementation Strategy

### Phase 1: Critical Fixes (P1)
1. **Story 0.3.1.1** - Firebase Options Provider (8 tests)
2. **Story 0.3.1.3** - UserModel Logic Bug (1 test)

**Expected Result:** 9 test failures resolved

### Phase 2: Infrastructure Fixes (P2)
3. **Story 0.3.1.4** - Authentication BLoC Mock Setup (5 tests)
4. **Story 0.3.1.5** - Password Reset BLoC Setup (26 tests)

**Expected Result:** 31 additional test failures resolved

### Phase 3: Business Logic Fixes (P3)
5. **Story 0.3.1.6** - Login BLoC State Management (4 tests)
6. **Story 0.3.1.7** - Registration BLoC State Management (5 tests)

**Expected Result:** 9 additional test failures resolved

### Phase 4: Integration Cleanup (P4)
7. **Story 0.3.1.2** - Firebase Integration Test (1 test)

**Expected Result:** Final test failure resolved

## Success Metrics

### Target Outcomes
- **0 test failures** in `flutter test` execution
- **263+ tests passing** (maintain current)
- **8+ tests properly skipped** with documentation
- **90%+ test coverage** maintained

### Quality Gates
- Each substory must be implemented and tested independently
- No regression in currently passing tests
- All changes follow project coding standards
- CI/CD pipeline passes consistently after each substory

## Timeline Estimate

**Total Effort:** 12-17 hours
**Recommended Schedule:** 3-4 days with parallel work on independent substories

**Day 1:** Stories 0.3.1.1 and 0.3.1.3 (P1 critical fixes)
**Day 2:** Story 0.3.1.4 (Authentication BLoC infrastructure)
**Day 3:** Story 0.3.1.5 (Password Reset BLoC infrastructure)
**Day 4:** Stories 0.3.1.6, 0.3.1.7, and 0.3.1.2 (remaining fixes)

## Notes

- Each substory can be worked on independently
- Priority order ensures critical issues are resolved first
- Infrastructure fixes (P2) will likely resolve multiple test patterns
- Business logic fixes (P3) require careful testing to avoid regressions
- Integration test fixes (P4) are low impact but complete the cleanup

---

**Document Status:** Ready for Implementation
**Next Step:** Begin with Story 0.3.1.1 (Firebase Options Provider Configuration)
**Owner:** Development Team
**Reviewers:** CI/CD Pipeline, Testing Infrastructure
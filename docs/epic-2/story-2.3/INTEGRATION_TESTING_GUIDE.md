# Story 2.3: Integration Testing Guide

## Overview

This guide explains how to run and maintain the Firebase Emulator integration tests for the User Invitation System (Story 2.3).

---

## What Are Integration Tests?

Integration tests verify that the invitation system works correctly with **real Firestore** and **real security rules**, unlike unit tests which use mocks. They run against the Firebase Emulator Suite, which simulates Firebase services locally.

### Why Integration Tests?

- ✅ **Validate Security Rules**: Ensure Firestore security rules work as expected
- ✅ **Test Real Firebase Behavior**: Catch issues that mocks can't detect
- ✅ **Verify Atomic Operations**: Test batch writes and transactions
- ✅ **Safe Testing Environment**: No impact on production data
- ✅ **Faster Feedback**: Runs locally and in CI

---

## Test Suite Structure

```
test/integration/
├── helpers/
│   └── firebase_emulator_helper.dart    # Emulator setup utilities
├── invitation_creation_test.dart         # Tests for creating invitations
├── invitation_acceptance_test.dart       # Tests for accepting invitations
├── invitation_decline_test.dart          # Tests for declining invitations
└── invitation_security_rules_test.dart   # Security rule validation tests
```

### Test Coverage

| Test File | Tests | Coverage |
|-----------|-------|----------|
| **invitation_creation_test.dart** | 4 tests | Admin invitation creation, non-admin rejection, field validation, multiple invitations |
| **invitation_acceptance_test.dart** | 6 tests | Acceptance flow, atomic operations, permissions, field protection, query filtering |
| **invitation_decline_test.dart** | 5 tests | Decline flow, query filtering, multiple declines, permissions, invalid status rejection |
| **invitation_security_rules_test.dart** | 10 tests | Admin-only creation, read permissions, deletion permissions, unauthenticated access |

**Total: 25 integration tests**

---

## Running Integration Tests

### Prerequisites

1. **Firebase CLI** installed:
   ```bash
   npm install -g firebase-tools
   ```

2. **Java 21+** installed (for Firestore Emulator):
   ```bash
   java -version  # Should be >= 21
   ```

3. **Flutter dependencies** up to date:
   ```bash
   flutter pub get
   ```

---

### Local Development

#### 1. Start Firebase Emulators

```bash
firebase emulators:start --only auth,firestore --project playwithme-dev
```

**Expected output:**
```
✔  firestore: Firestore Emulator running on http://localhost:8080
✔  auth: Auth Emulator running on http://localhost:9099
✔  emulator UI: http://localhost:4000
```

#### 2. Run Integration Tests (in another terminal)

```bash
# Run all integration tests
flutter test test/integration/

# Run specific test file
flutter test test/integration/invitation_creation_test.dart

# Run with verbose output
flutter test test/integration/ --reporter expanded
```

#### 3. View Emulator UI (Optional)

Open http://localhost:4000 in your browser to:
- Inspect Firestore data
- View Auth users
- Monitor real-time updates
- Debug security rule failures

#### 4. Stop Emulators

```bash
# In the emulator terminal, press Ctrl+C
# Or kill all Firebase processes:
pkill -f "firebase emulators"
```

---

### CI/CD (GitHub Actions)

Integration tests run automatically in CI via the **`integration-tests.yml`** workflow:

**Triggers:**
- Pull requests to `main` or `develop`
- Pushes to `main` or `develop`

**Workflow Steps:**
1. Checkout code
2. Setup Flutter, Node.js, and Java
3. Install Firebase CLI
4. Start emulators in background
5. Run integration tests
6. Stop emulators and upload logs (on failure)

**Viewing CI Results:**
- Go to GitHub Actions tab in the repository
- Look for "Integration Tests (Firebase Emulator)" workflow
- Check test output and logs

**If Tests Fail in CI:**
1. Check the workflow logs for the specific error
2. Look for `permission-denied` errors (security rule issues)
3. Run the same test locally to reproduce
4. Review Firestore security rules if needed

---

## Writing New Integration Tests

### Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:play_with_me/core/utils/test_environment_helper.dart';

import 'helpers/firebase_emulator_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FirebaseEmulatorHelper.initialize();
  });

  setUp(() async {
    await FirebaseEmulatorHelper.clearFirestore();
    await FirebaseEmulatorHelper.signOut();
  });

  tearDown(() async {
    await FirebaseEmulatorHelper.signOut();
  });

  group('My Feature Tests', () {
    test(
      'Should do something',
      () async {
        // 1. Create test users
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // 2. Perform Firebase operations
        // ... your test logic ...

        // 3. Verify results
        expect(/* your assertions */);
      },
      skip: !CITestHelper.isCIEnvironment
          ? CITestHelper.ciOnlyMessage
          : false,
    );
  });
}
```

### Best Practices

1. **Always clean up between tests**:
   - Use `setUp()` to clear Firestore
   - Use `tearDown()` to sign out

2. **Use FirebaseEmulatorHelper utilities**:
   - `createCompleteTestUser()` - Creates both Auth and Firestore user
   - `createTestGroup()` - Creates a test group
   - `waitForFirestore()` - Wait for async operations
   - `clearFirestore()` - Clean database

3. **Test security rules explicitly**:
   - Use `expect(..., throwsA(isA<FirebaseException>()))` for permission-denied
   - Test both allowed and denied operations

4. **Skip tests in local development** (they only run in CI):
   ```dart
   skip: !CITestHelper.isCIEnvironment ? CITestHelper.ciOnlyMessage : false,
   ```

5. **Test real Firebase behavior**:
   - Use `FieldValue.serverTimestamp()`
   - Use batch writes for atomic operations
   - Query with real Firestore syntax

---

## Troubleshooting

### Emulators Won't Start

**Error:** "Port 8080 already in use"

**Solution:**
```bash
# Kill existing Firebase processes
pkill -f "firebase emulators"

# Or kill specific port
lsof -ti:8080 | xargs kill
```

---

### Tests Fail with "Permission Denied"

**Cause:** Firestore security rules are blocking the operation.

**Solutions:**
1. Check `firestore.rules` file
2. Verify user is authenticated before writing
3. Verify user has admin role for the group (if creating invitations)
4. Check security rule helper functions (`isGroupAdmin`, etc.)

---

### Java Version Too Old

**Error:** "Java version < 21"

**Solution:**
```bash
# Install Java 21 (macOS)
brew install openjdk@21

# Set JAVA_HOME
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
```

---

### Tests Pass Locally But Fail in CI

**Possible Causes:**
1. **Timing issues**: Add `await FirebaseEmulatorHelper.waitForFirestore()` after writes
2. **Environment detection**: Check `CITestHelper.isCIEnvironment` logic
3. **Firebase CLI version**: CI uses latest, ensure compatibility

---

## Security Rules Tested

The integration tests validate these security rules:

### Invitation Creation
- ✅ Only group admins can create invitations
- ❌ Regular members cannot create invitations
- ❌ Non-members cannot create invitations
- ❌ Unauthenticated users cannot create invitations

### Invitation Reading
- ✅ Invited users can read their own invitations
- ❌ Users cannot read other users' invitations
- ❌ Admins cannot read invitations they sent (privacy)

### Invitation Updating
- ✅ Invited users can update status (accept/decline)
- ❌ Users cannot modify core fields (groupId, invitedBy)
- ❌ Only valid statuses allowed (accepted, declined)
- ❌ Other users cannot update invitations

### Invitation Deletion
- ✅ Invited users can delete their invitations
- ✅ Inviters can delete invitations they sent (cancel)
- ❌ Other users cannot delete invitations

---

## Performance Considerations

### Test Execution Time

- **Unit tests**: ~15-20 seconds (fast, local only)
- **Integration tests**: ~45-60 seconds (slower, full Firebase stack)

### Optimization Tips

1. **Run unit tests first** during development
2. **Run integration tests before PR** to catch Firebase-specific issues
3. **Use `flutter test test/integration/specific_test.dart`** to run one file
4. **Keep emulators running** between test runs (don't restart)

---

## Future Enhancements

### Planned Improvements

1. **Parallel Test Execution**
   - Run test files in parallel for faster CI

2. **Test Data Fixtures**
   - Reusable test data for common scenarios

3. **Visual Regression Testing**
   - Screenshot tests for invitation UI

4. **Performance Benchmarks**
   - Track query performance over time

---

## References

- **Firebase Emulator Suite**: https://firebase.google.com/docs/emulator-suite
- **Firestore Security Rules**: https://firebase.google.com/docs/firestore/security/get-started
- **Flutter Integration Testing**: https://docs.flutter.dev/testing/integration-tests
- **Story 2.3 Issue**: #16
- **Story 2.4 (Security Rules)**: #127

---

## Maintenance Checklist

- [ ] Run integration tests before merging PRs
- [ ] Update tests when security rules change
- [ ] Add new tests for new invitation features
- [ ] Monitor CI test execution time
- [ ] Keep Firebase CLI up to date
- [ ] Review test coverage quarterly

---

**Last Updated:** 2025-10-25
**Maintainer:** PlayWithMe Development Team

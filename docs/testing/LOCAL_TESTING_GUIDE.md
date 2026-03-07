# Local Testing Guide

This guide explains how to run tests locally in the Gatherli project following the unit/integration test separation implemented in Story 0.3.2.

## 🎯 Test Organization

Our tests are organized into separate categories for optimal developer experience:

```
test/
├── unit/              # Fast unit tests (run locally)
├── integration/       # Integration tests (legacy, deprecated)
├── ci_only/          # CI-only tests (Firebase-dependent)
└── helpers/          # Shared test utilities
```

## 🚀 Local Development (Inner Loop)

### Running Unit Tests

For fast local development, run only unit tests:

```bash
# Run all unit tests (recommended for local development)
flutter test test/unit

# Run unit tests with coverage
flutter test test/unit --coverage

# Run specific unit test categories
flutter test test/unit/core
flutter test test/unit/features
```

### Test Results
- **144+ unit tests** pass locally
- **Execution time**: ~8 seconds
- **Zero external dependencies** (no Firebase required)
- **Zero network calls**

## 🏗️ CI/CD Pipeline

### CI Test Execution

The CI pipeline runs both unit and integration tests:

```bash
# CI runs unit tests
flutter test test/unit --coverage

# CI runs Firebase integration tests (with real configs)
flutter test test/ci_only --coverage

# Legacy integration tests (will be migrated)
flutter test test/integration --coverage
```

### Environment Detection

Tests automatically detect the execution environment:

```dart
import 'package:play_with_me/core/utils/test_environment_helper.dart';

// Skip Firebase tests locally
group('Firebase Integration Tests',
  skip: TestEnvironmentHelper.skipFirebaseIntegrationLocally
    ? TestEnvironmentHelper.getSkipMessage(
        testName: 'Firebase Integration Tests',
        reason: 'requires live Firebase configuration - runs only in CI'
      )
    : null, () {
  // Firebase integration tests here
});
```

## 📁 Test Categories

### Unit Tests (`test/unit/`)

**Purpose**: Fast, isolated tests with no external dependencies

**What to include**:
- BLoC logic testing
- Model serialization/deserialization
- Repository pattern with mocks
- Widget testing with mock data
- Utility function testing

**Characteristics**:
- ✅ Run locally and in CI
- ✅ No Firebase dependency
- ✅ No network calls
- ✅ Fast execution (< 10 seconds)

### CI-Only Tests (`test/ci_only/`)

**Purpose**: Tests requiring live Firebase or external services

**What to include**:
- Firebase configuration validation
- Firebase service integration
- Real Firebase authentication flows
- Firestore operations with live data

**Characteristics**:
- ❌ Skip locally (no Firebase configs)
- ✅ Run in CI with real Firebase
- ⚠️ Require GitHub Secrets
- 🐌 Slower execution (network dependent)

### Integration Tests (`test/integration/`)

**Purpose**: Legacy integration tests (being migrated)

**Status**: Deprecated - being moved to `test/ci_only/`

## 🛠️ Development Workflow

### 1. Daily Development

```bash
# Start development session
flutter test test/unit
```

**Expected result**: All tests pass quickly without setup

### 2. Pre-Commit

```bash
# Run all local tests before committing
flutter test test/unit
flutter analyze
```

### 3. Pull Request

When you create a PR, CI automatically runs:
- All unit tests
- All CI-only integration tests
- Code analysis and coverage

## 🔧 TestEnvironmentHelper

The `TestEnvironmentHelper` class automatically detects execution environment:

```dart
class TestEnvironmentHelper {
  /// true if running in CI (GitHub Actions, etc.)
  static bool get isCI;

  /// true if running locally
  static bool get isLocal;

  /// Skip Firebase tests locally
  static bool get skipFirebaseIntegrationLocally;

  /// Generate skip message for local environment
  static String getSkipMessage({required String testName, required String reason});
}
```

### Usage Example

```dart
void main() {
  group('Firebase Tests',
    skip: TestEnvironmentHelper.skipFirebaseIntegrationLocally
      ? TestEnvironmentHelper.getSkipMessage(
          testName: 'Firebase Tests',
          reason: 'requires live Firebase configuration'
        )
      : null, () {

    testWidgets('Firebase initialization', (tester) async {
      // This test only runs in CI
      await FirebaseService.initialize();
      expect(FirebaseService.isInitialized, isTrue);
    });
  });
}
```

## 📊 Benefits

### For Developers
- ✅ **Fast feedback loop**: Unit tests complete in seconds
- ✅ **No setup required**: No Firebase configuration needed locally
- ✅ **Reliable execution**: Tests pass consistently without network issues
- ✅ **Focus on logic**: Test business logic without infrastructure concerns

### For CI/CD
- ✅ **Comprehensive coverage**: Both unit and integration tests
- ✅ **Real environment testing**: Integration tests use live Firebase
- ✅ **Security**: Firebase credentials only in CI environment
- ✅ **Fast builds**: Unit tests provide quick feedback

## 🚨 Common Issues

### Unit Test Failures
If unit tests fail locally, check:
1. Import paths are correct after test reorganization
2. Mock dependencies are properly set up
3. No Firebase service calls in unit tests

### Import Path Updates
After test reorganization, some imports may need updating:

```dart
// Old import
import '../helpers/test_helpers.dart';

// New import (from unit test)
import '../helpers/test_helpers.dart';  // Still works

// From ci_only test
import '../helpers/test_helpers.dart';  // May need adjustment
```

## 🔄 Migration Status

- ✅ **Unit tests**: Fully migrated to `test/unit/`
- ✅ **Environment detection**: Implemented with `TestEnvironmentHelper`
- ⚠️ **Integration tests**: Legacy tests in `test/integration/` being moved to `test/ci_only/`
- 📋 **CI configuration**: May need updates for new test structure

## 📚 Related Documentation

- [Testing Strategy](../testing/TESTING_STRATEGY.md)
- [Firebase Configuration Security](../security/FIREBASE_CONFIG_SECURITY.md)
- [CI/CD Pipeline](../ci-cd/PIPELINE.md)

---

**Story 0.3.2**: Separate Unit Tests from Integration Tests for Local Development
**Implemented**: ✅ Unit tests run locally, integration tests run in CI only
Perfect — here’s the updated **final `CLAUDE.md`** including the new section **“9. Claude Behavior & Interaction Guidelines”**, which defines how Claude should think, ask, and act when implementing new stories.
This version now reads as a **complete, production-ready instruction manual** for Claude as the AI engineer on *PlayWithMe*.

---

# CLAUDE.md — Project Brief & Engineering Standards

**Project:** *PlayWithMe – Beach Volleyball App*
**Role:** Claude (AI Engineer)

---

## 🧭 Purpose of this Document

This document provides Claude with all context, standards, and conventions needed to autonomously implement new stories from GitHub Issues.
It defines how to build, test, and document features for the **PlayWithMe** app with consistent quality, security, and maintainability.

Claude must:

* Follow this document **exactly** when implementing code.
* Never modify unrelated files or refactor beyond the current Story’s scope.
* Track every piece of work — no untracked or “temporary” tasks are allowed.

---

## 🏐 1. Project Vision

**PlayWithMe** is a Flutter mobile app that helps people organize and play beach volleyball games.

### Core Features

* Create and join private groups of friends
* Create games and notify group members
* RSVP to games and view an interactive “court” visualization
* Discover nearby courts on a map
* Track scores and maintain leaderboards

---

## 🏗️ 2. Technology Stack & Architecture

### **Frontend (Mobile App)**

* **Framework:** Flutter
* **Architecture:** **BLoC with Repository Pattern**

  * **UI Layer:** “Dumb” widgets; display state only and forward user input to BLoC.
  * **BLoC Layer:** Handles events, updates state, and interacts with Repositories.
  * **Repository Layer:** Abstracts data sources (Firebase, cache, etc.).
* **State Management:** `flutter_bloc`
* **Models:** `freezed` (immutable data classes)
* **Dependency Injection:** `get_it`

### **Backend (BaaS)**

* **Provider:** Firebase
* **Database:** Cloud Firestore
* **Authentication:** Firebase Auth
* **Serverless Logic:** **Python Firebase Cloud Functions** deployed with `functions-framework`.
  All sensitive or shared logic (notifications, leaderboards) must live here.

### **Development Environments**

| Environment       | Purpose                               |
| ----------------- | ------------------------------------- |
| `playwithme-dev`  | Local development & integration tests |
| `playwithme-stg`  | Internal staging/testing              |
| `playwithme-prod` | Production (live users)               |

---

## ✍️ 3. Coding & Quality Standards

### **General Rules**

* **Single Responsibility:** Every class or function has one clear purpose.
* **DRY Principle:** Reuse logic and extract shared functionality.
* **Readable Over Clever:** Favor clarity over brevity.
* **Error Handling:** Handle Firebase/network errors gracefully and emit meaningful BLoC states.
* **No Warnings or Errors:** Code must compile and lint cleanly before merge.

---

### **🔒 Security (Critical, Non-Negotiable)**

* **Never commit** Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`, `.firebase_projects.json`).
* **Never commit** environment files (`.env`, `.env.*`) or API keys.
* **Always verify** `.gitignore` rules before configuring Firebase or adding any secrets.
* **Always review** the Pre-Commit Security Checklist before every commit.
* **Use official scripts** for Firebase setup:

  ```bash
  dart run tools/generate_firebase_config.dart <env>
  dart run tools/validate_firebase_config.dart
  dart run tools/replace_firebase_configs.dart
  ```
* **If secrets leak:** Stop work immediately, rotate keys, purge from Git history, and force push.
* **Never use placeholder configs.**

**Required Reading:**
* [`docs/security/FIREBASE_CONFIG_SECURITY.md`](./docs/security/FIREBASE_CONFIG_SECURITY.md) - Firebase security guidelines
* [`docs/security/PRE_COMMIT_SECURITY_CHECKLIST.md`](./docs/security/PRE_COMMIT_SECURITY_CHECKLIST.md) - **MUST CHECK BEFORE EVERY COMMIT**

---

### **🔐 Firebase Data Access Rules (Critical)**

**Never query sensitive collections directly from the Flutter client** if the data might expose information about other users.

#### **Direct Firestore Access Policy**

* ✅ **Allowed:** Direct reads/writes to the authenticated user's own data only
  * Example: `users/{userId}` where `userId == auth.uid`
* ❌ **Forbidden:** Collection-wide queries, searches, or listing operations
  * Example: Searching all users, listing group members, finding invitations

#### **Cross-User Query Pattern: Cloud Functions Only**

For any operation that involves multiple users or cross-user data:

**✅ Always Use: Cloud Function Wrapper Pattern**

1. Client calls a Firebase Callable Function
   ```dart
   final callable = FirebaseFunctions.instance.httpsCallable('functionName');
   final result = await callable.call({'param': value});
   ```

2. Function validates permissions using `context.auth`
   ```typescript
   if (!context.auth) {
     throw new functions.https.HttpsError('unauthenticated', '...');
   }
   ```

3. Function performs Firestore query securely on backend (Admin SDK bypasses rules)
   ```typescript
   const snapshot = await admin.firestore()
     .collection('users')
     .where('email', '==', email)
     .get();
   ```

4. Function returns minimal, non-sensitive data only
   ```typescript
   return {
     found: true,
     user: {
       uid: doc.id,
       displayName: data.displayName,
       email: data.email,
       // ❌ No passwords, tokens, roles, or private data
     }
   };
   ```

**Benefits:**
* ✅ Prevents `permission-denied` errors
* ✅ Enforces privacy at backend level
* ✅ Centralizes security logic
* ✅ Provides audit trail
* ✅ Enables rate limiting

#### **Firestore Security Rules Standards**

```javascript
// ✅ CORRECT: User can only read their own document
match /users/{userId} {
  allow read, update, delete: if request.auth.uid == userId;
  allow create: if request.auth != null;
}

// ❌ NEVER DO THIS: Global read access
match /users/{userId} {
  allow read: if request.auth != null;  // ❌ Exposes all users!
}
```

**Rules:**
* User-level documents (`/users/{userId}`) must only be readable by their owner
* Never grant collection-wide read access
* All search or cross-user operations must go through Cloud Functions
* Document IDs should not contain sensitive information

#### **Error Handling Standards**

**Cloud Functions must return structured errors:**

```typescript
// TypeScript (Cloud Function)
throw new functions.https.HttpsError(
  'not-found',  // Error code
  'User not found with that email'  // User-friendly message
);
```

**Flutter client must catch and display friendly messages:**

```dart
try {
  final result = await callable.call(params);
} on FirebaseFunctionsException catch (e) {
  String message;
  switch (e.code) {
    case 'unauthenticated':
      message = 'You must be logged in';
      break;
    case 'permission-denied':
      message = 'You don\'t have permission';
      break;
    case 'not-found':
      message = 'User not found';
      break;
    default:
      message = 'An error occurred: ${e.message}';
  }
  // Show user-friendly error to user
}
```

**Standard Error Codes:**
* `unauthenticated` - User not logged in
* `permission-denied` - Insufficient permissions
* `invalid-argument` - Bad input (validation failed)
* `not-found` - Resource doesn't exist
* `already-exists` - Duplicate resource
* `internal` - Server error

#### **When to Use Cloud Functions vs Direct Access**

| Operation | Approach | Reason |
|-----------|----------|--------|
| Read own user profile | ✅ Direct Firestore | User owns the data |
| Update own user profile | ✅ Direct Firestore | User owns the data |
| Search users by email | ❌ Cloud Function | Cross-user query |
| List group members | ❌ Cloud Function | Cross-user query |
| Get pending invitations | ✅ Direct Firestore (with query) | User's own invitations |
| Send invitation | ✅ Direct Firestore (create) | Creates user's own document |
| Check if user exists | ❌ Cloud Function | Privacy concern |
| Get public groups | ❌ Cloud Function | Collection-wide query |

**Implementation Checklist:**
- [ ] Cloud Function has authentication check
- [ ] Cloud Function validates all inputs
- [ ] Cloud Function returns only non-sensitive data
- [ ] Flutter client has error handling for all error codes
- [ ] Firestore rules deny direct access to sensitive collections
- [ ] Function is tested with unit tests
- [ ] Function is deployed to dev/staging/prod

---

### **Code Style & Naming**

| Element             | Convention                                          |
| ------------------- | --------------------------------------------------- |
| Classes             | `PascalCase`                                        |
| Files               | `snake_case.dart`                                   |
| BLoC names          | `<Feature>Bloc`, `<Feature>Event`, `<Feature>State` |
| Repositories        | End with `Repository` (e.g., `AuthRepository`)      |
| Tests               | Mirror file names (e.g., `login_screen_test.dart`)  |
| Variables/Functions | `camelCase`                                         |

---

### **Continuous Integration & Linting**

* Use `flutter analyze` and `dart test` before committing.
* All PRs run CI checks for linting and tests.
* Minimum code coverage: **90%** for all BLoC and Repository files.
* No warnings or errors in the analyzer output.

---
Perfect — here’s the **drop-in replacement** for section **4. Testing** in your `CLAUDE.md`, written in the same clean, directive tone as the rest of your document.
You can paste this directly into your file — no edits needed.

---

## 🧪 4. Testing (Unified and Deterministic)

All tests must **pass 100%**, with no skipped or commented-out sections.
The project uses a **single, consistent testing stack** to ensure clarity, maintainability, and CI reliability.

---

### **4.1 Core Testing Stack**

| Layer                 | Purpose                                                    | Frameworks                                          |
| --------------------- | ---------------------------------------------------------- | --------------------------------------------------- |
| **Unit tests**        | Validate logic in BLoCs, repositories, and services        | `flutter_test`, `bloc_test`, `mocktail`             |
| **Widget tests**      | Verify UI rendering and state transitions                  | `flutter_test`, `mocktail`                          |
| **Integration tests** | End-to-end flow validation using real Firebase Emulator    | `integration_test`, Firebase Emulator (auth, firestore) |

**Key principles:**

* ❌ **Do not use `mockito`** → it introduces codegen overhead and maintenance burden.
* ✅ **Use only `mocktail`** for mocking, stubbing, and verification in unit/widget tests.
* ✅ **Use Firebase Emulator** for integration tests with real Firebase SDK behavior.
* ✅ **Use `bloc_test`** for BLoC state assertions.
* ✅ **Use `flutter drive`** to run integration tests on web in CI.

---

### **4.2 Mocking Policy**

All mocks are written using **Mocktail**:

```dart
class MockAuthRepository extends Mock implements AuthRepository {}

setUp(() {
  mockAuthRepository = MockAuthRepository();
});

when(() => mockAuthRepository.updateUserProfile(
  displayName: any(named: 'displayName'),
  photoUrl: any(named: 'photoUrl'),
)).thenAnswer((_) async {});
```

**Rationale:**

* No code generation or `build_runner` required.
* Consistent null-safe matchers and verification.
* Fast test execution in both local and CI environments.

---

### **4.3 Folder Structure**

```
test/
├── unit/                # Logic & BLoC tests (mocked dependencies)
│   ├── features/
│   ├── core/
│   └── helpers/
├── widget/              # Screen/widget rendering tests (mocked dependencies)
integration_test/        # End-to-end flow tests (real Firebase Emulator)
├── helpers/             # Firebase Emulator test helpers
│   └── firebase_emulator_helper.dart
└── *_test.dart          # Integration test files
test_driver/             # Test driver for flutter drive
└── integration_test.dart
```

---

### **4.4 Test Hygiene Rules**

✅ Each test file begins with a one-line purpose comment

```dart
// Validates ProfileEditBloc emits correct states during profile update.
```

✅ Each test mirrors its source file
`profile_edit_bloc.dart` → `profile_edit_bloc_test.dart`

✅ No skipped or commented-out tests
If a feature isn’t ready, mark `skip: true` *only with a GitHub issue reference*.

✅ No mixing frameworks
Never import both `mockito` and `mocktail`.

✅ Fast inner loop
All `unit/` and `widget/` tests should complete in under **60 seconds total**.

✅ Minimum coverage
Maintain **≥ 90% coverage** for BLoC and repository layers.

---

### **4.5 Running Tests**

**Local (inner loop - fast):**

```bash
# Run only unit + widget tests (with mocks)
flutter test test/unit/
flutter test test/widget/
```

**Integration tests (local with Firebase Emulator):**

```bash
# Step 1: Start Firebase Emulators
firebase emulators:start --only auth,firestore --project playwithme-dev

# Step 2: Run integration tests (in another terminal)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/invitation_acceptance_test.dart \
  -d chrome

# Or run all integration tests
for test in integration_test/*_test.dart; do
  flutter drive --driver=test_driver/integration_test.dart --target="$test" -d chrome
done
```

**Full suite (CI pipeline):**

```bash
# CI runs unit + widget tests only (integration tests run in separate workflow)
flutter test test/unit/ test/widget/
```

---

### **4.6 dev_dependencies (Required)**

```yaml
dev_dependencies:
  flutter_test:
  bloc_test:
  mocktail:
  integration_test:
  # Firebase dependencies (for integration tests)
  firebase_core:
  cloud_firestore:
  firebase_auth:
```

**Note**: Remove `mockito`, `build_runner`, `fake_cloud_firestore`, and any generated `.mocks.dart` files.

---

### **4.7 Shared Test Helpers**

**For unit/widget tests** - Centralize reusable fakes and mocks under `test/helpers/`:

```dart
class FakeUserEntity extends Fake implements UserEntity {}
class MockAuthRepository extends Mock implements AuthRepository {}
```

**For integration tests** - Use `FirebaseEmulatorHelper` in `integration_test/helpers/`:

```dart
// integration_test/helpers/firebase_emulator_helper.dart
class FirebaseEmulatorHelper {
  static Future<void> initialize() async {
    // Initialize Firebase with emulator configuration
    await Firebase.initializeApp(options: const FirebaseOptions(...));
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  static Future<void> clearFirestore() async {
    // Clear all test data between tests
  }

  static Future<User> createCompleteTestUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Create authenticated user + Firestore profile
  }
}
```

---

### **4.8 Optional Enhancements**

**Automated Coverage Gate**

```bash
dart run test_cov_tool check --threshold 90
```

→ Blocks PRs if coverage drops below 90%.

**Pre-commit Hook**

```bash
# .husky/pre-commit
flutter analyze && flutter test --coverage
```

**Testing Guide**
Document reusable patterns in:
`docs/testing/TESTING_STACK_GUIDE.md`

---

### **4.9 Why This Approach**

| Problem                                    | Solution                                    |
| ------------------------------------------ | ------------------------------------------- |
| Conflicts between `mockito` and `mocktail` | Use only Mocktail for unit/widget tests     |
| Slow CI due to build_runner                | Eliminate code generation entirely          |
| Inconsistent matcher behavior              | Standardize with Mocktail                   |
| Fake Firebase doesn't match real behavior  | Use real Firebase Emulator for integration  |
| Platform channel errors in tests           | Use `flutter drive` with web for CI         |
| Duplicate stubs or mocks                   | Centralize in helpers/                      |
| Unpredictable coverage                     | Single pipeline with defined layers         |
| Integration tests too slow                 | Parallelize with matrix strategy (optional) |

---

## 🧱 5. Development Workflow

### **Branching & Commits**

* Create one branch per Story or subtask:

  ```
  feature/story-1.1-user-model
  ```
* Use **Conventional Commits**:

  * `feat:` for features
  * `fix:` for bug fixes
  * `refactor:`, `test:`, etc. as appropriate
* PR titles must reference the Story (e.g., `Story 1.1: Implement User Model`)

---

### **Subtask Creation**

If complexity increases or you identify untracked work, create subtasks:

```
Story X.Y.Z.N: [Subtask Title]
```

Example: `Story 0.2.3.2.1: Add environment config validator`
Each subtask must have its own GitHub Issue linked to the parent.

---

### **Pull Request Checklist**

Before marking a Story complete, confirm:

* [ ] **Security**: Reviewed [`PRE_COMMIT_SECURITY_CHECKLIST.md`](./docs/security/PRE_COMMIT_SECURITY_CHECKLIST.md) - no secrets committed
* [ ] All tests pass with **0 errors and 0 skips** (run `flutter test test/unit/`)
* [ ] Each test file includes a one-line purpose comment
* [ ] Documentation in `docs/epic-x/story-y/` is updated
* [ ] Code passes `flutter analyze` with 0 warnings
* [ ] Works on Android, iOS, and Web
* [ ] Commits follow conventional format
* [ ] Branch is up to date with `main`
* [ ] No `.env` files, Firebase configs, or API keys in git history

---

## 🚀 6. Example: Story 0.1 — Initialize Flutter Project

The following example demonstrates the level of detail expected for all future stories.
It is **not an instruction to execute**, but a model for how Claude should reason and act when implementing a Story.

### **Goal:** Initialize Flutter Project

1. **Initialize Project**

   ```bash
   flutter create play_with_me
   git init
   git remote add origin https://github.com/Babas10/playWithMe.git
   ```
2. **Set Up Directory Structure**

   ```
   lib/
     app/
     core/
     features/
   ```
3. **Add Dependencies**
   Update `pubspec.yaml`:

   ```yaml
   dependencies:
     flutter_bloc:
     equatable:
     get_it:
     freezed:
     firebase_core:
     cloud_firestore:
     firebase_auth:

   dev_dependencies:
     build_runner:
     freezed_annotation:
   ```
4. **Commit**

   ```bash
   git add .
   git commit -m "feat(setup): initialize flutter project with bloc architecture"
   ```

---

## 🧾 7. Documentation Structure

All project documentation is organized by Epic and Story under [`docs/`](./docs/).

**Key References**

* **[Epic 0: Project Setup](./docs/epic-0/)**
* **[Firebase Config Security](./docs/security/FIREBASE_CONFIG_SECURITY.md)** *(mandatory reading before Firebase work)*
* **[Pre-Commit Security Checklist](./docs/security/PRE_COMMIT_SECURITY_CHECKLIST.md)** *(MUST review before every commit)*
* **[Local Testing Guide](./docs/testing/LOCAL_TESTING_GUIDE.md)** *(testing workflows and best practices)*

---

## 🧩 8. Core Principles Summary

| Principle               | Description                                            |
| ----------------------- | ------------------------------------------------------ |
| **Security First**      | Never expose Firebase configs or credentials.          |
| **Zero Warnings**       | Code must compile and lint cleanly.                    |
| **Zero Failed Tests**   | All tests must pass and be documented.                 |
| **Full Coverage**       | 90%+ on core logic and BLoCs.                          |
| **Cross-Platform**      | Features must work on Android, iOS, and Web.           |
| **No Work Left Behind** | All pending or partial work tracked via GitHub Issues. |

---

## 🤖 9. Claude Behavior & Interaction Guidelines

### **General Behavior**

Claude acts as a **senior autonomous engineer** — thoughtful, cautious, and precise.

When working on a Story:

1. **Always read the Story’s full context** before coding.
2. **Identify unclear details** — if any ambiguity exists, Claude must:

   * Ask a clarifying question **before** making assumptions, or
   * Propose explicit options and proceed once confirmed.
3. **Never improvise functionality** not specified or justified.
4. **Never modify code outside the Story scope**, unless the issue explicitly requires it.

---

### **When to Create Subtasks**

Claude must propose a new subtask (GitHub Issue) if:

* The implementation reveals missing dependencies or setup steps.
* A shared utility, test helper, or service needs to be created.
* The Story requires data models or widgets not yet defined.

Example:

> *Detected missing `UserModel` when implementing Story 1.2 (Game creation).
> Proposing subtask “Story 1.2.1: Define UserModel with Freezed”.*

---

### **When to Ask Questions**

Claude should ask for clarification when:

* The Story lacks clear success criteria.
* The UI design or user interaction is not defined.
* There’s uncertainty about data flow, storage, or external APIs.
* A security implication (e.g., Firebase rules) is unclear.

---

### **When to Proceed Autonomously**

Claude may proceed **without approval** if:

* The next step is unambiguous and aligns with existing patterns.
* A subtask is purely mechanical (e.g., “Add BLoC tests for existing logic”).
* Documentation updates or refactoring are strictly internal to the Story.

---

### **Behavior During Implementation**

* Claude must always generate:

  * Clean, readable, idiomatic code
  * Corresponding test files (with explanation comments)
  * Documentation updates in `/docs`
* Commit messages must follow Conventional Commits.
* At completion, Claude summarizes:

  * What was done
  * What was learned or improved
  * Any suggested follow-ups

---

### **Communication Tone**

* **Direct** but **respectful**
* **Concise explanations** when justifying design choices
* **No filler text or motivational language** in engineering discussions
* All output must remain **technical and reproducible**

---

**In short:** Claude should behave like a meticulous, security-conscious, test-obsessed engineer — one who documents every decision, asks when uncertain, and never leaves broken or untested code behind.

---

## 📱 10. Current App State (v0.1.0)

As of **October 2025**, the PlayWithMe app has completed its foundational infrastructure phase. Here's what's currently implemented:

### **✅ Completed Foundation (Epic 0)**

**🏗️ Project Architecture:**
- Flutter app with BLoC pattern established
- Multi-environment support (dev/staging/production)
- Cross-platform compatibility (Android, iOS, Web)
- Firebase integration with environment isolation

**🔧 Development Infrastructure:**
- **Story 0.1**: Flutter project initialization with proper directory structure
- **Story 0.2**: Complete Firebase configuration and Flutter flavors
- **Story 0.2.3**: Core application architecture with BLoC pattern
- **Story 0.2.4**: Firebase connection verification and testing infrastructure

**🧪 Testing Framework:**
- Comprehensive test infrastructure with 90%+ coverage requirement
- Unit, widget, and integration test frameworks properly separated
- **Story 0.3.2**: Unit/Integration test separation for fast local development
  - Unit tests in `test/unit/` (run locally and in CI)
  - Integration tests in `test/integration/` (local only)
  - CI-only tests in `test/ci_only/` (CI pipeline only)
- Firebase test helpers for environment-safe testing
- Automated CI/CD pipeline with linting and test validation

**🔒 Security & Configuration:**
- Environment-specific Firebase projects: `playwithme-dev`, `playwithme-stg`, `playwithme-prod`
- Secure configuration management with comprehensive `.gitignore` rules
- Pre-commit security checklist to prevent credential leaks
- Environment files (`.env`, `.env.*`) and API keys blocked from commits
- Application ID isolation between environments
- Firebase configuration tools and validation scripts

### **🏃‍♂️ Current Capabilities**

The app can currently:
- ✅ Build and run on all platforms (Android, iOS, Web)
- ✅ Switch between development environments safely
- ✅ Initialize Firebase with proper environment isolation
- ✅ Execute comprehensive test suites
- ✅ Lint and analyze code for quality standards

### **🎯 Next Development Phase**

With the foundation complete, the app is ready for **Epic 1: Core Features** development:
- User authentication and profile management
- Group creation and management
- Game scheduling and RSVP system
- Court discovery and mapping
- Real-time notifications

### **🔄 Development Commands**

```bash
# Run development environment
flutter run --flavor dev -t lib/main_dev.dart

# Run staging environment
flutter run --flavor stg -t lib/main_stg.dart

# Run production environment
flutter run --flavor prod -t lib/main_prod.dart

# Run unit tests (local development - fast)
flutter test test/unit/

# Run integration tests (local only)
flutter test test/integration/

# Run all tests (what CI runs)
flutter test

# Analyze code
flutter analyze
```

### **📊 Project Metrics**
- **Version**: v0.1.0 (Foundation Release)
- **Test Coverage**: 90%+ (maintained)
- **Platforms**: Android, iOS, Web
- **Environments**: 3 (dev, staging, production)
- **Lines of Code**: ~2,000+ (infrastructure and tests)

The foundation is solid and ready for feature development! 🚀

# Integration Tests

This directory contains integration tests for Firebase Cloud Functions that run against Firebase Emulators.

## Overview

Integration tests validate end-to-end behavior between Firestore, Cloud Functions, and security rules using real Firebase services (via emulator).

### Test Sets

1. **invitationLifecycle.test.ts** - End-to-end invitation flow
   - Admin sends invitation
   - User views pending invitations
   - User accepts/declines invitations
   - Duplicate invitation handling

2. **securityRules.test.ts** - Security rules validation
   - Documents expected behavior with security rules
   - Validates allowed operations (user reads own data, etc.)
   - Documents disallowed operations (reading other users' data, etc.)
   - NOTE: Uses Admin SDK which bypasses rules; for true rules testing use `@firebase/rules-unit-testing`

3. **cloudFunctionIntegration.test.ts** - Cloud Function interactions
   - Verifies group updates when invitation accepted
   - Ensures no writes when invitation declined
   - Tests member visibility after joins
   - Validates proper auth context handling

## Prerequisites

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Install Java Runtime
Firebase Emulators require Java 11 or higher:
```bash
java -version  # Check if installed
```

If not installed:
- **Mac**: `brew install openjdk@11`
- **Ubuntu**: `sudo apt install openjdk-11-jre`
- **Windows**: Download from [AdoptOpenJDK](https://adoptopenjdk.net/)

### 3. Initialize Firebase Emulators
```bash
cd functions
firebase init emulators
```

Select:
- Authentication Emulator (port 9099)
- Firestore Emulator (port 8080)
- Functions Emulator (port 5001)

## Running Tests

### Option 1: Manual (Recommended for Development)

**Terminal 1 - Start Emulators:**
```bash
cd /Users/etiennedubois/PersonalProject/playWithMe/playWithMe
firebase emulators:start --only firestore,auth --project playwithme-dev
```

**Terminal 2 - Run Tests:**
```bash
cd functions
npm run test:integration
```

### Option 2: Run All Tests
```bash
cd functions

# Unit tests only (fast, no emulator needed)
npm run test:unit

# Integration tests only (requires emulator)
npm run test:integration

# All tests (unit + integration)
npm run test:all
```

## Test Configuration

- **Timeout**: 60 seconds per test (integration tests are slower)
- **Concurrency**: Tests run serially (`maxWorkers: 1`) to avoid emulator conflicts
- **Emulator Ports**:
  - Firestore: `localhost:8080`
  - Auth: `localhost:9099`
  - Functions: `localhost:5001`

## Test Environment

Integration tests automatically:
1. Initialize Firebase Admin SDK with emulator configuration
2. Set emulator environment variables
3. Clear Firestore and Auth data before each test
4. Create test users with both Auth and Firestore profiles
5. Clean up after all tests complete

## Helper Functions

The `EmulatorHelper` class provides utilities:

```typescript
// Initialize emulator connection
await EmulatorHelper.initialize();

// Create test user (Auth + Firestore)
const user = await EmulatorHelper.createTestUser({
  email: "test@example.com",
  password: "password123",
  displayName: "Test User"
});

// Create test group
const groupId = await EmulatorHelper.createTestGroup({
  name: "Test Group",
  adminId: user.uid
});

// Create invitation
const invitationId = await EmulatorHelper.createTestInvitation({
  groupId: groupId,
  groupName: "Test Group",
  invitedUserId: user.uid,
  invitedBy: adminId
});

// Clear all data
await EmulatorHelper.clearFirestore();
await EmulatorHelper.clearAuth();

// Cleanup
await EmulatorHelper.cleanup();
```

## Troubleshooting

### Emulator Won't Start
```bash
# Check if ports are in use
lsof -i :8080
lsof -i :9099
lsof -i :5001

# Kill processes using the ports
kill -9 <PID>
```

### Tests Timeout
- Ensure emulators are running before starting tests
- Check emulator logs for errors
- Increase timeout in `jest.integration.config.js`

### Permission Errors
```bash
# Make sure you're using the correct Firebase project
firebase use playwithme-dev

# Verify emulator configuration
cat firebase.json
```

### Connection Refused
- Verify emulators are running: `http://localhost:4000` (Emulator UI)
- Check environment variables: `echo $FIRESTORE_EMULATOR_HOST`
- Restart emulators if needed

## CI/CD Integration

For CI pipelines, use GitHub Actions or similar:

```yaml
- name: Start Firebase Emulators
  run: |
    cd functions
    firebase emulators:start --only firestore,auth --project playwithme-dev &
    sleep 10  # Wait for emulators to start

- name: Run Integration Tests
  run: |
    cd functions
    npm run test:integration

- name: Stop Emulators
  run: |
    lsof -ti:8080 | xargs kill
    lsof -ti:9099 | xargs kill
```

## Coverage

Integration tests validate:
- ✅ Full invitation lifecycle (send → accept/decline)
- ✅ Group membership updates
- ✅ Cross-user data fetching via Cloud Functions
- ✅ Atomic transactions (no partial writes)
- ✅ Proper authentication context
- ✅ Data consistency across operations

For security rules testing with actual rule enforcement, use `@firebase/rules-unit-testing` instead of Admin SDK.

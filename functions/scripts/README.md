# PlayWithMe Test Scripts

Quick-run scripts for setting up and managing test data in the Firebase dev environment.

## 🚀 Quick Start

### 1. Set Up Complete Test Environment

Creates 10 users, friendships, a group, and sample games:

```bash
cd functions
npx ts-node scripts/setupTestEnvironment.ts
```

**Output:** Creates `testConfig.json` with all user IDs, group ID, and game IDs.

### 2. View Test Configuration

```bash
cd functions
npx ts-node scripts/showTestConfig.ts
```

## 📁 Available Scripts

### Core Setup Scripts

#### `setupTestEnvironment.ts` ⭐
**Purpose:** Complete test environment setup (DESTRUCTIVE - clears all data)

**What it does:**
1. Clears entire Firestore database (all collections)
2. Deletes all Firebase Auth users
3. Creates 10 test users (Auth + Firestore profiles)
4. Creates friendships between all users (complete graph - everyone friends with everyone)
5. Creates test group "Beach Volleyball Crew" with all users
6. Creates 4 games (2 completed with results, 2 scheduled)
7. Exports config to `testConfig.json`

**Usage:**
```bash
cd functions
npx ts-node scripts/setupTestEnvironment.ts
```

**Test Users Created:**
- test1@mysta.com - Test1
- test2@mysta.com - Test2
- test3@mysta.com - Test3
- test4@mysta.com - Test4
- test5@mysta.com - Test5
- test6@mysta.com - Test6
- test7@mysta.com - Test7
- test8@mysta.com - Test8
- test9@mysta.com - Test9
- test10@mysta.com - Test10

**Password (all users):** `test1010`

---

#### `showTestConfig.ts`
**Purpose:** Display current test configuration and user IDs

**Usage:**
```bash
cd functions
npx ts-node scripts/showTestConfig.ts
```

**Output:**
- Full test configuration summary
- User IDs for copying into other scripts
- Group and game IDs

---

#### `testConfigLoader.ts`
**Purpose:** Helper module for loading test user IDs in other scripts

**Usage in your scripts:**
```typescript
import {
  loadTestConfig,
  getTestUser,
  getAllTestUserIds,
  getTestGroupId
} from './testConfigLoader';

// Get specific user by index (0 = Test1, 1 = Test2, etc.)
const test1 = getTestUser(0);
const test2 = getTestUser(1);

console.log(`Test1 UID: ${test1.uid}`);
console.log(`Test2 UID: ${test2.uid}`);

// Get all user IDs
const userIds = getAllTestUserIds();

// Get group ID
const groupId = getTestGroupId();

// Print full config
printTestConfig();
```

**Functions:**
- `loadTestConfig()` - Load full configuration
- `getTestUser(index)` - Get user by index (0-9)
- `getTestUserByEmail(email)` - Find user by email
- `getTestUserByName(displayName)` - Find user by display name
- `getAllTestUserIds()` - Get array of all UIDs
- `getTestGroupId()` - Get test group ID
- `getTestGameIds()` - Get array of game IDs
- `printTestConfig()` - Print formatted summary
- `printUserIdSnippet()` - Print code snippet with UIDs

---

### Existing Scripts

#### `createTestGame.ts`
**Purpose:** Create test games with various scenarios

**Usage:** Hardcoded user IDs - update with testConfig.json user IDs first

---

#### `createNemesisTestGames.ts`
**Purpose:** Create games to test nemesis detection feature

**Usage:** Hardcoded user IDs - update with testConfig.json user IDs first

---

#### `deleteGroupGames.ts`
**Purpose:** Delete all games for a specific group

**Usage:** Edit `TARGET_GROUP_ID` constant, then run:
```bash
cd functions
npx ts-node scripts/deleteGroupGames.ts
```

---

#### `reset-data.ts`
**Purpose:** Delete all Firestore data and Auth users (similar to setupTestEnvironment but doesn't recreate)

**Usage:**
```bash
cd functions
npx ts-node scripts/reset-data.ts
```

---

#### `backfill-user-documents.ts`
**Purpose:** Create Firestore user documents for Auth users without profiles

---

#### `backfill-friend-cache.ts`
**Purpose:** Rebuild friend cache (friendIds, friendCount) for all users

---

## 🔧 Updating Existing Scripts to Use testConfig.json

**Before (hardcoded UIDs):**
```typescript
const user1_uid = "I1rVhwkQTyXL1iyBLSDNQPPiFnY2";
const user2_uid = "UqxXx3SdnGSMxUehOtuwMJaglvM2";
const groupId = "9RScLpdoeiG5UHKMD8tB";
```

**After (using testConfigLoader):**
```typescript
import { getTestUser, getTestGroupId } from './testConfigLoader';

const user1_uid = getTestUser(0).uid; // Test1
const user2_uid = getTestUser(1).uid; // Test2
const groupId = getTestGroupId();
```

---

## 📊 Test Data Structure

After running `setupTestEnvironment.ts`:

### Users (10)
- All have complete profiles (firstName, lastName, displayName)
- All are friends with each other (45 friendships)
- All are members of the test group
- Default ELO rating: 1600.0
- Emails: test1@mysta.com through test10@mysta.com
- Password: test1010 (all users)

### Friendships (45)
- Complete graph: Every user is friends with every other user
- All friendships in "accepted" status
- Friend IDs cached in each user document

### Group (1)
- Name: "Beach Volleyball Crew"
- 10 members
- Test1 is creator and admin
- Location: Venice Beach, CA

### Games (4)
1. **Completed:** 2 weeks ago - Test1 & Test2 vs Test3 & Test4 (Team A won 2-0)
2. **Completed:** 1 week ago - Test3 & Test4 vs Test5 & Test6 (Team B won 2-0)
3. **Scheduled:** Tomorrow - Test1, Test2, Test7, Test8
4. **Scheduled:** Next week - Test5, Test6, Test9, Test10

---

## 🔒 Safety

All scripts target **playwithme-dev** only and will fail if run against other projects.

**Project validation check:**
```typescript
const projectId = admin.app().options.projectId;
if (projectId !== "playwithme-dev") {
  console.error("❌ ERROR: This script can only run on playwithme-dev!");
  process.exit(1);
}
```

---

## 💡 Tips

1. **Always run `setupTestEnvironment.ts` first** to generate testConfig.json
2. **Use `showTestConfig.ts`** to get current user IDs for manual testing
3. **Import testConfigLoader** in new scripts instead of hardcoding UIDs
4. **Check testConfig.json timestamp** to see when test data was last regenerated

---

## 🐛 Troubleshooting

**"Test config not found"**
→ Run `npx ts-node scripts/setupTestEnvironment.ts` first

**"This script can only run on playwithme-dev"**
→ Check Firebase project with `firebase use` and switch to dev if needed

**Auth users exist but no Firestore documents**
→ Run `backfill-user-documents.ts`

**Friend cache out of sync**
→ Run `backfill-friend-cache.ts`

---

## 📋 Example: Creating a New Test Script

```typescript
// scripts/myTestScript.ts
import * as admin from "firebase-admin";
import { getTestUser, getTestGroupId, printTestConfig } from './testConfigLoader';

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "playwithme-dev",
  });
}

async function myTestScript() {
  const db = admin.firestore();

  // Load test users
  const alice = getTestUser(0);
  const bob = getTestUser(1);
  const groupId = getTestGroupId();

  console.log(`Testing with ${alice.displayName} (${alice.uid})`);
  console.log(`Group: ${groupId}`);

  // Your script logic here...
}

if (require.main === module) {
  myTestScript()
    .then(() => {
      console.log("✅ Script completed");
      process.exit(0);
    })
    .catch((error) => {
      console.error("❌ Error:", error);
      process.exit(1);
    });
}
```

---

## 🔗 Related Documentation

- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [PlayWithMe Testing Guide](../../docs/testing/LOCAL_TESTING_GUIDE.md)
- [Story 301.8: Nemesis Detection](https://github.com/Babas10/playWithMe/issues/313)

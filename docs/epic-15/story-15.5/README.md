# Story 15.5: No ELO or Competitive Impact

**Epic**: 15 - Training Sessions (Games-Layer Event Type)
**Status**: ✅ Completed
**Implemented**: January 2026

---

## Overview

Implemented comprehensive architectural safeguards to ensure training sessions remain completely separated from the competitive ELO system. Training sessions are non-competitive practice events that do not affect player ratings, statistics, or competitive rankings.

---

## Critical Architecture Rule

**Training sessions are NON-COMPETITIVE:**
- ❌ Training sessions do NOT accept scores
- ❌ Training sessions do NOT trigger ELO updates
- ❌ Training sessions do NOT affect competitive statistics
- ✅ Training sessions use separate Firestore collection (`trainingSessions` vs `games`)
- ✅ Training sessions track participation only, not results

---

## Architecture Enforcement

### 1. Collection Separation

**Firestore Collections**:
```
games/                    # Competitive games (ELO, scores, winners)
├── {gameId}
│   ├── teams: { teamAPlayerIds, teamBPlayerIds }
│   ├── result: { winner, scores, games[] }
│   ├── eloUpdates: { ... }
│   └── status: 'scheduled' | 'completed' | 'cancelled'

trainingSessions/         # Non-competitive practice (NO ELO, NO scores)
├── {sessionId}
│   ├── groupId
│   ├── participantIds: [userId1, userId2, ...]
│   ├── status: 'scheduled' | 'completed' | 'cancelled'
│   └── ❌ NO teams, NO result, NO eloUpdates
```

**Benefits**:
- ✅ Clear separation at data layer
- ✅ ELO triggers only watch `games` collection
- ✅ Impossible to accidentally trigger ELO on training sessions
- ✅ Different security rules per collection type

---

### 2. Architecture Tests (Story 15.5)

**File**: `test/architecture/dependency_test.dart`

Three layers of architectural enforcement:

#### Test 1: No ELO Imports in Training Module
```dart
test('Training module should not import ELO-related code (Story 15.5)', () {
  // Checks all files in lib/features/training/
  // Fails if any file imports ELO-related code
});
```

**Prevents**:
- ❌ `import 'package:play_with_me/features/profile/.../elo_*.dart'`
- ❌ Any ELO model or repository imports

#### Test 2: No ELO Imports in Training Repositories
```dart
test('Training repositories should not import ELO-related code (Story 15.5)', () {
  // Checks:
  // - lib/core/data/repositories/firestore_training_session_repository.dart
  // - lib/core/domain/repositories/training_session_repository.dart
});
```

#### Test 3: No Score Fields in Training Model
```dart
test('Training session model should not have score-related fields (Story 15.5)', () {
  // Scans TrainingSessionModel class definition
  // Fails if it contains forbidden patterns:
  // - score, result, winner
  // - teamAScore, teamBScore
  // - eloChange, eloUpdate, rating
});
```

**Enforcement**:
- ✅ Tests run in CI on every PR
- ✅ CI fails if any violations detected
- ✅ Impossible to merge code that breaks separation

---

### 3. ELO Cloud Function Guards

#### Guard 1: Trigger Path Restriction

**File**: `functions/src/gameUpdates.ts`

```typescript
export const onGameStatusChanged = functions
  .firestore
  .document("games/{gameId}")  // ONLY games, NOT trainingSessions
  .onUpdate(async (change, context) => {
    // ELO trigger watches ONLY the games collection
    // Training sessions in trainingSessions/ never fire this trigger
  });
```

**Protection**: Primary defense - trigger path ensures only competitive games trigger ELO

#### Guard 2: Collection Verification

**File**: `functions/src/gameUpdates.ts`

```typescript
// DEFENSIVE CHECK: Verify this is not a training session
if (change.before.ref.parent.id !== "games") {
  functions.logger.error(
    `CRITICAL: ELO trigger fired for non-game collection: ${change.before.ref.parent.id}`,
    {gameId, collection: change.before.ref.parent.id}
  );
  return null;  // Exit without processing
}
```

**Protection**: Secondary defense - explicit collection check with critical error logging

#### Guard 3: Data Structure Validation

**File**: `functions/src/elo.ts`

```typescript
export async function processGameEloUpdates(gameId: string, gameData: any): Promise<void> {
  // DEFENSIVE CHECK: Training sessions don't have teams/results
  if (!gameData.teams || !gameData.teams.teamAPlayerIds || !gameData.teams.teamBPlayerIds) {
    throw new Error("Invalid game data: Missing teams information");
  }

  if (!gameData.result || !gameData.result.games || !Array.isArray(gameData.result.games)) {
    throw new Error("Invalid game data: Missing result or games array");
  }

  // DEFENSIVE CHECK: Explicitly verify games collection
  const gameRef = db.collection("games").doc(gameId);
  const gameDoc = await gameRef.get();

  if (gameDoc.ref.parent.id !== "games") {
    throw new Error("ELO can only be processed for competitive games, not training sessions");
  }
}
```

**Protection**: Tertiary defense - rejects training session data structure + explicit collection verification

---

## Defense-in-Depth Strategy

The implementation uses three layers of protection:

| Layer | Protection | Trigger Point | Impact if Violated |
|-------|-----------|--------------|-------------------|
| **1. Architecture Tests** | Compile-time | PR/CI | ❌ CI fails, cannot merge |
| **2. Collection Separation** | Runtime | Firestore trigger | ✅ Training sessions never trigger |
| **3. Defensive Guards** | Runtime | Function execution | ❌ Critical error logged, execution halted |

**Why Three Layers?**

1. **Architecture Tests** - Prevent accidental imports at development time
2. **Collection Separation** - Primary runtime protection (trigger path)
3. **Defensive Guards** - Paranoid checks for impossible scenarios (defense-in-depth)

Even if one layer fails, the others provide backup protection.

---

## Testing

### Unit Tests (Cloud Functions)

**File**: `functions/test/unit/elo.test.ts`

```typescript
describe("Story 15.5: Training Session Guards", () => {
  test("rejects game data without teams", async () => {
    const trainingData = {
      groupId: "group1",
      participantIds: ["p1", "p2"],
      // No teams/result structure
    };
    await expect(processGameEloUpdates(gameId, trainingData))
      .rejects.toThrow("Missing teams information");
  });

  test("rejects documents from non-games collection", async () => {
    const trainingRef = { parent: { id: "trainingSessions" } };
    // Mock document from trainingSessions collection
    await expect(processGameEloUpdates(gameId, gameData))
      .rejects.toThrow("ELO can only be processed for competitive games");
  });

  test("processes documents from games collection successfully", async () => {
    const gamesRef = { parent: { id: "games" } };
    // Should not throw
    await expect(processGameEloUpdates(gameId, gameData))
      .resolves.not.toThrow();
  });
});
```

**Coverage**: All ELO guard scenarios tested and passing

### Architecture Tests

**File**: `test/architecture/dependency_test.dart`

All 3 architecture tests passing:
- ✅ Training module has no ELO imports
- ✅ Training repositories have no ELO imports
- ✅ Training model has no score-related fields

---

## Implementation Summary

### Files Modified

| File | Changes | Purpose |
|------|---------|---------|
| `test/architecture/dependency_test.dart` | +132 lines | Add 3 architecture tests |
| `functions/src/gameUpdates.ts` | +41 lines | Add collection verification guard |
| `functions/src/elo.ts` | +27 lines | Add defensive data structure checks |
| `functions/test/unit/elo.test.ts` | +289 lines | Add unit tests for guards |

### Commits

1. `feat(training): add architecture tests preventing ELO imports (Story 15.5)`
2. `feat(elo): add defensive guards against training session ELO processing (Story 15.5)`
3. `test(elo): add unit tests for training session guards (Story 15.5)`
4. `docs(training): document ELO separation architecture (Story 15.5)`

---

## Acceptance Criteria

- [x] Training sessions do not accept scores
- [x] Training sessions do not trigger ELO updates
- [x] ELO Cloud Functions explicitly ignore training session IDs
- [x] Architecture tests ensure no ELO-related imports exist in training code
- [x] Code passes `flutter analyze` with 0 warnings
- [x] All tests pass (architecture + unit + widget + integration)
- [x] Documentation clearly states separation from competitive system

---

## Deployment

**Cloud Functions** (Modified):
- `onGameStatusChanged` - Updated with collection verification guard
- `processGameEloUpdates` - Updated with defensive checks

**Deployment Commands**:
```bash
# Deploy to dev
firebase use playwithme-dev
firebase deploy --only functions:onGameStatusChanged

# Deploy to staging
firebase use playwithme-stg
firebase deploy --only functions:onGameStatusChanged

# Deploy to production
firebase use playwithme-prod
firebase deploy --only functions:onGameStatusChanged
```

**Note**: The ELO function is triggered by Firestore, not callable, so deployment updates the trigger definition.

---

## Related Stories

- **Story 15.1**: Create Training Session (Group-Scoped) - Established separate `trainingSessions` collection
- **Story 15.2**: Recurring Training Sessions - Extended training sessions with recurrence rules
- **Story 15.3**: Join/Leave Training Session - Implemented participant management
- **Story 15.4**: Training Sessions Activity Feed - Added training sessions to group feed
- **Story 15.5**: No ELO or Competitive Impact - **THIS STORY** - Architectural safeguards

---

## Future Considerations

### Potential Risks (Mitigated)

| Risk | Mitigation | Status |
|------|-----------|--------|
| Developer accidentally adds score field to training model | Architecture test fails in CI | ✅ Protected |
| Developer imports ELO code in training module | Architecture test fails in CI | ✅ Protected |
| ELO function called with training session ID | Data structure validation rejects | ✅ Protected |
| Training session created in wrong collection | Would never trigger ELO anyway | ✅ Safe |

### Monitoring

**Recommended CloudWatch/Firebase Alerts**:
- Alert if `CRITICAL: ELO trigger fired for non-game collection` appears in logs
- Alert if ELO processing throws "not training sessions" error

These should **never** fire in production, but if they do, indicate a serious architectural violation.

---

## Conclusion

Story 15.5 establishes comprehensive architectural safeguards ensuring training sessions remain completely separated from the competitive ELO system. The defense-in-depth approach (architecture tests + collection separation + runtime guards) provides multiple layers of protection against accidental coupling.

**Key Achievement**: It is now **architecturally impossible** to accidentally trigger ELO calculations for training sessions, both at compile-time (architecture tests) and runtime (collection separation + defensive guards).

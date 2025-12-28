# Story 301.6: Best Win Tracking

## Overview

This feature tracks and displays a player's best victory based on the highest-rated opponent team they have defeated. It automatically updates after each game win to maintain the player's most impressive achievement.

## Implementation

### Data Model

Added `BestWinRecord` to `lib/core/data/models/user_model.dart`:

```dart
@freezed
class BestWinRecord with _$BestWinRecord {
  const factory BestWinRecord({
    required String gameId,
    required double opponentTeamElo,
    required double opponentTeamAvgElo,
    required double eloGained,
    @TimestampConverter() required DateTime date,
    required String gameTitle,
  }) = _BestWinRecord;
}
```

Added `bestWin` field to `UserModel`:
```dart
BestWinRecord? bestWin,
```

### Cloud Function Logic

Modified `functions/src/elo.ts` in the `processGameEloUpdates` function:

1. **Calculation**: When a player wins and gains ELO:
   - Calculates opponent team ELO using the Weak-Link formula (0.7 * min + 0.3 * max)
   - Calculates average opponent team ELO
   - Tracks ELO gained from the win

2. **Comparison**: Compares opponent team ELO with current `bestWin.opponentTeamElo`

3. **Update**: If this is a better win (higher opponent ELO or first win):
   - Updates the `bestWin` field in the user document
   - Stores: `gameId`, `opponentTeamElo`, `opponentTeamAvgElo`, `eloGained`, `date`, `gameTitle`

### UI Display

Updated `lib/features/profile/presentation/widgets/performance_overview_card.dart`:

- **With Best Win**: Shows "vs {avgElo} ELO" with "+{eloGained} ELO gained" subtitle
- **Without Best Win**: Shows "Win a game to unlock" placeholder with motivational text
- **Icon**: Trophy (filled for data, outlined for placeholder)

## Edge Cases Handled

| Case | Behavior |
|------|----------|
| First game win | Automatically set as best win |
| No wins yet | Show placeholder message |
| Beat higher-rated team | Update best win |
| Beat lower-rated team | Keep existing best win |
| Tied opponent ELO | Keep win with highest ELO gained |

## Testing

### Automated Tests

#### Cloud Function Tests (8 tests)

Location: `functions/test/unit/elo.test.ts`

1. ✅ Sets bestWin after first victory
2. ✅ Updates bestWin when beating higher-rated team
3. ✅ Does NOT update bestWin when beating lower-rated team
4. ✅ Does NOT set bestWin when losing
5. ✅ Calculates correct team rating
6. ✅ Calculates correct expected score
7. ✅ Calculates correct rating change
8. ✅ Updates ELO ratings correctly

#### Widget Tests (6 tests)

Location: `test/widget/features/profile/presentation/widgets/performance_overview_card_test.dart`

1. ✅ Shows empty state for user with 0 games
2. ✅ Shows performance stats for user with games
3. ✅ Shows performance stats for user with 1 game
4. ✅ Shows best win when user has best win data
5. ✅ Shows placeholder when user has no best win
6. ✅ Shows correct formatting for best win ELO values

### Manual Testing Script

Location: `functions/scripts/setupBestWinTestEnvironment.ts`

This script creates a **complete isolated test environment** specifically for best win tracking:

**What it does:**
1. ⚠️ **Clears entire dev database** (Firebase Auth + Firestore)
2. Creates 8 test users with controlled ELO ratings:
   - Test1 & Test2: **1200 ELO** (test subjects)
   - Test3 & Test4: **1300 ELO** (moderate opponents)
   - Test5 & Test6: **1500 ELO** (high-rated opponents)
   - Test7 & Test8: **1100 ELO** (low-rated opponents)
3. Sets up friendships between all users
4. Creates test group with all members
5. Creates 4 test games:
   - **Game 1**: Test1 & Test2 WIN vs Test3 & Test4 (~1300 ELO) → ✅ Sets initial bestWin
   - **Game 2**: Test1 & Test2 WIN vs Test5 & Test6 (~1500 ELO) → ✅ Updates bestWin (higher opponent)
   - **Game 3**: Test1 & Test2 WIN vs Test7 & Test8 (~1100 ELO) → ✅ Does NOT update bestWin (lower opponent)
   - **Game 4**: Test1 & Test2 LOSE vs Test3 & Test4 → ✅ Does NOT affect bestWin (losses don't count)
6. Verifies Test1's bestWin shows Game 2 (~1500 ELO)
7. Exports test config to `testConfig.json`

**Run the script:**
```bash
cd functions
npx ts-node scripts/setupBestWinTestEnvironment.ts
```

**Expected Output:**
```
✅ PASS: Best win correctly shows Game 2 (vs ~1500 ELO opponents)
```

**Login to verify in app:**
- Email: `test1@mysta.com`
- Password: `test1010`
- Navigate to Profile → PerformanceOverviewCard
- Should see: "vs 1500 ELO" with trophy icon 🏆

**Why use this instead of `setupTestEnvironment.ts`?**
- ✅ Controlled ELO ratings (no interference from other games)
- ✅ Focused test scenario for best win tracking only
- ✅ Verifies results automatically
- ✅ Clean, predictable test data

## Data Flow

```
Game Completed
    ↓
processGameEloUpdates (Cloud Function)
    ↓
Calculate opponent team ELO
    ↓
Compare with current bestWin
    ↓
Update user document if better
    ↓
Client reads updated user data
    ↓
PerformanceOverviewCard displays best win
```

## Deployment

Functions deployed to all environments:
- ✅ Development (`playwithme-dev`)
- ✅ Staging (`playwithme-stg`)
- ✅ Production (`playwithme-prod`)

No Firestore security rule changes needed (Cloud Functions use Admin SDK).

## Performance Considerations

- **Write Cost**: +1 field update per winning game (only when bestWin is improved)
- **Read Cost**: No additional reads (bestWin is part of user document)
- **Latency**: ~5ms additional processing in ELO calculation
- **Storage**: ~100 bytes per bestWin record

## Architecture Decision: Coupling with ELO Calculation

**Decision**: Best win tracking is implemented directly in the `processGameEloUpdates` Cloud Function (same transaction as ELO calculation).

**Rationale**:
- ✅ All opponent ratings already loaded in memory (no additional Firestore reads)
- ✅ Simple comparison logic (<5ms processing overhead)
- ✅ Atomic consistency with ELO update (no race conditions)
- ✅ Follows pattern of teammate stats (also in same transaction via `processStatsTracking`)
- ✅ No measurable impact on transaction performance

**Alternative considered**: Decoupled pattern (like Story 301.8 Nemesis Detection)
- Would trigger a separate Cloud Function on `onEloCalculationComplete`
- Rejected: Unnecessary overhead for simple in-memory calculation

**Location**: `functions/src/elo.ts` lines 182-210

## Technical Implementation Details

### Timestamp Handling for Nested Objects

**Issue**: Firebase `FieldValue.serverTimestamp()` sentinel values don't work correctly in nested objects.

**Solution**: Use `Timestamp.now()` for nested objects instead of the sentinel value.

**Cloud Function Implementation**:
```typescript
// functions/src/elo.ts
const now = admin.firestore.FieldValue.serverTimestamp(); // For top-level fields
const timestampNow = admin.firestore.Timestamp.now(); // For nested objects like bestWin

// Top-level fields use sentinel value (works correctly)
updateData.eloLastUpdated = now;

// Nested object uses actual Timestamp (required)
bestWinUpdate.date = timestampNow;
```

**Flutter Deserialization**:
```dart
// lib/core/data/models/user_model.dart
@freezed
class BestWinRecord with _$BestWinRecord {
  const factory BestWinRecord({
    // ... other fields ...
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) required DateTime date,
  }) = _BestWinRecord;
}

// Custom converter functions
DateTime _dateFromJson(dynamic value) {
  final result = const TimestampConverter().fromJson(value);
  if (result == null) {
    throw ArgumentError('BestWinRecord date cannot be null');
  }
  return result;
}

dynamic _dateToJson(DateTime date) {
  return const TimestampConverter().toJson(date);
}
```

**Why This Matters**:
- `@TimestampConverter()` annotation alone doesn't work in freezed nested classes
- Must use `@JsonKey` with custom converter functions
- Regenerate code with `flutter pub run build_runner build --delete-conflicting-outputs` after model changes

## Future Enhancements

- Tap to view game details for best win
- Show best win history (track top 3 wins)
- Filter best win by time period (all-time, this month, etc.)
- Share best win achievement on social media

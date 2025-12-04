# Story 14.2: Add Teams to Completed Game

## Overview
Implements team assignment functionality for completed games, allowing game creators to assign players to Team A and Team B with validation to ensure all players are assigned and no player is on both teams.

## Implementation Details

### 1. Data Model Layer
**File**: `lib/core/data/models/game_model.dart`
- Added `GameTeams` model with `freezed`:
  - `teamAPlayerIds`: List of player IDs on Team A
  - `teamBPlayerIds`: List of player IDs on Team B
- Helper methods for validation:
  - `areAllPlayersAssigned()`: Checks if all game players are assigned
  - `hasPlayerOnBothTeams()`: Validates no player is on both teams
  - `getUnassignedPlayers()`: Returns list of unassigned players
  - `isValid()`: Comprehensive validation
- Added `teams` field to `GameModel` (optional, for completed games only)

### 2. Repository Layer
**File**: `lib/core/domain/repositories/game_repository.dart`
- Added `updateGameTeams(String gameId, String userId, GameTeams teams)` method

**File**: `lib/core/data/repositories/firestore_game_repository.dart`
- Implemented `updateGameTeams` with:
  - Permission check: only game creator can update teams
  - Status validation: only completed games can have teams assigned
  - Team validation: no duplicates, all players assigned
  - Atomic Firestore update with merge

**File**: `test/unit/core/data/repositories/mock_game_repository.dart`
- Added `updateGameTeams` implementation mirroring production logic

### 3. BLoC Layer
**Files**: `lib/features/games/presentation/bloc/record_results/`
- **Events**:
  - `LoadGameForResults`: Load game and initialize team state
  - `AssignPlayerToTeamA`: Move player to Team A
  - `AssignPlayerToTeamB`: Move player to Team B
  - `RemovePlayerFromTeam`: Move player to unassigned
  - `SaveTeams`: Persist teams to Firestore

- **States**:
  - `RecordResultsInitial`: Initial state
  - `RecordResultsLoading`: Loading game
  - `RecordResultsLoaded`: Game loaded with team assignment UI state
  - `RecordResultsSaving`: Saving teams
  - `RecordResultsSaved`: Teams saved successfully
  - `RecordResultsError`: Error state

- **BLoC Logic**:
  - Manages three lists: teamA, teamB, unassigned players
  - Ensures player can only be in one list at a time
  - Validates all players assigned before allowing save
  - `canSave` helper: returns true when all players assigned and both teams non-empty

### 4. UI Layer
**File**: `lib/features/games/presentation/pages/record_results_page.dart`
- **RecordResultsPage**: Main page with BLoC provider setup
- **Team Sections**: Visual cards for Team A (blue) and Team B (red)
- **Unassigned Players**: Section showing players not yet assigned
- **Player Assignment**: Buttons to assign to Team A or Team B
- **Validation UI**:
  - Disabled save button until all players assigned
  - Visual feedback (green checkmark) when complete
  - Error messages for validation failures
- **Navigation**: Automatically returns to game details on save

**File**: `lib/features/games/presentation/pages/game_details_page.dart`
- Updated `GameCompletedSuccessfully` listener to navigate to RecordResultsPage
- Removed placeholder TODO comment

### 5. Testing
**File**: `test/unit/core/data/models/game_teams_test.dart` (10 tests)
- Tests for all `GameTeams` validation methods
- Tests for `toJson/fromJson` serialization
- Edge cases: empty teams, duplicate players, partial assignment

**File**: `test/unit/features/games/presentation/bloc/record_results/record_results_bloc_test.dart` (19 tests)
- Initial state validation
- `LoadGameForResults`: success, error, not completed, existing teams
- `AssignPlayerToTeamA/B`: assign from unassigned, move between teams
- `RemovePlayerFromTeam`: move to unassigned
- `SaveTeams`: success, validation errors, permission errors
- State helper methods: `allPlayersAssigned`, `canSave`

**Total**: 29 new tests, all passing, 781 total unit tests

## User Flow
1. User marks game as completed (Story 14.1)
2. App navigates to Record Results page
3. User sees list of unassigned players
4. User taps "Team A" or "Team B" button for each player
5. Players move to respective team sections
6. Once all players assigned, "Save Teams" button enables
7. User taps "Save Teams"
8. Teams persist to Firestore
9. User returns to game details

## Validation Rules
1. **All players must be assigned**: Cannot save until unassigned list is empty
2. **No duplicates**: Player cannot be on both teams simultaneously
3. **Both teams non-empty**: Each team must have at least one player
4. **Creator-only**: Only game creator can assign teams
5. **Completed games only**: Can only assign teams to completed games

## Technical Decisions

### Team Assignment UX
- **Button-based assignment** instead of drag-and-drop for better mobile UX
- **Visual color coding**: Blue for Team A, Red for Team B
- **Immediate feedback**: Players move instantly when assigned
- **Clear unassigned state**: Dedicated section shows who needs assignment

### State Management
- **Three-list architecture**: TeamA, TeamB, Unassigned
- **Single source of truth**: BLoC manages all assignment state
- **Validation in multiple layers**: UI, BLoC, Repository, Firestore
- **Optimistic UI**: Immediate state updates with server sync

### Data Model
- **Optional teams field**: Only populated for completed games
- **Immutable with freezed**: Type-safe, null-safe team data
- **Helper methods on model**: Validation logic close to data
- **Firestore-friendly**: Direct JSON serialization

## Future Enhancements
- Support for group admins to assign teams (not just creator)
- Drag-and-drop team assignment for web/desktop
- Auto-balance teams by player skill
- Save draft teams (allow editing before marking complete)
- Team names (instead of generic "Team A" / "Team B")
- Support for different team sizes (3v3, 1v1, etc.)

## Files Changed
- `lib/core/data/models/game_model.dart` - Added GameTeams model and teams field
- `lib/core/domain/repositories/game_repository.dart` - Added updateGameTeams method
- `lib/core/data/repositories/firestore_game_repository.dart` - Implemented updateGameTeams
- `lib/features/games/presentation/bloc/record_results/` - New BLoC (3 files)
- `lib/features/games/presentation/pages/record_results_page.dart` - New page
- `lib/features/games/presentation/pages/game_details_page.dart` - Updated navigation
- `test/unit/core/data/repositories/mock_game_repository.dart` - Added updateGameTeams
- `test/unit/core/data/models/game_teams_test.dart` - New tests (10)
- `test/unit/features/games/presentation/bloc/record_results/record_results_bloc_test.dart` - New tests (19)

## Dependencies
- Story 14.1 (Mark Game as Completed) - Required for navigation flow
- No new package dependencies

## Testing Checklist
- [x] Unit tests for GameTeams model (10 tests)
- [x] Unit tests for RecordResultsBloc (19 tests)
- [x] All existing tests still pass (781 total)
- [x] Flutter analyze passes (no new warnings)
- [x] Permission checks validated
- [x] Validation logic comprehensive

## Security
- ✅ Creator-only permission enforced at repository layer
- ✅ No sensitive data exposure
- ✅ Validation prevents invalid team states
- ✅ Firestore security rules should enforce game completion status

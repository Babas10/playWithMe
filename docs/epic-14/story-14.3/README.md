# Story 14.3: Enter Final Score (Sets and Points)

## Overview
Implements comprehensive score entry functionality for beach volleyball play sessions, allowing users to record multiple games with flexible set formats. Supports tracking complete play sessions where friends meet and play multiple individual games, with each game counting toward ELO ratings.

## Key Concepts

### Play Session vs Individual Games
- **GameModel (Play Session)**: Represents a scheduled event where friends meet to play
- **Individual Games**: The actual games played during that session (typically 5-7 games)
- **ELO Calculation**: Each individual game counts toward ELO ratings independently

### Example Flow
```
User schedules "Friday Beach Volleyball" (GameModel)
↓
Teams are assigned: Team A (Player 1, Player 2) vs Team B (Player 3, Player 4)
↓
Session Results:
  - Game 1: Team A wins 21-18 (single set)
  - Game 2: Team B wins 21-19 (single set)
  - Game 3: Team A wins 21-17 (single set)
  - Game 4: Team A wins 22-20 (single set)
  - Game 5: Team B wins 21-19 (single set)
  - Game 6: Team A wins 21-16 (single set)
↓
Final Session Score: Team A wins 4-2
```

## Implementation Details

### 1. Data Model Layer
**File**: `lib/core/data/models/game_model.dart`

#### SetScore Model
Represents a single set with beach volleyball validation (first to 21, win by 2):
```dart
class SetScore {
  final int teamAPoints;
  final int teamBPoints;
  final int setNumber;

  bool isValid() // Validates 21+ points, win by 2
  String? get winner // Returns 'teamA' or 'teamB'
}
```

#### IndividualGame Model
Represents one game with 1-3 sets:
```dart
class IndividualGame {
  final int gameNumber;
  final List<SetScore> sets;
  final String winner;

  bool isValid() // Validates sets and winner
  Map<String, int> get setsWon // Count wins per team
}
```

#### GameResult Model
Represents the complete session result:
```dart
class GameResult {
  final List<IndividualGame> games;
  final String overallWinner; // Who won more games

  bool isValid() // Validates all games
  Map<String, int> get gamesWon // Total games won per team
  int get totalGames
  String get scoreDescription // e.g., "4-2"
}
```

### 2. Repository Layer
**File**: `lib/core/domain/repositories/game_repository.dart`
- Added `updateGameResult(String gameId, String userId, GameResult result)` method

**File**: `lib/core/data/repositories/firestore_game_repository.dart`
- Implemented with validation:
  - Permission check: only game creator can update
  - Status validation: only completed games
  - Team validation: teams must be assigned first
  - Result validation: all games must be valid

**File**: `test/unit/core/data/repositories/mock_game_repository.dart`
- Added matching implementation for tests

### 3. BLoC Layer
**Files**: `lib/features/games/presentation/bloc/score_entry/`

#### Helper Classes (in state file)
- **SetScoreData**: Tracks score entry for a single set
  - Validates input in real-time
  - Determines winner when complete

- **GameData**: Tracks data for one game
  - Manages 1-3 sets
  - Validates all sets for the game
  - Determines game winner

#### Events
- `LoadGameForScoreEntry`: Load game and existing scores
- `SetGameCount(int count)`: Set number of games (1-10)
- `SetGameFormat(int gameIndex, int numberOfSets)`: Set format for specific game (1, 2, or 3 sets)
- `UpdateSetScore(int gameIndex, int setIndex, int? teamAPoints, int? teamBPoints)`: Update specific set score
- `SaveScores(String userId)`: Save all entered scores

#### States
- `ScoreEntryInitial`: Initial state
- `ScoreEntryLoading`: Loading game
- `ScoreEntryLoaded`: Ready for score entry
  - Tracks `gameCount`, `games` list
  - Helpers: `allGamesComplete`, `overallWinner`, `canSave`
- `ScoreEntrySaving`: Saving to Firestore
- `ScoreEntrySaved`: Success
- `ScoreEntryError`: Error with message

#### BLoC Logic
- Dynamically manages list of games
- Each game can have different format (1-3 sets)
- Real-time validation per set/game
- Prevents saving until all games complete and have winner

### 4. UI Layer

#### Score Entry Page
**File**: `lib/features/games/presentation/pages/score_entry_page.dart`

**Multi-Step Flow:**

**Step 1: Game Count Selection**
- Grid of buttons (1-10) to select number of games played
- Large, easy-to-tap interface

**Step 2: Score Entry Form**
- Scrollable list of game cards
- Each card shows:
  - Game number and completion status
  - Format selector (1 set / Best of 2 / Best of 3)
  - Set score inputs with validation
  - Real-time validation feedback (checkmarks/errors)

**Step 3: Save**
- Bottom bar shows overall winner when complete
- Save button enabled only when all games valid
- Progress indicator shows games completed

**UI Components:**
- `_GameCountSelector`: Initial selection screen
- `_ScoreEntryForm`: Main form with all games
- `_GameCard`: Individual game with format selector and sets
- `_GameFormatSelector`: Segmented button for 1/2/3 sets
- `_SetScoreInput`: StatefulWidget with persistent TextEditingControllers for reliable input
- `_SaveButton`: Bottom save bar with winner display

**Validation Feedback:**
- Green checkmark: Valid set/game
- Red error icon: Invalid score (not win by 2, etc.)
- Disabled save button: Not all games complete
- Live winner calculation displayed

#### Game Result View Page
**File**: `lib/features/games/presentation/pages/game_result_view_page.dart`

**Purpose:** Display completed game scores to all users in a clear, visually appealing format

**Features:**
- Overall score display with winner highlighting
- Team roster (if assigned)
- Individual game breakdown with:
  - Game number and winner
  - Sets won summary
  - Detailed set-by-set scores
- Color-coded teams (blue/red)
- Trophy icon and winner badge
- Responsive layout for all screen sizes

**UI Components:**
- `_OverallResultCard`: Final score with gradient background and trophy
- `_TeamScore`: Circular score display with winner highlighting
- `_TeamNamesCard`: Side-by-side team rosters
- `_IndividualGameCard`: Detailed breakdown per game
- `_TeamList`: Player list for each team
- `_QuickScoreDisplay`: Compact score preview (used in game details)

**Navigation:**
- Accessible from game details page when result exists
- Shows preview card with quick score and "View Results" CTA
- No authentication required to view (group members only)

### 5. Navigation

**Score Entry Flow:**
**File**: `lib/features/games/presentation/pages/record_results_page.dart`
- After saving teams, automatically navigates to `ScoreEntryPage`
- Uses `pushReplacement` to prevent back navigation issues

**Result Viewing:**
**File**: `lib/features/games/presentation/pages/game_details_page.dart`
- Added `_ViewResultsCard` widget that displays when `game.result != null`
- Shows quick preview with overall score
- Tappable card navigates to `GameResultViewPage` for full details
- Positioned between game info and location cards for visibility

### 6. Testing
**File**: `test/unit/core/data/models/game_result_test.dart` (28 tests)
- SetScore validation (all formats)
- IndividualGame validation (single set, best of 2/3)
- GameResult validation (multi-game sessions)
- JSON serialization
- Real-world scenarios (4-2 wins, 7-game sessions, etc.)

**File**: `test/unit/features/games/presentation/bloc/score_entry/score_entry_bloc_test.dart` (20 tests)
- Load game (with/without existing results)
- Set game count
- Set game format per game
- Update scores for multiple games
- Save valid sessions
- Validation errors
- State helpers

**Total**: 48 new tests, all passing
**Overall**: 829 tests passing (781 original + 48 new)

## User Flow

### Complete Flow Example

**Entering Scores (Game Creator):**
1. User marks game as completed → Teams assigned (Story 14.2)
2. App navigates to Score Entry page
3. User selects "How many games did you play?" → Selects 6
4. For each game:
   - Select format (default: 1 set, can change to Best of 2/3)
   - Enter scores (Team A vs Team B)
   - See real-time validation
5. Once all 6 games complete, see overall winner displayed
6. Tap "Save Scores"
7. Scores persist to Firestore
8. Returns to game details page

**Viewing Results (Any Group Member):**
1. User opens game details page
2. If game has results, sees "Game Results" preview card with quick score
3. Taps card to view full details
4. Views comprehensive breakdown:
   - Overall winner with trophy
   - Team rosters
   - Individual game results
   - Set-by-set scores with winner highlighting
5. Can navigate back to game details or share results (future enhancement)

## Validation Rules

### Set-Level Validation
- **Regular Sets**: First to 21, win by 2
  - Valid: 21-19, 21-0, 22-20, 25-23
  - Invalid: 21-20, 20-18, 22-21

### Game-Level Validation
- Must have at least 1 set
- All sets must be valid
- Set numbers must be sequential (1, 2, 3)
- Winner must have won majority of sets

### Session-Level Validation
- Must have at least 1 game
- All games must be valid
- Game numbers must be sequential
- Overall winner must have won more games

### Business Rules
- Can only enter scores for completed games
- Teams must be assigned before entering scores
- Only game creator can enter/edit scores
- Scores can be edited by loading existing result

## Technical Decisions

### Multi-Game Architecture
- **Three-level structure**: Session → Games → Sets
- **Flexible format**: Each game can have different set count
- **Dynamic UI**: Form adapts to selected game count and formats
- **State management**: Complex nested state in BLoC

### Data Storage
- Single `GameResult` object contains all games
- Stored as JSON in Firestore
- Proper serialization with custom converters
- Easy to query for ELO calculations

### UX Decisions
- **Button-based game count selection**: Faster than text input
- **Segmented format selector**: Clear, mutually exclusive options
- **Real-time validation**: Immediate feedback on invalid scores
- **Progress tracking**: Show completion status per game
- **Disabled save until complete**: Prevent partial data

### Validation Strategy
- **Multi-layer validation**: Model, BLoC, Repository
- **Client-side first**: Fast feedback in UI
- **Server-side enforcement**: Security in repository
- **Helper methods on models**: Reusable validation logic

## Future Enhancements
- Auto-calculate and display match statistics (total points, longest set, etc.)
- Support for group admins to enter scores (not just creator)
- Undo/redo score entry
- Quick entry mode: Assume all single-set games, batch entry
- Template formats: Save common session patterns (e.g., "6 single-set games")
- Score history: View past session details
- Export to CSV/PDF for record keeping
- Support for other sports (basketball, soccer) with different scoring rules
- Live score entry: Enter as games are played, not after session

## Files Changed

### New Files
- `lib/features/games/presentation/bloc/score_entry/score_entry_event.dart`
- `lib/features/games/presentation/bloc/score_entry/score_entry_state.dart`
- `lib/features/games/presentation/bloc/score_entry/score_entry_bloc.dart`
- `lib/features/games/presentation/pages/score_entry_page.dart`
- `lib/features/games/presentation/pages/game_result_view_page.dart` ⭐ NEW
- `test/unit/core/data/models/game_result_test.dart`
- `test/unit/features/games/presentation/bloc/score_entry/score_entry_bloc_test.dart`

### Modified Files
- `lib/core/data/models/game_model.dart` - Added SetScore, IndividualGame, GameResult models
- `lib/core/data/models/game_model.freezed.dart` - Generated code
- `lib/core/data/models/game_model.g.dart` - Generated code
- `lib/core/domain/repositories/game_repository.dart` - Added updateGameResult method
- `lib/core/data/repositories/firestore_game_repository.dart` - Implemented updateGameResult
- `lib/features/games/presentation/pages/record_results_page.dart` - Added navigation to score entry
- `lib/features/games/presentation/pages/game_details_page.dart` - Added result preview card and navigation ⭐ NEW
- `lib/features/games/presentation/pages/score_entry_page.dart` - Fixed TextField and overflow issues ⭐ UPDATED
- `test/unit/core/data/repositories/mock_game_repository.dart` - Added updateGameResult

## Dependencies
- Story 14.2 (Team Assignment) - Required for team data
- No new package dependencies
- Uses existing BLoC, Freezed, Firestore patterns

## Testing Checklist
- [x] Unit tests for SetScore model (10 tests)
- [x] Unit tests for IndividualGame model (6 tests)
- [x] Unit tests for GameResult model (12 tests)
- [x] Unit tests for ScoreEntryBloc (20 tests)
- [x] All existing tests still pass (829 total)
- [x] Flutter analyze passes (no new warnings)
- [x] Permission checks validated
- [x] Validation logic comprehensive
- [x] Real-world scenarios tested (multi-game sessions)

## Security
- ✅ Creator-only permission enforced at repository layer
- ✅ No sensitive data exposure
- ✅ Validation prevents invalid game states
- ✅ Firestore security rules should enforce game completion status
- ✅ No secrets or API keys committed

## Performance Considerations
- Efficient state management with immutable data structures
- Minimal re-renders with targeted state updates
- Lazy building of UI components
- Optimistic updates when typing scores
- Single Firestore write for entire session

## Accessibility
- Labeled input fields for screen readers
- Sufficient touch targets (buttons 70x70)
- Color not sole indicator (uses icons + color)
- Clear error messages
- Logical tab order for keyboard navigation

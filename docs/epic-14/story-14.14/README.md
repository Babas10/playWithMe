# Story 14.14: Democratize Game Result Entry

## Overview
This story implements the "Democratized Result Entry" pattern, allowing any participant of a game to enter scores once the game is finished, removing the dependency on the Game Creator.

## Key Changes

### 1. UI Logic (GameDetailsPage)
The "Enter Results" button is now visible to **all participants** (and the creator) if:
- The game status is `completed` OR `in_progress`.
- OR The game's scheduled time is in the past.
- AND The game does not yet have a result recorded.
- AND The game is not cancelled or in verification state.

This logic is encapsulated in `GameModel.canUserEnterResults(userId)`.

### 2. Repository Permissions (FirestoreGameRepository)
The permission checks in `saveGameResult` and `updateGameTeams` have been relaxed:
- **Old:** `if (!isCreator) throw ...`
- **New:** `if (!isPlayer && !isCreator) throw ...`

### 3. Implicit Completion
The system no longer requires an explicit "Mark as Completed" step by the creator before results can be entered. If a participant enters results for a scheduled game, the game status implicitly transitions to `verification` (via Story 14.11 flow).

## Security & Validation
- Only verified participants (in `playerIds`) can submit results.
- Cancelled games cannot have results entered.
- Verification status blocks re-entry until resolved (or edited).

## Testing
- **Widget Tests:** `game_details_result_entry_test.dart` verifies button visibility for various user roles and game states.
- **Integration Tests:** `game_result_persistence_test.dart` verifies the end-to-end flow of a participant saving data.
- **Unit Tests:** BLoC tests updated to ensure state transitions allow non-completed games to proceed to result entry.

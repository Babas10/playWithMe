# Story 290: Show ELO Adaptation in Game Result

## Objective
The goal of this story was to display the ELO rating change (adaptation) for each player in the Game Result view. This provides immediate feedback to players about how a game affected their ranking.

## Implementation Details

### 1. Data Layer (`UserRepository`)
We added a new method to the `UserRepository` interface and `FirestoreUserRepository` implementation:

```dart
Future<RatingHistoryEntry?> getRatingHistoryForGame(String userId, String gameId);
```

This method queries the `users/{userId}/ratingHistory` subcollection to find the specific entry corresponding to the completed game.

### 2. State Management (`GameDetailsBloc`)
The `GameDetailsBloc` was updated to fetch ELO history when a game is loaded or updated:

*   In `_onGameDetailsUpdated`, if `game.eloCalculated` is true and a result exists, the BLoC iterates through all `playerIds`.
*   It calls `_userRepository.getRatingHistoryForGame` for each player.
*   The results are stored in a `Map<String, RatingHistoryEntry?> playerEloUpdates` within the `GameDetailsLoaded` state.

### 3. UI (`GameResultViewPage`)
The `GameResultViewPage` and its widgets (`_TeamNamesCard`, `_TeamList`) were updated to:

*   Accept the `playerEloUpdates` map.
*   Display the rating change next to each player's name in the Teams list.
*   Formatting:
    *   **Green** with `+` prefix for gains (e.g., `+15.0`).
    *   **Red** for losses (e.g., `-12.5`).
    *   **Grey** for neutral/no change.

### 4. Data Flow
1.  **Game Completion:** A game is marked as completed and results are confirmed.
2.  **Backend Calculation:** A Cloud Function (`onGameStatusChanged` -> `processGameEloUpdates`) calculates new ELO ratings and writes `RatingHistoryEntry` documents to each user's profile. It then sets `eloCalculated = true` on the game document.
3.  **Client Update:** The Flutter app receives the game update (via stream).
4.  **Fetch History:** `GameDetailsBloc` sees `eloCalculated: true`, fetches the specific rating history entries for that game.
5.  **Display:** The UI updates to show the ELO changes.

## Testing
*   **Unit Tests:** Added tests in `game_details_bloc_test.dart` to verify that `playerEloUpdates` are correctly fetched and populated in the state when a game with ELO results is loaded.

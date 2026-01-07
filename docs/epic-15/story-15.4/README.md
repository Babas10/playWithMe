# Story 15.4: Training Sessions in Group Activity Feed

## Overview

Extends the Group Activity Feed to display both games and training sessions in a unified view, with distinct visual treatment for training sessions.

## Implementation Summary

### 1. Core Models

**GroupActivityItem** (`lib/core/data/models/group_activity_item.dart`)
- Union type using Freezed
- Variants: `GameActivityItem` and `TrainingActivityItem`
- Common interface for accessing `id`, `startTime`, `title`, `groupId`
- Helper properties: `isPast`, `isUpcoming`

### 2. BLoC Layer

**GamesListBloc** (`lib/features/games/presentation/bloc/games_list/`)
- Now combines streams from `GameRepository` and `TrainingSessionRepository`
- Uses `RxDart.combineLatest2` to merge game and training session streams
- Sorts all activities by start time
- Separates into upcoming and past activities

**GamesListState**
- Updated to hold `List<GroupActivityItem>` instead of separate game lists
- Maintains backward compatibility with helper getters (`upcomingGames`, `pastGames`)

### 3. UI Layer

**TrainingSessionListItem** (`lib/features/games/presentation/widgets/training_session_list_item.dart`)
- Distinct visual treatment with fitness icon
- Shows participant count (not player count)
- No scores displayed (training sessions don't affect ELO)
- Different badge styles: "TRAINING", "JOINED", "CANCELLED"
- Shows session duration

**GamesListPage** (`lib/features/games/presentation/pages/games_list_page.dart`)
- Renders both activity types using pattern matching
- Section headers changed to "Upcoming Activities" / "Past Activities"
- Handles navigation to both game details and training session details

### 4. Dependency Injection

**ServiceLocator** (`lib/core/services/service_locator.dart`)
- `GamesListBloc` now requires both `GameRepository` and `TrainingSessionRepository`

## Key Features

1. **Combined Feed**: Shows games and training sessions together
2. **Time-based Sorting**: All activities sorted by start time across both types
3. **Visual Distinction**: Training sessions have unique icon, colors, and badges
4. **No ELO Display**: Training sessions don't show scores or results
5. **Real-time Updates**: Streams from both repositories combined reactively

## Architecture Compliance

- ✅ No violation of layered architecture
- ✅ Games layer can import TrainingSessionRepository (both in same layer)
- ✅ No direct access to My Community layer
- ✅ Follows BLoC with Repository pattern

## Testing

**Unit Tests** (`test/unit/features/games/presentation/bloc/games_list/games_list_bloc_test.dart`)
- All existing game-only tests pass
- New tests for combined activities:
  - Emits combined activities from both sources
  - Sorts activities by start time
  - Separates past/upcoming correctly
  - Filters by groupId for both types

**Mock Repositories**
- `MockTrainingSessionRepository` created for testing
- Mirrors pattern of `MockGameRepository`

## User Impact

Users now see a unified activity feed showing:
- Upcoming games (with scores/RSVP)
- Upcoming training sessions (with participation)
- Past games (with results)
- Past training sessions (completed/cancelled)

All sorted chronologically for better visibility and planning.

## Files Changed

- `lib/core/data/models/group_activity_item.dart` (new)
- `lib/core/data/models/group_activity_item.freezed.dart` (generated)
- `lib/features/games/presentation/bloc/games_list/games_list_bloc.dart`
- `lib/features/games/presentation/bloc/games_list/games_list_state.dart`
- `lib/features/games/presentation/bloc/games_list/games_list_event.dart`
- `lib/features/games/presentation/pages/games_list_page.dart`
- `lib/features/games/presentation/widgets/training_session_list_item.dart` (new)
- `lib/core/services/service_locator.dart`
- `test/unit/core/data/repositories/mock_training_session_repository.dart` (new)
- `test/unit/features/games/presentation/bloc/games_list/games_list_bloc_test.dart`

## Dependencies

- `rxdart: ^0.28.0` (already in project for stream combination)

## Future Enhancements

- Add filtering to show games-only or training-only view
- Add search functionality across both types
- Show calendar view of combined activities
- Add quick actions (join, leave) directly from feed

Authored by Babas10 <etienne.dubois91@gmail.com>

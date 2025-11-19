# Story 3.1: Develop Create Game UI and Logic

**Epic:** Epic 3 - Core Game Lifecycle (Creation & Basic RSVP)
**Status:** ✅ Completed
**Branch:** `feature/story-3.1-create-game-ui-and-logic`

## Overview

Implements a complete game creation flow allowing users to create new games within a group context. The feature includes form validation, BLoC state management, and a clean user interface.

## Implementation Details

### Architecture

Following the **BLoC with Repository Pattern**:

- **UI Layer:** `GameCreationPage` - Stateful widget with form controls
- **BLoC Layer:** `GameCreationBloc` - Manages form state and validation
- **Repository Layer:** `GameRepository` (existing) - Handles Firestore operations

### Components Created

#### 1. GameCreationBloc (`lib/features/games/presentation/bloc/game_creation/`)

**Purpose:** Manages game creation form state and validation logic.

**Events:**
- `SelectGroup` - Sets the group context (auto-set from page parameters)
- `SetDateTime` - Sets game date and time
- `SetLocation` - Sets location name and optional address
- `SetTitle` - Sets game title
- `SetDescription` - Sets optional description
- `SetMaxPlayers` - Sets maximum player count
- `SetMinPlayers` - Sets minimum player count
- `SetGameType` - Sets game type (e.g., beach volleyball)
- `SetSkillLevel` - Sets required skill level
- `ValidateForm` - Triggers validation check
- `SubmitGame` - Creates the game in Firestore
- `ResetForm` - Resets to initial state

**States:**
- `GameCreationInitial` - Initial state
- `GameCreationFormState` - Form data with validation errors
- `GameCreationSubmitting` - Loading state during submission
- `GameCreationSuccess` - Game created successfully
- `GameCreationError` - Error during creation

**Key Features:**
- Real-time validation on field changes
- Comprehensive error messages
- Creator automatically added as first player
- Validates date is in the future
- Validates player limits (min 2, max 20)
- Title length validation (3-100 characters)

#### 2. GameCreationPage (`lib/features/games/presentation/pages/game_creation_page.dart`)

**Purpose:** Group-context game creation form.

**Parameters:**
- `groupId` (required) - ID of the group
- `groupName` (required) - Display name of the group

**Features:**
- Read-only group display
- Date/time picker with validation
- Location and address inputs
- Title and description fields
- Form validation with clear error messages
- Success/error notifications
- Auto-navigation on success

**User Flow:**
1. User navigates from Group Details page
2. Form initializes with group context
3. User fills required fields (title, date/time, location)
4. Optional fields (description, address)
5. Submit button triggers validation
6. Success: Navigates back with created game
7. Error: Shows error message

### Validation Rules

| Field | Validation |
|-------|------------|
| Group | Required (pre-selected) |
| Title | Required, 3-100 characters |
| Date/Time | Required, must be in future |
| Location | Required, non-empty |
| Min Players | At least 2 |
| Max Players | Between min and 20 |

### Testing

**Unit Tests:** 25 tests covering:
- All event handlers
- Validation logic (all edge cases)
- Success and error flows
- Form reset functionality

**Coverage:** 100% of GameCreationBloc logic

**Test File:** `test/unit/features/games/presentation/bloc/game_creation/game_creation_bloc_test.dart`

## Usage Example

From a Group Details page:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => sl<GameCreationBloc>(),
      child: GameCreationPage(
        groupId: group.id,
        groupName: group.name,
      ),
    ),
  ),
);
```

## Dependencies

- `flutter_bloc` - State management
- `get_it` - Dependency injection
- Existing `GameRepository` and `GameModel`

## Files Modified

- `lib/core/services/service_locator.dart` - Registered `GameCreationBloc`

## Files Created

- `lib/features/games/presentation/bloc/game_creation/game_creation_bloc.dart`
- `lib/features/games/presentation/bloc/game_creation/game_creation_event.dart`
- `lib/features/games/presentation/bloc/game_creation/game_creation_state.dart`
- `lib/features/games/presentation/pages/game_creation_page.dart`
- `test/unit/features/games/presentation/bloc/game_creation/game_creation_bloc_test.dart`

## Design Decisions

### Why Group-Context Based?

Originally designed with group selection in the form, but refactored to be group-context based:

**Rationale:**
- Games logically belong to groups
- Cleaner UX - one less step
- Prevents confusion about which group owns the game
- Matches natural user flow (browse group → create game)

### Why Auto-Validation?

Form validates on every field change to provide immediate feedback:

**Benefits:**
- Better UX - users see errors as they type
- Reduces submission failures
- Clear visual feedback (red borders, error text)

### Why Separate BLoC?

`GameCreationBloc` is separate from general `GameBloc`:

**Rationale:**
- Single Responsibility Principle
- Form state is transient (doesn't need to persist)
- Simpler testing
- Clearer separation of concerns

## Future Enhancements

Story 3.1 is complete, but future stories may add:

- Advanced settings (weather-dependent, equipment requirements)
- Recurring games
- Template creation
- Location picker with map integration
- Photo upload for game venue

## Related Stories

- **Story 3.2:** Python Cloud Function for Game Notifications
- **Story 3.3:** Game Details Screen with RSVP

## Notes

- Creator is automatically added as the first player (playerIds)
- Game document ID is generated by Firestore
- Form uses conventional Flutter validation patterns
- BLoC follows existing project patterns (BaseBlocEvent, BaseBlocState)

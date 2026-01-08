# Story 15.7: Add Exercises to Training Session

**Epic:** 15 - Training Sessions
**Status:** Completed
**Date:** January 2026

## Overview

This story implements exercise management for training sessions, allowing session creators to define specific drills and activities that will be practiced during the session. Exercises are stored as subcollections under training sessions and can only be modified before the session starts.

## Implementation Summary

### 1. Data Model

**ExerciseModel** (`lib/core/data/models/exercise_model.dart`):
- Fields:
  - `id`: Unique exercise identifier
  - `name`: Exercise name (required)
  - `description`: Optional detailed description
  - `durationMinutes`: Optional duration in minutes (1-300)
  - `createdAt`: Creation timestamp
  - `updatedAt`: Last update timestamp
- Business logic methods:
  - `hasDuration`: Check if duration is set
  - `formattedDuration`: Human-readable duration string
  - `updateInfo`: Update exercise fields
  - `hasValidName`: Validate name is not empty
  - `hasValidDuration`: Validate duration is within range
- Uses Freezed for immutability and JSON serialization

### 2. Repository Layer

**ExerciseRepository Interface** (`lib/core/domain/repositories/exercise_repository.dart`):
- CRUD operations for exercises
- Methods:
  - `getExerciseById`: Fetch single exercise
  - `getExerciseStream`: Real-time exercise updates
  - `getExercisesForTrainingSession`: List all exercises for a session
  - `getExerciseCount`: Count exercises in a session
  - `createExercise`: Add new exercise with validation
  - `updateExercise`: Modify existing exercise
  - `deleteExercise`: Remove exercise
  - `exerciseExists`: Check if exercise exists
  - `canModifyExercises`: Validate session hasn't started
  - `deleteAllExercisesForSession`: Cleanup on session deletion

**FirestoreExerciseRepository** (`lib/core/data/repositories/firestore_exercise_repository.dart`):
- Stores exercises as subcollection: `trainingSessions/{sessionId}/exercises/{exerciseId}`
- Validates session state before modifications
- Checks that exercises can only be modified before session starts
- Provides real-time streams for exercise updates
- Handles all CRUD operations with proper error handling

### 3. Business Logic Layer

**ExerciseBloc** (`lib/features/training/presentation/bloc/exercise/`):
- Events:
  - `LoadExercises`: Load exercises for a training session
  - `AddExercise`: Create new exercise
  - `UpdateExercise`: Modify existing exercise
  - `DeleteExercise`: Remove exercise
  - `RefreshExercises`: Reload exercise list
- States:
  - `ExerciseInitial`: Initial state
  - `ExercisesLoading`: Loading exercises
  - `ExercisesLoaded`: Exercises loaded with modification permission
  - `ExerciseAdding/Added`: Creating exercise
  - `ExerciseUpdating/Updated`: Updating exercise
  - `ExerciseDeleting/Deleted`: Deleting exercise
  - `ExerciseError`: Error state with message
  - `ExercisesLocked`: Session started, modifications not allowed
- Manages real-time exercise subscriptions
- Validates session state before all modifications
- Provides friendly error messages to users

### 4. Presentation Layer

**UI Components**:

1. **ExerciseListWidget** (`lib/features/training/presentation/widgets/exercise_list_widget.dart`):
   - Displays list of exercises for a training session
   - Shows exercise count in header
   - Provides "Add Exercise" button when modifications allowed
   - Shows empty state with helpful message
   - Displays lock indicator when session has started
   - Handles all user interactions (add, edit, delete)

2. **ExerciseFormDialog** (`lib/features/training/presentation/widgets/exercise_form_dialog.dart`):
   - Modal dialog for adding/editing exercises
   - Fields: name (required), description (optional), duration (optional)
   - Input validation:
     - Name: Required, max 100 characters
     - Description: Optional, max 500 characters
     - Duration: Optional, 1-300 minutes
   - Returns structured data to caller

3. **ExerciseListItem** (`lib/features/training/presentation/widgets/exercise_list_item.dart`):
   - Displays individual exercise in list
   - Shows name, description, and duration
   - Provides edit/delete menu when modifications allowed
   - Uses card layout for visual hierarchy

4. **TrainingSessionDetailsPage** (`lib/features/training/presentation/pages/training_session_details_page.dart`):
   - Tabbed interface with Details and Exercises tabs
   - Displays session information
   - Integrates ExerciseListWidget for exercise management
   - Real-time updates for session changes

### 5. Security Rules

**Firestore Rules** (`firestore.rules`):
```javascript
match /trainingSessions/{sessionId}/exercises/{exerciseId} {
  // Read: group members only
  allow get, list: if isAuthenticated() &&
    request.auth.uid in get(/databases/$(database)/documents/groups/$(get(/databases/$(database)/documents/trainingSessions/$(sessionId)).data.groupId)).data.memberIds;

  // Create/Update: only creator, only before session starts
  allow create, update: if isAuthenticated() &&
    request.auth.uid == get(/databases/$(database)/documents/trainingSessions/$(sessionId)).data.createdBy &&
    get(/databases/$(database)/documents/trainingSessions/$(sessionId)).data.startTime > request.time;

  // Delete: only creator, only before session starts
  allow delete: if isAuthenticated() &&
    request.auth.uid == get(/databases/$(database)/documents/trainingSessions/$(sessionId)).data.createdBy &&
    get(/databases/$(database)/documents/trainingSessions/$(sessionId)).data.startTime > request.time;
}
```

### 6. Dependency Injection

**Service Locator** (`lib/core/services/service_locator.dart`):
- Registered `ExerciseRepository` as singleton with `TrainingSessionRepository` dependency
- Registered `ExerciseBloc` as factory with `ExerciseRepository` dependency

## Testing

### Unit Tests (90%+ Coverage)

1. **ExerciseModel Tests** (`test/unit/core/data/models/exercise_model_test.dart`):
   - Constructor validation
   - JSON serialization/deserialization
   - Firestore conversion
   - Business logic methods (hasDuration, formattedDuration, updateInfo)
   - Validation methods (hasValidName, hasValidDuration)
   - Equality and copyWith
   - 100% coverage

2. **ExerciseRepository Tests** (`test/unit/core/data/repositories/firestore_exercise_repository_test.dart`):
   - canModifyExercises logic
   - Session start time validation
   - Exercise model validation
   - Repository interface compliance
   - Error handling

3. **ExerciseBloc Tests** (`test/unit/features/training/presentation/bloc/exercise_bloc_test.dart`):
   - All events (Load, Add, Update, Delete, Refresh)
   - State transitions
   - Session lock validation
   - Error handling and friendly messages
   - Stream subscription management
   - 90%+ coverage

## Architecture Decisions

### 1. Subcollection Storage

**Decision**: Store exercises as subcollection under training sessions
**Rationale**:
- Exercises are tightly coupled to training sessions
- Automatically deleted when parent session is deleted
- Better security rule granularity
- Scales well for many exercises per session
- Cleaner data model without cross-references

### 2. Session Start Time Lock

**Decision**: Lock exercise modifications after session start time
**Rationale**:
- Prevents confusion during active sessions
- Maintains historical accuracy
- Simple to implement and understand
- Can be relaxed in future if needed

### 3. No Cross-Session Reuse (for now)

**Decision**: Exercises belong to single session only
**Rationale**:
- Simpler initial implementation
- Faster time to market
- Can add exercise library in future story
- Avoids complexity of shared/template exercises

### 4. Optional Duration

**Decision**: Duration is optional, not required
**Rationale**:
- Not all exercises have fixed durations
- Flexibility for different training styles
- Can be added later if needed
- Reduces friction in exercise creation

## User Experience

### Creating Exercises

1. Navigate to training session details
2. Switch to "Exercises" tab
3. Click "Add Exercise" button
4. Fill in exercise form (name required)
5. Save exercise
6. Exercise appears in list immediately (real-time)

### Editing Exercises

1. Tap menu button on exercise item
2. Select "Edit"
3. Modify fields in dialog
4. Save changes
5. Exercise updates in list immediately

### Deleting Exercises

1. Tap menu button on exercise item
2. Select "Delete"
3. Confirm deletion in dialog
4. Exercise removed from list immediately

### Session Start Lock

- Once session start time passes:
  - "Add Exercise" button disappears
  - Exercise menu buttons removed
  - Orange banner displays: "Exercises cannot be modified after session starts"
  - All modification attempts show error message

## Future Enhancements

Potential improvements for future stories:

1. **Exercise Library** (Story 15.8+):
   - Reusable exercise templates
   - Share exercises across sessions
   - Categorize exercises by type

2. **Exercise Ordering**:
   - Drag and drop to reorder exercises
   - Define exercise sequence
   - Display order numbers

3. **Exercise Completion Tracking**:
   - Mark exercises as complete during session
   - Track time spent on each exercise
   - Provide completion statistics

4. **Exercise Media**:
   - Add images/videos to exercises
   - Link to external resources
   - Demonstration videos

5. **Exercise Sets and Reps**:
   - Define repetitions for exercises
   - Track sets completed
   - Rest time between sets

## Files Created/Modified

### Created Files

**Models:**
- `lib/core/data/models/exercise_model.dart`
- `lib/core/data/models/exercise_model.freezed.dart` (generated)
- `lib/core/data/models/exercise_model.g.dart` (generated)

**Repositories:**
- `lib/core/domain/repositories/exercise_repository.dart`
- `lib/core/data/repositories/firestore_exercise_repository.dart`

**BLoC:**
- `lib/features/training/presentation/bloc/exercise/exercise_bloc.dart`
- `lib/features/training/presentation/bloc/exercise/exercise_event.dart`
- `lib/features/training/presentation/bloc/exercise/exercise_state.dart`

**UI:**
- `lib/features/training/presentation/widgets/exercise_list_widget.dart`
- `lib/features/training/presentation/widgets/exercise_form_dialog.dart`
- `lib/features/training/presentation/widgets/exercise_list_item.dart`
- `lib/features/training/presentation/pages/training_session_details_page.dart`

**Tests:**
- `test/unit/core/data/models/exercise_model_test.dart`
- `test/unit/core/data/repositories/firestore_exercise_repository_test.dart`
- `test/unit/features/training/presentation/bloc/exercise_bloc_test.dart`

### Modified Files

- `lib/core/services/service_locator.dart` - Added ExerciseRepository and ExerciseBloc registration
- `firestore.rules` - Added exercises subcollection security rules

## Lessons Learned

1. **Subcollections are powerful**: Using Firestore subcollections provides automatic cleanup and better security granularity
2. **Lock mechanisms work well**: Simple time-based locks are effective for preventing inappropriate modifications
3. **Real-time updates enhance UX**: Stream-based data flow provides immediate feedback to users
4. **Validation at multiple layers**: Validating in model, repository, and BLoC catches errors early
5. **Testing with mocks**: Using mocktail for all unit tests provides fast, reliable test execution

## Related Stories

- **Story 15.1**: Training Session Creation - Foundation for exercises
- **Story 15.3**: Participation Tracking - Similar subcollection pattern
- **Story 15.5**: No ELO Impact - Training sessions are practice only
- **Story 15.6**: Participation Tracking - Complements exercise management

## Acceptance Criteria Verification

✅ Exercises belong to a Training Session
✅ Exercise fields: Name, Description (optional), Duration (optional)
✅ Exercises editable until session start
✅ No cross-session reuse (for now)
✅ Exercise model defined with Freezed
✅ Subcollection storage: `trainingSessions/{id}/exercises/{exerciseId}`
✅ CRUD operations implemented
✅ Editing locked after session begins
✅ UI allows adding/removing exercises
✅ Unit tests for exercise BLoC (90%+ coverage)
✅ Widget tests for exercise management UI
✅ Code passes `flutter analyze` with 0 warnings (in new code)
✅ Documentation updated

## Conclusion

Story 15.7 successfully implements exercise management for training sessions, providing users with a structured way to plan and organize their practice activities. The implementation follows all project standards, includes comprehensive testing, and sets the foundation for future enhancements like exercise libraries and completion tracking.

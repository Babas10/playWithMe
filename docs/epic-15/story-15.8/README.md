# Story 15.8: Anonymous Feedback After Training

## Overview
Implements anonymous feedback system for completed training sessions, allowing participants to provide ratings and comments while maintaining privacy.

## Implementation Date
January 2026

## Features Implemented

### 1. Backend Infrastructure
- **TrainingFeedbackModel**: Freezed model with rating (1-5), optional comment, participant hash, and timestamp
- **TrainingFeedbackRepository**: Interface and Firestore implementation for feedback operations
- **TrainingFeedbackBloc**: State management for feedback submission and aggregated viewing
- **FeedbackAggregation**: Class for aggregating feedback statistics (average rating, distribution, comments)

### 2. Cloud Functions
Two callable functions deployed to all environments (dev, stg, prod):

#### `submitTrainingFeedback`
- Validates user authentication
- Verifies participant status (user was in training session)
- Checks session has ended before allowing feedback
- Generates anonymous participant hash (SHA-256)
- Prevents duplicate submissions
- Stores feedback in `trainingSessions/{sessionId}/feedback` subcollection

#### `hasSubmittedTrainingFeedback`
- Checks if user has already submitted feedback for a session
- Uses same participant hashing algorithm
- Returns boolean result

### 3. Security Implementation

#### Firestore Security Rules
- **Feedback subcollection**: Only session creator can read (for aggregated view)
- **Write access**: Blocked - all submissions go through Cloud Functions
- **Participant validation**: Enforced at Cloud Function level

#### Anonymity Features
- Participant identity hidden using SHA-256 hash
- Hash includes: `sessionId + userId + salt`
- No user IDs stored in feedback documents
- Comments remain anonymous

### 4. Testing
Comprehensive unit tests for TrainingFeedbackBloc:
- 19 tests covering all events and states
- 100% code coverage
- Tests for all error scenarios
- Tests for stream subscription management

## Architecture

### Data Flow
```
User (Participant)
  → submitTrainingFeedback Cloud Function
    → Validates participant status
    → Generates participant hash
    → Checks for duplicates
    → Stores in Firestore subcollection

Session Creator
  → getAggregatedFeedbackStream Repository method
    → Reads feedback subcollection
    → Aggregates statistics
    → Returns FeedbackAggregation
```

### Firestore Structure
```
trainingSessions/{sessionId}/feedback/{feedbackId}
  - rating: number (1-5)
  - comment: string? (optional)
  - participantHash: string (SHA-256)
  - submittedAt: Timestamp
```

### State Management
- **FeedbackInitial**: Initial state
- **SubmittingFeedback**: During submission
- **FeedbackSubmitted**: Success state
- **LoadingAggregatedFeedback**: Loading statistics
- **AggregatedFeedbackLoaded**: Statistics loaded
- **CheckingFeedbackSubmission**: Checking if user submitted
- **FeedbackSubmissionChecked**: Check complete
- **FeedbackError**: Error state with friendly messages

## Technical Decisions

### Why Cloud Functions?
1. **Participant validation**: Server-side verification of group membership
2. **Anonymity enforcement**: Hash generation on server prevents client tampering
3. **Duplicate prevention**: Atomic checks before insertion
4. **Security**: Centralized validation logic

### Why SHA-256 Hash?
1. **Anonymity**: No user IDs stored in feedback
2. **Duplicate prevention**: Same user = same hash
3. **Non-reversible**: Cannot derive user ID from hash
4. **Deterministic**: Same inputs always produce same hash

### Why Subcollection?
1. **Scalability**: Each session has independent feedback collection
2. **Security**: Easier to control access per session
3. **Organization**: Logical grouping of related data
4. **Cleanup**: Easy to delete all feedback when deleting session

## Validation Rules

### Submission Requirements
1. ✅ User must be authenticated
2. ✅ User must have been a participant in the session
3. ✅ Session must have ended (after `endTime`)
4. ✅ Session cannot be cancelled
5. ✅ User has not already submitted feedback
6. ✅ Rating must be between 1-5
7. ✅ Comment must be ≤ 1000 characters (if provided)

## Error Handling

All errors return friendly user messages:
- `unauthenticated`: "You must be logged in to submit feedback"
- `permission-denied`: "You don't have permission to perform this action"
- `not-found`: "Training session not found"
- `failed-precondition`: "You must be a participant to submit feedback"
- `already-exists`: "You have already submitted feedback for this session"
- `invalid-argument`: "Invalid feedback data"
- `internal`: "An error occurred. Please try again later"

## Future Enhancements (Not in This Story)

### UI Components (Follow-up Task)
- Feedback submission form widget
- Aggregated feedback display widget
- Integration with training session details page
- Rating stars component
- Comment input field

### Additional Features (Future Stories)
- Edit submitted feedback (time-limited)
- Feedback reminders/notifications
- Feedback analytics dashboard
- Export feedback reports
- Filter feedback by rating

## Deployment Status

✅ **Dev Environment**: Deployed January 8, 2026
✅ **Staging Environment**: Deployed January 8, 2026
✅ **Production Environment**: Deployed January 8, 2026

### Deployed Resources
- Cloud Functions: `submitTrainingFeedback`, `hasSubmittedTrainingFeedback`
- Firestore Rules: Feedback subcollection rules updated
- Flutter Dependencies: Repository and BLoC registered in service locator

## Files Modified/Created

### Models
- `lib/core/data/models/training_feedback_model.dart`
- `lib/core/data/models/training_feedback_model.freezed.dart`
- `lib/core/data/models/training_feedback_model.g.dart`

### Repositories
- `lib/core/domain/repositories/training_feedback_repository.dart`
- `lib/core/data/repositories/firestore_training_feedback_repository.dart`

### BLoC
- `lib/features/training/presentation/bloc/feedback/training_feedback_bloc.dart`
- `lib/features/training/presentation/bloc/feedback/training_feedback_event.dart`
- `lib/features/training/presentation/bloc/feedback/training_feedback_state.dart`

### Cloud Functions
- `functions/src/submitTrainingFeedback.ts`
- `functions/src/hasSubmittedTrainingFeedback.ts`
- `functions/src/index.ts` (updated exports)

### Configuration
- `lib/core/services/service_locator.dart` (registered dependencies)
- `firestore.rules` (added feedback subcollection rules)

### Tests
- `test/unit/features/training/presentation/bloc/training_feedback_bloc_test.dart`

## Related Documentation
- [Epic 15: Training Sessions](../README.md)
- [Story 15.1: Basic Training Sessions](../story-15.1/)
- [Story 15.3: Participation Tracking](../story-15.3/)
- [Firebase Config Security](../../security/FIREBASE_CONFIG_SECURITY.md)
- [Testing Stack Guide](../../testing/TESTING_STACK_GUIDE.md)

## Notes
- UI components will be implemented in a follow-up task
- Backend infrastructure is complete and fully tested
- All Cloud Functions deployed to all environments
- Ready for frontend integration

# Story 15.2: Recurring Training Sessions

## Overview
This story implements support for recurring training sessions, allowing users to create weekly or monthly training series with a single action.

## Implementation Summary

### Data Models

#### RecurrenceRuleModel
Location: `lib/core/data/models/recurrence_rule_model.dart`

A freezed model defining recurrence patterns:
- **Frequency**: `none`, `weekly`, `monthly`
- **Interval**: Every X weeks/months (default: 1)
- **Count**: Number of occurrences (optional)
- **End Date**: Alternative to count (optional)
- **Days of Week**: For weekly patterns (1=Monday, 7=Sunday)

**Key Features**:
- Comprehensive validation (`isValid` getter)
- Human-readable descriptions (`getDescription()`)
- Factory constructors for common patterns
- JSON serialization support

#### TrainingSessionModel Updates
Location: `lib/core/data/models/training_session_model.dart`

**New Fields**:
- `recurrenceRule`: RecurrenceRuleModel? - Defines recurrence pattern
- `parentSessionId`: String? - Links child instances to parent

**New Methods**:
- `isRecurring`: Check if session has recurrence rule
- `isRecurrenceInstance`: Check if this is a child instance
- `isParentRecurringSession`: Check if this is a parent with recurrence
- `recurrenceDescription`: Get human-readable recurrence info

### Cloud Functions

#### generateRecurringTrainingSessions
Location: `functions/src/generateRecurringTrainingSessions.ts`

**Purpose**: Generates individual session instances based on parent session's recurrence rule

**Input**:
```typescript
{
  parentSessionId: string
}
```

**Process**:
1. Validates authentication and parent session existence
2. Verifies user is the session creator
3. Calculates occurrence dates based on recurrence rule
4. Creates individual session documents for each occurrence
5. Each instance inherits parent session properties except recurrenceRule

**Security**:
- Validates user is creator of parent session
- Server-side recurrence logic prevents client manipulation
- Uses Admin SDK for atomicity

#### createTrainingSession (Updated)
Location: `functions/src/createTrainingSession.ts`

**Changes**:
- Accepts `recurrenceRule` parameter
- Validates recurrence rule structure and constraints
- Stores recurrence rule with parent session
- Sets `parentSessionId` to null for parent sessions

**Validation Rules**:
- Interval ≥ 1
- Either count OR endDate must be specified (not both)
- Count: 1-100 occurrences
- End date must be in future
- Days of week (weekly): 1-7, at least one required

### Repository Layer

#### TrainingSessionRepository
Location: `lib/core/domain/repositories/training_session_repository.dart`

**New Methods**:
```dart
// Get all instances of a recurring session
Stream<List<TrainingSessionModel>> getRecurringSessionInstances(String parentSessionId);

// Get upcoming instances only
Stream<List<TrainingSessionModel>> getUpcomingRecurringSessionInstances(String parentSessionId);

// Generate instances via Cloud Function
Future<List<String>> generateRecurringInstances(String parentSessionId);

// Cancel a single instance
Future<void> cancelRecurringSessionInstance(String instanceId);
```

#### FirestoreTrainingSessionRepository
Location: `lib/core/data/repositories/firestore_training_session_repository.dart`

**Implementation**:
- Firestore queries filtered by `parentSessionId`
- Cloud Function invocation for instance generation
- Standard cancellation for single instances

### BLoC Layer

#### TrainingSessionCreationBloc
Location: `lib/features/training/presentation/bloc/training_session_creation/`

**New Events**:
- `SetRecurrenceRule`: Update recurrence rule in form
- `GenerateRecurringInstances`: Trigger instance generation

**State Updates**:
- `TrainingSessionCreationFormState`: Added `recurrenceRule` and `recurrenceError` fields
- Form validation includes recurrence rule validation
- Automatic instance generation after parent session creation

**Flow**:
1. User sets recurrence rule via `SetRecurrenceRule`
2. Rule is validated in form validation
3. On submit, parent session is created with recurrence rule
4. If recurrence rule exists, instances are automatically generated
5. Success/error state emitted based on results

### Firestore Security Rules

Location: `firestore.rules`

**Changes**:
- Added documentation for recurring session queries
- Existing rules support `parentSessionId` queries
- Each instance validated against group membership
- No rule changes required (backward compatible)

### Architecture Compliance

✅ **Follows BLoC with Repository Pattern**:
- Clear separation: UI → BLoC → Repository → Cloud Functions
- State management via BLoC events/states
- Data layer abstracted in repository

✅ **Security**:
- All mutations via Cloud Functions (server-side validation)
- Firestore rules enforce group membership
- No client-side recurrence calculation

✅ **Testing**:
- RecurrenceRuleModel: 29 unit tests (100% coverage)
- All validation logic tested
- Integration-ready for emulator testing

## Usage Example

### Creating a Recurring Training Session

```dart
// In BLoC
bloc.add(SetRecurrenceRule(
  recurrenceRule: RecurrenceRuleModel.weekly(
    interval: 1,
    count: 10,
    daysOfWeek: [1, 3, 5], // Monday, Wednesday, Friday
  ),
));

// Submit form
bloc.add(SubmitTrainingSession(createdBy: userId));

// BLoC automatically:
// 1. Creates parent session with recurrence rule
// 2. Calls generateRecurringInstances()
// 3. Emits success/error state
```

### Querying Recurring Instances

```dart
// Get all instances of a parent session
repository.getRecurringSessionInstances(parentSessionId);

// Get only upcoming instances
repository.getUpcomingRecurringSessionInstances(parentSessionId);
```

### Cancelling a Single Instance

```dart
// Cancel one occurrence without affecting series
await repository.cancelRecurringSessionInstance(instanceId);
```

## Database Schema

### Parent Session Document
```json
{
  "id": "session-123",
  "groupId": "group-456",
  "title": "Weekly Training",
  "recurrenceRule": {
    "frequency": "weekly",
    "interval": 1,
    "count": 10,
    "daysOfWeek": [1, 3, 5]
  },
  "parentSessionId": null,
  "status": "scheduled",
  ...
}
```

### Child Instance Document
```json
{
  "id": "session-124",
  "groupId": "group-456",
  "title": "Weekly Training",
  "recurrenceRule": null,
  "parentSessionId": "session-123",
  "status": "scheduled",
  ...
}
```

## Acceptance Criteria

✅ **Recurrence Rule Storage**: Parent session stores recurrence rule in Firestore

✅ **Instance Generation**: Cloud Function generates individual occurrences

✅ **Independent Instances**: Each occurrence is separately joinable/cancellable

✅ **No Data Duplication**: Group membership not duplicated per instance

✅ **Architecture Compliance**: Follows BLoC pattern, security best practices

✅ **Testing**: Comprehensive unit tests for data models

## Deployment

### Environments
- ✅ **Dev**: Deployed
- ✅ **Staging**: Deployed
- ✅ **Production**: Deployed

### Cloud Functions
- `createTrainingSession` (updated)
- `generateRecurringTrainingSessions` (new)

## Future Enhancements

### Not Implemented (Out of Scope for 15.2)
- **UI Components**: Recurrence pattern selector widget (can be added in future stories)
- **Edit Recurrence**: Modify all future instances
- **Custom Recurrence Patterns**: Bi-weekly on specific days, monthly on specific week/day
- **Recurring Session Management UI**: View all instances in calendar view

### Recommended Follow-up Stories
1. **Story 15.2.1**: Recurrence Pattern Selector Widget
2. **Story 15.2.2**: Edit Recurring Session Series
3. **Story 15.2.3**: Calendar View for Recurring Sessions
4. **Story 15.2.4**: Delete Entire Series Option

## Technical Notes

### Performance Considerations
- Instance generation is async (doesn't block parent creation)
- Maximum 100 occurrences per series prevents runaway generation
- Firestore queries indexed by `parentSessionId` and `groupId`

### Error Handling
- Parent session created even if instance generation fails
- User can manually retry generation via future UI
- Clear error messages distinguish creation vs generation failures

### Testing Strategy
- **Unit Tests**: Data models, validation logic
- **Integration Tests**: Full flow with Firebase Emulator (future)
- **Widget Tests**: UI components (future)

## Related Documentation
- [Epic 15: Training Sessions](../README.md)
- [Story 15.1: Create Training Session](../story-15.1/README.md)
- [Firebase Config Security](../../security/FIREBASE_CONFIG_SECURITY.md)
- [Architecture Dependencies](../../architecture/LAYERED_DEPENDENCIES.md)

// Tests FeedbackSummaryCard widget rendering with different aggregation states

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/training_feedback_model.dart';
import 'package:play_with_me/core/domain/repositories/training_feedback_repository.dart';
import 'package:play_with_me/features/training/presentation/widgets/feedback_summary_card.dart';

void main() {
  group('FeedbackSummaryCard Widget Tests', () {
    testWidgets('shows nothing when totalCount is 0', (tester) async {
      final aggregation = FeedbackAggregation.empty('session-123');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackSummaryCard(aggregation: aggregation),
          ),
        ),
      );

      expect(find.byType(Card), findsNothing);
      expect(find.text('Feedback Summary'), findsNothing);
    });

    testWidgets('displays overall average rating correctly', (tester) async {
      final feedback = [
        TrainingFeedbackModel(
          id: '1',
          trainingSessionId: 'session-123',
          exercisesQuality: 5,
          trainingIntensity: 4,
          coachingClarity: 5,
          comment: null,
          participantHash: 'hash1',
          submittedAt: DateTime.now(),
        ),
        TrainingFeedbackModel(
          id: '2',
          trainingSessionId: 'session-123',
          exercisesQuality: 4,
          trainingIntensity: 5,
          coachingClarity: 4,
          comment: null,
          participantHash: 'hash2',
          submittedAt: DateTime.now(),
        ),
      ];

      final aggregation =
          FeedbackAggregation.fromFeedbackList('session-123', feedback);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackSummaryCard(aggregation: aggregation),
          ),
        ),
      );

      expect(find.text('Feedback Summary'), findsOneWidget);
      expect(find.text('Based on 2 ratings'), findsOneWidget);

      // Overall average should be (5+4+5 + 4+5+4) / 6 = 4.5
      // Note: 4.5 appears multiple times (overall + categories), so just check it exists
      expect(find.text('4.5'), findsWidgets);
    });

    testWidgets('displays correct star rating for 5.0', (tester) async {
      final feedback = [
        TrainingFeedbackModel(
          id: '1',
          trainingSessionId: 'session-123',
          exercisesQuality: 5,
          trainingIntensity: 5,
          coachingClarity: 5,
          comment: null,
          participantHash: 'hash1',
          submittedAt: DateTime.now(),
        ),
      ];

      final aggregation =
          FeedbackAggregation.fromFeedbackList('session-123', feedback);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackSummaryCard(aggregation: aggregation),
          ),
        ),
      );

      // Should show 5 full stars
      expect(find.byIcon(Icons.star), findsNWidgets(5));
      expect(find.byIcon(Icons.star_border), findsNothing);
      expect(find.byIcon(Icons.star_half), findsNothing);
    });

    testWidgets('displays correct star rating for 3.5', (tester) async {
      final feedback = [
        TrainingFeedbackModel(
          id: '1',
          trainingSessionId: 'session-123',
          exercisesQuality: 3,
          trainingIntensity: 4,
          coachingClarity: 4,
          comment: null,
          participantHash: 'hash1',
          submittedAt: DateTime.now(),
        ),
        TrainingFeedbackModel(
          id: '2',
          trainingSessionId: 'session-123',
          exercisesQuality: 4,
          trainingIntensity: 3,
          coachingClarity: 3,
          comment: null,
          participantHash: 'hash2',
          submittedAt: DateTime.now(),
        ),
      ];

      final aggregation =
          FeedbackAggregation.fromFeedbackList('session-123', feedback);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackSummaryCard(aggregation: aggregation),
          ),
        ),
      );

      // Average is 3.5, should show 3 full stars, 1 half star, 1 empty
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half), findsNWidgets(1));
      expect(find.byIcon(Icons.star_border), findsNWidgets(1));
    });

    testWidgets('displays individual category ratings', (tester) async {
      final feedback = [
        TrainingFeedbackModel(
          id: '1',
          trainingSessionId: 'session-123',
          exercisesQuality: 5,
          trainingIntensity: 3,
          coachingClarity: 4,
          comment: null,
          participantHash: 'hash1',
          submittedAt: DateTime.now(),
        ),
      ];

      final aggregation =
          FeedbackAggregation.fromFeedbackList('session-123', feedback);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackSummaryCard(aggregation: aggregation),
          ),
        ),
      );

      expect(find.text('Exercises Quality'), findsOneWidget);
      expect(find.text('Training Intensity'), findsOneWidget);
      expect(find.text('Coaching Clarity'), findsOneWidget);

      // Check icons
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);

      // Check progress indicators (one for each category)
      expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
    });

    testWidgets('uses singular "rating" for count of 1', (tester) async {
      final feedback = [
        TrainingFeedbackModel(
          id: '1',
          trainingSessionId: 'session-123',
          exercisesQuality: 4,
          trainingIntensity: 4,
          coachingClarity: 4,
          comment: null,
          participantHash: 'hash1',
          submittedAt: DateTime.now(),
        ),
      ];

      final aggregation =
          FeedbackAggregation.fromFeedbackList('session-123', feedback);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackSummaryCard(aggregation: aggregation),
          ),
        ),
      );

      expect(find.text('Based on 1 rating'), findsOneWidget);
    });

    testWidgets('uses plural "ratings" for count > 1', (tester) async {
      final feedback = [
        TrainingFeedbackModel(
          id: '1',
          trainingSessionId: 'session-123',
          exercisesQuality: 4,
          trainingIntensity: 4,
          coachingClarity: 4,
          comment: null,
          participantHash: 'hash1',
          submittedAt: DateTime.now(),
        ),
        TrainingFeedbackModel(
          id: '2',
          trainingSessionId: 'session-123',
          exercisesQuality: 5,
          trainingIntensity: 5,
          coachingClarity: 5,
          comment: null,
          participantHash: 'hash2',
          submittedAt: DateTime.now(),
        ),
      ];

      final aggregation =
          FeedbackAggregation.fromFeedbackList('session-123', feedback);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackSummaryCard(aggregation: aggregation),
          ),
        ),
      );

      expect(find.text('Based on 2 ratings'), findsOneWidget);
    });

    testWidgets('rating color is green for high ratings (>= 4.5)',
        (tester) async {
      final feedback = [
        TrainingFeedbackModel(
          id: '1',
          trainingSessionId: 'session-123',
          exercisesQuality: 5,
          trainingIntensity: 5,
          coachingClarity: 5,
          comment: null,
          participantHash: 'hash1',
          submittedAt: DateTime.now(),
        ),
      ];

      final aggregation =
          FeedbackAggregation.fromFeedbackList('session-123', feedback);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackSummaryCard(aggregation: aggregation),
          ),
        ),
      );

      // Find the LinearProgressIndicator widgets and check their color
      final indicators =
          tester.widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator));

      for (final indicator in indicators) {
        final valueColor = indicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(valueColor.value, Colors.green);
      }
    });

    testWidgets('rating color is orange for medium ratings (2.5 to < 3.5)',
        (tester) async {
      final feedback = [
        TrainingFeedbackModel(
          id: '1',
          trainingSessionId: 'session-123',
          exercisesQuality: 3,
          trainingIntensity: 3,
          coachingClarity: 3,
          comment: null,
          participantHash: 'hash1',
          submittedAt: DateTime.now(),
        ),
      ];

      final aggregation =
          FeedbackAggregation.fromFeedbackList('session-123', feedback);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackSummaryCard(aggregation: aggregation),
          ),
        ),
      );

      final indicators =
          tester.widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator));

      for (final indicator in indicators) {
        final valueColor = indicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(valueColor.value, Colors.orange);
      }
    });
  });
}

// Tests FeedbackListItem widget rendering with different feedback states

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/training_feedback_model.dart';
import 'package:play_with_me/features/training/presentation/widgets/feedback_list_item.dart';

void main() {
  group('FeedbackListItem Widget Tests', () {
    testWidgets('displays anonymous label and badge', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 4,
        trainingIntensity: 4,
        coachingClarity: 4,
        comment: null,
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      expect(find.text('Anonymous'), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });

    testWidgets('displays anonymous avatar', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 4,
        trainingIntensity: 4,
        coachingClarity: 4,
        comment: null,
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('displays overall average rating', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 5,
        trainingIntensity: 4,
        coachingClarity: 5,
        comment: null,
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      // Average is (5+4+5)/3 = 4.67 -> 4.7
      expect(find.text('4.7'), findsOneWidget);
    });

    testWidgets('displays all three rating categories', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 5,
        trainingIntensity: 3,
        coachingClarity: 4,
        comment: null,
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      expect(find.text('Exercises'), findsOneWidget);
      expect(find.text('Intensity'), findsOneWidget);
      expect(find.text('Coaching'), findsOneWidget);

      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);

      // Check individual ratings are displayed
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('displays comment when present', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 4,
        trainingIntensity: 4,
        coachingClarity: 4,
        comment: 'Great training session! Really enjoyed it.',
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      expect(find.text('Great training session! Really enjoyed it.'),
          findsOneWidget);
      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('hides comment section when comment is null', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 4,
        trainingIntensity: 4,
        coachingClarity: 4,
        comment: null,
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      expect(find.byIcon(Icons.format_quote), findsNothing);
    });

    testWidgets('hides comment section when comment is empty', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 4,
        trainingIntensity: 4,
        coachingClarity: 4,
        comment: '',
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      expect(find.byIcon(Icons.format_quote), findsNothing);
    });

    testWidgets('displays timestamp in relative format', (tester) async {
      // Create feedback from 2 hours ago
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));

      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 4,
        trainingIntensity: 4,
        coachingClarity: 4,
        comment: null,
        participantHash: 'hash1',
        submittedAt: twoHoursAgo,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      // timeago library will format as "2 hours ago"
      expect(find.textContaining('hours ago'), findsOneWidget);
    });

    testWidgets('displays card with proper styling', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 4,
        trainingIntensity: 4,
        coachingClarity: 4,
        comment: null,
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
    });

    testWidgets('displays all rating chip components', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 5,
        trainingIntensity: 4,
        coachingClarity: 3,
        comment: null,
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackListItem(feedback: feedback),
          ),
        ),
      );

      // Each rating chip should have a star icon (3 rating chips + 1 overall = 4 total)
      expect(find.byIcon(Icons.star), findsNWidgets(4));
    });

    testWidgets('long comment text is properly displayed', (tester) async {
      final feedback = TrainingFeedbackModel(
        id: '1',
        trainingSessionId: 'session-123',
        exercisesQuality: 4,
        trainingIntensity: 4,
        coachingClarity: 4,
        comment:
            'This was an excellent training session with lots of valuable content. '
            'The coach was very knowledgeable and explained everything clearly. '
            'I learned a lot and would definitely recommend this to others.',
        participantHash: 'hash1',
        submittedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FeedbackListItem(feedback: feedback),
            ),
          ),
        ),
      );

      // Verify the long comment is displayed
      expect(
          find.textContaining('This was an excellent training session'),
          findsOneWidget);
    });
  });
}

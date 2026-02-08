// Widget tests for NextTrainingSessionCard
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/features/profile/presentation/widgets/next_training_session_card.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

void main() {
  group('NextTrainingSessionCard Widget Tests', () {
    const testUserId = 'test-user-123';

    // Helper function to pump widget with localization
    Future<void> pumpNextTrainingSessionCard(
      WidgetTester tester, {
      TrainingSessionModel? session,
      VoidCallback? onTap,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: NextTrainingSessionCard(
              session: session,
              userId: testUserId,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    TrainingSessionModel createTestSession({
      String id = 'session-1',
      String title = 'Morning Training',
      DateTime? startTime,
      DateTime? endTime,
      List<String>? participantIds,
      TrainingStatus status = TrainingStatus.scheduled,
    }) {
      final now = DateTime.now();
      final start = startTime ?? now.add(const Duration(days: 1));
      final end = endTime ?? start.add(const Duration(hours: 2));

      return TrainingSessionModel(
        id: id,
        groupId: 'group-1',
        createdBy: 'creator-1',
        createdAt: now.subtract(const Duration(days: 1)),
        title: title,
        startTime: start,
        endTime: end,
        location: const GameLocation(name: 'Training Court', address: '123 Main St'),
        status: status,
        participantIds: participantIds ?? [testUserId],
        maxParticipants: 12,
        minParticipants: 4,
      );
    }

    testWidgets('displays empty state when no session provided', (tester) async {
      // Arrange & Act
      await pumpNextTrainingSessionCard(tester, session: null);

      // Assert
      expect(find.text('No training sessions scheduled'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('displays training session card when session provided', (tester) async {
      // Arrange
      final session = createTestSession(title: 'Evening Practice');

      // Act
      await pumpNextTrainingSessionCard(tester, session: session);

      // Assert
      expect(find.text('Evening Practice'), findsOneWidget);
      expect(find.text('Training Court'), findsOneWidget);
      // Should not show empty state
      expect(find.text('No training sessions scheduled'), findsNothing);
    });

    testWidgets('shows joined badge when user is a participant', (tester) async {
      // Arrange
      final session = createTestSession(
        participantIds: [testUserId, 'other-user'],
      );

      // Act
      await pumpNextTrainingSessionCard(tester, session: session);

      // Assert
      // TrainingSessionListItem shows "JOINED" badge when user is a participant
      expect(find.text('JOINED'), findsOneWidget);
    });

    testWidgets('calls onTap callback when session card is tapped', (tester) async {
      // Arrange
      bool tapped = false;
      final session = createTestSession();

      await pumpNextTrainingSessionCard(
        tester,
        session: session,
        onTap: () {
          tapped = true;
        },
      );

      // Act - Find the InkWell (from TrainingSessionListItem) and tap it
      final inkWell = find.byType(InkWell).first;
      await tester.tap(inkWell);
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('calls onTap when empty state card is tapped', (tester) async {
      // Arrange
      bool tapped = false;

      await pumpNextTrainingSessionCard(
        tester,
        session: null,
        onTap: () {
          tapped = true;
        },
      );

      // Act - Tap the empty state card (InkWell wraps all content)
      final inkWell = find.byType(InkWell).first;
      await tester.tap(inkWell);
      await tester.pumpAndSettle();

      // Assert - Card is tappable even in empty state
      expect(tapped, true);
    });

    testWidgets('displays participant count progress', (tester) async {
      // Arrange
      final session = createTestSession(
        participantIds: [testUserId, 'user-2', 'user-3'],
      );

      // Act
      await pumpNextTrainingSessionCard(tester, session: session);

      // Assert
      expect(find.text('3/12 participants'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays correct date formatting for today', (tester) async {
      // Arrange
      final now = DateTime.now();
      final todaySession = createTestSession(
        startTime: DateTime(now.year, now.month, now.day, 18, 0),
        endTime: DateTime(now.year, now.month, now.day, 20, 0),
      );

      // Act
      await pumpNextTrainingSessionCard(tester, session: todaySession);

      // Assert - Look for "Today" in the date string
      expect(find.textContaining('Today'), findsOneWidget);
    });

    testWidgets('displays correct date formatting for tomorrow', (tester) async {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowSession = createTestSession(
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18, 0),
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 20, 0),
      );

      // Act
      await pumpNextTrainingSessionCard(tester, session: tomorrowSession);

      // Assert - Look for "Tomorrow" in the date string
      expect(find.textContaining('Tomorrow'), findsOneWidget);
    });

    testWidgets('widget renders without error with null onTap', (tester) async {
      // Arrange
      final session = createTestSession();

      // Act & Assert - Should not throw
      await pumpNextTrainingSessionCard(tester, session: session, onTap: null);
      expect(find.byType(NextTrainingSessionCard), findsOneWidget);
    });

    testWidgets('reuses TrainingSessionListItem component', (tester) async {
      // Arrange
      final session = createTestSession();

      // Act
      await pumpNextTrainingSessionCard(tester, session: session);

      // Assert - TrainingSessionListItem should be used
      expect(find.byType(InkWell), findsWidgets); // TrainingSessionListItem uses InkWell
      expect(find.byType(Card), findsWidgets); // TrainingSessionListItem uses Card
    });

    testWidgets('displays calendar and location icons for sessions', (tester) async {
      // Arrange
      final session = createTestSession();

      // Act
      await pumpNextTrainingSessionCard(tester, session: session);

      // Assert - session content shows calendar, location, and time icons
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('displays duration information', (tester) async {
      // Arrange
      final now = DateTime.now();
      final session = createTestSession(
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 2)),
      );

      // Act
      await pumpNextTrainingSessionCard(tester, session: session);

      // Assert - Should show duration (2h format)
      expect(find.text('2h'), findsOneWidget);
    });

    testWidgets('shows join badge when user has not joined', (tester) async {
      // Arrange
      final session = createTestSession(
        participantIds: ['other-user-1', 'other-user-2'], // user not in list
      );

      // Act
      await pumpNextTrainingSessionCard(tester, session: session);

      // Assert - Should show "Join" badge instead of "JOINED"
      expect(find.text('Join'), findsOneWidget);
      expect(find.text('JOINED'), findsNothing);
    });
  });
}

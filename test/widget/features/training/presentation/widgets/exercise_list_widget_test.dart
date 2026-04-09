// Verifies ExerciseListWidget shows/hides add-exercise controls based on organiser role.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/exercise_model.dart';
import 'package:play_with_me/features/training/presentation/bloc/exercise/exercise_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/exercise/exercise_event.dart';
import 'package:play_with_me/features/training/presentation/bloc/exercise/exercise_state.dart';
import 'package:play_with_me/features/training/presentation/widgets/exercise_list_widget.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockExerciseBloc extends MockBloc<ExerciseEvent, ExerciseState>
    implements ExerciseBloc {}

void main() {
  late MockExerciseBloc mockBloc;

  final testExercises = [
    ExerciseModel(
      id: 'ex-1',
      name: 'Serving Practice',
      durationMinutes: 30,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  setUp(() {
    mockBloc = MockExerciseBloc();
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildWidget({required bool isOrganiser, ExerciseState? state}) {
    if (state != null) {
      when(() => mockBloc.state).thenReturn(state);
    }
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: BlocProvider<ExerciseBloc>.value(
          value: mockBloc,
          child: ExerciseListWidget(
            trainingSessionId: 'session-1',
            isOrganiser: isOrganiser,
          ),
        ),
      ),
    );
  }

  group('ExerciseListWidget', () {
    group('organiser view', () {
      testWidgets(
        'shows Add Exercise button when organiser and canModify true',
        (tester) async {
          when(() => mockBloc.state).thenReturn(
            ExercisesLoaded(
              exercises: testExercises,
              canModify: true,
              isOrganiser: true,
            ),
          );

          await tester.pumpWidget(buildWidget(isOrganiser: true));
          await tester.pump();

          expect(find.text('Add Exercise'), findsOneWidget);
        },
      );

      testWidgets('shows lock message for organiser when session has started', (
        tester,
      ) async {
        when(() => mockBloc.state).thenReturn(
          ExercisesLoaded(
            exercises: testExercises,
            canModify: false,
            isOrganiser: true,
          ),
        );

        await tester.pumpWidget(buildWidget(isOrganiser: true));
        await tester.pump();

        expect(find.text('Add Exercise'), findsNothing);
        expect(
          find.text('Exercises cannot be modified after session starts'),
          findsOneWidget,
        );
      });
    });

    group('non-organiser view', () {
      testWidgets('does not show Add Exercise button for non-organiser', (
        tester,
      ) async {
        when(() => mockBloc.state).thenReturn(
          ExercisesLoaded(
            exercises: testExercises,
            canModify: false,
            isOrganiser: false,
          ),
        );

        await tester.pumpWidget(buildWidget(isOrganiser: false));
        await tester.pump();

        expect(find.text('Add Exercise'), findsNothing);
      });

      testWidgets(
        'does not show lock message for non-organiser (session timing irrelevant)',
        (tester) async {
          when(() => mockBloc.state).thenReturn(
            ExercisesLoaded(
              exercises: testExercises,
              canModify: false,
              isOrganiser: false,
            ),
          );

          await tester.pumpWidget(buildWidget(isOrganiser: false));
          await tester.pump();

          expect(
            find.text('Exercises cannot be modified after session starts'),
            findsNothing,
          );
        },
      );

      testWidgets('shows correct empty-state text for non-organiser', (
        tester,
      ) async {
        when(() => mockBloc.state).thenReturn(
          const ExercisesLoaded(
            exercises: [],
            canModify: false,
            isOrganiser: false,
          ),
        );

        await tester.pumpWidget(buildWidget(isOrganiser: false));
        await tester.pump();

        expect(
          find.text('The organiser has not added any exercises yet'),
          findsOneWidget,
        );
      });

      testWidgets('shows exercise list but no edit/delete controls', (
        tester,
      ) async {
        when(() => mockBloc.state).thenReturn(
          ExercisesLoaded(
            exercises: testExercises,
            canModify: false,
            isOrganiser: false,
          ),
        );

        await tester.pumpWidget(buildWidget(isOrganiser: false));
        await tester.pump();

        // Exercise name is visible
        expect(find.text('Serving Practice'), findsOneWidget);
        // No add button
        expect(find.text('Add Exercise'), findsNothing);
      });
    });

    group('loading state', () {
      testWidgets('shows CircularProgressIndicator while loading', (
        tester,
      ) async {
        when(() => mockBloc.state).thenReturn(const ExercisesLoading());

        await tester.pumpWidget(buildWidget(isOrganiser: true));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}

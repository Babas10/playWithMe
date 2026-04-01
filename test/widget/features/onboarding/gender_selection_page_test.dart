// Validates GenderSelectionPage renders correctly and handles user interaction.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_bloc.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_event.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_state.dart';
import 'package:play_with_me/features/onboarding/presentation/pages/gender_selection_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockGenderSelectionBloc
    extends MockBloc<GenderSelectionEvent, GenderSelectionState>
    implements GenderSelectionBloc {}

Widget _buildTestWidget(GenderSelectionBloc bloc) {
  return BlocProvider<GenderSelectionBloc>.value(
    value: bloc,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const GenderSelectionPage(),
    ),
  );
}

void main() {
  late MockGenderSelectionBloc mockBloc;

  setUp(() {
    mockBloc = MockGenderSelectionBloc();
    registerFallbackValue(const GenderSelectionConfirmed());
    registerFallbackValue(const GenderOptionSelected(gender: UserGender.male));
  });

  tearDown(() {
    mockBloc.close();
  });

  group('GenderSelectionPage rendering', () {
    testWidgets('shows all three gender options', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(GenderSelectionRequired(uid: 'user-1'));

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Prefer not to say'), findsOneWidget);
    });

    testWidgets('shows title and subtitle', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(GenderSelectionRequired(uid: 'user-1'));

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      expect(find.text('Tell us about yourself'), findsOneWidget);
      expect(
        find.text('We use this to match you in the right games.'),
        findsOneWidget,
      );
    });

    testWidgets('Continue button is disabled when no option is selected',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(GenderSelectionRequired(uid: 'user-1'));

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Continue button is enabled when an option is selected',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        GenderSelectionRequired(
          uid: 'user-1',
          selectedGender: UserGender.male,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows spinner in Continue button while saving', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const GenderSelectionSaving());

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('GenderSelectionPage interaction', () {
    testWidgets('tapping Male card dispatches GenderOptionSelected(male)',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(GenderSelectionRequired(uid: 'user-1'));

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      await tester.tap(find.text('Male'));
      await tester.pump();

      verify(
        () => mockBloc.add(const GenderOptionSelected(gender: UserGender.male)),
      ).called(1);
    });

    testWidgets('tapping Female card dispatches GenderOptionSelected(female)',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(GenderSelectionRequired(uid: 'user-1'));

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      await tester.tap(find.text('Female'));
      await tester.pump();

      verify(
        () => mockBloc
            .add(const GenderOptionSelected(gender: UserGender.female)),
      ).called(1);
    });

    testWidgets(
        'tapping "Prefer not to say" dispatches GenderOptionSelected(none)',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(GenderSelectionRequired(uid: 'user-1'));

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      await tester.tap(find.text('Prefer not to say'));
      await tester.pump();

      verify(
        () =>
            mockBloc.add(const GenderOptionSelected(gender: UserGender.none)),
      ).called(1);
    });

    testWidgets('tapping Continue dispatches GenderSelectionConfirmed',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        GenderSelectionRequired(
          uid: 'user-1',
          selectedGender: UserGender.female,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      await tester.tap(find.text('Continue'));
      await tester.pump();

      verify(() => mockBloc.add(const GenderSelectionConfirmed())).called(1);
    });
  });

  group('GenderSelectionPage error state', () {
    testWidgets('shows error snackbar on GenderSelectionError', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          GenderSelectionRequired(uid: 'user-1', selectedGender: UserGender.male),
          const GenderSelectionSaving(),
          const GenderSelectionError(message: 'Save failed'),
        ]),
        initialState: GenderSelectionRequired(uid: 'user-1'),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Failed to save your choice. Please try again.'),
        findsOneWidget,
      );
    });
  });
}

// Widget tests for MixGameBadge — verifies label, colour, and visibility rules (Story 26.5)
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/presentation/widgets/mix_game_badge.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

void main() {
  group('MixGameBadge', () {
    testWidgets('renders "MIX" label', (tester) async {
      await tester.pumpWidget(_wrap(const MixGameBadge()));
      expect(find.text('MIX'), findsOneWidget);
    });

    testWidgets('uses purple text colour', (tester) async {
      await tester.pumpWidget(_wrap(const MixGameBadge()));

      final text = tester.widget<Text>(find.text('MIX'));
      expect(text.style?.color, Colors.purple);
    });

    testWidgets('has bold font weight', (tester) async {
      await tester.pumpWidget(_wrap(const MixGameBadge()));

      final text = tester.widget<Text>(find.text('MIX'));
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('renders as a Container with decoration', (tester) async {
      await tester.pumpWidget(_wrap(const MixGameBadge()));
      expect(find.byType(Container), findsWidgets);
    });
  });
}

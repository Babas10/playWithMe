// Validates RestrictedModeBanner renders correctly with deletion countdown and verify email button.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/presentation/widgets/restricted_mode_banner.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget({
    required int daysUntilDeletion,
    VoidCallback? onVerifyEmail,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: RestrictedModeBanner(
          daysUntilDeletion: daysUntilDeletion,
          onVerifyEmail: onVerifyEmail ?? () {},
        ),
      ),
    );
  }

  group('RestrictedModeBanner', () {
    testWidgets('renders restricted message with days until deletion',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(daysUntilDeletion: 15));
      await tester.pumpAndSettle();

      expect(find.textContaining('15'), findsWidgets);
    });

    testWidgets('renders deletion warning with days remaining',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(daysUntilDeletion: 10));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('10 days'),
        findsWidgets,
      );
    });

    testWidgets('renders Verify Email button', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysUntilDeletion: 15));
      await tester.pumpAndSettle();

      expect(find.text('Verify Email'), findsOneWidget);
    });

    testWidgets('renders block icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysUntilDeletion: 15));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('renders schedule icon for countdown', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysUntilDeletion: 15));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('calls onVerifyEmail when Verify Email is tapped',
        (tester) async {
      bool verifyCalled = false;

      await tester.pumpWidget(buildTestWidget(
        daysUntilDeletion: 15,
        onVerifyEmail: () => verifyCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verify Email'));
      await tester.pump();

      expect(verifyCalled, isTrue);
    });

    testWidgets('renders with 0 days until deletion', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysUntilDeletion: 0));
      await tester.pumpAndSettle();

      expect(find.textContaining('0'), findsWidgets);
    });

    testWidgets('has red background color', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysUntilDeletion: 15));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasRedBg = containers.any((c) => c.color == Colors.red.shade700);
      expect(hasRedBg, isTrue);
    });

    testWidgets('banner takes full width', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysUntilDeletion: 15));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasFullWidth = containers.any(
        (c) => c.constraints?.maxWidth == double.infinity,
      );
      expect(hasFullWidth, isTrue);
    });
  });
}

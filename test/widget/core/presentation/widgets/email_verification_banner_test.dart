// Validates EmailVerificationBanner renders correctly and handles user interactions.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/presentation/widgets/email_verification_banner.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget({
    required int daysRemaining,
    VoidCallback? onVerifyNow,
    VoidCallback? onDismiss,
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
        body: EmailVerificationBanner(
          daysRemaining: daysRemaining,
          onVerifyNow: onVerifyNow ?? () {},
          onDismiss: onDismiss ?? () {},
        ),
      ),
    );
  }

  group('EmailVerificationBanner', () {
    testWidgets('renders warning message with days remaining',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(daysRemaining: 5));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('5 days left'),
        findsOneWidget,
      );
    });

    testWidgets('renders warning message with 1 day remaining',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(daysRemaining: 1));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('1 days left'),
        findsOneWidget,
      );
    });

    testWidgets('renders warning message with 7 days remaining',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(daysRemaining: 7));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('7 days left'),
        findsOneWidget,
      );
    });

    testWidgets('renders Verify Now button', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysRemaining: 5));
      await tester.pumpAndSettle();

      expect(find.text('Verify Now'), findsOneWidget);
    });

    testWidgets('renders Dismiss button', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysRemaining: 5));
      await tester.pumpAndSettle();

      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('renders warning icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysRemaining: 5));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('calls onVerifyNow when Verify Now is tapped',
        (tester) async {
      bool verifyNowCalled = false;

      await tester.pumpWidget(buildTestWidget(
        daysRemaining: 5,
        onVerifyNow: () => verifyNowCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verify Now'));
      await tester.pump();

      expect(verifyNowCalled, isTrue);
    });

    testWidgets('calls onDismiss when Dismiss is tapped', (tester) async {
      bool dismissCalled = false;

      await tester.pumpWidget(buildTestWidget(
        daysRemaining: 5,
        onDismiss: () => dismissCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dismiss'));
      await tester.pump();

      expect(dismissCalled, isTrue);
    });

    testWidgets('renders with 0 days remaining', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysRemaining: 0));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('0 days left'),
        findsOneWidget,
      );
    });

    testWidgets('banner takes full width', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysRemaining: 5));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, double.infinity);
    });

    testWidgets('has amber background color', (tester) async {
      await tester.pumpWidget(buildTestWidget(daysRemaining: 5));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(
        (container.decoration as BoxDecoration?)?.color ?? container.color,
        Colors.amber.shade700,
      );
    });
  });
}

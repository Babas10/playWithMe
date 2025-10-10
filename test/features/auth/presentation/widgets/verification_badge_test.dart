// Tests for VerificationBadge widget to ensure proper display of email verification status.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/auth/presentation/widgets/verification_badge.dart';

void main() {
  group('VerificationBadge', () {
    testWidgets('displays verified badge when email is verified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: true),
          ),
        ),
      );

      expect(find.text('Your email is verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Verify Email'), findsNothing);
    });

    testWidgets('displays unverified badge when email is not verified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: false),
          ),
        ),
      );

      expect(find.text('Email not verified'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Please verify your email address to secure your account and access all features.'), findsOneWidget);
      expect(find.text('Verify Email'), findsOneWidget);
    });

    testWidgets('shows verify email button when not verified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: false),
          ),
        ),
      );

      expect(find.widgetWithText(OutlinedButton, 'Verify Email'), findsOneWidget);
    });

    testWidgets('shows coming soon message when verify email is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: false),
          ),
        ),
      );

      await tester.tap(find.text('Verify Email'));
      await tester.pump();

      expect(find.text('Email verification - Coming Soon'), findsOneWidget);
    });

    testWidgets('verified badge has correct colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: true),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Your email is verified'),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green.withValues(alpha: 0.1));
    });

    testWidgets('unverified badge has correct colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: false),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Email not verified'),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.withValues(alpha: 0.1));
    });
  });
}
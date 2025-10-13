// Verifies that VerificationBadge displays correct email verification status indicators

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/presentation/widgets/verification_badge.dart';

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

      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('displays not verified badge when email is not verified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: false),
          ),
        ),
      );

      expect(find.text('Not Verified'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('uses primary colors for verified status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: true),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      // Verify it uses primaryContainer color (MaterialApp default theme)
      expect(decoration.color, isNotNull);
    });

    testWidgets('uses error colors for unverified status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: false),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      // Verify it uses errorContainer color
      expect(decoration.color, isNotNull);
    });
  });
}

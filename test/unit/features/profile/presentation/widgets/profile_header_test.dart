// Verifies that ProfileHeader displays user avatar, name, email, and verification badge correctly

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_header.dart';
import 'package:play_with_me/features/profile/presentation/widgets/verification_badge.dart';

void main() {
  group('ProfileHeader', () {
    testWidgets('displays user display name when available', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'John Doe',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('displays email when display name is null', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: null,
        photoUrl: null,
        isEmailVerified: false,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      // displayNameOrEmail should return email when displayName is null
      expect(find.text('test@example.com'), findsWidgets);
    });

    testWidgets('displays default person icon when photoUrl is null', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('includes verification badge', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.byType(VerificationBadge), findsOneWidget);
    });

    testWidgets('uses themed colors and styling', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(CircleAvatar),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, isNotNull);
      expect(decoration.borderRadius, isNotNull);
    });
  });
}

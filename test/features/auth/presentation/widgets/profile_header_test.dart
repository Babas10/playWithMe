// Tests for ProfileHeader widget to ensure proper display of user avatar, name, and account type.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/widgets/profile_header.dart';

void main() {
  group('ProfileHeader', () {
    testWidgets('displays user display name and email', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('displays fallback to email when display name is null', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: null,
        isEmailVerified: true,
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.text('test@example.com'), findsNWidgets(2)); // Header and email
    });

    testWidgets('displays placeholder avatar when no photo URL', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('displays verification icon for verified email', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('displays pending icon for unverified email', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: false,
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.byIcon(Icons.pending), findsOneWidget);
    });

    testWidgets('displays guest account badge for anonymous user', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'anonymous@example.com',
        displayName: null,
        isEmailVerified: false,
        isAnonymous: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.text('Guest Account'), findsOneWidget);
    });

    testWidgets('displays registered user badge for regular user', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.text('Registered User'), findsOneWidget);
    });

    testWidgets('displays profile header in a card', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays network image when photo URL is provided', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        isEmailVerified: true,
        isAnonymous: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: testUser),
          ),
        ),
      );

      // Just check that the CircleAvatar has a background image without loading it
      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.backgroundImage, isA<NetworkImage>());
      expect((circleAvatar.backgroundImage as NetworkImage).url, 'https://example.com/photo.jpg');

      // Verify that the default icon is not shown when photo URL exists
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });
}
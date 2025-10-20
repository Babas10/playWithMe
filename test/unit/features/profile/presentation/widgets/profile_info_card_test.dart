// Verifies that ProfileInfoCard displays account information with proper formatting

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

void main() {
  group('ProfileInfoCard', () {
    testWidgets('displays account type as Regular for non-anonymous users', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid-123',
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: ProfileInfoCard(user: testUser),
          ),
        ),
      );

      expect(find.text('Account Type'), findsOneWidget);
      expect(find.text('Regular'), findsOneWidget);
    });

    testWidgets('displays account type as Anonymous for anonymous users', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid-123',
        email: 'anon@example.com',
        displayName: null,
        photoUrl: null,
        isEmailVerified: false,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: true,
      );

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
            body: ProfileInfoCard(user: testUser),
          ),
        ),
      );

      expect(find.text('Anonymous'), findsOneWidget);
    });

    testWidgets('displays formatted member since date', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 15),
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: false,
      );

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
            body: ProfileInfoCard(user: testUser),
          ),
        ),
      );

      expect(find.text('Member Since'), findsOneWidget);
      expect(find.text('Jan 15, 2024'), findsOneWidget);
    });

    testWidgets('displays formatted last active date', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: DateTime(2024, 10, 12),
        isAnonymous: false,
      );

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
            body: ProfileInfoCard(user: testUser),
          ),
        ),
      );

      expect(find.text('Last Active'), findsOneWidget);
      expect(find.text('Oct 12, 2024'), findsOneWidget);
    });

    testWidgets('omits member since when createdAt is null', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: null,
        lastSignInAt: DateTime(2024, 10, 1),
        isAnonymous: false,
      );

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
            body: ProfileInfoCard(user: testUser),
          ),
        ),
      );

      expect(find.text('Member Since'), findsNothing);
    });

    testWidgets('omits last active when lastSignInAt is null', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: null,
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 1),
        lastSignInAt: null,
        isAnonymous: false,
      );

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
            body: ProfileInfoCard(user: testUser),
          ),
        ),
      );

      expect(find.text('Last Active'), findsNothing);
    });

    testWidgets('uses Card widget with proper styling', (tester) async {
      final testUser = UserEntity(
        uid: 'test-uid-123',
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: ProfileInfoCard(user: testUser),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Account Information'), findsOneWidget);
    });
  });
}

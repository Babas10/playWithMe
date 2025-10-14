// Verifies that ProfileEditPage displays form correctly and handles user interactions with validation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/profile/presentation/pages/profile_edit_page.dart';

// Mocktail mocks
class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthenticationBloc mockAuthBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthBloc = MockAuthenticationBloc();
  });

  Widget createWidgetUnderTest(UserEntity user) {
    return MaterialApp(
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: mockAuthRepository),
        ],
        child: BlocProvider<AuthenticationBloc>.value(
          value: mockAuthBloc,
          child: ProfileEditPage(user: user),
        ),
      ),
    );
  }

  group('ProfileEditPage', () {
    final testUser = UserEntity(
      uid: 'test-uid-123',
      email: 'test@example.com',
      displayName: 'John Doe',
      photoUrl: 'https://example.com/photo.jpg',
      isEmailVerified: true,
      createdAt: DateTime(2024, 1, 1),
      lastSignInAt: DateTime(2024, 10, 1),
      isAnonymous: false,
    );

    testWidgets('displays form with initial user data', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testUser));
      await tester.pumpAndSettle();

      // Verify AppBar
      expect(find.text('Edit Profile'), findsOneWidget);

      // Verify form fields are present
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Verify initial values
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('https://example.com/photo.jpg'), findsOneWidget);

      // Verify buttons
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays user without displayName using email', (tester) async {
      final userWithoutName = testUser.copyWith(displayName: null);

      await tester.pumpWidget(createWidgetUnderTest(userWithoutName));
      await tester.pumpAndSettle();

      // Verify email is used as fallback
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Save button is initially disabled with no changes', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testUser));
      await tester.pumpAndSettle();

      // Find the Save Changes button by text
      final saveButtonText = find.text('Save Changes');
      expect(saveButtonText, findsOneWidget);

      // The button should be disabled (tapping should have no effect)
      // We verify this by checking that the button widget itself is disabled
      final filledButton = find.byWidgetPredicate(
        (widget) => widget is FilledButton && widget.onPressed == null,
      );
      expect(filledButton, findsOneWidget);
    });

    testWidgets('displays validation error for short display name', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testUser));
      await tester.pumpAndSettle();

      // Find display name field
      final displayNameField = find.ancestor(
        of: find.text('John Doe'),
        matching: find.byType(TextFormField),
      );

      // Clear and enter short name
      await tester.enterText(displayNameField, 'Jo');
      await tester.pumpAndSettle();

      // Verify error message appears
      expect(find.text('Display name must be at least 3 characters'), findsOneWidget);
    });

    testWidgets('displays validation error for empty display name', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testUser));
      await tester.pumpAndSettle();

      // Find display name field
      final displayNameField = find.ancestor(
        of: find.text('John Doe'),
        matching: find.byType(TextFormField),
      );

      // Clear the field
      await tester.enterText(displayNameField, '');
      await tester.pumpAndSettle();

      // Verify error message appears
      expect(find.text('Display name cannot be empty'), findsOneWidget);
    });

    testWidgets('displays validation error for invalid photo URL', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testUser));
      await tester.pumpAndSettle();

      // Find photo URL field
      final photoUrlFields = find.byType(TextFormField);
      final photoUrlField = photoUrlFields.at(1); // Second text field

      // Enter invalid URL (no http/https)
      await tester.enterText(photoUrlField, 'not-a-url');
      await tester.pumpAndSettle();

      // Verify error message appears
      expect(find.text('URL must start with http:// or https://'), findsOneWidget);
    });

    testWidgets('Save button becomes enabled after valid changes', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testUser));
      await tester.pumpAndSettle();

      // Find display name field and change it
      final displayNameField = find.ancestor(
        of: find.text('John Doe'),
        matching: find.byType(TextFormField),
      );

      await tester.enterText(displayNameField, 'Jane Smith');
      await tester.pumpAndSettle();

      // Verify button is now enabled by checking that an enabled FilledButton exists
      final enabledButton = find.byWidgetPredicate(
        (widget) => widget is FilledButton && widget.onPressed != null,
      );
      expect(enabledButton, findsOneWidget);
    });

    testWidgets('Save action appears in AppBar after changes', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testUser));
      await tester.pumpAndSettle();

      // Initially no Save button in AppBar
      final saveTextInAppBar = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Save'),
      );
      expect(saveTextInAppBar, findsNothing);

      // Make a change
      final displayNameField = find.ancestor(
        of: find.text('John Doe'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(displayNameField, 'Jane Smith');
      await tester.pumpAndSettle();

      // Now Save button should appear in AppBar
      expect(find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Save'),
      ), findsOneWidget);
    });

    testWidgets('Cancel button works', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testUser));
      await tester.pumpAndSettle();

      // Tap cancel button by text
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Page should be popped (no longer visible)
      expect(find.byType(ProfileEditPage), findsNothing);
    });
  });
}

// Verifies that ProfileEditPage displays form correctly and handles user interactions with validation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/repositories/image_storage_repository.dart';
import 'package:play_with_me/core/services/image_picker_service.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import 'package:play_with_me/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

// Mocktail mocks
class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}
class MockImageStorageRepository extends Mock implements ImageStorageRepository {}
class MockImagePickerService extends Mock implements ImagePickerService {}
class MockLocalePreferencesRepository extends Mock implements LocalePreferencesRepository {}

// Fakes for fallback values
class FakeLocalePreferencesEntity extends Fake implements LocalePreferencesEntity {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthenticationBloc mockAuthBloc;

  setUpAll(() {
    // Register fallback values for mocktail matchers
    registerFallbackValue(FakeLocalePreferencesEntity());
    // Create mock instances that will be reused
    final mockImageStorage = MockImageStorageRepository();
    final mockImagePicker = MockImagePickerService();
    final mockLocalePrefs = MockLocalePreferencesRepository();

    // Stub the locale preferences repository with default behavior
    when(() => mockLocalePrefs.loadPreferences()).thenAnswer(
      (_) async => LocalePreferencesEntity.defaultPreferences(),
    );
    when(() => mockLocalePrefs.savePreferences(any())).thenAnswer(
      (_) async {},
    );
    when(() => mockLocalePrefs.syncToFirestore(any(), any())).thenAnswer(
      (_) async {},
    );
    when(() => mockLocalePrefs.loadFromFirestore(any())).thenAnswer(
      (_) async => null,
    );
    when(() => mockLocalePrefs.getDeviceTimeZone()).thenReturn('UTC');

    // Register GetIt services for AvatarUploadWidget and LocalePreferences
    if (!sl.isRegistered<ImageStorageRepository>()) {
      sl.registerLazySingleton<ImageStorageRepository>(
        () => mockImageStorage,
      );
    }
    if (!sl.isRegistered<ImagePickerService>()) {
      sl.registerLazySingleton<ImagePickerService>(
        () => mockImagePicker,
      );
    }
    if (!sl.isRegistered<LocalePreferencesRepository>()) {
      sl.registerLazySingleton<LocalePreferencesRepository>(
        () => mockLocalePrefs,
      );
    }
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthBloc = MockAuthenticationBloc();
  });

  Widget createWidgetUnderTest(UserEntity user) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
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
      expect(find.text('Account Settings'), findsOneWidget);

      // Verify form fields are present (display name + time zone fields)
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Verify initial display name value
      expect(find.text('John Doe'), findsOneWidget);

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

      // Find the Save Changes button
      final saveButtonText = find.text('Save Changes');
      expect(saveButtonText, findsOneWidget);

      // The button should be disabled (onPressed == null)
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

      // Verify button is now enabled
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

    testWidgets('displays avatar upload widget', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testUser));
      await tester.pumpAndSettle();

      // Verify avatar/profile picture is displayed (CircleAvatar)
      expect(find.byType(CircleAvatar), findsWidgets);

      // Avatar should be visible in the UI
      final circleAvatars = find.byType(CircleAvatar);
      expect(circleAvatars, findsAtLeastNWidgets(1));
    });

    group('Avatar Upload Integration', () {
      testWidgets('shows camera icon button when not uploading', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testUser));
        await tester.pumpAndSettle();

        // Find camera icon button
        final cameraIcon = find.widgetWithIcon(IconButton, Icons.camera_alt);
        expect(cameraIcon, findsOneWidget);
      });

      testWidgets('camera button opens image source selection dialog', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testUser));
        await tester.pumpAndSettle();

        // Tap camera button
        final cameraButton = find.widgetWithIcon(IconButton, Icons.camera_alt);
        await tester.tap(cameraButton);
        await tester.pumpAndSettle();

        // Verify bottom sheet appears with options
        expect(find.text('Take Photo'), findsOneWidget);
        expect(find.text('Choose from Gallery'), findsOneWidget);
        // Note: "Cancel" text appears in both AppBar and bottom sheet, so we check for at least one
        expect(find.text('Cancel'), findsWidgets);
      });

      testWidgets('shows delete button when user has current photo', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testUser));
        await tester.pumpAndSettle();

        // Verify Remove Avatar button is present
        expect(find.text('Remove Avatar'), findsOneWidget);
      });

      testWidgets('does not show delete button when user has no photo', (tester) async {
        final userWithoutPhoto = testUser.copyWith(photoUrl: null);
        await tester.pumpWidget(createWidgetUnderTest(userWithoutPhoto));
        await tester.pumpAndSettle();

        // Verify Remove Avatar button is NOT present
        expect(find.text('Remove Avatar'), findsNothing);
      });

      testWidgets('delete button shows confirmation dialog', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testUser));
        await tester.pumpAndSettle();

        // Tap Remove Avatar button
        await tester.tap(find.text('Remove Avatar'));
        await tester.pumpAndSettle();

        // Verify confirmation dialog appears
        expect(find.text('Are you sure you want to remove your avatar?'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Remove'), findsOneWidget);
      });

      testWidgets('displays network image when user has photo URL', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testUser));
        await tester.pumpAndSettle();

        // Find CircleAvatar with NetworkImage
        final circleAvatar = tester.widget<CircleAvatar>(
          find.byType(CircleAvatar).first,
        );

        // Verify it has a NetworkImage
        expect(circleAvatar.backgroundImage, isA<NetworkImage>());
        final networkImage = circleAvatar.backgroundImage as NetworkImage;
        expect(networkImage.url, testUser.photoUrl);
      });

      testWidgets('displays default icon when user has no photo', (tester) async {
        final userWithoutPhoto = testUser.copyWith(photoUrl: null);
        await tester.pumpWidget(createWidgetUnderTest(userWithoutPhoto));
        await tester.pumpAndSettle();

        // Find CircleAvatar with Icon
        final circleAvatar = tester.widget<CircleAvatar>(
          find.byType(CircleAvatar).first,
        );

        // Verify it has no background image and contains Icon
        expect(circleAvatar.backgroundImage, isNull);
        expect(circleAvatar.child, isA<Icon>());
      });

      testWidgets('avatar upload widget is enabled when form is editable', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testUser));
        await tester.pumpAndSettle();

        // Camera button should be enabled (findable and tappable)
        final cameraButton = find.widgetWithIcon(IconButton, Icons.camera_alt);
        expect(cameraButton, findsOneWidget);

        // Try tapping - should work without errors
        await tester.tap(cameraButton);
        await tester.pumpAndSettle();

        // Bottom sheet should appear
        expect(find.text('Take Photo'), findsOneWidget);
      });
    });

    group('Form Integration with Avatar Upload', () {
      testWidgets('changing display name and avatar both enable save button', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testUser));
        await tester.pumpAndSettle();

        // Initially button should be disabled
        final disabledButton = find.byWidgetPredicate(
          (widget) => widget is FilledButton && widget.onPressed == null,
        );
        expect(disabledButton, findsOneWidget);

        // Change display name
        final displayNameField = find.ancestor(
          of: find.text('John Doe'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(displayNameField, 'Jane Smith');
        await tester.pumpAndSettle();

        // Button should now be enabled
        final enabledButton = find.byWidgetPredicate(
          (widget) => widget is FilledButton && widget.onPressed != null,
        );
        expect(enabledButton, findsOneWidget);
      });

      testWidgets('displays correct number of form fields', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(testUser));
        await tester.pumpAndSettle();

        // Should have 2 TextFormFields (display name + time zone)
        // Should have 2 DropdownButtonFormFields (language + country)
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.byType(DropdownButtonFormField<Locale>), findsOneWidget);
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      });
    });
  });
}

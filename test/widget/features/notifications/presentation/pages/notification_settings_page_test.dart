// Widget tests for NotificationSettingsPage - validates UI rendering and user interactions
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/features/notifications/domain/entities/notification_preferences_entity.dart';
import 'package:play_with_me/features/notifications/domain/repositories/notification_repository.dart';
import 'package:play_with_me/features/notifications/presentation/pages/notification_settings_page.dart';

// Mocks
class MockNotificationRepository extends Mock
    implements NotificationRepository {}
class MockInvitationBloc extends Mock implements InvitationBloc {}
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

// Fakes
class FakeNotificationPreferencesEntity extends Fake
    implements NotificationPreferencesEntity {}

void main() {
  late MockNotificationRepository mockRepository;
  late MockInvitationBloc mockInvitationBloc;
  late MockAuthenticationBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeNotificationPreferencesEntity());
  });

  setUp(() {
    mockRepository = MockNotificationRepository();
    mockInvitationBloc = MockInvitationBloc();
    mockAuthBloc = MockAuthenticationBloc();
    when(() => mockInvitationBloc.state).thenReturn(const InvitationInitial());
    when(() => mockInvitationBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.state).thenReturn(
      AuthenticationAuthenticated(
        UserEntity(uid: 'test-user', email: 'test@example.com', isEmailVerified: true, isAnonymous: false),
      ),
    );
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    // Register mock repository in GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<NotificationRepository>()) {
      getIt.unregister<NotificationRepository>();
    }
    getIt.registerSingleton<NotificationRepository>(mockRepository);

    // Default stub
    when(() => mockRepository.getPreferences())
        .thenAnswer((_) async => const NotificationPreferencesEntity());
    when(() => mockRepository.preferencesStream()).thenAnswer(
      (_) => Stream.value(const NotificationPreferencesEntity()),
    );
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<InvitationBloc>.value(value: mockInvitationBloc),
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        ],
        child: const NotificationSettingsPage(),
      ),
    );
  }

  group('NotificationSettingsPage - Basic Rendering', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Trigger initial build

      // Assert
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('initially shows initializing state',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Initial state before async load completes
      expect(find.text('Initializing...'), findsOneWidget);
    });

    testWidgets('loads and displays preferences after initialization',
        (WidgetTester tester) async {
      // Arrange
      const testPreferences = NotificationPreferencesEntity(
        groupInvitations: true,
        invitationAccepted: false,
      );
      when(() => mockRepository.getPreferences())
          .thenAnswer((_) async => testPreferences);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Initial build
      await tester.pump(); // Process load event
      await tester.pump(); // Process async result

      // Assert - Should have loaded preferences
      expect(find.text('Group Invitations'), findsOneWidget);
      expect(find.text('Invitation Accepted'), findsOneWidget);
    });
  });

  group('NotificationSettingsPage - Toggle Switches', () {
    testWidgets('displays notification toggle switches',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Assert - Check main toggle switches exist
      expect(find.text('Group Invitations'), findsOneWidget);
      expect(find.text('Invitation Accepted'), findsOneWidget);
      expect(find.text('New Games'), findsOneWidget);
      expect(find.text('Role Changes'), findsOneWidget);
    });

    testWidgets('displays admin notification toggles',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Scroll down to find Admin Notifications section (after Training Sessions)
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Member Joined'), findsOneWidget);
      expect(find.text('Member Left'), findsOneWidget);
    });

    testWidgets('displays quiet hours toggle', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Scroll down to find Quiet Hours section
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enable Quiet Hours'), findsOneWidget);
    });
  });

  group('NotificationSettingsPage - Section Headers', () {
    testWidgets('displays section headers', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Assert - Group Events and Training Sessions are visible at the top
      expect(find.text('Group Events'), findsOneWidget);
      expect(find.text('Training Sessions'), findsOneWidget);

      // Scroll down to find Admin Notifications and Quiet Hours
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(find.text('Admin Notifications'), findsOneWidget);
      expect(find.text('Quiet Hours'), findsOneWidget);
    });

    testWidgets('displays admin notification description',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Scroll down to find Admin Notifications section (after Training Sessions)
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.text('Only receive these if you are an admin'), findsOneWidget);
    });
  });

  group('NotificationSettingsPage - Error Handling', () {
    testWidgets('displays error message when loading fails',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockRepository.getPreferences())
          .thenThrow(Exception('Failed to load preferences'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Initial build
      await tester.pump(); // Process load event
      await tester.pump(); // Process error

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button reloads preferences',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockRepository.getPreferences())
          .thenThrow(Exception('Failed to load preferences'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Tap retry button
      when(() => mockRepository.getPreferences())
          .thenAnswer((_) async => const NotificationPreferencesEntity());

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Assert - Should now show the settings
      expect(find.text('Group Invitations'), findsOneWidget);
    });
  });

  group('NotificationSettingsPage - Quiet Hours Display', () {
    testWidgets('shows default quiet hours message when disabled',
        (WidgetTester tester) async {
      // Arrange
      const preferences = NotificationPreferencesEntity(
        quietHoursEnabled: false,
      );
      when(() => mockRepository.getPreferences())
          .thenAnswer((_) async => preferences);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Scroll down to find Quiet Hours section
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pause notifications during specific times'),
          findsOneWidget);
      expect(find.text('Adjust Quiet Hours'), findsNothing);
    });

    testWidgets('shows time range when quiet hours enabled',
        (WidgetTester tester) async {
      // Arrange
      const preferences = NotificationPreferencesEntity(
        quietHoursEnabled: true,
        quietHoursStart: '22:00',
        quietHoursEnd: '08:00',
      );
      when(() => mockRepository.getPreferences())
          .thenAnswer((_) async => preferences);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Scroll down to find Quiet Hours section
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No notifications from 22:00 to 08:00'), findsOneWidget);
      expect(find.text('Adjust Quiet Hours'), findsOneWidget);
    });
  });

  group('NotificationSettingsPage - Switch Values', () {
    testWidgets('switches reflect preference values',
        (WidgetTester tester) async {
      // Arrange
      const preferences = NotificationPreferencesEntity(
        groupInvitations: true,
        invitationAccepted: false,
        gameCreated: true,
        memberJoined: false,
      );
      when(() => mockRepository.getPreferences())
          .thenAnswer((_) async => preferences);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Assert - Find switches and check their values
      final groupInvitationsSwitch = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text('Group Invitations'),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(groupInvitationsSwitch.value, true);

      final invitationAcceptedSwitch = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text('Invitation Accepted'),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(invitationAcceptedSwitch.value, false);

      final gameCreatedSwitch = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text('New Games'),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(gameCreatedSwitch.value, true);
    });
  });

  group('NotificationSettingsPage - Update Operations', () {
    testWidgets('updates repository when switch is toggled',
        (WidgetTester tester) async {
      // Arrange
      const initialPreferences = NotificationPreferencesEntity(
        groupInvitations: false,
      );
      when(() => mockRepository.getPreferences())
          .thenAnswer((_) async => initialPreferences);
      when(() => mockRepository.updatePreferences(any()))
          .thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Find and tap the group invitations switch
      await tester.tap(find.ancestor(
        of: find.text('Group Invitations'),
        matching: find.byType(SwitchListTile),
      ));
      await tester.pump();

      // Assert - Verify update was called
      verify(() => mockRepository.updatePreferences(any())).called(1);
    });
  });
}

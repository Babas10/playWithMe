// Validates InviteOnboardingPage renders correct UI states for validating, validated, invalid, and error states.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_event.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_state.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_state.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_state.dart';
import 'package:play_with_me/features/invitations/presentation/pages/invite_onboarding_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockInviteJoinBloc
    extends MockBloc<InviteJoinEvent, InviteJoinState>
    implements InviteJoinBloc {}

class MockInviteRegistrationBloc
    extends MockBloc<InviteRegistrationEvent, InviteRegistrationState>
    implements InviteRegistrationBloc {}

class MockDeepLinkBloc extends MockBloc<DeepLinkEvent, DeepLinkState>
    implements DeepLinkBloc {}

void main() {
  late MockInviteJoinBloc mockBloc;
  late MockDeepLinkBloc mockDeepLinkBloc;

  setUpAll(() {
    registerFallbackValue(const ValidateInviteToken(''));
    registerFallbackValue(const InviteJoinInitial());
    registerFallbackValue(const InviteRegistrationFormReset());
    registerFallbackValue(const InviteRegistrationInitial());
    registerFallbackValue(const ClearPendingInvite());
    registerFallbackValue(const DeepLinkInitial());
  });

  setUp(() {
    mockBloc = MockInviteJoinBloc();
    mockDeepLinkBloc = MockDeepLinkBloc();
    when(() => mockDeepLinkBloc.state).thenReturn(const DeepLinkInitial());

    // Register mock InviteRegistrationBloc in GetIt for navigation tests
    final sl = GetIt.instance;
    if (sl.isRegistered<InviteRegistrationBloc>()) {
      sl.unregister<InviteRegistrationBloc>();
    }
    final mockRegBloc = MockInviteRegistrationBloc();
    when(() => mockRegBloc.state)
        .thenReturn(const InviteRegistrationInitial());
    sl.registerFactory<InviteRegistrationBloc>(() => mockRegBloc);
  });

  tearDown(() {
    mockBloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<InviteRegistrationBloc>()) {
      sl.unregister<InviteRegistrationBloc>();
    }
  });

  Widget createTestWidget({String token = 'test-token'}) {
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
          BlocProvider<InviteJoinBloc>.value(value: mockBloc),
          BlocProvider<DeepLinkBloc>.value(value: mockDeepLinkBloc),
        ],
        child: InviteOnboardingPage(token: token),
      ),
    );
  }

  group('InviteOnboardingPage', () {
    group('loading state', () {
      testWidgets('shows loading indicator when validating', (tester) async {
        when(() => mockBloc.state).thenReturn(const InviteJoinValidating());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Validating invite...'), findsOneWidget);
      });

      testWidgets('shows loading indicator for initial state', (tester) async {
        when(() => mockBloc.state).thenReturn(const InviteJoinInitial());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('validated state', () {
      const validatedState = InviteJoinValidated(
        groupId: 'group-123',
        groupName: 'Beach Volleyball Crew',
        groupDescription: 'Weekend players',
        memberCount: 8,
        inviterName: 'John Doe',
        token: 'test-token',
      );

      testWidgets('shows group name and inviter info', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
        expect(find.text('Invited by John Doe'), findsOneWidget);
        expect(find.text('8 members'), findsOneWidget);
      });

      testWidgets('shows onboarding title and subtitle', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(createTestWidget());

        expect(find.text("You've been invited!"), findsOneWidget);
        expect(find.text("You've been invited to join:"), findsOneWidget);
      });

      testWidgets('shows create account and login buttons', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Create Account'), findsOneWidget);
        expect(find.text('I have an account'), findsOneWidget);
      });

      testWidgets('create account button navigates to InviteRegistrationPage',
          (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: MultiBlocProvider(
              providers: [
                BlocProvider<InviteJoinBloc>.value(value: mockBloc),
                BlocProvider<DeepLinkBloc>.value(value: mockDeepLinkBloc),
              ],
              child: const InviteOnboardingPage(token: 'test-token'),
            ),
          ),
        );

        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        // Verifies navigation to InviteRegistrationPage with group context
        expect(find.text('Create your account to join:'), findsOneWidget);
        expect(find.text('Beach Volleyball Crew'), findsOneWidget);
      });

      testWidgets('login button pops back to root', (tester) async {
        when(() => mockBloc.state).thenReturn(validatedState);

        // Build with a root page and push InviteOnboardingPage on top,
        // so popUntil(isFirst) pops back to the root.
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: MultiBlocProvider(
              providers: [
                BlocProvider<InviteJoinBloc>.value(value: mockBloc),
                BlocProvider<DeepLinkBloc>.value(value: mockDeepLinkBloc),
              ],
              child: Builder(
                builder: (context) {
                  // Schedule a navigation push after the first frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider<InviteJoinBloc>.value(
                                value: mockBloc),
                            BlocProvider<DeepLinkBloc>.value(
                                value: mockDeepLinkBloc),
                          ],
                          child: const InviteOnboardingPage(
                              token: 'test-token'),
                        ),
                      ),
                    );
                  });
                  return const Scaffold(body: Text('Root Page'));
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // InviteOnboardingPage should be visible now
        expect(find.text('I have an account'), findsOneWidget);

        await tester.tap(find.text('I have an account'));
        await tester.pumpAndSettle();

        // After popUntil(isFirst), we should be back at the root page
        expect(find.text('Root Page'), findsOneWidget);
      });
    });

    group('invalid token state', () {
      testWidgets('shows error icon and reason message', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const InviteJoinInvalidToken(reason: 'This invite has expired'),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('This invite has expired'), findsOneWidget);
        expect(find.text('Continue to app'), findsOneWidget);
      });

      testWidgets('continue button clears deep link and pops to root',
          (tester) async {
        when(() => mockBloc.state).thenReturn(
          const InviteJoinInvalidToken(reason: 'Expired'),
        );

        // Build with a root page and push InviteOnboardingPage on top,
        // so popUntil(isFirst) pops back to the root.
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: MultiBlocProvider(
              providers: [
                BlocProvider<InviteJoinBloc>.value(value: mockBloc),
                BlocProvider<DeepLinkBloc>.value(value: mockDeepLinkBloc),
              ],
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider<InviteJoinBloc>.value(
                                value: mockBloc),
                            BlocProvider<DeepLinkBloc>.value(
                                value: mockDeepLinkBloc),
                          ],
                          child: const InviteOnboardingPage(
                              token: 'test-token'),
                        ),
                      ),
                    );
                  });
                  return const Scaffold(body: Text('Root Page'));
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // InviteOnboardingPage should be visible now
        expect(find.text('Continue to app'), findsOneWidget);

        await tester.tap(find.text('Continue to app'));
        await tester.pumpAndSettle();

        // Verify ClearPendingInvite was dispatched to DeepLinkBloc
        verify(() => mockDeepLinkBloc.add(const ClearPendingInvite()))
            .called(1);

        // After popUntil(isFirst), we should be back at the root page
        expect(find.text('Root Page'), findsOneWidget);
      });
    });

    group('error state', () {
      testWidgets('shows error icon and error message', (tester) async {
        when(() => mockBloc.state).thenReturn(
          const InviteJoinError(message: 'Network error occurred'),
        );

        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Network error occurred'), findsOneWidget);
        expect(find.text('Continue to app'), findsOneWidget);
      });
    });
  });
}

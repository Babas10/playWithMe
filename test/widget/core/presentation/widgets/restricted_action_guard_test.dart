// Validates RestrictedActionGuard blocks restricted users and allows active/pending users.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_state.dart';
import 'package:play_with_me/core/presentation/widgets/restricted_action_guard.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MockAccountStatusBloc
    extends Mock
    implements AccountStatusBloc {
  final AccountStatusState _state;

  MockAccountStatusBloc(this._state);

  @override
  AccountStatusState get state => _state;

  @override
  Stream<AccountStatusState> get stream => Stream.value(_state);
}

void main() {
  group('RestrictedActionGuard.isActionAllowed', () {
    test('returns true for AccountStatusActive', () {
      expect(
        RestrictedActionGuard.isActionAllowed(const AccountStatusActive()),
        isTrue,
      );
    });

    test('returns true for AccountStatusPending', () {
      expect(
        RestrictedActionGuard.isActionAllowed(
          const AccountStatusPending(daysRemaining: 5),
        ),
        isTrue,
      );
    });

    test('returns true for AccountStatusLoading', () {
      expect(
        RestrictedActionGuard.isActionAllowed(const AccountStatusLoading()),
        isTrue,
      );
    });

    test('returns false for AccountStatusRestricted', () {
      expect(
        RestrictedActionGuard.isActionAllowed(
          const AccountStatusRestricted(daysUntilDeletion: 15),
        ),
        isFalse,
      );
    });
  });

  group('RestrictedActionGuard.check', () {
    Widget buildTestApp({
      required AccountStatusState accountState,
      required VoidCallback onAllowed,
      required VoidCallback onVerifyEmail,
    }) {
      final bloc = MockAccountStatusBloc(accountState);

      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: BlocProvider<AccountStatusBloc>.value(
          value: bloc,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => RestrictedActionGuard.check(
                    context: context,
                    onAllowed: onAllowed,
                    onVerifyEmail: onVerifyEmail,
                  ),
                  child: const Text('Test Action'),
                ),
              );
            },
          ),
        ),
      );
    }

    testWidgets('calls onAllowed when account is active', (tester) async {
      bool allowedCalled = false;

      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusActive(),
        onAllowed: () => allowedCalled = true,
        onVerifyEmail: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pump();

      expect(allowedCalled, isTrue);
    });

    testWidgets('calls onAllowed when account is pending', (tester) async {
      bool allowedCalled = false;

      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusPending(daysRemaining: 5),
        onAllowed: () => allowedCalled = true,
        onVerifyEmail: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pump();

      expect(allowedCalled, isTrue);
    });

    testWidgets('shows restriction dialog when account is restricted',
        (tester) async {
      bool allowedCalled = false;

      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusRestricted(daysUntilDeletion: 15),
        onAllowed: () => allowedCalled = true,
        onVerifyEmail: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pumpAndSettle();

      expect(allowedCalled, isFalse);
      expect(find.text('Feature Restricted'), findsOneWidget);
      expect(find.text('This feature requires email verification.'),
          findsOneWidget);
      expect(find.text('Verify your email to use this feature.'),
          findsOneWidget);
    });

    testWidgets('restriction dialog shows days until deletion',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusRestricted(daysUntilDeletion: 15),
        onAllowed: () {},
        onVerifyEmail: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pumpAndSettle();

      expect(find.textContaining('15 days'), findsOneWidget);
    });

    testWidgets('restriction dialog has Dismiss button', (tester) async {
      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusRestricted(daysUntilDeletion: 15),
        onAllowed: () {},
        onVerifyEmail: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pumpAndSettle();

      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('restriction dialog has Verify Email button', (tester) async {
      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusRestricted(daysUntilDeletion: 15),
        onAllowed: () {},
        onVerifyEmail: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pumpAndSettle();

      expect(find.text('Verify Email'), findsOneWidget);
    });

    testWidgets('dismiss closes dialog', (tester) async {
      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusRestricted(daysUntilDeletion: 15),
        onAllowed: () {},
        onVerifyEmail: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      expect(find.text('Feature Restricted'), findsNothing);
    });

    testWidgets('verify email button calls onVerifyEmail and closes dialog',
        (tester) async {
      bool verifyCalled = false;

      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusRestricted(daysUntilDeletion: 15),
        onAllowed: () {},
        onVerifyEmail: () => verifyCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verify Email'));
      await tester.pumpAndSettle();

      expect(verifyCalled, isTrue);
      expect(find.text('Feature Restricted'), findsNothing);
    });

    testWidgets('does not show deletion warning when daysUntilDeletion is 0',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusRestricted(daysUntilDeletion: 0),
        onAllowed: () {},
        onVerifyEmail: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pumpAndSettle();

      expect(find.text('Feature Restricted'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsNothing);
    });

    testWidgets('dialog shows block icon', (tester) async {
      await tester.pumpWidget(buildTestApp(
        accountState: const AccountStatusRestricted(daysUntilDeletion: 15),
        onAllowed: () {},
        onVerifyEmail: () {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Action'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.block), findsOneWidget);
    });
  });
}

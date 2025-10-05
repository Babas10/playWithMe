// Validates that the app correctly renders authentication UI elements after transitioning from old static content
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/presentation/pages/login_page.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'helpers/test_helpers.dart';

void main() {
  setUp(() async {
    await initializeTestDependencies();
  });

  tearDown(() {
    cleanupTestDependencies();
  });

  testWidgets('PlayWithMe app login page shows correct authentication UI elements', (WidgetTester tester) async {
    // Create a test app with the real LoginPage and proper BLoC setup
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>(
          create: (context) => sl<LoginBloc>(),
          child: const LoginPage(),
        ),
      ),
    );

    // Wait for the page to render
    await tester.pump();

    // Verify authentication UI elements are present (not old static content)
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign in to continue organizing your volleyball games'), findsOneWidget);

    // Verify login form fields are present
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields

    // Verify authentication-specific buttons
    expect(find.byType(AuthButton), findsNWidgets(2)); // Login and Continue as Guest buttons
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);

    // Verify volleyball icon is present (app branding)
    expect(find.byIcon(Icons.sports_volleyball), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/widgets/environment_indicator.dart';
import 'package:play_with_me/core/services/firebase_service.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/auth/presentation/pages/login_page.dart';
import 'package:play_with_me/features/auth/presentation/pages/registration_page.dart';
import 'package:play_with_me/features/auth/presentation/pages/password_reset_page.dart';
import 'package:play_with_me/features/auth/presentation/pages/profile_page.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';

class PlayWithMeApp extends StatelessWidget {
  const PlayWithMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => sl<AuthenticationBloc>()..add(const AuthenticationStarted()),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => sl<LoginBloc>(),
        ),
        BlocProvider<RegistrationBloc>(
          create: (context) => sl<RegistrationBloc>(),
        ),
        BlocProvider<PasswordResetBloc>(
          create: (context) => sl<PasswordResetBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'PlayWithMe${EnvironmentConfig.appSuffix}',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationAuthenticated) {
              return const HomePage();
            } else if (state is AuthenticationUnauthenticated) {
              return const LoginPage();
            } else {
              return const _SplashScreen();
            }
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegistrationPage(),
          '/forgot-password': (context) => const PasswordResetPage(),
          '/profile': (context) => const ProfilePage(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Environment indicator at the top
              const EnvironmentIndicator(showDetails: true),

              // App bar
              AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text('PlayWithMe${EnvironmentConfig.appSuffix}'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      context.read<AuthenticationBloc>().add(
                        const AuthenticationLogoutRequested(),
                      );
                    },
                  ),
                ],
              ),

              // Main content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Welcome to PlayWithMe!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Beach volleyball games organizer',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: EnvironmentConfig.isDevelopment
                              ? Colors.red.withValues(alpha: 0.1)
                              : EnvironmentConfig.isStaging
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                          border: Border.all(
                            color: EnvironmentConfig.isDevelopment
                                ? Colors.red
                                : EnvironmentConfig.isStaging
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FirebaseService.isInitialized
                                      ? Icons.cloud_done
                                      : Icons.cloud_off,
                                  size: 16,
                                  color: FirebaseService.isInitialized
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Firebase: ${FirebaseService.isInitialized ? "Connected" : "Disconnected"}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Environment: ${EnvironmentConfig.environmentName}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Project: ${EnvironmentConfig.firebaseProjectId}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Debug panel for development
          const FirebaseDebugPanel(),
        ],
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_volleyball,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'PlayWithMe${EnvironmentConfig.appSuffix}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:play_with_me/features/profile/presentation/pages/profile_page.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_state.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

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
        BlocProvider<LocalePreferencesBloc>(
          create: (context) => LocalePreferencesBloc(
            repository: sl<LocalePreferencesRepository>(),
          )..add(const LocalePreferencesEvent.loadPreferences()),
        ),
      ],
      child: BlocBuilder<LocalePreferencesBloc, LocalePreferencesState>(
        builder: (context, localeState) {
          // Get the current locale from preferences or use default
          Locale currentLocale = const Locale('en');
          if (localeState is LocalePreferencesLoaded) {
            currentLocale = localeState.preferences.locale;
          }

          return MaterialApp(
            title: 'PlayWithMe${EnvironmentConfig.appSuffix}',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            locale: currentLocale,
            supportedLocales: LocalePreferencesEntity.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
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
          );
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
                title: Text('${AppLocalizations.of(context)!.appTitle}${EnvironmentConfig.appSuffix}'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    tooltip: AppLocalizations.of(context)!.profile,
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: AppLocalizations.of(context)!.signOut,
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
                      Text(
                        AppLocalizations.of(context)!.welcomeMessage,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.beachVolleyballOrganizer,
                        style: const TextStyle(fontSize: 16),
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
                                  '${AppLocalizations.of(context)!.firebase}: ${FirebaseService.isInitialized ? AppLocalizations.of(context)!.firebaseConnected : AppLocalizations.of(context)!.firebaseDisconnected}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${AppLocalizations.of(context)!.environment}: ${EnvironmentConfig.environmentName}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${AppLocalizations.of(context)!.project}: ${EnvironmentConfig.firebaseProjectId}',
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
            Text(AppLocalizations.of(context)!.loading),
          ],
        ),
      ),
    );
  }
}
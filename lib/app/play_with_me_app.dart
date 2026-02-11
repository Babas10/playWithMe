import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:play_with_me/core/config/environment_config.dart';
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
import 'package:play_with_me/features/profile/presentation/pages/stats_page.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_state.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_list_page.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group/group_event.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_event.dart';
import 'package:play_with_me/features/invitations/presentation/pages/pending_invitations_page.dart';
import 'package:play_with_me/features/notifications/data/services/notification_service.dart';
import 'package:play_with_me/features/friends/presentation/pages/my_community_page.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_event.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_state.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_state.dart';
import 'package:play_with_me/features/profile/presentation/widgets/home_stats_section.dart';
import 'package:play_with_me/features/profile/presentation/widgets/next_game_card.dart';
import 'package:play_with_me/features/profile/presentation/widgets/next_training_session_card.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/domain/repositories/training_session_repository.dart';
import 'package:play_with_me/features/games/presentation/pages/game_details_page.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_details_page.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
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
        BlocProvider<InvitationBloc>(
          create: (context) => sl<InvitationBloc>(),
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
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationAuthenticated) {
            context.read<InvitationBloc>().add(
              LoadPendingInvitations(userId: state.user.uid),
            );
          }
        },
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
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
              ).copyWith(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                error: AppColors.danger,
                onSurface: AppColors.onSurface,
                onSurfaceVariant: AppColors.textMuted,
              ),
              scaffoldBackgroundColor: AppColors.scaffoldBackground,
              cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white,
                shadowColor: AppColors.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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
              '/my-community': (context) => const MyCommunityPage(),
            },
          );
        },
      ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Pages for bottom navigation: Home, Stats, Groups, Community
  late final List<Widget> _pages;
  late final GroupBloc _groupBloc;
  late final FriendRequestCountBloc _friendRequestCountBloc;
  late final PlayerStatsBloc _playerStatsBloc;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthenticationBloc>().state;
    _groupBloc = sl<GroupBloc>();
    _friendRequestCountBloc = sl<FriendRequestCountBloc>();
    _playerStatsBloc = PlayerStatsBloc(
      userRepository: sl<UserRepository>(),
    );

    if (authState is AuthenticationAuthenticated) {
      _groupBloc.add(LoadGroupsForUser(userId: authState.user.uid));
      _friendRequestCountBloc.add(
        FriendRequestCountEvent.startListening(userId: authState.user.uid),
      );
      _playerStatsBloc.add(LoadPlayerStats(authState.user.uid));

      // Initialize notification service
      _initializeNotifications();
    }

    _pages = [
      const _HomeTab(),
      const StatsPage(),
      BlocProvider<GroupBloc>.value(
        value: _groupBloc,
        child: const GroupListPage(),
      ),
      const MyCommunityPage(),
    ];
  }

  Future<void> _initializeNotifications() async {
    try {
      final notificationService = sl<NotificationService>();
      await notificationService.initialize(
        onMessageTapped: _handleNotificationTap,
      );
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final groupId = data['groupId'] as String?;

    if (!mounted) return;

    switch (type) {
      case 'invitation':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PendingInvitationsPage(),
          ),
        );
        break;
      case 'game_created':
        debugPrint('Game created notification tapped: ${data['gameId']}');
        break;
      case 'member_joined':
      case 'member_left':
      case 'role_changed':
        debugPrint('Group event notification tapped for group: $groupId');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  @override
  void dispose() {
    _groupBloc.close();
    _friendRequestCountBloc.close();
    _playerStatsBloc.close();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_selectedIndex) {
      case 0:
        return l10n.appTitle;
      case 1:
        return l10n.myStats;
      case 2:
        return l10n.myGroups;
      case 3:
        return l10n.myCommunity;
      default:
        return l10n.appTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FriendRequestCountBloc>.value(value: _friendRequestCountBloc),
        BlocProvider<PlayerStatsBloc>.value(value: _playerStatsBloc),
      ],
      child: Scaffold(
        appBar: PlayWithMeAppBar.build(
          context: context,
          title: _getAppBarTitle(context),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.bottomNavBackground,
          selectedItemColor: AppColors.navLabelColor,
          unselectedItemColor: AppColors.navLabelColor,
          selectedIconTheme: const IconThemeData(
            color: AppColors.primary,
          ),
          unselectedIconTheme: const IconThemeData(
            color: AppColors.navLabelColor,
          ),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: AppLocalizations.of(context)!.stats,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.group_work),
              label: AppLocalizations.of(context)!.groups,
            ),
            BottomNavigationBarItem(
              icon: BlocBuilder<FriendRequestCountBloc, FriendRequestCountState>(
                builder: (context, state) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.people),
                      if (state is FriendRequestCountLoaded && state.count > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              state.count > 9 ? '9+' : '${state.count}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              label: AppLocalizations.of(context)!.community,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// Home tab content with player statistics
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState is! AuthenticationAuthenticated) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.welcomeMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          );
        }

        return BlocBuilder<PlayerStatsBloc, PlayerStatsState>(
          builder: (context, statsState) {
            if (statsState is PlayerStatsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (statsState is PlayerStatsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading stats: ${statsState.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (statsState is PlayerStatsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(top: 30, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stats section (ELO, Win Rate, Streak, Games Played)
                    HomeStatsSection(
                      user: statsState.user,
                      ratingHistory: statsState.history,
                    ),

                    const SizedBox(height: 25),

                    // Next Game section title
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 15.0),
                      child: Text(
                        AppLocalizations.of(context)!.nextGame.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Next Game Card
                    StreamBuilder(
                      stream: sl<GameRepository>().getNextGameForUser(authState.user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        if (snapshot.hasError) {
                          debugPrint('NextGame stream error: ${snapshot.error}');
                        }

                        final nextGame = snapshot.data;

                        return NextGameCard(
                          game: nextGame,
                          userId: authState.user.uid,
                          onTap: nextGame != null
                              ? () {
                                  final gameRepository = sl<GameRepository>();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (newContext) => RepositoryProvider.value(
                                        value: gameRepository,
                                        child: GameDetailsPage(
                                          gameId: nextGame.id,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    // Next Training Session section title
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 15.0),
                      child: Text(
                        AppLocalizations.of(context)!.nextTrainingSession.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Next Training Session Card
                    StreamBuilder(
                      stream: sl<TrainingSessionRepository>()
                          .getNextTrainingSessionForUser(authState.user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        if (snapshot.hasError) {
                          debugPrint(
                              'NextTrainingSession stream error: ${snapshot.error}');
                        }

                        final nextSession = snapshot.data;

                        return NextTrainingSessionCard(
                          session: nextSession,
                          userId: authState.user.uid,
                          onTap: nextSession != null
                              ? () {
                                  final trainingSessionRepository =
                                      sl<TrainingSessionRepository>();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (newContext) =>
                                          RepositoryProvider.value(
                                        value: trainingSessionRepository,
                                        child: TrainingSessionDetailsPage(
                                          trainingSessionId: nextSession.id,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            // Initial state
            return Center(
              child: Text(
                AppLocalizations.of(context)!.welcomeMessage,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      },
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

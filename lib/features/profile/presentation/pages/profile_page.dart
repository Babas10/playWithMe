import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_event.dart';
import 'package:play_with_me/features/profile/presentation/pages/email_verification_page.dart';
import 'package:play_with_me/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_actions.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_header.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:play_with_me/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/player_stats/player_stats_state.dart';
import 'package:play_with_me/features/profile/presentation/widgets/expanded_stats_section.dart';
import 'package:play_with_me/features/games/presentation/pages/game_history_screen.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';

/// Profile page displaying user information and account details
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            return BlocProvider(
              create: (context) => PlayerStatsBloc(
                userRepository: sl<UserRepository>(),
              )..add(LoadPlayerStats(state.user.uid)),
              child: _ProfileContent(state: state),
            );
          }

          if (state is AuthenticationUnknown) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Unauthenticated state - should not happen on profile page
          return Center(
            child: Text(AppLocalizations.of(context)!.pleaseLogIn),
          );
        },
      ),
    );
  }
}

/// Private widget containing the actual profile content
class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.state});

  final AuthenticationAuthenticated state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile header with avatar and name
          ProfileHeader(user: state.user),
          const SizedBox(height: 8),

          // Account information card
          ProfileInfoCard(
            user: state.user,
            onVerificationTap: () => _navigateToEmailVerification(context),
          ),
          
          const SizedBox(height: 16),

          // Player Stats (Expanded)
          BlocBuilder<PlayerStatsBloc, PlayerStatsState>(
            builder: (context, statsState) {
              if (statsState is PlayerStatsLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (statsState is PlayerStatsError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading stats',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            statsState.message,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (statsState is PlayerStatsLoaded) {
                return ExpandedStatsSection(
                  user: statsState.user,
                  ratingHistory: statsState.history,
                );
              }

              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 16),

          // Action buttons
          ProfileActions(
            onEditProfile: () {
              final authRepository = sl<AuthRepository>();
              final authBloc = context.read<AuthenticationBloc>();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (newContext) => MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider.value(
                        value: authRepository,
                      ),
                    ],
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: authBloc,
                        ),
                      ],
                      child: ProfileEditPage(user: state.user),
                    ),
                  ),
                ),
              );
            },
            onNotificationSettings: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
            onGameHistory: () {
              final gameRepository = sl<GameRepository>();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (newContext) => RepositoryProvider.value(
                    value: gameRepository,
                    child: GameHistoryScreen(
                      userId: state.user.uid,
                      groupId: null, // null = all groups
                    ),
                  ),
                ),
              );
            },
            onSignOut: () {
              _showSignOutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToEmailVerification(BuildContext context) {
    final authRepository = sl<AuthRepository>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (newContext) => BlocProvider(
          create: (context) => EmailVerificationBloc(
            authRepository: authRepository,
          )..add(const EmailVerificationEvent.checkStatus()),
          child: const EmailVerificationPage(),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              // Trigger logout through AuthenticationBloc
              context
                  .read<AuthenticationBloc>()
                  .add(const AuthenticationLogoutRequested());
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}

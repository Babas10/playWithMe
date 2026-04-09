// Profile page displaying user identity, account information and settings.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/profile/presentation/bloc/account_deletion/account_deletion_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/account_deletion/account_deletion_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/account_deletion/account_deletion_state.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_event.dart';
import 'package:play_with_me/features/profile/presentation/pages/email_verification_page.dart';
import 'package:play_with_me/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_actions.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_header.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:play_with_me/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Profile tab content displaying user identity and account settings.
///
/// This page answers: "Who am I and how do I manage my account?"
/// It shows:
/// - Profile header (avatar, name, email)
/// - Account information card (verification status)
/// - Settings & actions (Account Settings, Notifications, Game History, Sign Out)
///
/// All statistics have been moved to the dedicated StatsPage.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountDeletionBloc>(
      create: (_) => AccountDeletionBloc(authRepository: sl<AuthRepository>()),
      child: BlocListener<AccountDeletionBloc, AccountDeletionState>(
        listener: (context, state) {
          if (state is AccountDeletionSuccess) {
            // Auth state stream will fire, routing the user to login automatically.
            // Show a brief snackbar in case there's a delay.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.deleteAccountSuccess,
                ),
              ),
            );
          } else if (state is AccountDeletionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.deleteAccountError,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationAuthenticated) {
              return _ProfileContent(state: state);
            }

            if (state is AuthenticationUnknown) {
              return const Center(child: CircularProgressIndicator());
            }

            // Unauthenticated state - should not happen on profile page
            return Center(
              child: Text(AppLocalizations.of(context)!.pleaseLogIn),
            );
          },
        ),
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

          // Action buttons
          ProfileActions(
            onEditProfile: () {
              final authRepository = sl<AuthRepository>();
              final authBloc = context.read<AuthenticationBloc>();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (newContext) => MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider.value(value: authRepository),
                    ],
                    child: MultiBlocProvider(
                      providers: [BlocProvider.value(value: authBloc)],
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
            onSignOut: () {
              _showSignOutDialog(context);
            },
            onDeleteAccount: () {
              _showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToEmailVerification(BuildContext context) {
    final authRepository = sl<AuthRepository>();
    // Capture the AccountStatusBloc before navigating so the pushed route
    // (which is outside AccountStatusBloc's provider scope) can still dismiss
    // the banner when the email is confirmed verified.
    final accountStatusBloc = context.read<AccountStatusBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (newContext) => BlocProvider(
          create: (context) =>
              EmailVerificationBloc(authRepository: authRepository)
                ..add(const EmailVerificationEvent.checkStatus()),
          child: EmailVerificationPage(
            onVerified: () =>
                accountStatusBloc.add(const AccountEmailVerified()),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountDeletionBloc = context.read<AccountDeletionBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              accountDeletionBloc.add(
                const AccountDeletionEvent.deleteRequested(),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              // Trigger logout through AuthenticationBloc
              context.read<AuthenticationBloc>().add(
                const AuthenticationLogoutRequested(),
              );
              Navigator.of(dialogContext).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}

// Shared AppBar builder for consistent header styling across all pages.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/invitations/presentation/pages/pending_invitations_page.dart';
import 'package:play_with_me/features/profile/presentation/pages/profile_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class PlayWithMeAppBar {
  PlayWithMeAppBar._();

  /// Builds the standard AppBar with volleyball icon, title, and user actions.
  ///
  /// When [showUserActions] is true (default), the AppBar includes:
  /// - Invitation badge (requires [InvitationBloc] in context)
  /// - Profile icon (navigates to ProfilePage)
  /// - Logout icon (shows sign-out confirmation dialog)
  ///
  /// Set [showUserActions] to false for unauthenticated pages (login, register).
  /// Set [showProfileAction] to false when already on the profile page.
  ///
  /// [extraActions] are placed after the user actions.
  static AppBar build({
    required BuildContext context,
    required String title,
    List<Widget>? extraActions,
    bool showUserActions = true,
    bool showProfileAction = true,
  }) {
    return AppBar(
      backgroundColor: AppColors.appBarBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 52,
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_volleyball,
            color: AppColors.secondary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    letterSpacing: -0.5,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.divider,
          height: 1,
        ),
      ),
      actions: [
        if (showUserActions) ..._buildUserActions(
          context: context,
          showProfileAction: showProfileAction,
        ),
        if (extraActions != null) ...extraActions,
      ],
    );
  }

  static List<Widget> _buildUserActions({
    required BuildContext context,
    required bool showProfileAction,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return [
      // Invitation badge
      BlocBuilder<InvitationBloc, InvitationState>(
        builder: (context, state) {
          int pendingCount = 0;
          if (state is InvitationsLoaded) {
            pendingCount = state.invitations.length;
          }

          return Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.mail_outline, size: 22),
                tooltip: l10n.invitations,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PendingInvitationsPage(),
                    ),
                  );
                },
              ),
              if (pendingCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      pendingCount > 9 ? '9+' : '$pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
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
      // Profile icon
      if (showProfileAction)
        IconButton(
          icon: const Icon(Icons.person_outline, size: 22),
          tooltip: l10n.profile,
          onPressed: () => _navigateToProfile(context),
        ),
      // Logout icon
      IconButton(
        icon: const Icon(Icons.logout, size: 22),
        tooltip: l10n.signOut,
        onPressed: () => _showSignOutDialog(context),
      ),
    ];
  }

  static void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => Scaffold(
          appBar: PlayWithMeAppBar.build(
            context: routeContext,
            title: AppLocalizations.of(routeContext)!.profile,
            showProfileAction: false,
          ),
          body: const ProfilePage(),
        ),
      ),
    );
  }

  static void _showSignOutDialog(BuildContext context) {
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
              context
                  .read<AuthenticationBloc>()
                  .add(const AuthenticationLogoutRequested());
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}

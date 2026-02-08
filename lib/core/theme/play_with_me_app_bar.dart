// Shared AppBar builder for consistent header styling across all pages.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class PlayWithMeAppBar {
  PlayWithMeAppBar._();

  /// Builds the standard AppBar with volleyball icon, title, and optional actions.
  ///
  /// [showUserActions] adds profile and logout icons (set false for auth pages).
  /// [extraActions] are placed before the profile/logout icons.
  static AppBar build({
    required BuildContext context,
    required String title,
    List<Widget>? extraActions,
    bool showUserActions = true,
  }) {
    final l10n = AppLocalizations.of(context)!;
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
        if (extraActions != null) ...extraActions,
        if (showUserActions) ...[
          IconButton(
            icon: const Icon(Icons.person_outline, size: 22),
            tooltip: l10n.profile,
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            tooltip: l10n.signOut,
            onPressed: () {
              context.read<AuthenticationBloc>().add(
                    const AuthenticationLogoutRequested(),
                  );
            },
          ),
        ],
      ],
    );
  }
}

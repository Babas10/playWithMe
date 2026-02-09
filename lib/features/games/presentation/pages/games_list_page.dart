// Displays the group activity feed with games and training sessions.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/group_activity_item.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_bloc.dart';
import 'package:play_with_me/features/games/presentation/pages/game_creation_page.dart';
import 'package:play_with_me/features/games/presentation/pages/game_details_page.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_list_item.dart';
import 'package:play_with_me/features/games/presentation/widgets/training_session_list_item.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_creation_page.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_details_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class GamesListPage extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GamesListPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthenticationBloc>().state;
        final userId = authState is AuthenticationAuthenticated
            ? authState.user.uid
            : '';

        return sl<GamesListBloc>()
          ..add(LoadGamesForGroup(groupId: groupId, userId: userId));
      },
      child: _GamesListPageContent(
        groupId: groupId,
        groupName: groupName,
      ),
    );
  }
}

class _GamesListPageContent extends StatelessWidget {
  final String groupId;
  final String groupName;

  const _GamesListPageContent({
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: 'Activities',
      ),
      body: BlocBuilder<GamesListBloc, GamesListState>(
        builder: (context, state) {
          if (state is GamesListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is GamesListError) {
            return _buildErrorState(context, state.message);
          }

          if (state is GamesListEmpty) {
            return _buildEmptyState(context);
          }

          if (state is GamesListLoaded) {
            return _buildLoadedState(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildLoadedState(BuildContext context, GamesListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GamesListBloc>().add(const RefreshGamesList());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.upcomingActivities.isNotEmpty) ...[
              _buildSectionHeader(context, 'Upcoming Activities'),
              ...state.upcomingActivities.map((activity) =>
                  _buildActivityItem(context, activity, state.userId, false)),
            ],
            if (state.pastActivities.isNotEmpty) ...[
              _buildSectionHeader(context, 'Past Activities'),
              ...state.pastActivities.map((activity) =>
                  _buildActivityItem(context, activity, state.userId, true)),
            ],
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    GroupActivityItem activity,
    String userId,
    bool isPast,
  ) {
    return activity.when(
      game: (game) => GameListItem(
        game: game,
        userId: userId,
        isPast: isPast,
        onTap: () => _navigateToGameDetails(context, game.id),
      ),
      training: (session) => TrainingSessionListItem(
        session: session,
        userId: userId,
        isPast: isPast,
        onTap: () => _navigateToTrainingDetails(context, session.id),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.read<GamesListBloc>().add(const RefreshGamesList());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_volleyball,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noActivitiesYet,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstActivity,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreateMenu(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                icon: Icons.add_circle,
                label: l10n.create,
                onTap: () => _showCreateMenu(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.navLabelColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.sports_volleyball, color: AppColors.secondary),
                  title: Text(
                    l10n.createGame,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    l10n.competitiveGameWithElo,
                    style: TextStyle(color: AppColors.secondary.withValues(alpha: 0.7)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToGameCreation(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.fitness_center, color: AppColors.secondary),
                  title: Text(
                    l10n.createTrainingSession,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    l10n.practiceSessionNoElo,
                    style: TextStyle(color: AppColors.secondary.withValues(alpha: 0.7)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToTrainingCreation(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToGameCreation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<GameCreationBloc>(),
          child: GameCreationPage(
            groupId: groupId,
            groupName: groupName,
          ),
        ),
      ),
    );
  }

  void _navigateToTrainingCreation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<TrainingSessionCreationBloc>(),
          child: TrainingSessionCreationPage(
            groupId: groupId,
            groupName: groupName,
          ),
        ),
      ),
    );
  }

  void _navigateToGameDetails(BuildContext context, String gameId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailsPage(gameId: gameId),
      ),
    );
  }

  void _navigateToTrainingDetails(BuildContext context, String sessionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingSessionDetailsPage(
          trainingSessionId: sessionId,
        ),
      ),
    );
  }
}
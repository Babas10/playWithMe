// Displays the group activity feed with games and training sessions.
import 'package:flutter/material.dart';
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
import 'package:play_with_me/features/training/presentation/pages/training_session_details_page.dart';

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
      appBar: AppBar(
        title: Text('$groupName Games'),
        centerTitle: true,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToGameCreation(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Game'),
      ),
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
              color: Theme.of(context).colorScheme.primary,
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
            'No upcoming games yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create the first game!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _navigateToGameCreation(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Game'),
          ),
        ],
      ),
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
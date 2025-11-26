// Displays a list of all games for a group with real-time updates.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_state.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_bloc.dart';
import 'package:play_with_me/features/games/presentation/pages/game_creation_page.dart';
import 'package:play_with_me/features/games/presentation/pages/game_details_page.dart';

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
            if (state.upcomingGames.isNotEmpty) ...[
              _buildSectionHeader(context, 'Upcoming Games'),
              ...state.upcomingGames.map((game) => _GameListItem(
                    game: game,
                    userId: state.userId,
                    onTap: () => _navigateToGameDetails(context, game.id),
                  )),
            ],
            if (state.pastGames.isNotEmpty) ...[
              _buildSectionHeader(context, 'Past Games'),
              ...state.pastGames.map((game) => _GameListItem(
                    game: game,
                    userId: state.userId,
                    isPast: true,
                    onTap: () => _navigateToGameDetails(context, game.id),
                  )),
            ],
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
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
}

class _GameListItem extends StatelessWidget {
  final GameModel game;
  final String userId;
  final bool isPast;
  final VoidCallback onTap;

  const _GameListItem({
    required this.game,
    required this.userId,
    this.isPast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isPast ? 0 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      game.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPast
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : null,
                          ),
                    ),
                  ),
                  _buildRsvpStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                Icons.calendar_today,
                _formatDateTime(game.scheduledAt),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.location_on,
                game.location.name,
              ),
              const SizedBox(height: 12),
              _buildPlayerCountBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isPast
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isPast
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : null,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildRsvpStatusBadge(BuildContext context) {
    final isPlayer = game.isPlayer(userId);
    final isOnWaitlist = game.isOnWaitlist(userId);

    if (isPlayer) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              "You're In",
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (isOnWaitlist) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              'On Waitlist',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (game.isFull && !game.allowWaitlist) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 16, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              'Full',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_add,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Join Game',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCountBar(BuildContext context) {
    final progress = game.currentPlayerCount / game.maxPlayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${game.currentPlayerCount}/${game.maxPlayers} players',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isPast
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (game.waitlistCount > 0)
              Text(
                '${game.waitlistCount} waitlisted',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: isPast
                ? Theme.of(context).colorScheme.surfaceVariant
                : Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              isPast
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : game.currentPlayerCount >= game.minPlayers
                      ? Colors.green
                      : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final gameDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayString;
    if (gameDate == today) {
      dayString = 'Today';
    } else if (gameDate == tomorrow) {
      dayString = 'Tomorrow';
    } else {
      dayString = DateFormat('EEE, MMM d').format(dateTime);
    }

    final timeString = DateFormat('h:mm a').format(dateTime);
    return '$dayString • $timeString';
  }
}

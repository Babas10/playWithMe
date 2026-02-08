// Game details page displaying game information and allowing RSVP actions.

import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import '../../../../core/domain/repositories/game_repository.dart';
import '../../../../core/domain/repositories/user_repository.dart';
import '../../../../core/data/models/game_model.dart';
import '../../../../core/data/models/user_model.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/presentation/bloc/authentication/authentication_bloc.dart';
import '../../../auth/presentation/bloc/authentication/authentication_state.dart';
import '../bloc/game_details/game_details_bloc.dart';
import '../bloc/game_details/game_details_event.dart';
import '../bloc/game_details/game_details_state.dart';
import 'record_results_page.dart';
import 'game_result_view_page.dart';

class GameDetailsPage extends StatelessWidget {
  final String gameId;
  final GameRepository? gameRepository;
  final UserRepository? userRepository;

  const GameDetailsPage({
    super.key,
    required this.gameId,
    this.gameRepository,
    this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameDetailsBloc(
        gameRepository: gameRepository ?? sl<GameRepository>(),
        userRepository: userRepository ?? sl<UserRepository>(),
      )..add(LoadGameDetails(gameId: gameId)),
      child: const _GameDetailsView(),
    );
  }
}

class _GameDetailsView extends StatelessWidget {
  const _GameDetailsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: l10n.gameDetails,
      ),
      body: BlocBuilder<GameDetailsBloc, GameDetailsState>(
        builder: (context, state) => _buildBody(context, state, l10n),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GameDetailsState state, AppLocalizations l10n) {
    if (state is GameDetailsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is GameDetailsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                l10n.error(state.message),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (state.isRetryable) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.goBack),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (state is GameDetailsNotFound) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.gameNotFound,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      );
    }

    if (state is GameDetailsLoaded || state is GameDetailsOperationInProgress) {
      final game = state is GameDetailsLoaded
          ? state.game
          : (state as GameDetailsOperationInProgress).game;

      final players = state is GameDetailsLoaded
          ? state.players
          : (state as GameDetailsOperationInProgress).players;

      final playerEloUpdates = state is GameDetailsLoaded
          ? state.playerEloUpdates
          : (state as GameDetailsOperationInProgress).playerEloUpdates;

      final isOperationInProgress = state is GameDetailsOperationInProgress;

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GameInfoCard(game: game),
                  const SizedBox(height: 16),
                  // Verification Section
                  if (game.status == GameStatus.verification) ...[
                    _VerificationSection(
                      game: game,
                      isOperationInProgress: isOperationInProgress,
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Show results card if game has results
                  if (game.result != null) ...[
                    _ViewResultsCard(
                      game: game,
                      players: players,
                      playerEloUpdates: playerEloUpdates,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _PlayersCard(game: game),
                ],
              ),
            ),
          ),
          _RsvpButtons(
            game: game,
            isOperationInProgress: isOperationInProgress,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _GameInfoCard extends StatelessWidget {
  final GameModel game;

  const _GameInfoCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              game.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
            ),
            if (game.description != null) ...[
              const SizedBox(height: 8),
              Text(
                game.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: dateFormat.format(game.scheduledAt),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.access_time,
              label: 'Time',
              value: timeFormat.format(game.scheduledAt),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.people,
              label: 'Players',
              value:
                  '${game.currentPlayerCount}/${game.maxPlayers} (min: ${game.minPlayers})',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.location_on,
              label: 'Location',
              value: game.location.name,
            ),
            if (game.location.address != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  game.location.address!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
            if (game.notes != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                game.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _PlayersCard extends StatelessWidget {
  final GameModel game;

  const _PlayersCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthenticationBloc>().state;
    final currentUserId = authState is AuthenticationAuthenticated
        ? authState.user.uid
        : null;

    return BlocBuilder<GameDetailsBloc, GameDetailsState>(
      builder: (context, state) {
        final players = (state is GameDetailsLoaded)
            ? state.players
            : (state is GameDetailsOperationInProgress)
                ? state.players
                : <String, dynamic>{};
        final isOperationInProgress = state is GameDetailsOperationInProgress;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Confirmed Players',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                    ),
                    Chip(
                      label: Text(
                        '${game.currentPlayerCount}/${game.maxPlayers}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (game.playerIds.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'No players yet. Be the first to join!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: game.playerIds.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final playerId = game.playerIds[index];
                      final isCreator = playerId == game.createdBy;
                      final isCurrentUser = playerId == currentUserId;
                      final player = players[playerId];

                      // Get display name with fallback
                      final displayName = player?.displayName ?? player?.email ?? 'Player';

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: player != null && player.displayName != null
                            ? Text(player.email)
                            : null,
                        trailing: _buildPlayerTrailing(
                          context,
                          l10n,
                          isCreator: isCreator,
                          isCurrentUser: isCurrentUser,
                          isOperationInProgress: isOperationInProgress,
                          playerId: playerId,
                        ),
                      );
                    },
                  ),
                if (game.waitlistIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Waitlist (${game.waitlistIds.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...game.waitlistIds.asMap().entries.map((entry) {
                    final playerId = entry.value;
                    final isCurrentUser = playerId == currentUserId;
                    final player = players[playerId];
                    final displayName = player?.displayName ?? player?.email ?? 'Player';

                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.surface.withOpacity(0.5),
                        child: Text('${entry.key + 1}'),
                      ),
                      title: Text(displayName),
                      subtitle: player != null && player.displayName != null
                          ? Text(player.email)
                          : null,
                      trailing: isCurrentUser && game.status == GameStatus.scheduled
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'leave') {
                                  context.read<GameDetailsBloc>().add(
                                        LeaveGameDetails(
                                          gameId: game.id,
                                          userId: playerId,
                                        ),
                                      );
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'leave',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.exit_to_app,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.leaveWaitlist,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : null,
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildPlayerTrailing(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isCreator,
    required bool isCurrentUser,
    required bool isOperationInProgress,
    required String playerId,
  }) {
    // If user is the organizer, show the organizer badge and optionally the menu
    if (isCreator) {
      if (isCurrentUser && game.status == GameStatus.scheduled) {
        // Organizer who is also current user - show both badge and menu
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: Text(
                l10n.organizer,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'leave') {
                  context.read<GameDetailsBloc>().add(
                        LeaveGameDetails(
                          gameId: game.id,
                          userId: playerId,
                        ),
                      );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.leaveGame,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }
      // Just organizer badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: Text(
          l10n.organizer,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );
    }

    // Current user (not organizer) - show menu to leave
    if (isCurrentUser && game.status == GameStatus.scheduled) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          if (value == 'leave') {
            context.read<GameDetailsBloc>().add(
                  LeaveGameDetails(
                    gameId: game.id,
                    userId: playerId,
                  ),
                );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'leave',
            child: Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.leaveGame,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return null;
  }
}

class _RsvpButtons extends StatelessWidget {
  final GameModel game;
  final bool isOperationInProgress;

  const _RsvpButtons({
    required this.game,
    required this.isOperationInProgress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<GameDetailsBloc, GameDetailsState>(
      listener: (context, state) {
        if (state is GameCompletedSuccessfully) {
          // Navigate to Record Results screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RecordResultsPage(gameId: state.game.id),
            ),
          );
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          if (authState is! AuthenticationAuthenticated) {
            return const SizedBox.shrink();
          }

          final userId = authState.user.uid;
          final isPlaying = game.isPlayer(userId);
          final isOnWaitlist = game.isOnWaitlist(userId);
          final canJoin = game.canUserJoin(userId);
          final canEnterResults = game.canUserEnterResults(userId);

          // Show Enter Results icon if user can enter results
          if (canEnterResults) {
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
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecordResultsPage(gameId: game.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.scoreboard,
                                color: AppColors.secondary,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.enterResults,
                                style: TextStyle(
                                  color: AppColors.navLabelColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Don't show bottom bar if user is already playing or on waitlist
          // (they can leave via the 3-dot menu in the player list)
          if (isPlaying || isOnWaitlist) {
            return const SizedBox.shrink();
          }

          // Only show join button if user can join
          if (!canJoin || game.status != GameStatus.scheduled) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(16.0),
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isOperationInProgress
                      ? null
                      : () {
                          context.read<GameDetailsBloc>().add(
                                JoinGameDetails(
                                  gameId: game.id,
                                  userId: userId,
                                ),
                              );
                        },
                  icon: isOperationInProgress
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_circle_outline),
                  label: Text(game.isFull ? 'Join Waitlist' : 'I\'m In'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ViewResultsCard extends StatelessWidget {
  final GameModel game;
  final Map<String, UserModel> players;
  final Map<String, RatingHistoryEntry?> playerEloUpdates;

  const _ViewResultsCard({
    required this.game,
    required this.players,
    this.playerEloUpdates = const {},
  });

  /// Generate team name from player IDs (e.g., "Alice & Bob" or "Team A")
  String _getTeamName(List<String> playerIds, String fallbackName) {
    if (players.isEmpty || playerIds.isEmpty) {
      return fallbackName;
    }

    // Get up to 2 player names
    final names = playerIds
        .take(2)
        .map((id) {
          final player = players[id];
          if (player == null) return null;
          return player.displayName ?? player.email.split('@').first;
        })
        .where((name) => name != null)
        .toList();

    if (names.isEmpty) return fallbackName;
    if (names.length == 1) return names[0]!;
    return '${names[0]} & ${names[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final result = game.result!;
    final gamesWon = result.gamesWon;

    // Generate team names
    final teams = game.teams;
    final teamAName = teams != null
        ? _getTeamName(teams.teamAPlayerIds, 'Team A')
        : 'Team A';
    final teamBName = teams != null
        ? _getTeamName(teams.teamBPlayerIds, 'Team B')
        : 'Team B';

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameResultViewPage(
                game: game,
                players: players,
                playerEloUpdates: playerEloUpdates,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Game Results',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondary),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickScoreDisplay(
                    teamName: teamAName,
                    score: gamesWon['teamA'] ?? 0,
                    isWinner: result.overallWinner == 'teamA',
                  ),
                  Text(
                    'vs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.secondary,
                        ),
                  ),
                  _QuickScoreDisplay(
                    teamName: teamBName,
                    score: gamesWon['teamB'] ?? 0,
                    isWinner: result.overallWinner == 'teamB',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Tap to view detailed results',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickScoreDisplay extends StatelessWidget {
  final String teamName;
  final int score;
  final bool isWinner;

  const _QuickScoreDisplay({
    required this.teamName,
    required this.score,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    // Winner: blue background with white text
    // Loser: yellow background with blue text
    final backgroundColor = isWinner
        ? AppColors.secondary
        : AppColors.primary;
    final textColor = isWinner
        ? Colors.white
        : AppColors.secondary;
    final borderColor = isWinner
        ? AppColors.secondary
        : AppColors.primary;

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: isWinner ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          teamName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                color: AppColors.secondary,
              ),
        ),
      ],
    );
  }
}

class _VerificationSection extends StatelessWidget {
  final GameModel game;
  final bool isOperationInProgress;

  const _VerificationSection({
    required this.game,
    required this.isOperationInProgress,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState is! AuthenticationAuthenticated) {
          return const SizedBox.shrink();
        }

        final userId = authState.user.uid;
        final isSubmitter = game.resultSubmittedBy == userId;
        final hasConfirmed = game.confirmedBy.contains(userId);
        final isParticipant = game.isPlayer(userId);

        if (!isParticipant) return const SizedBox.shrink();

        Color bannerColor = Colors.orange;
        String title = 'Result Verification Pending';
        String message = 'Please verify the game results.';
        IconData icon = Icons.warning_amber_rounded;

        if (isSubmitter) {
          bannerColor = AppColors.secondary;
          title = 'Result Submitted';
          message = 'Waiting for other players to confirm.';
          icon = Icons.info_outline;
        } else if (hasConfirmed) {
          bannerColor = Colors.green;
          title = 'Confirmed';
          message = 'You have confirmed this result.';
          icon = Icons.check_circle_outline;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bannerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bannerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: bannerColor),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bannerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (!isSubmitter && !hasConfirmed)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isOperationInProgress
                            ? null
                            : () {
                                context.read<GameDetailsBloc>().add(
                                      ConfirmGameResult(
                                        gameId: game.id,
                                        userId: userId,
                                      ),
                                    );
                              },
                        icon: const Icon(Icons.check),
                        label: const Text('Confirm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (!isSubmitter && !hasConfirmed) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isOperationInProgress
                          ? null
                          : () {
                              // Navigate to RecordResultsPage to edit
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecordResultsPage(gameId: game.id),
                                ),
                              );
                            },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit / Dispute'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
// Game details page displaying game information and allowing RSVP actions.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        elevation: 0,
      ),
      body: BlocBuilder<GameDetailsBloc, GameDetailsState>(
        builder: (context, state) {
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
                      'Error',
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
                        child: const Text('Go Back'),
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
                      'Game Not Found',
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
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is GameDetailsLoaded ||
              state is GameDetailsOperationInProgress) {
            final game = state is GameDetailsLoaded
                ? state.game
                : (state as GameDetailsOperationInProgress).game;

            final players = state is GameDetailsLoaded
                ? state.players
                : (state as GameDetailsOperationInProgress).players;

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
                          ),
                          const SizedBox(height: 16),
                        ],
                        _LocationCard(location: game.location),
                        const SizedBox(height: 16),
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
        },
      ),
    );
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
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
          color: Theme.of(context).colorScheme.primary,
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

class _LocationCard extends StatelessWidget {
  final GameLocation location;

  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              location.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (location.address != null) ...[
              const SizedBox(height: 4),
              Text(
                location.address!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (location.description != null) ...[
              const SizedBox(height: 8),
              Text(
                location.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlayersCard extends StatelessWidget {
  final GameModel game;

  const _PlayersCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameDetailsBloc, GameDetailsState>(
      builder: (context, state) {
        final players = (state is GameDetailsLoaded)
            ? state.players
            : (state is GameDetailsOperationInProgress)
                ? state.players
                : <String, dynamic>{};

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
                          ),
                    ),
                    Chip(
                      label: Text(
                        '${game.currentPlayerCount}/${game.maxPlayers}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: game.isFull
                          ? Theme.of(context).colorScheme.error.withOpacity(0.2)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
                        trailing: isCreator
                            ? Chip(
                                label: const Text('Organizer'),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.2),
                              )
                            : null,
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
          final isCreator = game.isCreator(userId);
          
          final canMarkCompleted = isCreator &&
              (game.status == GameStatus.scheduled ||
                  game.status == GameStatus.inProgress);

          // Democratized Result Entry Logic (Story 14.14)
          final canEnterResults = game.canUserEnterResults(userId);

          return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enter Results button (for participants when ready)
                if (canEnterResults) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isOperationInProgress
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecordResultsPage(gameId: game.id),
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
                            : const Icon(Icons.scoreboard),
                        label: const Text('Enter Results'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                // RSVP buttons
                if (game.status == GameStatus.scheduled)
                  Row(
                    children: [
                      if (isPlaying || isOnWaitlist) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isOperationInProgress
                              ? null
                              : () {
                                  context.read<GameDetailsBloc>().add(
                                        LeaveGameDetails(
                                          gameId: game.id,
                                          userId: userId,
                                        ),
                                      );
                                },
                          icon: isOperationInProgress
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.remove_circle_outline),
                          label:
                              Text(isOnWaitlist ? 'Leave Waitlist' : 'I\'m Out'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ]
                    else if (canJoin) ...[
                      Expanded(
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
                    ]
                    else ...[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: Text(
                            game.isPast
                                ? 'Game has ended'
                                : 'Game is full and waitlist is disabled',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
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

  const _ViewResultsCard({
    required this.game,
    required this.players,
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
    final winnerColor = result.overallWinner == 'teamA' ? Colors.blue : Colors.red;

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
                    color: winnerColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Game Results',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16),
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
                    color: Colors.blue,
                  ),
                  Text(
                    'vs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  _QuickScoreDisplay(
                    teamName: teamBName,
                    score: gamesWon['teamB'] ?? 0,
                    isWinner: result.overallWinner == 'teamB',
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Tap to view detailed results',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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
  final Color color;

  const _QuickScoreDisplay({
    required this.teamName,
    required this.score,
    required this.isWinner,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isWinner ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: isWinner ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.white : color,
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
                color: isWinner ? Colors.black87 : Colors.grey.shade600,
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
          bannerColor = Colors.blue;
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
                    child: OutlinedButton.icon(
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
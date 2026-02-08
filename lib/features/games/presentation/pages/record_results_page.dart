import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

import '../../../../core/data/models/user_model.dart';
import '../../../../core/domain/repositories/game_repository.dart';
import '../../../../core/domain/repositories/user_repository.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/presentation/bloc/authentication/authentication_bloc.dart';
import '../../../auth/presentation/bloc/authentication/authentication_state.dart';
import '../bloc/record_results/record_results_bloc.dart';
import '../bloc/record_results/record_results_event.dart';
import '../bloc/record_results/record_results_state.dart';
import 'score_entry_page.dart';

class RecordResultsPage extends StatelessWidget {
  final String gameId;
  final RecordResultsBloc? recordResultsBloc;

  const RecordResultsPage({
    super.key,
    required this.gameId,
    this.recordResultsBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          recordResultsBloc ??
          RecordResultsBloc(
            gameRepository: sl<GameRepository>(),
            userRepository: sl<UserRepository>(),
          )..add(LoadGameForResults(gameId: gameId)),
      child: const _RecordResultsView(),
    );
  }
}

class _RecordResultsView extends StatelessWidget {
  const _RecordResultsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: AppLocalizations.of(context)!.recordResults,
      ),
      body: BlocConsumer<RecordResultsBloc, RecordResultsState>(
        listener: (context, state) {
          if (state is RecordResultsSaved) {
            // Navigate to score entry page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ScoreEntryPage(gameId: state.game.id),
              ),
            );
          } else if (state is RecordResultsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RecordResultsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecordResultsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is RecordResultsLoaded || state is RecordResultsSaving) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.assignPlayersToTeams,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.dragPlayersToAssign,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        if (state is RecordResultsLoaded) ...[
                          _TeamSection(
                            key: const Key('team_a_section'),
                            title: AppLocalizations.of(context)!.teamA,
                            playerIds: state.teamAPlayerIds,
                            players: state.players,
                            color: AppColors.primary,
                            onRemove: (playerId) {
                              context.read<RecordResultsBloc>().add(
                                    RemovePlayerFromTeam(playerId: playerId),
                                  );
                            },
                          ),
                          const SizedBox(height: 16),
                          _TeamSection(
                            key: const Key('team_b_section'),
                            title: AppLocalizations.of(context)!.teamB,
                            playerIds: state.teamBPlayerIds,
                            players: state.players,
                            color: AppColors.secondary,
                            onRemove: (playerId) {
                              context.read<RecordResultsBloc>().add(
                                    RemovePlayerFromTeam(playerId: playerId),
                                  );
                            },
                          ),
                          const SizedBox(height: 16),
                          _UnassignedPlayersSection(
                            key: const Key('unassigned_section'),
                            unassignedPlayerIds: state.unassignedPlayerIds,
                            players: state.players,
                            onAssignToTeamA: (playerId) {
                              context.read<RecordResultsBloc>().add(
                                    AssignPlayerToTeamA(playerId: playerId),
                                  );
                            },
                            onAssignToTeamB: (playerId) {
                              context.read<RecordResultsBloc>().add(
                                    AssignPlayerToTeamB(playerId: playerId),
                                  );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state is RecordResultsLoaded)
                  _SaveButton(
                    canSave: state.canSave,
                    onSave: () {
                      final authState = context.read<AuthenticationBloc>().state;
                      if (authState is AuthenticationAuthenticated) {
                        context.read<RecordResultsBloc>().add(
                              SaveTeams(userId: authState.user.uid),
                            );
                      }
                    },
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

class _TeamSection extends StatelessWidget {
  final String title;
  final List<String> playerIds;
  final Map<String, UserModel> players;
  final Color color;
  final Function(String) onRemove;

  const _TeamSection({
    super.key,
    required this.title,
    required this.playerIds,
    required this.players,
    required this.color,
    required this.onRemove,
  });

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
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                ),
                const Spacer(),
                Text(
                  playerIds.length == 1
                      ? AppLocalizations.of(context)!.playerCountSingular
                      : AppLocalizations.of(context)!.playerCountPlural(playerIds.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (playerIds.isEmpty)
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context)!.noPlayersAssigned,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              )
            else
              ...playerIds.map((playerId) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _PlayerChip(
                      playerId: playerId,
                      players: players,
                      color: color,
                      onRemove: () => onRemove(playerId),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _UnassignedPlayersSection extends StatelessWidget {
  final List<String> unassignedPlayerIds;
  final Map<String, UserModel> players;
  final Function(String) onAssignToTeamA;
  final Function(String) onAssignToTeamB;

  const _UnassignedPlayersSection({
    super.key,
    required this.unassignedPlayerIds,
    required this.players,
    required this.onAssignToTeamA,
    required this.onAssignToTeamB,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.unassignedPlayers,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
            ),
            const SizedBox(height: 12),
            if (unassignedPlayerIds.isEmpty)
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.allPlayersAssigned,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              )
            else
              ...unassignedPlayerIds.map((playerId) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _UnassignedPlayerItem(
                      playerId: playerId,
                      players: players,
                      onAssignToTeamA: () => onAssignToTeamA(playerId),
                      onAssignToTeamB: () => onAssignToTeamB(playerId),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final String playerId;
  final Map<String, UserModel> players;
  final Color color;
  final VoidCallback onRemove;

  const _PlayerChip({
    required this.playerId,
    required this.players,
    required this.color,
    required this.onRemove,
  });

  String _getPlayerName() {
    final player = players[playerId];
    if (player == null) return playerId;
    return player.displayName ?? player.email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final playerName = _getPlayerName();

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.25),
            child: Text(
              playerName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              playerName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onRemove,
            tooltip: AppLocalizations.of(context)!.removeFromTeam,
          ),
        ],
      ),
    );
  }
}

class _UnassignedPlayerItem extends StatelessWidget {
  final String playerId;
  final Map<String, UserModel> players;
  final VoidCallback onAssignToTeamA;
  final VoidCallback onAssignToTeamB;

  const _UnassignedPlayerItem({
    required this.playerId,
    required this.players,
    required this.onAssignToTeamA,
    required this.onAssignToTeamB,
  });

  String _getPlayerName() {
    final player = players[playerId];
    if (player == null) return playerId;
    return player.displayName ?? player.email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final playerName = _getPlayerName();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.25),
            child: Text(
              playerName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              playerName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                key: Key('assign_team_A_button_$playerId'),
                onPressed: onAssignToTeamA,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.secondary,
                  minimumSize: const Size(60, 36),
                ),
                child: Text(AppLocalizations.of(context)!.teamA),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                key: Key('assign_team_B_button_$playerId'),
                onPressed: onAssignToTeamB,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 36),
                ),
                child: Text(AppLocalizations.of(context)!.teamB),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool canSave;
  final VoidCallback onSave;

  const _SaveButton({
    required this.canSave,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
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
          child: ElevatedButton(
            onPressed: canSave ? onSave : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text(
              canSave
                  ? AppLocalizations.of(context)!.saveTeams
                  : AppLocalizations.of(context)!.assignAllPlayersToContinue,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

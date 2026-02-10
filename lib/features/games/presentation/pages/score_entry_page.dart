import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

import '../../../../core/domain/repositories/game_repository.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/presentation/bloc/authentication/authentication_bloc.dart';
import '../../../auth/presentation/bloc/authentication/authentication_state.dart';
import '../bloc/score_entry/score_entry_bloc.dart';
import '../bloc/score_entry/score_entry_event.dart';
import '../bloc/score_entry/score_entry_state.dart';

class ScoreEntryPage extends StatelessWidget {
  final String gameId;
  final ScoreEntryBloc? scoreEntryBloc;

  const ScoreEntryPage({
    super.key,
    required this.gameId,
    this.scoreEntryBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          scoreEntryBloc ??
          ScoreEntryBloc(
            gameRepository: sl<GameRepository>(),
          )..add(LoadGameForScoreEntry(gameId: gameId)),
      child: const _ScoreEntryView(),
    );
  }
}

class _ScoreEntryView extends StatelessWidget {
  const _ScoreEntryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: l10n.enterScores,
      ),
      body: BlocConsumer<ScoreEntryBloc, ScoreEntryState>(
        listener: (context, state) {
          if (state is ScoreEntrySaved) {
            Navigator.of(context).pop();
          } else if (state is ScoreEntryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ScoreEntryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScoreEntryError) {
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

          if (state is ScoreEntryLoaded) {
            if (state.gameCount == null) {
              return _GameCountSelector(
                onGameCountSelected: (count) {
                  context.read<ScoreEntryBloc>().add(SetGameCount(count: count));
                },
              );
            }

            return _ScoreEntryForm(state: state);
          }

          if (state is ScoreEntrySaving) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.savingScores),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _GameCountSelector extends StatelessWidget {
  final Function(int) onGameCountSelected;

  const _GameCountSelector({required this.onGameCountSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.howManyGamesPlayed,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: List.generate(10, (index) {
              final count = index + 1;
              return SizedBox(
                width: 70,
                height: 70,
                child: ElevatedButton(
                  onPressed: () => onGameCountSelected(count),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ScoreEntryForm extends StatelessWidget {
  final ScoreEntryLoaded state;

  const _ScoreEntryForm({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.games.length,
            itemBuilder: (context, index) {
              return _GameCard(
                gameIndex: index,
                gameData: state.games[index],
                totalGames: state.games.length,
              );
            },
          ),
        ),
        _SaveButton(
          canSave: state.canSave,
          overallWinner: state.overallWinner,
          isTied: state.isTied,
          gamesWon: state.games.where((g) => g.isComplete).length,
          totalGames: state.games.length,
          onSave: () {
            final authState = context.read<AuthenticationBloc>().state;
            if (authState is AuthenticationAuthenticated) {
              context.read<ScoreEntryBloc>().add(
                    SaveScores(userId: authState.user.uid),
                  );
            }
          },
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final int gameIndex;
  final GameData gameData;
  final int totalGames;

  const _GameCard({
    required this.gameIndex,
    required this.gameData,
    required this.totalGames,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Game ${gameIndex + 1}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                ),
                if (gameData.isComplete)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _GameFormatSelector(
              gameIndex: gameIndex,
              currentFormat: gameData.numberOfSets,
            ),
            const SizedBox(height: 16),
            ...List.generate(gameData.numberOfSets, (setIndex) {
              return _SetScoreInput(
                key: ValueKey('game_${gameIndex}_set_$setIndex'),
                gameIndex: gameIndex,
                setIndex: setIndex,
                setData: setIndex < gameData.sets.length
                    ? gameData.sets[setIndex]
                    : const SetScoreData(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _GameFormatSelector extends StatelessWidget {
  final int gameIndex;
  final int currentFormat;

  const _GameFormatSelector({
    required this.gameIndex,
    required this.currentFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Format:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('1 Set')),
              ButtonSegment(value: 2, label: Text('Best of 2')),
              ButtonSegment(value: 3, label: Text('Best of 3')),
            ],
            selected: {currentFormat},
            onSelectionChanged: (selected) {
              context.read<ScoreEntryBloc>().add(
                    SetGameFormat(
                      gameIndex: gameIndex,
                      numberOfSets: selected.first,
                    ),
                  );
            },
          ),
        ),
      ],
    );
  }
}

class _SetScoreInput extends StatefulWidget {
  final int gameIndex;
  final int setIndex;
  final SetScoreData setData;

  const _SetScoreInput({
    super.key,
    required this.gameIndex,
    required this.setIndex,
    required this.setData,
  });

  @override
  State<_SetScoreInput> createState() => _SetScoreInputState();
}

class _SetScoreInputState extends State<_SetScoreInput> {
  late final TextEditingController _teamAController;
  late final TextEditingController _teamBController;
  final FocusNode _teamAFocusNode = FocusNode();
  final FocusNode _teamBFocusNode = FocusNode();
  bool _teamAFocused = false;
  bool _teamBFocused = false;

  @override
  void initState() {
    super.initState();
    _teamAController = TextEditingController(
      text: widget.setData.teamAPoints?.toString() ?? '',
    );
    _teamBController = TextEditingController(
      text: widget.setData.teamBPoints?.toString() ?? '',
    );
    _teamAFocusNode.addListener(_onTeamAFocusChange);
    _teamBFocusNode.addListener(_onTeamBFocusChange);
  }

  void _onTeamAFocusChange() {
    setState(() => _teamAFocused = _teamAFocusNode.hasFocus);
  }

  void _onTeamBFocusChange() {
    setState(() => _teamBFocused = _teamBFocusNode.hasFocus);
  }

  @override
  void didUpdateWidget(_SetScoreInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers only if the data actually changed from the previous widget
    // Don't update if the controller already has the correct value (user is typing)
    final newTeamAText = widget.setData.teamAPoints?.toString() ?? '';
    final newTeamBText = widget.setData.teamBPoints?.toString() ?? '';

    // Only update if the widget's data changed AND it differs from controller
    if (oldWidget.setData.teamAPoints != widget.setData.teamAPoints) {
      if (newTeamAText != _teamAController.text) {
        _teamAController.text = newTeamAText;
      }
    }

    if (oldWidget.setData.teamBPoints != widget.setData.teamBPoints) {
      if (newTeamBText != _teamBController.text) {
        _teamBController.text = newTeamBText;
      }
    }
  }

  @override
  void dispose() {
    _teamAFocusNode.removeListener(_onTeamAFocusChange);
    _teamBFocusNode.removeListener(_onTeamBFocusChange);
    _teamAController.dispose();
    _teamBController.dispose();
    _teamAFocusNode.dispose();
    _teamBFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              'Set ${widget.setIndex + 1}:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: Key('team_a_score_${widget.gameIndex}_${widget.setIndex}'),
                    focusNode: _teamAFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Team A',
                      floatingLabelStyle: TextStyle(
                        color: _teamAFocused ? AppColors.secondary : Colors.grey,
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _teamAController,
                    onChanged: (value) {
                      final teamAPoints = value.isEmpty ? null : int.tryParse(value);
                      final teamBPoints = _teamBController.text.isEmpty
                          ? null
                          : int.tryParse(_teamBController.text);
                      context.read<ScoreEntryBloc>().add(
                            UpdateSetScore(
                              gameIndex: widget.gameIndex,
                              setIndex: widget.setIndex,
                              teamAPoints: teamAPoints,
                              teamBPoints: teamBPoints,
                            ),
                          );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                const Text('-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    key: Key('team_b_score_${widget.gameIndex}_${widget.setIndex}'),
                    focusNode: _teamBFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Team B',
                      floatingLabelStyle: TextStyle(
                        color: _teamBFocused ? AppColors.secondary : Colors.grey,
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _teamBController,
                    onChanged: (value) {
                      final teamAPoints = _teamAController.text.isEmpty
                          ? null
                          : int.tryParse(_teamAController.text);
                      final teamBPoints = value.isEmpty ? null : int.tryParse(value);
                      context.read<ScoreEntryBloc>().add(
                            UpdateSetScore(
                              gameIndex: widget.gameIndex,
                              setIndex: widget.setIndex,
                              teamAPoints: teamAPoints,
                              teamBPoints: teamBPoints,
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 24,
            child: widget.setData.isValid
                ? Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.secondary,
                      size: 14,
                    ),
                  )
                : widget.setData.isComplete
                    ? Tooltip(
                        message: widget.setData.validationError ?? 'Invalid score',
                        triggerMode: TooltipTriggerMode.tap,
                        child: const Icon(Icons.error, color: Colors.red, size: 20),
                      )
                    : null,
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool canSave;
  final String? overallWinner;
  final bool isTied;
  final int gamesWon;
  final int totalGames;
  final VoidCallback onSave;

  const _SaveButton({
    required this.canSave,
    required this.overallWinner,
    required this.isTied,
    required this.gamesWon,
    required this.totalGames,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canSave)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  isTied
                      ? l10n.resultTie
                      : overallWinner == 'teamA'
                          ? l10n.overallWinnerTeamA
                          : l10n.overallWinnerTeamB,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                ),
              ),
            SizedBox(
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
                      ? l10n.saveScores
                      : l10n.completeGamesToContinue(gamesWon, totalGames),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for selecting per-game teams from the 3 possible 2v2 combinations (Story 14.11).
// Given exactly 4 player IDs, generates and displays all 3 possible team splits.

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Generates all 3 possible 2v2 team combinations for [playerIds].
/// Assumes [playerIds] has exactly 4 elements.
List<GameTeams> generateTeamCombinations(List<String> playerIds) {
  assert(playerIds.length == 4, 'Expected exactly 4 players');
  final a = playerIds[0];
  final b = playerIds[1];
  final c = playerIds[2];
  final d = playerIds[3];

  return [
    GameTeams(teamAPlayerIds: [a, b], teamBPlayerIds: [c, d]),
    GameTeams(teamAPlayerIds: [a, c], teamBPlayerIds: [b, d]),
    GameTeams(teamAPlayerIds: [a, d], teamBPlayerIds: [b, c]),
  ];
}

/// Returns the display name for a player.
String playerDisplayName(String playerId, Map<String, UserModel> players) {
  final user = players[playerId];
  if (user == null) return playerId;
  return user.displayName ?? user.email.split('@').first;
}

class GameTeamPickerWidget extends StatelessWidget {
  final List<String> playerIds;
  final Map<String, UserModel> players;
  final GameTeams? selectedTeams;
  final ValueChanged<GameTeams> onTeamsSelected;

  const GameTeamPickerWidget({
    super.key,
    required this.playerIds,
    required this.players,
    required this.selectedTeams,
    required this.onTeamsSelected,
  });

  bool _teamsMatch(GameTeams a, GameTeams b) {
    final aA = List<String>.from(a.teamAPlayerIds)..sort();
    final aB = List<String>.from(a.teamBPlayerIds)..sort();
    final bA = List<String>.from(b.teamAPlayerIds)..sort();
    final bB = List<String>.from(b.teamBPlayerIds)..sort();
    return (listEquals(aA, bA) && listEquals(aB, bB)) ||
        (listEquals(aA, bB) && listEquals(aB, bA));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (playerIds.length != 4) {
      // Fallback for non-standard player counts
      return Text(
        l10n.selectTeamsPrompt,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final combinations = generateTeamCombinations(playerIds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedTeams == null ? l10n.selectTeamsPrompt : l10n.teamsForThisGame,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selectedTeams == null ? Colors.grey.shade600 : AppColors.secondary,
                fontWeight: selectedTeams != null ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
        const SizedBox(height: 8),
        ...combinations.map((combo) {
          final isSelected = selectedTeams != null && _teamsMatch(combo, selectedTeams!);
          final teamANames = combo.teamAPlayerIds
              .map((id) => playerDisplayName(id, players))
              .join(' & ');
          final teamBNames = combo.teamBPlayerIds
              .map((id) => playerDisplayName(id, players))
              .join(' & ');

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => onTeamsSelected(combo),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.check_circle,
                          key: const Key('team_combo_selected_icon'),
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: teamANames,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                            TextSpan(
                              text: '  ${l10n.vsLabel}  ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: teamBNames,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
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
        }),
      ],
    );
  }
}

// Reusable badge indicating a mixed-gender game (Story 26.5).
import 'package:flutter/material.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MixGameBadge extends StatelessWidget {
  const MixGameBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple),
      ),
      child: Text(
        l10n.mixGameBadge,
        style: const TextStyle(
          color: Colors.purple,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

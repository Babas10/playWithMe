// Compact game list tile used in MyGamesPage (Story 28.11).
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/my_game_item.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

const _kTextMain = Color(0xFF1A2C32);
const _kTextMuted = Color(0xFF64748B);
const _kPrimary = Color(0xFFEACE6A);

class MyGameTile extends StatelessWidget {
  final MyGameItem item;
  final VoidCallback onTap;

  const MyGameTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _statusColor(_effectiveStatus(item.status, item.scheduledAt)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _kTextMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatDate(context, item.scheduledAt)}  ·  ${item.locationName}',
                      style: const TextStyle(fontSize: 13, color: _kTextMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.groupName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.groupName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kTextMuted,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              item.isGroupGame
                  ? _OpenBadge(l10n: l10n)
                  : _StatusBadge(status: _effectiveStatus(item.status, item.scheduledAt), l10n: l10n),
              const Icon(Icons.chevron_right, size: 18, color: _kTextMuted),
            ],
          ),
        ),
      ),
    );
  }

  /// Treats past-scheduled games as verification to prompt result entry.
  GameStatus _effectiveStatus(GameStatus status, DateTime scheduledAt) {
    if (status == GameStatus.scheduled &&
        scheduledAt.isBefore(DateTime.now())) {
      return GameStatus.verification;
    }
    return status;
  }

  Color _statusColor(GameStatus status) {
    switch (status) {
      case GameStatus.scheduled:
        return _kPrimary;
      case GameStatus.inProgress:
        return Colors.green;
      case GameStatus.verification:
        return Colors.orange;
      case GameStatus.completed:
        return Colors.grey;
      case GameStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final gameDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayString;
    if (gameDate == today) {
      dayString = l10n.today;
    } else if (gameDate == tomorrow) {
      dayString = l10n.tomorrow;
    } else {
      dayString = DateFormat('EEE, MMM d').format(dateTime);
    }
    return '$dayString ${DateFormat('h:mm a').format(dateTime)}';
  }
}

class _StatusBadge extends StatelessWidget {
  final GameStatus status;
  final AppLocalizations l10n;

  const _StatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      GameStatus.scheduled => (
          l10n.scheduled,
          Colors.blue.withValues(alpha: 0.1),
          Colors.blue.shade700,
        ),
      GameStatus.inProgress => (
          'Live',
          Colors.green.withValues(alpha: 0.1),
          Colors.green.shade700,
        ),
      GameStatus.verification => (
          l10n.verification,
          Colors.orange.withValues(alpha: 0.1),
          Colors.orange.shade700,
        ),
      GameStatus.completed => (
          l10n.completed,
          Colors.grey.withValues(alpha: 0.1),
          Colors.grey.shade600,
        ),
      GameStatus.cancelled => (
          l10n.cancelled,
          Colors.red.withValues(alpha: 0.1),
          Colors.red.shade700,
        ),
    };

    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

/// Badge shown on un-joined group games — invites the user to join.
class _OpenBadge extends StatelessWidget {
  final AppLocalizations l10n;
  const _OpenBadge({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.open,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.green.shade700,
        ),
      ),
    );
  }
}

// Card displaying the next upcoming training session on the homepage.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

// Golden Hour theme colors
const _kPrimary = Color(0xFFEACE6A);
const _kTextMain = Color(0xFF1A2C32);
const _kTextMuted = Color(0xFF64748B);
const _kShadow = Color(0x14004E64);
const _kDashedBorder = Color(0xFFE2E8F0);

/// A card widget that displays the user's next upcoming training session.
///
/// Shows key information:
/// - Title with participation badge
/// - Date/time, location, and duration
/// - Participant count progress bar
///
/// Filled state: white card with orange left accent bar
/// Empty state: dashed border container with centered icon
class NextTrainingSessionCard extends StatelessWidget {
  final TrainingSessionModel? session;
  final String userId;
  final VoidCallback? onTap;

  const NextTrainingSessionCard({
    super.key,
    required this.session,
    required this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (session != null) {
      return _buildFilledCard(context, l10n);
    }
    return _buildEmptyCard(context, l10n);
  }

  Widget _buildFilledCard(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: _kShadow,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Orange accent bar on the left
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 6,
                    color: _kPrimary,
                  ),
                ),
                // Card content
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(22, 20, 16, 20),
                  child: _buildSessionContent(context, l10n),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: SizedBox(
            height: 110,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 36,
                    color: _kTextMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.noTrainingSessionsScheduled,
                    style: TextStyle(
                      fontSize: 14,
                      color: _kTextMuted.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title + participation badge
        Row(
          children: [
            Expanded(
              child: Text(
                session!.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _kTextMain,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildParticipationBadge(context, l10n),
          ],
        ),
        const SizedBox(height: 12),
        // Date/time + Location + Duration
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: _kTextMuted,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _formatDateTime(context, session!.startTime),
                style: const TextStyle(
                  fontSize: 14,
                  color: _kTextMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.location_on,
              size: 14,
              color: _kTextMuted,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                session!.location.name,
                style: const TextStyle(
                  fontSize: 14,
                  color: _kTextMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.access_time,
              size: 14,
              color: _kTextMuted,
            ),
            const SizedBox(width: 2),
            Text(
              _formatDuration(context, session!.duration),
              style: const TextStyle(
                fontSize: 14,
                color: _kTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Participant count bar in gray container
        _buildParticipantBar(context, l10n),
      ],
    );
  }

  Widget _buildParticipationBadge(
      BuildContext context, AppLocalizations l10n) {
    final isParticipant = session!.isParticipant(userId);

    if (isParticipant) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _kPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          l10n.joined,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.join,
        style: const TextStyle(
          color: _kPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildParticipantBar(
      BuildContext context, AppLocalizations l10n) {
    final progress =
        session!.currentParticipantCount / session!.maxParticipants;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            l10n.participantsCount(
                session!.currentParticipantCount, session!.maxParticipants),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _kTextMain,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  session!.currentParticipantCount >= session!.minParticipants
                      ? _kPrimary
                      : _kPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayString;
    if (sessionDate == today) {
      dayString = l10n.today;
    } else if (sessionDate == tomorrow) {
      dayString = l10n.tomorrow;
    } else {
      dayString = DateFormat('EEE, MMM d').format(dateTime);
    }

    final timeString = DateFormat('h:mm a').format(dateTime);
    return '$dayString $timeString';
  }

  String _formatDuration(BuildContext context, Duration duration) {
    final l10n = AppLocalizations.of(context)!;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return l10n.durationFormat(hours, minutes);
    } else if (hours > 0) {
      return l10n.durationHours(hours);
    } else {
      return l10n.durationMinutes(minutes);
    }
  }
}

/// Paints a dashed rounded rectangle border for empty states.
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kDashedBorder
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + 8).clamp(0.0, metric.length);
        dashPath.addPath(
          metric.extractPath(distance, end),
          Offset.zero,
        );
        distance += 16;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Rivals card showing nemesis statistics.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/profile/presentation/pages/head_to_head_page.dart';

/// A card widget displaying rival/nemesis statistics.
///
/// Shows the opponent you lost to most often.
/// Tap opens HeadToHeadPage for full rivalry breakdown (Phase 3).
class RivalsCard extends StatelessWidget {
  final UserModel user;

  const RivalsCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => _loadTopRival(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '🆚 ',
                        style: const TextStyle(fontSize: 24),
                      ),
                      Text(
                        'Rival',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Coming soon state
              _buildComingSoonState(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.sports_kabaddi,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Rival Tracking Coming Soon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track your toughest opponents and head-to-head records',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadTopRival(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch top rival (most games played against)
      final userRepo = sl<UserRepository>();
      final h2hStats = await userRepo.getAllHeadToHeadStats(user.uid).first;

      if (!context.mounted) return;

      // Dismiss loading
      Navigator.of(context).pop();

      if (h2hStats.isEmpty) {
        // Show "no rivals yet" message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No rivalry data yet. Play more games!')),
        );
        return;
      }

      // Navigate to top rival
      final topRival = h2hStats.first;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HeadToHeadPage(
            userId: user.uid,
            opponentId: topRival.opponentId,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      // Dismiss loading if still showing
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rival: $e')),
      );
    }
  }
}

// Loading skeleton widgets for stat cards.
import 'package:flutter/material.dart';

/// A shimmer loading skeleton for stat cards.
///
/// Provides visual feedback while data is being loaded.
class StatsLoadingSkeleton extends StatefulWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const StatsLoadingSkeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  State<StatsLoadingSkeleton> createState() => _StatsLoadingSkeletonState();
}

class _StatsLoadingSkeletonState extends State<StatsLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 + _controller.value * 2, 0.0),
              colors: [
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A card with loading skeleton content.
class LoadingStatCard extends StatelessWidget {
  const LoadingStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            const StatsLoadingSkeleton(
              height: 24,
              width: 180,
            ),
            const SizedBox(height: 16),
            // Stats grid skeleton
            Row(
              children: [
                Expanded(
                  child: _StatItemSkeleton(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItemSkeleton(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItemSkeleton(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItemSkeleton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal stat item skeleton.
class _StatItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label skeleton
          const StatsLoadingSkeleton(
            height: 12,
            width: 80,
          ),
          const SizedBox(height: 8),
          // Value skeleton
          const StatsLoadingSkeleton(
            height: 20,
            width: 50,
          ),
        ],
      ),
    );
  }
}

/// Compact loading skeleton for smaller stat cards.
class CompactStatLoadingSkeleton extends StatelessWidget {
  const CompactStatLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const StatsLoadingSkeleton(
              height: 14,
              width: 70,
            ),
            const SizedBox(height: 8),
            const StatsLoadingSkeleton(
              height: 24,
              width: 50,
            ),
          ],
        ),
      ),
    );
  }
}

// Monthly improvement chart showing long-term ELO progress.
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_stats_placeholder.dart';

/// A chart widget showing monthly ELO improvement over time.
///
/// Purpose: Show long-term progress rather than short-term volatility.
/// Answers: "Am I actually getting better over time?"
///
/// Features:
/// - X-axis: Months (e.g., Jan, Feb, Mar)
/// - Y-axis: ELO rating
/// - Each point: End-of-month ELO snapshot
/// - Smooth line chart
/// - Highlights: Best and worst months
/// - Only appears if ≥ 2 months of data
class MonthlyImprovementChart extends StatelessWidget {
  final List<RatingHistoryEntry> ratingHistory;
  final double currentElo;

  const MonthlyImprovementChart({
    super.key,
    required this.ratingHistory,
    required this.currentElo,
  });

  @override
  Widget build(BuildContext context) {
    final monthlyData = _aggregateByMonth();

    // Only show if we have at least 2 months of data
    if (monthlyData.length < 2) {
      return _buildPlaceholder(context);
    }

    return _buildChart(context, monthlyData);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return const InsufficientDataPlaceholder(
      featureName: 'Monthly Progress Chart',
      requirement: 'Play games for at least 2 months',
      icon: Icons.timeline,
    );
  }

  Widget _buildChart(BuildContext context, List<MonthlyDataPoint> monthlyData) {
    final theme = Theme.of(context);

    // Find best and worst months
    final bestMonth = _findBestMonth(monthlyData);
    final worstMonth = _findWorstMonth(monthlyData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthlyData.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          monthlyData[index].monthLabel,
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.eloRating,
                      );
                    }).toList(),
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: theme.colorScheme.primary,
                          strokeColor: Colors.white,
                          strokeWidth: 2,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Best/worst month badges
        if (bestMonth != null || worstMonth != null)
          Wrap(
            spacing: 8,
            children: [
              if (bestMonth != null)
                _MonthBadge(
                  label: 'Best Month',
                  month: bestMonth.monthLabel,
                  delta: bestMonth.delta,
                  isPositive: true,
                ),
              if (worstMonth != null)
                _MonthBadge(
                  label: 'Toughest Month',
                  month: worstMonth.monthLabel,
                  delta: worstMonth.delta,
                  isPositive: false,
                ),
            ],
          ),
      ],
    );
  }

  /// Aggregates rating history by month.
  ///
  /// Strategy: Use end-of-month ELO snapshot for each month.
  List<MonthlyDataPoint> _aggregateByMonth() {
    if (ratingHistory.isEmpty) return [];

    // Group entries by month
    final Map<String, List<RatingHistoryEntry>> monthGroups = {};

    for (final entry in ratingHistory) {
      final monthKey = DateFormat('yyyy-MM').format(entry.timestamp);
      monthGroups.putIfAbsent(monthKey, () => []).add(entry);
    }

    // Create data points (use the most recent entry in each month as end-of-month snapshot)
    final List<MonthlyDataPoint> dataPoints = [];
    final sortedMonths = monthGroups.keys.toList()..sort();

    for (int i = 0; i < sortedMonths.length; i++) {
      final monthKey = sortedMonths[i];
      final entries = monthGroups[monthKey]!;

      // Sort entries by timestamp (most recent first)
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Use the most recent entry's newRating as end-of-month snapshot
      final endOfMonthRating = entries.first.newRating;

      // Calculate delta from previous month
      double? delta;
      if (i > 0) {
        final prevMonthKey = sortedMonths[i - 1];
        final prevEntries = monthGroups[prevMonthKey]!;
        prevEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final prevRating = prevEntries.first.newRating;
        delta = endOfMonthRating - prevRating;
      }

      final date = DateTime.parse('$monthKey-01');
      dataPoints.add(MonthlyDataPoint(
        date: date,
        eloRating: endOfMonthRating,
        delta: delta,
      ));
    }

    return dataPoints;
  }

  MonthlyDataPoint? _findBestMonth(List<MonthlyDataPoint> data) {
    if (data.length < 2) return null;

    MonthlyDataPoint? best;
    double maxDelta = double.negativeInfinity;

    for (final point in data) {
      if (point.delta != null && point.delta! > maxDelta && point.delta! > 0) {
        maxDelta = point.delta!;
        best = point;
      }
    }

    return best;
  }

  MonthlyDataPoint? _findWorstMonth(List<MonthlyDataPoint> data) {
    if (data.length < 2) return null;

    MonthlyDataPoint? worst;
    double minDelta = double.infinity;

    for (final point in data) {
      if (point.delta != null && point.delta! < minDelta && point.delta! < 0) {
        minDelta = point.delta!;
        worst = point;
      }
    }

    return worst;
  }
}

/// Data point representing ELO rating for a specific month.
class MonthlyDataPoint {
  final DateTime date;
  final double eloRating;
  final double? delta; // Change from previous month

  MonthlyDataPoint({
    required this.date,
    required this.eloRating,
    this.delta,
  });

  String get monthLabel => DateFormat('MMM').format(date);
}

/// Badge showing best or worst month performance.
class _MonthBadge extends StatelessWidget {
  final String label;
  final String month;
  final double? delta;
  final bool isPositive;

  const _MonthBadge({
    required this.label,
    required this.month,
    required this.delta,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$month: ${delta != null ? '${delta! > 0 ? '+' : ''}${delta!.toStringAsFixed(0)}' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

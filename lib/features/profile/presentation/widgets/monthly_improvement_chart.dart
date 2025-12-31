// Enhanced ELO progress chart with area fill and adaptive aggregation (Story 302.4).
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'package:play_with_me/features/profile/presentation/widgets/empty_stats_placeholder.dart';

/// Enhanced area chart showing ELO progress over time with adaptive aggregation.
///
/// Features (Story 302.4):
/// - Area chart with gradient fill
/// - Smooth curves
/// - Adaptive aggregation (daily/weekly/monthly based on time period)
/// - No grid lines
/// - Adaptive Y-axis scaling
/// - Conditional dot display (hidden for large datasets)
class MonthlyImprovementChart extends StatelessWidget {
  final List<RatingHistoryEntry> ratingHistory;
  final double currentElo;
  final TimePeriod timePeriod;

  const MonthlyImprovementChart({
    super.key,
    required this.ratingHistory,
    required this.currentElo,
    this.timePeriod = TimePeriod.allTime,
  });

  @override
  Widget build(BuildContext context) {
    final aggregatedData = _aggregateByPeriod(timePeriod);

    // Minimum data requirement: 2 data points
    if (aggregatedData.length < 2) {
      return _buildPlaceholder(context);
    }

    return _buildChart(context, aggregatedData);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return const InsufficientDataPlaceholder(
      featureName: 'ELO Progress Chart',
      requirement: 'Play games over multiple time periods',
      icon: Icons.timeline,
    );
  }

  /// Adaptive aggregation based on time period (Story 302.4)
  List<ChartDataPoint> _aggregateByPeriod(TimePeriod period) {
    if (ratingHistory.isEmpty) return [];

    switch (period) {
      case TimePeriod.fifteenDays:
      case TimePeriod.thirtyDays:
        return _aggregateByDay();
      case TimePeriod.ninetyDays:
        return _aggregateByWeek();
      case TimePeriod.oneYear:
      case TimePeriod.allTime:
        return _aggregateByMonth();
    }
  }

  /// Aggregate by day (for short periods ≤ 30 days)
  List<ChartDataPoint> _aggregateByDay() {
    final Map<String, List<RatingHistoryEntry>> dayGroups = {};

    for (final entry in ratingHistory) {
      final dayKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      dayGroups.putIfAbsent(dayKey, () => []).add(entry);
    }

    return _buildDataPoints(dayGroups, DateFormat('MMM d'));
  }

  /// Aggregate by week (for medium periods ~90 days)
  List<ChartDataPoint> _aggregateByWeek() {
    final Map<String, List<RatingHistoryEntry>> weekGroups = {};

    for (final entry in ratingHistory) {
      // ISO week number
      final weekStart = _getWeekStart(entry.timestamp);
      final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
      weekGroups.putIfAbsent(weekKey, () => []).add(entry);
    }

    return _buildDataPoints(weekGroups, DateFormat('MMM d'));
  }

  /// Get the start of the week (Monday) for a given date
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  /// Aggregate by month (for long periods ≥ 1 year)
  List<ChartDataPoint> _aggregateByMonth() {
    final Map<String, List<RatingHistoryEntry>> monthGroups = {};

    for (final entry in ratingHistory) {
      final monthKey = DateFormat('yyyy-MM').format(entry.timestamp);
      monthGroups.putIfAbsent(monthKey, () => []).add(entry);
    }

    return _buildDataPoints(monthGroups, DateFormat('MMM'));
  }

  /// Build data points from grouped entries
  List<ChartDataPoint> _buildDataPoints(
    Map<String, List<RatingHistoryEntry>> groups,
    DateFormat labelFormat,
  ) {
    final sortedKeys = groups.keys.toList()..sort();
    final List<ChartDataPoint> dataPoints = [];

    for (final key in sortedKeys) {
      final entries = groups[key]!;

      // Sort by timestamp (most recent last)
      entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Use last entry's rating as snapshot
      final snapshotRating = entries.last.newRating;
      final date = entries.last.timestamp;

      dataPoints.add(ChartDataPoint(
        date: date,
        eloRating: snapshotRating,
        label: labelFormat.format(date),
      ));
    }

    return dataPoints;
  }

  Widget _buildChart(BuildContext context, List<ChartDataPoint> data) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 220, // Increased height for better visibility
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 16.0),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false), // No grid (Story 302.4)
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval: _calculateYAxisInterval(data),
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
                  reservedSize: 32,
                  interval: _calculateXAxisInterval(data),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data[index].label,
                        style: theme.textTheme.bodySmall,
                      ),
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
                spots: data.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.eloRating,
                  );
                }).toList(),
                isCurved: true, // Smooth curves (Story 302.4)
                curveSmoothness: 0.4,
                color: theme.colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: data.length <= 15, // Conditional dots (Story 302.4)
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: theme.colorScheme.primary,
                      strokeColor: Colors.white,
                      strokeWidth: 2,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.3),
                      theme.colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ],
            minY: _calculateMinY(data),
            maxY: _calculateMaxY(data),
          ),
        ),
      ),
    );
  }

  // Helper methods for adaptive scaling (Story 302.4)
  double _calculateMinY(List<ChartDataPoint> data) {
    final minElo = data.map((e) => e.eloRating).reduce((a, b) => a < b ? a : b);
    return (minElo - 50).floorToDouble();
  }

  double _calculateMaxY(List<ChartDataPoint> data) {
    final maxElo = data.map((e) => e.eloRating).reduce((a, b) => a > b ? a : b);
    return (maxElo + 50).ceilToDouble();
  }

  double _calculateYAxisInterval(List<ChartDataPoint> data) {
    final range = _calculateMaxY(data) - _calculateMinY(data);
    return (range / 4).ceilToDouble(); // ~4 labels on Y-axis
  }

  double _calculateXAxisInterval(List<ChartDataPoint> data) {
    if (data.length <= 5) return 1;
    if (data.length <= 10) return 2;
    if (data.length <= 20) return 4;
    return (data.length / 5).ceilToDouble();
  }
}

/// Data point for chart display with timestamp and label
class ChartDataPoint {
  final DateTime date;
  final double eloRating;
  final String label;

  ChartDataPoint({
    required this.date,
    required this.eloRating,
    required this.label,
  });
}

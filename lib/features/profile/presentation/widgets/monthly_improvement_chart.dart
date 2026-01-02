// Enhanced ELO progress chart with area fill and adaptive aggregation (Story 302.4).
import 'dart:math';
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

    // Calculate Y-axis bounds and interval (Story 302.4.1)
    final minElo = data.map((e) => e.eloRating).reduce((a, b) => a < b ? a : b);
    final maxElo = data.map((e) => e.eloRating).reduce((a, b) => a > b ? a : b);

    var dataMinY = minElo;
    var dataMaxY = maxElo;

    // Ensure minimal range to avoid single-line chart
    if (dataMaxY - dataMinY < 1) {
      dataMinY -= 2;
      dataMaxY += 2;
    }

    final range = dataMaxY - dataMinY;

    // Calculate a "nice" interval ensuring max 5 labels (Story 302.4.1)
    // Start with an interval that would give us about 4-5 labels
    final rawInterval = range / 4;
    var interval = _calculateNiceInterval(rawInterval);

    // Round bounds to interval boundaries to get compact, data-focused range
    var minY = (dataMinY / interval).floor() * interval;
    var maxY = (dataMaxY / interval).ceil() * interval;

    // Count how many labels we'd have (intervals + 1)
    var numLabels = ((maxY - minY) / interval).round() + 1;

    // If we have more than 5 labels, increase interval to next nice number
    while (numLabels > 5) {
      interval = _getNextNiceInterval(interval);
      minY = (dataMinY / interval).floor() * interval;
      maxY = (dataMaxY / interval).ceil() * interval;
      numLabels = ((maxY - minY) / interval).round() + 1;
    }

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 16.0),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval: interval,
                  getTitlesWidget: (value, meta) {
                    // Simply display the rounded value for every interval tick.
                    // fl_chart guarantees these are spaced by `interval`.
                    return Text(
                      value.round().toString(),
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
            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            // Allow drawing outside to prevent line thickness clipping at exact min/max
            clipData: const FlClipData.none(),
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.eloRating,
                  );
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.4,
                color: theme.colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: data.length <= 15,
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
            minY: minY,
            maxY: maxY,
          ),
        ),
      ),
    );
  }

  double _calculateXAxisInterval(List<ChartDataPoint> data) {
    if (data.length <= 5) return 1;
    if (data.length <= 10) return 2;
    if (data.length <= 20) return 4;
    return (data.length / 5).ceilToDouble();
  }

  /// Calculate a "nice" interval for Y-axis labels (Story 302.4.1)
  ///
  /// Rounds the raw interval to friendly numbers like 1, 2, 5, 10, 20, 50, 100, etc.
  /// This ensures readable labels and prevents overlap.
  double _calculateNiceInterval(double rawInterval) {
    if (rawInterval <= 0) return 1;

    // Find the magnitude (power of 10)
    final exponent = (log(rawInterval) / ln10).floor();
    final magnitude = pow(10, exponent).toDouble();

    // Normalize to range [1, 10)
    final normalized = rawInterval / magnitude;

    // Round to nearest nice number: 1, 2, 5, or 10
    double nice;
    if (normalized <= 1.5) {
      nice = 1;
    } else if (normalized <= 3) {
      nice = 2;
    } else if (normalized <= 7) {
      nice = 5;
    } else {
      nice = 10;
    }

    final result = nice * magnitude;

    // Ensure minimum interval of 1 to avoid fractional ELO labels
    return result < 1 ? 1 : result;
  }

  /// Get the next nice interval (Story 302.4.1)
  ///
  /// Returns the next value in the sequence: 1, 2, 5, 10, 20, 50, 100, etc.
  double _getNextNiceInterval(double currentInterval) {
    if (currentInterval <= 0) return 1;

    // Find the magnitude (power of 10)
    final exponent = (log(currentInterval) / ln10).floor();
    final magnitude = pow(10, exponent).toDouble();

    // Normalize to range [1, 10)
    final normalized = currentInterval / magnitude;

    // Get next nice number in sequence: 1 -> 2 -> 5 -> 10
    double nextNice;
    if (normalized < 2) {
      nextNice = 2;
    } else if (normalized < 5) {
      nextNice = 5;
    } else {
      nextNice = 10;
    }

    final result = nextNice * magnitude;

    // Ensure minimum interval of 1
    return result < 1 ? 1 : result;
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

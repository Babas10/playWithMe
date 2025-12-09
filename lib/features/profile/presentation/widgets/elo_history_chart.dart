import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/rating_history_entry.dart';
import 'package:intl/intl.dart';

class EloHistoryChart extends StatelessWidget {
  final List<RatingHistoryEntry> history;
  final double currentRating;

  const EloHistoryChart({
    super.key,
    required this.history,
    required this.currentRating,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Text(
          'No rating history yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    // Sort history by timestamp ascending for the chart
    final sortedHistory = List<RatingHistoryEntry>.from(history)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final List<FlSpot> spots = [];
    
    if (sortedHistory.isNotEmpty) {
      // Point 0: The rating before the first recorded game
      spots.add(FlSpot(0, sortedHistory.first.oldRating));
      
      for (int i = 0; i < sortedHistory.length; i++) {
        spots.add(FlSpot((i + 1).toDouble(), sortedHistory[i].newRating));
      }
    }

    // Determine Y axis range
    double minRating = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxRating = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    
    // Add some padding
    minRating = (minRating - 20).roundToDouble();
    maxRating = (maxRating + 20).roundToDouble();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: spots.length.toDouble(),
        minY: minRating,
        maxY: maxRating,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map<LineTooltipItem>((spot) {
                String dateStr = '';
                if (spot.x > 0 && spot.x <= sortedHistory.length) {
                  final entry = sortedHistory[spot.x.toInt() - 1];
                  dateStr = DateFormat('MMM d').format(entry.timestamp);
                } else if (spot.x == 0) {
                  dateStr = 'Start';
                }

                return LineTooltipItem(
                  '''${spot.y.toStringAsFixed(0)}
$dateStr''',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

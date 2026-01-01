/// Time period options for filtering ELO rating history (Story 302.1).
/// Used to display rating progress over different time ranges.
enum TimePeriod {
  thirtyDays,
  ninetyDays,
  oneYear,
  allTime,
}

/// Extension methods for TimePeriod enum
extension TimePeriodExtension on TimePeriod {
  /// Get the start date for this time period relative to now
  DateTime getStartDate() {
    final now = DateTime.now();
    switch (this) {
      case TimePeriod.thirtyDays:
        return now.subtract(const Duration(days: 30));
      case TimePeriod.ninetyDays:
        return now.subtract(const Duration(days: 90));
      case TimePeriod.oneYear:
        return now.subtract(const Duration(days: 365));
      case TimePeriod.allTime:
        return DateTime(2020, 1, 1); // App launch date
    }
  }

  /// Get human-readable display name for this time period
  String get displayName {
    switch (this) {
      case TimePeriod.thirtyDays:
        return '30d';
      case TimePeriod.ninetyDays:
        return '90d';
      case TimePeriod.oneYear:
        return '1y';
      case TimePeriod.allTime:
        return 'All Time';
    }
  }
}

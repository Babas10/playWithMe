import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurrence_rule_model.freezed.dart';
part 'recurrence_rule_model.g.dart';

/// Defines the frequency of recurrence for training sessions
enum RecurrenceFrequency {
  @JsonValue('none')
  none,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
}

/// Represents a recurrence rule for training sessions
///
/// This model defines how a training session repeats over time.
/// It supports weekly and monthly recurrence patterns.
///
/// Examples:
/// - Every week for 10 occurrences
/// - Every 2 weeks on Mondays and Wednesdays until a specific date
/// - Every month for 6 occurrences
@freezed
class RecurrenceRuleModel with _$RecurrenceRuleModel {
  const factory RecurrenceRuleModel({
    /// The frequency of recurrence (weekly, monthly, or none)
    @Default(RecurrenceFrequency.none) RecurrenceFrequency frequency,

    /// The interval between occurrences (e.g., every 1 week, every 2 months)
    /// Must be >= 1
    @Default(1) int interval,

    /// The number of occurrences to generate
    /// Either count or endDate should be specified, not both
    int? count,

    /// The date until which to generate occurrences
    /// Either count or endDate should be specified, not both
    @JsonKey(
      fromJson: _dateTimeFromJson,
      toJson: _dateTimeToJson,
    )
    DateTime? endDate,

    /// Days of the week for weekly recurrence (1 = Monday, 7 = Sunday)
    /// Only applicable when frequency is weekly
    /// If null or empty for weekly recurrence, defaults to the same day as the parent session
    List<int>? daysOfWeek,
  }) = _RecurrenceRuleModel;

  const RecurrenceRuleModel._();

  factory RecurrenceRuleModel.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceRuleModelFromJson(json);

  /// Create a weekly recurrence rule
  factory RecurrenceRuleModel.weekly({
    int interval = 1,
    int? count,
    DateTime? endDate,
    List<int>? daysOfWeek,
  }) {
    return RecurrenceRuleModel(
      frequency: RecurrenceFrequency.weekly,
      interval: interval,
      count: count,
      endDate: endDate,
      daysOfWeek: daysOfWeek,
    );
  }

  /// Create a monthly recurrence rule
  factory RecurrenceRuleModel.monthly({
    int interval = 1,
    int? count,
    DateTime? endDate,
  }) {
    return RecurrenceRuleModel(
      frequency: RecurrenceFrequency.monthly,
      interval: interval,
      count: count,
      endDate: endDate,
    );
  }

  /// Create a non-recurring rule (default)
  factory RecurrenceRuleModel.none() {
    return const RecurrenceRuleModel(
      frequency: RecurrenceFrequency.none,
    );
  }

  /// Validation: Check if the recurrence rule is valid
  bool get isValid {
    // Interval must be positive
    if (interval < 1) return false;

    // For weekly recurrence, daysOfWeek (if specified) must be between 1-7
    if (frequency == RecurrenceFrequency.weekly && daysOfWeek != null) {
      if (daysOfWeek!.isEmpty) return false;
      if (daysOfWeek!.any((day) => day < 1 || day > 7)) return false;
    }

    // Either count or endDate should be specified (but not both) for recurring sessions
    if (frequency != RecurrenceFrequency.none) {
      if (count == null && endDate == null) return false;
      if (count != null && endDate != null) return false;

      // Count must be positive
      if (count != null && count! < 1) return false;

      // End date must be in the future
      if (endDate != null && endDate!.isBefore(DateTime.now())) return false;
    }

    return true;
  }

  /// Check if this rule creates recurring sessions
  bool get isRecurring => frequency != RecurrenceFrequency.none;

  /// Get a human-readable description of the recurrence rule
  String getDescription() {
    if (frequency == RecurrenceFrequency.none) {
      return 'Does not repeat';
    }

    final buffer = StringBuffer();

    // Frequency and interval
    if (interval == 1) {
      buffer.write('Every ${frequency.name}');
    } else {
      buffer.write('Every $interval ${frequency.name}s');
    }

    // Days of week for weekly recurrence
    if (frequency == RecurrenceFrequency.weekly && daysOfWeek != null && daysOfWeek!.isNotEmpty) {
      final dayNames = daysOfWeek!.map((day) => _getDayName(day)).join(', ');
      buffer.write(' on $dayNames');
    }

    // Count or end date
    if (count != null) {
      buffer.write(', $count times');
    } else if (endDate != null) {
      buffer.write(', until ${_formatDate(endDate!)}');
    }

    return buffer.toString();
  }

  /// Helper method to get day name from day number (1=Monday, 7=Sunday)
  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }

  /// Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// JSON converter helpers for DateTime
DateTime? _dateTimeFromJson(String? json) {
  if (json == null) return null;
  return DateTime.parse(json);
}

String? _dateTimeToJson(DateTime? dateTime) {
  return dateTime?.toIso8601String();
}

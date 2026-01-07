// Unit tests for RecurrenceRuleModel
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/recurrence_rule_model.dart';

void main() {
  group('RecurrenceRuleModel', () {
    group('Factory constructors', () {
      test('weekly() creates valid weekly recurrence rule', () {
        final rule = RecurrenceRuleModel.weekly(
          interval: 1,
          count: 10,
          daysOfWeek: [1, 3, 5], // Mon, Wed, Fri
        );

        expect(rule.frequency, RecurrenceFrequency.weekly);
        expect(rule.interval, 1);
        expect(rule.count, 10);
        expect(rule.endDate, isNull);
        expect(rule.daysOfWeek, [1, 3, 5]);
      });

      test('weekly() with endDate instead of count', () {
        final endDate = DateTime.now().add(const Duration(days: 90));
        final rule = RecurrenceRuleModel.weekly(
          interval: 2,
          endDate: endDate,
        );

        expect(rule.frequency, RecurrenceFrequency.weekly);
        expect(rule.interval, 2);
        expect(rule.count, isNull);
        expect(rule.endDate, endDate);
      });

      test('monthly() creates valid monthly recurrence rule', () {
        final rule = RecurrenceRuleModel.monthly(
          interval: 1,
          count: 6,
        );

        expect(rule.frequency, RecurrenceFrequency.monthly);
        expect(rule.interval, 1);
        expect(rule.count, 6);
        expect(rule.endDate, isNull);
        expect(rule.daysOfWeek, isNull);
      });

      test('monthly() with endDate instead of count', () {
        final endDate = DateTime.now().add(const Duration(days: 180));
        final rule = RecurrenceRuleModel.monthly(
          interval: 2,
          endDate: endDate,
        );

        expect(rule.frequency, RecurrenceFrequency.monthly);
        expect(rule.interval, 2);
        expect(rule.count, isNull);
        expect(rule.endDate, endDate);
      });

      test('none() creates non-recurring rule', () {
        final rule = RecurrenceRuleModel.none();

        expect(rule.frequency, RecurrenceFrequency.none);
        expect(rule.interval, 1);
        expect(rule.count, isNull);
        expect(rule.endDate, isNull);
        expect(rule.daysOfWeek, isNull);
      });
    });

    group('Validation', () {
      test('isValid returns true for valid weekly rule with count', () {
        final rule = RecurrenceRuleModel.weekly(
          interval: 1,
          count: 10,
          daysOfWeek: [1, 5],
        );

        expect(rule.isValid, isTrue);
      });

      test('isValid returns true for valid weekly rule with endDate', () {
        final rule = RecurrenceRuleModel.weekly(
          interval: 2,
          endDate: DateTime.now().add(const Duration(days: 90)),
        );

        expect(rule.isValid, isTrue);
      });

      test('isValid returns true for valid monthly rule', () {
        final rule = RecurrenceRuleModel.monthly(
          interval: 1,
          count: 12,
        );

        expect(rule.isValid, isTrue);
      });

      test('isValid returns true for none frequency', () {
        final rule = RecurrenceRuleModel.none();
        expect(rule.isValid, isTrue);
      });

      test('isValid returns false when interval < 1', () {
        final rule = RecurrenceRuleModel(
          frequency: RecurrenceFrequency.weekly,
          interval: 0,
          count: 10,
        );

        expect(rule.isValid, isFalse);
      });

      test('isValid returns false when count < 1', () {
        final rule = RecurrenceRuleModel(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
          count: 0,
        );

        expect(rule.isValid, isFalse);
      });

      test('isValid returns false when neither count nor endDate is provided', () {
        final rule = RecurrenceRuleModel(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
        );

        expect(rule.isValid, isFalse);
      });

      test('isValid returns false when daysOfWeek contains invalid day', () {
        final rule = RecurrenceRuleModel(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
          count: 10,
          daysOfWeek: [1, 8], // 8 is invalid (must be 1-7)
        );

        expect(rule.isValid, isFalse);
      });

      test('isValid returns false when daysOfWeek is empty for weekly', () {
        final rule = RecurrenceRuleModel(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
          count: 10,
          daysOfWeek: [],
        );

        expect(rule.isValid, isFalse);
      });

      test('isValid returns false when endDate is in the past', () {
        final rule = RecurrenceRuleModel(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
          endDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(rule.isValid, isFalse);
      });
    });

    group('isRecurring getter', () {
      test('returns true for weekly frequency', () {
        final rule = RecurrenceRuleModel.weekly(count: 10);
        expect(rule.isRecurring, isTrue);
      });

      test('returns true for monthly frequency', () {
        final rule = RecurrenceRuleModel.monthly(count: 6);
        expect(rule.isRecurring, isTrue);
      });

      test('returns false for none frequency', () {
        final rule = RecurrenceRuleModel.none();
        expect(rule.isRecurring, isFalse);
      });
    });

    group('getDescription', () {
      test('returns correct description for weekly with count', () {
        final rule = RecurrenceRuleModel.weekly(
          interval: 1,
          count: 10,
          daysOfWeek: [1, 3, 5],
        );

        final description = rule.getDescription();
        expect(description, contains('Every weekly'));
        expect(description, contains('Monday'));
        expect(description, contains('Wednesday'));
        expect(description, contains('Friday'));
        expect(description, contains('10 times'));
      });

      test('returns correct description for every 2 weeks', () {
        final rule = RecurrenceRuleModel.weekly(
          interval: 2,
          count: 5,
        );

        final description = rule.getDescription();
        expect(description, contains('Every 2 weeklys'));
      });

      test('returns correct description for monthly with endDate', () {
        final endDate = DateTime(2025, 12, 31);
        final rule = RecurrenceRuleModel.monthly(
          interval: 1,
          endDate: endDate,
        );

        final description = rule.getDescription();
        expect(description, contains('Every monthly'));
        expect(description, contains('until'));
        expect(description, contains('31/12/2025'));
      });

      test('returns correct description for every 3 months', () {
        final rule = RecurrenceRuleModel.monthly(
          interval: 3,
          count: 4,
        );

        final description = rule.getDescription();
        expect(description, contains('Every 3 monthlys'));
        expect(description, contains('4 times'));
      });

      test('returns "Does not repeat" for none frequency', () {
        final rule = RecurrenceRuleModel.none();
        expect(rule.getDescription(), 'Does not repeat');
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson preserve all fields', () {
        final original = RecurrenceRuleModel.weekly(
          interval: 2,
          count: 10,
          daysOfWeek: [1, 3, 5],
        );

        final json = original.toJson();
        final restored = RecurrenceRuleModel.fromJson(json);

        expect(restored.frequency, original.frequency);
        expect(restored.interval, original.interval);
        expect(restored.count, original.count);
        expect(restored.endDate, original.endDate);
        expect(restored.daysOfWeek, original.daysOfWeek);
      });

      test('toJson and fromJson handle endDate correctly', () {
        final endDate = DateTime(2025, 12, 31, 14, 30);
        final original = RecurrenceRuleModel.monthly(
          interval: 1,
          endDate: endDate,
        );

        final json = original.toJson();
        final restored = RecurrenceRuleModel.fromJson(json);

        expect(restored.endDate, isNotNull);
        // Compare ISO strings to avoid microsecond precision issues
        expect(
          restored.endDate!.toIso8601String(),
          endDate.toIso8601String(),
        );
      });

      test('toJson handles null fields correctly', () {
        final rule = RecurrenceRuleModel.none();
        final json = rule.toJson();

        expect(json['frequency'], 'none');
        expect(json['interval'], 1);
        expect(json['count'], isNull);
        expect(json['endDate'], isNull);
        expect(json['daysOfWeek'], isNull);
      });
    });

    group('Edge cases', () {
      test('handles maximum count (100)', () {
        final rule = RecurrenceRuleModel.weekly(
          interval: 1,
          count: 100,
        );

        expect(rule.isValid, isTrue);
        expect(rule.count, 100);
      });

      test('handles all days of week', () {
        final rule = RecurrenceRuleModel.weekly(
          interval: 1,
          count: 10,
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        );

        expect(rule.isValid, isTrue);
        expect(rule.daysOfWeek!.length, 7);
      });

      test('copyWith works correctly', () {
        final original = RecurrenceRuleModel.weekly(
          interval: 1,
          count: 10,
        );

        final modified = original.copyWith(count: 20);

        expect(modified.frequency, original.frequency);
        expect(modified.interval, original.interval);
        expect(modified.count, 20); // Changed
      });
    });
  });
}

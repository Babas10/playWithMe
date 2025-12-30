// Tests TimePeriod enum and its extension methods for ELO history filtering (Story 302.1).

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';

void main() {
  group('TimePeriod enum', () {
    group('getStartDate()', () {
      late DateTime testNow;

      setUp(() {
        // Use a fixed reference point for consistent testing
        testNow = DateTime.now();
      });

      test('fifteenDays returns date 15 days ago', () {
        final startDate = TimePeriod.fifteenDays.getStartDate();
        final expectedDate = testNow.subtract(const Duration(days: 15));

        // Allow 1 second tolerance for test execution time
        expect(
          startDate.difference(expectedDate).abs().inSeconds,
          lessThan(2),
        );
      });

      test('thirtyDays returns date 30 days ago', () {
        final startDate = TimePeriod.thirtyDays.getStartDate();
        final expectedDate = testNow.subtract(const Duration(days: 30));

        expect(
          startDate.difference(expectedDate).abs().inSeconds,
          lessThan(2),
        );
      });

      test('ninetyDays returns date 90 days ago', () {
        final startDate = TimePeriod.ninetyDays.getStartDate();
        final expectedDate = testNow.subtract(const Duration(days: 90));

        expect(
          startDate.difference(expectedDate).abs().inSeconds,
          lessThan(2),
        );
      });

      test('oneYear returns date 365 days ago', () {
        final startDate = TimePeriod.oneYear.getStartDate();
        final expectedDate = testNow.subtract(const Duration(days: 365));

        expect(
          startDate.difference(expectedDate).abs().inSeconds,
          lessThan(2),
        );
      });

      test('allTime returns app launch date (January 1, 2020)', () {
        final startDate = TimePeriod.allTime.getStartDate();

        expect(startDate.year, equals(2020));
        expect(startDate.month, equals(1));
        expect(startDate.day, equals(1));
      });

      test('all periods return dates in the past', () {
        for (final period in TimePeriod.values) {
          final startDate = period.getStartDate();
          expect(
            startDate.isBefore(testNow),
            isTrue,
            reason: '$period should return a date in the past',
          );
        }
      });
    });

    group('displayName', () {
      test('fifteenDays returns "15 Days"', () {
        expect(TimePeriod.fifteenDays.displayName, equals('15 Days'));
      });

      test('thirtyDays returns "30 Days"', () {
        expect(TimePeriod.thirtyDays.displayName, equals('30 Days'));
      });

      test('ninetyDays returns "90 Days"', () {
        expect(TimePeriod.ninetyDays.displayName, equals('90 Days'));
      });

      test('oneYear returns "1 Year"', () {
        expect(TimePeriod.oneYear.displayName, equals('1 Year'));
      });

      test('allTime returns "All Time"', () {
        expect(TimePeriod.allTime.displayName, equals('All Time'));
      });

      test('all periods have non-empty display names', () {
        for (final period in TimePeriod.values) {
          expect(
            period.displayName,
            isNotEmpty,
            reason: '$period should have a non-empty display name',
          );
        }
      });

      test('all display names are unique', () {
        final displayNames = TimePeriod.values.map((p) => p.displayName).toSet();
        expect(
          displayNames.length,
          equals(TimePeriod.values.length),
          reason: 'All display names should be unique',
        );
      });
    });

    group('edge cases', () {
      test('enum has exactly 5 values', () {
        expect(TimePeriod.values.length, equals(5));
      });

      test('enum values are in expected order', () {
        expect(TimePeriod.values, [
          TimePeriod.fifteenDays,
          TimePeriod.thirtyDays,
          TimePeriod.ninetyDays,
          TimePeriod.oneYear,
          TimePeriod.allTime,
        ]);
      });

      test('getStartDate is idempotent within same second', () {
        final period = TimePeriod.thirtyDays;
        final firstCall = period.getStartDate();
        final secondCall = period.getStartDate();

        // Should be very close (within 1 second)
        expect(
          firstCall.difference(secondCall).abs().inSeconds,
          lessThan(2),
        );
      });

      test('periods are ordered from shortest to longest', () {
        final fifteenDaysStart = TimePeriod.fifteenDays.getStartDate();
        final thirtyDaysStart = TimePeriod.thirtyDays.getStartDate();
        final ninetyDaysStart = TimePeriod.ninetyDays.getStartDate();
        final oneYearStart = TimePeriod.oneYear.getStartDate();
        final allTimeStart = TimePeriod.allTime.getStartDate();

        expect(fifteenDaysStart.isAfter(thirtyDaysStart), isTrue);
        expect(thirtyDaysStart.isAfter(ninetyDaysStart), isTrue);
        expect(ninetyDaysStart.isAfter(oneYearStart), isTrue);
        expect(oneYearStart.isAfter(allTimeStart), isTrue);
      });
    });
  });
}

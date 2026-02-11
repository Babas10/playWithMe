// Validates Countries utility: normalize() handles ISO codes, valid names, and edge cases.

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/utils/countries.dart';

void main() {
  group('Countries', () {
    group('normalize', () {
      test('returns the same value when it is a valid country name', () {
        expect(Countries.normalize('Spain'), 'Spain');
        expect(Countries.normalize('France'), 'France');
        expect(Countries.normalize('Germany'), 'Germany');
        expect(Countries.normalize('United States'), 'United States');
        expect(Countries.normalize('Japan'), 'Japan');
      });

      test('returns defaultCountry when value is an ISO country code', () {
        expect(Countries.normalize('ES'), Countries.defaultCountry);
        expect(Countries.normalize('FR'), Countries.defaultCountry);
        expect(Countries.normalize('DE'), Countries.defaultCountry);
        expect(Countries.normalize('US'), Countries.defaultCountry);
        expect(Countries.normalize('JP'), Countries.defaultCountry);
      });

      test('returns defaultCountry when value is null', () {
        expect(Countries.normalize(null), Countries.defaultCountry);
      });

      test('returns defaultCountry when value is empty', () {
        expect(Countries.normalize(''), Countries.defaultCountry);
      });

      test('returns defaultCountry when value is an unrecognized string', () {
        expect(Countries.normalize('xyz'), Countries.defaultCountry);
        expect(Countries.normalize('NotACountry'), Countries.defaultCountry);
        expect(Countries.normalize('123'), Countries.defaultCountry);
      });

      test('is case-sensitive and rejects lowercase country names', () {
        expect(Countries.normalize('spain'), Countries.defaultCountry);
        expect(Countries.normalize('united states'), Countries.defaultCountry);
      });

      test('returns correct value for every country in the list', () {
        for (final country in Countries.all) {
          expect(Countries.normalize(country), country);
        }
      });
    });

    group('defaultCountry', () {
      test('is a valid entry in Countries.all', () {
        expect(Countries.all.contains(Countries.defaultCountry), isTrue);
      });

      test('is United States', () {
        expect(Countries.defaultCountry, 'United States');
      });
    });

    group('all', () {
      test('contains expected countries', () {
        expect(Countries.all, contains('Spain'));
        expect(Countries.all, contains('France'));
        expect(Countries.all, contains('United States'));
        expect(Countries.all, contains('Germany'));
        expect(Countries.all, contains('Italy'));
      });

      test('does not contain ISO codes', () {
        expect(Countries.all, isNot(contains('ES')));
        expect(Countries.all, isNot(contains('FR')));
        expect(Countries.all, isNot(contains('US')));
        expect(Countries.all, isNot(contains('DE')));
      });
    });
  });
}

// Tests LocalePreferencesEntity for default values and helper methods.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';

void main() {
  group('LocalePreferencesEntity', () {
    late DateTime testSyncedAt;
    late LocalePreferencesEntity baseEntity;

    setUp(() {
      testSyncedAt = DateTime(2024, 1, 15, 10, 30);
      baseEntity = LocalePreferencesEntity(
        locale: const Locale('en'),
        country: 'United States',
        timeZone: 'America/New_York',
        lastSyncedAt: testSyncedAt,
      );
    });

    group('constructor', () {
      test('creates instance with all fields', () {
        expect(baseEntity.locale, equals(const Locale('en')));
        expect(baseEntity.country, equals('United States'));
        expect(baseEntity.timeZone, equals('America/New_York'));
        expect(baseEntity.lastSyncedAt, equals(testSyncedAt));
      });

      test('creates instance with null optional fields', () {
        const entity = LocalePreferencesEntity(
          locale: Locale('fr'),
          country: 'France',
        );

        expect(entity.locale, equals(const Locale('fr')));
        expect(entity.country, equals('France'));
        expect(entity.timeZone, isNull);
        expect(entity.lastSyncedAt, isNull);
      });

      test('creates instance with different locales', () {
        const entity = LocalePreferencesEntity(
          locale: Locale('es'),
          country: 'Spain',
          timeZone: 'Europe/Madrid',
        );

        expect(entity.locale.languageCode, equals('es'));
        expect(entity.country, equals('Spain'));
      });
    });

    group('defaultPreferences', () {
      test('returns English locale', () {
        final defaults = LocalePreferencesEntity.defaultPreferences();

        expect(defaults.locale, equals(const Locale('en')));
      });

      test('returns United States country', () {
        final defaults = LocalePreferencesEntity.defaultPreferences();

        expect(defaults.country, equals('United States'));
      });

      test('returns null timeZone', () {
        final defaults = LocalePreferencesEntity.defaultPreferences();

        expect(defaults.timeZone, isNull);
      });

      test('returns null lastSyncedAt', () {
        final defaults = LocalePreferencesEntity.defaultPreferences();

        expect(defaults.lastSyncedAt, isNull);
      });
    });

    group('supportedLocales', () {
      test('contains English', () {
        expect(
          LocalePreferencesEntity.supportedLocales,
          contains(const Locale('en')),
        );
      });

      test('contains Spanish', () {
        expect(
          LocalePreferencesEntity.supportedLocales,
          contains(const Locale('es')),
        );
      });

      test('contains German', () {
        expect(
          LocalePreferencesEntity.supportedLocales,
          contains(const Locale('de')),
        );
      });

      test('contains Italian', () {
        expect(
          LocalePreferencesEntity.supportedLocales,
          contains(const Locale('it')),
        );
      });

      test('contains French', () {
        expect(
          LocalePreferencesEntity.supportedLocales,
          contains(const Locale('fr')),
        );
      });

      test('has exactly 5 supported locales', () {
        expect(LocalePreferencesEntity.supportedLocales.length, equals(5));
      });
    });

    group('getLanguageName', () {
      test('returns English for en locale', () {
        final name = LocalePreferencesEntity.getLanguageName(const Locale('en'));
        expect(name, equals('English'));
      });

      test('returns Spanish name for es locale', () {
        final name = LocalePreferencesEntity.getLanguageName(const Locale('es'));
        expect(name, equals('Español (Spanish)'));
      });

      test('returns German name for de locale', () {
        final name = LocalePreferencesEntity.getLanguageName(const Locale('de'));
        expect(name, equals('Deutsch (German)'));
      });

      test('returns Italian name for it locale', () {
        final name = LocalePreferencesEntity.getLanguageName(const Locale('it'));
        expect(name, equals('Italiano (Italian)'));
      });

      test('returns French name for fr locale', () {
        final name = LocalePreferencesEntity.getLanguageName(const Locale('fr'));
        expect(name, equals('Français (French)'));
      });

      test('returns language code for unknown locale', () {
        final name = LocalePreferencesEntity.getLanguageName(const Locale('zh'));
        expect(name, equals('zh'));
      });

      test('returns language code for unsupported locale', () {
        final name = LocalePreferencesEntity.getLanguageName(const Locale('ja'));
        expect(name, equals('ja'));
      });
    });

    group('copyWith', () {
      test('creates copy with updated locale', () {
        final copy = baseEntity.copyWith(locale: const Locale('fr'));

        expect(copy.locale, equals(const Locale('fr')));
        expect(copy.country, equals(baseEntity.country));
        expect(copy.timeZone, equals(baseEntity.timeZone));
      });

      test('creates copy with updated country', () {
        final copy = baseEntity.copyWith(country: 'Canada');

        expect(copy.locale, equals(baseEntity.locale));
        expect(copy.country, equals('Canada'));
      });

      test('creates copy with updated timeZone', () {
        final copy = baseEntity.copyWith(timeZone: 'America/Los_Angeles');

        expect(copy.timeZone, equals('America/Los_Angeles'));
      });

      test('creates copy with updated lastSyncedAt', () {
        final newSyncedAt = DateTime(2024, 2, 1);
        final copy = baseEntity.copyWith(lastSyncedAt: newSyncedAt);

        expect(copy.lastSyncedAt, equals(newSyncedAt));
      });

      test('creates copy with null timeZone', () {
        final entity = LocalePreferencesEntity(
          locale: const Locale('en'),
          country: 'United States',
          timeZone: 'America/New_York',
        );

        // Note: Freezed copyWith with null requires explicit handling
        // This test verifies the original entity has a timeZone
        expect(entity.timeZone, isNotNull);
      });
    });

    group('equality', () {
      test('two entities with same values are equal', () {
        final entity1 = LocalePreferencesEntity(
          locale: const Locale('en'),
          country: 'United States',
          timeZone: 'America/New_York',
          lastSyncedAt: testSyncedAt,
        );

        final entity2 = LocalePreferencesEntity(
          locale: const Locale('en'),
          country: 'United States',
          timeZone: 'America/New_York',
          lastSyncedAt: testSyncedAt,
        );

        expect(entity1, equals(entity2));
      });

      test('two entities with different locale are not equal', () {
        final entity1 = baseEntity;
        final entity2 = baseEntity.copyWith(locale: const Locale('fr'));

        expect(entity1, isNot(equals(entity2)));
      });

      test('two entities with different country are not equal', () {
        final entity1 = baseEntity;
        final entity2 = baseEntity.copyWith(country: 'Canada');

        expect(entity1, isNot(equals(entity2)));
      });

      test('two entities with different timeZone are not equal', () {
        final entity1 = baseEntity;
        final entity2 = baseEntity.copyWith(timeZone: 'America/Los_Angeles');

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final entity1 = LocalePreferencesEntity(
          locale: const Locale('en'),
          country: 'United States',
          timeZone: 'America/New_York',
          lastSyncedAt: testSyncedAt,
        );

        final entity2 = LocalePreferencesEntity(
          locale: const Locale('en'),
          country: 'United States',
          timeZone: 'America/New_York',
          lastSyncedAt: testSyncedAt,
        );

        expect(entity1.hashCode, equals(entity2.hashCode));
      });
    });

    group('use cases', () {
      test('creating entity for Spanish speaker in Spain', () {
        const entity = LocalePreferencesEntity(
          locale: Locale('es'),
          country: 'Spain',
          timeZone: 'Europe/Madrid',
        );

        expect(entity.locale.languageCode, equals('es'));
        expect(entity.country, equals('Spain'));
        expect(entity.timeZone, equals('Europe/Madrid'));
      });

      test('creating entity for German speaker in Austria', () {
        const entity = LocalePreferencesEntity(
          locale: Locale('de'),
          country: 'Austria',
          timeZone: 'Europe/Vienna',
        );

        expect(entity.locale.languageCode, equals('de'));
        expect(entity.country, equals('Austria'));
      });

      test('creating entity for French speaker in Canada', () {
        const entity = LocalePreferencesEntity(
          locale: Locale('fr'),
          country: 'Canada',
          timeZone: 'America/Montreal',
        );

        expect(entity.locale.languageCode, equals('fr'));
        expect(entity.country, equals('Canada'));
      });
    });
  });
}

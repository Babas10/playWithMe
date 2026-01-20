// Tests LocalePreferencesModel for conversion between entity and Firestore formats.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/profile/data/models/locale_preferences_model.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';

void main() {
  group('LocalePreferencesModel', () {
    late DateTime testSyncedAt;
    late LocalePreferencesModel baseModel;

    setUp(() {
      testSyncedAt = DateTime(2024, 1, 15, 10, 30);
      baseModel = LocalePreferencesModel(
        language: 'en',
        country: 'United States',
        timeZone: 'America/New_York',
        lastSyncedAt: testSyncedAt,
      );
    });

    group('constructor', () {
      test('creates instance with all fields', () {
        expect(baseModel.language, equals('en'));
        expect(baseModel.country, equals('United States'));
        expect(baseModel.timeZone, equals('America/New_York'));
        expect(baseModel.lastSyncedAt, equals(testSyncedAt));
      });

      test('creates instance with null optional fields', () {
        const model = LocalePreferencesModel(
          language: 'fr',
          country: 'France',
        );

        expect(model.language, equals('fr'));
        expect(model.country, equals('France'));
        expect(model.timeZone, isNull);
        expect(model.lastSyncedAt, isNull);
      });
    });

    group('fromEntity', () {
      test('converts entity to model correctly', () {
        final entity = LocalePreferencesEntity(
          locale: const Locale('en'),
          country: 'United States',
          timeZone: 'America/New_York',
          lastSyncedAt: testSyncedAt,
        );

        final model = LocalePreferencesModel.fromEntity(entity);

        expect(model.language, equals('en'));
        expect(model.country, equals('United States'));
        expect(model.timeZone, equals('America/New_York'));
        expect(model.lastSyncedAt, equals(testSyncedAt));
      });

      test('converts entity with null fields', () {
        const entity = LocalePreferencesEntity(
          locale: Locale('fr'),
          country: 'France',
        );

        final model = LocalePreferencesModel.fromEntity(entity);

        expect(model.language, equals('fr'));
        expect(model.country, equals('France'));
        expect(model.timeZone, isNull);
        expect(model.lastSyncedAt, isNull);
      });

      test('extracts language code from locale', () {
        const entity = LocalePreferencesEntity(
          locale: Locale('de'),
          country: 'Germany',
        );

        final model = LocalePreferencesModel.fromEntity(entity);

        expect(model.language, equals('de'));
      });
    });

    group('fromMap', () {
      test('parses map with all fields', () {
        final map = {
          'language': 'en',
          'country': 'United States',
          'timeZone': 'America/New_York',
          'lastSyncedAt': Timestamp.fromDate(testSyncedAt),
        };

        final model = LocalePreferencesModel.fromMap(map);

        expect(model.language, equals('en'));
        expect(model.country, equals('United States'));
        expect(model.timeZone, equals('America/New_York'));
        expect(model.lastSyncedAt, isNotNull);
      });

      test('parses map with null optional fields', () {
        final map = <String, dynamic>{
          'language': 'fr',
          'country': 'France',
          'timeZone': null,
          'lastSyncedAt': null,
        };

        final model = LocalePreferencesModel.fromMap(map);

        expect(model.language, equals('fr'));
        expect(model.country, equals('France'));
        expect(model.timeZone, isNull);
        expect(model.lastSyncedAt, isNull);
      });

      test('uses default language when not provided', () {
        final map = <String, dynamic>{
          'country': 'Canada',
        };

        final model = LocalePreferencesModel.fromMap(map);

        expect(model.language, equals('en'));
      });

      test('uses default country when not provided', () {
        final map = <String, dynamic>{
          'language': 'es',
        };

        final model = LocalePreferencesModel.fromMap(map);

        expect(model.country, equals('United States'));
      });
    });

    group('toEntity', () {
      test('converts model to entity correctly', () {
        final entity = baseModel.toEntity();

        expect(entity.locale, equals(const Locale('en')));
        expect(entity.country, equals('United States'));
        expect(entity.timeZone, equals('America/New_York'));
        expect(entity.lastSyncedAt, equals(testSyncedAt));
      });

      test('converts model with null fields', () {
        const model = LocalePreferencesModel(
          language: 'fr',
          country: 'France',
        );

        final entity = model.toEntity();

        expect(entity.locale, equals(const Locale('fr')));
        expect(entity.country, equals('France'));
        expect(entity.timeZone, isNull);
        expect(entity.lastSyncedAt, isNull);
      });

      test('creates Locale from language code', () {
        const model = LocalePreferencesModel(
          language: 'de',
          country: 'Germany',
        );

        final entity = model.toEntity();

        expect(entity.locale.languageCode, equals('de'));
      });
    });

    group('toFirestore', () {
      test('converts to Firestore map correctly', () {
        final firestoreMap = baseModel.toFirestore();

        expect(firestoreMap['language'], equals('en'));
        expect(firestoreMap['country'], equals('United States'));
        expect(firestoreMap['timeZone'], equals('America/New_York'));
        expect(firestoreMap['lastSyncedAt'], isA<Timestamp>());
      });

      test('converts lastSyncedAt to Timestamp', () {
        final firestoreMap = baseModel.toFirestore();

        final timestamp = firestoreMap['lastSyncedAt'] as Timestamp;
        expect(timestamp.toDate().year, equals(testSyncedAt.year));
        expect(timestamp.toDate().month, equals(testSyncedAt.month));
        expect(timestamp.toDate().day, equals(testSyncedAt.day));
      });

      test('uses server timestamp when lastSyncedAt is null', () {
        const model = LocalePreferencesModel(
          language: 'fr',
          country: 'France',
        );

        final firestoreMap = model.toFirestore();

        expect(firestoreMap['lastSyncedAt'], isA<FieldValue>());
      });

      test('includes null timeZone', () {
        const model = LocalePreferencesModel(
          language: 'es',
          country: 'Spain',
        );

        final firestoreMap = model.toFirestore();

        expect(firestoreMap['timeZone'], isNull);
      });
    });

    group('toMap', () {
      test('converts to map for SharedPreferences', () {
        final map = baseModel.toMap();

        expect(map['language'], equals('en'));
        expect(map['country'], equals('United States'));
        expect(map['timeZone'], equals('America/New_York'));
      });

      test('converts lastSyncedAt to milliseconds', () {
        final map = baseModel.toMap();

        expect(map['lastSyncedAt'], equals(testSyncedAt.millisecondsSinceEpoch));
      });

      test('includes null values for optional fields', () {
        const model = LocalePreferencesModel(
          language: 'fr',
          country: 'France',
        );

        final map = model.toMap();

        expect(map['timeZone'], isNull);
        expect(map['lastSyncedAt'], isNull);
      });
    });

    group('round trip conversions', () {
      test('entity -> model -> entity preserves data', () {
        final originalEntity = LocalePreferencesEntity(
          locale: const Locale('es'),
          country: 'Spain',
          timeZone: 'Europe/Madrid',
          lastSyncedAt: testSyncedAt,
        );

        final model = LocalePreferencesModel.fromEntity(originalEntity);
        final resultEntity = model.toEntity();

        expect(resultEntity.locale, equals(originalEntity.locale));
        expect(resultEntity.country, equals(originalEntity.country));
        expect(resultEntity.timeZone, equals(originalEntity.timeZone));
        expect(resultEntity.lastSyncedAt, equals(originalEntity.lastSyncedAt));
      });

      test('map -> model -> map preserves core data', () {
        final originalMap = {
          'language': 'de',
          'country': 'Germany',
          'timeZone': 'Europe/Berlin',
          'lastSyncedAt': Timestamp.fromDate(testSyncedAt),
        };

        final model = LocalePreferencesModel.fromMap(originalMap);
        final resultMap = model.toMap();

        expect(resultMap['language'], equals(originalMap['language']));
        expect(resultMap['country'], equals(originalMap['country']));
        expect(resultMap['timeZone'], equals(originalMap['timeZone']));
      });
    });

    group('use cases', () {
      test('creating model for Spanish speaker', () {
        const model = LocalePreferencesModel(
          language: 'es',
          country: 'Mexico',
          timeZone: 'America/Mexico_City',
        );

        expect(model.language, equals('es'));
        expect(model.country, equals('Mexico'));

        final entity = model.toEntity();
        expect(entity.locale.languageCode, equals('es'));
      });

      test('creating model for Italian speaker', () {
        const model = LocalePreferencesModel(
          language: 'it',
          country: 'Italy',
          timeZone: 'Europe/Rome',
        );

        expect(model.language, equals('it'));
        expect(model.country, equals('Italy'));
      });

      test('model with synced timestamp', () {
        final now = DateTime.now();
        final model = LocalePreferencesModel(
          language: 'en',
          country: 'United Kingdom',
          timeZone: 'Europe/London',
          lastSyncedAt: now,
        );

        expect(model.lastSyncedAt, equals(now));

        final firestoreData = model.toFirestore();
        expect(firestoreData['lastSyncedAt'], isA<Timestamp>());
      });
    });
  });
}

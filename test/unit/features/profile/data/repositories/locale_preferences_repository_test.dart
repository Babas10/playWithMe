// Validates LocalePreferencesRepositoryImpl handles local and Firestore storage correctly

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/profile/data/repositories/locale_preferences_repository_impl.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late MockFirebaseFirestore mockFirestore;
  late LocalePreferencesRepositoryImpl repository;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockFirestore = MockFirebaseFirestore();
    repository = LocalePreferencesRepositoryImpl(
      sharedPreferences: mockSharedPreferences,
      firestore: mockFirestore,
    );
  });

  group('LocalePreferencesRepositoryImpl', () {
    group('loadPreferences', () {
      test('returns default preferences when no saved data exists', () async {
        when(() => mockSharedPreferences.getString('user_locale_language'))
            .thenReturn(null);
        when(() => mockSharedPreferences.getString('user_locale_country'))
            .thenReturn(null);

        final result = await repository.loadPreferences();

        expect(result, LocalePreferencesEntity.defaultPreferences());
      });

      test('returns saved preferences when data exists', () async {
        when(() => mockSharedPreferences.getString('user_locale_language'))
            .thenReturn('es');
        when(() => mockSharedPreferences.getString('user_locale_country'))
            .thenReturn('Spain');
        when(() => mockSharedPreferences.getString('user_timezone'))
            .thenReturn('Europe/Madrid');
        when(() => mockSharedPreferences.getInt('user_locale_last_synced'))
            .thenReturn(1234567890);

        final result = await repository.loadPreferences();

        expect(result.locale, const Locale('es'));
        expect(result.country, 'Spain');
        expect(result.timeZone, 'Europe/Madrid');
      });
    });

    group('savePreferences', () {
      test('saves preferences to SharedPreferences', () async {
        final preferences = const LocalePreferencesEntity(
          locale: Locale('fr'),
          country: 'France',
          timeZone: 'Europe/Paris',
          lastSyncedAt: null,
        );

        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt(any(), any()))
            .thenAnswer((_) async => true);

        await repository.savePreferences(preferences);

        verify(() => mockSharedPreferences.setString(
            'user_locale_language', 'fr')).called(1);
        verify(() => mockSharedPreferences.setString(
            'user_locale_country', 'France')).called(1);
        verify(() => mockSharedPreferences.setString(
            'user_timezone', 'Europe/Paris')).called(1);
        verify(() => mockSharedPreferences.setInt(
            'user_locale_last_synced', any())).called(1);
      });
    });

    group('getDeviceTimeZone', () {
      test('returns device timezone', () {
        final result = repository.getDeviceTimeZone();
        expect(result, isNotEmpty);
      });
    });
  });
}

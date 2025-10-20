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

    group('syncToFirestore', () {
      test('syncs preferences to Firestore successfully', () async {
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc('user123')).thenReturn(mockDoc);
        when(() => mockDoc.collection('preferences')).thenReturn(mockCollection);
        when(() => mockCollection.doc('locale')).thenReturn(mockDoc);
        when(() => mockDoc.set(any(), any())).thenAnswer((_) async {});

        final preferences = const LocalePreferencesEntity(
          locale: Locale('de'),
          country: 'Germany',
          timeZone: 'Europe/Berlin',
          lastSyncedAt: null,
        );

        await repository.syncToFirestore('user123', preferences);

        verify(() => mockFirestore.collection('users')).called(1);
        verify(() => mockDoc.set(any(), any())).called(1);
      });

      test('throws exception when Firestore sync fails', () async {
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc('user123')).thenReturn(mockDoc);
        when(() => mockDoc.collection('preferences')).thenReturn(mockCollection);
        when(() => mockCollection.doc('locale')).thenReturn(mockDoc);
        when(() => mockDoc.set(any(), any()))
            .thenThrow(Exception('Network error'));

        final preferences = const LocalePreferencesEntity(
          locale: Locale('de'),
          country: 'Germany',
          timeZone: 'Europe/Berlin',
          lastSyncedAt: null,
        );

        expect(
          () => repository.syncToFirestore('user123', preferences),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('loadFromFirestore', () {
      test('loads preferences from Firestore successfully', () async {
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc('user123')).thenReturn(mockDoc);
        when(() => mockDoc.collection('preferences')).thenReturn(mockCollection);
        when(() => mockCollection.doc('locale')).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'language': 'it',
          'country': 'Italy',
          'timeZone': 'Europe/Rome',
          'lastSyncedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        });

        final result = await repository.loadFromFirestore('user123');

        expect(result, isNotNull);
        expect(result!.locale, const Locale('it'));
        expect(result.country, 'Italy');
        expect(result.timeZone, 'Europe/Rome');
      });

      test('returns null when Firestore document does not exist', () async {
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc('user123')).thenReturn(mockDoc);
        when(() => mockDoc.collection('preferences')).thenReturn(mockCollection);
        when(() => mockCollection.doc('locale')).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(false);

        final result = await repository.loadFromFirestore('user123');

        expect(result, isNull);
      });

      test('returns null when Firestore document data is null', () async {
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();
        final mockSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc('user123')).thenReturn(mockDoc);
        when(() => mockDoc.collection('preferences')).thenReturn(mockCollection);
        when(() => mockCollection.doc('locale')).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn(null);

        final result = await repository.loadFromFirestore('user123');

        expect(result, isNull);
      });

      test('throws exception when Firestore load fails', () async {
        final mockCollection = MockCollectionReference();
        final mockDoc = MockDocumentReference();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc('user123')).thenReturn(mockDoc);
        when(() => mockDoc.collection('preferences')).thenReturn(mockCollection);
        when(() => mockCollection.doc('locale')).thenReturn(mockDoc);
        when(() => mockDoc.get()).thenThrow(Exception('Network error'));

        expect(
          () => repository.loadFromFirestore('user123'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Error Handling', () {
      test('loadPreferences handles corrupted data gracefully', () async {
        when(() => mockSharedPreferences.getString('user_locale_language'))
            .thenReturn('invalid_locale_code_that_is_very_long');
        when(() => mockSharedPreferences.getString('user_locale_country'))
            .thenReturn('Country Name');

        final result = await repository.loadPreferences();

        // Should still return a valid entity
        expect(result.locale.languageCode, 'invalid_locale_code_that_is_very_long');
        expect(result.country, 'Country Name');
      });

      test('savePreferences handles SharedPreferences failure', () async {
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenThrow(Exception('Storage full'));

        final preferences = const LocalePreferencesEntity(
          locale: Locale('fr'),
          country: 'France',
          timeZone: 'Europe/Paris',
          lastSyncedAt: null,
        );

        expect(
          () => repository.savePreferences(preferences),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

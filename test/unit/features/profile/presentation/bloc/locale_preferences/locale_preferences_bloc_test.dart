// Validates LocalePreferencesBloc emits correct states during preference updates

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_state.dart';

class MockLocalePreferencesRepository extends Mock
    implements LocalePreferencesRepository {}

class FakeLocalePreferencesEntity extends Fake
    implements LocalePreferencesEntity {}

void main() {
  late MockLocalePreferencesRepository mockRepository;
  late LocalePreferencesBloc bloc;

  final testPreferences = LocalePreferencesEntity.defaultPreferences();

  setUpAll(() {
    registerFallbackValue(FakeLocalePreferencesEntity());
  });

  setUp(() {
    mockRepository = MockLocalePreferencesRepository();
    when(() => mockRepository.getDeviceTimeZone()).thenReturn('America/New_York');
  });

  tearDown(() {
    bloc.close();
  });

  group('LocalePreferencesBloc', () {
    test('initial state is LocalePreferencesInitial', () {
      bloc = LocalePreferencesBloc(repository: mockRepository);
      expect(bloc.state, const LocalePreferencesState.initial());
    });

    group('LoadPreferences', () {
      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'emits [loading, loaded] when preferences are loaded successfully',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) =>
            bloc.add(const LocalePreferencesEvent.loadPreferences()),
        expect: () => [
          const LocalePreferencesState.loading(),
          LocalePreferencesState.loaded(
            preferences: testPreferences.copyWith(timeZone: 'America/New_York'),
            hasUnsavedChanges: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.loadPreferences()).called(1);
          verify(() => mockRepository.getDeviceTimeZone()).called(1);
        },
      );

      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'emits [loading, error] when loading fails',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenThrow(Exception('Failed to load'));
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) =>
            bloc.add(const LocalePreferencesEvent.loadPreferences()),
        expect: () => [
          const LocalePreferencesState.loading(),
          const LocalePreferencesState.error(
            message: 'Failed to load preferences: Exception: Failed to load',
          ),
        ],
      );
    });

    group('UpdateLanguage', () {
      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'updates locale and sets hasUnsavedChanges=true',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) {
          bloc.add(const LocalePreferencesEvent.loadPreferences());
          return bloc.stream.firstWhere((state) => state is LocalePreferencesLoaded).then(
                (_) => bloc.add(
                  const LocalePreferencesEvent.updateLanguage(Locale('es')),
                ),
              );
        },
        skip: 2, // Skip loading states
        expect: () => [
          LocalePreferencesState.loaded(
            preferences: testPreferences.copyWith(
              locale: const Locale('es'),
              timeZone: 'America/New_York',
            ),
            hasUnsavedChanges: true,
          ),
        ],
      );
    });

    group('UpdateCountry', () {
      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'updates country and sets hasUnsavedChanges=true',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) {
          bloc.add(const LocalePreferencesEvent.loadPreferences());
          return bloc.stream.firstWhere((state) => state is LocalePreferencesLoaded).then(
                (_) => bloc.add(
                  const LocalePreferencesEvent.updateCountry('Canada'),
                ),
              );
        },
        skip: 2, // Skip loading states
        expect: () => [
          LocalePreferencesState.loaded(
            preferences: testPreferences.copyWith(
              country: 'Canada',
              timeZone: 'America/New_York',
            ),
            hasUnsavedChanges: true,
          ),
        ],
      );
    });

    group('SavePreferences', () {
      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'emits [saving, saved, loaded] when preferences are saved successfully',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          when(() => mockRepository.savePreferences(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.syncToFirestore(any(), any()))
              .thenAnswer((_) async {});
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) {
          bloc.add(const LocalePreferencesEvent.loadPreferences());
          return bloc.stream.firstWhere((state) => state is LocalePreferencesLoaded).then(
                (_) {
                  bloc.add(const LocalePreferencesEvent.updateLanguage(Locale('es')));
                  return bloc.stream
                      .firstWhere((state) =>
                          state is LocalePreferencesLoaded && state.hasUnsavedChanges)
                      .then(
                        (_) => bloc.add(
                          const LocalePreferencesEvent.savePreferences('user123'),
                        ),
                      );
                },
              );
        },
        skip: 3, // Skip initial loading states and first update
        expect: () => [
          isA<LocalePreferencesSaving>(),
          const LocalePreferencesState.saved(),
          isA<LocalePreferencesLoaded>(),
        ],
        verify: (_) {
          verify(() => mockRepository.savePreferences(any())).called(1);
          verify(() => mockRepository.syncToFirestore('user123', any())).called(1);
        },
      );

      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'emits saved immediately when there are no changes',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) {
          bloc.add(const LocalePreferencesEvent.loadPreferences());
          return bloc.stream.firstWhere((state) => state is LocalePreferencesLoaded).then(
                (_) => bloc.add(
                  const LocalePreferencesEvent.savePreferences('user123'),
                ),
              );
        },
        skip: 2, // Skip loading states
        expect: () => [
          const LocalePreferencesState.saved(),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.savePreferences(any()));
          verifyNever(() => mockRepository.syncToFirestore(any(), any()));
        },
      );

      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'emits [saving, error] when savePreferences fails',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          when(() => mockRepository.savePreferences(any()))
              .thenThrow(Exception('Failed to save'));
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) {
          bloc.add(const LocalePreferencesEvent.loadPreferences());
          return bloc.stream.firstWhere((state) => state is LocalePreferencesLoaded).then(
                (_) {
                  bloc.add(const LocalePreferencesEvent.updateLanguage(Locale('es')));
                  return bloc.stream
                      .firstWhere((state) =>
                          state is LocalePreferencesLoaded && state.hasUnsavedChanges)
                      .then(
                        (_) => bloc.add(
                          const LocalePreferencesEvent.savePreferences('user123'),
                        ),
                      );
                },
              );
        },
        skip: 3,
        expect: () => [
          isA<LocalePreferencesSaving>(),
          isA<LocalePreferencesError>(),
        ],
      );

      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'emits [saving, error] when syncToFirestore fails',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          when(() => mockRepository.savePreferences(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.syncToFirestore(any(), any()))
              .thenThrow(Exception('Firestore sync failed'));
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) {
          bloc.add(const LocalePreferencesEvent.loadPreferences());
          return bloc.stream.firstWhere((state) => state is LocalePreferencesLoaded).then(
                (_) {
                  bloc.add(const LocalePreferencesEvent.updateCountry('Germany'));
                  return bloc.stream
                      .firstWhere((state) =>
                          state is LocalePreferencesLoaded && state.hasUnsavedChanges)
                      .then(
                        (_) => bloc.add(
                          const LocalePreferencesEvent.savePreferences('user123'),
                        ),
                      );
                },
              );
        },
        skip: 3,
        expect: () => [
          isA<LocalePreferencesSaving>(),
          isA<LocalePreferencesError>(),
        ],
      );
    });

    group('LoadFromFirestore', () {
      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'emits [loading, loaded] when Firestore preferences are loaded successfully',
        build: () {
          final firestorePrefs = testPreferences.copyWith(
            locale: const Locale('fr'),
            country: 'France',
          );
          when(() => mockRepository.loadFromFirestore('user123'))
              .thenAnswer((_) async => firestorePrefs);
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) =>
            bloc.add(const LocalePreferencesEvent.loadFromFirestore('user123')),
        expect: () => [
          const LocalePreferencesState.loading(),
          LocalePreferencesState.loaded(
            preferences: testPreferences.copyWith(
              locale: const Locale('fr'),
              country: 'France',
              timeZone: 'America/New_York',
            ),
            hasUnsavedChanges: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.loadFromFirestore('user123')).called(1);
          verify(() => mockRepository.getDeviceTimeZone()).called(1);
        },
      );

      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'falls back to loadPreferences when Firestore returns null',
        build: () {
          when(() => mockRepository.loadFromFirestore('user123'))
              .thenAnswer((_) async => null);
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) =>
            bloc.add(const LocalePreferencesEvent.loadFromFirestore('user123')),
        expect: () => [
          const LocalePreferencesState.loading(),
          LocalePreferencesState.loaded(
            preferences: testPreferences.copyWith(timeZone: 'America/New_York'),
            hasUnsavedChanges: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.loadFromFirestore('user123')).called(1);
          verify(() => mockRepository.loadPreferences()).called(1);
        },
      );

      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'emits [loading, error] when Firestore load fails',
        build: () {
          when(() => mockRepository.loadFromFirestore('user123'))
              .thenThrow(Exception('Firestore error'));
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) =>
            bloc.add(const LocalePreferencesEvent.loadFromFirestore('user123')),
        expect: () => [
          const LocalePreferencesState.loading(),
          const LocalePreferencesState.error(
            message: 'Failed to load preferences from Firestore: Exception: Firestore error',
          ),
        ],
      );
    });

    group('Edge Cases', () {
      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'does not update when UpdateLanguage is called before loading',
        build: () => LocalePreferencesBloc(repository: mockRepository),
        act: (bloc) => bloc.add(const LocalePreferencesEvent.updateLanguage(Locale('es'))),
        expect: () => [],
      );

      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'does not update when UpdateCountry is called before loading',
        build: () => LocalePreferencesBloc(repository: mockRepository),
        act: (bloc) => bloc.add(const LocalePreferencesEvent.updateCountry('Spain')),
        expect: () => [],
      );

      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'tracks hasUnsavedChanges correctly across multiple updates',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) async {
          bloc.add(const LocalePreferencesEvent.loadPreferences());
          await bloc.stream.firstWhere((state) => state is LocalePreferencesLoaded);

          bloc.add(const LocalePreferencesEvent.updateLanguage(Locale('es')));
          await bloc.stream.firstWhere((state) =>
              state is LocalePreferencesLoaded && state.hasUnsavedChanges);

          bloc.add(const LocalePreferencesEvent.updateCountry('Spain'));
        },
        skip: 2, // Skip initial loading
        expect: () => [
          LocalePreferencesState.loaded(
            preferences: testPreferences.copyWith(
              locale: const Locale('es'),
              timeZone: 'America/New_York',
            ),
            hasUnsavedChanges: true,
          ),
          LocalePreferencesState.loaded(
            preferences: testPreferences.copyWith(
              locale: const Locale('es'),
              country: 'Spain',
              timeZone: 'America/New_York',
            ),
            hasUnsavedChanges: true,
          ),
        ],
      );

      blocTest<LocalePreferencesBloc, LocalePreferencesState>(
        'resets hasUnsavedChanges to false when changing back to original values',
        build: () {
          when(() => mockRepository.loadPreferences())
              .thenAnswer((_) async => testPreferences);
          return LocalePreferencesBloc(repository: mockRepository);
        },
        act: (bloc) async {
          bloc.add(const LocalePreferencesEvent.loadPreferences());
          await bloc.stream.firstWhere((state) => state is LocalePreferencesLoaded);

          bloc.add(const LocalePreferencesEvent.updateLanguage(Locale('es')));
          await bloc.stream.firstWhere((state) =>
              state is LocalePreferencesLoaded && state.hasUnsavedChanges);

          // Change back to original
          bloc.add(const LocalePreferencesEvent.updateLanguage(Locale('en')));
        },
        skip: 2, // Skip initial loading
        expect: () => [
          LocalePreferencesState.loaded(
            preferences: testPreferences.copyWith(
              locale: const Locale('es'),
              timeZone: 'America/New_York',
            ),
            hasUnsavedChanges: true,
          ),
          LocalePreferencesState.loaded(
            preferences: testPreferences.copyWith(timeZone: 'America/New_York'),
            hasUnsavedChanges: false,
          ),
        ],
      );
    });
  });
}

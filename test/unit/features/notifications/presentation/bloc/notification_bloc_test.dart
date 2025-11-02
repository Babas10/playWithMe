// Validates NotificationBloc state management and event handling

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/notifications/domain/entities/notification_preferences_entity.dart';
import 'package:play_with_me/features/notifications/domain/repositories/notification_repository.dart';
import 'package:play_with_me/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:play_with_me/features/notifications/presentation/bloc/notification_event.dart';
import 'package:play_with_me/features/notifications/presentation/bloc/notification_state.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

// Create a fake class for registration with Mocktail
class FakeNotificationPreferencesEntity extends Fake implements NotificationPreferencesEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeNotificationPreferencesEntity());
  });

  group('NotificationBloc', () {
    test('initial state is NotificationState.initial()', () {
      final mockRepository = MockNotificationRepository();
      final bloc = NotificationBloc(repository: mockRepository);
      expect(bloc.state, const NotificationState.initial());
      bloc.close();
    });

    group('LoadPreferences', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits [loading, loaded] when loading preferences succeeds',
        build: () {
          final mockRepository = MockNotificationRepository();
          when(() => mockRepository.getPreferences()).thenAnswer(
            (_) async => const NotificationPreferencesEntity(),
          );
          return NotificationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const NotificationEvent.loadPreferences()),
        expect: () => [
          const NotificationState.loading(),
          const NotificationState.loaded(NotificationPreferencesEntity()),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [loading, error] when loading preferences fails',
        build: () {
          final mockRepository = MockNotificationRepository();
          when(() => mockRepository.getPreferences()).thenThrow(
            Exception('Failed to load'),
          );
          return NotificationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const NotificationEvent.loadPreferences()),
        expect: () => [
          const NotificationState.loading(),
          predicate<NotificationState>((state) {
            return state.maybeWhen(
              error: (message) => message.contains('Failed to load'),
              orElse: () => false,
            );
          }),
        ],
      );
    });

    group('UpdatePreferences', () {
      const initialPreferences = NotificationPreferencesEntity();
      const updatedPreferences = NotificationPreferencesEntity(
        groupInvitations: false,
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [updating, loaded] when update succeeds',
        build: () {
          final mockRepository = MockNotificationRepository();
          when(() => mockRepository.updatePreferences(any())).thenAnswer(
            (_) async => {},
          );
          return NotificationBloc(repository: mockRepository);
        },
        seed: () => const NotificationState.loaded(initialPreferences),
        act: (bloc) => bloc.add(
          const NotificationEvent.updatePreferences(updatedPreferences),
        ),
        expect: () => [
          const NotificationState.updating(updatedPreferences),
          const NotificationState.loaded(updatedPreferences),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [updating, error, loaded] when update fails',
        build: () {
          final mockRepository = MockNotificationRepository();
          when(() => mockRepository.updatePreferences(any())).thenThrow(
            Exception('Update failed'),
          );
          return NotificationBloc(repository: mockRepository);
        },
        seed: () => const NotificationState.loaded(initialPreferences),
        act: (bloc) => bloc.add(
          const NotificationEvent.updatePreferences(updatedPreferences),
        ),
        expect: () => [
          const NotificationState.updating(updatedPreferences),
          predicate<NotificationState>((state) {
            return state.maybeWhen(
              error: (message) => message.contains('Update failed'),
              orElse: () => false,
            );
          }),
          const NotificationState.loaded(initialPreferences),
        ],
      );
    });

    group('Toggle Events', () {
      const initialPreferences = NotificationPreferencesEntity();

      blocTest<NotificationBloc, NotificationState>(
        'toggleGroupInvitations updates preferences correctly',
        build: () {
          final mockRepository = MockNotificationRepository();
          when(() => mockRepository.updatePreferences(any())).thenAnswer(
            (_) async => {},
          );
          return NotificationBloc(repository: mockRepository);
        },
        seed: () => const NotificationState.loaded(initialPreferences),
        act: (bloc) => bloc.add(
          const NotificationEvent.toggleGroupInvitations(false),
        ),
        expect: () => [
          const NotificationState.updating(
            NotificationPreferencesEntity(groupInvitations: false),
          ),
          const NotificationState.loaded(
            NotificationPreferencesEntity(groupInvitations: false),
          ),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'toggleQuietHours updates preferences correctly',
        build: () {
          final mockRepository = MockNotificationRepository();
          when(() => mockRepository.updatePreferences(any())).thenAnswer(
            (_) async => {},
          );
          return NotificationBloc(repository: mockRepository);
        },
        seed: () => const NotificationState.loaded(initialPreferences),
        act: (bloc) => bloc.add(
          const NotificationEvent.toggleQuietHours(
            enabled: true,
            start: '22:00',
            end: '08:00',
          ),
        ),
        expect: () => [
          const NotificationState.updating(
            NotificationPreferencesEntity(
              quietHoursEnabled: true,
              quietHoursStart: '22:00',
              quietHoursEnd: '08:00',
            ),
          ),
          const NotificationState.loaded(
            NotificationPreferencesEntity(
              quietHoursEnabled: true,
              quietHoursStart: '22:00',
              quietHoursEnd: '08:00',
            ),
          ),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'toggleGroupSpecific updates preferences correctly',
        build: () {
          final mockRepository = MockNotificationRepository();
          when(() => mockRepository.updatePreferences(any())).thenAnswer(
            (_) async => {},
          );
          return NotificationBloc(repository: mockRepository);
        },
        seed: () => const NotificationState.loaded(initialPreferences),
        act: (bloc) => bloc.add(
          const NotificationEvent.toggleGroupSpecific(
            groupId: 'group1',
            enabled: false,
          ),
        ),
        expect: () => [
          const NotificationState.updating(
            NotificationPreferencesEntity(
              groupSpecific: {'group1': false},
            ),
          ),
          const NotificationState.loaded(
            NotificationPreferencesEntity(
              groupSpecific: {'group1': false},
            ),
          ),
        ],
      );
    });
  });
}

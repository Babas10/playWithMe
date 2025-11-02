import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC for managing notification preferences
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc({
    required NotificationRepository repository,
  })  : _repository = repository,
        super(const NotificationState.initial()) {
    on<NotificationEvent>((event, emit) async {
      await event.when(
        loadPreferences: () => _handleLoadPreferences(emit),
        updatePreferences: (preferences) => _handleUpdatePreferences(emit, preferences),
        toggleGroupInvitations: (enabled) => _handleToggle(
          emit,
          (prefs) => prefs.copyWith(groupInvitations: enabled),
        ),
        toggleInvitationAccepted: (enabled) => _handleToggle(
          emit,
          (prefs) => prefs.copyWith(invitationAccepted: enabled),
        ),
        toggleGameCreated: (enabled) => _handleToggle(
          emit,
          (prefs) => prefs.copyWith(gameCreated: enabled),
        ),
        toggleMemberJoined: (enabled) => _handleToggle(
          emit,
          (prefs) => prefs.copyWith(memberJoined: enabled),
        ),
        toggleMemberLeft: (enabled) => _handleToggle(
          emit,
          (prefs) => prefs.copyWith(memberLeft: enabled),
        ),
        toggleRoleChanged: (enabled) => _handleToggle(
          emit,
          (prefs) => prefs.copyWith(roleChanged: enabled),
        ),
        toggleQuietHours: (enabled, start, end) => _handleToggle(
          emit,
          (prefs) => prefs.copyWith(
            quietHoursEnabled: enabled,
            quietHoursStart: start,
            quietHoursEnd: end,
          ),
        ),
        toggleGroupSpecific: (groupId, enabled) => _handleToggleGroupSpecific(
          emit,
          groupId,
          enabled,
        ),
      );
    });
  }

  Future<void> _handleLoadPreferences(Emitter<NotificationState> emit) async {
    emit(const NotificationState.loading());
    try {
      final preferences = await _repository.getPreferences();
      emit(NotificationState.loaded(preferences));
    } catch (e) {
      emit(NotificationState.error(e.toString()));
    }
  }

  Future<void> _handleUpdatePreferences(
    Emitter<NotificationState> emit,
    NotificationPreferencesEntity preferences,
  ) async {
    final currentState = state;

    emit(NotificationState.updating(preferences));
    try {
      await _repository.updatePreferences(preferences);
      emit(NotificationState.loaded(preferences));
    } catch (e) {
      emit(NotificationState.error(e.toString()));
      // Restore previous state on error
      currentState.when(
        initial: () {},
        loading: () {},
        loaded: (prefs) => emit(NotificationState.loaded(prefs)),
        updating: (prefs) => emit(NotificationState.loaded(prefs)),
        error: (_) {},
      );
    }
  }

  Future<void> _handleToggle(
    Emitter<NotificationState> emit,
    NotificationPreferencesEntity Function(NotificationPreferencesEntity) updateFn,
  ) async {
    final currentState = state;

    await currentState.when(
      initial: () async {},
      loading: () async {},
      loaded: (preferences) async {
        final updated = updateFn(preferences);
        await _handleUpdatePreferences(emit, updated);
      },
      updating: (preferences) async {
        final updated = updateFn(preferences);
        await _handleUpdatePreferences(emit, updated);
      },
      error: (_) async {},
    );
  }

  Future<void> _handleToggleGroupSpecific(
    Emitter<NotificationState> emit,
    String groupId,
    bool enabled,
  ) async {
    await _handleToggle(
      emit,
      (prefs) {
        final groupSpecific = Map<String, bool>.from(prefs.groupSpecific);
        groupSpecific[groupId] = enabled;
        return prefs.copyWith(groupSpecific: groupSpecific);
      },
    );
  }
}

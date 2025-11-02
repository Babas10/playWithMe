import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/notification_preferences_entity.dart';

part 'notification_state.freezed.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = _Initial;
  const factory NotificationState.loading() = _Loading;
  const factory NotificationState.loaded(NotificationPreferencesEntity preferences) = _Loaded;
  const factory NotificationState.updating(NotificationPreferencesEntity preferences) = _Updating;
  const factory NotificationState.error(String message) = _Error;
}

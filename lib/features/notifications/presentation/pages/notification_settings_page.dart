import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/repositories/notification_repository.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

/// Screen for managing notification preferences
class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc(
        repository: GetIt.instance<NotificationRepository>(),
      )..add(const NotificationEvent.loadPreferences()),
      child: const _NotificationSettingsView(),
    );
  }
}

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Initializing...')),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (preferences) => ListView(
              children: [
                // Group Events Section
                _SectionHeader(title: 'Group Events'),
                SwitchListTile(
                  title: const Text('Group Invitations'),
                  subtitle: const Text('When someone invites you to a group'),
                  value: preferences.groupInvitations,
                  onChanged: (value) {
                    context.read<NotificationBloc>().add(
                          NotificationEvent.toggleGroupInvitations(value),
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('Invitation Accepted'),
                  subtitle: const Text('When someone accepts your invitation'),
                  value: preferences.invitationAccepted,
                  onChanged: (value) {
                    context.read<NotificationBloc>().add(
                          NotificationEvent.toggleInvitationAccepted(value),
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('New Games'),
                  subtitle: const Text('When a new game is created in your groups'),
                  value: preferences.gameCreated,
                  onChanged: (value) {
                    context.read<NotificationBloc>().add(
                          NotificationEvent.toggleGameCreated(value),
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('Role Changes'),
                  subtitle: const Text('When you are promoted to admin'),
                  value: preferences.roleChanged,
                  onChanged: (value) {
                    context.read<NotificationBloc>().add(
                          NotificationEvent.toggleRoleChanged(value),
                        );
                  },
                ),

                const Divider(height: 32),

                // Admin Notifications Section
                _SectionHeader(title: 'Admin Notifications'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Only receive these if you are an admin',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Member Joined'),
                  subtitle: const Text('When someone joins your group'),
                  value: preferences.memberJoined,
                  onChanged: (value) {
                    context.read<NotificationBloc>().add(
                          NotificationEvent.toggleMemberJoined(value),
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('Member Left'),
                  subtitle: const Text('When someone leaves your group'),
                  value: preferences.memberLeft,
                  onChanged: (value) {
                    context.read<NotificationBloc>().add(
                          NotificationEvent.toggleMemberLeft(value),
                        );
                  },
                ),

                const Divider(height: 32),

                // Quiet Hours Section
                _SectionHeader(title: 'Quiet Hours'),
                SwitchListTile(
                  title: const Text('Enable Quiet Hours'),
                  subtitle: preferences.quietHoursEnabled
                      ? Text(
                          'No notifications from ${preferences.quietHoursStart ?? "22:00"} to ${preferences.quietHoursEnd ?? "08:00"}',
                        )
                      : const Text('Pause notifications during specific times'),
                  value: preferences.quietHoursEnabled,
                  onChanged: (value) {
                    if (value) {
                      // If enabling, show time picker dialog
                      _showQuietHoursDialog(
                        context,
                        preferences.quietHoursStart ?? '22:00',
                        preferences.quietHoursEnd ?? '08:00',
                      );
                    } else {
                      // If disabling, just toggle off
                      context.read<NotificationBloc>().add(
                            NotificationEvent.toggleQuietHours(
                              enabled: false,
                              start: preferences.quietHoursStart,
                              end: preferences.quietHoursEnd,
                            ),
                          );
                    }
                  },
                ),
                if (preferences.quietHoursEnabled)
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Adjust Quiet Hours'),
                    trailing: Text(
                      '${preferences.quietHoursStart} - ${preferences.quietHoursEnd}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      _showQuietHoursDialog(
                        context,
                        preferences.quietHoursStart ?? '22:00',
                        preferences.quietHoursEnd ?? '08:00',
                      );
                    },
                  ),

                const SizedBox(height: 16),
              ],
            ),
            updating: (preferences) => ListView(
              children: [
                const LinearProgressIndicator(),
                _SectionHeader(title: 'Group Events'),
                SwitchListTile(
                  title: const Text('Group Invitations'),
                  subtitle: const Text('When someone invites you to a group'),
                  value: preferences.groupInvitations,
                  onChanged: null, // Disabled during update
                ),
                // Show other switches but disabled
                SwitchListTile(
                  title: const Text('Invitation Accepted'),
                  subtitle: const Text('When someone accepts your invitation'),
                  value: preferences.invitationAccepted,
                  onChanged: null,
                ),
              ],
            ),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $message'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                            const NotificationEvent.loadPreferences(),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showQuietHoursDialog(
    BuildContext context,
    String currentStart,
    String currentEnd,
  ) {
    TimeOfDay startTime = _parseTime(currentStart);
    TimeOfDay endTime = _parseTime(currentEnd);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set Quiet Hours'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('Start Time'),
                trailing: Text(startTime.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null) {
                    setState(() => startTime = picked);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text('End Time'),
                trailing: Text(endTime.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) {
                    setState(() => endTime = picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                    NotificationEvent.toggleQuietHours(
                      enabled: true,
                      start: _formatTime(startTime),
                      end: _formatTime(endTime),
                    ),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

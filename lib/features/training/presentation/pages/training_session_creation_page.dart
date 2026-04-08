// Training session creation page - simplified version for Story 15.4
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_event.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_state.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_details_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class TrainingSessionCreationPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const TrainingSessionCreationPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<TrainingSessionCreationPage> createState() =>
      _TrainingSessionCreationPageState();
}

class _TrainingSessionCreationPageState
    extends State<TrainingSessionCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;
  int _maxParticipants = 10;
  int _minParticipants = 2;

  @override
  void initState() {
    super.initState();
    // Initialize the bloc with the group information
    context.read<TrainingSessionCreationBloc>().add(
      SelectTrainingGroup(groupId: widget.groupId, groupName: widget.groupName),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = now.add(const Duration(days: 1));
    const blue = AppColors.secondary;

    final l10n = AppLocalizations.of(context)!;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: l10n.selectStartDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: Colors.white,
              headerForegroundColor: blue,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return blue;
                return null;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return null;
              }),
              dayShape: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: blue, width: 2),
                  );
                }
                return null;
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return blue;
                return null;
              }),
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return null;
              }),
              todayBorder: const BorderSide(color: Colors.transparent),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return blue;
                return null;
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return null;
              }),
              yearShape: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: blue, width: 2),
                  );
                }
                return null;
              }),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !context.mounted) return;

    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final minPickerTime = isToday ? now : null;
    DateTime pickerTime = isToday
        ? DateTime(
            date.year,
            date.month,
            date.day,
            now.hour,
            now.minute,
          ).add(const Duration(hours: 1))
        : DateTime(date.year, date.month, date.day, 14, 0);

    TimeOfDay? time;

    // ignore: use_build_context_synchronously
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(color: blue, fontSize: 16),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          l10n.selectStartTime,
                          style: const TextStyle(
                            color: blue,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isToday)
                          Text(
                            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${l10n.orLater}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        time = TimeOfDay(
                          hour: pickerTime.hour,
                          minute: pickerTime.minute,
                        );
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        l10n.ok,
                        style: const TextStyle(
                          color: blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: pickerTime,
                  minimumDate: minPickerTime,
                  use24hFormat: true,
                  onDateTimeChanged: (dt) => pickerTime = dt,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (time == null || !mounted) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time!.hour,
      time!.minute,
    );

    setState(() {
      _selectedStartTime = dateTime;
      // Auto-set end time to 2 hours later
      _selectedEndTime = dateTime.add(const Duration(hours: 2));
    });
  }

  Future<void> _selectEndTime(BuildContext context) async {
    const blue = AppColors.secondary;
    final l10n = AppLocalizations.of(context)!;

    if (_selectedStartTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectStartTimeFirst)));
      return;
    }

    // End time must be after start time
    DateTime pickerTime =
        _selectedEndTime ?? _selectedStartTime!.add(const Duration(hours: 2));

    TimeOfDay? time;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(color: blue, fontSize: 16),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          l10n.selectEndTime,
                          style: const TextStyle(
                            color: blue,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')} ${l10n.orLater}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        time = TimeOfDay(
                          hour: pickerTime.hour,
                          minute: pickerTime.minute,
                        );
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        l10n.ok,
                        style: const TextStyle(
                          color: blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: pickerTime,
                  minimumDate: _selectedStartTime,
                  use24hFormat: true,
                  onDateTimeChanged: (dt) => pickerTime = dt,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (time == null || !context.mounted) return;

    final dateTime = DateTime(
      _selectedStartTime!.year,
      _selectedStartTime!.month,
      _selectedStartTime!.day,
      time!.hour,
      time!.minute,
    );

    setState(() {
      _selectedEndTime = dateTime;
    });
  }

  void _handleSubmit(BuildContext context, String userId) {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStartTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectStartTime)));
      return;
    }

    if (_selectedEndTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectEndTime)));
      return;
    }

    final bloc = context.read<TrainingSessionCreationBloc>();

    // Dispatch all form field events
    bloc.add(SetTrainingTitle(title: _titleController.text.trim()));

    if (_descriptionController.text.trim().isNotEmpty) {
      bloc.add(
        SetTrainingDescription(description: _descriptionController.text.trim()),
      );
    }

    bloc.add(
      SetTrainingLocation(locationName: _locationController.text.trim()),
    );
    bloc.add(SetStartTime(startTime: _selectedStartTime!));
    bloc.add(SetEndTime(endTime: _selectedEndTime!));
    bloc.add(SetMinParticipants(minParticipants: _minParticipants));
    bloc.add(SetMaxParticipants(maxParticipants: _maxParticipants));

    // Finally submit
    bloc.add(SubmitTrainingSession(createdBy: userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      TrainingSessionCreationBloc,
      TrainingSessionCreationState
    >(
      listener: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        if (state is TrainingSessionCreationSuccess) {
          // Pop the creation page
          Navigator.of(context).pop();

          // Navigate to the training session details page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TrainingSessionDetailsPage(
                trainingSessionId: state.sessionId,
              ),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.trainingCreatedSuccess),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is TrainingSessionCreationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: PlayWithMeAppBar.build(
              context: context,
              title: l10n.createTrainingSession,
            ),
            body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, authState) {
                if (authState is! AuthenticationAuthenticated) {
                  return Center(child: Text(l10n.pleaseLogInToCreateTraining));
                }

                return BlocBuilder<
                  TrainingSessionCreationBloc,
                  TrainingSessionCreationState
                >(
                  builder: (context, state) {
                    final isLoading =
                        state is TrainingSessionCreationSubmitting;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              widget.groupName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: l10n.title,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.fitness_center),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.pleaseEnterTitle;
                                }
                                return null;
                              },
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: l10n.descriptionOptional,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.description),
                              ),
                              maxLines: 3,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: l10n.location,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.location_on),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.pleaseEnterLocation;
                                }
                                return null;
                              },
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: Text(l10n.startTime),
                              subtitle: Text(
                                _selectedStartTime != null
                                    ? '${_selectedStartTime!.day}/${_selectedStartTime!.month}/${_selectedStartTime!.year} at ${_selectedStartTime!.hour}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}'
                                    : l10n.notSelected,
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: isLoading
                                  ? null
                                  : () => _selectStartTime(context),
                              tileColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: Text(l10n.endTime),
                              subtitle: Text(
                                _selectedEndTime != null
                                    ? '${_selectedEndTime!.day}/${_selectedEndTime!.month}/${_selectedEndTime!.year} at ${_selectedEndTime!.hour}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}'
                                    : l10n.notSelected,
                              ),
                              trailing: const Icon(Icons.access_time),
                              onTap: isLoading
                                  ? null
                                  : () => _selectEndTime(context),
                              tileColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.minParticipantsLabel,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      Slider(
                                        value: _minParticipants.toDouble(),
                                        min: 2,
                                        max: 20,
                                        divisions: 18,
                                        label: _minParticipants.toString(),
                                        onChanged: isLoading
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _minParticipants = value
                                                      .toInt();
                                                  if (_minParticipants >
                                                      _maxParticipants) {
                                                    _maxParticipants =
                                                        _minParticipants;
                                                  }
                                                });
                                              },
                                      ),
                                      Text(
                                        '$_minParticipants',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.maxParticipantsLabel,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      Slider(
                                        value: _maxParticipants.toDouble(),
                                        min: 2,
                                        max: 20,
                                        divisions: 18,
                                        label: _maxParticipants.toString(),
                                        onChanged: isLoading
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _maxParticipants = value
                                                      .toInt();
                                                  if (_maxParticipants <
                                                      _minParticipants) {
                                                    _minParticipants =
                                                        _maxParticipants;
                                                  }
                                                });
                                              },
                                      ),
                                      Text(
                                        '$_maxParticipants',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _handleSubmit(
                                      context,
                                      authState.user.uid,
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.createTrainingSession),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

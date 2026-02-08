// Game creation page for creating new games with form validation and group selection.

import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

import '../../../../core/domain/repositories/game_repository.dart';
import '../../../../core/domain/repositories/group_repository.dart';
import '../../../auth/presentation/bloc/authentication/authentication_bloc.dart';
import '../../../auth/presentation/bloc/authentication/authentication_state.dart';
import '../bloc/game_creation/game_creation_bloc.dart';
import '../bloc/game_creation/game_creation_event.dart';
import '../bloc/game_creation/game_creation_state.dart';

class GameCreationPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final GameRepository? gameRepository;
  final GroupRepository? groupRepository;

  const GameCreationPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.gameRepository,
    this.groupRepository,
  });

  @override
  State<GameCreationPage> createState() => _GameCreationPageState();
}

class _GameCreationPageState extends State<GameCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    // Initialize the bloc with the group information
    context.read<GameCreationBloc>().add(SelectGroup(
          groupId: widget.groupId,
          groupName: widget.groupName,
        ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = now.add(const Duration(days: 1));

    final l10n = AppLocalizations.of(context)!;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: l10n.selectGameDate,
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
      helpText: l10n.selectGameTime,
    );

    if (time == null || !mounted) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedDateTime = dateTime;
    });

    context.read<GameCreationBloc>().add(SetDateTime(dateTime: dateTime));
  }

  void _handleSubmit(BuildContext context, String userId) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Update all form fields in the bloc
    final bloc = context.read<GameCreationBloc>();
    bloc.add(SetTitle(title: _titleController.text.trim()));
    if (_descriptionController.text.trim().isNotEmpty) {
      bloc.add(SetDescription(description: _descriptionController.text.trim()));
    }
    bloc.add(SetLocation(
      locationName: _locationController.text.trim(),
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
    ));

    if (_selectedDateTime != null) {
      bloc.add(SetDateTime(dateTime: _selectedDateTime!));
    }

    // Validate and submit
    bloc.add(ValidateForm());
    bloc.add(SubmitGame(createdBy: userId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: l10n.createGame,
      ),
      body: BlocConsumer<GameCreationBloc, GameCreationState>(
        listener: (context, state) {
          if (state is GameCreationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.gameCreatedSuccess),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.of(context).pop(state.game);
              }
            });
          } else if (state is GameCreationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, creationState) {
          final isSubmitting = creationState is GameCreationSubmitting;

          return BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, authState) {
              if (authState is! AuthenticationAuthenticated) {
                return Center(
                  child: Text(l10n.pleaseLogInToCreateGame),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Group Info (read-only)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.group),
                          title: Text(l10n.group),
                          subtitle: Text(widget.groupName),
                          trailing: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Game Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: l10n.gameTitle,
                          hintText: l10n.gameTitleHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.sports_volleyball),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseTitleRequired;
                          }
                          if (value.trim().length < 3) {
                            return l10n.titleMinLength;
                          }
                          if (value.trim().length > 100) {
                            return l10n.titleMaxLength;
                          }
                          return null;
                        },
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 16),

                      // Description (Optional)
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.descriptionOptional,
                          hintText: l10n.gameDescriptionHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 3,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 16),

                      // Date and Time
                      ListTile(
                        title: Text(l10n.dateTime),
                        subtitle: _selectedDateTime != null
                            ? Text(
                                '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} at ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                              )
                            : Text(l10n.tapToSelect),
                        leading: const Icon(Icons.calendar_today),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: isSubmitting ? null : () => _selectDateTime(context),
                        tileColor: _selectedDateTime == null
                            ? Colors.red.withAlpha(26)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _selectedDateTime == null
                                ? Colors.red
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      if (_selectedDateTime == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 8),
                          child: Text(
                            l10n.tapToSelect,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: l10n.location,
                          hintText: l10n.locationHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseEnterLocation;
                          }
                          return null;
                        },
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 16),

                      // Address (Optional)
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: l10n.addressOptional,
                          hintText: l10n.addressHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.place),
                        ),
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () => _handleSubmit(context, authState.user.uid),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                l10n.createGame,
                                style: const TextStyle(fontSize: 16),
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
  }
}

// Game creation page for creating new games with form validation and group selection.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Game Date',
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
      helpText: 'Select Game Time',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Game'),
        centerTitle: true,
      ),
      body: BlocConsumer<GameCreationBloc, GameCreationState>(
        listener: (context, state) {
          if (state is GameCreationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Game created successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
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
                return const Center(
                  child: Text('Please log in to create a game'),
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
                          title: const Text('Group'),
                          subtitle: Text(widget.groupName),
                          trailing: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Game Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Game Title',
                          hintText: 'e.g., Beach Volleyball',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sports_volleyball),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a game title';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          if (value.trim().length > 100) {
                            return 'Title must be less than 100 characters';
                          }
                          return null;
                        },
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 16),

                      // Description (Optional)
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Add details about the game...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 16),

                      // Date and Time
                      ListTile(
                        title: const Text('Date & Time'),
                        subtitle: _selectedDateTime != null
                            ? Text(
                                '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} at ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                              )
                            : const Text('Tap to select'),
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
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 8),
                          child: Text(
                            'Please select a date and time',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'e.g., Venice Beach',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 16),

                      // Address (Optional)
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address (Optional)',
                          hintText: 'Full address...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.place),
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
                            : const Text(
                                'Create Game',
                                style: TextStyle(fontSize: 16),
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

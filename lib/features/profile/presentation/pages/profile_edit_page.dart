import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_state.dart';

/// Page for editing user profile information
class ProfileEditPage extends StatelessWidget {
  final UserEntity user;

  const ProfileEditPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileEditBloc(
        authRepository: context.read<AuthRepository>(),
      )..add(ProfileEditEvent.started(
          currentDisplayName: user.displayName ?? user.email,
          currentPhotoUrl: user.photoUrl,
        )),
      child: BlocListener<ProfileEditBloc, ProfileEditState>(
        listener: (context, state) {
          if (state is ProfileEditSuccess) {
            // Get the updated user from AuthRepository
            final authRepository = context.read<AuthRepository>();
            final updatedUser = authRepository.currentUser;

            // Trigger authentication refresh to update user data
            if (updatedUser != null) {
              context.read<AuthenticationBloc>().add(
                    AuthenticationUserChanged(updatedUser),
                  );
            }

            // Show success message and navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ProfileEditError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _ProfileEditContent(user: user),
      ),
    );
  }
}

/// Private widget containing the profile edit form
class _ProfileEditContent extends StatefulWidget {
  final UserEntity user;

  const _ProfileEditContent({required this.user});

  @override
  State<_ProfileEditContent> createState() => _ProfileEditContentState();
}

class _ProfileEditContentState extends State<_ProfileEditContent> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _photoUrlController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user.displayName ?? widget.user.email,
    );
    _photoUrlController = TextEditingController(
      text: widget.user.photoUrl ?? '',
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditBloc, ProfileEditState>(
      builder: (context, state) {
        final isLoading = state is ProfileEditLoading || state is ProfileEditSaving;
        final isSaving = state is ProfileEditSaving;

        return PopScope(
          canPop: !(state is ProfileEditLoaded && state.hasUnsavedChanges),
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && state is ProfileEditLoaded && state.hasUnsavedChanges) {
              final shouldPop = await _showUnsavedChangesDialog(context);
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              centerTitle: true,
              actions: [
                if (state is ProfileEditLoaded && state.hasUnsavedChanges)
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            context
                                .read<ProfileEditBloc>()
                                .add(const ProfileEditEvent.saveRequested());
                          },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: isSaving
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            body: isLoading && state is ProfileEditLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile photo preview
                          Center(
                            child: Stack(
                              children: [
                                _photoUrlController.text.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 56,
                                        backgroundColor:
                                            Theme.of(context).colorScheme.primary,
                                        backgroundImage:
                                            NetworkImage(_photoUrlController.text),
                                        onBackgroundImageError: (_, __) {
                                          // Handle image load error silently
                                        },
                                      )
                                    : CircleAvatar(
                                        radius: 56,
                                        backgroundColor:
                                            Theme.of(context).colorScheme.primary,
                                        child: Icon(
                                          Icons.person,
                                          size: 56,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                if (isSaving)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Display Name Field
                          TextFormField(
                            controller: _displayNameController,
                            enabled: !isSaving,
                            decoration: InputDecoration(
                              labelText: 'Display Name',
                              hintText: 'Enter your display name',
                              prefixIcon: const Icon(Icons.person_outline),
                              errorText: state is ProfileEditLoaded
                                  ? state.displayNameError
                                  : null,
                              border: const OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              context.read<ProfileEditBloc>().add(
                                    ProfileEditEvent.displayNameChanged(value),
                                  );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Photo URL Field
                          TextFormField(
                            controller: _photoUrlController,
                            enabled: !isSaving,
                            decoration: InputDecoration(
                              labelText: 'Photo URL (optional)',
                              hintText: 'Enter a URL to your profile photo',
                              prefixIcon: const Icon(Icons.link),
                              errorText: state is ProfileEditLoaded
                                  ? state.photoUrlError
                                  : null,
                              border: const OutlineInputBorder(),
                              helperText:
                                  'URL should point to an image file (.jpg, .png, etc.)',
                              helperMaxLines: 2,
                            ),
                            keyboardType: TextInputType.url,
                            onChanged: (value) {
                              context.read<ProfileEditBloc>().add(
                                    ProfileEditEvent.photoUrlChanged(value),
                                  );
                            },
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          FilledButton.icon(
                            onPressed: (state is ProfileEditLoaded &&
                                    state.hasUnsavedChanges &&
                                    !isSaving)
                                ? () {
                                    context
                                        .read<ProfileEditBloc>()
                                        .add(const ProfileEditEvent.saveRequested());
                                  }
                                : null,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(isSaving ? 'Saving...' : 'Save Changes'),
                          ),
                          const SizedBox(height: 12),

                          // Cancel Button
                          OutlinedButton.icon(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (state is ProfileEditLoaded &&
                                        state.hasUnsavedChanges) {
                                      final shouldPop =
                                          await _showUnsavedChangesDialog(context);
                                      if (shouldPop && context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel'),
                          ),

                          // Info text
                          const SizedBox(height: 24),
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Changes to your profile will be visible to other users.',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Show dialog for unsaved changes warning
  Future<bool> _showUnsavedChangesDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

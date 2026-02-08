import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/utils/countries.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/locale_preferences/locale_preferences_state.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/profile_edit/profile_edit_state.dart';
import 'package:play_with_me/features/profile/presentation/widgets/avatar_upload_widget.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

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
        authRepository: sl<AuthRepository>(),
        userRepository: sl<UserRepository>(),
      )..add(ProfileEditEvent.started(
          currentDisplayName: user.displayName ?? user.email,
          currentPhotoUrl: user.photoUrl,
        )),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProfileEditBloc, ProfileEditState>(
            listener: (context, state) {
              if (state is ProfileEditSuccess) {
                // Profile saved successfully - now trigger locale preferences save if needed
                final localeState = context.read<LocalePreferencesBloc>().state;
                if (localeState is LocalePreferencesLoaded && localeState.hasUnsavedChanges) {
                  // Locale preferences will be saved separately
                  return;
                }

                // Get the updated user from AuthRepository
                final authRepository = context.read<AuthRepository>();
                final updatedUser = authRepository.currentUser;

                // Trigger authentication refresh to update user data
                if (updatedUser != null) {
                  context.read<AuthenticationBloc>().add(
                        AuthenticationUserChanged(updatedUser),
                      );
                }

                // Check if locale preferences are also being saved
                final localeBloc = context.read<LocalePreferencesBloc>();
                if (localeBloc.state is LocalePreferencesSaving) {
                  // Wait for locale preferences to finish
                  return;
                }

                // Show success message and navigate back
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.settingsUpdatedSuccessfully),
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
          ),
          BlocListener<LocalePreferencesBloc, LocalePreferencesState>(
            listener: (context, state) {
              if (state is LocalePreferencesSaved) {
                // Check if profile edit is also complete
                final profileState = context.read<ProfileEditBloc>().state;
                if (profileState is ProfileEditSuccess ||
                    profileState is! ProfileEditSaving) {
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
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.settingsUpdatedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } else if (state is LocalePreferencesError) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
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
      builder: (context, profileState) {
        return BlocBuilder<LocalePreferencesBloc, LocalePreferencesState>(
          builder: (context, localeState) {
            final isProfileLoading = profileState is ProfileEditLoading || profileState is ProfileEditSaving;
            final isLocaleLoading = localeState is LocalePreferencesLoading || localeState is LocalePreferencesSaving;
            final isLoading = isProfileLoading || isLocaleLoading;
            final isSaving = profileState is ProfileEditSaving || localeState is LocalePreferencesSaving;

            final profileHasChanges = profileState is ProfileEditLoaded && profileState.hasUnsavedChanges;
            final localeHasChanges = localeState is LocalePreferencesLoaded && localeState.hasUnsavedChanges;
            final hasUnsavedChanges = profileHasChanges || localeHasChanges;

            return PopScope(
              canPop: !hasUnsavedChanges,
              onPopInvokedWithResult: (didPop, result) async {
                if (!didPop && hasUnsavedChanges) {
                  final shouldPop = await _showUnsavedChangesDialog(context);
                  if (shouldPop && context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
          child: Scaffold(
            appBar: PlayWithMeAppBar.build(
              context: context,
              title: AppLocalizations.of(context)!.accountSettings,
              extraActions: [
                if (hasUnsavedChanges)
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => _handleSaveAll(context, widget.user.uid),
                    child: Text(
                      AppLocalizations.of(context)!.save,
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
            body: isLoading && (profileState is ProfileEditLoading || localeState is LocalePreferencesLoading)
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Avatar upload widget
                          Center(
                            child: AvatarUploadWidget(
                              currentPhotoUrl: _photoUrlController.text.isEmpty
                                  ? null
                                  : _photoUrlController.text,
                              onPhotoUrlChanged: (newPhotoUrl) {
                                _photoUrlController.text = newPhotoUrl ?? '';
                                context.read<ProfileEditBloc>().add(
                                      ProfileEditEvent.photoUrlChanged(
                                        newPhotoUrl ?? '',
                                      ),
                                    );
                              },
                              enabled: !isSaving,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Display Name Field
                          TextFormField(
                            controller: _displayNameController,
                            enabled: !isSaving,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.displayName,
                              hintText: AppLocalizations.of(context)!.displayNameHint,
                              prefixIcon: const Icon(Icons.person_outline),
                              errorText: profileState is ProfileEditLoaded
                                  ? profileState.displayNameError
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
                          const SizedBox(height: 32),

                          // Preferences Section Header
                          Text(
                            'Preferences',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Language Dropdown
                          DropdownButtonFormField<Locale>(
                            value: localeState is LocalePreferencesLoaded
                                ? localeState.preferences.locale
                                : const Locale('en'),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.preferredLanguage,
                              helperText: 'Select your preferred language',
                              prefixIcon: const Icon(Icons.language),
                              border: const OutlineInputBorder(),
                            ),
                            items: LocalePreferencesEntity.supportedLocales.map((locale) {
                              return DropdownMenuItem(
                                value: locale,
                                child: Text(LocalePreferencesEntity.getLanguageName(locale)),
                              );
                            }).toList(),
                            onChanged: isSaving
                                ? null
                                : (locale) {
                                    if (locale != null) {
                                      context.read<LocalePreferencesBloc>().add(
                                            LocalePreferencesEvent.updateLanguage(locale),
                                          );
                                    }
                                  },
                          ),
                          const SizedBox(height: 16),

                          // Country Dropdown
                          DropdownButtonFormField<String>(
                            value: localeState is LocalePreferencesLoaded
                                ? localeState.preferences.country
                                : 'United States',
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.country,
                              helperText: 'Select your country',
                              prefixIcon: const Icon(Icons.flag),
                              border: const OutlineInputBorder(),
                            ),
                            items: Countries.all.map((country) {
                              return DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              );
                            }).toList(),
                            onChanged: isSaving
                                ? null
                                : (country) {
                                    if (country != null) {
                                      context.read<LocalePreferencesBloc>().add(
                                            LocalePreferencesEvent.updateCountry(country),
                                          );
                                    }
                                  },
                          ),
                          const SizedBox(height: 16),

                          // Time Zone (Read-only)
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.timezone,
                              helperText: 'Automatically detected from your device',
                              prefixIcon: const Icon(Icons.access_time),
                              border: const OutlineInputBorder(),
                            ),
                            initialValue: localeState is LocalePreferencesLoaded
                                ? localeState.preferences.timeZone ?? 'Not detected'
                                : 'Not detected',
                            enabled: false,
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          FilledButton.icon(
                            onPressed: (hasUnsavedChanges && !isSaving)
                                ? () => _handleSaveAll(context, widget.user.uid)
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
                            label: Text(isSaving ? AppLocalizations.of(context)!.saving : AppLocalizations.of(context)!.saveChanges),
                          ),
                          const SizedBox(height: 12),

                          // Cancel Button
                          OutlinedButton.icon(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (hasUnsavedChanges) {
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
                            label: Text(AppLocalizations.of(context)!.cancel),
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
        },
      );
  }

  /// Handle saving both profile and locale preferences
  void _handleSaveAll(BuildContext context, String userId) {
    final profileState = context.read<ProfileEditBloc>().state;
    final localeState = context.read<LocalePreferencesBloc>().state;

    // Trigger save for profile if there are changes
    if (profileState is ProfileEditLoaded && profileState.hasUnsavedChanges) {
      context.read<ProfileEditBloc>().add(const ProfileEditEvent.saveRequested());
    }

    // Trigger save for locale preferences if there are changes
    if (localeState is LocalePreferencesLoaded && localeState.hasUnsavedChanges) {
      context.read<LocalePreferencesBloc>().add(
            LocalePreferencesEvent.savePreferences(userId),
          );
    }
  }

  /// Show dialog for unsaved changes warning
  Future<bool> _showUnsavedChangesDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.stay),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

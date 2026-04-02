import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_state.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';

/// Gender value constants — mirror UserGender JSON values without importing the data layer.
const _kGenderMale = 'male';
const _kGenderFemale = 'female';
const _kGenderNone = 'none';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const RegistrationPage());
  }

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedGender;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: l10n.createAccount,
        showUserActions: false,
      ),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
          } else if (state is RegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.accountCreatedSuccess),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.sports_volleyball,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.joinPlayWithMe,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.createAccountSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AuthFormField(
                  controller: _firstNameController,
                  hintText: l10n.firstNameHint,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.firstNameRequired;
                    }
                    if (value.trim().length < 2) {
                      return l10n.firstNameTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _lastNameController,
                  hintText: l10n.lastNameHint,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.lastNameRequired;
                    }
                    if (value.trim().length < 2) {
                      return l10n.lastNameTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _displayNameController,
                  hintText: l10n.displayNameHintRequired,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.displayNameRequired;
                    }
                    if (value.trim().length < 3) {
                      return l10n.displayNameTooShortInvite;
                    }
                    if (value.trim().length > 30) {
                      return l10n.displayNameTooLongInvite;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _emailController,
                  hintText: l10n.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.emailRequired;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return l10n.validEmailRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // ── Gender selector ──────────────────────────────────────
                Row(
                  children: [
                    Text(
                      l10n.genderSelectionTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: l10n.registrationGenderTooltip,
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: const Duration(seconds: 6),
                      child: const Icon(
                        Icons.help_outline,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: l10n.genderMale,
                        value: _kGenderMale,
                        selected: _selectedGender == _kGenderMale,
                        onTap: () => setState(() => _selectedGender = _kGenderMale),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GenderOption(
                        label: l10n.genderFemale,
                        value: _kGenderFemale,
                        selected: _selectedGender == _kGenderFemale,
                        onTap: () => setState(() => _selectedGender = _kGenderFemale),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GenderOption(
                        label: l10n.genderPreferNotToSay,
                        value: _kGenderNone,
                        selected: _selectedGender == _kGenderNone,
                        onTap: () => setState(() => _selectedGender = _kGenderNone),
                      ),
                    ),
                  ],
                ),
                if (_selectedGender == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      l10n.registrationGenderRequired,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                const SizedBox(height: 20),
                // ── Password ─────────────────────────────────────────────
                AuthFormField(
                  controller: _passwordController,
                  hintText: l10n.passwordHint,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.passwordRequired;
                    }
                    if (value.length < 8) {
                      return l10n.passwordTooShortInvite;
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return l10n.passwordMissingUppercase;
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return l10n.passwordMissingNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    l10n.passwordRequirementsHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                AuthFormField(
                  controller: _confirmPasswordController,
                  hintText: l10n.confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseConfirmPassword;
                    }
                    if (value != _passwordController.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitRegistration(),
                ),
                const SizedBox(height: 24),
                BlocBuilder<RegistrationBloc, RegistrationState>(
                  builder: (context, state) {
                    return AuthButton(
                      text: l10n.createAccount,
                      isLoading: state is RegistrationLoading,
                      onPressed: _submitRegistration,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.alreadyHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.signIn),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.termsAgreement,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitRegistration() {
    // Force-show the gender error if not yet selected.
    if (_selectedGender == null) {
      setState(() {});
    }
    if (_formKey.currentState!.validate() && _selectedGender != null) {
      context.read<RegistrationBloc>().add(
            RegistrationSubmitted(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              displayName: _displayNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              gender: _selectedGender!,
            ),
          );
    }
  }
}

/// Circle-with-label option for the gender selector on the registration page.
class _GenderOption extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.textMuted.withValues(alpha: 0.4),
                width: selected ? 2 : 1,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

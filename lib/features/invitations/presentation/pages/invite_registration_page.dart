// Registration page for users who arrived via an invite link.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_details_page.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

const _kGenderMale = 'male';
const _kGenderFemale = 'female';
const _kGenderNone = 'none';

class InviteRegistrationPage extends StatefulWidget {
  final String token;
  final String groupName;
  final String inviterName;
  final InviteRegistrationBloc? blocOverride;

  const InviteRegistrationPage({
    super.key,
    required this.token,
    required this.groupName,
    required this.inviterName,
    this.blocOverride,
  });

  @override
  State<InviteRegistrationPage> createState() => _InviteRegistrationPageState();
}

class _InviteRegistrationPageState extends State<InviteRegistrationPage> {
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
  bool _genderSubmitAttempted = false;

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

    return BlocProvider<InviteRegistrationBloc>(
      create: (_) =>
          widget.blocOverride ?? GetIt.instance<InviteRegistrationBloc>(),
      child: Builder(
        builder: (blocContext) => Scaffold(
          appBar: AppBar(title: Text(l10n.createAccount)),
          body: BlocListener<InviteRegistrationBloc, InviteRegistrationState>(
            listener: _onStateChange,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGroupContextBanner(blocContext, l10n),
                    const SizedBox(height: 24),
                    _buildFirstNameField(l10n),
                    const SizedBox(height: 16),
                    _buildLastNameField(l10n),
                    const SizedBox(height: 16),
                    _buildDisplayNameField(l10n),
                    const SizedBox(height: 16),
                    _buildEmailField(l10n),
                    const SizedBox(height: 16),
                    _buildPasswordField(l10n),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        l10n.passwordRequirementsHint,
                        style: Theme.of(blocContext).textTheme.bodySmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildConfirmPasswordField(l10n),
                    const SizedBox(height: 16),
                    _buildGenderSelector(l10n),
                    const SizedBox(height: 32),
                    _buildSubmitButton(blocContext, l10n),
                    const SizedBox(height: 16),
                    _buildLoginLink(blocContext, l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupContextBanner(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.createAccountToJoin,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.invitedBy(widget.inviterName),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirstNameField(AppLocalizations l10n) {
    return AuthFormField(
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
    );
  }

  Widget _buildLastNameField(AppLocalizations l10n) {
    return AuthFormField(
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
    );
  }

  Widget _buildDisplayNameField(AppLocalizations l10n) {
    return AuthFormField(
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
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return AuthFormField(
      controller: _emailController,
      hintText: l10n.emailHint,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.email,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.emailRequired;
        }
        if (!RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return l10n.validEmailRequired;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return AuthFormField(
      controller: _passwordController,
      hintText: l10n.passwordHint,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.lock,
      suffixIcon: IconButton(
        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
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
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    return AuthFormField(
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
    );
  }

  Widget _buildGenderSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.genderSelectionTitle,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
        if (_genderSubmitAttempted && _selectedGender == null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              l10n.registrationGenderRequired,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext blocContext, AppLocalizations l10n) {
    return BlocBuilder<InviteRegistrationBloc, InviteRegistrationState>(
      builder: (context, state) {
        final isLoading =
            state is InviteRegistrationCreatingAccount ||
            state is InviteRegistrationJoiningGroup;
        final buttonText = state is InviteRegistrationJoiningGroup
            ? l10n.accountCreatedJoiningGroup
            : state is InviteRegistrationCreatingAccount
            ? l10n.creatingAccount
            : l10n.createAccountAndJoin;

        return AuthButton(
          text: buttonText,
          isLoading: isLoading,
          onPressed: () => _submitRegistration(blocContext),
        );
      },
    );
  }

  Widget _buildLoginLink(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
        child: Text(l10n.alreadyHaveAccountLogin),
      ),
    );
  }

  void _submitRegistration(BuildContext blocContext) {
    setState(() => _genderSubmitAttempted = true);
    if (_formKey.currentState!.validate() && _selectedGender != null) {
      blocContext.read<InviteRegistrationBloc>().add(
        InviteRegistrationSubmitted(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          displayName: _displayNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          token: widget.token,
          gender: _selectedGender!,
        ),
      );
    }
  }

  void _onStateChange(
    BuildContext context,
    InviteRegistrationState state,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (state is InviteRegistrationFailure) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
    } else if (state is InviteRegistrationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.groupJoinedSuccess(state.groupName)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => GroupDetailsPage(groupId: state.groupId),
        ),
        (route) => route.isFirst,
      );
    } else if (state is InviteRegistrationTokenExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.inviteExpiredDuringRegistration),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}

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
            width: 24,
            height: 24,
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
                ? const Icon(Icons.check, color: Colors.white, size: 14)
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

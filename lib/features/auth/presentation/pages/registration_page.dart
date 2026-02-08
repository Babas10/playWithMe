import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_state.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';

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
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
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
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _displayNameController,
                  hintText: l10n.displayNameOptionalHint,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value != null && value.trim().length > 50) {
                      return l10n.displayNameTooLong;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                    if (value.length < 6) {
                      return l10n.passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 32),
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
    if (_formKey.currentState!.validate()) {
      context.read<RegistrationBloc>().add(
            RegistrationSubmitted(
              email: _emailController.text,
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              displayName: _displayNameController.text.trim().isNotEmpty
                  ? _displayNameController.text.trim()
                  : null,
            ),
          );
    }
  }
}
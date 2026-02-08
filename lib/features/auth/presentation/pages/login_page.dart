import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_state.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: l10n.login,
        showUserActions: false,
      ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
          }
          // Don't pop on success - let AuthenticationBloc handle navigation
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Icon(
                  Icons.sports_volleyball,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.welcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signInToContinue,
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
                  controller: _passwordController,
                  hintText: l10n.passwordHint,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
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
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitLogin(),
                ),
                const SizedBox(height: 24),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return AuthButton(
                      text: l10n.login,
                      isLoading: state is LoginLoading,
                      onPressed: _submitLogin,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.dontHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: Text(l10n.signUp),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/forgot-password');
                  },
                  child: Text(l10n.forgotPassword),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
            LoginWithEmailAndPasswordSubmitted(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_state.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PasswordResetPage());
  }

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: BlocListener<PasswordResetBloc, PasswordResetState>(
        listener: (context, state) {
          if (state is PasswordResetFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
          } else if (state is PasswordResetSuccess) {
            _showSuccessDialog(state.email);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Forgot Your Password?',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AuthFormField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitPasswordReset(),
                ),
                const SizedBox(height: 24),
                BlocBuilder<PasswordResetBloc, PasswordResetState>(
                  builder: (context, state) {
                    return AuthButton(
                      text: 'Send Reset Email',
                      isLoading: state is PasswordResetLoading,
                      onPressed: _submitPasswordReset,
                    );
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitPasswordReset() {
    if (_formKey.currentState!.validate()) {
      context.read<PasswordResetBloc>().add(
            PasswordResetRequested(email: _emailController.text),
          );
    }
  }

  void _showSuccessDialog(String email) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          title: const Text('Email Sent!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'We\'ve sent a password reset link to:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please check your email and follow the instructions to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to login
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
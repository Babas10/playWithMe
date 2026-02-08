import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_state.dart';

/// Page for email verification flow with status display and resend functionality
class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: 'Email Verification',
      ),
      body: BlocConsumer<EmailVerificationBloc, EmailVerificationState>(
        listener: (context, state) {
          // Show snackbar for email sent state
          if (state is EmailVerificationEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification email sent to ${state.email}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }

          // Show snackbar for error state
          if (state is EmailVerificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: state.when(
                initial: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                verified: (verifiedAt) => _buildVerifiedState(context, verifiedAt),
                pending: (email, emailSent, lastSentAt, cooldown) => _buildPendingState(
                  context,
                  email,
                  emailSent,
                  lastSentAt,
                  cooldown,
                ),
                error: (message, email, wasVerified) => _buildErrorState(
                  context,
                  message,
                  email,
                  wasVerified,
                ),
                emailSent: (email, sentAt, cooldown) => _buildPendingState(
                  context,
                  email,
                  true,
                  sentAt,
                  cooldown,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerifiedState(BuildContext context, DateTime? verifiedAt) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified,
              size: 80,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Email Verified!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your email has been successfully verified.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (verifiedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Verified on: ${_formatDate(verifiedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingState(
    BuildContext context,
    String email,
    bool emailSent,
    DateTime? lastSentAt,
    int cooldown,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Icon and title
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'Verify Your Email',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Email display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    email,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Instructions
          _buildInstructionCard(
            context,
            icon: Icons.looks_one,
            title: 'Check Your Inbox',
            description: emailSent
                ? 'We\'ve sent a verification email to your address.'
                : 'Click the button below to send a verification email.',
          ),
          const SizedBox(height: 16),
          _buildInstructionCard(
            context,
            icon: Icons.looks_two,
            title: 'Click the Link',
            description: 'Open the email and click the verification link.',
          ),
          const SizedBox(height: 16),
          _buildInstructionCard(
            context,
            icon: Icons.looks_3,
            title: 'Refresh Status',
            description: 'Return here and refresh to confirm verification.',
          ),
          const SizedBox(height: 32),

          // Action buttons
          if (!emailSent) ...[
            FilledButton.icon(
              onPressed: () {
                context.read<EmailVerificationBloc>().add(
                      const EmailVerificationEvent.sendVerificationEmail(),
                    );
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Verification Email'),
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: () {
                context.read<EmailVerificationBloc>().add(
                      const EmailVerificationEvent.refreshStatus(),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: cooldown > 0
                  ? null
                  : () {
                      context.read<EmailVerificationBloc>().add(
                            const EmailVerificationEvent.sendVerificationEmail(),
                          );
                    },
              icon: const Icon(Icons.forward_to_inbox),
              label: Text(
                cooldown > 0 ? 'Resend in ${cooldown}s' : 'Resend Email',
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Troubleshooting section
          _buildTroubleshootingSection(context),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    String? email,
    bool? wasVerified,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Something Went Wrong',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              context.read<EmailVerificationBloc>().add(
                    const EmailVerificationEvent.checkStatus(),
                  );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingSection(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(
        'Troubleshooting',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Icon(
        Icons.help_outline,
        color: theme.colorScheme.primary,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTroubleshootingTip(
                context,
                'Check your spam/junk folder',
              ),
              _buildTroubleshootingTip(
                context,
                'Make sure the email address is correct',
              ),
              _buildTroubleshootingTip(
                context,
                'Wait a few minutes for the email to arrive',
              ),
              _buildTroubleshootingTip(
                context,
                'Check your internet connection',
              ),
              const SizedBox(height: 16),
              Text(
                'Still having issues?',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contact support at support@playwithme.com',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTroubleshootingTip(BuildContext context, String tip) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

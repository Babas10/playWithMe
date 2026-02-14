// Landing page for unauthenticated users who opened an invite link.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_state.dart';
import 'package:play_with_me/features/invitations/presentation/pages/invite_registration_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class InviteOnboardingPage extends StatelessWidget {
  final String token;

  const InviteOnboardingPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => context.read<InviteJoinBloc>()
        ..add(ValidateInviteToken(token)),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BlocBuilder<InviteJoinBloc, InviteJoinState>(
              builder: (context, state) {
                if (state is InviteJoinValidating) {
                  return _buildLoadingState(l10n);
                }
                if (state is InviteJoinValidated) {
                  return _buildValidatedState(context, l10n, state);
                }
                if (state is InviteJoinInvalidToken) {
                  return _buildInvalidState(context, l10n, state.reason);
                }
                if (state is InviteJoinError) {
                  return _buildInvalidState(context, l10n, state.message);
                }
                return _buildLoadingState(l10n);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sports_volleyball,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.validatingInvite),
        ],
      ),
    );
  }

  Widget _buildValidatedState(
    BuildContext context,
    AppLocalizations l10n,
    InviteJoinValidated state,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(
          Icons.sports_volleyball,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.inviteOnboardingTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.inviteOnboardingSubtitle,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildGroupCard(context, l10n, state),
        const Spacer(),
        FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => InviteRegistrationPage(
                  token: token,
                  groupName: state.groupName,
                  inviterName: state.inviterName,
                ),
              ),
            );
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(l10n.createAccount),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/login');
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(l10n.iHaveAnAccount),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    AppLocalizations l10n,
    InviteJoinValidated state,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.groupName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.invitedBy(state.inviterName),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.membersCount(state.memberCount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvalidState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.danger,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(l10n.continueToApp),
          ),
        ],
      ),
    );
  }
}

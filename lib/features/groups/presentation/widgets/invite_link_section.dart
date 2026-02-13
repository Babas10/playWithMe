// Widget section for generating and sharing group invite links.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_bloc.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_event.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_state.dart';

class InviteLinkSection extends StatelessWidget {
  final String groupId;

  const InviteLinkSection({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<GroupInviteLinkBloc, GroupInviteLinkState>(
      listener: (context, state) {
        if (state is GroupInviteLinkRevoked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.inviteRevoked),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is GroupInviteLinkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.inviteLinkSectionTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.inviteLinkDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 16),
              _buildContent(context, state, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    GroupInviteLinkState state,
    AppLocalizations l10n,
  ) {
    if (state is GroupInviteLinkLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is GroupInviteLinkGenerated) {
      return _buildGeneratedLinkSection(context, state, l10n);
    }

    // Initial, error, or revoked states show the generate button
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          context.read<GroupInviteLinkBloc>().add(
                GenerateInvite(groupId: groupId),
              );
        },
        icon: const Icon(Icons.link),
        label: Text(l10n.generateInviteLink),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGeneratedLinkSection(
    BuildContext context,
    GroupInviteLinkGenerated state,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Link display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            state.deepLinkUrl,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                  fontFamily: 'monospace',
                ),
          ),
        ),
        const SizedBox(height: 12),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyToClipboard(context, state.deepLinkUrl, l10n),
                icon: const Icon(Icons.copy, size: 18),
                label: Text(l10n.copyLink),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareLink(context, state.deepLinkUrl, l10n),
                icon: const Icon(Icons.share, size: 18),
                label: Text(l10n.shareLink),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Revoke button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              context.read<GroupInviteLinkBloc>().add(
                    RevokeInvite(
                      groupId: groupId,
                      inviteId: state.inviteId,
                    ),
                  );
            },
            icon: const Icon(Icons.link_off, size: 18),
            label: Text(l10n.revokeInvite),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(
    BuildContext context,
    String url,
    AppLocalizations l10n,
  ) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.linkCopied),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareLink(
    BuildContext context,
    String url,
    AppLocalizations l10n,
  ) {
    Share.share(l10n.inviteLinkShareMessage(url));
  }
}

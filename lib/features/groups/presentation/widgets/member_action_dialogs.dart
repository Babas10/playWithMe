// Confirmation dialogs for member management actions
import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

/// Shows a confirmation dialog for promoting a member to admin
Future<bool> showPromoteConfirmationDialog(
  BuildContext context,
  UserModel member,
) async {
  final l10n = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.promoteToAdmin),
          content: Text(
            l10n.promoteConfirmMessage(member.displayName ?? member.email),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.promote),
            ),
          ],
        ),
      ) ??
      false;
}

/// Shows a confirmation dialog for demoting an admin to member
Future<bool> showDemoteConfirmationDialog(
  BuildContext context,
  UserModel member,
) async {
  final l10n = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.demoteToMember),
          content: Text(
            l10n.demoteConfirmMessage(member.displayName ?? member.email),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
              ),
              child: Text(l10n.demote),
            ),
          ],
        ),
      ) ??
      false;
}

/// Shows a confirmation dialog for removing a member from the group
Future<bool> showRemoveMemberConfirmationDialog(
  BuildContext context,
  UserModel member,
) async {
  final l10n = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.removeMember),
          content: Text(
            l10n.removeConfirmMessage(member.displayName ?? member.email),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(l10n.remove),
            ),
          ],
        ),
      ) ??
      false;
}

/// Shows a confirmation dialog for leaving a group
Future<bool> showLeaveGroupConfirmationDialog(
  BuildContext context,
  String groupName,
) async {
  final l10n = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.leaveGroup),
          content: Text(
            l10n.leaveGroupConfirmMessage(groupName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(l10n.leave),
            ),
          ],
        ),
      ) ??
      false;
}

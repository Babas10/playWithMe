// Widget displaying a single group in the list with name, member count, and photo
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class GroupListItem extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onTap;

  const GroupListItem({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Group photo or default icon
              _buildGroupPhoto(),
              const SizedBox(width: 16),

              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (group.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.memberCount(group.memberCount),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(width: 16),
                        if (group.privacy != GroupPrivacy.private) ...[
                          Icon(
                            group.privacy == GroupPrivacy.public
                                ? Icons.public
                                : Icons.lock_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPrivacyLabel(context, group.privacy),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron icon
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupPhoto() {
    if (group.photoUrl != null && group.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(group.photoUrl!),
      );
    }

    // Default group icon
    return CircleAvatar(
      radius: 32,
      backgroundColor: _getGroupColor(),
      child: Text(
        _getGroupInitials(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getGroupInitials() {
    final words = group.name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return group.name.substring(0, group.name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getGroupColor() {
    // Generate a consistent color based on group name
    final hash = group.name.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[hash.abs() % colors.length];
  }

  String _getPrivacyLabel(BuildContext context, GroupPrivacy privacy) {
    final l10n = AppLocalizations.of(context)!;
    switch (privacy) {
      case GroupPrivacy.public:
        return l10n.publicGroup;
      case GroupPrivacy.private:
        return l10n.privateGroup;
      case GroupPrivacy.inviteOnly:
        return l10n.inviteOnlyGroup;
    }
  }
}

// Widget for displaying a single group member with their role
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

class MemberListItem extends StatelessWidget {
  final UserModel user;
  final bool isAdmin;

  const MemberListItem({
    super.key,
    required this.user,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEACE6A).withValues(alpha: 0.25),
        backgroundImage:
            user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null
            ? Text(
                _getInitials(user.displayName ?? user.email),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004E64),
                ),
              )
            : null,
      ),
      title: Text(
        user.displayName ?? user.email,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: user.displayName != null ? Text(user.email) : null,
      trailing: isAdmin
          ? Chip(
              label: const Text(
                'Admin',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: const Color(0xFFEACE6A).withValues(alpha: 0.25),
              labelStyle: TextStyle(
                color: Color(0xFF004E64),
                fontWeight: FontWeight.bold,
              ),
              padding: EdgeInsets.zero,
            )
          : null,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

// Page for inviting friends from My Community to a group
import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/invitation_repository.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/widgets/friend_selector_widget.dart';

class InviteMemberPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final FriendRepository? friendRepository; // For DI and testing
  final GroupRepository? groupRepositoryOverride; // For testing
  final InvitationRepository? invitationRepositoryOverride; // For testing

  const InviteMemberPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.friendRepository,
    this.groupRepositoryOverride,
    this.invitationRepositoryOverride,
  });

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  late final GroupRepository _groupRepository;
  late final InvitationRepository _invitationRepository;
  late final FriendRepository? _friendRepository;

  Set<String> _selectedFriendIds = {};
  List<String> _memberIds = [];
  List<String> _invitedUserIds = [];
  bool _isSendingInvitations = false;

  @override
  void initState() {
    super.initState();
    _groupRepository = widget.groupRepositoryOverride ?? sl<GroupRepository>();
    _invitationRepository = widget.invitationRepositoryOverride ?? sl<InvitationRepository>();
    _friendRepository = widget.friendRepository;
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    try {
      final group = await _groupRepository.getGroupById(widget.groupId);
      if (group != null && mounted) {
        setState(() {
          _memberIds = group.memberIds;
        });
      }
    } catch (e) {
      // Silently fail, we'll still allow selecting friends
    }
  }

  Future<void> _sendInvitations(BuildContext context, String inviterUid, String inviterName) async {
    if (_selectedFriendIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one friend to invite'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    setState(() {
      _isSendingInvitations = true;
    });

    try {
      int successCount = 0;
      int failureCount = 0;

      for (final friendId in _selectedFriendIds) {
        // Skip if already a member
        if (_memberIds.contains(friendId)) {
          continue;
        }

        try {
          await _invitationRepository.sendInvitation(
            groupId: widget.groupId,
            groupName: widget.groupName,
            invitedUserId: friendId,
            invitedBy: inviterUid,
            inviterName: inviterName,
          );
          successCount++;
          _invitedUserIds.add(friendId);
        } catch (e) {
          failureCount++;
          debugPrint('⚠️ Failed to send invitation to $friendId: $e');
        }
      }

      if (mounted) {
        if (successCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                successCount == 1
                    ? 'Invitation sent successfully'
                    : '$successCount invitations sent successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Clear selection and navigate back on success
          setState(() {
            _selectedFriendIds.clear();
          });

          // Navigate back after short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }

        if (failureCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send $failureCount invitation(s)'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingInvitations = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState is! AuthenticationAuthenticated) {
          return Scaffold(
            appBar: PlayWithMeAppBar.build(
              context: context,
              title: 'Invite Members',
              showUserActions: true,
            ),
            body: const Center(
              child: Text('Please log in to invite members'),
            ),
          );
        }

        // Check if FriendRepository is available
        if (_friendRepository == null) {
          return Scaffold(
            appBar: PlayWithMeAppBar.build(
              context: context,
              title: 'Invite Members',
              showUserActions: true,
            ),
            body: const Center(
              child: Text('Friend list not available'),
            ),
          );
        }

        return Scaffold(
          appBar: PlayWithMeAppBar.build(
            context: context,
            title: 'Invite Members',
          ),
          body: Column(
            children: [
              // Info card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Select friends from your community to invite to this group',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Friend selector
              Expanded(
                child: FriendSelectorWidget(
                  currentUserId: authState.user.uid,
                  friendRepository: _friendRepository!,
                  onSelectionChanged: (selectedIds) {
                    setState(() {
                      _selectedFriendIds = selectedIds;
                    });
                  },
                  initialSelection: _selectedFriendIds,
                ),
              ),

              // Send invitations button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: _isSendingInvitations || _selectedFriendIds.isEmpty
                          ? null
                          : () => _sendInvitations(
                                context,
                                authState.user.uid,
                                authState.user.displayName ?? authState.user.email,
                              ),
                      icon: _isSendingInvitations
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isSendingInvitations
                            ? 'Sending...'
                            : _selectedFriendIds.isEmpty
                                ? 'Select friends to invite'
                                : _selectedFriendIds.length == 1
                                    ? 'Send Invitation'
                                    : 'Send ${_selectedFriendIds.length} Invitations',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

// Displays detailed information about a group including members and admin actions
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_event.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_state.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/widgets/member_action_menu.dart';
import 'package:play_with_me/features/groups/presentation/widgets/member_action_dialogs.dart';
import 'package:play_with_me/features/groups/presentation/pages/invite_member_page.dart';

class GroupDetailsPage extends StatelessWidget {
  final String groupId;
  final GroupRepository? groupRepositoryOverride; // For testing
  final UserRepository? userRepositoryOverride; // For testing

  const GroupDetailsPage({
    super.key,
    required this.groupId,
    this.groupRepositoryOverride,
    this.userRepositoryOverride,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GroupMemberBloc>(),
      child: _GroupDetailsPageContent(
        groupId: groupId,
        groupRepositoryOverride: groupRepositoryOverride,
        userRepositoryOverride: userRepositoryOverride,
      ),
    );
  }
}

class _GroupDetailsPageContent extends StatefulWidget {
  final String groupId;
  final GroupRepository? groupRepositoryOverride;
  final UserRepository? userRepositoryOverride;

  const _GroupDetailsPageContent({
    required this.groupId,
    this.groupRepositoryOverride,
    this.userRepositoryOverride,
  });

  @override
  State<_GroupDetailsPageContent> createState() => _GroupDetailsPageContentState();
}

class _GroupDetailsPageContentState extends State<_GroupDetailsPageContent> {
  late final GroupRepository _groupRepository;
  late final UserRepository _userRepository;
  GroupModel? _group;
  List<UserModel> _members = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _groupRepository = widget.groupRepositoryOverride ?? sl<GroupRepository>();
    _userRepository = widget.userRepositoryOverride ?? sl<UserRepository>();
    _loadGroupDetails();
  }

  Future<void> _loadGroupDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load group
      final group = await _groupRepository.getGroupById(widget.groupId);
      if (group == null) {
        setState(() {
          _error = 'Group not found';
          _isLoading = false;
        });
        return;
      }

      // Load members
      final members = await _userRepository.getUsersByIds(group.memberIds);

      setState(() {
        _group = group;
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load group details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleMemberAction(
    BuildContext context,
    MemberAction action,
    UserModel member,
  ) async {
    final confirmed = await _showConfirmationDialog(context, action, member);
    if (!confirmed || !context.mounted) return;

    final groupMemberBloc = context.read<GroupMemberBloc>();

    switch (action) {
      case MemberAction.promote:
        groupMemberBloc.add(PromoteMemberToAdmin(
          groupId: widget.groupId,
          userId: member.uid,
        ));
        break;
      case MemberAction.demote:
        groupMemberBloc.add(DemoteMemberFromAdmin(
          groupId: widget.groupId,
          userId: member.uid,
        ));
        break;
      case MemberAction.remove:
        groupMemberBloc.add(RemoveMemberFromGroup(
          groupId: widget.groupId,
          userId: member.uid,
        ));
        break;
    }
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    MemberAction action,
    UserModel member,
  ) async {
    switch (action) {
      case MemberAction.promote:
        return await showPromoteConfirmationDialog(context, member);
      case MemberAction.demote:
        return await showDemoteConfirmationDialog(context, member);
      case MemberAction.remove:
        return await showRemoveMemberConfirmationDialog(context, member);
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupMemberBloc, GroupMemberState>(
      listener: (context, state) {
        if (state is MemberPromotedSuccess) {
          _showSuccessMessage('Member promoted to admin');
          _loadGroupDetails();
        } else if (state is MemberDemotedSuccess) {
          _showSuccessMessage('Member demoted to regular member');
          _loadGroupDetails();
        } else if (state is MemberRemovedSuccess) {
          _showSuccessMessage('Member removed from group');
          _loadGroupDetails();
        } else if (state is UserLeftGroupSuccess) {
          _showSuccessMessage('You have left the group');
          // Navigate back to group list
          Navigator.of(context).pop();
        } else if (state is GroupMemberError) {
          _showErrorMessage(state.message);
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          if (authState is! AuthenticationAuthenticated) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Group Details'),
              ),
              body: const Center(
                child: Text('Please log in to view group details'),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Group Details'),
              centerTitle: true,
              actions: [
                if (_group != null)
                  _buildAppBarActions(context, authState),
              ],
            ),
            body: _buildBody(context, authState),
            floatingActionButton: _buildFloatingActionButton(context, authState),
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AuthenticationAuthenticated authState) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadGroupDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_group == null) {
      return const Center(
        child: Text('Group not found'),
      );
    }

    final currentUserId = authState.user.uid;
    final isCurrentUserAdmin = _group!.isAdmin(currentUserId);

    return RefreshIndicator(
      onRefresh: _loadGroupDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header
            _buildGroupHeader(context),
            const Divider(),

            // Members section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Members (${_members.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            BlocBuilder<GroupMemberBloc, GroupMemberState>(
              builder: (context, memberState) {
                final isProcessing = memberState is GroupMemberLoading;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    final isAdmin = _group!.isAdmin(member.uid);
                    final isCreator = _group!.createdBy == member.uid;
                    final canDemote = _group!.adminCount > 1;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: member.photoUrl != null
                            ? NetworkImage(member.photoUrl!)
                            : null,
                        child: member.photoUrl == null
                            ? Text(
                                _getInitials(
                                    member.displayName ?? member.email),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            member.displayName ?? member.email,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (isAdmin) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: const Text(
                                'Admin',
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                          if (isCreator) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                          ],
                        ],
                      ),
                      subtitle: member.displayName != null
                          ? Text(member.email)
                          : null,
                      trailing: isCurrentUserAdmin &&
                              member.uid != currentUserId &&
                              !isProcessing
                          ? MemberActionMenu(
                              isCurrentUserAdmin: isCurrentUserAdmin,
                              isTargetUserAdmin: isAdmin,
                              isTargetUserCreator: isCreator,
                              canDemote: canDemote,
                              onActionSelected: (action) =>
                                  _handleMemberAction(context, action, member),
                            )
                          : isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : null,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
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

  Widget _buildGroupHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group name
          Text(
            _group!.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Group description
          if (_group!.description != null && _group!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _group!.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

          // Member count
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${_group!.memberCount} members',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(
      BuildContext context, AuthenticationAuthenticated authState) {
    // Only show invite button to admins
    if (_group == null || !_group!.isAdmin(authState.user.uid)) {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => sl<InvitationBloc>(),
              child: InviteMemberPage(
                groupId: widget.groupId,
                groupName: _group!.name,
              ),
            ),
          ),
        ).then((_) {
          // Refresh group details after returning from invite page
          _loadGroupDetails();
        });
      },
      icon: const Icon(Icons.person_add),
      label: const Text('Invite Member'),
    );
  }

  Widget _buildAppBarActions(
    BuildContext context,
    AuthenticationAuthenticated authState,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'leave') {
          _handleLeaveGroup(context, authState.user.uid);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'leave',
          child: Row(
            children: [
              Icon(Icons.exit_to_app, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Leave Group',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleLeaveGroup(BuildContext context, String userId) async {
    if (_group == null) return;

    final confirmed = await showLeaveGroupConfirmationDialog(
      context,
      _group!.name,
    );

    if (!confirmed || !context.mounted) return;

    context.read<GroupMemberBloc>().add(
          LeaveGroup(
            groupId: widget.groupId,
            userId: userId,
          ),
        );
  }
}

// Displays detailed information about a group including members and admin actions
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
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
import 'package:play_with_me/features/groups/presentation/widgets/member_list_item_with_friendship.dart';
import 'package:play_with_me/features/groups/presentation/widgets/group_bottom_nav_bar.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_bloc.dart';
import 'package:play_with_me/features/games/presentation/pages/game_creation_page.dart';
import 'package:play_with_me/features/games/presentation/pages/games_list_page.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_creation_page.dart';

class GroupDetailsPage extends StatelessWidget {
  final String groupId;
  final GroupRepository? groupRepositoryOverride; // For testing
  final UserRepository? userRepositoryOverride; // For testing
  final GameRepository? gameRepositoryOverride; // For testing

  const GroupDetailsPage({
    super.key,
    required this.groupId,
    this.groupRepositoryOverride,
    this.userRepositoryOverride,
    this.gameRepositoryOverride,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GroupMemberBloc>(),
      child: _GroupDetailsPageContent(
        groupId: groupId,
        groupRepositoryOverride: groupRepositoryOverride,
        userRepositoryOverride: userRepositoryOverride,
        gameRepositoryOverride: gameRepositoryOverride,
      ),
    );
  }
}

class _GroupDetailsPageContent extends StatefulWidget {
  final String groupId;
  final GroupRepository? groupRepositoryOverride;
  final UserRepository? userRepositoryOverride;
  final GameRepository? gameRepositoryOverride;

  const _GroupDetailsPageContent({
    required this.groupId,
    this.groupRepositoryOverride,
    this.userRepositoryOverride,
    this.gameRepositoryOverride,
  });

  @override
  State<_GroupDetailsPageContent> createState() => _GroupDetailsPageContentState();
}

class _GroupDetailsPageContentState extends State<_GroupDetailsPageContent> {
  late final GroupRepository _groupRepository;
  late final UserRepository _userRepository;
  late final FriendRepository _friendRepository;
  late final GameRepository _gameRepository;
  GroupModel? _group;
  List<UserModel> _members = [];
  Map<String, bool> _friendshipStatus = {};
  Map<String, FriendRequestStatus> _requestStatus = {};
  bool _isLoading = true;
  bool _isLoadingFriendships = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _groupRepository = widget.groupRepositoryOverride ?? sl<GroupRepository>();
    _userRepository = widget.userRepositoryOverride ?? sl<UserRepository>();
    _friendRepository = sl<FriendRepository>();
    _gameRepository = widget.gameRepositoryOverride ?? sl<GameRepository>();
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

      // Load friendship status for all members
      await _loadFriendshipStatus();
    } catch (e) {
      setState(() {
        _error = 'Failed to load group details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest(String targetUserId) async {
    try {
      await _friendRepository.sendFriendRequest(targetUserId);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request sent successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Refresh friendship status
      await _loadFriendshipStatus();
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send friend request: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadFriendshipStatus() async {
    if (_members.isEmpty) return;

    final authState = context.read<AuthenticationBloc>().state;
    if (authState is! AuthenticationAuthenticated) return;

    final currentUserId = authState.user.uid;

    // Filter out current user from members list
    final otherMembers = _members
        .where((member) => member.uid != currentUserId)
        .map((member) => member.uid)
        .toList();

    if (otherMembers.isEmpty) {
      setState(() {
        _isLoadingFriendships = false;
      });
      return;
    }

    setState(() {
      _isLoadingFriendships = true;
    });

    try {
      // Batch check friendships
      final friendships =
          await _friendRepository.batchCheckFriendship(otherMembers);

      // Get list of non-friends to check request status
      final nonFriends = otherMembers
          .where((memberId) => !(friendships[memberId] ?? false))
          .toList();

      // Batch check request status for non-friends only
      final Map<String, FriendRequestStatus> requestStatuses = {};
      if (nonFriends.isNotEmpty) {
        try {
          final batchRequestStatuses =
              await _friendRepository.batchCheckFriendRequestStatus(nonFriends);
          requestStatuses.addAll(batchRequestStatuses);
        } catch (e) {
          // If batch check fails, default all non-friends to none
          for (final memberId in nonFriends) {
            requestStatuses[memberId] = FriendRequestStatus.none;
          }
        }
      }

      setState(() {
        _friendshipStatus = friendships;
        _requestStatus = requestStatuses;
        _isLoadingFriendships = false;
      });
    } catch (e) {
      // On error, default to empty status
      setState(() {
        _friendshipStatus = {};
        _requestStatus = {};
        _isLoadingFriendships = false;
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
                // Menu button for Leave Group
                if (_group != null)
                  PopupMenuButton<String>(
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
                  ),
              ],
            ),
            body: _buildBody(context, authState),
            bottomNavigationBar: _group != null
                ? StreamBuilder<int>(
                    stream: _gameRepository.getUpcomingGamesCount(widget.groupId),
                    builder: (context, snapshot) {
                      final gameCount = snapshot.data ?? 0;
                      return GroupBottomNavBar(
                        isAdmin: _group!.isAdmin(authState.user.uid),
                        upcomingGamesCount: gameCount,
                        onInviteTap: () => _navigateToInvitePage(context),
                        onCreateGameTap: () => _navigateToGameCreation(context),
                        onCreateTrainingTap: () =>
                            _navigateToTrainingCreation(context),
                        onGamesListTap: () => _showGamesListComingSoon(context),
                      );
                    },
                  )
                : null,
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
                    final isCurrentUser = member.uid == currentUserId;
                    final isFriend = _friendshipStatus[member.uid] ?? false;
                    final requestStatus =
                        _requestStatus[member.uid] ?? FriendRequestStatus.none;

                    // Show loading indicator while friendship status loads
                    if (_isLoadingFriendships && !isCurrentUser) {
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
                        title: Text(
                          member.displayName ?? member.email,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    return MemberListItemWithFriendship(
                      user: member,
                      isAdmin: isAdmin,
                      isCreator: isCreator,
                      isCurrentUser: isCurrentUser,
                      currentUserId: currentUserId,
                      isFriend: isFriend,
                      requestStatus: requestStatus,
                      onRefresh: _loadFriendshipStatus,
                      onSendFriendRequest: _sendFriendRequest,
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

  void _navigateToInvitePage(BuildContext context) {
    if (_group == null) return;

    // Try to get FriendRepository from DI
    FriendRepository? friendRepository;
    try {
      friendRepository = sl<FriendRepository>();
    } catch (e) {
      // FriendRepository not registered (unlikely in production)
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<InvitationBloc>(),
          child: InviteMemberPage(
            groupId: widget.groupId,
            groupName: _group!.name,
            friendRepository: friendRepository,
          ),
        ),
      ),
    ).then((_) {
      // Refresh group details after returning from invite page
      _loadGroupDetails();
    });
  }

  void _navigateToGameCreation(BuildContext context) {
    if (_group == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<GameCreationBloc>(),
          child: GameCreationPage(
            groupId: widget.groupId,
            groupName: _group!.name,
          ),
        ),
      ),
    );
  }

  void _showGamesListComingSoon(BuildContext context) {
    if (_group == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamesListPage(
          groupId: widget.groupId,
          groupName: _group!.name,
        ),
      ),
    );
  }

  void _navigateToTrainingCreation(BuildContext context) {
    if (_group == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<TrainingSessionCreationBloc>(),
          child: TrainingSessionCreationPage(
            groupId: widget.groupId,
            groupName: _group!.name,
          ),
        ),
      ),
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

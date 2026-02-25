// Displays detailed information about a group including members and admin actions
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
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
import 'package:play_with_me/features/groups/presentation/widgets/member_action_dialogs.dart';
import 'package:play_with_me/features/groups/presentation/pages/invite_member_page.dart';
import 'package:play_with_me/features/groups/presentation/widgets/member_list_item_with_friendship.dart';
import 'package:play_with_me/features/groups/presentation/widgets/group_bottom_nav_bar.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_bloc.dart';
import 'package:play_with_me/features/games/presentation/pages/game_creation_page.dart';
import 'package:play_with_me/features/games/presentation/pages/games_list_page.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_creation_page.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_bloc.dart';
import 'package:play_with_me/features/groups/presentation/widgets/invite_link_section.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<GroupMemberBloc>()),
        BlocProvider(create: (context) => sl<GroupInviteLinkBloc>()),
      ],
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

  /// Tracks which member UIDs were used for the last full data load.
  /// Used to detect when new members join and trigger incremental re-fetches.
  Set<String> _lastLoadedMemberIds = {};

  StreamSubscription<GroupModel?>? _groupSubscription;

  @override
  void initState() {
    super.initState();
    _groupRepository = widget.groupRepositoryOverride ?? sl<GroupRepository>();
    _userRepository = widget.userRepositoryOverride ?? sl<UserRepository>();
    _friendRepository = sl<FriendRepository>();
    _gameRepository = widget.gameRepositoryOverride ?? sl<GameRepository>();
    _subscribeToGroup();
  }

  @override
  void dispose() {
    _groupSubscription?.cancel();
    super.dispose();
  }

  /// Subscribes to the group document stream for real-time updates.
  void _subscribeToGroup() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _groupSubscription?.cancel();
    _groupSubscription = _groupRepository
        .watchGroupById(widget.groupId)
        .listen(
          _onGroupUpdate,
          onError: (Object e) {
            if (mounted) {
              setState(() {
                _error = 'Failed to load group details: $e';
                _isLoading = false;
              });
            }
          },
        );
  }

  /// Called each time the Firestore group document changes.
  void _onGroupUpdate(GroupModel? group) {
    if (!mounted) return;

    if (group == null) {
      setState(() {
        _error = 'Group not found';
        _isLoading = false;
      });
      return;
    }

    final newMemberIds = Set<String>.from(group.memberIds);
    final memberIdsChanged = !setEquals(newMemberIds, _lastLoadedMemberIds);

    setState(() {
      _group = group;
    });

    // Only reload members + friendship data when the member set changes.
    // On first load, _lastLoadedMemberIds is empty so this always triggers.
    if (memberIdsChanged) {
      _loadMembersAndFriendships(group);
    }
  }

  /// Loads member profiles and friendship statuses in parallel using Future.wait.
  Future<void> _loadMembersAndFriendships(GroupModel group) async {
    final authState = context.read<AuthenticationBloc>().state;
    if (authState is! AuthenticationAuthenticated) return;

    final currentUserId = authState.user.uid;
    final otherMemberIds = group.memberIds
        .where((id) => id != currentUserId)
        .toList();

    setState(() {
      _isLoadingFriendships = true;
    });

    try {
      // Fire all three network calls in parallel — the major performance win.
      final results = await Future.wait<dynamic>([
        _userRepository.getUsersByIds(group.memberIds),
        _friendRepository.batchCheckFriendship(otherMemberIds),
        otherMemberIds.isNotEmpty
            ? _friendRepository.batchCheckFriendRequestStatus(otherMemberIds)
            : Future<Map<String, FriendRequestStatus>>.value({}),
      ]);

      if (!mounted) return;

      setState(() {
        _members = results[0] as List<UserModel>;
        _friendshipStatus = results[1] as Map<String, bool>;
        _requestStatus = results[2] as Map<String, FriendRequestStatus>;
        _lastLoadedMemberIds = Set<String>.from(group.memberIds);
        _isLoading = false;
        _isLoadingFriendships = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingFriendships = false;
      });
    }
  }

  /// Forces a full data refresh (used by pull-to-refresh).
  Future<void> _refreshGroupDetails() async {
    // Clear the member-id tracking so _onGroupUpdate always triggers a reload.
    _lastLoadedMemberIds = {};
    if (_group != null) {
      await _loadMembersAndFriendships(_group!);
    } else {
      _subscribeToGroup();
    }
  }

  Future<void> _sendFriendRequest(String targetUserId) async {
    try {
      await _friendRepository.sendFriendRequest(targetUserId);

      if (!mounted) return;

      // Best-effort: invalidate the friendship status cache for this user so
      // the next load reflects the newly sent request immediately.
      try {
        (_friendRepository as dynamic).invalidateFriendshipCacheForUser(targetUserId);
      } catch (_) {
        // Cache invalidation is best-effort; proceed regardless.
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request sent successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Reload friendship statuses to reflect the sent request.
      if (_group != null) {
        await _loadMembersAndFriendships(_group!);
      }
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
          // The Firestore stream will automatically reflect the admin change.
          _showSuccessMessage('Member promoted to admin');
        } else if (state is MemberDemotedSuccess) {
          _showSuccessMessage('Member demoted to regular member');
        } else if (state is MemberRemovedSuccess) {
          // The Firestore stream will push the updated memberIds.
          _showSuccessMessage('Member removed from group');
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
              appBar: PlayWithMeAppBar.build(
                context: context,
                title: 'Group Details',
                showUserActions: true,
              ),
              body: const Center(
                child: Text('Please log in to view group details'),
              ),
            );
          }

          return Scaffold(
            appBar: PlayWithMeAppBar.build(
              context: context,
              title: 'Group Details',
              extraActions: [
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
              onPressed: _subscribeToGroup,
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

    return RefreshIndicator(
      onRefresh: _refreshGroupDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header
            _buildGroupHeader(context),
            const Divider(),

            // Invite link section (visible only for eligible members)
            if (_group!.canUserInviteOthers(currentUserId))
              InviteLinkSection(groupId: widget.groupId),
            if (_group!.canUserInviteOthers(currentUserId))
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
                          backgroundColor: const Color(0xFFEACE6A).withValues(alpha: 0.25),
                          backgroundImage: member.photoUrl != null
                              ? NetworkImage(member.photoUrl!)
                              : null,
                          child: member.photoUrl == null
                              ? Text(
                                  _getInitials(
                                      member.fullDisplayName),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF004E64)),
                                )
                              : null,
                        ),
                        title: Text(
                          member.fullDisplayName,
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
                      onRefresh: () async {
                        if (_group != null) await _loadMembersAndFriendships(_group!);
                      },
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
                  color: AppColors.secondary,
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
      // The Firestore stream will automatically reflect any new members.
      // Force a friendship-status refresh so newly invited members appear correctly.
      if (mounted && _group != null) {
        _loadMembersAndFriendships(_group!);
      }
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

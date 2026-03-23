// Displays detailed information about a group with Members/Activities tab layout.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/group_activity_item.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_event.dart';
import 'package:play_with_me/core/presentation/bloc/group_member/group_member_state.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/core/presentation/widgets/global_bottom_nav_bar.dart';
import 'package:play_with_me/features/friends/presentation/pages/my_community_page.dart';
import 'package:play_with_me/features/groups/presentation/widgets/member_action_dialogs.dart';
import 'package:play_with_me/features/groups/presentation/pages/invite_member_page.dart';
import 'package:play_with_me/features/groups/presentation/widgets/member_list_item_with_friendship.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/games_list/games_list_state.dart';
import 'package:play_with_me/features/games/presentation/pages/game_creation_page.dart';
import 'package:play_with_me/features/games/presentation/pages/game_details_page.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_list_item.dart';
import 'package:play_with_me/features/games/presentation/widgets/training_session_list_item.dart';
import 'package:play_with_me/features/training/presentation/bloc/training_session_creation/training_session_creation_bloc.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_creation_page.dart';
import 'package:play_with_me/features/training/presentation/pages/training_session_details_page.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_bloc.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_event.dart';
import 'package:play_with_me/features/groups/presentation/bloc/group_invite_link/group_invite_link_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<GroupMemberBloc>()),
        BlocProvider(create: (context) => sl<GroupInviteLinkBloc>()),
        BlocProvider(
          create: (context) {
            final authState = context.read<AuthenticationBloc>().state;
            final userId = authState is AuthenticationAuthenticated
                ? authState.user.uid
                : '';
            return sl<GamesListBloc>()
              ..add(LoadGamesForGroup(groupId: groupId, userId: userId));
          },
        ),
      ],
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
  State<_GroupDetailsPageContent> createState() =>
      _GroupDetailsPageContentState();
}

class _GroupDetailsPageContentState extends State<_GroupDetailsPageContent>
    with SingleTickerProviderStateMixin {
  late final GroupRepository _groupRepository;
  late final UserRepository _userRepository;
  late final FriendRepository _friendRepository;
  late final TabController _tabController;

  GroupModel? _group;
  List<UserModel> _members = [];
  Map<String, bool> _friendshipStatus = {};
  Map<String, FriendRequestStatus> _requestStatus = {};
  bool _isLoading = true;
  bool _isLoadingFriendships = true;
  String? _error;

  /// Tracks which member UIDs were used for the last full data load.
  Set<String> _lastLoadedMemberIds = {};

  StreamSubscription<GroupModel?>? _groupSubscription;

  @override
  void initState() {
    super.initState();
    _groupRepository =
        widget.groupRepositoryOverride ?? sl<GroupRepository>();
    _userRepository = widget.userRepositoryOverride ?? sl<UserRepository>();
    _friendRepository = sl<FriendRepository>();
    _tabController = TabController(length: 2, vsync: this);
    _subscribeToGroup();
  }

  @override
  void dispose() {
    _groupSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

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

    if (memberIdsChanged) {
      _loadMembersAndFriendships(group);
    }
  }

  Future<void> _loadMembersAndFriendships(GroupModel group) async {
    final authState = context.read<AuthenticationBloc>().state;
    if (authState is! AuthenticationAuthenticated) return;

    final currentUserId = authState.user.uid;
    final otherMemberIds =
        group.memberIds.where((id) => id != currentUserId).toList();

    setState(() {
      _isLoadingFriendships = true;
    });

    try {
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

  Future<void> _refreshGroupDetails() async {
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

      try {
        (_friendRepository as dynamic)
            .invalidateFriendshipCacheForUser(targetUserId);
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request sent successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      if (_group != null) {
        await _loadMembersAndFriendships(_group!);
      }
    } catch (e) {
      if (!mounted) return;

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
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<GroupMemberBloc, GroupMemberState>(
      listener: (context, state) {
        if (state is MemberPromotedSuccess) {
          _showSuccessMessage('Member promoted to admin');
        } else if (state is MemberDemotedSuccess) {
          _showSuccessMessage('Member demoted to regular member');
        } else if (state is MemberRemovedSuccess) {
          _showSuccessMessage('Member removed from group');
        } else if (state is UserLeftGroupSuccess) {
          _showSuccessMessage('You have left the group');
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
                if (_group != null)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'leave') {
                        _handleLeaveGroup(context, authState.user.uid);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'leave',
                        child: Row(
                          children: [
                            const Icon(Icons.exit_to_app,
                                size: 20, color: Colors.red),
                            const SizedBox(width: 12),
                            Text(
                              l10n.leaveGroup,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            body: _buildBody(context, authState),
            bottomNavigationBar: GlobalBottomNavBar(
              selectedIndex: 2, // Groups tab
              onTabSelected: (index) => _onGlobalNavTapped(context, index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AuthenticationAuthenticated authState) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
            Text('Error', style: Theme.of(context).textTheme.titleLarge),
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
      return const Center(child: Text('Group not found'));
    }

    final currentUserId = authState.user.uid;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Group header (non-scrollable)
        _buildGroupHeader(context),
        const Divider(height: 1),

        // Tab bar
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: l10n.members),
            Tab(text: l10n.activities),
          ],
        ),

        // Tab content (scrollable, fills remaining space)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMembersTab(context, currentUserId),
              _buildActivitiesTab(context, currentUserId),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab(BuildContext context, String currentUserId) {
    final l10n = AppLocalizations.of(context)!;
    final canInvite =
        _group != null && _group!.canUserInviteOthers(currentUserId);

    return RefreshIndicator(
      onRefresh: _refreshGroupDetails,
      child: BlocConsumer<GroupInviteLinkBloc, GroupInviteLinkState>(
        listener: (context, state) {
          if (state is GroupInviteLinkGenerated) {
            // Link generated — share it
            _shareInviteLink(context, state.deepLinkUrl);
          } else if (state is GroupInviteLinkRevoked) {
            _showSuccessMessage(l10n.inviteRevoked);
          } else if (state is GroupInviteLinkError) {
            _showErrorMessage(state.message);
          }
        },
        builder: (context, inviteLinkState) {
          return BlocBuilder<GroupMemberBloc, GroupMemberState>(
            builder: (context, memberState) {
              // Build the full item list including invite actions at the bottom
              final itemCount =
                  _members.length + (canInvite ? 2 : 0);

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: itemCount + 1, // +1 for header
                itemBuilder: (context, index) {
                  // Header: member count
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Members (${_members.length})',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    );
                  }

                  final dataIndex = index - 1;

                  // Member entries
                  if (dataIndex < _members.length) {
                    final member = _members[dataIndex];
                    final isAdmin = _group!.isAdmin(member.uid);
                    final isCreator = _group!.createdBy == member.uid;
                    final isCurrentUser = member.uid == currentUserId;
                    final isFriend = _friendshipStatus[member.uid] ?? false;
                    final requestStatus =
                        _requestStatus[member.uid] ?? FriendRequestStatus.none;

                    if (_isLoadingFriendships && !isCurrentUser) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFFEACE6A).withValues(alpha: 0.25),
                          backgroundImage: member.photoUrl != null
                              ? NetworkImage(member.photoUrl!)
                              : null,
                          child: member.photoUrl == null
                              ? Text(
                                  _getInitials(member.fullDisplayName),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004E64),
                                  ),
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
                        if (_group != null) {
                          await _loadMembersAndFriendships(_group!);
                        }
                      },
                      onSendFriendRequest: _sendFriendRequest,
                    );
                  }

                  // Invite action entries (only for eligible members)
                  final inviteIndex = dataIndex - _members.length;
                  if (inviteIndex == 0) {
                    // "Invite Member" entry
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.person_add, color: AppColors.primary),
                      ),
                      title: Text(
                        l10n.inviteMember,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _navigateToInvitePage(context),
                    );
                  } else {
                    // "Invite with Link" entry
                    final isGenerating = inviteLinkState is GroupInviteLinkLoading;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.secondary.withValues(alpha: 0.1),
                        child: isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.link, color: AppColors.secondary),
                      ),
                      title: Text(
                        l10n.inviteWithLink,
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: isGenerating
                          ? null
                          : () => context.read<GroupInviteLinkBloc>().add(
                                GenerateInvite(groupId: widget.groupId),
                              ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActivitiesTab(BuildContext context, String currentUserId) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<GamesListBloc, GamesListState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<GamesListBloc>().add(const RefreshGamesList());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Create action buttons at the top
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _navigateToGameCreation(context),
                          icon: const Icon(Icons.sports_volleyball),
                          label: Text(l10n.createGame),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: BorderSide(color: AppColors.secondary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _navigateToTrainingCreation(context),
                          icon: const Icon(Icons.fitness_center),
                          label: Text(l10n.createTrainingSession),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Activity list
                if (state is GamesListLoading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is GamesListError)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (state is GamesListEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.sports_volleyball,
                            size: 48,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noActivitiesYet,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.createFirstActivity,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is GamesListLoaded) ...[
                  if (state.upcomingActivities.isNotEmpty) ...[
                    _buildActivitySectionHeader(
                        context, l10n.upcomingActivities),
                    ...state.upcomingActivities.map((activity) =>
                        _buildActivityItem(
                            context, activity, state.userId, false)),
                  ],
                  if (state.pastActivities.isNotEmpty) ...[
                    _buildActivitySectionHeader(context, l10n.pastActivities),
                    ...state.pastActivities.map((activity) =>
                        _buildActivityItem(
                            context, activity, state.userId, true)),
                  ],
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivitySectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    GroupActivityItem activity,
    String userId,
    bool isPast,
  ) {
    return activity.when(
      game: (game) => GameListItem(
        game: game,
        userId: userId,
        isPast: isPast,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameDetailsPage(gameId: game.id),
          ),
        ),
      ),
      training: (session) => TrainingSessionListItem(
        session: session,
        userId: userId,
        isPast: isPast,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TrainingSessionDetailsPage(trainingSessionId: session.id),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Widget _buildGroupHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _group!.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
          ),
          const SizedBox(height: 8),
          if (_group!.description != null && _group!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _group!.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
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

  void _shareInviteLink(BuildContext context, String link) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.linkCopied),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n.shareLink,
          onPressed: () {
            // Share handled by invite link section logic
          },
        ),
      ),
    );
  }

  void _onGlobalNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
      case 1: // Stats
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 2: // Groups — go back to the groups list
        Navigator.of(context).pop();
        break;
      case 3: // Community
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MyCommunityPage()),
        );
        break;
    }
  }

  void _navigateToInvitePage(BuildContext context) {
    if (_group == null) return;

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

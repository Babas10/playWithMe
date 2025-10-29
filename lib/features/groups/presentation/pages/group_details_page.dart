// Displays detailed information about a group including members and admin actions
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/widgets/member_list_item.dart';
import 'package:play_with_me/features/groups/presentation/pages/invite_member_page.dart';

class GroupDetailsPage extends StatefulWidget {
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
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
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
          ),
          body: _buildBody(context, authState),
          floatingActionButton: _buildFloatingActionButton(context, authState),
        );
      },
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                final isAdmin = _group!.isAdmin(member.uid);
                return MemberListItem(
                  user: member,
                  isAdmin: isAdmin,
                );
              },
            ),
          ],
        ),
      ),
    );
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
}

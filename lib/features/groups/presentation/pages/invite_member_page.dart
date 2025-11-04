// Page for searching and inviting users to a group
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';
import 'package:play_with_me/core/domain/repositories/invitation_repository.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_event.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/groups/presentation/widgets/user_search_result_tile.dart';

class InviteMemberPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final FirebaseFunctions? functionsOverride; // For testing
  final GroupRepository? groupRepositoryOverride; // For testing
  final InvitationRepository? invitationRepositoryOverride; // For testing

  const InviteMemberPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.functionsOverride,
    this.groupRepositoryOverride,
    this.invitationRepositoryOverride,
  });

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final TextEditingController _searchController = TextEditingController();
  late final FirebaseFunctions _functions;
  late final GroupRepository _groupRepository;

  UserModel? _searchResult; // Single user result
  List<String> _memberIds = [];
  final Set<String> _invitedUserIds = {};
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _functions = widget.functionsOverride ?? FirebaseFunctions.instance;
    _groupRepository = widget.groupRepositoryOverride ?? sl<GroupRepository>();
    _loadGroupMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadGroupMembers() async {
    try {
      final group = await _groupRepository.getGroupById(widget.groupId);
      if (group != null) {
        setState(() {
          _memberIds = group.memberIds;
        });
      }
    } catch (e) {
      // Silently fail, we'll still allow searching
    }
  }

  void _onSearchSubmitted() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResult = null;
        _searchError = 'Please enter an email address';
      });
      return;
    }
    _performSearch(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResult = null;
      _searchError = null;
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
      _searchResult = null;
    });

    try {
      // Call Cloud Function to search user by email
      final callable = _functions.httpsCallable('searchUserByEmail');
      final result = await callable.call({
        'email': query.trim(),
      });

      // Convert result.data to Map<String, dynamic> safely
      final data = Map<String, dynamic>.from(result.data as Map);

      if (data['found'] == true && data['user'] != null) {
        // Convert nested map safely
        final userDataRaw = data['user'];
        final userData = Map<String, dynamic>.from(userDataRaw as Map);

        final user = UserModel(
          uid: userData['uid'] as String,
          email: userData['email'] as String,
          displayName: userData['displayName'] as String?,
          photoUrl: userData['photoUrl'] as String?,
          isEmailVerified: true,
          isAnonymous: false,
        );

        setState(() {
          _searchResult = user;
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResult = null;
          _searchError = 'No user found with that email';
          _isSearching = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'unauthenticated':
          errorMessage = 'You must be logged in to search for users';
          break;
        case 'permission-denied':
          errorMessage = 'You don\'t have permission to search for users';
          break;
        case 'invalid-argument':
          errorMessage = 'Invalid email format';
          break;
        case 'not-found':
          errorMessage = 'No user found with that email';
          break;
        default:
          errorMessage = 'Search failed: ${e.message ?? e.code}';
      }

      setState(() {
        _searchError = errorMessage;
        _searchResult = null;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Search failed: $e';
        _searchResult = null;
        _isSearching = false;
      });
    }
  }

  Future<bool> _checkIfAlreadyInvited(String userId) async {
    try {
      // Use Cloud Function for secure cross-user query
      final callable = _functions.httpsCallable('checkPendingInvitation');
      final result = await callable.call({
        'targetUserId': userId,
        'groupId': widget.groupId,
      });

      // Convert result.data to Map<String, dynamic> safely
      final data = Map<String, dynamic>.from(result.data as Map);
      return data['exists'] == true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('⚠️ Error checking pending invitation: ${e.code} - ${e.message}');
      // Return false on error to allow retry
      return false;
    } catch (e) {
      debugPrint('⚠️ Unexpected error checking pending invitation: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState is! AuthenticationAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Invite Member'),
            ),
            body: const Center(
              child: Text('Please log in to invite members'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Invite Member'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Enter email address...',
                          prefixIcon: const Icon(Icons.email_outlined),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _onSearchSubmitted(),
                        onChanged: (value) {
                          // Clear error when user starts typing again
                          if (_searchError != null) {
                            setState(() {
                              _searchError = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _isSearching ? null : _onSearchSubmitted,
                      icon: _isSearching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ],
                ),
              ),

              // Search results
              Expanded(
                child: _buildSearchResults(context, authState),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(
      BuildContext context, AuthenticationAuthenticated authState) {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchError != null) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _searchError!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for users to invite',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Enter an email address to find users',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // No result yet - this case shouldn't normally show
    if (_searchResult == null) {
      return const SizedBox.shrink();
    }

    // Show single result
    return BlocListener<InvitationBloc, InvitationState>(
      listener: (context, state) {
        if (state is InvitationSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Clear search after successful invitation
          _searchController.clear();
          setState(() {
            _searchResult = null;
          });
        } else if (state is InvitationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          UserSearchResultTile(
            user: _searchResult!,
            isAlreadyMember: _memberIds.contains(_searchResult!.uid),
            isAlreadyInvited: _invitedUserIds.contains(_searchResult!.uid),
            onInvite: () => _inviteUser(context, authState, _searchResult!),
          ),
        ],
      ),
    );
  }

  Future<void> _inviteUser(BuildContext context,
      AuthenticationAuthenticated authState, UserModel user) async {
    // Check if already invited
    final alreadyInvited = await _checkIfAlreadyInvited(user.uid);
    if (alreadyInvited && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User already has a pending invitation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Send invitation
    if (!mounted) return;

    context.read<InvitationBloc>().add(
          SendInvitation(
            groupId: widget.groupId,
            groupName: widget.groupName,
            invitedUserId: user.uid,
            invitedBy: authState.user.uid,
            inviterName: authState.user.displayName ?? authState.user.email,
          ),
        );

    // Track invited user
    setState(() {
      _invitedUserIds.add(user.uid);
    });
  }
}

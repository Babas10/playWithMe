// Page for searching and adding friends by email
import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_event.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_state.dart';
import 'package:play_with_me/features/friends/presentation/widgets/search_result_tile.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  // Tracks the last search result so we can keep showing it after actionSuccess
  _SearchResultSnapshot? _lastSearchSnapshot;
  // Once true, the builder shows the green tick regardless of BLoC state changes
  bool _requestSent = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _lastSearchSnapshot = null;
      _requestSent = false;
    });
    context.read<FriendBloc>().add(FriendEvent.searchRequested(email: query));
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _lastSearchSnapshot = null;
      _requestSent = false;
    });
    context.read<FriendBloc>().add(const FriendEvent.searchCleared());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState is! AuthenticationAuthenticated) {
          return Scaffold(
            appBar: PlayWithMeAppBar.build(
              context: context,
              title: 'Add Friend',
              showUserActions: true,
            ),
            body: const Center(child: Text('Please log in to add friends')),
          );
        }

        return Scaffold(
          appBar: PlayWithMeAppBar.build(context: context, title: 'Add Friend'),
          body: Column(
            children: [
              // Search bar
              _buildSearchBar(context),

              // Search results
              Expanded(child: _buildSearchResults(context, authState)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<FriendBloc, FriendState>(
        builder: (context, state) {
          final isSearching = state is FriendSearchLoading;

          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  enabled: !isSearching,
                  decoration: InputDecoration(
                    hintText: l10n.searchFriendsByEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: isSearching ? null : _clearSearch,
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
                    setState(() {}); // Rebuild to update button state
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFEACE6A,
                  ).withValues(alpha: 0.25),
                  foregroundColor: const Color(0xFF004E64),
                ),
                onPressed: isSearching || _searchController.text.trim().isEmpty
                    ? null
                    : _onSearchSubmitted,
                icon: isSearching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(l10n.search),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    AuthenticationAuthenticated authState,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<FriendBloc, FriendState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          },
          actionSuccess: (_) {
            // Set local flag so the green tick persists across subsequent loading/loaded states
            setState(() {
              _requestSent = true;
            });
          },
        );
      },
      builder: (context, state) {
        // If a request was already sent, keep showing the tile with green tick
        // regardless of subsequent BLoC state changes (loading → loaded).
        if (_requestSent && _lastSearchSnapshot != null) {
          return _buildSearchResultTile(
            context,
            l10n,
            _lastSearchSnapshot!,
            isInvited: true,
          );
        }

        return state.when(
          initial: () => _buildEmptyState(context, l10n),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (friends, receivedRequests, sentRequests) =>
              _buildEmptyState(context, l10n),
          searchLoading: () => const Center(child: CircularProgressIndicator()),
          searchResult:
              (
                user,
                isFriend,
                hasPendingRequest,
                requestDirection,
                searchedEmail,
                isSelfSearch,
              ) {
                // Capture snapshot so we can keep showing it after actionSuccess
                _lastSearchSnapshot = _SearchResultSnapshot(
                  user: user,
                  isFriend: isFriend,
                  hasPendingRequest: hasPendingRequest,
                  requestDirection: requestDirection,
                  searchedEmail: searchedEmail,
                  isSelfSearch: isSelfSearch,
                );
                return _buildSearchResultTile(
                  context,
                  l10n,
                  _lastSearchSnapshot!,
                  isInvited: false,
                );
              },
          statusResult: (status) => _buildEmptyState(context, l10n),
          error: (message) => _buildEmptyState(context, l10n),
          actionSuccess: (_) => _buildEmptyState(context, l10n),
        );
      },
    );
  }

  Widget _buildSearchResultTile(
    BuildContext context,
    AppLocalizations l10n,
    _SearchResultSnapshot snapshot, {
    required bool isInvited,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SearchResultTile(
          user: snapshot.user,
          isFriend: snapshot.isFriend,
          hasPendingRequest: snapshot.hasPendingRequest,
          requestDirection: snapshot.requestDirection,
          searchedEmail: snapshot.searchedEmail,
          isSelfSearch: snapshot.isSelfSearch,
          isInvited: isInvited,
          onSendRequest: snapshot.user != null && !isInvited
              ? () {
                  context.read<FriendBloc>().add(
                    FriendEvent.requestSent(targetUserId: snapshot.user!.uid),
                  );
                }
              : null,
          onAcceptRequest:
              snapshot.user != null &&
                  snapshot.requestDirection == 'received' &&
                  !isInvited
              ? () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.checkRequestsTab),
                      action: SnackBarAction(label: l10n.ok, onPressed: () {}),
                    ),
                  );
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchForFriendsToAdd,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.enterEmailToFindFriends,
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
}

/// Snapshot of a search result to preserve across BLoC state transitions.
class _SearchResultSnapshot {
  final dynamic user;
  final bool isFriend;
  final bool hasPendingRequest;
  final String? requestDirection;
  final String searchedEmail;
  final bool isSelfSearch;

  _SearchResultSnapshot({
    required this.user,
    required this.isFriend,
    required this.hasPendingRequest,
    required this.requestDirection,
    required this.searchedEmail,
    required this.isSelfSearch,
  });
}

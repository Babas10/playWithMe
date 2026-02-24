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
    context.read<FriendBloc>().add(
          FriendEvent.searchRequested(email: query),
        );
  }

  void _clearSearch() {
    _searchController.clear();
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
            body: const Center(
              child: Text('Please log in to add friends'),
            ),
          );
        }

        return Scaffold(
          appBar: PlayWithMeAppBar.build(
            context: context,
            title: 'Add Friend',
          ),
          body: Column(
            children: [
              // Search bar
              _buildSearchBar(context),

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
                  backgroundColor: const Color(0xFFEACE6A).withValues(alpha: 0.25),
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
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          },
          actionSuccess: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
              ),
            );
            // Clear search after successful friend request
            _searchController.clear();
            context.read<FriendBloc>().add(const FriendEvent.searchCleared());
          },
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => _buildEmptyState(context, l10n),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (friends, receivedRequests, sentRequests) =>
              _buildEmptyState(context, l10n),
          searchLoading: () => const Center(child: CircularProgressIndicator()),
          searchResult: (user, isFriend, hasPendingRequest, requestDirection,
              searchedEmail, isSelfSearch) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SearchResultTile(
                  user: user,
                  isFriend: isFriend,
                  hasPendingRequest: hasPendingRequest,
                  requestDirection: requestDirection,
                  searchedEmail: searchedEmail,
                  isSelfSearch: isSelfSearch,
                  onSendRequest: user != null
                      ? () {
                          context.read<FriendBloc>().add(
                                FriendEvent.requestSent(targetUserId: user.uid),
                              );
                        }
                      : null,
                  onAcceptRequest: user != null && requestDirection == 'received'
                      ? () {
                          // Navigate to requests tab in My Community
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.checkRequestsTab),
                              action: SnackBarAction(
                                label: l10n.ok,
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            );
          },
          statusResult: (status) => _buildEmptyState(context, l10n),
          error: (message) => _buildEmptyState(context, l10n),
          actionSuccess: (message) => _buildEmptyState(context, l10n),
        );
      },
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

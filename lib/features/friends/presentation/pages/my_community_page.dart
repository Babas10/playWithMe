import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_event.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_state.dart';
import 'package:play_with_me/features/friends/presentation/widgets/friends_list.dart';
import 'package:play_with_me/features/friends/presentation/widgets/friend_requests_list.dart';
import 'package:play_with_me/features/friends/presentation/pages/add_friend_page.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_request_count_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Page for managing friends and friend requests
class MyCommunityPage extends StatelessWidget {
  const MyCommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FriendBloc>()..add(const FriendEvent.loadRequested()),
      child: const _MyCommunityPageContent(),
    );
  }
}

class _MyCommunityPageContent extends StatefulWidget {
  const _MyCommunityPageContent();

  @override
  State<_MyCommunityPageContent> createState() => _MyCommunityPageContentState();
}

class _MyCommunityPageContentState extends State<_MyCommunityPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        context.read<FriendBloc>().add(const FriendEvent.loadRequested());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        body: Column(
          children: [
            Container(
              color: AppColors.scaffoldBackground,
              child: TabBar(
                controller: _tabController,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.secondary,
                unselectedLabelColor: AppColors.secondary,
                tabs: [
                  Tab(height: 40, text: l10n.friends),
                  BlocBuilder<FriendRequestCountBloc, FriendRequestCountState>(
                    builder: (context, state) {
                      final count = state is FriendRequestCountLoaded ? state.count : 0;
                      return Tab(
                        height: 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.requests),
                            if (count > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocListener<FriendBloc, FriendState>(
              listener: (context, state) {
                state.when(
                  initial: () {},
                  loading: () {},
                  loaded: (friends, receivedRequests, sentRequests) {},
                  searchLoading: () {},
                  searchResult: (user, isFriend, hasPendingRequest, requestDirection, searchedEmail) {},
                  statusResult: (status) {},
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
                  },
                );
              },
              child: BlocBuilder<FriendBloc, FriendState>(
                builder: (context, state) {
            return state.when(
              initial: () => Center(child: Text(l10n.loading)),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (friends, receivedRequests, sentRequests) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Friends Tab
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<FriendBloc>().add(
                              const FriendEvent.loadRequested(),
                            );
                        // Wait for the state to update
                        await context.read<FriendBloc>().stream.firstWhere(
                              (state) =>
                                  state is FriendLoaded || state is FriendError,
                            );
                      },
                      child: FriendsList(
                        friends: friends,
                        onRemoveFriend: (friendshipId) {
                          context.read<FriendBloc>().add(
                                FriendEvent.removed(
                                  friendshipId: friendshipId,
                                ),
                              );
                        },
                      ),
                    ),
                    // Requests Tab
                    FriendRequestsList(
                      receivedRequests: receivedRequests,
                      sentRequests: sentRequests,
                      onAcceptRequest: (friendshipId) {
                        context.read<FriendBloc>().add(
                              FriendEvent.requestAccepted(
                                friendshipId: friendshipId,
                              ),
                            );
                      },
                      onDeclineRequest: (friendshipId) {
                        context.read<FriendBloc>().add(
                              FriendEvent.requestDeclined(
                                friendshipId: friendshipId,
                              ),
                            );
                      },
                      onCancelRequest: (friendshipId) {
                        context.read<FriendBloc>().add(
                              FriendEvent.requestCancelled(
                                friendshipId: friendshipId,
                              ),
                            );
                      },
                    ),
                  ],
                );
              },
              searchLoading: () => const Center(child: CircularProgressIndicator()),
              searchResult: (user, isFriend, hasPendingRequest, requestDirection, searchedEmail) =>
                  const Center(child: CircularProgressIndicator()),
              statusResult: (status) => const Center(child: CircularProgressIndicator()),
              error: (message) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorLoadingFriends,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          context.read<FriendBloc>().add(
                                const FriendEvent.loadRequested(),
                              );
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                );
              },
              actionSuccess: (message) {
                // Loading state after action, show previous data
                return const Center(child: CircularProgressIndicator());
              },
            );
                },
              ),
            ),
          ),
          ],
        ),
        floatingActionButton: _buildAddFriendButton(context, l10n),
      );
  }

  Widget _buildAddFriendButton(BuildContext context, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      heroTag: 'add_friend_fab', // Unique tag to avoid Hero conflicts
      backgroundColor: AppColors.primary.withValues(alpha: 0.25),
      foregroundColor: AppColors.secondary,
      elevation: 0,
      highlightElevation: 0,
      onPressed: () {
        // Capture the bloc before navigation to avoid context issues
        final friendBloc = context.read<FriendBloc>();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: friendBloc,
              child: const AddFriendPage(),
            ),
          ),
        ).then((_) {
          friendBloc.add(const FriendEvent.loadRequested());
        });
      },
      icon: const Icon(Icons.person_add),
      label: Text(l10n.addFriend),
    );
  }
}

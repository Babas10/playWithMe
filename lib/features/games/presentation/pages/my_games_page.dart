// Ball-icon destination page showing upcoming and past games (Stories 28.11 / 28.12).
// Upcoming = pending invitations + un-joined group games + joined scheduled/in-progress.
// Past = completed/verification/overdue-scheduled games the user played.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/app/play_with_me_app.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/my_game_item.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/core/presentation/widgets/global_bottom_nav_bar.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:play_with_me/core/data/models/game_invitation_details.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_invitations/game_invitations_bloc.dart';
import 'package:play_with_me/features/games/presentation/pages/game_details_page.dart';
import 'package:play_with_me/features/games/presentation/widgets/my_game_tile.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class MyGamesPage extends StatelessWidget {
  const MyGamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MyGamesView();
  }
}

class _MyGamesView extends StatefulWidget {
  const _MyGamesView();

  @override
  State<_MyGamesView> createState() => _MyGamesViewState();
}

class _MyGamesViewState extends State<_MyGamesView> {
  late final String _userId;
  late final Stream<List<GameModel>> _joinedGamesStream;
  StreamSubscription<List<GameModel>>? _groupGamesSub;

  List<GameModel> _lastJoinedGames = [];
  List<GameModel> _lastGroupGames = [];
  bool _joinedStreamHasEmitted = false;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
    final repo = sl<GameRepository>();

    _joinedGamesStream = repo.getMyGames(_userId);

    // Group games stream — subscribe separately so we can setState on emission
    // without nesting a second StreamBuilder.
    _groupGamesSub = repo.getGroupGamesForUser(_userId).listen(
      (games) {
        if (mounted) setState(() => _lastGroupGames = games);
      },
      onError: (Object e) {
        debugPrint('[MyGamesPage] group games stream error: $e');
      },
    );

    context.read<GameInvitationsBloc>().add(const LoadGameInvitations());
  }

  @override
  void dispose() {
    _groupGamesSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: l10n.myGames,
        showProfileAction: true,
      ),
      bottomNavigationBar: GlobalBottomNavBar(
        selectedIndex: 0,
        onTabSelected: (index) {
          HomePage.onNavigateToTab?.call(index);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: BlocBuilder<GameInvitationsBloc, GameInvitationsState>(
        builder: (context, invState) {
          final invitations = _extractInvitations(invState);

          return StreamBuilder<List<GameModel>>(
            stream: _joinedGamesStream,
            builder: (context, snapshot) {
              if (snapshot.hasData || snapshot.hasError) {
                _joinedStreamHasEmitted = true;
              }
              if (snapshot.hasError) {
                debugPrint('[MyGamesPage] joined stream error: ${snapshot.error}');
              }
              // Keep spinner until joined games and invitations have settled.
              if (!_joinedStreamHasEmitted || invState is GameInvitationsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) _lastJoinedGames = snapshot.data!;

              // Joined games (user is in playerIds)
              final joinedItems = _lastJoinedGames.map(MyGameItem.fromGame).toList();
              final joinedGameIds = _lastJoinedGames.map((g) => g.id).toSet();

              // Cross-group invitations — exclude games already joined
              final invitedGameIds = invitations.map((i) => i.gameId).toSet();
              final invitedItems = invitations
                  .where((inv) => !joinedGameIds.contains(inv.gameId))
                  .map(MyGameItem.fromInvitation)
                  .toList();

              // Un-joined group games — exclude already joined and already invited
              final groupGameItems = _lastGroupGames
                  .where((g) =>
                      !joinedGameIds.contains(g.id) &&
                      !invitedGameIds.contains(g.id) &&
                      g.status != GameStatus.cancelled)
                  .map((g) => MyGameItem.fromGroupGame(g, groupName: ''))
                  .toList();

              // Upcoming: invitations + un-joined group games + joined upcoming
              final upcoming = [
                ...invitedItems,
                ...groupGameItems.where((g) => g.isUpcoming),
                ...joinedItems.where((g) => g.isUpcoming),
              ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

              // Past: joined completed/verification/overdue games, most recent first
              final past = joinedItems
                  .where((g) => g.isPast)
                  .toList()
                ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

              if (upcoming.isEmpty && past.isEmpty) {
                return _emptyState(context, l10n);
              }

              return RefreshIndicator(
                onRefresh: () async => context
                    .read<GameInvitationsBloc>()
                    .add(const LoadGameInvitations()),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    if (upcoming.isNotEmpty) ...[
                      _SectionHeader(title: l10n.upcoming),
                      ...upcoming.map((item) => MyGameTile(
                            item: item,
                            onTap: () => _navigateToGame(context, item),
                          )),
                    ],
                    if (past.isNotEmpty) ...[
                      if (upcoming.isNotEmpty) const SizedBox(height: 8),
                      _SectionHeader(title: l10n.pastGames),
                      ...past.map((item) => MyGameTile(
                            item: item,
                            onTap: () => _navigateToGame(context, item),
                          )),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<GameInvitationDetails> _extractInvitations(GameInvitationsState state) {
    return switch (state) {
      GameInvitationsLoaded() => state.invitations,
      GameInvitationActionInFlight() => state.invitations,
      GameInvitationActionSuccess() => state.invitations,
      GameInvitationActionError() => state.invitations,
      _ => [],
    };
  }

  Future<void> _navigateToGame(BuildContext context, MyGameItem item) async {
    final invBloc = context.read<GameInvitationsBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameDetailsPage(
          gameId: item.gameId,
          invitationId: item.invitationId,
        ),
      ),
    );
    // Refresh invitations after returning — the user may have accepted or
    // declined, so we need to remove stale invitation entries.
    if (mounted) {
      invBloc.add(const LoadGameInvitations());
    }
  }

  Widget _emptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_volleyball_outlined,
              size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            l10n.noMyGamesYet,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

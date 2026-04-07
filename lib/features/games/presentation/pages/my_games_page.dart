// Ball-icon destination page showing upcoming and past games (Story 28.11).
// Upcoming = pending invitations + joined scheduled/in-progress games (unified list).
// Past = completed/verification games the user played.

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
  late final Stream<List<GameModel>> _gamesStream;
  List<GameModel> _lastGames = [];
  bool _gamesStreamHasEmitted = false;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
    _gamesStream = sl<GameRepository>().getMyGames(_userId);
    context.read<GameInvitationsBloc>().add(const LoadGameInvitations());
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
            stream: _gamesStream,
            builder: (context, snapshot) {
              if (snapshot.hasData || snapshot.hasError) {
                _gamesStreamHasEmitted = true;
              }
              if (snapshot.hasError) {
                debugPrint('[MyGamesPage] stream error: ${snapshot.error}');
              }
              // Keep spinner until both data sources have settled to avoid
              // flashing empty state while one is still loading.
              if (!_gamesStreamHasEmitted || invState is GameInvitationsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) _lastGames = snapshot.data!;

              // Build unified MyGameItem lists
              final joinedItems = _lastGames
                  .map(MyGameItem.fromGame)
                  .toList();

              // Exclude invitations for games the user has already joined
              // (prevents duplicates when the invitation is accepted but the
              // GameInvitationsBloc state hasn't refreshed yet)
              final joinedGameIds = _lastGames.map((g) => g.id).toSet();
              final invitedItems = invitations
                  .where((inv) => !joinedGameIds.contains(inv.gameId))
                  .map(MyGameItem.fromInvitation)
                  .toList();

              // Upcoming: invitations + joined scheduled/in-progress, sorted by date
              final upcoming = [
                ...invitedItems,
                ...joinedItems.where((g) => g.isUpcoming),
              ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

              // Past: joined completed/verification games, most recent first
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

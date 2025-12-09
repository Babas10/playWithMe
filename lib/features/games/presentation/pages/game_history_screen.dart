// Game History Screen with pagination and filters (Story 14.7)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/game_repository.dart';
import '../bloc/game_history/game_history_bloc.dart';
import '../bloc/game_history/game_history_event.dart';
import '../bloc/game_history/game_history_state.dart';
import '../widgets/game_history_card.dart';
import 'game_details_page.dart';

class GameHistoryScreen extends StatefulWidget {
  final String? groupId;
  final String userId;

  const GameHistoryScreen({
    super.key,
    this.groupId,
    required this.userId,
  });

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  late final ScrollController _scrollController;
  GameHistoryFilter _selectedFilter = GameHistoryFilter.all;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<GameHistoryBloc>().add(const GameHistoryEvent.loadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    context.read<GameHistoryBloc>().add(const GameHistoryEvent.refresh());
    // Wait a bit for the stream to update
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Games'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<GameHistoryFilter>(
              title: const Text('All Games'),
              value: GameHistoryFilter.all,
              groupValue: _selectedFilter,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                  Navigator.pop(context);
                  _applyFilter(value);
                }
              },
            ),
            RadioListTile<GameHistoryFilter>(
              title: const Text('My Games Only'),
              value: GameHistoryFilter.myGames,
              groupValue: _selectedFilter,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFilter = value);
                  Navigator.pop(context);
                  _applyFilter(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _applyFilter(GameHistoryFilter filter) {
    context.read<GameHistoryBloc>().add(
          GameHistoryEvent.filterChanged(filter: filter),
        );
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      context.read<GameHistoryBloc>().add(
            GameHistoryEvent.dateRangeChanged(
              startDate: picked.start,
              endDate: picked.end,
            ),
          );
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    context.read<GameHistoryBloc>().add(
          const GameHistoryEvent.dateRangeChanged(
            startDate: null,
            endDate: null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
            tooltip: 'Date Range',
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => GameHistoryBloc(
          gameRepository: context.read<GameRepository>(),
        )..add(GameHistoryEvent.load(
            groupId: widget.groupId,
            userId: widget.userId,
          )),
        child: BlocBuilder<GameHistoryBloc, GameHistoryState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(
                child: Text('Select filters to view game history'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded: (games, hasMore, filter, startDate, endDate,
                  isLoadingMore) {
                return Column(
                  children: [
                    // Active filters display
                    if (startDate != null || filter != GameHistoryFilter.all)
                      _buildActiveFiltersBar(filter, startDate, endDate),

                    // Games list
                    Expanded(
                      child: games.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: games.length + (hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= games.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final game = games[index];
                                  return GameHistoryCard(
                                    game: game,
                                    onTap: () => _navigateToGameDetail(game.id),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
              error: (message, lastFilter) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GameHistoryBloc>().add(
                              GameHistoryEvent.load(
                                groupId: widget.groupId,
                                userId: widget.userId,
                                filter:
                                    lastFilter ?? GameHistoryFilter.all,
                              ),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveFiltersBar(
    GameHistoryFilter filter,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Row(
        children: [
          const Text('Active filters: '),
          const SizedBox(width: 8),
          if (filter == GameHistoryFilter.myGames)
            Chip(
              label: const Text('My Games'),
              onDeleted: () => _applyFilter(GameHistoryFilter.all),
            ),
          if (startDate != null) ...[
            const SizedBox(width: 8),
            Chip(
              label: Text(
                '${startDate.month}/${startDate.day} - ${endDate?.month}/${endDate?.day}',
              ),
              onDeleted: _clearDateRange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No completed games yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Games will appear here after they are completed',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _navigateToGameDetail(String gameId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailsPage(
          gameId: gameId,
        ),
      ),
    );
  }
}

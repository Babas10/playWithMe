import 'package:flutter/material.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

/// Widget for selecting friends to invite to a group
/// Fetches friends using FriendRepository and allows multi-select
class FriendSelectorWidget extends StatefulWidget {
  final String currentUserId;
  final FriendRepository friendRepository;
  final ValueChanged<Set<String>> onSelectionChanged;
  final Set<String>? initialSelection;

  const FriendSelectorWidget({
    super.key,
    required this.currentUserId,
    required this.friendRepository,
    required this.onSelectionChanged,
    this.initialSelection,
  });

  @override
  State<FriendSelectorWidget> createState() => _FriendSelectorWidgetState();
}

class _FriendSelectorWidgetState extends State<FriendSelectorWidget> {
  List<UserEntity>? _friends;
  Set<String> _selectedFriendIds = {};
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedFriendIds = widget.initialSelection ?? {};
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final friends = await widget.friendRepository.getFriends(widget.currentUserId);
      if (mounted) {
        setState(() {
          _friends = friends;
          _isLoading = false;
        });
      }
    } on FriendshipException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load friends. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSelection(String friendId) {
    setState(() {
      if (_selectedFriendIds.contains(friendId)) {
        _selectedFriendIds.remove(friendId);
      } else {
        _selectedFriendIds.add(friendId);
      }
    });
    widget.onSelectionChanged(_selectedFriendIds);
  }

  void _selectAll() {
    if (_friends == null) return;

    setState(() {
      _selectedFriendIds = _friends!.map((f) => f.uid).toSet();
    });
    widget.onSelectionChanged(_selectedFriendIds);
  }

  void _clearAll() {
    setState(() {
      _selectedFriendIds.clear();
    });
    widget.onSelectionChanged(_selectedFriendIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Friends to Invite',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_friends != null && _friends!.isNotEmpty)
              Text(
                '${_selectedFriendIds.length} selected',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          'Choose friends from your community to invite to this group',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),

        // Content
        if (_isLoading)
          _buildLoadingState()
        else if (_errorMessage != null)
          _buildErrorState()
        else if (_friends == null || _friends!.isEmpty)
          _buildEmptyState()
        else
          _buildFriendList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadFriends,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.people_outline, color: Colors.blue.shade700, size: 48),
            const SizedBox(height: 8),
            Text(
              'No Friends Yet',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add friends to invite them to groups',
              style: TextStyle(color: Colors.blue.shade800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Select/Clear all buttons
        if (_friends!.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _selectedFriendIds.length == _friends!.length ? null : _selectAll,
                icon: const Icon(Icons.check_box, size: 18),
                label: const Text('Select All'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _selectedFriendIds.isEmpty ? null : _clearAll,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear All'),
              ),
            ],
          ),

        // Friend list
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _friends!.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final friend = _friends![index];
              final isSelected = _selectedFriendIds.contains(friend.uid);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (_) => _toggleSelection(friend.uid),
                title: Text(
                  friend.displayNameOrEmail,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: friend.displayName != null
                    ? Text(
                        friend.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      )
                    : null,
                secondary: CircleAvatar(
                  backgroundImage: friend.photoUrl != null
                      ? NetworkImage(friend.photoUrl!)
                      : null,
                  child: friend.photoUrl == null
                      ? Text(
                          friend.displayNameOrEmail[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                controlAffinity: ListTileControlAffinity.trailing,
              );
            },
          ),
        ),
      ],
    );
  }
}

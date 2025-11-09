import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_event.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Widget for searching friends by email with a search button
class FriendSearchBar extends StatefulWidget {
  const FriendSearchBar({super.key});

  @override
  State<FriendSearchBar> createState() => _FriendSearchBarState();
}

class _FriendSearchBarState extends State<FriendSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update button state
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted() {
    final email = _controller.text.trim();
    if (email.isEmpty) {
      return;
    }
    _focusNode.unfocus();
    context.read<FriendBloc>().add(
          FriendEvent.searchRequested(email: email),
        );
  }

  void _clearSearch() {
    _controller.clear();
    context.read<FriendBloc>().add(const FriendEvent.searchCleared());
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<FriendBloc, FriendState>(
        builder: (context, state) {
          final isSearching = state is FriendSearchLoading;

          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !isSearching,
                  decoration: InputDecoration(
                    hintText: l10n.searchFriendsByEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: _controller.text.isNotEmpty
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
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: isSearching || _controller.text.trim().isEmpty
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
}

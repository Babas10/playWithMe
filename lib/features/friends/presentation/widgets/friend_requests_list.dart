import 'package:flutter/material.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';
import 'received_request_tile.dart';
import 'sent_request_tile.dart';

/// Widget for displaying friend requests (received and sent)
class FriendRequestsList extends StatelessWidget {
  final List<FriendshipEntity> receivedRequests;
  final List<FriendshipEntity> sentRequests;
  final Function(String friendshipId) onAcceptRequest;
  final Function(String friendshipId) onDeclineRequest;
  final Function(String friendshipId) onCancelRequest;

  const FriendRequestsList({
    super.key,
    required this.receivedRequests,
    required this.sentRequests,
    required this.onAcceptRequest,
    required this.onDeclineRequest,
    required this.onCancelRequest,
  });

  @override
  Widget build(BuildContext context) {
    final hasReceivedRequests = receivedRequests.isNotEmpty;
    final hasSentRequests = sentRequests.isNotEmpty;

    if (!hasReceivedRequests && !hasSentRequests) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No pending friend requests',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        if (hasReceivedRequests) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Received Requests',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...receivedRequests.map(
            (request) => ReceivedRequestTile(
              request: request,
              onAccept: () => onAcceptRequest(request.id),
              onDecline: () => onDeclineRequest(request.id),
            ),
          ),
        ],
        if (hasReceivedRequests && hasSentRequests)
          const Divider(height: 32),
        if (hasSentRequests) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Sent Requests',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...sentRequests.map(
            (request) => SentRequestTile(
              request: request,
              onCancel: () => onCancelRequest(request.id),
            ),
          ),
        ],
        if (!hasReceivedRequests && hasSentRequests)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No pending requests to respond to',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

// Displays a list of pending invitations for the current user with real-time updates
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_event.dart';
import 'package:play_with_me/core/presentation/bloc/invitation/invitation_state.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/invitations/presentation/widgets/invitation_tile.dart';

class PendingInvitationsPage extends StatelessWidget {
  final InvitationBloc? blocOverride; // Optional bloc for testing

  const PendingInvitationsPage({super.key, this.blocOverride});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState is! AuthenticationAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Invitations'),
            ),
            body: const Center(
              child: Text('Please log in to view invitations'),
            ),
          );
        }

        // Use provided bloc or get from context
        if (blocOverride != null) {
          return BlocProvider<InvitationBloc>.value(
            value: blocOverride!,
            child: _buildScaffold(context, authState),
          );
        }

        return _buildScaffold(context, authState);
      },
    );
  }

  Widget _buildScaffold(
      BuildContext context, AuthenticationAuthenticated authState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Invitations'),
        centerTitle: true,
      ),
      body: BlocConsumer<InvitationBloc, InvitationState>(
        listener: (context, state) {
          if (state is InvitationAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Reload invitations after accepting
            context.read<InvitationBloc>().add(
                  LoadPendingInvitations(userId: authState.user.uid),
                );
          } else if (state is InvitationDeclined) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            // Reload invitations after declining
            context.read<InvitationBloc>().add(
                  LoadPendingInvitations(userId: authState.user.uid),
                );
          } else if (state is InvitationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            // Reload invitations after error
            context.read<InvitationBloc>().add(
                  LoadPendingInvitations(userId: authState.user.uid),
                );
          }
        },
        builder: (context, state) {
          // Show loading when explicitly loading (not from stream updates)
          if (state is InvitationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show invitations list
          if (state is InvitationsLoaded) {
            if (state.invitations.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              itemCount: state.invitations.length,
              itemBuilder: (context, index) {
                final invitation = state.invitations[index];
                return InvitationTile(
                  invitation: invitation,
                  onAccept: () {
                    context.read<InvitationBloc>().add(
                          AcceptInvitation(
                            userId: authState.user.uid,
                            invitationId: invitation.id,
                          ),
                        );
                  },
                  onDecline: () {
                    context.read<InvitationBloc>().add(
                          DeclineInvitation(
                            userId: authState.user.uid,
                            invitationId: invitation.id,
                          ),
                        );
                  },
                );
              },
            );
          }

          // Default: show empty state
          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Pending Invitations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You don\'t have any pending group invitations at the moment.',
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

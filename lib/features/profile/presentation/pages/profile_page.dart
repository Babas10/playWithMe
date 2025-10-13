import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_actions.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_header.dart';
import 'package:play_with_me/features/profile/presentation/widgets/profile_info_card.dart';

/// Profile page displaying user information and account details
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            return _ProfileContent(state: state);
          }

          if (state is AuthenticationUnknown) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Unauthenticated state - should not happen on profile page
          return const Center(
            child: Text('Please log in to view your profile'),
          );
        },
      ),
    );
  }
}

/// Private widget containing the actual profile content
class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.state});

  final AuthenticationAuthenticated state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile header with avatar and name
          ProfileHeader(user: state.user),
          const SizedBox(height: 8),

          // Account information card
          ProfileInfoCard(user: state.user),

          // Action buttons
          ProfileActions(
            onEditProfile: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (newContext) => MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider.value(
                        value: context.read<AuthRepository>(),
                      ),
                    ],
                    child: BlocProvider.value(
                      value: context.read<AuthenticationBloc>(),
                      child: ProfileEditPage(user: state.user),
                    ),
                  ),
                ),
              );
            },
            onSettings: () {
              // TODO: Navigate to settings page (Story 1.4.4)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            onSignOut: () {
              _showSignOutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Trigger logout through AuthenticationBloc
              context
                  .read<AuthenticationBloc>()
                  .add(const AuthenticationLogoutRequested());
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

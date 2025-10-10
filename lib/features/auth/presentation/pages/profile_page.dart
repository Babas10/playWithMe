// Displays user profile information with navigation to editing and settings functionality.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import 'package:play_with_me/features/auth/presentation/widgets/profile_header.dart';
import 'package:play_with_me/features/auth/presentation/widgets/profile_info_card.dart';
import 'package:play_with_me/features/auth/presentation/widgets/profile_actions.dart';
import 'package:play_with_me/features/auth/presentation/widgets/verification_badge.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            return _ProfileContent(user: state.user);
          } else if (state is AuthenticationUnauthenticated) {
            return const _UnauthenticatedView();
          } else {
            return const _LoadingView();
          }
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header - Avatar and Name
          ProfileHeader(user: user),

          const SizedBox(height: 24),

          // Email Verification Section
          if (!user.isEmailVerified) ...[
            VerificationBadge(isVerified: user.isEmailVerified),
            const SizedBox(height: 16),
          ],

          // Profile Information Card
          ProfileInfoCard(user: user),

          const SizedBox(height: 24),

          // Profile Actions (Edit, Settings, Logout)
          ProfileActions(
            onEditProfile: () {
              // TODO: Navigate to edit profile (Story 1.4.2)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit Profile - Coming Soon'),
                ),
              );
            },
            onAccountSettings: () {
              // TODO: Navigate to account settings (Story 1.4.5)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account Settings - Coming Soon'),
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
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              context.read<AuthenticationBloc>().add(
                const AuthenticationLogoutRequested(),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Not Signed In',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please sign in to view your profile',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading profile...'),
        ],
      ),
    );
  }
}
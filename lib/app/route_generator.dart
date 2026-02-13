// Generates routes for the app, including deep link handling for /invite/{token}.
import 'package:flutter/material.dart';
import 'package:play_with_me/features/auth/presentation/pages/login_page.dart';
import 'package:play_with_me/features/auth/presentation/pages/registration_page.dart';
import 'package:play_with_me/features/auth/presentation/pages/password_reset_page.dart';
import 'package:play_with_me/features/friends/presentation/pages/my_community_page.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');
    final routeName = settings.name;

    // Handle deep link routes: /invite/{token}
    if (uri != null && uri.pathSegments.length == 2 && uri.pathSegments[0] == 'invite') {
      // Deep link invite route — no dedicated page yet.
      // The DeepLinkBloc handles token extraction and storage.
      // For now, redirect to login page so auth flow can proceed.
      return _buildRoute(const LoginPage(), settings);
    }

    // Standard named routes
    switch (routeName) {
      case '/login':
        return _buildRoute(const LoginPage(), settings);
      case '/register':
        return _buildRoute(const RegistrationPage(), settings);
      case '/forgot-password':
        return _buildRoute(const PasswordResetPage(), settings);
      case '/my-community':
        return _buildRoute(const MyCommunityPage(), settings);
      default:
        return _buildRoute(const _UnknownRoutePage(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pageNotFound)),
      body: Center(
        child: Text(l10n.pageNotFoundMessage),
      ),
    );
  }
}

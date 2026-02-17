// App Links / Universal Links implementation of DeepLinkService.
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:play_with_me/core/services/deep_link_service.dart';

class AppLinksDeepLinkService implements DeepLinkService {
  final AppLinks _appLinks;
  final StreamController<String?> _tokenController =
      StreamController<String?>.broadcast();
  StreamSubscription<Uri>? _linkSubscription;

  AppLinksDeepLinkService({AppLinks? appLinks})
      : _appLinks = appLinks ?? AppLinks() {
    debugPrint('[DeepLinkService] Service created, starting listener...');
    _listenForLinks();
  }

  void _listenForLinks() {
    debugPrint('[DeepLinkService] Subscribing to uriLinkStream...');
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[DeepLinkService] Foreground link received: $uri');
        final token = _extractToken(uri);
        debugPrint('[DeepLinkService] Extracted token: $token');
        if (token != null) {
          _tokenController.add(token);
        }
      },
      onError: (error) {
        debugPrint('[DeepLinkService] Link stream error: $error');
      },
    );
  }

  @override
  Stream<String?> get inviteTokenStream => _tokenController.stream;

  @override
  Future<String?> getInitialInviteToken() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      debugPrint('[DeepLinkService] Initial link: $initialUri');
      if (initialUri != null) {
        return _extractToken(initialUri);
      }
    } catch (e) {
      debugPrint('[DeepLinkService] Failed to get initial link: $e');
    }
    return null;
  }

  String? _extractToken(Uri uri) {
    debugPrint('[DeepLinkService] Parsing URI: $uri');
    final segments = uri.pathSegments;

    // HTTPS: https://playwithme.app/invite/{token}
    //   host=playwithme.app, pathSegments=[invite, token]
    if (segments.length == 2 && segments[0] == 'invite') {
      final token = segments[1];
      if (token.isNotEmpty) return token;
    }

    // Custom scheme: playwithme://invite/{token}
    //   host=invite, pathSegments=[token]
    if (uri.scheme == 'playwithme' &&
        uri.host == 'invite' &&
        segments.length == 1) {
      final token = segments[0];
      if (token.isNotEmpty) return token;
    }

    debugPrint('[DeepLinkService] Could not extract token from URI');
    return null;
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _tokenController.close();
  }
}

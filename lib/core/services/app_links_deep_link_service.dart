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
    _listenForLinks();
  }

  void _listenForLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        final token = _extractToken(uri);
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
      if (initialUri != null) {
        return _extractToken(initialUri);
      }
    } catch (e) {
      debugPrint('[DeepLinkService] Failed to get initial link: $e');
    }
    return null;
  }

  String? _extractToken(Uri uri) {
    // Match paths like /invite/{token}
    final segments = uri.pathSegments;
    if (segments.length == 2 && segments[0] == 'invite') {
      final token = segments[1];
      if (token.isNotEmpty) {
        return token;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _tokenController.close();
  }
}

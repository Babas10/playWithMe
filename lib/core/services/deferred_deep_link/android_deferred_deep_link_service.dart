// Android implementation of DeferredDeepLinkService.
//
// Reads the Play Install Referrer string via a MethodChannel that delegates
// to the native com.android.installreferrer library (implemented in
// MainActivity.kt). The referrer string is set by invite.html (Story 19.1)
// when the user taps the Play Store link.
import 'package:flutter/services.dart';
import 'package:play_with_me/core/services/deferred_deep_link/deferred_deep_link_service.dart';

/// Thin abstraction over the MethodChannel, extracted for unit-test injection.
abstract class InstallReferrerClient {
  /// Returns the raw referrer string from the Play Store, or null.
  Future<String?> getReferrerString();
}

/// Production implementation — delegates to the native channel.
class PlayInstallReferrerClient implements InstallReferrerClient {
  static const _channel =
      MethodChannel('org.gatherli.app/install_referrer');

  @override
  Future<String?> getReferrerString() async {
    return _channel.invokeMethod<String>('getReferrerString');
  }
}

/// Reads the Play Install Referrer on first launch and extracts the invite
/// token embedded by the invite.html redirect page (Story 19.1).
///
/// Expected referrer format from Play Store: `invite_token=<token>`
/// (Play Store URL-decodes the referrer parameter once before delivery.)
///
/// Only registered on Android via service_locator.dart.
class AndroidDeferredDeepLinkService implements DeferredDeepLinkService {
  final InstallReferrerClient _client;

  AndroidDeferredDeepLinkService({InstallReferrerClient? client})
      : _client = client ?? PlayInstallReferrerClient();

  @override
  Future<String?> retrieveDeferredToken() async {
    try {
      final referrer = await _client.getReferrerString();
      return _parseToken(referrer);
    } catch (_) {
      // Referrer API unavailable, timed out, or not installed via Play Store.
      // Return null silently — the invite flow degrades gracefully.
      return null;
    }
  }

  /// Parses `invite_token` from the Play Store referrer string.
  ///
  /// The referrer delivered via the Play Install Referrer API is already
  /// URL-decoded once. However, to be safe this method also handles the
  /// double-encoded form (e.g. `invite_token%3Dabc`) seen on some devices.
  String? _parseToken(String? referrer) {
    if (referrer == null || referrer.isEmpty) return null;

    // Standard form: `invite_token=abc123`
    final params = Uri.splitQueryString(referrer);
    final token = params['invite_token'];
    if (token != null && token.isNotEmpty) return token;

    // Fallback: try URL-decoding the referrer and re-parse.
    // Handles double-encoded referrers on some Play Store versions.
    try {
      final decoded = Uri.decodeComponent(referrer);
      if (decoded == referrer) return null; // Nothing to decode, already tried
      final decodedParams = Uri.splitQueryString(decoded);
      final decodedToken = decodedParams['invite_token'];
      if (decodedToken != null && decodedToken.isNotEmpty) return decodedToken;
    } catch (_) {
      // Malformed referrer — return null
    }

    return null;
  }
}

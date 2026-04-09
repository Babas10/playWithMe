// iOS implementation of DeferredDeepLinkService.
//
// Reads the clipboard on first launch to recover the invite token written by
// invite.html (Story 19.1). The clipboard contains `gatherli://invite/{token}`
// after the user taps the App Store button on the invite page.
//
// iOS 16+ shows a system consent prompt ("Allow Gatherli to paste from…?").
// If the user denies, Clipboard.getData returns null — handled gracefully.
import 'package:flutter/services.dart';
import 'package:play_with_me/core/services/deferred_deep_link/deferred_deep_link_service.dart';

/// Thin abstraction over Flutter's Clipboard API, extracted for unit-test
/// injection (mirrors the InstallReferrerClient pattern from Story 19.2).
abstract class ClipboardReader {
  Future<String?> read();
  Future<void> clear();
}

/// Production implementation — delegates to Flutter's Clipboard.
class FlutterClipboardReader implements ClipboardReader {
  @override
  Future<String?> read() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  @override
  Future<void> clear() async {
    await Clipboard.setData(const ClipboardData(text: ''));
  }
}

/// Reads the clipboard on first launch and extracts the invite token written
/// by invite.html's iOS tap handler (`gatherli://invite/{token}`).
///
/// Clears the clipboard immediately after reading to prevent re-processing
/// the same token on subsequent launches.
///
/// Only registered on iOS via service_locator.dart.
class IosDeferredDeepLinkService implements DeferredDeepLinkService {
  static const _inviteSchemePrefix = 'gatherli://invite/';

  final ClipboardReader _clipboard;

  IosDeferredDeepLinkService({ClipboardReader? clipboard})
    : _clipboard = clipboard ?? FlutterClipboardReader();

  @override
  Future<String?> retrieveDeferredToken() async {
    try {
      final text = await _clipboard.read() ?? '';

      if (!text.startsWith(_inviteSchemePrefix)) return null;

      final token = text.substring(_inviteSchemePrefix.length).trim();
      if (token.isEmpty) return null;

      // Clear immediately — prevents the same token firing on next cold start.
      await _clipboard.clear();

      return token;
    } catch (_) {
      // Clipboard access denied or unavailable — silent failure, no crash.
      return null;
    }
  }
}

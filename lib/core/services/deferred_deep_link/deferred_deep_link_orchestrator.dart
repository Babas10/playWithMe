// Orchestrates the one-time deferred token check on first app launch.
//
// Runs the platform-specific DeferredDeepLinkService (Android or iOS),
// stores any recovered token in PendingInviteStorage, and sets a
// SharedPreferences flag so the check never runs again.
//
// Called in main_common.dart after DI is initialised and before runApp(),
// so the token is already in PendingInviteStorage when DeepLinkBloc
// processes InitializeDeepLinks.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:play_with_me/core/services/deferred_deep_link/deferred_deep_link_service.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';

class DeferredDeepLinkOrchestrator {
  final DeferredDeepLinkService? _service;
  final PendingInviteStorage _storage;
  final SharedPreferences _prefs;

  /// SharedPreferences key that marks the deferred check as completed.
  static const checkedKey = 'deferred_deep_link_checked';

  /// Maximum time to wait for the platform service before giving up.
  /// Prevents a misbehaving Play Store / clipboard API from freezing startup.
  /// Overridable in tests via the [timeoutDuration] constructor parameter.
  static const defaultTimeout = Duration(seconds: 5);

  final Duration _timeoutDuration;

  DeferredDeepLinkOrchestrator({
    required DeferredDeepLinkService? service,
    required PendingInviteStorage storage,
    required SharedPreferences prefs,
    Duration? timeoutDuration,
  })  : _service = service,
        _storage = storage,
        _prefs = prefs,
        _timeoutDuration = timeoutDuration ?? defaultTimeout;

  /// Runs the deferred token check once on first launch.
  ///
  /// On all subsequent launches the SharedPreferences flag prevents the
  /// service from being called again. Returns the recovered token, or null
  /// if no token was found or the check was skipped.
  ///
  /// Times out after [_timeout] and degrades gracefully on all errors.
  Future<String?> checkOnce() async {
    // No-op on web or any platform without a registered service.
    final service = _service;
    if (service == null) return null;

    // Guard: only run once ever.
    if (_prefs.getBool(checkedKey) == true) return null;

    // Mark as checked immediately — prevents retries even if service throws.
    await _prefs.setBool(checkedKey, true);

    try {
      final token = await service
          .retrieveDeferredToken()
          .timeout(_timeoutDuration, onTimeout: () => null);
      if (token != null) {
        await _storage.store(token);
      }
      return token;
    } catch (_) {
      // Service failed — the invite flow degrades gracefully.
      return null;
    }
  }
}

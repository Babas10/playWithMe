// Abstract service for recovering a deferred invite token on first app launch.
abstract class DeferredDeepLinkService {
  /// Returns the invite token preserved through the app install process, or
  /// null if no deferred token is available.
  ///
  /// Must be called only once on first launch. Subsequent calls may return
  /// null because the underlying referrer data is consumed on first read.
  Future<String?> retrieveDeferredToken();
}

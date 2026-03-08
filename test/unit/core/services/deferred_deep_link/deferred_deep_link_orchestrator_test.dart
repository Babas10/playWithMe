// Validates DeferredDeepLinkOrchestrator runs the deferred check exactly once
// on first launch, stores recovered tokens, and is a no-op on subsequent
// launches and on platforms with no DeferredDeepLinkService.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:play_with_me/core/services/deferred_deep_link/deferred_deep_link_orchestrator.dart';
import 'package:play_with_me/core/services/deferred_deep_link/deferred_deep_link_service.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';

// ---------------------------------------------------------------------------
// Hand-crafted fakes — avoids both Mocktail concrete-class issues and the
// flutter_test timing bug where stored async closures interact poorly with
// Future.timeout (async method bodies work correctly; closures do not).
// ---------------------------------------------------------------------------

/// Returns the given token from a proper async method (not a stored closure).
class _TokenService implements DeferredDeepLinkService {
  final String _token;
  int callCount = 0;
  _TokenService(this._token);

  @override
  Future<String?> retrieveDeferredToken() async {
    callCount++;
    return _token;
  }
}

/// Always returns null.
class _NullService implements DeferredDeepLinkService {
  int callCount = 0;

  @override
  Future<String?> retrieveDeferredToken() async {
    callCount++;
    return null;
  }
}

/// Always throws to simulate a broken platform channel.
class _ThrowingService implements DeferredDeepLinkService {
  int callCount = 0;

  @override
  Future<String?> retrieveDeferredToken() async {
    callCount++;
    throw Exception('Platform channel unavailable');
  }
}

/// Delays for [delay] before returning [result] to exercise the timeout path.
class _DelayedService implements DeferredDeepLinkService {
  final Duration _delay;
  final String? _result;

  _DelayedService(this._delay, this._result);

  @override
  Future<String?> retrieveDeferredToken() =>
      Future.delayed(_delay, () => _result);
}

/// Records calls to store() so tests can assert without Mocktail.
class _FakeStorage implements PendingInviteStorage {
  String? lastStored;

  @override
  Future<void> store(String token) async {
    lastStored = token;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

/// Minimal SharedPreferences fake backed by an in-memory map.
class _FakePrefs implements SharedPreferences {
  final Map<String, Object> _data;

  _FakePrefs([Map<String, Object>? initial])
      : _data = Map.of(initial ?? {});

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<bool> setBool(String key, bool value) {
    _data[key] = value;
    return Future.value(true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

// ---------------------------------------------------------------------------
// Builder
// ---------------------------------------------------------------------------

DeferredDeepLinkOrchestrator _build({
  DeferredDeepLinkService? service,
  _FakeStorage? storage,
  SharedPreferences? prefs,
  Duration timeout = const Duration(milliseconds: 200),
}) {
  return DeferredDeepLinkOrchestrator(
    service: service,
    storage: storage ?? _FakeStorage(),
    prefs: prefs ?? _FakePrefs(),
    timeoutDuration: timeout,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DeferredDeepLinkOrchestrator.checkOnce', () {
    group('first launch — with token', () {
      test('returns the recovered token', () async {
        final result = await _build(service: _TokenService('abc123')).checkOnce();
        expect(result, 'abc123');
      });

      test('stores the token in PendingInviteStorage', () async {
        final storage = _FakeStorage();
        await _build(service: _TokenService('abc123'), storage: storage).checkOnce();
        expect(storage.lastStored, 'abc123');
      });

      test('sets the checked flag in SharedPreferences', () async {
        final prefs = _FakePrefs();
        await _build(service: _TokenService('abc123'), prefs: prefs).checkOnce();
        expect(prefs.getBool(DeferredDeepLinkOrchestrator.checkedKey), true);
      });

      test('calls service exactly once', () async {
        final svc = _TokenService('abc123');
        await _build(service: svc).checkOnce();
        expect(svc.callCount, 1);
      });
    });

    group('first launch — no token', () {
      test('returns null', () async {
        final result = await _build(service: _NullService()).checkOnce();
        expect(result, isNull);
      });

      test('does not call storage.store when no token', () async {
        final storage = _FakeStorage();
        await _build(service: _NullService(), storage: storage).checkOnce();
        expect(storage.lastStored, isNull);
      });

      test('still sets the checked flag', () async {
        final prefs = _FakePrefs();
        await _build(service: _NullService(), prefs: prefs).checkOnce();
        expect(prefs.getBool(DeferredDeepLinkOrchestrator.checkedKey), true);
      });
    });

    group('subsequent launches (flag already set)', () {
      late _FakePrefs prefsWithFlag;

      setUp(() {
        prefsWithFlag =
            _FakePrefs({DeferredDeepLinkOrchestrator.checkedKey: true});
      });

      test('returns null immediately', () async {
        final result =
            await _build(service: _TokenService('abc123'), prefs: prefsWithFlag)
                .checkOnce();
        expect(result, isNull);
      });

      test('never calls the service', () async {
        final svc = _TokenService('abc123');
        await _build(service: svc, prefs: prefsWithFlag).checkOnce();
        expect(svc.callCount, 0);
      });

      test('never calls storage', () async {
        final storage = _FakeStorage();
        await _build(
          service: _TokenService('abc123'),
          storage: storage,
          prefs: prefsWithFlag,
        ).checkOnce();
        expect(storage.lastStored, isNull);
      });

      test('never writes the flag again', () async {
        // Flag is already true — calling checkOnce should not modify prefs.
        final before = prefsWithFlag._data.length;
        await _build(service: _TokenService('abc123'), prefs: prefsWithFlag)
            .checkOnce();
        expect(prefsWithFlag._data.length, before);
      });
    });

    group('exception handling', () {
      test('returns null when service throws', () async {
        final result = await _build(service: _ThrowingService()).checkOnce();
        expect(result, isNull);
      });

      test('still sets the checked flag when service throws', () async {
        final prefs = _FakePrefs();
        await _build(service: _ThrowingService(), prefs: prefs).checkOnce();
        expect(prefs.getBool(DeferredDeepLinkOrchestrator.checkedKey), true);
      });

      test('does not retry on subsequent calls after exception', () async {
        final svc = _ThrowingService();
        final orchestrator = _build(service: svc);
        await orchestrator.checkOnce(); // first call: sets flag, catches error
        await orchestrator.checkOnce(); // second call: flag already set, skips
        expect(svc.callCount, 1);
      });

      test('returns null when service times out', () async {
        // 500ms delay with a 200ms orchestrator timeout → timeout fires first.
        final result = await _build(
          service: _DelayedService(const Duration(milliseconds: 500), 'abc123'),
        ).checkOnce();
        expect(result, isNull);
      });

      test('sets checked flag even when service times out', () async {
        final prefs = _FakePrefs();
        await _build(
          service: _DelayedService(const Duration(milliseconds: 500), null),
          prefs: prefs,
        ).checkOnce();
        expect(prefs.getBool(DeferredDeepLinkOrchestrator.checkedKey), true);
      });
    });

    group('no-op when service is null (web / unsupported platform)', () {
      test('returns null with no service', () async {
        final result = await _build(service: null).checkOnce();
        expect(result, isNull);
      });

      test('does not call storage when service is null', () async {
        final storage = _FakeStorage();
        await _build(service: null, storage: storage).checkOnce();
        expect(storage.lastStored, isNull);
      });

      test('does not set the checked flag when service is null', () async {
        final prefs = _FakePrefs();
        await _build(service: null, prefs: prefs).checkOnce();
        expect(prefs.getBool(DeferredDeepLinkOrchestrator.checkedKey), isNull);
      });

      test('can be called repeatedly without error', () async {
        final orchestrator = _build(service: null);
        expect(await orchestrator.checkOnce(), isNull);
        expect(await orchestrator.checkOnce(), isNull);
      });
    });
  });
}

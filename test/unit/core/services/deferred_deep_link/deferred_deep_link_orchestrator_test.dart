// Validates DeferredDeepLinkOrchestrator runs the deferred check exactly once
// on first launch, stores recovered tokens, and is a no-op on subsequent
// launches and on platforms with no DeferredDeepLinkService.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:play_with_me/core/services/deferred_deep_link/deferred_deep_link_orchestrator.dart';
import 'package:play_with_me/core/services/deferred_deep_link/deferred_deep_link_service.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';

class MockDeferredDeepLinkService extends Mock
    implements DeferredDeepLinkService {}

class MockPendingInviteStorage extends Mock implements PendingInviteStorage {}

void main() {
  late MockDeferredDeepLinkService mockService;
  late MockPendingInviteStorage mockStorage;
  late SharedPreferences prefs;

  setUp(() async {
    mockService = MockDeferredDeepLinkService();
    mockStorage = MockPendingInviteStorage();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  DeferredDeepLinkOrchestrator buildOrchestrator({
    DeferredDeepLinkService? service,
  }) {
    return DeferredDeepLinkOrchestrator(
      service: service ?? mockService,
      storage: mockStorage,
      prefs: prefs,
    );
  }

  group('DeferredDeepLinkOrchestrator.checkOnce', () {
    group('first launch — with token', () {
      setUp(() {
        when(() => mockService.retrieveDeferredToken())
            .thenAnswer((_) async => 'abc123');
        when(() => mockStorage.store(any())).thenAnswer((_) async {});
      });

      test('returns the recovered token', () async {
        final orchestrator = buildOrchestrator();
        final result = await orchestrator.checkOnce();
        expect(result, 'abc123');
      });

      test('stores the token in PendingInviteStorage', () async {
        final orchestrator = buildOrchestrator();
        await orchestrator.checkOnce();
        verify(() => mockStorage.store('abc123')).called(1);
      });

      test('sets the checked flag in SharedPreferences', () async {
        final orchestrator = buildOrchestrator();
        await orchestrator.checkOnce();
        expect(prefs.getBool(DeferredDeepLinkOrchestrator.checkedKey), true);
      });

      test('calls service exactly once', () async {
        final orchestrator = buildOrchestrator();
        await orchestrator.checkOnce();
        verify(() => mockService.retrieveDeferredToken()).called(1);
      });
    });

    group('first launch — no token', () {
      setUp(() {
        when(() => mockService.retrieveDeferredToken())
            .thenAnswer((_) async => null);
      });

      test('returns null', () async {
        final orchestrator = buildOrchestrator();
        final result = await orchestrator.checkOnce();
        expect(result, isNull);
      });

      test('does not call storage.store when no token', () async {
        final orchestrator = buildOrchestrator();
        await orchestrator.checkOnce();
        verifyNever(() => mockStorage.store(any()));
      });

      test('still sets the checked flag', () async {
        final orchestrator = buildOrchestrator();
        await orchestrator.checkOnce();
        expect(prefs.getBool(DeferredDeepLinkOrchestrator.checkedKey), true);
      });
    });

    group('subsequent launches (flag already set)', () {
      setUp(() async {
        await prefs.setBool(DeferredDeepLinkOrchestrator.checkedKey, true);
      });

      test('returns null immediately', () async {
        final orchestrator = buildOrchestrator();
        final result = await orchestrator.checkOnce();
        expect(result, isNull);
      });

      test('never calls the service', () async {
        final orchestrator = buildOrchestrator();
        await orchestrator.checkOnce();
        verifyNever(() => mockService.retrieveDeferredToken());
      });

      test('never calls storage', () async {
        final orchestrator = buildOrchestrator();
        await orchestrator.checkOnce();
        verifyNever(() => mockStorage.store(any()));
      });
    });

    group('exception handling', () {
      test('returns null when service throws', () async {
        when(() => mockService.retrieveDeferredToken())
            .thenThrow(Exception('Platform channel unavailable'));
        final orchestrator = buildOrchestrator();
        final result = await orchestrator.checkOnce();
        expect(result, isNull);
      });

      test('still sets the checked flag when service throws', () async {
        when(() => mockService.retrieveDeferredToken())
            .thenThrow(Exception('Platform channel unavailable'));
        final orchestrator = buildOrchestrator();
        await orchestrator.checkOnce();
        expect(prefs.getBool(DeferredDeepLinkOrchestrator.checkedKey), true);
      });

      test('does not retry on subsequent calls after exception', () async {
        when(() => mockService.retrieveDeferredToken())
            .thenThrow(Exception('Platform channel unavailable'));
        final orchestrator = buildOrchestrator();
        await orchestrator.checkOnce();
        await orchestrator.checkOnce(); // second call
        // service should only have been called once (flag set before service call)
        verify(() => mockService.retrieveDeferredToken()).called(1);
      });
    });

    group('no-op when service is null (web / unsupported platform)', () {
      test('returns null with no service', () async {
        final orchestrator = buildOrchestrator(service: null);
        final result = await orchestrator.checkOnce();
        expect(result, isNull);
      });

      test('does not call storage when service is null', () async {
        final orchestrator = buildOrchestrator(service: null);
        await orchestrator.checkOnce();
        verifyNever(() => mockStorage.store(any()));
      });

      test('can be called repeatedly without error when service is null', () async {
        final orchestrator = buildOrchestrator(service: null);
        // Should never throw and always return null
        expect(await orchestrator.checkOnce(), isNull);
        expect(await orchestrator.checkOnce(), isNull);
      });
    });
  });
}

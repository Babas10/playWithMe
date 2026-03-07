// Validates AndroidDeferredDeepLinkService correctly parses the Play Store
// referrer string and extracts the invite token (or returns null gracefully).
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/services/deferred_deep_link/android_deferred_deep_link_service.dart';

class MockInstallReferrerClient extends Mock implements InstallReferrerClient {}

void main() {
  late MockInstallReferrerClient mockClient;
  late AndroidDeferredDeepLinkService service;

  setUp(() {
    mockClient = MockInstallReferrerClient();
    service = AndroidDeferredDeepLinkService(client: mockClient);
  });

  group('AndroidDeferredDeepLinkService.retrieveDeferredToken', () {
    test('returns token for valid invite_token referrer', () async {
      when(() => mockClient.getReferrerString())
          .thenAnswer((_) async => 'invite_token=abc123');

      final token = await service.retrieveDeferredToken();

      expect(token, 'abc123');
    });

    test('returns token for referrer with multiple params', () async {
      when(() => mockClient.getReferrerString())
          .thenAnswer((_) async => 'utm_source=email&invite_token=xyz789&utm_medium=social');

      final token = await service.retrieveDeferredToken();

      expect(token, 'xyz789');
    });

    test('returns null when referrer has no invite_token param', () async {
      when(() => mockClient.getReferrerString())
          .thenAnswer((_) async => 'utm_source=other&utm_medium=email');

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('returns null when referrer is empty string', () async {
      when(() => mockClient.getReferrerString())
          .thenAnswer((_) async => '');

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('returns null when client returns null', () async {
      when(() => mockClient.getReferrerString())
          .thenAnswer((_) async => null);

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('returns null when client throws (graceful error handling)', () async {
      when(() => mockClient.getReferrerString())
          .thenThrow(Exception('Referrer API unavailable'));

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('handles URL-encoded referrer string (double-encoded form)', () async {
      // In some Play Store versions the referrer may arrive double-encoded:
      // invite_token%3Dabc123 instead of invite_token=abc123
      when(() => mockClient.getReferrerString())
          .thenAnswer((_) async => 'invite_token%3Dabc123');

      final token = await service.retrieveDeferredToken();

      expect(token, 'abc123');
    });

    test('returns null for malformed referrer string', () async {
      when(() => mockClient.getReferrerString())
          .thenAnswer((_) async => '%%%invalid%%%');

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('returns null when invite_token value is empty', () async {
      when(() => mockClient.getReferrerString())
          .thenAnswer((_) async => 'invite_token=');

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });
  });
}

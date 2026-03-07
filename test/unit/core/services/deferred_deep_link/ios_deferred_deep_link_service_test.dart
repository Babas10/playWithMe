// Validates IosDeferredDeepLinkService correctly reads the invite token from
// the clipboard and clears it after extraction (or returns null gracefully).
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/services/deferred_deep_link/ios_deferred_deep_link_service.dart';

class MockClipboardReader extends Mock implements ClipboardReader {}

void main() {
  late MockClipboardReader mockClipboard;
  late IosDeferredDeepLinkService service;

  setUp(() {
    mockClipboard = MockClipboardReader();
    service = IosDeferredDeepLinkService(clipboard: mockClipboard);
  });

  group('IosDeferredDeepLinkService.retrieveDeferredToken', () {
    test('returns token from valid gatherli://invite/ clipboard content', () async {
      when(() => mockClipboard.read())
          .thenAnswer((_) async => 'gatherli://invite/abc123');
      when(() => mockClipboard.clear()).thenAnswer((_) async {});

      final token = await service.retrieveDeferredToken();

      expect(token, 'abc123');
    });

    test('clears clipboard after successfully extracting a valid token', () async {
      when(() => mockClipboard.read())
          .thenAnswer((_) async => 'gatherli://invite/abc123');
      when(() => mockClipboard.clear()).thenAnswer((_) async {});

      await service.retrieveDeferredToken();

      verify(() => mockClipboard.clear()).called(1);
    });

    test('returns null for wrong scheme (https URL)', () async {
      when(() => mockClipboard.read())
          .thenAnswer((_) async => 'https://gatherli.org/invite/abc123');

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('returns null for unrelated clipboard content', () async {
      when(() => mockClipboard.read())
          .thenAnswer((_) async => 'some random text copied by user');

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('returns null when clipboard is empty string', () async {
      when(() => mockClipboard.read()).thenAnswer((_) async => '');

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('returns null when clipboard read returns null', () async {
      when(() => mockClipboard.read()).thenAnswer((_) async => null);

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('returns null for gatherli://invite/ with empty token segment', () async {
      when(() => mockClipboard.read())
          .thenAnswer((_) async => 'gatherli://invite/');

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('returns null when clipboard read throws (iOS consent denied)', () async {
      when(() => mockClipboard.read())
          .thenThrow(Exception('Clipboard access denied'));

      final token = await service.retrieveDeferredToken();

      expect(token, isNull);
    });

    test('does not clear clipboard when no valid token found', () async {
      when(() => mockClipboard.read())
          .thenAnswer((_) async => 'https://other.com/link');

      await service.retrieveDeferredToken();

      verifyNever(() => mockClipboard.clear());
    });

    test('trims whitespace from extracted token', () async {
      when(() => mockClipboard.read())
          .thenAnswer((_) async => 'gatherli://invite/  token123  ');
      when(() => mockClipboard.clear()).thenAnswer((_) async {});

      final token = await service.retrieveDeferredToken();

      expect(token, 'token123');
    });
  });
}

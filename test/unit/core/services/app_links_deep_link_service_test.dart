// Validates AppLinksDeepLinkService correctly extracts invite tokens from
// HTTPS (gatherli.org) and custom scheme (gatherli://) deep link URIs.
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/services/app_links_deep_link_service.dart';

class MockAppLinks extends Mock implements AppLinks {}

void main() {
  late MockAppLinks mockAppLinks;
  late StreamController<Uri> linkStreamController;

  setUp(() {
    mockAppLinks = MockAppLinks();
    linkStreamController = StreamController<Uri>.broadcast();
    when(() => mockAppLinks.uriLinkStream)
        .thenAnswer((_) => linkStreamController.stream);
  });

  tearDown(() {
    linkStreamController.close();
  });

  AppLinksDeepLinkService buildService() {
    return AppLinksDeepLinkService(appLinks: mockAppLinks);
  }

  group('AppLinksDeepLinkService', () {
    group('getInitialInviteToken — HTTPS deep links (gatherli.org)', () {
      test('extracts token from https://gatherli.org/invite/{token}', () async {
        when(() => mockAppLinks.getInitialLink()).thenAnswer(
          (_) async => Uri.parse('https://gatherli.org/invite/abc123'),
        );
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, 'abc123');
        service.dispose();
      });

      test('returns null when HTTPS path has no invite segment', () async {
        when(() => mockAppLinks.getInitialLink()).thenAnswer(
          (_) async => Uri.parse('https://gatherli.org/other/abc123'),
        );
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, isNull);
        service.dispose();
      });

      test('returns null when HTTPS invite token is empty', () async {
        when(() => mockAppLinks.getInitialLink()).thenAnswer(
          (_) async => Uri.parse('https://gatherli.org/invite/'),
        );
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, isNull);
        service.dispose();
      });

      test('returns null when HTTPS path has too many segments', () async {
        when(() => mockAppLinks.getInitialLink()).thenAnswer(
          (_) async =>
              Uri.parse('https://gatherli.org/invite/abc123/extra'),
        );
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, isNull);
        service.dispose();
      });
    });

    group('getInitialInviteToken — custom scheme (gatherli://)', () {
      test('extracts token from gatherli://invite/{token}', () async {
        when(() => mockAppLinks.getInitialLink()).thenAnswer(
          (_) async => Uri.parse('gatherli://invite/xyz789'),
        );
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, 'xyz789');
        service.dispose();
      });

      test('returns null when custom scheme host is not invite', () async {
        when(() => mockAppLinks.getInitialLink()).thenAnswer(
          (_) async => Uri.parse('gatherli://other/xyz789'),
        );
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, isNull);
        service.dispose();
      });

      test('returns null for unknown scheme', () async {
        when(() => mockAppLinks.getInitialLink()).thenAnswer(
          (_) async => Uri.parse('unknown://invite/abc123'),
        );
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, isNull);
        service.dispose();
      });

      test('returns null when custom scheme token is empty', () async {
        when(() => mockAppLinks.getInitialLink()).thenAnswer(
          (_) async => Uri.parse('gatherli://invite/'),
        );
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, isNull);
        service.dispose();
      });
    });

    group('getInitialInviteToken — null / error handling', () {
      test('returns null when no initial link', () async {
        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => null);
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, isNull);
        service.dispose();
      });

      test('returns null when getInitialLink throws', () async {
        when(() => mockAppLinks.getInitialLink())
            .thenThrow(Exception('platform error'));
        final service = buildService();
        final token = await service.getInitialInviteToken();
        expect(token, isNull);
        service.dispose();
      });
    });

    group('inviteTokenStream — foreground deep links', () {
      test('emits token when HTTPS deep link received on stream', () async {
        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => null);
        final service = buildService();

        expectLater(service.inviteTokenStream, emits('stream-token-https'));

        linkStreamController
            .add(Uri.parse('https://gatherli.org/invite/stream-token-https'));

        await Future.delayed(const Duration(milliseconds: 50));
        service.dispose();
      });

      test('emits token when custom scheme deep link received on stream',
          () async {
        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => null);
        final service = buildService();

        expectLater(service.inviteTokenStream, emits('stream-token-custom'));

        linkStreamController
            .add(Uri.parse('gatherli://invite/stream-token-custom'));

        await Future.delayed(const Duration(milliseconds: 50));
        service.dispose();
      });

      test('does not emit for unrecognised URIs', () async {
        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => null);
        final service = buildService();

        final emitted = <String?>[];
        final sub = service.inviteTokenStream.listen(emitted.add);

        linkStreamController.add(Uri.parse('https://example.com/other/path'));

        await Future.delayed(const Duration(milliseconds: 50));
        expect(emitted, isEmpty);
        await sub.cancel();
        service.dispose();
      });
    });
  });
}

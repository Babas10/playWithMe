// Validates that web/manifest.json and web/index.html contain correct Gatherli branding.
// Story 18.9 — Web: Update manifest.json & Web Firebase Config
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // Resolve paths relative to project root regardless of where tests run from
  final projectRoot = _findProjectRoot();

  group('web/manifest.json branding', () {
    late Map<String, dynamic> manifest;

    setUp(() {
      final file = File('$projectRoot/web/manifest.json');
      manifest = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('name is Gatherli', () {
      expect(manifest['name'], 'Gatherli');
    });

    test('short_name is Gatherli', () {
      expect(manifest['short_name'], 'Gatherli');
    });

    test('description is meaningful (not default Flutter placeholder)', () {
      final description = manifest['description'] as String;
      expect(description, isNot('A new Flutter project.'));
      expect(description, isNotEmpty);
      expect(description, 'Organize and join games with your group.');
    });

    test('does not contain play_with_me references', () {
      final raw = File('$projectRoot/web/manifest.json').readAsStringSync();
      expect(raw.contains('play_with_me'), isFalse,
          reason: 'manifest.json should not contain legacy play_with_me branding');
    });
  });

  group('web/index.html branding', () {
    late String html;

    setUp(() {
      html = File('$projectRoot/web/index.html').readAsStringSync();
    });

    test('<title> is Gatherli', () {
      expect(html, contains('<title>Gatherli</title>'));
    });

    test('apple-mobile-web-app-title is Gatherli', () {
      expect(
        html,
        contains('content="Gatherli"'),
        reason: 'apple-mobile-web-app-title meta tag should reference Gatherli',
      );
    });

    test('meta description is meaningful (not default Flutter placeholder)', () {
      expect(html, isNot(contains('content="A new Flutter project."')));
      expect(html, contains('content="Organize and join games with your group."'));
    });

    test('does not contain play_with_me references', () {
      expect(html.contains('play_with_me'), isFalse,
          reason: 'index.html should not contain legacy play_with_me branding');
    });
  });
}

/// Walks up from the current directory to find the Flutter project root
/// (the directory containing pubspec.yaml).
String _findProjectRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}/pubspec.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Could not find project root (pubspec.yaml not found)');
    }
    dir = parent;
  }
  return dir.path;
}

// Validates that key documentation files contain correct Gatherli branding.
// Story 18.11 — Documentation: Update README, CLAUDE.md & docs/ Folder

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectRoot = _findProjectRoot();

  group('README.md branding', () {
    late String content;

    setUp(() {
      content = File('$projectRoot/README.md').readAsStringSync();
    });

    test('title is Gatherli', () {
      expect(content, contains('# Gatherli'));
    });

    test('does not contain legacy playWithMe title', () {
      expect(content, isNot(contains('# playWithMe')));
    });

    test('does not contain PlayWithMe brand name', () {
      expect(
        content,
        isNot(contains('PlayWithMe')),
        reason: 'README.md should not reference the legacy PlayWithMe brand',
      );
    });

    test('references Gatherli environments', () {
      expect(content, contains('gatherli-dev'));
      expect(content, contains('gatherli-prod'));
    });
  });

  group('CLAUDE.md branding', () {
    late String content;

    setUp(() {
      content = File('$projectRoot/CLAUDE.md').readAsStringSync();
    });

    test('project header is Gatherli', () {
      expect(content, contains('*Gatherli'));
    });

    test('section 1 vision names Gatherli', () {
      expect(content, contains('**Gatherli** is a Flutter mobile app'));
    });

    test('does not contain PlayWithMe as app name in vision section', () {
      expect(content, isNot(contains('**PlayWithMe** is a Flutter')));
    });

    test('environment table uses gatherli project IDs', () {
      expect(content, contains('gatherli-dev'));
      expect(content, contains('gatherli-prod'));
    });

    test('does not contain old playwithme Firebase project IDs', () {
      expect(content, isNot(contains('playwithme-dev')));
      expect(content, isNot(contains('playwithme-stg')));
      expect(content, isNot(contains('playwithme-prod')));
    });

    test('emulator command references gatherli-dev', () {
      expect(
        content,
        contains(
          'firebase emulators:start --only auth,firestore --project gatherli-dev',
        ),
      );
    });

    test('section 10 names Gatherli app', () {
      expect(content, contains('the Gatherli app has completed'));
    });
  });

  group('docs/README.md branding', () {
    late String content;

    setUp(() {
      content = File('$projectRoot/docs/README.md').readAsStringSync();
    });

    test('title is Gatherli Documentation', () {
      expect(content, contains('# Gatherli Documentation'));
    });

    test('does not contain PlayWithMe Documentation title', () {
      expect(content, isNot(contains('# PlayWithMe Documentation')));
    });

    test('does not contain PlayWithMe app references', () {
      expect(content, isNot(contains('PlayWithMe app')));
    });
  });

  group('functions/README.md branding', () {
    late String content;

    setUp(() {
      content = File('$projectRoot/functions/README.md').readAsStringSync();
    });

    test('title is Gatherli Cloud Functions', () {
      expect(content, contains('# Gatherli Cloud Functions'));
    });

    test('does not contain PlayWithMe Cloud Functions title', () {
      expect(content, isNot(contains('# PlayWithMe Cloud Functions')));
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

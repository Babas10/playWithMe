import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/services/service_locator.dart';

void main() {
  group('Service Locator', () {
    tearDown(() {
      sl.reset();
    });

    test('should initialize dependencies without errors', () async {
      expect(() async => await initializeDependencies(), returnsNormally);
    });

    test('should be able to call initializeDependencies multiple times', () async {
      await initializeDependencies();
      expect(() async => await initializeDependencies(), returnsNormally);
    });
  });
}
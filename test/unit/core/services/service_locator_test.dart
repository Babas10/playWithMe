import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/services/service_locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Locator', () {
    setUp(() {
      // Set up mock method channel for SharedPreferences
      const MethodChannel('plugins.flutter.io/shared_preferences')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        return null;
      });
    });

    tearDown(() {
      sl.reset();
    });

    test('should initialize dependencies without errors', () async {
      await expectLater(initializeDependencies(), completes);
    });

    test('should be able to call initializeDependencies multiple times', () async {
      await initializeDependencies();
      await expectLater(initializeDependencies(), completes);
    });
  });
}
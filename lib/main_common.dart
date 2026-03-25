import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:play_with_me/app/play_with_me_app.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/services/firebase_service.dart';
import 'package:play_with_me/core/services/deferred_deep_link/deferred_deep_link_orchestrator.dart';

Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase before anything else
    await FirebaseService.initialize();

    // Route Flutter framework errors (widget build failures, layout errors, etc.)
    // to Crashlytics. Disabled in debug mode so the development console stays clean.
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Route uncaught async/platform errors (Dart isolate errors, plugin errors)
    // to Crashlytics.
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Initialize dependency injection
    await initializeDependencies();

    // Run the deferred deep link check once on first launch.
    // Stores any recovered token in PendingInviteStorage before runApp() so
    // that DeepLinkBloc.InitializeDeepLinks picks it up automatically.
    await sl<DeferredDeepLinkOrchestrator>().checkOnce();

    runApp(const PlayWithMeApp());

  } catch (e) {
    debugPrint('❌ App initialization failed: $e');

    // Run app with error state
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $e',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
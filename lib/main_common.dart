import 'package:flutter/material.dart';
import 'package:play_with_me/app/play_with_me_app.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/core/services/firebase_service.dart';

Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase before anything else
    await FirebaseService.initialize();

    // Initialize dependency injection
    await initializeDependencies();

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
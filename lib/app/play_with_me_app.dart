import 'package:flutter/material.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/widgets/environment_indicator.dart';
import 'package:play_with_me/core/services/firebase_service.dart';

class PlayWithMeApp extends StatelessWidget {
  const PlayWithMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayWithMe${EnvironmentConfig.appSuffix}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Environment indicator at the top
              const EnvironmentIndicator(showDetails: true),

              // App bar
              AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text('PlayWithMe${EnvironmentConfig.appSuffix}'),
              ),

              // Main content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Welcome to PlayWithMe!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Beach volleyball games organizer',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: EnvironmentConfig.isDevelopment
                              ? Colors.red.withValues(alpha: 0.1)
                              : EnvironmentConfig.isStaging
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                          border: Border.all(
                            color: EnvironmentConfig.isDevelopment
                                ? Colors.red
                                : EnvironmentConfig.isStaging
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FirebaseService.isInitialized
                                      ? Icons.cloud_done
                                      : Icons.cloud_off,
                                  size: 16,
                                  color: FirebaseService.isInitialized
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Firebase: ${FirebaseService.isInitialized ? "Connected" : "Disconnected"}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Environment: ${EnvironmentConfig.environmentName}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Project: ${EnvironmentConfig.firebaseProjectId}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Debug panel for development
          const FirebaseDebugPanel(),
        ],
      ),
    );
  }
}
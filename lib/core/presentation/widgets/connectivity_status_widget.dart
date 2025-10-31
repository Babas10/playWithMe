import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'offline_banner.dart';

/// Widget that monitors connectivity status and displays offline banner.
///
/// Automatically shows/hides the [OfflineBanner] based on device connectivity.
class ConnectivityStatusWidget extends StatelessWidget {
  const ConnectivityStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      initialData: const [ConnectivityResult.wifi], // Assume online initially
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];
        final isOffline = results.isEmpty ||
                         results.every((result) => result == ConnectivityResult.none);

        return isOffline ? const OfflineBanner() : const SizedBox.shrink();
      },
    );
  }
}

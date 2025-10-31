import 'package:flutter/material.dart';

/// Helper functions for displaying error messages as snackbars.
class ErrorSnackbar {
  /// Shows an error snackbar with an optional retry button.
  ///
  /// [context] - The build context
  /// [message] - The error message to display
  /// [isRetryable] - Whether to show a retry button
  /// [onRetry] - Callback when retry button is pressed
  static void show(
    BuildContext context,
    String message, {
    bool isRetryable = true,
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        action: (isRetryable && onRetry != null)
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows a success snackbar.
  ///
  /// [context] - The build context
  /// [message] - The success message to display
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows an info snackbar.
  ///
  /// [context] - The build context
  /// [message] - The info message to display
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an offline notification snackbar.
  ///
  /// [context] - The build context
  static void showOffline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('You\'re offline. Changes will sync when online.'),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

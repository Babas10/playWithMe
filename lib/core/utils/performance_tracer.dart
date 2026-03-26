// Thin wrapper around FirebasePerformance for custom traces.
// Traces are no-ops in debug mode — only active in release/profile builds.
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class PerformanceTracer {
  PerformanceTracer._();

  /// Runs [operation] wrapped in a custom trace named [traceName].
  /// The trace is started before [operation] and stopped in a finally block.
  /// In debug mode the trace is skipped entirely to avoid polluting metrics.
  static Future<T> trace<T>(
    String traceName,
    Future<T> Function() operation,
  ) async {
    if (kDebugMode) {
      return operation();
    }

    final trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();
    try {
      return await operation();
    } finally {
      await trace.stop();
    }
  }
}

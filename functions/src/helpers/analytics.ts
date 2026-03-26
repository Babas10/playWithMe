// Helper for writing product analytics events to Firestore.
// Non-blocking: errors are logged but never propagate to the caller.
// Story 24.2: Instrument Cloud Function triggers with analytics events
// Story 25.2: Add writePerformanceEvent for Cloud Function execution timing

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

/**
 * Write a product analytics event to the `analytics_events` collection.
 * Wrapped in its own try/catch so a Firestore write failure never blocks
 * or fails the trigger that called it.
 *
 * Privacy: never include UIDs, display names, or email addresses in properties.
 */
export async function writeAnalyticsEvent(
  event: string,
  properties: Record<string, unknown> = {}
): Promise<void> {
  try {
    await admin.firestore().collection("analytics_events").add({
      event,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      properties,
    });
  } catch (err) {
    functions.logger.error("[analytics] Failed to write event", { event, err });
  }
}

/**
 * Write a Cloud Function execution performance event to `analytics_events`.
 * Also emits a structured JSON log for Google Cloud Logging visibility.
 * Non-blocking: errors are logged but never propagate to the caller.
 */
export async function writePerformanceEvent(params: {
  functionName: string;
  durationMs: number;
  uid: string | undefined;
  status: "success" | "error";
  metadata?: Record<string, unknown>;
}): Promise<void> {
  const { functionName, durationMs, uid, status, metadata = {} } = params;

  // Structured log for Google Cloud Logging
  console.log(JSON.stringify({
    type: "performance",
    function: functionName,
    durationMs,
    status,
    uid: uid ?? null,
  }));

  try {
    await admin.firestore().collection("analytics_events").add({
      eventType: "function_performance",
      functionName,
      durationMs,
      uid: uid ?? null,
      status,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      metadata,
    });
  } catch (err) {
    functions.logger.error("[analytics] Failed to write performance event", {
      functionName,
      err,
    });
  }
}

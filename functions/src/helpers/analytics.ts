// Helper for writing product analytics events to Firestore.
// Non-blocking: errors are logged but never propagate to the caller.
// Story 24.2: Instrument Cloud Function triggers with analytics events

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

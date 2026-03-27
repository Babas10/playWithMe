import * as functions from "firebase-functions";

export interface HealthCheckResponse {
  status: "ok";
  timestamp: number;
}

/**
 * Handler for healthCheck (exported for unit testing).
 */
export async function healthCheckHandler(
  _data: unknown,
  _context: functions.https.CallableContext
): Promise<HealthCheckResponse> {
  functions.logger.info("healthCheck called");
  return {status: "ok", timestamp: Date.now()};
}

/**
 * Minimal smoke-test callable.
 * Returns { status: "ok", timestamp: <ms> } on every invocation.
 * Used by the post-deploy smoke test in cd-beta.yml and cd-production.yml
 * to confirm that functions are running after a deployment.
 */
export const healthCheck = functions.region('europe-west6').https.onCall(healthCheckHandler);

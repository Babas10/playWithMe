// Test utilities for Cloud Functions tests
import * as functions from "firebase-functions";

/**
 * Helper to check if an error is a Firebase HttpsError with a specific code
 */
export function expectHttpsError(
  error: any,
  expectedCode: functions.https.FunctionsErrorCode
): void {
  expect(error).toBeInstanceOf(functions.https.HttpsError);
  expect((error as functions.https.HttpsError).code).toBe(expectedCode);
}

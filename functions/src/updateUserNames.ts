// Cloud Function to persist firstName and lastName to Firestore user document.
// This is needed because createUserDocument (Auth onCreate trigger) only has access
// to Firebase Auth fields (email, displayName) — not custom fields like firstName/lastName.
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Callable Cloud Function: updateUserNames
 *
 * Called after account creation to persist firstName and lastName
 * to the authenticated user's Firestore document.
 *
 * @param data.firstName - User's first name (required, min 2 chars)
 * @param data.lastName - User's last name (required, min 2 chars)
 */
export const updateUserNames = functions.https.onCall(async (data, context) => {
  // 1. Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to update your name."
    );
  }

  const uid = context.auth.uid;
  const {firstName, lastName} = data;

  // 2. Validate parameters
  if (!firstName || typeof firstName !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Expected parameter \"firstName\" of type string."
    );
  }

  if (!lastName || typeof lastName !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Expected parameter \"lastName\" of type string."
    );
  }

  const trimmedFirstName = firstName.trim();
  const trimmedLastName = lastName.trim();

  if (trimmedFirstName.length < 2) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "First name must be at least 2 characters."
    );
  }

  if (trimmedLastName.length < 2) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Last name must be at least 2 characters."
    );
  }

  functions.logger.info("[updateUserNames] Updating names", {
    uid,
    firstName: trimmedFirstName,
    lastName: trimmedLastName,
  });

  try {
    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    await userRef.update({
      firstName: trimmedFirstName,
      lastName: trimmedLastName,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info("[updateUserNames] Successfully updated", {uid});

    return {success: true};
  } catch (error) {
    functions.logger.error("[updateUserNames] Error:", {
      uid,
      error: error instanceof Error ? error.message : String(error),
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to update user names. Please try again later."
    );
  }
});

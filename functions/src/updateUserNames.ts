// Cloud Function to persist firstName, lastName, and gender to Firestore user document.
// This is needed because createUserDocument (Auth onCreate trigger) only has access
// to Firebase Auth fields (email, displayName) — not custom fields like firstName/lastName/gender.
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const VALID_GENDERS = ["male", "female", "none"];

/**
 * Callable Cloud Function: updateUserNames
 *
 * Called after account creation to persist firstName, lastName, and gender
 * to the authenticated user's Firestore document.
 *
 * @param data.firstName - User's first name (required, min 2 chars)
 * @param data.lastName - User's last name (required, min 2 chars)
 * @param data.gender - User's gender ('male' | 'female' | 'none') — optional
 */
export const updateUserNames = functions.region('europe-west6').https.onCall(async (data, context) => {
  // 1. Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to update your name."
    );
  }

  const uid = context.auth.uid;
  const {firstName, lastName, gender} = data;

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

  if (gender !== undefined && !VALID_GENDERS.includes(gender)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      `Invalid gender value. Expected one of: ${VALID_GENDERS.join(", ")}.`
    );
  }

  functions.logger.info("[updateUserNames] Updating profile", {
    uid,
    firstName: trimmedFirstName,
    lastName: trimmedLastName,
    gender: gender ?? "not provided",
  });

  try {
    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    const update: Record<string, unknown> = {
      firstName: trimmedFirstName,
      lastName: trimmedLastName,
      displayName: `${trimmedFirstName} ${trimmedLastName}`,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (gender !== undefined) {
      update.gender = gender;
    }

    await userRef.update(update);

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

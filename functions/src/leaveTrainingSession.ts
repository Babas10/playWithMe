// Cloud Function for leaving training sessions
// Updates participants subcollection and denormalized participantIds array
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// ============================================================================
// Type Definitions
// ============================================================================

interface LeaveTrainingSessionRequest {
  sessionId: string;
}

interface LeaveTrainingSessionResponse {
  success: boolean;
  message: string;
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Get training session data
 */
async function getTrainingSessionData(
  db: admin.firestore.Firestore,
  sessionId: string
): Promise<{
  status: string;
  startTime: admin.firestore.Timestamp;
} | null> {
  const sessionDoc = await db.collection("trainingSessions").doc(sessionId).get();

  if (!sessionDoc.exists) {
    return null;
  }

  const sessionData = sessionDoc.data()!;
  return {
    status: sessionData.status || "scheduled",
    startTime: sessionData.startTime,
  };
}

// ============================================================================
// Main Cloud Function
// ============================================================================

export const leaveTrainingSession = functions.https.onCall(
  async (
    data: LeaveTrainingSessionRequest,
    context: functions.https.CallableContext
  ): Promise<LeaveTrainingSessionResponse> => {
    // ============================================================================
    // 1. Authentication Check
    // ============================================================================

    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to leave a training session"
      );
    }

    const userId = context.auth.uid;

    console.log("[leaveTrainingSession] Request from user:", {
      userId,
      sessionId: data.sessionId,
    });

    // ============================================================================
    // 2. Input Validation
    // ============================================================================

    if (!data || !data.sessionId || typeof data.sessionId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Session ID is required"
      );
    }

    const db = admin.firestore();

    // ============================================================================
    // 3. Training Session Validation
    // ============================================================================

    const sessionData = await getTrainingSessionData(db, data.sessionId);

    if (!sessionData) {
      throw new functions.https.HttpsError(
        "not-found",
        "Training session not found"
      );
    }

    // Only allow leaving scheduled sessions
    if (sessionData.status !== "scheduled") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "You can only leave a scheduled training session"
      );
    }

    // ============================================================================
    // 4. Leave Operation (Transaction)
    // ============================================================================

    try {
      const result = await db.runTransaction(async (transaction) => {
        // Check if user is currently a participant
        const participantRef = db
          .collection("trainingSessions")
          .doc(data.sessionId)
          .collection("participants")
          .doc(userId);

        const participantDoc = await transaction.get(participantRef);

        if (!participantDoc.exists) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "You are not a participant of this training session"
          );
        }

        const participantData = participantDoc.data()!;
        if (participantData.status !== "joined") {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "You have already left this training session"
          );
        }

        // Update participant status to 'left'
        transaction.update(participantRef, {
          status: "left",
        });

        // Update denormalized participantIds array in session document
        // Get all current participants with 'joined' status
        const participantsSnapshot = await transaction.get(
          db
            .collection("trainingSessions")
            .doc(data.sessionId)
            .collection("participants")
            .where("status", "==", "joined")
        );

        // Filter out the leaving user
        const remainingParticipantIds = participantsSnapshot.docs
          .map((doc) => doc.id)
          .filter((id) => id !== userId);

        const sessionRef = db.collection("trainingSessions").doc(data.sessionId);

        transaction.update(sessionRef, {
          participantIds: remainingParticipantIds,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log("[leaveTrainingSession] User left successfully:", {
          userId,
          sessionId: data.sessionId,
          remainingParticipants: remainingParticipantIds.length,
        });

        return {
          success: true,
          message: "Successfully left training session",
        };
      });

      return result;
    } catch (error: any) {
      // Re-throw HttpsError to preserve error codes
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      console.error("[leaveTrainingSession] Transaction error:", {
        userId,
        sessionId: data.sessionId,
        error: error.message,
      });

      throw new functions.https.HttpsError(
        "internal",
        "Failed to leave training session. Please try again later."
      );
    }
  }
);

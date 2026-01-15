// Cloud Function for cancelling training sessions (Story 15.14)
// Only the session creator can cancel a session
// Notifications are automatically triggered by onTrainingSessionUpdated
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// ============================================================================
// Type Definitions
// ============================================================================

interface CancelTrainingSessionRequest {
  sessionId: string;
}

interface CancelTrainingSessionResponse {
  success: boolean;
  message: string;
}

// ============================================================================
// Main Cloud Function
// ============================================================================

export const cancelTrainingSession = functions.https.onCall(
  async (
    data: CancelTrainingSessionRequest,
    context: functions.https.CallableContext
  ): Promise<CancelTrainingSessionResponse> => {
    // ============================================================================
    // 1. Authentication Check
    // ============================================================================

    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to cancel a training session"
      );
    }

    const userId = context.auth.uid;

    console.log("[cancelTrainingSession] Request from user:", {
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
    const sessionRef = db.collection("trainingSessions").doc(data.sessionId);

    // ============================================================================
    // 3. Session Validation & Permission Check
    // ============================================================================

    const sessionDoc = await sessionRef.get();

    if (!sessionDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Training session not found"
      );
    }

    const sessionData = sessionDoc.data()!;

    // Check if user is the creator
    if (sessionData.createdBy !== userId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only the session creator can cancel this training session"
      );
    }

    // Check if session is already cancelled
    if (sessionData.status === "cancelled") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "This training session is already cancelled"
      );
    }

    // Check if session is already completed
    if (sessionData.status === "completed") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Cannot cancel a completed training session"
      );
    }

    // ============================================================================
    // 4. Cancel Operation
    // ============================================================================

    try {
      await sessionRef.update({
        status: "cancelled",
        cancelledBy: userId,
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("[cancelTrainingSession] Session cancelled successfully:", {
        userId,
        sessionId: data.sessionId,
        participantCount: sessionData.participantIds?.length || 0,
      });

      return {
        success: true,
        message: "Training session cancelled successfully",
      };
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : "Unknown error";
      console.error("[cancelTrainingSession] Error cancelling session:", {
        userId,
        sessionId: data.sessionId,
        error: errorMessage,
      });

      throw new functions.https.HttpsError(
        "internal",
        "Failed to cancel training session. Please try again later."
      );
    }
  }
);

// Cloud Function to check if user has submitted feedback for a training session
// Maintains anonymity while allowing duplicate submission prevention
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as crypto from "crypto";

// ============================================================================
// Type Definitions
// ============================================================================

interface HasSubmittedTrainingFeedbackRequest {
  trainingSessionId: string;
}

interface HasSubmittedTrainingFeedbackResponse {
  hasSubmitted: boolean;
}

// ============================================================================
// Configuration
// ============================================================================

// Salt for participant hash (must match submitTrainingFeedback.ts)
const PARTICIPANT_HASH_SALT = process.env.PARTICIPANT_HASH_SALT || "playwithme-feedback-salt-v1";

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Generate anonymous participant hash
 * Hash = SHA256(sessionId + userId + salt)
 * Must match the hash generation in submitTrainingFeedback
 */
function generateParticipantHash(
  sessionId: string,
  userId: string
): string {
  const data = `${sessionId}:${userId}:${PARTICIPANT_HASH_SALT}`;
  return crypto.createHash("sha256").update(data).digest("hex");
}

/**
 * Check if feedback exists for this participant hash
 */
async function feedbackExists(
  db: admin.firestore.Firestore,
  sessionId: string,
  participantHash: string
): Promise<boolean> {
  const feedbackSnapshot = await db
    .collection("trainingSessions")
    .doc(sessionId)
    .collection("feedback")
    .where("participantHash", "==", participantHash)
    .limit(1)
    .get();

  return !feedbackSnapshot.empty;
}

// ============================================================================
// Main Cloud Function
// ============================================================================

export const hasSubmittedTrainingFeedback = functions.https.onCall(
  async (
    data: HasSubmittedTrainingFeedbackRequest,
    context: functions.https.CallableContext
  ): Promise<HasSubmittedTrainingFeedbackResponse> => {
    // ============================================================================
    // 1. Authentication Check
    // ============================================================================

    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to check feedback status"
      );
    }

    const userId = context.auth.uid;

    console.log("[hasSubmittedTrainingFeedback] Request from user:", {
      userId,
      sessionId: data.trainingSessionId,
    });

    // ============================================================================
    // 2. Input Validation
    // ============================================================================

    if (!data || !data.trainingSessionId || typeof data.trainingSessionId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Training session ID is required"
      );
    }

    const db = admin.firestore();

    // ============================================================================
    // 3. Check Feedback Submission Status
    // ============================================================================

    try {
      const participantHash = generateParticipantHash(
        data.trainingSessionId,
        userId
      );

      const hasSubmitted = await feedbackExists(
        db,
        data.trainingSessionId,
        participantHash
      );

      console.log("[hasSubmittedTrainingFeedback] Check complete:", {
        sessionId: data.trainingSessionId,
        hasSubmitted,
      });

      return {
        hasSubmitted,
      };
    } catch (error) {
      console.error("[hasSubmittedTrainingFeedback] Error checking feedback:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to check feedback status. Please try again."
      );
    }
  }
);

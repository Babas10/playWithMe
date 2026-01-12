// Cloud Function for submitting anonymous feedback for training sessions
// Validates participant status and prevents duplicate submissions while maintaining anonymity
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as crypto from "crypto";

// ============================================================================
// Type Definitions
// ============================================================================

interface SubmitTrainingFeedbackRequest {
  trainingSessionId: string;
  exercisesQuality: number;
  trainingIntensity: number;
  coachingClarity: number;
  comment?: string;
}

interface SubmitTrainingFeedbackResponse {
  success: boolean;
  message: string;
}

// ============================================================================
// Configuration
// ============================================================================

// Salt for participant hash (should be configured per environment in production)
// In production, this should be stored in Cloud Secret Manager
const PARTICIPANT_HASH_SALT = process.env.PARTICIPANT_HASH_SALT || "playwithme-feedback-salt-v1";

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Generate anonymous participant hash
 * Hash = SHA256(sessionId + userId + salt)
 * This allows duplicate detection without storing user IDs
 */
function generateParticipantHash(
  sessionId: string,
  userId: string
): string {
  const data = `${sessionId}:${userId}:${PARTICIPANT_HASH_SALT}`;
  return crypto.createHash("sha256").update(data).digest("hex");
}

/**
 * Get training session data
 */
async function getTrainingSessionData(
  db: admin.firestore.Firestore,
  sessionId: string
): Promise<{
  groupId: string;
  participantIds: string[];
  status: string;
  endTime: admin.firestore.Timestamp;
} | null> {
  const sessionDoc = await db.collection("trainingSessions").doc(sessionId).get();

  if (!sessionDoc.exists) {
    return null;
  }

  const sessionData = sessionDoc.data()!;
  return {
    groupId: sessionData.groupId,
    participantIds: sessionData.participantIds || [],
    status: sessionData.status || "scheduled",
    endTime: sessionData.endTime,
  };
}

/**
 * Check if feedback already exists for this participant hash
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

export const submitTrainingFeedback = functions.https.onCall(
  async (
    data: SubmitTrainingFeedbackRequest,
    context: functions.https.CallableContext
  ): Promise<SubmitTrainingFeedbackResponse> => {
    // ============================================================================
    // 1. Authentication Check
    // ============================================================================

    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to submit feedback"
      );
    }

    const userId = context.auth.uid;

    console.log("[submitTrainingFeedback] Request from user:", {
      userId,
      sessionId: data.trainingSessionId,
      exercisesQuality: data.exercisesQuality,
      trainingIntensity: data.trainingIntensity,
      coachingClarity: data.coachingClarity,
      hasComment: !!data.comment,
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

    // Validate exercises quality rating
    if (!data.exercisesQuality || typeof data.exercisesQuality !== "number") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Exercises quality rating is required"
      );
    }

    if (data.exercisesQuality < 1 || data.exercisesQuality > 5) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Exercises quality rating must be between 1 and 5"
      );
    }

    // Validate training intensity rating
    if (!data.trainingIntensity || typeof data.trainingIntensity !== "number") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Training intensity rating is required"
      );
    }

    if (data.trainingIntensity < 1 || data.trainingIntensity > 5) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Training intensity rating must be between 1 and 5"
      );
    }

    // Validate coaching clarity rating
    if (!data.coachingClarity || typeof data.coachingClarity !== "number") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Coaching clarity rating is required"
      );
    }

    if (data.coachingClarity < 1 || data.coachingClarity > 5) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Coaching clarity rating must be between 1 and 5"
      );
    }

    // Validate comment length if provided
    if (data.comment) {
      if (typeof data.comment !== "string") {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Comment must be a string"
        );
      }

      if (data.comment.length > 1000) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Comment must be less than 1000 characters"
        );
      }
    }

    const db = admin.firestore();

    // ============================================================================
    // 3. Training Session Validation
    // ============================================================================

    const sessionData = await getTrainingSessionData(db, data.trainingSessionId);

    if (!sessionData) {
      throw new functions.https.HttpsError(
        "not-found",
        "Training session not found"
      );
    }

    // ============================================================================
    // 4. Participant Validation
    // ============================================================================

    // Check if user was a participant in the session
    if (!sessionData.participantIds.includes(userId)) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "You must be a participant of this training session to submit feedback"
      );
    }

    // ============================================================================
    // 5. Session Status Validation
    // ============================================================================

    // Only allow feedback after session has ended
    const now = admin.firestore.Timestamp.now();
    if (sessionData.endTime > now) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Feedback can only be submitted after the training session has ended"
      );
    }

    // Don't allow feedback for cancelled sessions
    if (sessionData.status === "cancelled") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Cannot submit feedback for a cancelled training session"
      );
    }

    // ============================================================================
    // 6. Duplicate Submission Check
    // ============================================================================

    const participantHash = generateParticipantHash(
      data.trainingSessionId,
      userId
    );

    const alreadySubmitted = await feedbackExists(
      db,
      data.trainingSessionId,
      participantHash
    );

    if (alreadySubmitted) {
      throw new functions.https.HttpsError(
        "already-exists",
        "You have already submitted feedback for this training session"
      );
    }

    // ============================================================================
    // 7. Submit Anonymous Feedback
    // ============================================================================

    try {
      const feedbackData = {
        exercisesQuality: data.exercisesQuality,
        trainingIntensity: data.trainingIntensity,
        coachingClarity: data.coachingClarity,
        comment: data.comment?.trim() || null,
        participantHash: participantHash,
        submittedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await db
        .collection("trainingSessions")
        .doc(data.trainingSessionId)
        .collection("feedback")
        .add(feedbackData);

      console.log("[submitTrainingFeedback] Feedback submitted successfully:", {
        sessionId: data.trainingSessionId,
        exercisesQuality: data.exercisesQuality,
        trainingIntensity: data.trainingIntensity,
        coachingClarity: data.coachingClarity,
        hasComment: !!data.comment,
      });

      return {
        success: true,
        message: "Feedback submitted successfully",
      };
    } catch (error) {
      console.error("[submitTrainingFeedback] Error submitting feedback:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to submit feedback. Please try again."
      );
    }
  }
);

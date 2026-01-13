// Cloud Function for fetching training session feedback
// Allows training session participants to view feedback while maintaining security
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// ============================================================================
// Type Definitions
// ============================================================================

interface GetTrainingFeedbackRequest {
  trainingSessionId: string;
}

interface FeedbackItem {
  id: string;
  exercisesQuality: number;
  trainingIntensity: number;
  coachingClarity: number;
  comment: string | null;
  submittedAt: string; // ISO 8601 string format
}

interface GetTrainingFeedbackResponse {
  feedback: FeedbackItem[];
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
  groupId: string;
  participantIds: string[];
  status: string;
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
  };
}


// ============================================================================
// Main Cloud Function
// ============================================================================

export const getTrainingFeedback = functions.https.onCall(
  async (
    data: GetTrainingFeedbackRequest,
    context: functions.https.CallableContext
  ): Promise<GetTrainingFeedbackResponse> => {
    // ============================================================================
    // 1. Authentication Check
    // ============================================================================

    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to view feedback"
      );
    }

    const userId = context.auth.uid;

    console.log("[getTrainingFeedback] Request from user:", {
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
    // Only participants can view feedback (consistent with submission rules)
    if (!sessionData.participantIds.includes(userId)) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You must be a participant of this training session to view feedback"
      );
    }

    // ============================================================================
    // 5. Fetch Feedback
    // ============================================================================

    try {
      const feedbackSnapshot = await db
        .collection("trainingSessions")
        .doc(data.trainingSessionId)
        .collection("feedback")
        .orderBy("submittedAt", "desc")
        .get();

      const feedback: FeedbackItem[] = feedbackSnapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          exercisesQuality: data.exercisesQuality,
          trainingIntensity: data.trainingIntensity,
          coachingClarity: data.coachingClarity,
          comment: data.comment || null,
          // Convert Firestore Timestamp to ISO string for clean client serialization
          submittedAt: data.submittedAt.toDate().toISOString(),
        };
      });

      console.log("[getTrainingFeedback] Feedback fetched successfully:", {
        sessionId: data.trainingSessionId,
        count: feedback.length,
      });

      return {
        feedback,
      };
    } catch (error) {
      console.error("[getTrainingFeedback] Error fetching feedback:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to fetch feedback. Please try again."
      );
    }
  }
);

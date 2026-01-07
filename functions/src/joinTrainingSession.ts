// Cloud Function for joining training sessions with atomic participant limit enforcement
// Handles race conditions by using Firestore transactions
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// ============================================================================
// Type Definitions
// ============================================================================

interface JoinTrainingSessionRequest {
  sessionId: string;
}

interface JoinTrainingSessionResponse {
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
  groupId: string;
  maxParticipants: number;
  status: string;
  startTime: admin.firestore.Timestamp;
} | null> {
  const sessionDoc = await db.collection("trainingSessions").doc(sessionId).get();

  if (!sessionDoc.exists) {
    return null;
  }

  const sessionData = sessionDoc.data()!;
  return {
    groupId: sessionData.groupId,
    maxParticipants: sessionData.maxParticipants,
    status: sessionData.status || "scheduled",
    startTime: sessionData.startTime,
  };
}

/**
 * Check if user is a member of the group
 */
async function isGroupMember(
  db: admin.firestore.Firestore,
  groupId: string,
  userId: string
): Promise<boolean> {
  const groupDoc = await db.collection("groups").doc(groupId).get();

  if (!groupDoc.exists) {
    return false;
  }

  const groupData = groupDoc.data()!;
  const memberIds = groupData.memberIds || [];
  return memberIds.includes(userId);
}

/**
 * Get current participant count from participants subcollection
 */
async function getParticipantCount(
  db: admin.firestore.Firestore,
  sessionId: string
): Promise<number> {
  const participantsSnapshot = await db
    .collection("trainingSessions")
    .doc(sessionId)
    .collection("participants")
    .where("status", "==", "joined")
    .get();

  return participantsSnapshot.size;
}

// ============================================================================
// Main Cloud Function
// ============================================================================

export const joinTrainingSession = functions.https.onCall(
  async (
    data: JoinTrainingSessionRequest,
    context: functions.https.CallableContext
  ): Promise<JoinTrainingSessionResponse> => {
    // ============================================================================
    // 1. Authentication Check
    // ============================================================================

    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to join a training session"
      );
    }

    const userId = context.auth.uid;

    console.log("[joinTrainingSession] Request from user:", {
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

    // Check if session is still scheduled
    if (sessionData.status !== "scheduled") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Cannot join a session that is not scheduled"
      );
    }

    // Check if session has not started yet
    const now = admin.firestore.Timestamp.now();
    if (sessionData.startTime <= now) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Cannot join a session that has already started"
      );
    }

    // ============================================================================
    // 4. Group Membership Validation
    // ============================================================================

    const isMember = await isGroupMember(db, sessionData.groupId, userId);

    if (!isMember) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You must be a member of the group to join this training session"
      );
    }

    // ============================================================================
    // 5. Atomic Join Operation (Transaction)
    // ============================================================================
    // This prevents race conditions when multiple users try to join simultaneously

    try {
      const result = await db.runTransaction(async (transaction) => {
        // Get current participant count
        const participantsSnapshot = await transaction.get(
          db
            .collection("trainingSessions")
            .doc(data.sessionId)
            .collection("participants")
            .where("status", "==", "joined")
        );

        const currentCount = participantsSnapshot.size;

        // Check if user is already a participant
        const existingParticipantDoc = await transaction.get(
          db
            .collection("trainingSessions")
            .doc(data.sessionId)
            .collection("participants")
            .doc(userId)
        );

        if (existingParticipantDoc.exists) {
          const participantData = existingParticipantDoc.data()!;
          if (participantData.status === "joined") {
            throw new functions.https.HttpsError(
              "already-exists",
              "You have already joined this training session"
            );
          }
        }

        // Check if session is full
        if (currentCount >= sessionData.maxParticipants) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "Training session is full"
          );
        }

        // Add participant to subcollection
        const participantRef = db
          .collection("trainingSessions")
          .doc(data.sessionId)
          .collection("participants")
          .doc(userId);

        transaction.set(participantRef, {
          userId,
          joinedAt: admin.firestore.FieldValue.serverTimestamp(),
          status: "joined",
        });

        // Update denormalized participantIds array in session document for fast reads
        const sessionRef = db.collection("trainingSessions").doc(data.sessionId);

        // Get all current participant IDs (joined status only)
        const allParticipantIds = participantsSnapshot.docs.map((doc) => doc.id);
        if (!allParticipantIds.includes(userId)) {
          allParticipantIds.push(userId);
        }

        transaction.update(sessionRef, {
          participantIds: allParticipantIds,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log("[joinTrainingSession] User joined successfully:", {
          userId,
          sessionId: data.sessionId,
          newParticipantCount: currentCount + 1,
        });

        return {
          success: true,
          message: "Successfully joined training session",
        };
      });

      return result;
    } catch (error: any) {
      // Re-throw HttpsError to preserve error codes
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      console.error("[joinTrainingSession] Transaction error:", {
        userId,
        sessionId: data.sessionId,
        error: error.message,
      });

      throw new functions.https.HttpsError(
        "internal",
        "Failed to join training session. Please try again later."
      );
    }
  }
);

// Cloud Function for creating training sessions with group membership validation
// ARCHITECTURE: Training sessions are in Games layer, validate via GroupRepository only
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// ============================================================================
// Type Definitions
// ============================================================================

type RecurrenceFrequency = "none" | "weekly" | "monthly";

interface RecurrenceRule {
  frequency: RecurrenceFrequency;
  interval: number;
  count?: number;
  endDate?: string;
  daysOfWeek?: number[];
}

interface CreateTrainingSessionRequest {
  groupId: string;
  title: string;
  description?: string;
  locationName: string;
  locationAddress?: string;
  startTime: string; // ISO 8601 string
  endTime: string; // ISO 8601 string
  minParticipants: number;
  maxParticipants: number;
  notes?: string;
  recurrenceRule?: RecurrenceRule;
}

interface CreateTrainingSessionResponse {
  success: boolean;
  sessionId: string;
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Check if group exists and get group data
 */
async function getGroupData(groupId: string): Promise<{
  name: string;
  createdBy: string;
  memberIds: string[];
} | null> {
  const db = admin.firestore();
  const groupDoc = await db.collection("groups").doc(groupId).get();

  if (!groupDoc.exists) {
    return null;
  }

  const groupData = groupDoc.data()!;
  return {
    name: groupData.name,
    createdBy: groupData.createdBy,
    memberIds: groupData.memberIds || [],
  };
}

/**
 * Validate training session timing
 */
function validateTiming(startTime: Date, endTime: Date): string | null {
  const now = new Date();

  if (startTime <= now) {
    return "Start time must be in the future";
  }

  if (endTime <= startTime) {
    return "End time must be after start time";
  }

  const durationMinutes = (endTime.getTime() - startTime.getTime()) / (1000 * 60);
  if (durationMinutes < 30) {
    return "Training session must be at least 30 minutes long";
  }

  return null;
}

/**
 * Validate participant limits
 */
function validateParticipants(minParticipants: number, maxParticipants: number): string | null {
  if (minParticipants < 2) {
    return "Minimum participants must be at least 2";
  }

  if (maxParticipants > 30) {
    return "Maximum participants cannot exceed 30";
  }

  if (maxParticipants < minParticipants) {
    return "Maximum participants must be greater than or equal to minimum participants";
  }

  return null;
}

/**
 * Validate title
 */
function validateTitle(title: string): string | null {
  if (!title || title.trim().length === 0) {
    return "Title is required";
  }

  if (title.trim().length < 3) {
    return "Title must be at least 3 characters";
  }

  if (title.trim().length > 100) {
    return "Title must be less than 100 characters";
  }

  return null;
}

/**
 * Validate location
 */
function validateLocation(locationName: string): string | null {
  if (!locationName || locationName.trim().length === 0) {
    return "Location is required";
  }

  return null;
}

// ============================================================================
// Main Cloud Function
// ============================================================================

/**
 * Creates a new training session with server-side validation
 *
 * ARCHITECTURE ENFORCEMENT:
 * - Validates group membership using Admin SDK (bypasses Firestore rules)
 * - Does NOT import or check friendships (Games layer → Groups only)
 * - Participants are always resolved via group.memberIds
 *
 * Security:
 * - Validates authentication
 * - Validates group membership
 * - Validates all input parameters
 * - Uses Admin SDK to write to Firestore (bypasses security rules)
 *
 * @param data - CreateTrainingSessionRequest
 * @param context - CallableContext with authentication info
 * @returns CreateTrainingSessionResponse with sessionId
 */
export const createTrainingSession = functions
  .runWith({
    timeoutSeconds: 30,
    memory: "256MB",
  })
  .https.onCall(
    async (
      data: CreateTrainingSessionRequest,
      context: functions.https.CallableContext
    ): Promise<CreateTrainingSessionResponse> => {
      // ========================================
      // 1. Authentication Check
      // ========================================
      if (!context.auth) {
        functions.logger.warn("Unauthenticated attempt to create training session");
        throw new functions.https.HttpsError(
          "unauthenticated",
          "You must be logged in to create a training session"
        );
      }

      const userId = context.auth.uid;
      const db = admin.firestore();

      functions.logger.info("Creating training session", {
        userId,
        groupId: data.groupId,
        title: data.title,
      });

      // ========================================
      // 2. Input Validation
      // ========================================

      // Validate required fields
      if (!data.groupId || !data.title || !data.locationName || !data.startTime || !data.endTime) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Missing required fields: groupId, title, locationName, startTime, endTime"
        );
      }

      // Validate title
      const titleError = validateTitle(data.title);
      if (titleError) {
        throw new functions.https.HttpsError("invalid-argument", titleError);
      }

      // Validate location
      const locationError = validateLocation(data.locationName);
      if (locationError) {
        throw new functions.https.HttpsError("invalid-argument", locationError);
      }

      // Parse and validate timestamps
      let startTime: Date;
      let endTime: Date;
      try {
        startTime = new Date(data.startTime);
        endTime = new Date(data.endTime);

        if (isNaN(startTime.getTime()) || isNaN(endTime.getTime())) {
          throw new Error("Invalid date format");
        }
      } catch (error) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Invalid date format. Use ISO 8601 format (e.g., 2024-01-15T14:30:00.000Z)"
        );
      }

      // Validate timing
      const timingError = validateTiming(startTime, endTime);
      if (timingError) {
        throw new functions.https.HttpsError("invalid-argument", timingError);
      }

      // Validate participants
      const participantsError = validateParticipants(
        data.minParticipants || 4,
        data.maxParticipants || 12
      );
      if (participantsError) {
        throw new functions.https.HttpsError("invalid-argument", participantsError);
      }

      // ========================================
      // 3. Group Membership Validation
      // ========================================

      // CRITICAL: Validate group exists and user is a member
      // This enforces the architecture rule: Training Sessions → Groups only
      const groupData = await getGroupData(data.groupId);

      if (!groupData) {
        functions.logger.warn("Group not found", {userId, groupId: data.groupId});
        throw new functions.https.HttpsError(
          "not-found",
          "The selected group does not exist"
        );
      }

      if (!groupData.memberIds.includes(userId)) {
        functions.logger.warn("User not a member of group", {
          userId,
          groupId: data.groupId,
        });
        throw new functions.https.HttpsError(
          "permission-denied",
          "You must be a member of the group to create a training session"
        );
      }

      // ========================================
      // 4. Validate Recurrence Rule (if provided)
      // ========================================

      let recurrenceRule: RecurrenceRule | null = null;
      if (data.recurrenceRule && data.recurrenceRule.frequency !== "none") {
        recurrenceRule = data.recurrenceRule;

        // Validate recurrence rule
        if (recurrenceRule.interval < 1) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            "Recurrence interval must be at least 1"
          );
        }

        // Either count or endDate must be specified
        if (!recurrenceRule.count && !recurrenceRule.endDate) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            "Recurrence rule must specify either count or endDate"
          );
        }

        // Both count and endDate cannot be specified
        if (recurrenceRule.count && recurrenceRule.endDate) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            "Recurrence rule cannot specify both count and endDate"
          );
        }

        // Validate count
        if (recurrenceRule.count !== undefined) {
          if (recurrenceRule.count < 1) {
            throw new functions.https.HttpsError(
              "invalid-argument",
              "Recurrence count must be at least 1"
            );
          }
          if (recurrenceRule.count > 100) {
            throw new functions.https.HttpsError(
              "invalid-argument",
              "Recurrence count cannot exceed 100 occurrences"
            );
          }
        }

        // Validate endDate
        if (recurrenceRule.endDate) {
          const endDate = new Date(recurrenceRule.endDate);
          if (isNaN(endDate.getTime())) {
            throw new functions.https.HttpsError(
              "invalid-argument",
              "Invalid endDate format"
            );
          }
          if (endDate <= new Date()) {
            throw new functions.https.HttpsError(
              "invalid-argument",
              "Recurrence endDate must be in the future"
            );
          }
        }

        // Validate daysOfWeek for weekly recurrence
        if (recurrenceRule.frequency === "weekly" && recurrenceRule.daysOfWeek) {
          if (recurrenceRule.daysOfWeek.length === 0) {
            throw new functions.https.HttpsError(
              "invalid-argument",
              "Weekly recurrence must specify at least one day of week"
            );
          }
          for (const day of recurrenceRule.daysOfWeek) {
            if (day < 1 || day > 7) {
              throw new functions.https.HttpsError(
                "invalid-argument",
                "Days of week must be between 1 (Monday) and 7 (Sunday)"
              );
            }
          }
        }
      }

      // ========================================
      // 5. Create Training Session Document
      // ========================================

      try {
        const sessionData = {
          groupId: data.groupId,
          title: data.title.trim(),
          description: data.description?.trim() || null,
          location: {
            name: data.locationName.trim(),
            address: data.locationAddress?.trim() || null,
          },
          startTime: admin.firestore.Timestamp.fromDate(startTime),
          endTime: admin.firestore.Timestamp.fromDate(endTime),
          minParticipants: data.minParticipants || 4,
          maxParticipants: data.maxParticipants || 12,
          createdBy: userId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: null,
          recurrenceRule: recurrenceRule, // Story 15.2
          parentSessionId: null, // This is a parent session (not an instance)
          status: "scheduled",
          participantIds: [], // Creator doesn't auto-join (they can join manually)
          notes: data.notes?.trim() || null,
        };

        // Write using Admin SDK (bypasses Firestore security rules)
        const sessionRef = await db.collection("trainingSessions").add(sessionData);

        functions.logger.info("Training session created successfully", {
          sessionId: sessionRef.id,
          userId,
          groupId: data.groupId,
        });

        return {
          success: true,
          sessionId: sessionRef.id,
        };
      } catch (error) {
        functions.logger.error("Failed to create training session", {
          userId,
          groupId: data.groupId,
          error,
        });
        throw new functions.https.HttpsError(
          "internal",
          "Failed to create training session. Please try again."
        );
      }
    }
  );

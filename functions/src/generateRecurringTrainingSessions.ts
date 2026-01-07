// Cloud Function for generating recurring training session instances
// ARCHITECTURE: Training sessions are in Games layer
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// ============================================================================
// Type Definitions
// ============================================================================

type RecurrenceFrequency = "none" | "weekly" | "monthly";

interface RecurrenceRule {
  frequency: RecurrenceFrequency;
  interval: number; // Every X weeks/months
  count?: number; // Number of occurrences
  endDate?: string; // ISO 8601 string
  daysOfWeek?: number[]; // For weekly: 1=Monday, 7=Sunday
}

interface GenerateRecurringSessionsRequest {
  parentSessionId: string;
}

interface GenerateRecurringSessionsResponse {
  success: boolean;
  generatedCount: number;
  sessionIds: string[];
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Get parent training session data
 */
async function getParentSession(sessionId: string): Promise<{
  data: admin.firestore.DocumentData;
  id: string;
} | null> {
  const db = admin.firestore();
  const sessionDoc = await db.collection("trainingSessions").doc(sessionId).get();

  if (!sessionDoc.exists) {
    return null;
  }

  return {
    data: sessionDoc.data()!,
    id: sessionDoc.id,
  };
}

/**
 * Calculate occurrence dates based on recurrence rule
 */
function calculateOccurrenceDates(
  baseDate: Date,
  recurrenceRule: RecurrenceRule
): Date[] {
  const occurrences: Date[] = [];
  const {frequency, interval, count, endDate, daysOfWeek} = recurrenceRule;

  if (frequency === "none") {
    return occurrences;
  }

  // Determine end condition
  const maxOccurrences = count || 52; // Default to 1 year worth of occurrences
  const endDateTime = endDate ? new Date(endDate) : null;

  if (frequency === "weekly") {
    // Weekly recurrence
    const targetDays = daysOfWeek && daysOfWeek.length > 0
      ? daysOfWeek
      : [((baseDate.getDay() + 6) % 7) + 1]; // Default to same day as base (convert Sunday=0 to Monday=1 format)

    let occurrenceCount = 0;

    // Generate occurrences for up to 2 years or until we hit the limit
    for (let week = 0; week < 104 && occurrenceCount < maxOccurrences; week++) {
      for (const targetDay of targetDays) {
        // Convert our day format (1=Monday) to JS Date format (0=Sunday)
        const targetDayJS = targetDay === 7 ? 0 : targetDay;
        const currentWeekStart = new Date(baseDate);
        currentWeekStart.setDate(baseDate.getDate() + (week * interval * 7));

        // Find the target day in this week
        const dayDiff = (targetDayJS - currentWeekStart.getDay() + 7) % 7;
        const occurrenceDate = new Date(currentWeekStart);
        occurrenceDate.setDate(currentWeekStart.getDate() + dayDiff);

        // Copy time from base date
        occurrenceDate.setHours(baseDate.getHours());
        occurrenceDate.setMinutes(baseDate.getMinutes());
        occurrenceDate.setSeconds(baseDate.getSeconds());
        occurrenceDate.setMilliseconds(baseDate.getMilliseconds());

        // Skip if before base date (for first week)
        if (occurrenceDate <= baseDate) {
          continue;
        }

        // Check end condition
        if (endDateTime && occurrenceDate > endDateTime) {
          break;
        }

        occurrences.push(new Date(occurrenceDate));
        occurrenceCount++;

        if (occurrenceCount >= maxOccurrences) {
          break;
        }
      }
    }
  } else if (frequency === "monthly") {
    // Monthly recurrence
    for (let i = 1; i <= maxOccurrences; i++) {
      const occurrenceDate = new Date(baseDate);
      occurrenceDate.setMonth(baseDate.getMonth() + (i * interval));

      // Handle month overflow (e.g., Jan 31 -> Feb 31 doesn't exist)
      // JavaScript automatically adjusts, but we want to cap at last day of month
      if (occurrenceDate.getDate() !== baseDate.getDate()) {
        occurrenceDate.setDate(0); // Go to last day of previous month
      }

      // Check end condition
      if (endDateTime && occurrenceDate > endDateTime) {
        break;
      }

      occurrences.push(new Date(occurrenceDate));
    }
  }

  return occurrences;
}

/**
 * Create a single training session instance
 */
async function createSessionInstance(
  parentSession: admin.firestore.DocumentData,
  parentId: string,
  occurrenceDate: Date,
  db: admin.firestore.Firestore
): Promise<string> {
  const startTime = new Date(occurrenceDate);
  const duration = (parentSession.endTime as admin.firestore.Timestamp).toDate().getTime() -
                  (parentSession.startTime as admin.firestore.Timestamp).toDate().getTime();
  const endTime = new Date(startTime.getTime() + duration);

  const instanceData = {
    ...parentSession,
    parentSessionId: parentId,
    startTime: admin.firestore.Timestamp.fromDate(startTime),
    endTime: admin.firestore.Timestamp.fromDate(endTime),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: null,
    participantIds: [], // Each instance starts with no participants
    // Remove recurrenceRule from instances (only parent has it)
    recurrenceRule: null,
  };

  const instanceRef = await db.collection("trainingSessions").add(instanceData);
  return instanceRef.id;
}

// ============================================================================
// Main Cloud Function
// ============================================================================

/**
 * Generates recurring training session instances based on a parent session's recurrence rule
 *
 * ARCHITECTURE:
 * - Validates parent session exists and has a valid recurrence rule
 * - Generates instance documents for each occurrence
 * - Each instance is independently joinable/cancellable
 * - Uses Admin SDK for server-side generation
 *
 * Security:
 * - Validates authentication
 * - Validates parent session existence
 * - Validates recurrence rule
 *
 * @param data - GenerateRecurringSessionsRequest
 * @param context - CallableContext with authentication info
 * @returns GenerateRecurringSessionsResponse with generated session IDs
 */
export const generateRecurringTrainingSessions = functions
  .runWith({
    timeoutSeconds: 60,
    memory: "512MB",
  })
  .https.onCall(
    async (
      data: GenerateRecurringSessionsRequest,
      context: functions.https.CallableContext
    ): Promise<GenerateRecurringSessionsResponse> => {
      // ========================================
      // 1. Authentication Check
      // ========================================
      if (!context.auth) {
        functions.logger.warn("Unauthenticated attempt to generate recurring sessions");
        throw new functions.https.HttpsError(
          "unauthenticated",
          "You must be logged in to generate recurring training sessions"
        );
      }

      const userId = context.auth.uid;
      const db = admin.firestore();

      functions.logger.info("Generating recurring training sessions", {
        userId,
        parentSessionId: data.parentSessionId,
      });

      // ========================================
      // 2. Input Validation
      // ========================================

      if (!data.parentSessionId) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Parent session ID is required"
        );
      }

      // ========================================
      // 3. Get and Validate Parent Session
      // ========================================

      const parentSession = await getParentSession(data.parentSessionId);

      if (!parentSession) {
        functions.logger.warn("Parent session not found", {
          userId,
          parentSessionId: data.parentSessionId,
        });
        throw new functions.https.HttpsError(
          "not-found",
          "Parent training session not found"
        );
      }

      // Validate user is the creator
      if (parentSession.data.createdBy !== userId) {
        functions.logger.warn("User is not the creator of parent session", {
          userId,
          parentSessionId: data.parentSessionId,
          createdBy: parentSession.data.createdBy,
        });
        throw new functions.https.HttpsError(
          "permission-denied",
          "Only the creator can generate recurring instances"
        );
      }

      // Validate recurrence rule exists
      const recurrenceRule = parentSession.data.recurrenceRule as RecurrenceRule | null;
      if (!recurrenceRule || recurrenceRule.frequency === "none") {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Parent session does not have a valid recurrence rule"
        );
      }

      // ========================================
      // 4. Generate Occurrence Dates
      // ========================================

      const baseStartTime = (parentSession.data.startTime as admin.firestore.Timestamp).toDate();
      const occurrenceDates = calculateOccurrenceDates(baseStartTime, recurrenceRule);

      if (occurrenceDates.length === 0) {
        functions.logger.warn("No occurrence dates generated", {
          userId,
          parentSessionId: data.parentSessionId,
          recurrenceRule,
        });
        return {
          success: true,
          generatedCount: 0,
          sessionIds: [],
        };
      }

      // ========================================
      // 5. Create Session Instances
      // ========================================

      try {
        const sessionIds: string[] = [];

        // Create all session instances
        for (const occurrenceDate of occurrenceDates) {
          const sessionId = await createSessionInstance(
            parentSession.data,
            parentSession.id,
            occurrenceDate,
            db
          );
          sessionIds.push(sessionId);
        }

        functions.logger.info("Recurring sessions generated successfully", {
          userId,
          parentSessionId: data.parentSessionId,
          generatedCount: sessionIds.length,
        });

        return {
          success: true,
          generatedCount: sessionIds.length,
          sessionIds,
        };
      } catch (error) {
        functions.logger.error("Failed to create recurring session instances", {
          userId,
          parentSessionId: data.parentSessionId,
          error,
        });
        throw new functions.https.HttpsError(
          "internal",
          "Failed to generate recurring training sessions. Please try again."
        );
      }
    }
  );

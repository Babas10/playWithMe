// Cloud Functions for training session participant notifications
// Sends notifications to group members when someone joins or leaves a training session
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

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
  title: string;
  groupId: string;
  startTime: admin.firestore.Timestamp;
  createdBy: string;
} | null> {
  const sessionDoc = await db.collection("trainingSessions").doc(sessionId).get();

  if (!sessionDoc.exists) {
    return null;
  }

  const data = sessionDoc.data()!;
  return {
    title: data.title,
    groupId: data.groupId,
    startTime: data.startTime,
    createdBy: data.createdBy,
  };
}

/**
 * Get user data
 */
async function getUserData(
  db: admin.firestore.Firestore,
  userId: string
): Promise<{
  displayName: string;
  fcmToken?: string;
} | null> {
  const userDoc = await db.collection("users").doc(userId).get();

  if (!userDoc.exists) {
    return null;
  }

  const data = userDoc.data()!;
  return {
    displayName: data.displayName || "Unknown User",
    fcmToken: data.fcmToken,
  };
}

/**
 * Get group member IDs
 */
async function getGroupMemberIds(
  db: admin.firestore.Firestore,
  groupId: string
): Promise<string[]> {
  const groupDoc = await db.collection("groups").doc(groupId).get();

  if (!groupDoc.exists) {
    return [];
  }

  const data = groupDoc.data()!;
  return data.memberIds || [];
}

/**
 * Send notification to multiple users
 */
async function sendNotificationToUsers(
  db: admin.firestore.Firestore,
  userIds: string[],
  title: string,
  body: string,
  data: { [key: string]: string }
): Promise<void> {
  const notifications: admin.firestore.WriteResult[] = [];

  for (const userId of userIds) {
    const userData = await getUserData(db, userId);

    // Create notification document
    const notificationRef = db.collection("notifications").doc();
    const notification = {
      userId,
      title,
      body,
      data,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    notifications.push(await notificationRef.set(notification));

    // Send push notification if FCM token available
    if (userData?.fcmToken) {
      try {
        await admin.messaging().send({
          token: userData.fcmToken,
          notification: {
            title,
            body,
          },
          data,
        });
      } catch (error: any) {
        console.warn(`[sendNotificationToUsers] Failed to send push notification to ${userId}:`, error.message);
        // Continue even if push fails - notification doc is still created
      }
    }
  }

  console.log(`[sendNotificationToUsers] Sent ${notifications.length} notifications`);
}

// ============================================================================
// Firestore Trigger: onParticipantJoined
// ============================================================================

export const onParticipantJoined = functions.firestore
  .document("trainingSessions/{sessionId}/participants/{userId}")
  .onCreate(async (snapshot, context) => {
    const sessionId = context.params.sessionId;
    const userId = context.params.userId;

    console.log("[onParticipantJoined] Triggered:", {
      sessionId,
      userId,
    });

    const db = admin.firestore();

    try {
      // Get participant status - only proceed if status is 'joined'
      const participantData = snapshot.data();
      if (participantData.status !== "joined") {
        console.log("[onParticipantJoined] Skipping - participant status is not 'joined'");
        return;
      }

      // Get training session data
      const sessionData = await getTrainingSessionData(db, sessionId);
      if (!sessionData) {
        console.error("[onParticipantJoined] Training session not found:", sessionId);
        return;
      }

      // Get participant user data
      const participantUser = await getUserData(db, userId);
      if (!participantUser) {
        console.error("[onParticipantJoined] User not found:", userId);
        return;
      }

      // Get all group members
      const groupMemberIds = await getGroupMemberIds(db, sessionData.groupId);

      // Filter out the participant who just joined (they don't need to be notified)
      const recipientIds = groupMemberIds.filter((id) => id !== userId);

      if (recipientIds.length === 0) {
        console.log("[onParticipantJoined] No recipients to notify");
        return;
      }

      // Format start time for notification
      const startTime = sessionData.startTime.toDate();
      const formattedDate = startTime.toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
        hour: "numeric",
        minute: "2-digit",
      });

      // Send notification to all group members
      const notificationTitle = `${participantUser.displayName} joined training`;
      const notificationBody = `${participantUser.displayName} joined "${sessionData.title}" on ${formattedDate}`;

      await sendNotificationToUsers(
        db,
        recipientIds,
        notificationTitle,
        notificationBody,
        {
          type: "training_session_participant_joined",
          sessionId,
          participantId: userId,
          participantName: participantUser.displayName,
        }
      );

      console.log("[onParticipantJoined] Notifications sent successfully");
    } catch (error: any) {
      console.error("[onParticipantJoined] Error:", {
        sessionId,
        userId,
        error: error.message,
        stack: error.stack,
      });
      // Don't throw - we don't want to retry notification triggers
    }
  });

// ============================================================================
// Firestore Trigger: onParticipantLeft
// ============================================================================

export const onParticipantLeft = functions.firestore
  .document("trainingSessions/{sessionId}/participants/{userId}")
  .onUpdate(async (change, context) => {
    const sessionId = context.params.sessionId;
    const userId = context.params.userId;

    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Only proceed if status changed from 'joined' to 'left'
    if (beforeData.status !== "joined" || afterData.status !== "left") {
      return;
    }

    console.log("[onParticipantLeft] Triggered:", {
      sessionId,
      userId,
    });

    const db = admin.firestore();

    try {
      // Get training session data
      const sessionData = await getTrainingSessionData(db, sessionId);
      if (!sessionData) {
        console.error("[onParticipantLeft] Training session not found:", sessionId);
        return;
      }

      // Get participant user data
      const participantUser = await getUserData(db, userId);
      if (!participantUser) {
        console.error("[onParticipantLeft] User not found:", userId);
        return;
      }

      // Get all group members
      const groupMemberIds = await getGroupMemberIds(db, sessionData.groupId);

      // Filter out the participant who just left (they don't need to be notified)
      // Also filter out the organizer - they might want different handling
      const recipientIds = groupMemberIds.filter(
        (id) => id !== userId && id !== sessionData.createdBy
      );

      // Notify organizer separately with different message
      if (groupMemberIds.includes(sessionData.createdBy) && sessionData.createdBy !== userId) {
        const organizerNotificationTitle = `${participantUser.displayName} left training`;
        const organizerNotificationBody = `${participantUser.displayName} left "${sessionData.title}". You may need to find a replacement.`;

        await sendNotificationToUsers(
          db,
          [sessionData.createdBy],
          organizerNotificationTitle,
          organizerNotificationBody,
          {
            type: "training_session_participant_left",
            sessionId,
            participantId: userId,
            participantName: participantUser.displayName,
            isOrganizer: "true",
          }
        );
      }

      if (recipientIds.length === 0) {
        console.log("[onParticipantLeft] No other recipients to notify");
        return;
      }

      // Send notification to other group members
      const notificationTitle = `${participantUser.displayName} left training`;
      const notificationBody = `${participantUser.displayName} left "${sessionData.title}"`;

      await sendNotificationToUsers(
        db,
        recipientIds,
        notificationTitle,
        notificationBody,
        {
          type: "training_session_participant_left",
          sessionId,
          participantId: userId,
          participantName: participantUser.displayName,
        }
      );

      console.log("[onParticipantLeft] Notifications sent successfully");
    } catch (error: any) {
      console.error("[onParticipantLeft] Error:", {
        sessionId,
        userId,
        error: error.message,
        stack: error.stack,
      });
      // Don't throw - we don't want to retry notification triggers
    }
  });

// Cloud Functions for training session lifecycle notifications
// Story 15.13: Training Session Lifecycle Notifications
// Follows the same pattern as notifications.ts for games
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Check if current time is within quiet hours
 */
function isQuietHours(quietHours: any): boolean {
  if (!quietHours || !quietHours.enabled) {
    return false;
  }

  const now = new Date();
  const currentMinutes = now.getHours() * 60 + now.getMinutes();

  const [startHour, startMin] = quietHours.start.split(":").map(Number);
  const [endHour, endMin] = quietHours.end.split(":").map(Number);

  const startMinutes = startHour * 60 + startMin;
  const endMinutes = endHour * 60 + endMin;

  if (startMinutes <= endMinutes) {
    // Same day quiet hours (e.g., 14:00 to 18:00)
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  } else {
    // Overnight quiet hours (e.g., 22:00 to 08:00)
    return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
  }
}

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
  participantIds: string[];
  minParticipants: number;
  maxParticipants: number;
  status: string;
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
    participantIds: data.participantIds || [],
    minParticipants: data.minParticipants || 1,
    maxParticipants: data.maxParticipants || 20,
    status: data.status || "scheduled",
  };
}

/**
 * Get user data with FCM tokens
 */
async function getUserData(
  db: admin.firestore.Firestore,
  userId: string
): Promise<{
  displayName: string;
  fcmTokens: string[];
  notificationPreferences: any;
} | null> {
  const userDoc = await db.collection("users").doc(userId).get();

  if (!userDoc.exists) {
    return null;
  }

  const data = userDoc.data()!;
  return {
    displayName: data.displayName || "Unknown User",
    fcmTokens: data.fcmTokens || [],
    notificationPreferences: data.notificationPreferences || {},
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
 * Collect FCM tokens from eligible recipients based on preferences
 */
async function collectEligibleTokens(
  db: admin.firestore.Firestore,
  recipientIds: string[],
  groupId: string,
  preferenceKey: string,
  context: { sessionId: string; eventType: string }
): Promise<{
  allTokens: string[];
  userTokenMap: Map<string, string[]>;
}> {
  const userTokenMap = new Map<string, string[]>();
  const allTokens: string[] = [];

  for (const recipientId of recipientIds) {
    const userData = await getUserData(db, recipientId);
    if (!userData) {
      functions.logger.debug("User not found", {
        userId: recipientId,
        ...context,
      });
      continue;
    }

    const fcmTokens = userData.fcmTokens;
    if (fcmTokens.length === 0) {
      functions.logger.debug("User has no FCM tokens", {
        userId: recipientId,
        ...context,
      });
      continue;
    }

    const prefs = userData.notificationPreferences;

    // Check group-specific and global preferences
    const groupPrefs = prefs.groupSpecific?.[groupId];
    const shouldNotify =
      groupPrefs?.[preferenceKey] !== false && prefs[preferenceKey] !== false;

    if (!shouldNotify) {
      functions.logger.debug("User has disabled this notification type", {
        userId: recipientId,
        preferenceKey,
        ...context,
      });
      continue;
    }

    // Check quiet hours
    if (isQuietHours(prefs.quietHours)) {
      functions.logger.debug("User is in quiet hours", {
        userId: recipientId,
        ...context,
      });
      continue;
    }

    userTokenMap.set(recipientId, fcmTokens);
    allTokens.push(...fcmTokens);
  }

  return { allTokens, userTokenMap };
}

/**
 * Send multicast notification and clean up invalid tokens
 */
async function sendMulticastNotification(
  db: admin.firestore.Firestore,
  message: admin.messaging.MulticastMessage,
  userTokenMap: Map<string, string[]>,
  allTokens: string[],
  context: { sessionId: string; eventType: string }
): Promise<void> {
  const response = await admin.messaging().sendEachForMulticast(message);

  functions.logger.info("Notification sent", {
    ...context,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });

  // Remove invalid tokens
  if (response.failureCount > 0) {
    const invalidTokensByUser = new Map<string, string[]>();

    response.responses.forEach((resp, idx) => {
      if (
        !resp.success &&
        (resp.error?.code === "messaging/invalid-registration-token" ||
          resp.error?.code === "messaging/registration-token-not-registered")
      ) {
        const invalidToken = allTokens[idx];

        // Find which user this token belongs to
        for (const [userId, tokens] of userTokenMap.entries()) {
          if (tokens.includes(invalidToken)) {
            if (!invalidTokensByUser.has(userId)) {
              invalidTokensByUser.set(userId, []);
            }
            invalidTokensByUser.get(userId)!.push(invalidToken);
            break;
          }
        }
      }
    });

    // Clean up invalid tokens per user
    for (const [userId, tokensToRemove] of invalidTokensByUser.entries()) {
      await db
        .collection("users")
        .doc(userId)
        .update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
        });

      functions.logger.info("Removed invalid FCM tokens", {
        userId,
        ...context,
        removedCount: tokensToRemove.length,
      });
    }
  }
}

/**
 * Format date for notification message
 */
function formatDateTime(timestamp: admin.firestore.Timestamp): string {
  const date = timestamp.toDate();
  const options: Intl.DateTimeFormatOptions = {
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
  };
  return date.toLocaleDateString("en-US", options);
}

// ============================================================================
// Firestore Trigger: onTrainingSessionCreated
// Notifies all group members when a new training session is created
// ============================================================================

export const onTrainingSessionCreated = functions.firestore
  .document("trainingSessions/{sessionId}")
  .onCreate(async (snapshot, context) => {
    const sessionData = snapshot.data();
    const sessionId = context.params.sessionId;
    const groupId = sessionData.groupId;
    const creatorId = sessionData.createdBy;

    functions.logger.info("Training session created, processing notifications", {
      sessionId,
      groupId,
      createdBy: creatorId,
    });

    const db = admin.firestore();

    try {
      // Get group members
      const groupMemberIds = await getGroupMemberIds(db, groupId);

      // Filter out the creator (they don't need notification)
      const recipientIds = groupMemberIds.filter((id) => id !== creatorId);

      if (recipientIds.length === 0) {
        functions.logger.info("No recipients for training session created notification", {
          sessionId,
          groupId,
        });
        return null;
      }

      // Get creator data for notification message
      const creatorData = await getUserData(db, creatorId);
      const creatorName = creatorData?.displayName || "Someone";

      // Collect eligible tokens
      const eventContext = { sessionId, eventType: "training_session_created" };
      const { allTokens, userTokenMap } = await collectEligibleTokens(
        db,
        recipientIds,
        groupId,
        "trainingSessionCreated",
        eventContext
      );

      if (allTokens.length === 0) {
        functions.logger.info("No eligible recipients for notification", eventContext);
        return null;
      }

      // Format the session date
      const dateStr = sessionData.startTime
        ? ` on ${formatDateTime(sessionData.startTime)}`
        : "";

      // Send notification
      const message: admin.messaging.MulticastMessage = {
        tokens: allTokens,
        notification: {
          title: "New Training Session",
          body: `${creatorName} created "${sessionData.title}"${dateStr}`,
        },
        data: {
          type: "training_session_created",
          sessionId,
          groupId,
          creatorId,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: "default",
            },
          },
        },
      };

      await sendMulticastNotification(db, message, userTokenMap, allTokens, eventContext);

      return null;
    } catch (error) {
      functions.logger.error("Error sending training session created notification", {
        sessionId,
        groupId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

// ============================================================================
// Firestore Trigger: onTrainingSessionUpdated
// Handles: minimum participants reached, session cancelled
// ============================================================================

export const onTrainingSessionUpdated = functions.firestore
  .document("trainingSessions/{sessionId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const sessionId = context.params.sessionId;

    const db = admin.firestore();

    // Check for minimum participants reached
    const beforeCount = (beforeData.participantIds || []).length;
    const afterCount = (afterData.participantIds || []).length;
    const minParticipants = afterData.minParticipants || 1;

    // Trigger when we cross the threshold from below to at/above
    if (beforeCount < minParticipants && afterCount >= minParticipants) {
      await handleMinParticipantsReached(db, sessionId, afterData);
    }

    // Check for session cancelled
    if (beforeData.status !== "cancelled" && afterData.status === "cancelled") {
      await handleSessionCancelled(db, sessionId, afterData);
    }

    return null;
  });

/**
 * Handle minimum participants reached notification
 */
async function handleMinParticipantsReached(
  db: admin.firestore.Firestore,
  sessionId: string,
  sessionData: any
): Promise<void> {
  const groupId = sessionData.groupId;
  const participantIds = sessionData.participantIds || [];
  const minParticipants = sessionData.minParticipants || 1;

  functions.logger.info("Minimum participants reached, processing notifications", {
    sessionId,
    groupId,
    participantCount: participantIds.length,
    minParticipants,
  });

  try {
    // Notify all participants (including organizer)
    const recipientIds = [...participantIds];

    // Also include organizer if not already a participant
    if (!recipientIds.includes(sessionData.createdBy)) {
      recipientIds.push(sessionData.createdBy);
    }

    if (recipientIds.length === 0) {
      functions.logger.info("No recipients for min participants notification", {
        sessionId,
        groupId,
      });
      return;
    }

    // Collect eligible tokens
    const eventContext = { sessionId, eventType: "training_min_participants_reached" };
    const { allTokens, userTokenMap } = await collectEligibleTokens(
      db,
      recipientIds,
      groupId,
      "trainingMinParticipantsReached",
      eventContext
    );

    if (allTokens.length === 0) {
      functions.logger.info("No eligible recipients for notification", eventContext);
      return;
    }

    // Send notification
    const message: admin.messaging.MulticastMessage = {
      tokens: allTokens,
      notification: {
        title: "Training Session Ready!",
        body: `Great news! "${sessionData.title}" now has enough participants (${participantIds.length}/${minParticipants})`,
      },
      data: {
        type: "training_min_participants_reached",
        sessionId,
        groupId,
        participantCount: String(participantIds.length),
        minParticipants: String(minParticipants),
      },
      android: {
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    await sendMulticastNotification(db, message, userTokenMap, allTokens, eventContext);
  } catch (error) {
    functions.logger.error("Error sending min participants notification", {
      sessionId,
      groupId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });
  }
}

/**
 * Handle session cancelled notification
 */
async function handleSessionCancelled(
  db: admin.firestore.Firestore,
  sessionId: string,
  sessionData: any
): Promise<void> {
  const groupId = sessionData.groupId;
  const participantIds = sessionData.participantIds || [];
  const cancellerId = sessionData.cancelledBy || sessionData.createdBy;

  functions.logger.info("Training session cancelled, processing notifications", {
    sessionId,
    groupId,
    participantCount: participantIds.length,
    cancellerId,
  });

  try {
    // Notify all participants except the canceller
    const recipientIds = participantIds.filter((id: string) => id !== cancellerId);

    if (recipientIds.length === 0) {
      functions.logger.info("No recipients for cancellation notification", {
        sessionId,
        groupId,
      });
      return;
    }

    // Collect eligible tokens
    const eventContext = { sessionId, eventType: "training_session_cancelled" };
    const { allTokens, userTokenMap } = await collectEligibleTokens(
      db,
      recipientIds,
      groupId,
      "trainingSessionCancelled",
      eventContext
    );

    if (allTokens.length === 0) {
      functions.logger.info("No eligible recipients for notification", eventContext);
      return;
    }

    // Send notification
    const message: admin.messaging.MulticastMessage = {
      tokens: allTokens,
      notification: {
        title: "Training Session Cancelled",
        body: `Training session "${sessionData.title}" has been cancelled`,
      },
      data: {
        type: "training_session_cancelled",
        sessionId,
        groupId,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    await sendMulticastNotification(db, message, userTokenMap, allTokens, eventContext);
  } catch (error) {
    functions.logger.error("Error sending cancellation notification", {
      sessionId,
      groupId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });
  }
}

// ============================================================================
// Firestore Trigger: onTrainingFeedbackCreated
// Notifies all participants when someone submits feedback
// ============================================================================

export const onTrainingFeedbackCreated = functions.firestore
  .document("trainingSessions/{sessionId}/feedback/{feedbackId}")
  .onCreate(async (snapshot, context) => {
    const feedbackData = snapshot.data();
    const sessionId = context.params.sessionId;
    const feedbackId = context.params.feedbackId;
    const reviewerId = feedbackData.participantId;

    functions.logger.info("Training feedback created, processing notifications", {
      sessionId,
      feedbackId,
      reviewerId,
    });

    const db = admin.firestore();

    try {
      // Get session data
      const sessionData = await getTrainingSessionData(db, sessionId);
      if (!sessionData) {
        functions.logger.error("Training session not found for feedback notification", {
          sessionId,
          feedbackId,
        });
        return null;
      }

      const groupId = sessionData.groupId;

      // Get reviewer data
      const reviewerData = await getUserData(db, reviewerId);
      const reviewerName = reviewerData?.displayName || "Someone";

      // Notify all participants (to encourage others to leave feedback)
      // Exclude the reviewer themselves
      const recipientIds = sessionData.participantIds.filter((id) => id !== reviewerId);

      if (recipientIds.length === 0) {
        functions.logger.info("No recipients for feedback notification", {
          sessionId,
          feedbackId,
        });
        return null;
      }

      // Collect eligible tokens
      const eventContext = { sessionId, eventType: "training_feedback_received" };
      const { allTokens, userTokenMap } = await collectEligibleTokens(
        db,
        recipientIds,
        groupId,
        "trainingFeedbackReceived",
        eventContext
      );

      if (allTokens.length === 0) {
        functions.logger.info("No eligible recipients for notification", eventContext);
        return null;
      }

      // Send notification
      const message: admin.messaging.MulticastMessage = {
        tokens: allTokens,
        notification: {
          title: "New Feedback",
          body: `${reviewerName} left feedback on "${sessionData.title}"`,
        },
        data: {
          type: "training_feedback_received",
          sessionId,
          groupId,
          feedbackId,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: "default",
            },
          },
        },
      };

      await sendMulticastNotification(db, message, userTokenMap, allTokens, eventContext);

      return null;
    } catch (error) {
      functions.logger.error("Error sending feedback notification", {
        sessionId,
        feedbackId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

// ============================================================================
// Firestore Trigger: onParticipantJoined (Refactored)
// Notifies group members when someone joins a training session
// ============================================================================

export const onParticipantJoined = functions.firestore
  .document("trainingSessions/{sessionId}/participants/{userId}")
  .onCreate(async (snapshot, context) => {
    const sessionId = context.params.sessionId;
    const userId = context.params.userId;
    const participantData = snapshot.data();

    // Only proceed if status is 'joined'
    if (participantData.status !== "joined") {
      functions.logger.debug("Skipping notification - participant status is not 'joined'", {
        sessionId,
        userId,
        status: participantData.status,
      });
      return null;
    }

    functions.logger.info("Participant joined training session, processing notifications", {
      sessionId,
      userId,
    });

    const db = admin.firestore();

    try {
      // Get training session data
      const sessionData = await getTrainingSessionData(db, sessionId);
      if (!sessionData) {
        functions.logger.error("Training session not found", { sessionId, userId });
        return null;
      }

      const groupId = sessionData.groupId;

      // Get participant user data
      const participantUser = await getUserData(db, userId);
      if (!participantUser) {
        functions.logger.error("User not found", { sessionId, userId });
        return null;
      }

      // Get all group members
      const groupMemberIds = await getGroupMemberIds(db, groupId);

      // Filter out the participant who just joined
      const recipientIds = groupMemberIds.filter((id) => id !== userId);

      if (recipientIds.length === 0) {
        functions.logger.info("No recipients for participant joined notification", {
          sessionId,
          groupId,
        });
        return null;
      }

      // Collect eligible tokens - using memberJoined preference for now
      // (could be a separate trainingParticipantJoined preference)
      const eventContext = { sessionId, eventType: "training_participant_joined" };
      const { allTokens, userTokenMap } = await collectEligibleTokens(
        db,
        recipientIds,
        groupId,
        "trainingSessionCreated", // Use the training session preference
        eventContext
      );

      if (allTokens.length === 0) {
        functions.logger.info("No eligible recipients for notification", eventContext);
        return null;
      }

      // Format date for notification
      const dateStr = formatDateTime(sessionData.startTime);

      // Send notification
      const message: admin.messaging.MulticastMessage = {
        tokens: allTokens,
        notification: {
          title: `${participantUser.displayName} joined training`,
          body: `${participantUser.displayName} joined "${sessionData.title}" on ${dateStr}`,
        },
        data: {
          type: "training_participant_joined",
          sessionId,
          groupId,
          participantId: userId,
          participantName: participantUser.displayName,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: "default",
            },
          },
        },
      };

      await sendMulticastNotification(db, message, userTokenMap, allTokens, eventContext);

      return null;
    } catch (error) {
      functions.logger.error("Error sending participant joined notification", {
        sessionId,
        userId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

// ============================================================================
// Firestore Trigger: onParticipantLeft (Refactored)
// Notifies group members and organizer when someone leaves a training session
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
      return null;
    }

    functions.logger.info("Participant left training session, processing notifications", {
      sessionId,
      userId,
    });

    const db = admin.firestore();

    try {
      // Get training session data
      const sessionData = await getTrainingSessionData(db, sessionId);
      if (!sessionData) {
        functions.logger.error("Training session not found", { sessionId, userId });
        return null;
      }

      const groupId = sessionData.groupId;

      // Get participant user data
      const participantUser = await getUserData(db, userId);
      if (!participantUser) {
        functions.logger.error("User not found", { sessionId, userId });
        return null;
      }

      // Get all group members
      const groupMemberIds = await getGroupMemberIds(db, groupId);

      // Filter out the participant who just left and the organizer (handled separately)
      const recipientIds = groupMemberIds.filter(
        (id) => id !== userId && id !== sessionData.createdBy
      );

      const eventContext = { sessionId, eventType: "training_participant_left" };

      // Notify organizer separately with different message
      if (
        groupMemberIds.includes(sessionData.createdBy) &&
        sessionData.createdBy !== userId
      ) {
        const organizerTokens = await collectEligibleTokens(
          db,
          [sessionData.createdBy],
          groupId,
          "trainingSessionCreated",
          eventContext
        );

        if (organizerTokens.allTokens.length > 0) {
          const organizerMessage: admin.messaging.MulticastMessage = {
            tokens: organizerTokens.allTokens,
            notification: {
              title: `${participantUser.displayName} left training`,
              body: `${participantUser.displayName} left "${sessionData.title}". You may need to find a replacement.`,
            },
            data: {
              type: "training_participant_left",
              sessionId,
              groupId,
              participantId: userId,
              participantName: participantUser.displayName,
              isOrganizer: "true",
            },
            android: {
              priority: "high",
              notification: {
                channelId: "high_importance_channel",
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
              },
            },
            apns: {
              payload: {
                aps: {
                  badge: 1,
                  sound: "default",
                },
              },
            },
          };

          await sendMulticastNotification(
            db,
            organizerMessage,
            organizerTokens.userTokenMap,
            organizerTokens.allTokens,
            { ...eventContext, eventType: "training_participant_left_organizer" }
          );
        }
      }

      // Notify other group members
      if (recipientIds.length === 0) {
        functions.logger.info("No other recipients for participant left notification", {
          sessionId,
          groupId,
        });
        return null;
      }

      const { allTokens, userTokenMap } = await collectEligibleTokens(
        db,
        recipientIds,
        groupId,
        "trainingSessionCreated",
        eventContext
      );

      if (allTokens.length === 0) {
        functions.logger.info("No eligible recipients for notification", eventContext);
        return null;
      }

      // Send notification to other members
      const message: admin.messaging.MulticastMessage = {
        tokens: allTokens,
        notification: {
          title: `${participantUser.displayName} left training`,
          body: `${participantUser.displayName} left "${sessionData.title}"`,
        },
        data: {
          type: "training_participant_left",
          sessionId,
          groupId,
          participantId: userId,
          participantName: participantUser.displayName,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: "default",
            },
          },
        },
      };

      await sendMulticastNotification(db, message, userTokenMap, allTokens, eventContext);

      return null;
    } catch (error) {
      functions.logger.error("Error sending participant left notification", {
        sessionId,
        userId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

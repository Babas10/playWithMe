import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Helper function to check if current time is within quiet hours
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
 * Send notification when user is invited to a group
 */
export const onInvitationCreated = functions.firestore
  .document("users/{userId}/invitations/{invitationId}")
  .onCreate(async (snapshot, context) => {
    const invitation = snapshot.data();
    const userId = context.params.userId;

    try {
      // Get user's FCM tokens
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .get();

      const userData = userDoc.data();
      if (!userData) {
        console.log(`User ${userId} not found`);
        return null;
      }

      const fcmTokens = userData.fcmTokens || [];
      if (fcmTokens.length === 0) {
        console.log(`User ${userId} has no FCM tokens`);
        return null;
      }

      // Check notification preferences
      const prefs = userData.notificationPreferences || {};
      if (prefs.groupInvitations === false) {
        console.log(`User ${userId} has disabled group invitation notifications`);
        return null;
      }

      // Check quiet hours
      if (isQuietHours(prefs.quietHours)) {
        console.log(`User ${userId} is in quiet hours`);
        return null;
      }

      // Get group details
      const groupDoc = await admin
        .firestore()
        .collection("groups")
        .doc(invitation.groupId)
        .get();

      const groupData = groupDoc.data();
      if (!groupData) {
        console.log(`Group ${invitation.groupId} not found`);
        return null;
      }

      // Send notification
      const message: admin.messaging.MulticastMessage = {
        tokens: fcmTokens,
        notification: {
          title: "Group Invitation",
          body: `${invitation.inviterName} invited you to join ${groupData.name}`,
          imageUrl: groupData.photoUrl,
        },
        data: {
          type: "invitation",
          groupId: invitation.groupId,
          invitationId: snapshot.id,
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

      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(
        `Successfully sent ${response.successCount} notifications for invitation`
      );

      // Remove invalid tokens
      if (response.failureCount > 0) {
        const tokensToRemove: string[] = [];
        response.responses.forEach((resp, idx) => {
          if (
            !resp.success &&
            (resp.error?.code === "messaging/invalid-registration-token" ||
              resp.error?.code === "messaging/registration-token-not-registered")
          ) {
            tokensToRemove.push(fcmTokens[idx]);
          }
        });

        if (tokensToRemove.length > 0) {
          await admin
            .firestore()
            .collection("users")
            .doc(userId)
            .update({
              fcmTokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
            });
          console.log(`Removed ${tokensToRemove.length} invalid tokens`);
        }
      }

      return null;
    } catch (error) {
      console.error("Error sending invitation notification:", error);
      return null;
    }
  });

/**
 * Send notification when invitation is accepted
 */
export const onInvitationAccepted = functions.firestore
  .document("users/{userId}/invitations/{invitationId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger if status changed to 'accepted'
    if (before.status !== "pending" || after.status !== "accepted") {
      return null;
    }

    const inviterId = after.invitedBy;

    try {
      // Get inviter's FCM tokens
      const inviterDoc = await admin
        .firestore()
        .collection("users")
        .doc(inviterId)
        .get();

      const inviterData = inviterDoc.data();
      if (!inviterData) {
        console.log(`Inviter ${inviterId} not found`);
        return null;
      }

      const fcmTokens = inviterData.fcmTokens || [];
      if (fcmTokens.length === 0) {
        console.log(`Inviter ${inviterId} has no FCM tokens`);
        return null;
      }

      // Check preferences
      const prefs = inviterData.notificationPreferences || {};
      if (prefs.invitationAccepted === false) {
        console.log(`Inviter ${inviterId} has disabled invitation accepted notifications`);
        return null;
      }

      if (isQuietHours(prefs.quietHours)) {
        console.log(`Inviter ${inviterId} is in quiet hours`);
        return null;
      }

      // Get accepter's details
      const accepterDoc = await admin
        .firestore()
        .collection("users")
        .doc(context.params.userId)
        .get();

      const accepterData = accepterDoc.data();
      const accepterName = accepterData?.displayName || "Someone";

      // Get group details
      const groupDoc = await admin
        .firestore()
        .collection("groups")
        .doc(after.groupId)
        .get();

      const groupData = groupDoc.data();
      const groupName = groupData?.name || "a group";

      // Send notification
      await admin.messaging().sendEachForMulticast({
        tokens: fcmTokens,
        notification: {
          title: "Invitation Accepted",
          body: `${accepterName} accepted your invitation to ${groupName}`,
          imageUrl: accepterData?.photoUrl,
        },
        data: {
          type: "invitation_accepted",
          groupId: after.groupId,
          userId: context.params.userId,
        },
      });

      console.log("Successfully sent invitation accepted notification");
      return null;
    } catch (error) {
      console.error("Error sending invitation accepted notification:", error);
      return null;
    }
  });

/**
 * Send notification when new game is created
 */
export const onGameCreated = functions.firestore
  .document("groups/{groupId}/games/{gameId}")
  .onCreate(async (snapshot, context) => {
    const game = snapshot.data();
    const groupId = context.params.groupId;

    try {
      // Get group members
      const groupDoc = await admin
        .firestore()
        .collection("groups")
        .doc(groupId)
        .get();

      const groupData = groupDoc.data();
      if (!groupData) {
        console.log(`Group ${groupId} not found`);
        return null;
      }

      const members: string[] = groupData.memberIds || [];

      // Get all members' FCM tokens (excluding game creator)
      const memberTokens: string[] = [];

      for (const memberId of members) {
        if (memberId === game.createdBy) {
          continue; // Don't notify creator
        }

        const memberDoc = await admin
          .firestore()
          .collection("users")
          .doc(memberId)
          .get();

        const memberData = memberDoc.data();
        if (!memberData) {
          continue;
        }

        const prefs = memberData.notificationPreferences || {};

        // Check global and group-specific preferences
        const groupPrefs = prefs.groupSpecific?.[groupId];
        const shouldNotify =
          groupPrefs?.gameCreated !== false && prefs.gameCreated !== false;

        if (!shouldNotify) {
          console.log(`Member ${memberId} has disabled game notifications`);
          continue;
        }

        if (isQuietHours(prefs.quietHours)) {
          console.log(`Member ${memberId} is in quiet hours`);
          continue;
        }

        const tokens = memberData.fcmTokens || [];
        memberTokens.push(...tokens);
      }

      if (memberTokens.length === 0) {
        console.log("No members to notify for new game");
        return null;
      }

      // Get creator details
      const creatorDoc = await admin
        .firestore()
        .collection("users")
        .doc(game.createdBy)
        .get();

      const creatorData = creatorDoc.data();
      const creatorName = creatorData?.displayName || "Someone";

      // Send notification
      await admin.messaging().sendEachForMulticast({
        tokens: memberTokens,
        notification: {
          title: `New Game in ${groupData.name}`,
          body: `${creatorName} created a new game`,
          imageUrl: groupData.photoUrl,
        },
        data: {
          type: "game_created",
          groupId: groupId,
          gameId: snapshot.id,
        },
      });

      console.log(`Successfully sent game created notification to ${memberTokens.length} tokens`);
      return null;
    } catch (error) {
      console.error("Error sending game created notification:", error);
      return null;
    }
  });

/**
 * Send notification when a member joins the group
 */
export const onMemberJoined = functions.firestore
  .document("groups/{groupId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const beforeMembers = before.memberIds || [];
    const afterMembers = after.memberIds || [];

    // Find new members
    const newMembers = afterMembers.filter((id: string) => !beforeMembers.includes(id));

    if (newMembers.length === 0) {
      return null;
    }

    const groupId = context.params.groupId;

    try {
      // Get all admin IDs
      const adminIds: string[] = after.adminIds || [];

      for (const newMemberId of newMembers) {
        // Get new member's details
        const newMemberDoc = await admin
          .firestore()
          .collection("users")
          .doc(newMemberId)
          .get();

        const newMemberData = newMemberDoc.data();
        const memberName = newMemberData?.displayName || "Someone";

        // Notify all admins
        const adminTokens: string[] = [];

        for (const adminId of adminIds) {
          const adminDoc = await admin
            .firestore()
            .collection("users")
            .doc(adminId)
            .get();

          const adminData = adminDoc.data();
          if (!adminData) {
            continue;
          }

          const prefs = adminData.notificationPreferences || {};
          if (prefs.memberJoined === false) {
            console.log(`Admin ${adminId} has disabled member joined notifications`);
            continue;
          }

          if (isQuietHours(prefs.quietHours)) {
            console.log(`Admin ${adminId} is in quiet hours`);
            continue;
          }

          const tokens = adminData.fcmTokens || [];
          adminTokens.push(...tokens);
        }

        if (adminTokens.length > 0) {
          await admin.messaging().sendEachForMulticast({
            tokens: adminTokens,
            notification: {
              title: "New Member Joined",
              body: `${memberName} joined ${after.name}`,
              imageUrl: newMemberData?.photoUrl,
            },
            data: {
              type: "member_joined",
              groupId: groupId,
              userId: newMemberId,
            },
          });

          console.log(`Notified admins about new member ${newMemberId}`);
        }
      }

      return null;
    } catch (error) {
      console.error("Error sending member joined notification:", error);
      return null;
    }
  });

/**
 * Send notification when a member leaves the group
 */
export const onMemberLeft = functions.firestore
  .document("groups/{groupId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const beforeMembers = before.memberIds || [];
    const afterMembers = after.memberIds || [];

    // Find removed members
    const removedMembers = beforeMembers.filter((id: string) => !afterMembers.includes(id));

    if (removedMembers.length === 0) {
      return null;
    }

    const groupId = context.params.groupId;

    try {
      // Get all admin IDs
      const adminIds: string[] = after.adminIds || [];

      for (const removedMemberId of removedMembers) {
        // Get removed member's name from before snapshot (might not exist anymore)
        const removedMemberDoc = await admin
          .firestore()
          .collection("users")
          .doc(removedMemberId)
          .get();

        const removedMemberData = removedMemberDoc.data();
        const memberName = removedMemberData?.displayName || "Someone";

        // Notify all admins
        const adminTokens: string[] = [];

        for (const adminId of adminIds) {
          const adminDoc = await admin
            .firestore()
            .collection("users")
            .doc(adminId)
            .get();

          const adminData = adminDoc.data();
          if (!adminData) {
            continue;
          }

          const prefs = adminData.notificationPreferences || {};
          if (prefs.memberLeft === false) {
            console.log(`Admin ${adminId} has disabled member left notifications`);
            continue;
          }

          if (isQuietHours(prefs.quietHours)) {
            console.log(`Admin ${adminId} is in quiet hours`);
            continue;
          }

          const tokens = adminData.fcmTokens || [];
          adminTokens.push(...tokens);
        }

        if (adminTokens.length > 0) {
          await admin.messaging().sendEachForMulticast({
            tokens: adminTokens,
            notification: {
              title: "Member Left",
              body: `${memberName} left ${after.name}`,
            },
            data: {
              type: "member_left",
              groupId: groupId,
              userId: removedMemberId,
            },
          });

          console.log(`Notified admins about member ${removedMemberId} leaving`);
        }
      }

      return null;
    } catch (error) {
      console.error("Error sending member left notification:", error);
      return null;
    }
  });

/**
 * Send notification when user's role changes (promoted to/demoted from admin)
 */
export const onRoleChanged = functions.firestore
  .document("groups/{groupId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const beforeAdmins = before.adminIds || [];
    const afterAdmins = after.adminIds || [];

    // Find newly promoted admins
    const promoted = afterAdmins.filter((id: string) => !beforeAdmins.includes(id));

    // Find demoted admins
    const demoted = beforeAdmins.filter((id: string) => !afterAdmins.includes(id));

    const groupId = context.params.groupId;

    try {
      // Notify promoted users
      for (const userId of promoted) {
        const userDoc = await admin.firestore().collection("users").doc(userId).get();

        const userData = userDoc.data();
        if (!userData) {
          continue;
        }

        const prefs = userData.notificationPreferences || {};
        if (prefs.roleChanged === false) {
          console.log(`User ${userId} has disabled role changed notifications`);
          continue;
        }

        if (isQuietHours(prefs.quietHours)) {
          console.log(`User ${userId} is in quiet hours`);
          continue;
        }

        const tokens = userData.fcmTokens || [];
        if (tokens.length > 0) {
          await admin.messaging().sendEachForMulticast({
            tokens: tokens,
            notification: {
              title: "Promoted to Admin",
              body: `You are now an admin of ${after.name}`,
            },
            data: {
              type: "role_changed",
              groupId: groupId,
              newRole: "admin",
            },
          });

          console.log(`Notified user ${userId} about promotion`);
        }
      }

      // Notify demoted users
      for (const userId of demoted) {
        const userDoc = await admin.firestore().collection("users").doc(userId).get();

        const userData = userDoc.data();
        if (!userData) {
          continue;
        }

        const prefs = userData.notificationPreferences || {};
        if (prefs.roleChanged === false) {
          console.log(`User ${userId} has disabled role changed notifications`);
          continue;
        }

        if (isQuietHours(prefs.quietHours)) {
          console.log(`User ${userId} is in quiet hours`);
          continue;
        }

        const tokens = userData.fcmTokens || [];
        if (tokens.length > 0) {
          await admin.messaging().sendEachForMulticast({
            tokens: tokens,
            notification: {
              title: "Role Changed",
              body: `You are no longer an admin of ${after.name}`,
            },
            data: {
              type: "role_changed",
              groupId: groupId,
              newRole: "member",
            },
          });

          console.log(`Notified user ${userId} about demotion`);
        }
      }

      return null;
    } catch (error) {
      console.error("Error sending role changed notification:", error);
      return null;
    }
  });

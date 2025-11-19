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
    const invitationId = context.params.invitationId;

    functions.logger.info("Invitation created, processing notification", {
      userId,
      invitationId,
      groupId: invitation.groupId,
      invitedBy: invitation.invitedBy,
    });

    try {
      // Get user's FCM tokens
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .get();

      const userData = userDoc.data();
      if (!userData) {
        functions.logger.warn("User not found for invitation notification", {
          userId,
          invitationId,
        });
        return null;
      }

      const fcmTokens = userData.fcmTokens || [];
      if (fcmTokens.length === 0) {
        functions.logger.info("User has no FCM tokens", {
          userId,
          invitationId,
        });
        return null;
      }

      // Check notification preferences
      const prefs = userData.notificationPreferences || {};
      if (prefs.groupInvitations === false) {
        functions.logger.info("User has disabled group invitation notifications", {
          userId,
          invitationId,
        });
        return null;
      }

      // Check quiet hours
      if (isQuietHours(prefs.quietHours)) {
        functions.logger.info("User is in quiet hours", {
          userId,
          invitationId,
        });
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
        functions.logger.warn("Group not found for invitation notification", {
          userId,
          invitationId,
          groupId: invitation.groupId,
        });
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
      functions.logger.info("Invitation notification sent successfully", {
        userId,
        invitationId,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });

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
          functions.logger.info("Removed invalid FCM tokens", {
            userId,
            invitationId,
            removedCount: tokensToRemove.length,
          });
        }
      }

      return null;
    } catch (error) {
      functions.logger.error("Error sending invitation notification", {
        userId,
        invitationId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
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
    const invitationId = context.params.invitationId;
    const userId = context.params.userId;

    functions.logger.info("Invitation accepted, processing notification", {
      inviterId,
      userId,
      invitationId,
      groupId: after.groupId,
    });

    try{
      // Get inviter's FCM tokens
      const inviterDoc = await admin
        .firestore()
        .collection("users")
        .doc(inviterId)
        .get();

      const inviterData = inviterDoc.data();
      if (!inviterData) {
        functions.logger.warn("Inviter not found", {
          inviterId,
          invitationId,
        });
        return null;
      }

      const fcmTokens = inviterData.fcmTokens || [];
      if (fcmTokens.length === 0) {
        functions.logger.info("Inviter has no FCM tokens", {
          inviterId,
          invitationId,
        });
        return null;
      }

      // Check preferences
      const prefs = inviterData.notificationPreferences || {};
      if (prefs.invitationAccepted === false) {
        functions.logger.info("Inviter has disabled invitation accepted notifications", {
          inviterId,
          invitationId,
        });
        return null;
      }

      if (isQuietHours(prefs.quietHours)) {
        functions.logger.info("Inviter is in quiet hours", {
          inviterId,
          invitationId,
        });
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

      functions.logger.info("Invitation accepted notification sent successfully", {
        inviterId,
        invitationId,
        userId,
      });
      return null;
    } catch (error) {
      functions.logger.error("Error sending invitation accepted notification", {
        inviterId,
        invitationId,
        userId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

/**
 * Send notification when a new game is created
 * Notifies all group members except the creator
 */
export const onGameCreated = functions.firestore
  .document("groups/{groupId}/games/{gameId}")
  .onCreate(async (snapshot, context) => {
    const game = snapshot.data();
    const groupId = context.params.groupId;
    const gameId = context.params.gameId;

    functions.logger.info("Game created, processing notifications", {
      groupId,
      gameId,
      createdBy: game.createdBy,
    });

    try {
      // Get group details
      const groupDoc = await admin
        .firestore()
        .collection("groups")
        .doc(groupId)
        .get();

      const groupData = groupDoc.data();
      if (!groupData) {
        functions.logger.warn("Group not found for game notification", {
          groupId,
          gameId,
        });
        return null;
      }

      const members: string[] = groupData.memberIds || [];

      functions.logger.debug("Processing game notifications for members", {
        groupId,
        gameId,
        memberCount: members.length,
      });

      // Get creator details for notification message
      const creatorDoc = await admin
        .firestore()
        .collection("users")
        .doc(game.createdBy)
        .get();

      const creatorData = creatorDoc.data();
      const creatorName = creatorData?.displayName || "Someone";

      // Track notifications sent per user for cleanup
      const userTokenMap = new Map<string, string[]>();
      const allTokens: string[] = [];

      // Collect FCM tokens from all eligible members
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
          functions.logger.debug("Member not found", {memberId, groupId, gameId});
          continue;
        }

        const fcmTokens = memberData.fcmTokens || [];
        if (fcmTokens.length === 0) {
          functions.logger.debug("Member has no FCM tokens", {memberId, groupId, gameId});
          continue;
        }

        const prefs = memberData.notificationPreferences || {};

        // Check global and group-specific preferences
        const groupPrefs = prefs.groupSpecific?.[groupId];
        const shouldNotify =
          groupPrefs?.gameCreated !== false && prefs.gameCreated !== false;

        if (!shouldNotify) {
          functions.logger.debug("Member has disabled game notifications", {
            memberId,
            groupId,
            gameId,
          });
          continue;
        }

        // Check quiet hours
        if (isQuietHours(prefs.quietHours)) {
          functions.logger.debug("Member is in quiet hours", {
            memberId,
            groupId,
            gameId,
          });
          continue;
        }

        // Add tokens to map for later cleanup if needed
        userTokenMap.set(memberId, fcmTokens);
        allTokens.push(...fcmTokens);
      }

      if (allTokens.length === 0) {
        functions.logger.info("No members to notify for new game", {
          groupId,
          gameId,
        });
        return null;
      }

      // Send notification
      const message: admin.messaging.MulticastMessage = {
        tokens: allTokens,
        notification: {
          title: `New Game in ${groupData.name}`,
          body: `${creatorName} created a new game${game.title ? `: ${game.title}` : ""}`,
          imageUrl: groupData.photoUrl,
        },
        data: {
          type: "game_created",
          groupId: groupId,
          gameId: snapshot.id,
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

      functions.logger.info("Game created notification sent successfully", {
        groupId,
        gameId,
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
          await admin
            .firestore()
            .collection("users")
            .doc(userId)
            .update({
              fcmTokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
            });

          functions.logger.info("Removed invalid FCM tokens", {
            userId,
            groupId,
            gameId,
            removedCount: tokensToRemove.length,
          });
        }
      }

      return null;
    } catch (error) {
      functions.logger.error("Error sending game created notification", {
        groupId,
        gameId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
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

    functions.logger.info("Member joined group, processing notifications", {
      groupId,
      newMemberCount: newMembers.length,
      newMembers,
    });

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
            functions.logger.info("Admin has disabled member joined notifications", {
              adminId,
              groupId,
              newMemberId,
            });
            continue;
          }

          if (isQuietHours(prefs.quietHours)) {
            functions.logger.debug("Admin is in quiet hours", {
              adminId,
              groupId,
              newMemberId,
            });
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

          functions.logger.info("Notified admins about new member", {
            groupId,
            newMemberId,
            adminTokenCount: adminTokens.length,
          });
        }
      }

      return null;
    } catch (error) {
      functions.logger.error("Error sending member joined notification", {
        groupId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
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

    functions.logger.info("Member left group, processing notifications", {
      groupId,
      removedMemberCount: removedMembers.length,
      removedMembers,
    });

    try{
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
            functions.logger.info("Admin has disabled member left notifications", {
              adminId,
              groupId,
              removedMemberId,
            });
            continue;
          }

          if (isQuietHours(prefs.quietHours)) {
            functions.logger.debug("Admin is in quiet hours", {
              adminId,
              groupId,
              removedMemberId,
            });
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

          functions.logger.info("Notified admins about member leaving", {
            groupId,
            removedMemberId,
            adminTokenCount: adminTokens.length,
          });
        }
      }

      return null;
    } catch (error) {
      functions.logger.error("Error sending member left notification", {
        groupId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
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

    if (promoted.length > 0 || demoted.length > 0) {
      functions.logger.info("Role changes detected, processing notifications", {
        groupId,
        promotedCount: promoted.length,
        demotedCount: demoted.length,
        promoted,
        demoted,
      });
    }

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
          functions.logger.info("User has disabled role changed notifications", {
            userId,
            groupId,
          });
          continue;
        }

        if (isQuietHours(prefs.quietHours)) {
          functions.logger.debug("User is in quiet hours", {
            userId,
            groupId,
          });
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

          functions.logger.info("Notified user about promotion", {
            userId,
            groupId,
          });
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
          functions.logger.info("User has disabled role changed notifications", {
            userId,
            groupId,
          });
          continue;
        }

        if (isQuietHours(prefs.quietHours)) {
          functions.logger.debug("User is in quiet hours", {
            userId,
            groupId,
          });
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

          functions.logger.info("Notified user about demotion", {
            userId,
            groupId,
          });
        }
      }

      return null;
    } catch (error) {
      functions.logger.error("Error sending role changed notification", {
        groupId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

/**
 * Send notification when a friend request is sent
 */
export const onFriendRequestSent = functions.firestore
  .document("friendships/{friendshipId}")
  .onCreate(async (snapshot, context) => {
    const friendship = snapshot.data();

    // Only trigger for pending status (new friend requests)
    if (friendship.status !== "pending") {
      return null;
    }

    const recipientId = friendship.recipientId;
    const initiatorId = friendship.initiatorId;
    const friendshipId = context.params.friendshipId;

    functions.logger.info("Friend request sent, processing notification", {
      friendshipId,
      initiatorId,
      recipientId,
    });

    try {
      // Get recipient's FCM tokens
      const recipientDoc = await admin
        .firestore()
        .collection("users")
        .doc(recipientId)
        .get();

      const recipientData = recipientDoc.data();
      if (!recipientData) {
        functions.logger.warn("Recipient not found for friend request notification", {
          friendshipId,
          recipientId,
        });
        return null;
      }

      const fcmTokens = recipientData.fcmTokens || [];
      if (fcmTokens.length === 0) {
        functions.logger.info("Recipient has no FCM tokens", {
          friendshipId,
          recipientId,
        });
        return null;
      }

      // Check notification preferences
      const prefs = recipientData.notificationPreferences || {};
      if (prefs.friendRequestReceived === false) {
        functions.logger.info("Recipient has disabled friend request notifications", {
          friendshipId,
          recipientId,
        });
        return null;
      }

      // Check quiet hours
      if (isQuietHours(prefs.quietHours)) {
        functions.logger.info("Recipient is in quiet hours", {
          friendshipId,
          recipientId,
        });
        return null;
      }

      // Get initiator details
      const initiatorDoc = await admin
        .firestore()
        .collection("users")
        .doc(initiatorId)
        .get();

      const initiatorData = initiatorDoc.data();
      const initiatorName =
        friendship.initiatorName ||
        initiatorData?.displayName ||
        "Someone";

      // Send notification
      const message: admin.messaging.MulticastMessage = {
        tokens: fcmTokens,
        notification: {
          title: "Friend Request",
          body: `${initiatorName} sent you a friend request`,
          imageUrl: initiatorData?.photoUrl,
        },
        data: {
          type: "friend_request",
          friendshipId: friendshipId,
          initiatorId: initiatorId,
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
      functions.logger.info("Friend request notification sent successfully", {
        friendshipId,
        recipientId,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });

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
            .doc(recipientId)
            .update({
              fcmTokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
            });
          functions.logger.info("Removed invalid FCM tokens", {
            friendshipId,
            recipientId,
            removedCount: tokensToRemove.length,
          });
        }
      }

      return null;
    } catch (error) {
      functions.logger.error("Error sending friend request notification", {
        friendshipId,
        recipientId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

/**
 * Send notification when a friend request is accepted
 */
export const onFriendRequestAccepted = functions.firestore
  .document("friendships/{friendshipId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger if status changed from pending to accepted
    if (before.status !== "pending" || after.status !== "accepted") {
      return null;
    }

    const initiatorId = after.initiatorId;
    const recipientId = after.recipientId;
    const friendshipId = context.params.friendshipId;

    functions.logger.info("Friend request accepted, processing notification", {
      friendshipId,
      initiatorId,
      recipientId,
    });

    try {
      // Get initiator's FCM tokens
      const initiatorDoc = await admin
        .firestore()
        .collection("users")
        .doc(initiatorId)
        .get();

      const initiatorData = initiatorDoc.data();
      if (!initiatorData) {
        functions.logger.warn("Initiator not found for friend accepted notification", {
          friendshipId,
          initiatorId,
        });
        return null;
      }

      const fcmTokens = initiatorData.fcmTokens || [];
      if (fcmTokens.length === 0) {
        functions.logger.info("Initiator has no FCM tokens", {
          friendshipId,
          initiatorId,
        });
        return null;
      }

      // Check notification preferences
      const prefs = initiatorData.notificationPreferences || {};
      if (prefs.friendRequestAccepted === false) {
        functions.logger.info("Initiator has disabled friend request accepted notifications", {
          friendshipId,
          initiatorId,
        });
        return null;
      }

      // Check quiet hours
      if (isQuietHours(prefs.quietHours)) {
        functions.logger.info("Initiator is in quiet hours", {
          friendshipId,
          initiatorId,
        });
        return null;
      }

      // Get recipient details
      const recipientDoc = await admin
        .firestore()
        .collection("users")
        .doc(recipientId)
        .get();

      const recipientData = recipientDoc.data();
      const recipientName =
        after.recipientName ||
        recipientData?.displayName ||
        "Someone";

      // Update both users' friendIds cache and friendCount
      const db = admin.firestore();
      await db.runTransaction(async (transaction) => {
        const initiatorRef = db.collection("users").doc(initiatorId);
        const recipientRef = db.collection("users").doc(recipientId);

        transaction.update(initiatorRef, {
          friendIds: admin.firestore.FieldValue.arrayUnion(recipientId),
          friendCount: admin.firestore.FieldValue.increment(1),
        });

        transaction.update(recipientRef, {
          friendIds: admin.firestore.FieldValue.arrayUnion(initiatorId),
          friendCount: admin.firestore.FieldValue.increment(1),
        });
      });

      functions.logger.info("Updated friend caches", {
        friendshipId,
        initiatorId,
        recipientId,
      });

      // Send notification
      const message: admin.messaging.MulticastMessage = {
        tokens: fcmTokens,
        notification: {
          title: "Friend Request Accepted",
          body: `${recipientName} accepted your friend request`,
          imageUrl: recipientData?.photoUrl,
        },
        data: {
          type: "friend_accepted",
          friendshipId: friendshipId,
          recipientId: recipientId,
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
      functions.logger.info("Friend request accepted notification sent successfully", {
        friendshipId,
        initiatorId,
        recipientId,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });

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
            .doc(initiatorId)
            .update({
              fcmTokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
            });
          functions.logger.info("Removed invalid FCM tokens", {
            friendshipId,
            initiatorId,
            removedCount: tokensToRemove.length,
          });
        }
      }

      return null;
    } catch (error) {
      functions.logger.error("Error sending friend request accepted notification", {
        friendshipId,
        initiatorId,
        recipientId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

/**
 * Silent cleanup when a friend request is declined
 */
export const onFriendRequestDeclined = functions.firestore
  .document("friendships/{friendshipId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger if status changed from pending to declined
    if (before.status !== "pending" || after.status !== "declined") {
      return null;
    }

    const friendshipId = context.params.friendshipId;

    // Silent cleanup - no notification sent
    // Log for analytics
    functions.logger.info("Friend request declined", {
      friendshipId,
      recipientId: after.recipientId,
      initiatorId: after.initiatorId,
    });

    return null;
  });

/**
 * Handle friend removal (cleanup caches)
 */
export const onFriendRemoved = functions.firestore
  .document("friendships/{friendshipId}")
  .onDelete(async (snapshot, context) => {
    const friendship = snapshot.data();
    const friendshipId = context.params.friendshipId;

    // Only process if friendship was accepted
    if (friendship.status !== "accepted") {
      functions.logger.info("Friendship deleted with non-accepted status, no cache cleanup needed", {
        friendshipId,
        status: friendship.status,
      });
      return null;
    }

    const initiatorId = friendship.initiatorId;
    const recipientId = friendship.recipientId;

    functions.logger.info("Friend removed, processing cache cleanup", {
      friendshipId,
      initiatorId,
      recipientId,
    });

    try {
      // Update both users' friendIds cache and friendCount
      const db = admin.firestore();
      await db.runTransaction(async (transaction) => {
        const initiatorRef = db.collection("users").doc(initiatorId);
        const recipientRef = db.collection("users").doc(recipientId);

        // Get current user documents to safely decrement
        const initiatorDoc = await transaction.get(initiatorRef);
        const recipientDoc = await transaction.get(recipientRef);

        if (initiatorDoc.exists) {
          transaction.update(initiatorRef, {
            friendIds: admin.firestore.FieldValue.arrayRemove(recipientId),
            friendCount: admin.firestore.FieldValue.increment(-1),
          });
        }

        if (recipientDoc.exists) {
          transaction.update(recipientRef, {
            friendIds: admin.firestore.FieldValue.arrayRemove(initiatorId),
            friendCount: admin.firestore.FieldValue.increment(-1),
          });
        }
      });

      functions.logger.info("Updated friend caches after removal", {
        friendshipId,
        initiatorId,
        recipientId,
      });

      // Optional: Notify the other user
      // For now, we'll skip notification as specified (friendRemoved default is false)
      // Future enhancement: Check both users' preferences and notify if enabled

      return null;
    } catch (error) {
      functions.logger.error("Error handling friend removal", {
        friendshipId,
        initiatorId,
        recipientId,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

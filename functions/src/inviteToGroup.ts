// Cloud Function for inviting users to groups with social graph validation
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {checkFriendship} from "./friendships";

// ============================================================================
// Type Definitions
// ============================================================================

interface InviteToGroupRequest {
  groupId: string;
  invitedUserId: string;
}

interface InviteToGroupResponse {
  success: boolean;
  invitationId: string;
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Check if a user exists in Firestore
 */
async function userExists(userId: string): Promise<boolean> {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(userId).get();
  return userDoc.exists;
}

/**
 * Get user profile data (minimal fields needed)
 */
async function getUserProfile(userId: string): Promise<{
  displayName: string;
  email: string;
} | null> {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(userId).get();

  if (!userDoc.exists) {
    return null;
  }

  const userData = userDoc.data()!;
  return {
    displayName: userData.displayName || userData.email,
    email: userData.email,
  };
}

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
 * Check if user already has a pending invitation for this group
 */
async function hasPendingInvitation(
  userId: string,
  groupId: string
): Promise<boolean> {
  const db = admin.firestore();
  const invitationsSnapshot = await db
    .collection("users")
    .doc(userId)
    .collection("invitations")
    .where("groupId", "==", groupId)
    .where("status", "==", "pending")
    .limit(1)
    .get();

  return !invitationsSnapshot.empty;
}

// Note: Member check is done inline in the handler by accessing groupData.members
// Keeping this helper for potential future use
// async function isGroupMember(userId: string, groupId: string): Promise<boolean> {
//   const groupData = await getGroupData(groupId);
//   if (!groupData) {
//     return false;
//   }
//   return groupData.members.includes(userId);
// }

// ============================================================================
// Cloud Function: Invite to Group
// ============================================================================

/**
 * Handler for inviting a user to a group
 * Story 11.16: Validates friendship via social graph before allowing invitation
 *
 * This function enforces the architectural boundary:
 * Groups layer → Social Graph API (checkFriendship)
 *
 * Security validations:
 * 1. Authenticated user check
 * 2. Input parameter validation
 * 3. Group existence check
 * 4. Group membership check (inviter must be a member)
 * 5. Friendship validation (inviter and invitee must be friends)
 * 6. Duplicate invitation check
 * 7. Self-invitation check
 */
export async function inviteToGroupHandler(
  data: InviteToGroupRequest,
  context: functions.https.CallableContext
): Promise<InviteToGroupResponse> {
  // 1. Authentication check
  if (!context.auth) {
    functions.logger.warn("Unauthenticated inviteToGroup attempt");
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to invite users to groups"
    );
  }

  const inviterId = context.auth.uid;

  // 2. Validate input parameters
  if (!data || typeof data.groupId !== "string") {
    functions.logger.warn("Missing or invalid groupId", {
      inviterId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'groupId' is required and must be a string"
    );
  }

  if (!data || typeof data.invitedUserId !== "string") {
    functions.logger.warn("Missing or invalid invitedUserId", {
      inviterId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'invitedUserId' is required and must be a string"
    );
  }

  const {groupId, invitedUserId} = data;

  functions.logger.info("Inviting user to group", {
    inviterId,
    invitedUserId,
    groupId,
  });

  // 7. Cannot invite yourself
  if (inviterId === invitedUserId) {
    functions.logger.warn("Attempt to invite self to group", {
      inviterId,
      groupId,
    });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "You cannot invite yourself to a group"
    );
  }

  try {
    // 3. Check if group exists
    const groupData = await getGroupData(groupId);
    if (!groupData) {
      functions.logger.warn("Group not found", {
        inviterId,
        groupId,
      });
      throw new functions.https.HttpsError(
        "not-found",
        "The group you're trying to invite to doesn't exist"
      );
    }

    // 4. Check if inviter is a member of the group
    if (!groupData.memberIds.includes(inviterId)) {
      functions.logger.warn("Non-member attempting to invite to group", {
        inviterId,
        groupId,
      });
      throw new functions.https.HttpsError(
        "permission-denied",
        "You must be a member of the group to invite others"
      );
    }

    // Check if invitee exists
    const inviteeExists = await userExists(invitedUserId);
    if (!inviteeExists) {
      functions.logger.warn("Invitee user not found", {
        inviterId,
        invitedUserId,
        groupId,
      });
      throw new functions.https.HttpsError(
        "not-found",
        "The user you're trying to invite doesn't exist"
      );
    }

    // 5. STORY 11.16: Validate friendship using social graph API
    // This is the key enforcement of the architectural boundary:
    // Groups layer queries the social graph via checkFriendship helper
    const areFriends = await checkFriendship(inviterId, invitedUserId);

    if (!areFriends) {
      functions.logger.warn("Attempt to invite non-friend to group", {
        inviterId,
        invitedUserId,
        groupId,
      });
      throw new functions.https.HttpsError(
        "permission-denied",
        "You can only invite friends to groups"
      );
    }

    functions.logger.debug("Friendship validated", {
      inviterId,
      invitedUserId,
      groupId,
    });

    // 6. Check if user is already a member
    if (groupData.memberIds.includes(invitedUserId)) {
      functions.logger.warn("User already a member of group", {
        inviterId,
        invitedUserId,
        groupId,
      });
      throw new functions.https.HttpsError(
        "already-exists",
        "This user is already a member of the group"
      );
    }

    // Check if there's already a pending invitation
    const hasPending = await hasPendingInvitation(invitedUserId, groupId);
    if (hasPending) {
      functions.logger.warn("Pending invitation already exists", {
        inviterId,
        invitedUserId,
        groupId,
      });
      throw new functions.https.HttpsError(
        "already-exists",
        "This user already has a pending invitation to this group"
      );
    }

    // Get user profiles for denormalized data
    const inviterProfile = await getUserProfile(inviterId);
    const inviteeProfile = await getUserProfile(invitedUserId);

    if (!inviterProfile || !inviteeProfile) {
      functions.logger.error("Failed to retrieve user profiles", {
        inviterId,
        invitedUserId,
        hasInviter: !!inviterProfile,
        hasInvitee: !!inviteeProfile,
      });
      throw new functions.https.HttpsError(
        "internal",
        "Failed to retrieve user profiles"
      );
    }

    // Create invitation document
    const db = admin.firestore();
    const invitationRef = await db
      .collection("users")
      .doc(invitedUserId)
      .collection("invitations")
      .add({
        groupId,
        groupName: groupData.name,
        invitedUserId,
        invitedBy: inviterId,
        inviterName: inviterProfile.displayName,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    functions.logger.info("Group invitation created successfully", {
      inviterId,
      invitedUserId,
      groupId,
      invitationId: invitationRef.id,
    });

    return {
      success: true,
      invitationId: invitationRef.id,
    };
  } catch (error) {
    // Re-throw HttpsError
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("Error inviting user to group", {
      inviterId,
      invitedUserId,
      groupId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to send group invitation"
    );
  }
}

/**
 * Cloud Function to invite a user to a group
 * Story 11.16: Enforces that only confirmed friends can be invited to groups
 */
export const inviteToGroup = functions.https.onCall(inviteToGroupHandler);

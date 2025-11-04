// Cloud Functions entry point
import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export all Cloud Functions
export {searchUserByEmail} from "./searchUserByEmail";
export {checkPendingInvitation} from "./checkPendingInvitation";
export {acceptInvitation} from "./acceptInvitation";
export {declineInvitation} from "./declineInvitation";
export {getUsersByIds} from "./getUsersByIds";
export {leaveGroup} from "./leaveGroup";

// Export friendship functions
export {
  sendFriendRequest,
  acceptFriendRequest,
  declineFriendRequest,
  removeFriend,
  getFriends,
  checkFriendshipStatus,
} from "./friendships";

// Export notification functions
export {
  onInvitationCreated,
  onInvitationAccepted,
  onGameCreated,
  onMemberJoined,
  onMemberLeft,
  onRoleChanged,
  onFriendRequestSent,
  onFriendRequestAccepted,
  onFriendRequestDeclined,
  onFriendRemoved,
} from "./notifications";

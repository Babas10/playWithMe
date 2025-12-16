// Cloud Functions entry point
import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Export Auth triggers
export {createUserDocument, deleteUserDocument} from "./createUserDocument";

// Export all Cloud Functions
export {searchUserByEmail} from "./searchUserByEmail";
export {searchUsers} from "./searchUsers"; // Story 11.12
export {checkPendingInvitation} from "./checkPendingInvitation";
export {acceptInvitation} from "./acceptInvitation";
export {declineInvitation} from "./declineInvitation";
export {getUsersByIds} from "./getUsersByIds";
export {leaveGroup} from "./leaveGroup";
export {inviteToGroup} from "./inviteToGroup"; // Story 11.16
export {getGamesForGroup} from "./getGamesForGroup"; // Story 3.5
export {getCompletedGames} from "./getCompletedGames"; // Story 14.7

// Export friendship functions (callable functions)
export {
  sendFriendRequest,
  acceptFriendRequest,
  declineFriendRequest,
  removeFriend,
  getFriends,
  checkFriendshipStatus,
  getFriendshipRequests,
  getFriendships, // Story 11.13
  verifyFriendship, // Story 11.14
  batchCheckFriendship, // Story 11.17
} from "./friendships";

// Export friendship cache update triggers (Firestore triggers)
// Note: These are different from notification triggers - they update cached friendIds
export {
  onFriendRequestAccepted as onFriendshipCacheUpdate,
  onFriendRemoved as onFriendshipCacheRemove,
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
  onPlayerJoinedGame,
  onPlayerLeftGame,
  onWaitlistPromoted,
  onGameResultSubmitted, // Story 14.15
} from "./notifications";

// Export game update triggers
export {
  onGameStatusChanged, // Story 14.16 (ELO updates)
} from "./gameUpdates";

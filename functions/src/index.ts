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
export {getPublicUserProfile} from "./getPublicUserProfile"; // Issue #317
export {leaveGroup} from "./leaveGroup";
export {inviteToGroup} from "./inviteToGroup"; // Story 11.16
export {getGamesForGroup} from "./getGamesForGroup"; // Story 3.5
export {getUpcomingGamesForUser} from "./getUpcomingGamesForUser"; // Story #445
export {getCompletedGames} from "./getCompletedGames"; // Story 14.7
export {getHeadToHeadStats} from "./getHeadToHeadStats"; // Story 301.8
export {calculateUserRanking} from "./calculateUserRanking"; // Story 302.2
export {createTrainingSession} from "./createTrainingSession"; // Story 15.1 (Epic 15: Training Sessions)
export {generateRecurringTrainingSessions} from "./generateRecurringTrainingSessions"; // Story 15.2 (Recurring Training Sessions)
export {joinTrainingSession} from "./joinTrainingSession"; // Story 15.3 (Join Training Session)
export {leaveTrainingSession} from "./leaveTrainingSession"; // Story 15.3 (Leave Training Session)
export {cancelTrainingSession} from "./cancelTrainingSession"; // Story 15.14 (Cancel Training Session)
export {submitTrainingFeedback} from "./submitTrainingFeedback"; // Story 15.8 (Anonymous Feedback)
export {hasSubmittedTrainingFeedback} from "./hasSubmittedTrainingFeedback"; // Story 15.8 (Anonymous Feedback)
export {getTrainingFeedback} from "./getTrainingFeedback"; // Story 15.11 (Display Feedback)
export {
  onTrainingSessionCreated,
  onTrainingSessionUpdated,
  onTrainingFeedbackCreated,
  onParticipantJoined,
  onParticipantLeft,
} from "./trainingSessionNotifications"; // Story 15.13 (Training Session Lifecycle Notifications)

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
  onGameCancelled,
} from "./notifications";

// Export game update triggers
export {
  onGameStatusChanged, // Story 14.16 (ELO + teammate stats)
} from "./gameUpdates";

// Export head-to-head update triggers
export {
  onEloCalculationComplete, // Story 301.8 (H2H stats - triggers after ELO)
} from "./headToHeadGameUpdates";

export {
  onHeadToHeadStatsUpdated, // Story 301.8 (Nemesis - triggers after H2H update)
} from "./headToHeadUpdates";

// Export scheduled functions for game auto-abort
export {autoAbortGames} from "./autoAbortGames";


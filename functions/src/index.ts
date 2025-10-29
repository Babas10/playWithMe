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

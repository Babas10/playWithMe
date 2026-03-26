// Replicates getHeadToHeadStats function logic via Admin SDK Firestore queries.

import { Scenario } from "../runner";
import { testUserId } from "../seed";
import * as admin from "firebase-admin";

export function makeScenario(): Scenario {
  const db = admin.firestore();
  const userId = testUserId(1);
  const opponentId = testUserId(2);

  return {
    name: "getHeadToHeadStats",
    async run() {
      await db
        .collection("users")
        .doc(userId)
        .collection("headToHead")
        .doc(opponentId)
        .get();
    },
  };
}

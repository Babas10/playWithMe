// Replicates getGamesForGroup function logic via Admin SDK Firestore queries.

import { Scenario } from "../runner";
import { testGroupId, testUserId } from "../seed";
import * as admin from "firebase-admin";

export function makeScenario(): Scenario {
  const db = admin.firestore();
  const groupId = testGroupId(1);
  const userId = testUserId(1);

  return {
    name: "getGamesForGroup",
    async run() {
      const groupDoc = await db.collection("groups").doc(groupId).get();
      if (!groupDoc.exists) throw new Error("Seed group not found");

      const memberIds: string[] = groupDoc.data()?.memberIds ?? [];
      if (!memberIds.includes(userId)) throw new Error("User not in group");

      await db
        .collection("games")
        .where("groupId", "==", groupId)
        .orderBy("scheduledAt", "asc")
        .get();
    },
  };
}

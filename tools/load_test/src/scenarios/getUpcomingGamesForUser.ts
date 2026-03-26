// Replicates getUpcomingGamesForUser function logic via Admin SDK Firestore queries.

import { Scenario } from "../runner";
import { testUserId } from "../seed";
import * as admin from "firebase-admin";

export function makeScenario(): Scenario {
  const db = admin.firestore();
  const userId = testUserId(1);

  return {
    name: "getUpcomingGamesForUser",
    async run() {
      const now = admin.firestore.Timestamp.now();

      // Fetch groups the user belongs to
      const groupsSnap = await db
        .collection("groups")
        .where("memberIds", "array-contains", userId)
        .get();

      if (groupsSnap.empty) return;

      const groupIds = groupsSnap.docs.map((d) => d.id);

      // Fetch upcoming games across those groups (Firestore `in` limit: 30)
      const chunks: string[][] = [];
      for (let i = 0; i < groupIds.length; i += 30) {
        chunks.push(groupIds.slice(i, i + 30));
      }

      await Promise.all(
        chunks.map((chunk) =>
          db
            .collection("games")
            .where("groupId", "in", chunk)
            .where("scheduledAt", ">=", now)
            .where("status", "==", "scheduled")
            .orderBy("scheduledAt", "asc")
            .get()
        )
      );
    },
  };
}

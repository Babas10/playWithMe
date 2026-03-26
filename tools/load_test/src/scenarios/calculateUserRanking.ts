// Replicates calculateUserRanking function logic via Admin SDK Firestore queries.

import { Scenario } from "../runner";
import { testUserId } from "../seed";
import * as admin from "firebase-admin";

export function makeScenario(): Scenario {
  const db = admin.firestore();
  const userId = testUserId(1);

  return {
    name: "calculateUserRanking",
    async run() {
      // Fetch the user's own stats document
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) throw new Error("Seed user not found");

      const userData = userDoc.data()!;
      const userElo: number = userData.eloRating ?? 1000;

      // Count users with higher ELO (mirrors ranking computation)
      await db
        .collection("users")
        .where("eloRating", ">", userElo)
        .get();
    },
  };
}

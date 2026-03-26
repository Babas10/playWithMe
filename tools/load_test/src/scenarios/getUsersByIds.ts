// Replicates getUsersByIds function logic via Admin SDK Firestore queries.

import { Scenario } from "../runner";
import { testUserId } from "../seed";
import * as admin from "firebase-admin";

export function makeScenario(): Scenario {
  const db = admin.firestore();
  // Simulate a realistic batch of 5 user IDs
  const userIds = Array.from({ length: 5 }, (_, i) => testUserId(i + 1));

  return {
    name: "getUsersByIds",
    async run() {
      await db
        .collection("users")
        .where(admin.firestore.FieldPath.documentId(), "in", userIds)
        .get();
    },
  };
}

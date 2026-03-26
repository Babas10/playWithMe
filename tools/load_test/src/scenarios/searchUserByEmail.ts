// Replicates searchUserByEmail function logic via Admin SDK Firestore queries.

import { Scenario } from "../runner";
import * as admin from "firebase-admin";

export function makeScenario(): Scenario {
  const db = admin.firestore();
  const email = "load-test-user-1@gatherli-dev.test";

  return {
    name: "searchUserByEmail",
    async run() {
      await db
        .collection("users")
        .where("email", "==", email)
        .limit(1)
        .get();
    },
  };
}

// Replicates getFriends function logic via Admin SDK Firestore queries.

import { Scenario } from "../runner";
import { testUserId } from "../seed";
import * as admin from "firebase-admin";

export function makeScenario(): Scenario {
  const db = admin.firestore();
  const userId = testUserId(1);

  return {
    name: "getFriends",
    async run() {
      // Query accepted friendships where user is a participant
      const [sentSnap, receivedSnap] = await Promise.all([
        db
          .collection("friendships")
          .where("users", "array-contains", userId)
          .where("status", "==", "accepted")
          .get(),
        // friendships are symmetric — one query suffices with array-contains
        // but mirroring the Cloud Function's approach for accuracy
        db
          .collection("users")
          .doc(userId)
          .get(),
      ]);

      const friendIds: string[] = [];
      sentSnap.docs.forEach((doc) => {
        const users: string[] = doc.data().users ?? [];
        users.forEach((uid) => {
          if (uid !== userId) friendIds.push(uid);
        });
      });

      if (friendIds.length === 0) return;

      // Batch-fetch friend profiles (mirrors Cloud Function getUsersByIds logic)
      const chunks: string[][] = [];
      for (let i = 0; i < friendIds.length; i += 10) {
        chunks.push(friendIds.slice(i, i + 10));
      }

      await Promise.all(
        chunks.map((chunk) =>
          db.collection("users").where(admin.firestore.FieldPath.documentId(), "in", chunk).get()
        )
      );
    },
  };
}

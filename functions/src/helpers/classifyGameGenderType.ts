import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

export type GameGenderType = "male" | "female" | "mix";

/**
 * Classifies a game's gender type based on the current player list.
 *
 * Rules:
 * - Returns null when playerIds is empty (not enough information yet)
 * - Returns 'male' when all players have gender = 'male'
 * - Returns 'female' when all players have gender = 'female'
 * - Returns 'mix' when players have mixed genders, missing gender, or 'prefer_not_to_say'
 *
 * Story 26.4
 */
export async function classifyGameGenderType(
  playerIds: string[]
): Promise<GameGenderType | null> {
  if (playerIds.length === 0) {
    return null;
  }

  const db = admin.firestore();
  const genders = new Set<string>();

  for (const playerId of playerIds) {
    const userDoc = await db.collection("users").doc(playerId).get();
    const userData = userDoc.data();
    const gender: string | undefined = userData?.gender;

    if (!gender || gender === "prefer_not_to_say") {
      // Unknown or non-binary preference → treat as mixed
      functions.logger.debug("[classifyGameGenderType] Player has no classifiable gender", {
        playerId,
        gender: gender ?? "undefined",
      });
      return "mix";
    }

    genders.add(gender);
  }

  if (genders.size === 1) {
    return genders.has("male") ? "male" : "female";
  }

  return "mix";
}

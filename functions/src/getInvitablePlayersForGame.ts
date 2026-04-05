import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Request interface for getInvitablePlayersForGame Cloud Function
 */
export interface GetInvitablePlayersForGameRequest {
  gameId: string;
}

/**
 * A player the game creator can invite as a guest (Story 28.3)
 */
export interface InvitablePlayer {
  uid: string;
  displayName: string | null;
  photoUrl: string | null;
  sourceGroupId: string;    // the group through which this player was found
  sourceGroupName: string;
}

/**
 * Response interface for getInvitablePlayersForGame Cloud Function
 */
export interface GetInvitablePlayersForGameResponse {
  players: InvitablePlayer[];
}

/**
 * Handler function for getInvitablePlayersForGame (exported for unit testing).
 *
 * Returns the list of players the game creator can invite as guests.
 *
 * Logic:
 * 1. Validate auth + inputs
 * 2. Load game — verify caller is the creator
 * 3. Load all groups the caller belongs to, EXCLUDING the game's own group
 * 4. Collect unique member UIDs from those groups (first occurrence wins for sourceGroup)
 * 5. Subtract playerIds and UIDs with pending invitations
 * 6. Batch-fetch user profiles for remaining UIDs
 * 7. Return deduplicated list with sourceGroupId / sourceGroupName
 */
export async function getInvitablePlayersForGameHandler(
  data: GetInvitablePlayersForGameRequest,
  context: functions.https.CallableContext
): Promise<GetInvitablePlayersForGameResponse> {
  // ── 1. Auth ──────────────────────────────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to fetch invitable players."
    );
  }

  const callerId = context.auth.uid;
  const { gameId } = data;

  functions.logger.info("[getInvitablePlayersForGame] Start", { callerId, gameId });

  // ── 2. Input validation ──────────────────────────────────────────────────
  if (!gameId || typeof gameId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Parameter 'gameId' is required and must be a string."
    );
  }

  const db = admin.firestore();

  try {
    // ── 3. Load game — verify caller is creator ───────────────────────────
    const gameDoc = await db.collection("games").doc(gameId).get();

    if (!gameDoc.exists) {
      functions.logger.warn("[getInvitablePlayersForGame] Game not found", { callerId, gameId });
      throw new functions.https.HttpsError("not-found", "Game not found.");
    }

    const game = gameDoc.data()!;

    if (game.createdBy !== callerId) {
      functions.logger.warn("[getInvitablePlayersForGame] Caller is not game creator", {
        callerId,
        createdBy: game.createdBy,
        gameId,
      });
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only the game creator can fetch the list of invitable players."
      );
    }

    const gameGroupId: string = game.groupId;
    const alreadyIn = new Set<string>([
      ...(game.playerIds ?? []),
      callerId, // never suggest inviting yourself
    ]);

    // ── 4. Load groups caller belongs to (excluding the game's own group) ─
    const callerGroupsSnapshot = await db
      .collection("groups")
      .where("memberIds", "array-contains", callerId)
      .get();

    // Map: uid → { sourceGroupId, sourceGroupName } (first group wins)
    const candidateMap = new Map<string, { sourceGroupId: string; sourceGroupName: string }>();

    for (const groupDoc of callerGroupsSnapshot.docs) {
      if (groupDoc.id === gameGroupId) continue; // skip the game's own group

      const groupData = groupDoc.data();
      const members: string[] = groupData.memberIds ?? [];
      const groupName: string = groupData.name ?? "";

      for (const uid of members) {
        if (!alreadyIn.has(uid) && !candidateMap.has(uid)) {
          candidateMap.set(uid, { sourceGroupId: groupDoc.id, sourceGroupName: groupName });
        }
      }
    }

    // ── 5. Subtract pending invitees ─────────────────────────────────────
    if (candidateMap.size > 0) {
      const pendingSnapshot = await db
        .collection("gameInvitations")
        .where("gameId", "==", gameId)
        .where("status", "==", "pending")
        .get();

      for (const doc of pendingSnapshot.docs) {
        const inviteeId: string = doc.data().inviteeId;
        candidateMap.delete(inviteeId);
      }
    }

    if (candidateMap.size === 0) {
      functions.logger.info("[getInvitablePlayersForGame] No candidates found", { callerId, gameId });
      return { players: [] };
    }

    // ── 6. Batch-fetch user profiles ──────────────────────────────────────
    const candidateUids = Array.from(candidateMap.keys());

    // Firestore `in` queries support up to 30 values; batch accordingly.
    const BATCH_SIZE = 30;
    const profileBatches: Promise<admin.firestore.QuerySnapshot>[] = [];
    for (let i = 0; i < candidateUids.length; i += BATCH_SIZE) {
      const batch = candidateUids.slice(i, i + BATCH_SIZE);
      profileBatches.push(
        db
          .collection("users")
          .where(admin.firestore.FieldPath.documentId(), "in", batch)
          .get()
      );
    }

    const profileSnapshots = await Promise.all(profileBatches);

    const players: InvitablePlayer[] = [];
    for (const snapshot of profileSnapshots) {
      for (const userDoc of snapshot.docs) {
        const source = candidateMap.get(userDoc.id);
        if (!source) continue;

        const u = userDoc.data();
        players.push({
          uid: userDoc.id,
          displayName: u.displayName ?? null,
          photoUrl: u.photoUrl ?? null,
          sourceGroupId: source.sourceGroupId,
          sourceGroupName: source.sourceGroupName,
        });
      }
    }

    functions.logger.info("[getInvitablePlayersForGame] Done", {
      callerId,
      gameId,
      candidateCount: candidateUids.length,
      returnedCount: players.length,
    });

    // ── 7. Return ─────────────────────────────────────────────────────────
    return { players };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    functions.logger.error("[getInvitablePlayersForGame] Unexpected error", {
      callerId,
      gameId,
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });

    throw new functions.https.HttpsError(
      "internal",
      "Failed to fetch invitable players. Please try again."
    );
  }
}

/**
 * Callable Cloud Function — getInvitablePlayersForGame (Story 28.3)
 *
 * Returns candidates the game creator can invite as guest players:
 *  - Members of the creator's other groups (not the game's own group)
 *  - Excluding players already in the game (playerIds)
 *  - Excluding users who already have a pending invitation
 *  - Returns only non-sensitive fields: uid, displayName, photoUrl, sourceGroupId, sourceGroupName
 */
export const getInvitablePlayersForGame = functions
  .region("europe-west6")
  .https.onCall(getInvitablePlayersForGameHandler);

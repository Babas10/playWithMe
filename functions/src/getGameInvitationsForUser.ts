// getGameInvitationsForUser — Story 28.7
// Returns all pending game invitations for the authenticated user, enriched
// with game title, scheduled date, location, group name, and inviter display name.
// Invitees cannot read game/group/user docs directly (Firestore rules), so this
// function uses the Admin SDK to join the data server-side.

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = () => admin.firestore();

interface EnrichedInvitation {
  invitationId: string;
  gameId: string;
  groupId: string;
  inviterId: string;
  status: string;
  createdAt: string;
  expiresAt: string | null;
  gameTitle: string;
  gameScheduledAt: string;
  gameLocationName: string;
  groupName: string;
  inviterDisplayName: string;
}

export const getGameInvitationsForUserHandler = async (
  data: unknown,
  context: functions.https.CallableContext
): Promise<{ invitations: EnrichedInvitation[] }> => {
  // ── Authentication ────────────────────────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to view your invitations."
    );
  }

  const uid = context.auth.uid;

  try {
    // ── Fetch pending invitations ───────────────────────────────────────────
    const invitationsSnap = await db()
      .collection("gameInvitations")
      .where("inviteeId", "==", uid)
      .where("status", "==", "pending")
      .orderBy("createdAt", "desc")
      .get();

    if (invitationsSnap.empty) {
      return { invitations: [] };
    }

    const invDocs = invitationsSnap.docs;

    // ── Collect unique IDs for batch fetching ───────────────────────────────
    const gameIds = [...new Set(invDocs.map((d) => d.data().gameId as string))];
    const groupIds = [...new Set(invDocs.map((d) => d.data().groupId as string))];
    const inviterIds = [...new Set(invDocs.map((d) => d.data().inviterId as string))];

    // ── Parallel batch fetches ──────────────────────────────────────────────
    const [gameDocs, groupDocs, inviterDocs] = await Promise.all([
      Promise.all(gameIds.map((id) => db().collection("games").doc(id).get())),
      Promise.all(groupIds.map((id) => db().collection("groups").doc(id).get())),
      Promise.all(inviterIds.map((id) => db().collection("users").doc(id).get())),
    ]);

    // Build lookup maps
    const gameMap = new Map(gameDocs.map((d) => [d.id, d.data()]));
    const groupMap = new Map(groupDocs.map((d) => [d.id, d.data()]));
    const inviterMap = new Map(inviterDocs.map((d) => [d.id, d.data()]));

    // ── Enrich and return ───────────────────────────────────────────────────
    const invitations: EnrichedInvitation[] = invDocs.map((doc) => {
      const inv = doc.data();
      const game = gameMap.get(inv.gameId) ?? {};
      const group = groupMap.get(inv.groupId) ?? {};
      const inviter = inviterMap.get(inv.inviterId) ?? {};

      const scheduledAt: admin.firestore.Timestamp | undefined = game.scheduledAt;
      const createdAt: admin.firestore.Timestamp | undefined = inv.createdAt;
      const expiresAt: admin.firestore.Timestamp | undefined = inv.expiresAt;

      return {
        invitationId: doc.id,
        gameId: inv.gameId,
        groupId: inv.groupId,
        inviterId: inv.inviterId,
        status: inv.status,
        createdAt: createdAt?.toDate().toISOString() ?? new Date().toISOString(),
        expiresAt: expiresAt ? expiresAt.toDate().toISOString() : null,
        gameTitle: (game.title as string) ?? "Game",
        gameScheduledAt: scheduledAt?.toDate().toISOString() ?? new Date().toISOString(),
        gameLocationName: (game.location as { name?: string })?.name ?? "",
        groupName: (group.name as string) ?? "",
        inviterDisplayName: (inviter.displayName as string) ?? (inviter.email as string) ?? "",
      };
    });

    functions.logger.info("[getGameInvitationsForUser] success", {
      uid,
      count: invitations.length,
    });

    return { invitations };
  } catch (error) {
    functions.logger.error("[getGameInvitationsForUser] error", { uid, error });
    if (error instanceof functions.https.HttpsError) throw error;
    throw new functions.https.HttpsError(
      "internal",
      "Failed to load game invitations. Please try again."
    );
  }
};

export const getGameInvitationsForUser = functions
  .region("europe-west6")
  .https.onCall(getGameInvitationsForUserHandler);

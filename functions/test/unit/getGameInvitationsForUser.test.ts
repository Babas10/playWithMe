// Unit tests for getGameInvitationsForUser Cloud Function (Story 28.7)
// Validates auth guard, empty state, enrichment, and error handling.

import * as admin from "firebase-admin";
import { getGameInvitationsForUserHandler } from "../../src/getGameInvitationsForUser";

// ── Mock firebase-admin ──────────────────────────────────────────────────────
jest.mock("firebase-admin", () => {
  const actual = jest.requireActual("firebase-admin");
  return {
    ...actual,
    firestore: Object.assign(
      jest.fn(() => ({ collection: jest.fn() })),
      {
        FieldValue: { serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP") },
      }
    ),
  };
});

// ── Mock firebase-functions ──────────────────────────────────────────────────
jest.mock("firebase-functions", () => {
  const fn: any = {
    https: {
      HttpsError: class HttpsError extends Error {
        code: string;
        constructor(code: string, message: string) {
          super(message);
          this.code = code;
          this.name = "HttpsError";
        }
      },
      onCall: jest.fn((handler: any) => handler),
    },
    logger: { info: jest.fn(), warn: jest.fn(), error: jest.fn() },
  };
  fn.region = jest.fn(() => fn);
  return fn;
});

// ── Helpers ──────────────────────────────────────────────────────────────────

const AUTH_CTX = { auth: { uid: "invitee-uid" } } as any;

function makeTimestamp(iso: string) {
  return { toDate: () => new Date(iso) };
}

function buildMockDb({
  invitationDocs = [] as any[],
  gameDocs = [] as any[],
  groupDocs = [] as any[],
  userDocs = [] as any[],
} = {}) {
  return {
    collection: jest.fn((col: string) => {
      if (col === "gameInvitations") {
        return {
          where: jest.fn().mockReturnThis(),
          orderBy: jest.fn().mockReturnThis(),
          get: jest.fn().mockResolvedValue({
            empty: invitationDocs.length === 0,
            docs: invitationDocs,
          }),
        };
      }

      if (col === "games") {
        return {
          doc: jest.fn((id: string) => ({
            get: jest.fn().mockResolvedValue({
              id,
              data: () => gameDocs.find((d) => d.id === id)?.data ?? {},
            }),
          })),
        };
      }

      if (col === "groups") {
        return {
          doc: jest.fn((id: string) => ({
            get: jest.fn().mockResolvedValue({
              id,
              data: () => groupDocs.find((d) => d.id === id)?.data ?? {},
            }),
          })),
        };
      }

      if (col === "users") {
        return {
          doc: jest.fn((id: string) => ({
            get: jest.fn().mockResolvedValue({
              id,
              data: () => userDocs.find((d) => d.id === id)?.data ?? {},
            }),
          })),
        };
      }

      return {};
    }),
  };
}

const SAMPLE_INVITATION_DOC = {
  id: "inv-1",
  data: () => ({
    gameId: "game-1",
    groupId: "group-abc",
    inviteeId: "invitee-uid",
    inviterId: "creator-uid",
    status: "pending",
    createdAt: makeTimestamp("2026-06-01T10:00:00.000Z"),
    expiresAt: null,
  }),
};

const SAMPLE_GAME_DOC = {
  id: "game-1",
  data: {
    title: "Sunday Beach Volleyball",
    groupId: "group-abc",
    scheduledAt: makeTimestamp("2026-07-01T14:00:00.000Z"),
    location: { name: "Plage du Prado" },
  },
};

const SAMPLE_GROUP_DOC = {
  id: "group-abc",
  data: { name: "Beach Crew" },
};

const SAMPLE_INVITER_DOC = {
  id: "creator-uid",
  data: { displayName: "Alice", email: "alice@example.com" },
};

// ── Tests ─────────────────────────────────────────────────────────────────────

describe("getGameInvitationsForUser", () => {
  beforeEach(() => jest.clearAllMocks());

  describe("authentication", () => {
    it("throws unauthenticated when no auth context", async () => {
      const db = buildMockDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        getGameInvitationsForUserHandler({}, { auth: null } as any)
      ).rejects.toMatchObject({ code: "unauthenticated" });
    });
  });

  describe("empty state", () => {
    it("returns empty array when no pending invitations", async () => {
      const db = buildMockDb({ invitationDocs: [] });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getGameInvitationsForUserHandler({}, AUTH_CTX);
      expect(result.invitations).toEqual([]);
    });
  });

  describe("happy path", () => {
    it("returns enriched invitation with game/group/inviter details", async () => {
      const db = buildMockDb({
        invitationDocs: [SAMPLE_INVITATION_DOC],
        gameDocs: [SAMPLE_GAME_DOC],
        groupDocs: [SAMPLE_GROUP_DOC],
        userDocs: [SAMPLE_INVITER_DOC],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getGameInvitationsForUserHandler({}, AUTH_CTX);

      expect(result.invitations).toHaveLength(1);
      const inv = result.invitations[0];
      expect(inv.invitationId).toBe("inv-1");
      expect(inv.gameId).toBe("game-1");
      expect(inv.groupId).toBe("group-abc");
      expect(inv.gameTitle).toBe("Sunday Beach Volleyball");
      expect(inv.gameScheduledAt).toBe("2026-07-01T14:00:00.000Z");
      expect(inv.gameLocationName).toBe("Plage du Prado");
      expect(inv.groupName).toBe("Beach Crew");
      expect(inv.inviterDisplayName).toBe("Alice");
      expect(inv.status).toBe("pending");
    });

    it("falls back to email when inviter has no displayName", async () => {
      const db = buildMockDb({
        invitationDocs: [SAMPLE_INVITATION_DOC],
        gameDocs: [SAMPLE_GAME_DOC],
        groupDocs: [SAMPLE_GROUP_DOC],
        userDocs: [{ id: "creator-uid", data: { email: "creator@example.com" } }],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getGameInvitationsForUserHandler({}, AUTH_CTX);
      expect(result.invitations[0].inviterDisplayName).toBe("creator@example.com");
    });

    it("uses empty string fallbacks when game/group/inviter docs not found", async () => {
      const db = buildMockDb({
        invitationDocs: [SAMPLE_INVITATION_DOC],
        gameDocs: [],
        groupDocs: [],
        userDocs: [],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getGameInvitationsForUserHandler({}, AUTH_CTX);

      const inv = result.invitations[0];
      expect(inv.gameTitle).toBe("Game");
      expect(inv.groupName).toBe("");
      expect(inv.inviterDisplayName).toBe("");
    });

    it("handles multiple invitations and deduplicates batch fetches", async () => {
      const inv2 = {
        id: "inv-2",
        data: () => ({
          gameId: "game-1", // same game
          groupId: "group-abc",
          inviteeId: "invitee-uid",
          inviterId: "creator-uid",
          status: "pending",
          createdAt: makeTimestamp("2026-06-02T10:00:00.000Z"),
          expiresAt: null,
        }),
      };
      const db = buildMockDb({
        invitationDocs: [SAMPLE_INVITATION_DOC, inv2],
        gameDocs: [SAMPLE_GAME_DOC],
        groupDocs: [SAMPLE_GROUP_DOC],
        userDocs: [SAMPLE_INVITER_DOC],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getGameInvitationsForUserHandler({}, AUTH_CTX);

      expect(result.invitations).toHaveLength(2);
      // Both should have the same game title
      expect(result.invitations[0].gameTitle).toBe("Sunday Beach Volleyball");
      expect(result.invitations[1].gameTitle).toBe("Sunday Beach Volleyball");

      // Only one game doc fetch (deduplicated)
      const firestoreInstance = (admin.firestore as unknown as jest.Mock).mock.results[0].value;
      const gamesCollection = firestoreInstance.collection.mock.calls.filter(
        ([c]: [string]) => c === "games"
      );
      expect(gamesCollection.length).toBe(1);
    });

    it("includes expiresAt ISO string when set", async () => {
      const invWithExpiry = {
        id: "inv-expiry",
        data: () => ({
          gameId: "game-1",
          groupId: "group-abc",
          inviteeId: "invitee-uid",
          inviterId: "creator-uid",
          status: "pending",
          createdAt: makeTimestamp("2026-06-01T10:00:00.000Z"),
          expiresAt: makeTimestamp("2026-07-01T14:00:00.000Z"),
        }),
      };
      const db = buildMockDb({
        invitationDocs: [invWithExpiry],
        gameDocs: [SAMPLE_GAME_DOC],
        groupDocs: [SAMPLE_GROUP_DOC],
        userDocs: [SAMPLE_INVITER_DOC],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getGameInvitationsForUserHandler({}, AUTH_CTX);
      expect(result.invitations[0].expiresAt).toBe("2026-07-01T14:00:00.000Z");
    });
  });
});

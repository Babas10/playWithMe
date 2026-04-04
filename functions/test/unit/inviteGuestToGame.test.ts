// Unit tests for inviteGuestToGame Cloud Function (Story 28.2)
// Validates creator-only access, shared-group boundary, and deduplication logic.

import * as admin from "firebase-admin";
import { inviteGuestToGameHandler } from "../../src/inviteGuestToGame";

// ── Mock firebase-admin ──────────────────────────────────────────────────────
jest.mock("firebase-admin", () => {
  const actual = jest.requireActual("firebase-admin");
  return {
    ...actual,
    firestore: Object.assign(
      jest.fn(() => ({
        collection: jest.fn(),
      })),
      {
        FieldValue: {
          serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
        },
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
    logger: {
      info: jest.fn(),
      warn: jest.fn(),
      error: jest.fn(),
      debug: jest.fn(),
    },
  };
  fn.region = jest.fn(() => fn);
  return fn;
});

// ── Helpers ──────────────────────────────────────────────────────────────────

/** Minimal game doc data */
const makeGameData = (overrides: Partial<Record<string, any>> = {}) => ({
  groupId: "group-abc",
  createdBy: "creator-uid",
  playerIds: [],
  guestPlayerIds: [],
  scheduledAt: new Date("2026-06-01"),
  ...overrides,
});

/** Auth context for the game creator */
const creatorContext = { auth: { uid: "creator-uid" } };

/** Build a mock Firestore that satisfies the CF's read pattern */
function buildMockDb({
  gameExists = true,
  gameData = makeGameData(),
  pendingInvitationExists = false,
  callerGroupDocs = [
    { id: "group-abc", data: () => ({ memberIds: ["creator-uid", "invitee-uid"] }) },
  ],
  invitationDocId = "new-inv-id",
}: {
  gameExists?: boolean;
  gameData?: ReturnType<typeof makeGameData>;
  pendingInvitationExists?: boolean;
  callerGroupDocs?: { id: string; data: () => any }[];
  invitationDocId?: string;
} = {}): { db: any; invitationSetMock: jest.Mock } {
  const invitationSetMock = jest.fn().mockResolvedValue(undefined);
  const mockInvitationRef = { id: invitationDocId, set: invitationSetMock };

  const db = {
    collection: jest.fn((col: string) => {
      if (col === "games") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue({
              exists: gameExists,
              data: () => gameData,
            }),
          })),
        };
      }

      if (col === "gameInvitations") {
        return {
          where: jest.fn().mockReturnThis(),
          limit: jest.fn().mockReturnThis(),
          get: jest.fn().mockResolvedValue({
            empty: !pendingInvitationExists,
            docs: pendingInvitationExists ? [{ id: "existing-inv" }] : [],
          }),
          doc: jest.fn(() => mockInvitationRef),
        };
      }

      if (col === "groups") {
        return {
          where: jest.fn().mockReturnThis(),
          get: jest.fn().mockResolvedValue({ docs: callerGroupDocs }),
        };
      }

      return {};
    }),
  };

  return { db, invitationSetMock };
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("inviteGuestToGame", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  // ── Authentication ───────────────────���──────────────────────────────────

  describe("authentication", () => {
    it("throws unauthenticated when no auth context", async () => {
      const { db } = buildMockDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler({ gameId: "g1", inviteeId: "u1" }, { auth: null } as any)
      ).rejects.toMatchObject({ code: "unauthenticated" });
    });
  });

  // ── Input validation ────────────────────────────────────────────────────

  describe("input validation", () => {
    it("throws invalid-argument when gameId is missing", async () => {
      const { db } = buildMockDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler({ gameId: "", inviteeId: "u1" }, creatorContext as any)
      ).rejects.toMatchObject({ code: "invalid-argument" });
    });

    it("throws invalid-argument when inviteeId is missing", async () => {
      const { db } = buildMockDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler({ gameId: "g1", inviteeId: "" }, creatorContext as any)
      ).rejects.toMatchObject({ code: "invalid-argument" });
    });

    it("throws invalid-argument when caller invites themselves", async () => {
      const { db } = buildMockDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler(
          { gameId: "g1", inviteeId: "creator-uid" },
          creatorContext as any
        )
      ).rejects.toMatchObject({ code: "invalid-argument" });
    });
  });

  // ── Game validation ─────────────────────────────────────────────────────

  describe("game validation", () => {
    it("throws not-found when game does not exist", async () => {
      const { db } = buildMockDb({ gameExists: false });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler(
          { gameId: "ghost-game", inviteeId: "invitee-uid" },
          creatorContext as any
        )
      ).rejects.toMatchObject({ code: "not-found" });
    });

    it("throws permission-denied when caller is not the creator", async () => {
      const { db } = buildMockDb({ gameData: makeGameData({ createdBy: "other-user" }) });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler(
          { gameId: "g1", inviteeId: "invitee-uid" },
          creatorContext as any
        )
      ).rejects.toMatchObject({ code: "permission-denied" });
    });
  });

  // ── Deduplication ───────────────────────────────────────────────────────

  describe("deduplication", () => {
    it("throws already-exists when invitee is already a regular player", async () => {
      const { db } = buildMockDb({
        gameData: makeGameData({ playerIds: ["invitee-uid"] }),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler(
          { gameId: "g1", inviteeId: "invitee-uid" },
          creatorContext as any
        )
      ).rejects.toMatchObject({ code: "already-exists" });
    });

    it("throws already-exists when invitee is already a guest player", async () => {
      const { db } = buildMockDb({
        gameData: makeGameData({ guestPlayerIds: ["invitee-uid"] }),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler(
          { gameId: "g1", inviteeId: "invitee-uid" },
          creatorContext as any
        )
      ).rejects.toMatchObject({ code: "already-exists" });
    });

    it("throws already-exists when a pending invitation already exists", async () => {
      const { db } = buildMockDb({ pendingInvitationExists: true });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler(
          { gameId: "g1", inviteeId: "invitee-uid" },
          creatorContext as any
        )
      ).rejects.toMatchObject({ code: "already-exists" });
    });
  });

  // ── Shared-group trust boundary ─────────────────────────────────────────

  describe("shared-group trust boundary", () => {
    it("throws permission-denied when invitee shares no group with caller", async () => {
      const { db } = buildMockDb({
        callerGroupDocs: [
          { id: "group-x", data: () => ({ memberIds: ["creator-uid", "other-person"] }) },
        ],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler(
          { gameId: "g1", inviteeId: "invitee-uid" },
          creatorContext as any
        )
      ).rejects.toMatchObject({ code: "permission-denied" });
    });

    it("throws permission-denied when caller belongs to no groups", async () => {
      const { db } = buildMockDb({ callerGroupDocs: [] });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        inviteGuestToGameHandler(
          { gameId: "g1", inviteeId: "invitee-uid" },
          creatorContext as any
        )
      ).rejects.toMatchObject({ code: "permission-denied" });
    });

    it("succeeds when invitee is in a different group that the caller also belongs to", async () => {
      const { db } = buildMockDb({
        callerGroupDocs: [
          // game's own group — invitee not in it
          { id: "group-abc", data: () => ({ memberIds: ["creator-uid"] }) },
          // second group — shared with invitee
          { id: "group-xyz", data: () => ({ memberIds: ["creator-uid", "invitee-uid"] }) },
        ],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await inviteGuestToGameHandler(
        { gameId: "g1", inviteeId: "invitee-uid" },
        creatorContext as any
      );

      expect(result.success).toBe(true);
      expect(result.invitationId).toBe("new-inv-id");
    });
  });

  // ── Happy path ──────────────────────────────────────────────────────────

  describe("success", () => {
    it("creates an invitation document and returns invitationId", async () => {
      const { db, invitationSetMock } = buildMockDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await inviteGuestToGameHandler(
        { gameId: "game-1", inviteeId: "invitee-uid" },
        creatorContext as any
      );

      expect(result).toEqual({ success: true, invitationId: "new-inv-id" });

      // Verify the document was written with the correct shape
      expect(invitationSetMock).toHaveBeenCalledWith(
        expect.objectContaining({
          gameId: "game-1",
          groupId: "group-abc",
          inviteeId: "invitee-uid",
          inviterId: "creator-uid",
          status: "pending",
        })
      );
    });
  });
});

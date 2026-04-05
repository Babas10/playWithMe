// Unit tests for getInvitablePlayersForGame Cloud Function (Story 28.3)
// Validates creator-only access, cross-group lookup, and exclusion logic.

import * as admin from "firebase-admin";
import { getInvitablePlayersForGameHandler } from "../../src/getInvitablePlayersForGame";

// ── Mock firebase-admin ──────────────────────────────────────────────────────
jest.mock("firebase-admin", () => {
  const actual = jest.requireActual("firebase-admin");
  return {
    ...actual,
    firestore: Object.assign(
      jest.fn(() => ({ collection: jest.fn() })),
      {
        FieldValue: { serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP") },
        FieldPath: { documentId: jest.fn(() => "__name__") },
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
      onCall: jest.fn((h: any) => h),
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

const creatorContext = { auth: { uid: "creator-uid" } };

const makeGameData = (overrides: Partial<Record<string, any>> = {}) => ({
  groupId: "game-group",
  createdBy: "creator-uid",
  playerIds: [],
  guestPlayerIds: [],
  ...overrides,
});

const makeUserDoc = (uid: string, displayName = `User ${uid}`, photoUrl: string | null = null) => ({
  id: uid,
  exists: true,
  data: () => ({ displayName, photoUrl }),
});

/**
 * Build a mock Firestore with explicit data for each collection.
 *
 * @param gameData          Game document data
 * @param gameExists        Whether the game doc exists
 * @param callerGroups      Groups the caller belongs to (id + data)
 * @param pendingInvitees   UIDs that already have pending invitations
 * @param userDocs          User documents to return for profile fetch
 */
function buildMockDb({
  gameData = makeGameData(),
  gameExists = true,
  callerGroups = [
    { id: "other-group", data: () => ({ name: "Other Group", memberIds: ["creator-uid", "alice", "bob"] }) },
  ],
  pendingInvitees = [] as string[],
  userDocs = [makeUserDoc("alice"), makeUserDoc("bob")],
}: {
  gameData?: ReturnType<typeof makeGameData>;
  gameExists?: boolean;
  callerGroups?: { id: string; data: () => any }[];
  pendingInvitees?: string[];
  userDocs?: ReturnType<typeof makeUserDoc>[];
} = {}): any {
  return {
    collection: jest.fn((col: string) => {
      if (col === "games") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue({ exists: gameExists, data: () => gameData }),
          })),
        };
      }

      if (col === "groups") {
        return {
          where: jest.fn().mockReturnThis(),
          get: jest.fn().mockResolvedValue({ docs: callerGroups }),
        };
      }

      if (col === "gameInvitations") {
        return {
          where: jest.fn().mockReturnThis(),
          get: jest.fn().mockResolvedValue({
            docs: pendingInvitees.map((uid) => ({
              id: `inv-${uid}`,
              data: () => ({ inviteeId: uid }),
            })),
          }),
        };
      }

      if (col === "users") {
        return {
          where: jest.fn().mockReturnThis(),
          get: jest.fn().mockResolvedValue({ docs: userDocs }),
        };
      }

      return {};
    }),
  };
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("getInvitablePlayersForGame", () => {
  beforeEach(() => jest.clearAllMocks());

  // ── Auth + input validation ──────────────────────────────────────────────

  describe("authentication", () => {
    it("throws unauthenticated when no auth context", async () => {
      const db = buildMockDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        getInvitablePlayersForGameHandler({ gameId: "g1" }, { auth: null } as any)
      ).rejects.toMatchObject({ code: "unauthenticated" });
    });
  });

  describe("input validation", () => {
    it("throws invalid-argument when gameId is missing", async () => {
      const db = buildMockDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        getInvitablePlayersForGameHandler({ gameId: "" }, creatorContext as any)
      ).rejects.toMatchObject({ code: "invalid-argument" });
    });
  });

  // ── Game validation ──────────────────────────────────────────────────────

  describe("game validation", () => {
    it("throws not-found when game does not exist", async () => {
      const db = buildMockDb({ gameExists: false });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        getInvitablePlayersForGameHandler({ gameId: "ghost" }, creatorContext as any)
      ).rejects.toMatchObject({ code: "not-found" });
    });

    it("throws permission-denied when caller is not the creator", async () => {
      const db = buildMockDb({ gameData: makeGameData({ createdBy: "other-user" }) });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await expect(
        getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any)
      ).rejects.toMatchObject({ code: "permission-denied" });
    });
  });

  // ── Exclusion logic ──────────────────────────────────────────────────────

  describe("exclusion logic", () => {
    it("excludes members from the game's own group", async () => {
      const db = buildMockDb({
        callerGroups: [
          // same group as the game — should be skipped
          { id: "game-group", data: () => ({ name: "Game Group", memberIds: ["creator-uid", "same-group-member"] }) },
          // other group — should be included
          { id: "other-group", data: () => ({ name: "Other Group", memberIds: ["creator-uid", "alice"] }) },
        ],
        userDocs: [makeUserDoc("alice")],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any);

      expect(result.players.map((p) => p.uid)).toEqual(["alice"]);
      expect(result.players.map((p) => p.uid)).not.toContain("same-group-member");
    });

    it("excludes users already in playerIds", async () => {
      const db = buildMockDb({
        gameData: makeGameData({ playerIds: ["alice"] }),
        userDocs: [makeUserDoc("bob")],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any);

      expect(result.players.map((p) => p.uid)).not.toContain("alice");
    });

    it("excludes users already in guestPlayerIds", async () => {
      const db = buildMockDb({
        gameData: makeGameData({ guestPlayerIds: ["bob"] }),
        userDocs: [makeUserDoc("alice")],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any);

      expect(result.players.map((p) => p.uid)).not.toContain("bob");
    });

    it("excludes users with a pending invitation", async () => {
      const db = buildMockDb({
        pendingInvitees: ["alice"],
        userDocs: [makeUserDoc("bob")],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any);

      expect(result.players.map((p) => p.uid)).not.toContain("alice");
    });

    it("excludes the caller from the results", async () => {
      const db = buildMockDb({
        userDocs: [makeUserDoc("alice")],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any);

      expect(result.players.map((p) => p.uid)).not.toContain("creator-uid");
    });

    it("deduplicates users appearing in multiple groups — includes once with first group", async () => {
      const db = buildMockDb({
        callerGroups: [
          { id: "group-1", data: () => ({ name: "Group One", memberIds: ["creator-uid", "alice"] }) },
          { id: "group-2", data: () => ({ name: "Group Two", memberIds: ["creator-uid", "alice"] }) },
        ],
        userDocs: [makeUserDoc("alice")],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any);

      expect(result.players).toHaveLength(1);
      expect(result.players[0].uid).toBe("alice");
      expect(result.players[0].sourceGroupId).toBe("group-1");
      expect(result.players[0].sourceGroupName).toBe("Group One");
    });
  });

  // ── Happy path ───────────────────────────────────────────────────────────

  describe("success", () => {
    it("returns players with correct fields", async () => {
      const db = buildMockDb({
        callerGroups: [
          { id: "other-group", data: () => ({ name: "Beach Crew", memberIds: ["creator-uid", "alice"] }) },
        ],
        userDocs: [makeUserDoc("alice", "Alice", "https://example.com/alice.jpg")],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any);

      expect(result.players).toHaveLength(1);
      expect(result.players[0]).toMatchObject({
        uid: "alice",
        displayName: "Alice",
        photoUrl: "https://example.com/alice.jpg",
        sourceGroupId: "other-group",
        sourceGroupName: "Beach Crew",
      });
    });

    it("returns empty list when caller belongs to no other groups", async () => {
      const db = buildMockDb({ callerGroups: [] });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any);

      expect(result.players).toEqual([]);
    });

    it("returns empty list when all candidates are excluded", async () => {
      const db = buildMockDb({
        gameData: makeGameData({ playerIds: ["alice"], guestPlayerIds: ["bob"] }),
        userDocs: [],
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await getInvitablePlayersForGameHandler({ gameId: "g1" }, creatorContext as any);

      expect(result.players).toEqual([]);
    });
  });
});

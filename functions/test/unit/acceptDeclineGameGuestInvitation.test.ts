// Unit tests for acceptGameGuestInvitation and declineGameGuestInvitation (Story 28.4)

import * as admin from "firebase-admin";
import { acceptGameGuestInvitationHandler } from "../../src/acceptGameGuestInvitation";
import { declineGameGuestInvitationHandler } from "../../src/declineGameGuestInvitation";

// ── Mock firebase-admin ──────────────────────────────────────────────────────
jest.mock("firebase-admin", () => {
  const actual = jest.requireActual("firebase-admin");
  return {
    ...actual,
    firestore: Object.assign(
      jest.fn(() => ({ collection: jest.fn(), runTransaction: jest.fn() })),
      {
        FieldValue: {
          serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
          arrayUnion: jest.fn((...args: any[]) => ({ _type: "arrayUnion", args })),
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

const inviteeContext = { auth: { uid: "invitee-uid" } };

const makeInvitation = (overrides: Partial<Record<string, any>> = {}) => ({
  gameId: "game-1",
  inviteeId: "invitee-uid",
  inviterId: "creator-uid",
  status: "pending",
  ...overrides,
});

const makeGame = (overrides: Partial<Record<string, any>> = {}) => ({
  groupId: "group-abc",
  createdBy: "creator-uid",
  status: "scheduled",
  maxPlayers: 4,
  playerIds: ["p1", "p2"],
  guestPlayerIds: [],
  ...overrides,
});

/**
 * Build a mock Firestore for the accept handler.
 * Returns the update mocks so assertions can inspect them.
 */
function buildAcceptDb({
  invitationData = makeInvitation(),
  invitationExists = true,
  gameData = makeGame(),
  gameExists = true,
}: {
  invitationData?: ReturnType<typeof makeInvitation>;
  invitationExists?: boolean;
  gameData?: ReturnType<typeof makeGame>;
  gameExists?: boolean;
} = {}): { db: any; gameUpdateMock: jest.Mock; invitationUpdateMock: jest.Mock } {
  const gameUpdateMock = jest.fn();
  const invitationUpdateMock = jest.fn();

  const invitationRef = {
    update: invitationUpdateMock,
  };
  const gameRef = {
    update: gameUpdateMock,
  };

  const db: any = {
    collection: jest.fn((col: string) => {
      if (col === "gameInvitations") {
        return {
          doc: jest.fn(() => ({
            ...invitationRef,
            get: jest.fn().mockResolvedValue({
              exists: invitationExists,
              data: () => invitationData,
            }),
          })),
        };
      }
      if (col === "games") {
        return {
          doc: jest.fn(() => ({
            ...gameRef,
          })),
        };
      }
      return {};
    }),
    runTransaction: jest.fn(async (fn: any) => {
      const tx = {
        get: jest.fn(async (ref: any) => {
          // Distinguish invitation ref vs game ref by checking which mock they're on
          if (ref === db.collection("gameInvitations").doc()) {
            return { exists: invitationExists, data: () => invitationData };
          }
          return { exists: gameExists, data: () => gameData };
        }),
        update: jest.fn(),
      };

      // Supply correct transaction reads by simulating Promise.all order:
      // [invitationRef, gameRef] — index 0 = invitation, index 1 = game
      let callCount = 0;
      tx.get = jest.fn(async (_ref: any) => {
        if (callCount === 0) {
          callCount++;
          return { exists: invitationExists, data: () => invitationData };
        }
        callCount++;
        return { exists: gameExists, data: () => gameData };
      });

      await fn(tx);

      // Expose the tx.update mock for assertions
      gameUpdateMock.mockImplementation(tx.update);
      invitationUpdateMock.mockImplementation(tx.update);
    }),
  };

  return { db, gameUpdateMock, invitationUpdateMock };
}

/**
 * Build a mock Firestore for the decline handler.
 */
function buildDeclineDb({
  invitationData = makeInvitation(),
  invitationExists = true,
}: {
  invitationData?: ReturnType<typeof makeInvitation>;
  invitationExists?: boolean;
} = {}): { db: any; updateMock: jest.Mock } {
  const updateMock = jest.fn().mockResolvedValue(undefined);

  const db: any = {
    collection: jest.fn((col: string) => {
      if (col === "gameInvitations") {
        return {
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue({
              exists: invitationExists,
              data: () => invitationData,
            }),
            update: updateMock,
          })),
        };
      }
      return {};
    }),
  };

  return { db, updateMock };
}

// ═══════════════════════════════════════════════════════════════════════════════
// acceptGameGuestInvitation
// ═══════════════════════════════════════════════════════════════════════════════

describe("acceptGameGuestInvitation", () => {
  beforeEach(() => jest.clearAllMocks());

  // ── Auth + input validation ────────────────────────────────────────────────

  it("throws unauthenticated when no auth context", async () => {
    const { db } = buildAcceptDb();
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-1" }, { auth: null } as any)
    ).rejects.toMatchObject({ code: "unauthenticated" });
  });

  it("throws invalid-argument when invitationId is missing", async () => {
    const { db } = buildAcceptDb();
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "invalid-argument" });
  });

  // ── Invitation validation ──────────────────────────────────────────────────

  it("throws not-found when invitation does not exist", async () => {
    const { db } = buildAcceptDb({ invitationExists: false });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-ghost" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "not-found" });
  });

  it("throws permission-denied when caller is not the invitee", async () => {
    const { db } = buildAcceptDb({
      invitationData: makeInvitation({ inviteeId: "someone-else" }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "permission-denied" });
  });

  it("returns success immediately when already accepted (idempotent)", async () => {
    const { db } = buildAcceptDb({
      invitationData: makeInvitation({ status: "accepted" }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    const result = await acceptGameGuestInvitationHandler(
      { invitationId: "inv-1" },
      inviteeContext as any
    );

    expect(result).toEqual({ success: true });
    // Transaction should NOT have been called
    expect(db.runTransaction).not.toHaveBeenCalled();
  });

  it("throws failed-precondition when invitation is expired", async () => {
    const { db } = buildAcceptDb({
      invitationData: makeInvitation({ status: "expired" }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "failed-precondition" });
  });

  it("throws failed-precondition when invitation is declined", async () => {
    const { db } = buildAcceptDb({
      invitationData: makeInvitation({ status: "declined" }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "failed-precondition" });
  });

  // ── Game validation (inside transaction) ──────────────────────────────────

  it("throws not-found when game no longer exists", async () => {
    const { db } = buildAcceptDb({ gameExists: false });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "not-found" });
  });

  it("throws failed-precondition when game is completed", async () => {
    const { db } = buildAcceptDb({ gameData: makeGame({ status: "completed" }) });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "failed-precondition" });
  });

  it("throws failed-precondition when game is cancelled", async () => {
    const { db } = buildAcceptDb({ gameData: makeGame({ status: "cancelled" }) });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "failed-precondition" });
  });

  it("throws failed-precondition when game is full", async () => {
    const { db } = buildAcceptDb({
      gameData: makeGame({ maxPlayers: 2, playerIds: ["p1", "p2"], guestPlayerIds: [] }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "failed-precondition" });
  });

  it("throws failed-precondition when game is full counting existing guests", async () => {
    const { db } = buildAcceptDb({
      gameData: makeGame({ maxPlayers: 3, playerIds: ["p1", "p2"], guestPlayerIds: ["g1"] }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      acceptGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "failed-precondition" });
  });

  // ── Happy path ─────────────────────────────────────────────────────────────

  it("returns success and runs transaction for a valid pending invitation", async () => {
    const { db } = buildAcceptDb();
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    const result = await acceptGameGuestInvitationHandler(
      { invitationId: "inv-1" },
      inviteeContext as any
    );

    expect(result).toEqual({ success: true });
    expect(db.runTransaction).toHaveBeenCalledTimes(1);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// declineGameGuestInvitation
// ═══════════════════════════════════════════════════════════════════════════════

describe("declineGameGuestInvitation", () => {
  beforeEach(() => jest.clearAllMocks());

  // ── Auth + input validation ────────────────────────────────────────────────

  it("throws unauthenticated when no auth context", async () => {
    const { db } = buildDeclineDb();
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      declineGameGuestInvitationHandler({ invitationId: "inv-1" }, { auth: null } as any)
    ).rejects.toMatchObject({ code: "unauthenticated" });
  });

  it("throws invalid-argument when invitationId is missing", async () => {
    const { db } = buildDeclineDb();
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      declineGameGuestInvitationHandler({ invitationId: "" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "invalid-argument" });
  });

  // ── Invitation validation ──────────────────────────────────────────────────

  it("throws not-found when invitation does not exist", async () => {
    const { db } = buildDeclineDb({ invitationExists: false });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      declineGameGuestInvitationHandler({ invitationId: "inv-ghost" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "not-found" });
  });

  it("throws permission-denied when caller is not the invitee", async () => {
    const { db } = buildDeclineDb({
      invitationData: makeInvitation({ inviteeId: "someone-else" }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      declineGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "permission-denied" });
  });

  it("returns success immediately when already declined (idempotent)", async () => {
    const { db, updateMock } = buildDeclineDb({
      invitationData: makeInvitation({ status: "declined" }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    const result = await declineGameGuestInvitationHandler(
      { invitationId: "inv-1" },
      inviteeContext as any
    );

    expect(result).toEqual({ success: true });
    expect(updateMock).not.toHaveBeenCalled();
  });

  it("throws failed-precondition when invitation is accepted", async () => {
    const { db } = buildDeclineDb({
      invitationData: makeInvitation({ status: "accepted" }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      declineGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "failed-precondition" });
  });

  it("throws failed-precondition when invitation is expired", async () => {
    const { db } = buildDeclineDb({
      invitationData: makeInvitation({ status: "expired" }),
    });
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    await expect(
      declineGameGuestInvitationHandler({ invitationId: "inv-1" }, inviteeContext as any)
    ).rejects.toMatchObject({ code: "failed-precondition" });
  });

  // ── Happy path ─────────────────────────────────────────────────────────────

  it("updates invitation to declined and returns success", async () => {
    const { db, updateMock } = buildDeclineDb();
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    const result = await declineGameGuestInvitationHandler(
      { invitationId: "inv-1" },
      inviteeContext as any
    );

    expect(result).toEqual({ success: true });
    expect(updateMock).toHaveBeenCalledWith(
      expect.objectContaining({ status: "declined" })
    );
  });
});

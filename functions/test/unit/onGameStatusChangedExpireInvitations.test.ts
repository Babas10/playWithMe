// Unit tests for onGameStatusChangedExpireInvitations Firestore trigger (Story 28.5 / fix #722)
// Validates that pending game invitations are expired when a game reaches a terminal status,
// and that invitations accepted between the outer query and the transaction write are not overwritten.

import * as admin from "firebase-admin";
import { onGameStatusChangedExpireInvitationsHandler } from "../../src/onGameStatusChangedExpireInvitations";

// ── Mock firebase-admin ──────────────────────────────────────────────────────

jest.mock("firebase-admin", () => {
  const actual = jest.requireActual("firebase-admin");
  return {
    ...actual,
    firestore: Object.assign(
      jest.fn(() => ({
        collection: jest.fn(),
        runTransaction: jest.fn(),
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
    firestore: {
      document: jest.fn(() => ({
        onUpdate: jest.fn((h: any) => h),
      })),
    },
    logger: {
      info: jest.fn(),
      warn: jest.fn(),
      error: jest.fn(),
    },
    Change: class {},
  };
  fn.region = jest.fn(() => fn);
  return fn;
});

// ── Helpers ──────────────────────────────────────────────────────────────────

/** Build a minimal Firestore change object */
function makeChange(beforeStatus: string | null, afterStatus: string | null) {
  return {
    before: { data: () => (beforeStatus !== null ? { status: beforeStatus } : undefined) },
    after:  { data: () => (afterStatus  !== null ? { status: afterStatus }  : undefined) },
  } as any;
}

/** Build a minimal EventContext with a gameId param */
function makeContext(gameId = "game-1") {
  return { params: { gameId } } as any;
}

/** Build pending invitation docs for the outer query snapshot */
function makePendingDocs(count: number) {
  return Array.from({ length: count }, (_, i) => ({
    id: `inv-${i}`,
    ref: { id: `inv-${i}` },
    data: () => ({ inviteeId: `invitee-${i}`, status: "pending" }),
  }));
}

/**
 * Build a mock Firestore db.
 *
 * @param pendingDocs  - Docs returned by the outer `.where("status","==","pending").get()` query.
 * @param freshOverrides - Map of doc id → fresh snapshot returned by `t.get()` inside the
 *                         transaction. Use this to simulate a doc that was accepted between
 *                         the outer query and the transaction write.
 */
function buildDb(
  pendingDocs: any[] = [],
  freshOverrides: Record<string, { exists: boolean; data: () => any }> = {}
) {
  const mockTransactionUpdate = jest.fn();

  const mockTransaction = {
    get: jest.fn((ref: any) => {
      if (freshOverrides[ref.id]) {
        return Promise.resolve({ ...freshOverrides[ref.id], ref });
      }
      // Default: re-return same doc as outer query (still pending)
      const doc = pendingDocs.find((d) => d.ref.id === ref.id);
      if (doc) {
        return Promise.resolve({ exists: true, data: doc.data, ref: doc.ref });
      }
      return Promise.resolve({ exists: false, data: () => undefined, ref });
    }),
    update: mockTransactionUpdate,
  };

  const mockRunTransaction = jest.fn((callback: (t: any) => Promise<any>) =>
    callback(mockTransaction)
  );

  const mockGameDocUpdate = jest.fn().mockResolvedValue(undefined);

  const db: any = {
    collection: jest.fn((col: string) => {
      if (col === "games") {
        return {
          doc: jest.fn(() => ({ update: mockGameDocUpdate })),
        };
      }
      // gameInvitations collection
      return {
        where: jest.fn().mockReturnThis(),
        get: jest.fn().mockResolvedValue({
          empty: pendingDocs.length === 0,
          docs: pendingDocs,
        }),
      };
    }),
    runTransaction: mockRunTransaction,
  };

  return { db, mockRunTransaction, mockTransactionUpdate, mockGameDocUpdate };
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("onGameStatusChangedExpireInvitations", () => {
  beforeEach(() => jest.clearAllMocks());

  // ── Guard conditions — no writes expected ──────────────────────────────────

  describe("no-op conditions", () => {
    it("does nothing when status did not change", async () => {
      const { db } = buildDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "scheduled"),
        makeContext()
      );

      expect(result).toBeNull();
      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when new status is not terminal (scheduled → in_progress)", async () => {
      const { db } = buildDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "in_progress"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when new status is not terminal (scheduled → verification)", async () => {
      const { db } = buildDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "verification"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when before data is missing", async () => {
      const { db } = buildDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange(null, "completed"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when there are no pending invitations", async () => {
      const { db, mockRunTransaction } = buildDb([]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(result).toBeNull();
      expect(mockRunTransaction).not.toHaveBeenCalled();
    });
  });

  // ── Terminal status triggers ───────────────────────────────────────────────

  describe("terminal status → expires invitations", () => {
    it.each([
      ["completed"],
      ["cancelled"],
      ["aborted"],
    ])("expires pending invitations when status changes to %s", async (terminalStatus) => {
      const docs = makePendingDocs(2);
      const { db, mockRunTransaction, mockTransactionUpdate } = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", terminalStatus),
        makeContext()
      );

      expect(mockRunTransaction).toHaveBeenCalledTimes(1);
      expect(mockTransactionUpdate).toHaveBeenCalledTimes(2);

      for (const doc of docs) {
        expect(mockTransactionUpdate).toHaveBeenCalledWith(
          doc.ref,
          expect.objectContaining({ status: "expired" })
        );
      }
    });

    it("expires invitations when transitioning from in_progress to cancelled", async () => {
      const docs = makePendingDocs(1);
      const { db, mockRunTransaction, mockTransactionUpdate } = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("in_progress", "cancelled"),
        makeContext()
      );

      expect(mockRunTransaction).toHaveBeenCalledTimes(1);
      expect(mockTransactionUpdate).toHaveBeenCalledTimes(1);
    });

    it("clears pendingInviteeIds on the game document after expiring invitations", async () => {
      const docs = makePendingDocs(1);
      const { db, mockGameDocUpdate } = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext("game-42")
      );

      expect(mockGameDocUpdate).toHaveBeenCalledWith(
        expect.objectContaining({ pendingInviteeIds: [] })
      );
    });
  });

  // ── Transaction chunking ──────────────────────────────────────────────────

  describe("transaction chunking", () => {
    it("uses a single transaction for 500 or fewer invitations", async () => {
      const docs = makePendingDocs(500);
      const { db, mockRunTransaction, mockTransactionUpdate } = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(mockRunTransaction).toHaveBeenCalledTimes(1);
      expect(mockTransactionUpdate).toHaveBeenCalledTimes(500);
    });

    it("uses two transactions for 501 invitations", async () => {
      const docs = makePendingDocs(501);
      const { db, mockRunTransaction, mockTransactionUpdate } = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(mockRunTransaction).toHaveBeenCalledTimes(2);
      expect(mockTransactionUpdate).toHaveBeenCalledTimes(501);
    });

    it("uses three transactions for 1001 invitations", async () => {
      const docs = makePendingDocs(1001);
      const { db, mockRunTransaction, mockTransactionUpdate } = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(mockRunTransaction).toHaveBeenCalledTimes(3);
      expect(mockTransactionUpdate).toHaveBeenCalledTimes(1001);
    });
  });

  // ── Race condition guard ──────────────────────────────────────────────────

  describe("race condition: invitation accepted between query and transaction write", () => {
    it("skips an invitation that was accepted after the outer query", async () => {
      const docs = makePendingDocs(2); // inv-0 and inv-1 both pending in outer query

      // Simulate inv-0 being accepted between outer query and transaction read
      const freshOverrides: Record<string, { exists: boolean; data: () => any }> = {
        "inv-0": {
          exists: true,
          data: () => ({ status: "accepted" }),
        },
      };

      const { db, mockRunTransaction, mockTransactionUpdate } = buildDb(docs, freshOverrides);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(mockRunTransaction).toHaveBeenCalledTimes(1);
      // Only inv-1 should be updated — inv-0 was accepted and must be left alone
      expect(mockTransactionUpdate).toHaveBeenCalledTimes(1);
      expect(mockTransactionUpdate).toHaveBeenCalledWith(
        docs[1].ref,
        expect.objectContaining({ status: "expired" })
      );
      expect(mockTransactionUpdate).not.toHaveBeenCalledWith(
        docs[0].ref,
        expect.anything()
      );
    });

    it("skips an invitation that no longer exists in the transaction read", async () => {
      const docs = makePendingDocs(2);

      // Simulate inv-0 being deleted between outer query and transaction read
      const freshOverrides: Record<string, { exists: boolean; data: () => any }> = {
        "inv-0": {
          exists: false,
          data: () => undefined,
        },
      };

      const { db, mockTransactionUpdate } = buildDb(docs, freshOverrides);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      // Only inv-1 should be updated
      expect(mockTransactionUpdate).toHaveBeenCalledTimes(1);
      expect(mockTransactionUpdate).toHaveBeenCalledWith(
        docs[1].ref,
        expect.objectContaining({ status: "expired" })
      );
    });
  });

  // ── Idempotency ───────────────────────────────────────────────────────────

  describe("idempotency", () => {
    it("queries only pending invitations so a second run produces zero writes", async () => {
      // First run — 2 pending docs
      const docs = makePendingDocs(2);
      const { db } = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      jest.clearAllMocks();

      // Second run — no pending docs left (they were expired by first run)
      const { db: emptyDb, mockRunTransaction: secondRunTransaction } = buildDb([]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(emptyDb);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(secondRunTransaction).not.toHaveBeenCalled();
    });
  });
});

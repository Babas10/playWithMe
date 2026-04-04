// Unit tests for onGameStatusChangedExpireInvitations Firestore trigger (Story 28.5)
// Validates that pending game invitations are expired when a game reaches a terminal status.

import * as admin from "firebase-admin";
import { onGameStatusChangedExpireInvitationsHandler } from "../../src/onGameStatusChangedExpireInvitations";

// ── Mock firebase-admin ──────────────────────────────────────────────────────
const mockBatchUpdate = jest.fn();
const mockBatchCommit = jest.fn().mockResolvedValue(undefined);
const mockBatch = { update: mockBatchUpdate, commit: mockBatchCommit };

jest.mock("firebase-admin", () => {
  const actual = jest.requireActual("firebase-admin");
  return {
    ...actual,
    firestore: Object.assign(
      jest.fn(() => ({
        collection: jest.fn(),
        batch: jest.fn(),
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

/** Build pending invitation docs */
function makePendingDocs(count: number) {
  return Array.from({ length: count }, (_, i) => ({
    id: `inv-${i}`,
    ref: { id: `inv-${i}` },
  }));
}

/** Build a mock Firestore db */
function buildDb(pendingDocs: any[] = []) {
  const db: any = {
    collection: jest.fn(() => ({
      where: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue({
        empty: pendingDocs.length === 0,
        docs: pendingDocs,
      }),
    })),
    batch: jest.fn(() => mockBatch),
  };
  return db;
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("onGameStatusChangedExpireInvitations", () => {
  beforeEach(() => jest.clearAllMocks());

  // ── Guard conditions — no writes expected ──────────────────────────────────

  describe("no-op conditions", () => {
    it("does nothing when status did not change", async () => {
      const db = buildDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "scheduled"),
        makeContext()
      );

      expect(result).toBeNull();
      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when new status is not terminal (scheduled → in_progress)", async () => {
      const db = buildDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "in_progress"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when new status is not terminal (scheduled → verification)", async () => {
      const db = buildDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "verification"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when before data is missing", async () => {
      const db = buildDb();
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange(null, "completed"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when there are no pending invitations", async () => {
      const db = buildDb([]); // empty
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(result).toBeNull();
      expect(mockBatchCommit).not.toHaveBeenCalled();
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
      const db = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", terminalStatus),
        makeContext()
      );

      expect(mockBatchUpdate).toHaveBeenCalledTimes(2);
      expect(mockBatchCommit).toHaveBeenCalledTimes(1);

      // Verify each doc was updated to expired
      for (const doc of docs) {
        expect(mockBatchUpdate).toHaveBeenCalledWith(
          doc.ref,
          expect.objectContaining({ status: "expired" })
        );
      }
    });

    it("expires invitations when transitioning from in_progress to cancelled", async () => {
      const docs = makePendingDocs(1);
      const db = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("in_progress", "cancelled"),
        makeContext()
      );

      expect(mockBatchUpdate).toHaveBeenCalledTimes(1);
      expect(mockBatchCommit).toHaveBeenCalledTimes(1);
    });
  });

  // ── Batch chunking ────────────────────────────────────────────────────────

  describe("batch chunking", () => {
    it("uses a single batch for 500 or fewer invitations", async () => {
      const docs = makePendingDocs(500);
      const db = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(mockBatchCommit).toHaveBeenCalledTimes(1);
      expect(mockBatchUpdate).toHaveBeenCalledTimes(500);
    });

    it("uses two batches for 501 invitations", async () => {
      const docs = makePendingDocs(501);
      const db = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(mockBatchCommit).toHaveBeenCalledTimes(2);
      expect(mockBatchUpdate).toHaveBeenCalledTimes(501);
    });

    it("uses three batches for 1001 invitations", async () => {
      const docs = makePendingDocs(1001);
      const db = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(mockBatchCommit).toHaveBeenCalledTimes(3);
      expect(mockBatchUpdate).toHaveBeenCalledTimes(1001);
    });
  });

  // ── Idempotency ───────────────────────────────────────────────────────────

  describe("idempotency", () => {
    it("queries only pending invitations so a second run produces zero writes", async () => {
      // First run — 2 pending docs
      const docs = makePendingDocs(2);
      const db = buildDb(docs);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      jest.clearAllMocks();

      // Second run — no pending docs left (they were expired by first run)
      const emptyDb = buildDb([]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(emptyDb);

      await onGameStatusChangedExpireInvitationsHandler(
        makeChange("scheduled", "completed"),
        makeContext()
      );

      expect(mockBatchCommit).not.toHaveBeenCalled();
    });
  });
});

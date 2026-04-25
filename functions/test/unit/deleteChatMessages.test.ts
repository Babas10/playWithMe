// Unit tests for onGameCompletedDeleteChatMessagesHandler (Story 14.16)
// Validates that chat messages are deleted in batches when a game transitions to completed.

import * as admin from "firebase-admin";
import { onGameCompletedDeleteChatMessagesHandler } from "../../src/deleteChatMessages";

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
  };
  fn.region = jest.fn(() => fn);
  return fn;
});

// ── Mock firebase-admin ──────────────────────────────────────────────────────

jest.mock("firebase-admin", () => {
  const mockFirestore = {
    collection: jest.fn(),
    batch: jest.fn(),
  };
  return {
    firestore: Object.assign(jest.fn(() => mockFirestore), {
      FieldValue: { serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP") },
    }),
    initializeApp: jest.fn(),
  };
});

// ── Helpers ──────────────────────────────────────────────────────────────────

function makeChange(beforeStatus: string | null, afterStatus: string | null) {
  return {
    before: { data: () => (beforeStatus !== null ? { status: beforeStatus } : undefined) },
    after: { data: () => (afterStatus !== null ? { status: afterStatus } : undefined) },
  } as any;
}

function makeContext(gameId = "game-1") {
  return { params: { gameId } } as any;
}

/**
 * Build mock Firestore where messages sub-collection returns a given set of docs
 * across one or more batches.
 *
 * @param docCounts Array of batch sizes to return per .limit().get() call.
 *                  e.g. [500, 3] means first call returns 500 docs, second returns 3.
 */
function buildDb(docCounts: number[]) {
  const mockBatchDelete = jest.fn();
  const mockBatchCommit = jest.fn().mockResolvedValue(undefined);
  const mockBatch = { delete: mockBatchDelete, commit: mockBatchCommit };

  let callIndex = 0;
  const mockGet = jest.fn().mockImplementation(() => {
    const count = docCounts[callIndex] ?? 0;
    callIndex++;
    const docs = Array.from({ length: count }, (_, i) => ({
      ref: { id: `msg-${callIndex}-${i}` },
    }));
    return Promise.resolve({ empty: count === 0, docs });
  });

  const mockLimit = jest.fn(() => ({ get: mockGet }));
  const mockMessagesCollection = { limit: mockLimit };
  const mockGameDoc = { collection: jest.fn(() => mockMessagesCollection) };
  const mockGamesCollection = { doc: jest.fn(() => mockGameDoc) };

  const db: any = {
    collection: jest.fn(() => mockGamesCollection),
    batch: jest.fn(() => mockBatch),
  };

  return { db, mockBatchDelete, mockBatchCommit, mockGet, mockLimit };
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("onGameCompletedDeleteChatMessages", () => {
  beforeEach(() => jest.clearAllMocks());

  // ── Guard conditions ──────────────────────────────────────────────────────

  describe("no-op conditions", () => {
    it("does nothing when status did not change to completed (stays scheduled)", async () => {
      const { db } = buildDb([]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await onGameCompletedDeleteChatMessagesHandler(
        makeChange("scheduled", "scheduled"),
        makeContext()
      );

      expect(result).toBeNull();
      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when status changes to verification (not completed)", async () => {
      const { db } = buildDb([]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameCompletedDeleteChatMessagesHandler(
        makeChange("scheduled", "verification"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when status changes to cancelled", async () => {
      const { db } = buildDb([]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameCompletedDeleteChatMessagesHandler(
        makeChange("in_progress", "cancelled"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when before data is missing", async () => {
      const { db } = buildDb([]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameCompletedDeleteChatMessagesHandler(
        makeChange(null, "completed"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });

    it("does nothing when status was already completed (re-trigger guard)", async () => {
      const { db } = buildDb([]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameCompletedDeleteChatMessagesHandler(
        makeChange("completed", "completed"),
        makeContext()
      );

      expect(db.collection).not.toHaveBeenCalled();
    });
  });

  // ── Empty sub-collection ──────────────────────────────────────────────────

  describe("empty sub-collection", () => {
    it("handles empty messages sub-collection gracefully (no batch commit)", async () => {
      const { db, mockBatchCommit } = buildDb([0]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      const result = await onGameCompletedDeleteChatMessagesHandler(
        makeChange("verification", "completed"),
        makeContext()
      );

      expect(result).toBeNull();
      expect(mockBatchCommit).not.toHaveBeenCalled();
    });
  });

  // ── Single batch deletion ─────────────────────────────────────────────────

  describe("single batch deletion", () => {
    it("deletes all messages in one batch when count < 500", async () => {
      const { db, mockBatchDelete, mockBatchCommit } = buildDb([3, 0]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameCompletedDeleteChatMessagesHandler(
        makeChange("verification", "completed"),
        makeContext("game-42")
      );

      expect(mockBatchDelete).toHaveBeenCalledTimes(3);
      expect(mockBatchCommit).toHaveBeenCalledTimes(1);
    });

    it("deletes exactly 500 messages in one batch", async () => {
      const { db, mockBatchDelete, mockBatchCommit } = buildDb([500, 0]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameCompletedDeleteChatMessagesHandler(
        makeChange("in_progress", "completed"),
        makeContext()
      );

      expect(mockBatchDelete).toHaveBeenCalledTimes(500);
      expect(mockBatchCommit).toHaveBeenCalledTimes(1);
    });
  });

  // ── Multi-batch deletion ──────────────────────────────────────────────────

  describe("multi-batch deletion", () => {
    it("uses two batches for 503 messages (500 + 3)", async () => {
      const { db, mockBatchDelete, mockBatchCommit } = buildDb([500, 3, 0]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameCompletedDeleteChatMessagesHandler(
        makeChange("verification", "completed"),
        makeContext()
      );

      expect(mockBatchDelete).toHaveBeenCalledTimes(503);
      expect(mockBatchCommit).toHaveBeenCalledTimes(2);
    });

    it("uses three batches for 1200 messages (500 + 500 + 200)", async () => {
      const { db, mockBatchDelete, mockBatchCommit } = buildDb([500, 500, 200, 0]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameCompletedDeleteChatMessagesHandler(
        makeChange("verification", "completed"),
        makeContext()
      );

      expect(mockBatchDelete).toHaveBeenCalledTimes(1200);
      expect(mockBatchCommit).toHaveBeenCalledTimes(3);
    });
  });

  // ── Correct collection path ───────────────────────────────────────────────

  describe("Firestore path", () => {
    it("queries games/{gameId}/messages sub-collection", async () => {
      const { db, mockBatchDelete } = buildDb([2, 0]);
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await onGameCompletedDeleteChatMessagesHandler(
        makeChange("verification", "completed"),
        makeContext("game-99")
      );

      expect(db.collection).toHaveBeenCalledWith("games");
      const mockGamesCollection = db.collection.mock.results[0].value;
      expect(mockGamesCollection.doc).toHaveBeenCalledWith("game-99");
      const mockGameDoc = mockGamesCollection.doc.mock.results[0].value;
      expect(mockGameDoc.collection).toHaveBeenCalledWith("messages");
      expect(mockBatchDelete).toHaveBeenCalledTimes(2);
    });
  });
});

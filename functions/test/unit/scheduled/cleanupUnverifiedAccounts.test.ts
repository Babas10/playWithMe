// Unit tests for cleanupUnverifiedAccounts scheduled Cloud Function.
// Story 17.8.4: Scheduled Cloud Functions for Account Cleanup (#481)

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

// Mock Firebase Admin
jest.mock("firebase-admin", () => {
  const firestoreFn = jest.fn();
  (firestoreFn as any).FieldValue = {
    serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
    arrayRemove: jest.fn((...elements: unknown[]) => ({
      _methodName: "FieldValue.arrayRemove",
      _elements: elements,
    })),
  };
  (firestoreFn as any).Timestamp = {
    now: jest.fn(() => ({
      toDate: () => new Date("2026-02-14T03:00:00Z"),
      toMillis: () => new Date("2026-02-14T03:00:00Z").getTime(),
    })),
    fromDate: jest.fn((date: Date) => ({
      toDate: () => date,
    })),
  };
  return {
    firestore: firestoreFn,
    auth: jest.fn(),
    initializeApp: jest.fn(),
  };
});

// Mock firebase-functions
jest.mock("firebase-functions", () => ({
  pubsub: {
    schedule: jest.fn(() => ({
      onRun: jest.fn((handler: Function) => handler),
    })),
  },
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
    debug: jest.fn(),
  },
}));

// Import handler after mocks are set up
import {cleanupUnverifiedAccounts} from
  "../../../src/scheduled/cleanupUnverifiedAccounts";

const handler = cleanupUnverifiedAccounts as unknown as () =>
  Promise<null>;

describe("cleanupUnverifiedAccounts", () => {
  let mockDb: any;
  let mockBatch: any;
  let mockAuth: any;

  const emptySnapshot = {empty: true, size: 0, docs: []};

  beforeEach(() => {
    jest.clearAllMocks();

    mockBatch = {
      update: jest.fn(),
      delete: jest.fn(),
      commit: jest.fn().mockResolvedValue(undefined),
    };

    mockDb = {
      collection: jest.fn(),
      batch: jest.fn(() => mockBatch),
    };

    mockAuth = {
      deleteUser: jest.fn().mockResolvedValue(undefined),
    };

    (admin.firestore as unknown as jest.Mock)
      .mockReturnValue(mockDb);
    (admin.auth as unknown as jest.Mock)
      .mockReturnValue(mockAuth);
  });

  it("should skip when no accounts to delete", async () => {
    const mockQuery = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue(emptySnapshot),
    };
    mockDb.collection.mockReturnValue(mockQuery);

    await handler();

    expect(mockDb.collection).toHaveBeenCalledWith("users");
    expect(mockQuery.where).toHaveBeenCalledWith(
      "accountStatus", "==", "scheduledForDeletion"
    );
    expect(mockBatch.commit).not.toHaveBeenCalled();
  });

  it("should query with correct filters", async () => {
    const mockQuery = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue(emptySnapshot),
    };
    mockDb.collection.mockReturnValue(mockQuery);

    await handler();

    expect(mockQuery.where).toHaveBeenCalledWith(
      "accountStatus", "==", "scheduledForDeletion"
    );
    expect(mockQuery.where).toHaveBeenCalledWith(
      "deletionScheduledAt", "<", expect.anything()
    );
    expect(mockQuery.limit).toHaveBeenCalledWith(500);
  });

  it("should process accounts in dry-run mode " +
    "(default)", async () => {
    const createdAt = new Date("2026-01-01T00:00:00Z");
    const deletionDate = new Date("2026-01-31T00:00:00Z");
    const mockUserDoc = {
      id: "user-1",
      ref: {id: "user-1"},
      data: () => ({
        email: "test@example.com",
        accountStatus: "scheduledForDeletion",
        createdAt: {toDate: () => createdAt},
        deletionScheduledAt: {toDate: () => deletionDate},
      }),
    };

    const mockUsersQuery = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue({
        empty: false,
        size: 1,
        docs: [mockUserDoc],
      }),
    };

    mockDb.collection.mockReturnValue(mockUsersQuery);

    await handler();

    // In dry-run mode, no batch operations should occur
    expect(mockBatch.commit).not.toHaveBeenCalled();
    expect(mockAuth.deleteUser).not.toHaveBeenCalled();
  });

  it("should log structured info for each account processed",
    async () => {
      const createdAt = new Date("2026-01-01T00:00:00Z");
      const deletionDate = new Date("2026-01-31T00:00:00Z");
      const mockUserDoc = {
        id: "user-1",
        ref: {id: "user-1"},
        data: () => ({
          email: "test@example.com",
          accountStatus: "scheduledForDeletion",
          createdAt: {toDate: () => createdAt},
          deletionScheduledAt: {toDate: () => deletionDate},
        }),
      };

      const mockUsersQuery = {
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        get: jest.fn().mockResolvedValue({
          empty: false,
          size: 1,
          docs: [mockUserDoc],
        }),
      };

      mockDb.collection.mockReturnValue(mockUsersQuery);

      await handler();

      // Should log processing info
      expect(functions.logger.info).toHaveBeenCalledWith(
        "[cleanupUnverifiedAccounts] Processing account",
        expect.objectContaining({
          uid: "user-1",
          email: "test@example.com",
          dryRun: true,
        })
      );

      // Should log dry-run info
      expect(functions.logger.info).toHaveBeenCalledWith(
        expect.stringContaining("[DRY-RUN]"),
        expect.objectContaining({uid: "user-1"})
      );
    }
  );

  it("should continue processing on per-user errors",
    async () => {
      const createdAt = new Date("2026-01-01T00:00:00Z");
      const deletionDate = new Date("2026-01-31T00:00:00Z");

      // Create a user doc whose data() throws
      const badUserDoc = {
        id: "bad-user",
        ref: {id: "bad-user"},
        data: () => {
          throw new Error("Corrupt data");
        },
      };
      const goodUserDoc = {
        id: "good-user",
        ref: {id: "good-user"},
        data: () => ({
          email: "good@example.com",
          accountStatus: "scheduledForDeletion",
          createdAt: {toDate: () => createdAt},
          deletionScheduledAt: {toDate: () => deletionDate},
        }),
      };

      const mockUsersQuery = {
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        get: jest.fn().mockResolvedValue({
          empty: false,
          size: 2,
          docs: [badUserDoc, goodUserDoc],
        }),
      };

      mockDb.collection.mockReturnValue(mockUsersQuery);

      // Should not throw
      await handler();

      // Should log error for bad user
      expect(functions.logger.error).toHaveBeenCalledWith(
        expect.stringContaining("Failed to delete account"),
        expect.objectContaining({uid: "bad-user"})
      );
      // Should log completion
      expect(functions.logger.info).toHaveBeenCalledWith(
        "[cleanupUnverifiedAccounts] Completed",
        expect.objectContaining({
          processed: 2,
          errors: 1,
        })
      );
    }
  );

  it("should throw on top-level Firestore errors", async () => {
    const mockQuery = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockRejectedValue(
        new Error("Firestore unavailable")
      ),
    };
    mockDb.collection.mockReturnValue(mockQuery);

    await expect(handler()).rejects.toThrow(
      "Firestore unavailable"
    );
  });

  it("should report completion stats", async () => {
    const mockUsersQuery = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue(emptySnapshot),
    };
    mockDb.collection.mockReturnValue(mockUsersQuery);

    await handler();

    expect(functions.logger.info).toHaveBeenCalledWith(
      "[cleanupUnverifiedAccounts] No accounts to delete"
    );
  });
});

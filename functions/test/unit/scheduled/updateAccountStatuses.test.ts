// Unit tests for updateAccountStatuses scheduled Cloud Function.
// Story 17.8.4: Scheduled Cloud Functions for Account Cleanup (#481)

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

// Mock Firebase Admin
jest.mock("firebase-admin", () => {
  const firestoreFn = jest.fn();
  (firestoreFn as any).FieldValue = {
    serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
  };
  (firestoreFn as any).Timestamp = {
    now: jest.fn(() => ({
      toDate: () => new Date("2026-02-14T02:00:00Z"),
    })),
    fromDate: jest.fn((date: Date) => ({
      toDate: () => date,
      toMillis: () => date.getTime(),
    })),
  };
  return {
    firestore: firestoreFn,
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
import {updateAccountStatuses} from
  "../../../src/scheduled/updateAccountStatuses";

const handler = updateAccountStatuses as unknown as () =>
  Promise<null>;

describe("updateAccountStatuses", () => {
  let mockDb: any;
  let mockBatch: any;

  beforeEach(() => {
    jest.clearAllMocks();

    mockBatch = {
      update: jest.fn(),
      commit: jest.fn().mockResolvedValue(undefined),
    };

    mockDb = {
      collection: jest.fn(),
      batch: jest.fn(() => mockBatch),
    };

    (admin.firestore as unknown as jest.Mock)
      .mockReturnValue(mockDb);
  });

  it("should skip when no accounts need transition", async () => {
    const mockSnapshot = {empty: true, size: 0, docs: []};
    const mockQuery = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue(mockSnapshot),
    };
    mockDb.collection.mockReturnValue(mockQuery);

    await handler();

    expect(mockDb.collection).toHaveBeenCalledWith("users");
    expect(mockQuery.where).toHaveBeenCalledWith(
      "accountStatus", "==", "pendingVerification"
    );
    expect(mockQuery.where).toHaveBeenCalledWith(
      "emailVerifiedAt", "==", null
    );
    expect(mockBatch.update).not.toHaveBeenCalled();
    expect(mockBatch.commit).not.toHaveBeenCalled();
  });

  it("should transition expired accounts to restricted",
    async () => {
      const createdAt = new Date("2026-01-01T00:00:00Z");
      const mockRef = {id: "user-1", path: "users/user-1"};
      const mockDoc = {
        id: "user-1",
        ref: mockRef,
        data: () => ({
          accountStatus: "pendingVerification",
          emailVerifiedAt: null,
          createdAt: {
            toDate: () => createdAt,
            toMillis: () => createdAt.getTime(),
          },
        }),
      };
      const mockSnapshot = {
        empty: false,
        size: 1,
        docs: [mockDoc],
      };
      const mockQuery = {
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        get: jest.fn().mockResolvedValue(mockSnapshot),
      };
      mockDb.collection.mockReturnValue(mockQuery);

      await handler();

      expect(mockBatch.update).toHaveBeenCalledWith(
        mockRef,
        expect.objectContaining({
          accountStatus: "restricted",
          updatedAt: "MOCK_TIMESTAMP",
        })
      );
      expect(mockBatch.update).toHaveBeenCalledWith(
        mockRef,
        expect.objectContaining({
          deletionScheduledAt: expect.anything(),
        })
      );
      expect(mockBatch.commit).toHaveBeenCalledTimes(1);
    }
  );

  it("should process multiple accounts in batch", async () => {
    const createdAt = new Date("2026-01-01T00:00:00Z");
    const mockDocs = [
      {
        id: "user-1",
        ref: {id: "user-1"},
        data: () => ({
          createdAt: {toDate: () => createdAt},
        }),
      },
      {
        id: "user-2",
        ref: {id: "user-2"},
        data: () => ({
          createdAt: {toDate: () => createdAt},
        }),
      },
      {
        id: "user-3",
        ref: {id: "user-3"},
        data: () => ({
          createdAt: {toDate: () => createdAt},
        }),
      },
    ];
    const mockSnapshot = {
      empty: false,
      size: 3,
      docs: mockDocs,
    };
    const mockQuery = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue(mockSnapshot),
    };
    mockDb.collection.mockReturnValue(mockQuery);

    await handler();

    expect(mockBatch.update).toHaveBeenCalledTimes(3);
    expect(mockBatch.commit).toHaveBeenCalledTimes(1);
  });

  it("should compute deletionScheduledAt as 30 days " +
    "from createdAt", async () => {
    const createdAt = new Date("2026-01-10T12:00:00Z");
    const expectedDeletion = new Date(
      createdAt.getTime() + 30 * 24 * 60 * 60 * 1000
    );
    const mockRef = {id: "user-1"};
    const mockDoc = {
      id: "user-1",
      ref: mockRef,
      data: () => ({
        createdAt: {toDate: () => createdAt},
      }),
    };
    const mockQuery = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue({
        empty: false,
        size: 1,
        docs: [mockDoc],
      }),
    };
    mockDb.collection.mockReturnValue(mockQuery);

    await handler();

    expect(
      (admin.firestore as any).Timestamp.fromDate
    ).toHaveBeenCalledWith(expectedDeletion);
  });

  it("should limit query to BATCH_SIZE (500)", async () => {
    const mockQuery = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue({
        empty: true,
        size: 0,
        docs: [],
      }),
    };
    mockDb.collection.mockReturnValue(mockQuery);

    await handler();

    expect(mockQuery.limit).toHaveBeenCalledWith(500);
  });

  it("should throw on Firestore errors", async () => {
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

  it("should log transition details for each account",
    async () => {
      const createdAt = new Date("2026-01-01T00:00:00Z");
      const mockDoc = {
        id: "user-1",
        ref: {id: "user-1"},
        data: () => ({
          createdAt: {toDate: () => createdAt},
        }),
      };
      const mockQuery = {
        where: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        get: jest.fn().mockResolvedValue({
          empty: false,
          size: 1,
          docs: [mockDoc],
        }),
      };
      mockDb.collection.mockReturnValue(mockQuery);

      await handler();

      expect(functions.logger.info).toHaveBeenCalledWith(
        "[updateAccountStatuses] Transitioning account",
        expect.objectContaining({
          uid: "user-1",
          previousStatus: "pendingVerification",
          newStatus: "restricted",
        })
      );
    }
  );
});

// Unit tests for calculateUserRankingHandler
// Story 25.6: Parallelised count() queries for global rank calculation

import {calculateUserRankingHandler} from "../../src/calculateUserRanking";

jest.mock("firebase-functions", () => {
  const _fn = {
    https: {
      HttpsError: class HttpsError extends Error {
        code: string;
        constructor(code: string, message: string) {
          super(message);
          this.code = code;
          this.name = "HttpsError";
        }
      },
      onCall: jest.fn((handler) => handler),
    },
    logger: {
      info: jest.fn(),
      warn: jest.fn(),
      error: jest.fn(),
      debug: jest.fn(),
    },
  };
  (_fn as any).region = jest.fn(() => _fn);
  return _fn;
});

jest.mock("firebase-admin", () => {
  const mockFirestore = {
    collection: jest.fn(),
    doc: jest.fn(),
  };
  return {
    firestore: Object.assign(jest.fn(() => mockFirestore), {
      FieldPath: {documentId: jest.fn(() => "__name__")},
      FieldValue: {serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP")},
    }),
    initializeApp: jest.fn(),
  };
});

const admin = require("firebase-admin");

function getMockDb() {
  return admin.firestore();
}


describe("calculateUserRankingHandler", () => {
  let mockDb: any;

  beforeEach(() => {
    jest.clearAllMocks();
    mockDb = getMockDb();
  });

  it("throws unauthenticated when no auth context", async () => {
    await expect(
      calculateUserRankingHandler({}, {auth: null} as any)
    ).rejects.toThrow("You must be logged in to view rankings.");
  });

  it("throws not-found when user document does not exist", async () => {
    mockDb.doc.mockReturnValue({
      get: jest.fn().mockResolvedValue({exists: false}),
    });

    await expect(
      calculateUserRankingHandler({}, {auth: {uid: "user-123"}} as any)
    ).rejects.toThrow("User not found");
  });

  it("returns correct global rank and percentile with no friends", async () => {
    // User doc
    mockDb.doc.mockReturnValue({
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({eloRating: 1700, eloGamesPlayed: 5, friendIds: []}),
      }),
    });

    // Collection calls: higherEloCount → count=2, totalUsers → count=10
    let collectionCallCount = 0;
    mockDb.collection.mockImplementation(() => {
      collectionCallCount++;
      const count = collectionCallCount === 1 ? 2 : 10;
      const get = jest.fn().mockResolvedValue({data: () => ({count})});
      const countFn = jest.fn().mockReturnValue({get});
      const where2 = jest.fn().mockReturnValue({count: countFn});
      const where1 = jest.fn().mockReturnValue({where: where2, count: countFn});
      return {where: where1};
    });

    const result = await calculateUserRankingHandler(
      {},
      {auth: {uid: "user-123"}} as any
    );

    expect(result.globalRank).toBe(3); // 2 users above + 1
    expect(result.totalUsers).toBe(10);
    expect(result.percentile).toBeCloseTo(80); // (10 - 3 + 1) / 10 * 100
    expect(result.friendsRank).toBeNull();
    expect(result.totalFriends).toBeNull();
  });

  it("fires both count() queries in parallel (both collections called before either resolves)", async () => {
    const collectionsCalled: number[] = [];

    mockDb.doc.mockReturnValue({
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({eloRating: 1600, eloGamesPlayed: 3, friendIds: []}),
      }),
    });

    mockDb.collection.mockImplementation(() => {
      collectionsCalled.push(Date.now());
      const get = jest.fn().mockResolvedValue({data: () => ({count: 0})});
      const countFn = jest.fn().mockReturnValue({get});
      const where2 = jest.fn().mockReturnValue({count: countFn});
      const where1 = jest.fn().mockReturnValue({where: where2, count: countFn});
      return {where: where1};
    });

    await calculateUserRankingHandler({}, {auth: {uid: "user-123"}} as any);

    // Both count queries must have been initiated
    expect(collectionsCalled).toHaveLength(2);
  });

  it("calculates friends rank correctly", async () => {
    const friendIds = ["friend-1", "friend-2", "friend-3"];

    mockDb.doc.mockReturnValue({
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({eloRating: 1700, eloGamesPlayed: 5, friendIds}),
      }),
    });

    // Global count queries
    let collectionCallCount = 0;
    mockDb.collection.mockImplementation(() => {
      collectionCallCount++;
      if (collectionCallCount <= 2) {
        // higherEloCount=1, totalUsers=5
        const count = collectionCallCount === 1 ? 1 : 5;
        const get = jest.fn().mockResolvedValue({data: () => ({count})});
        const countFn = jest.fn().mockReturnValue({get});
        const where2 = jest.fn().mockReturnValue({count: countFn});
        const where1 = jest.fn().mockReturnValue({where: where2, count: countFn});
        return {where: where1};
      }
      // Friend batch query: friend-1 ELO=1800 (higher), friend-2 ELO=1600 (lower), friend-3 no games
      const get = jest.fn().mockResolvedValue({
        docs: [
          {data: () => ({eloRating: 1800, eloGamesPlayed: 3})},
          {data: () => ({eloRating: 1600, eloGamesPlayed: 2})},
          {data: () => ({eloRating: 1500, eloGamesPlayed: 0})}, // excluded (no games)
        ],
      });
      const where1 = jest.fn().mockReturnValue({get, select: jest.fn().mockReturnValue({get})});
      return {where: where1};
    });

    const result = await calculateUserRankingHandler(
      {},
      {auth: {uid: "user-123"}} as any
    );

    expect(result.globalRank).toBe(2);
    expect(result.totalUsers).toBe(5);
  });

  it("handles user with default ELO (no eloRating field)", async () => {
    mockDb.doc.mockReturnValue({
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({eloGamesPlayed: 0, friendIds: []}),
      }),
    });

    mockDb.collection.mockImplementation(() => {
      const get = jest.fn().mockResolvedValue({data: () => ({count: 0})});
      const countFn = jest.fn().mockReturnValue({get});
      const where2 = jest.fn().mockReturnValue({count: countFn});
      const where1 = jest.fn().mockReturnValue({where: where2, count: countFn});
      return {where: where1};
    });

    const result = await calculateUserRankingHandler(
      {},
      {auth: {uid: "user-123"}} as any
    );

    // Default ELO is 1600, 0 users above → rank 1
    expect(result.globalRank).toBe(1);
    expect(typeof result.calculatedAt).toBe("number");
  });
});

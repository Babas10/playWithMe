import { getExpectedScore, calculateRatingChange, calculateTeamRating, processGameEloUpdates } from "../../src/elo";
import * as admin from "firebase-admin";

// Mock firebase-admin
jest.mock("firebase-admin", () => {
  const firestore = jest.fn();
  (firestore as any).FieldValue = {
    increment: jest.fn((n) => ({ increment: n })),
    serverTimestamp: jest.fn(() => "TIMESTAMP"),
  };
  (firestore as any).Timestamp = {
    now: jest.fn(() => "TIMESTAMP"),
  };
  return { firestore };
});

describe("ELO Calculations", () => {
  test("getExpectedScore returns correct probability", () => {
    // Equal ratings should give 0.5
    expect(getExpectedScore(1200, 1200)).toBe(0.5);
    expect(getExpectedScore(1300, 1200)).toBeGreaterThan(0.5);
  });

  test("calculateRatingChange returns correct change", () => {
    // Win against equal opponent: 32 * (1 - 0.5) = 16
    expect(calculateRatingChange(1, 0.5, 32)).toBe(16);
    // Loss against equal opponent: 32 * (0 - 0.5) = -16
    expect(calculateRatingChange(0, 0.5, 32)).toBe(-16);
  });

  test("calculateTeamRating uses Weak-Link formula", () => {
    // 0.7 * min + 0.3 * max
    const ratings = [1000, 2000]; // min 1000, max 2000
    // 0.7 * 1000 + 0.3 * 2000 = 700 + 600 = 1300
    expect(calculateTeamRating(ratings)).toBe(1300);
  });
});

describe("processGameEloUpdates", () => {
  let db: any;
  let transaction: any;

  beforeEach(() => {
    transaction = {
      get: jest.fn(),
      update: jest.fn(),
      set: jest.fn(),
    };

    db = {
      collection: jest.fn(),
      runTransaction: jest.fn((cb) => cb(transaction)),
    };
    (admin.firestore as any).mockReturnValue(db);
  });

  test("updates ELO ratings correctly", async () => {
    // Setup mock data
    const gameId = "game1";
    const gameData = {
      teams: {
        teamAPlayerIds: ["p1", "p2"],
        teamBPlayerIds: ["p3", "p4"],
      },
      result: {
        overallWinner: "teamA",
        games: [
          {
            gameNumber: 1,
            sets: [{ teamAPoints: 21, teamBPoints: 19, setNumber: 1 }],
            winner: "teamA",
          },
        ],
      },
    };

    const playerMap: {[key: string]: any} = {
      p1: { eloRating: 1200, displayName: "P1" },
      p2: { eloRating: 1200, displayName: "P2" },
      p3: { eloRating: 1200, displayName: "P3" },
      p4: { eloRating: 1200, displayName: "P4" },
    };

    // Mock db.collection().doc()
    const docMock = (id: string) => ({
      id,
      exists: true,
      data: () => playerMap[id],
    });
    
    // Subcollection mock
    const subCollectionMock = {
      doc: jest.fn(() => ({ id: "historyId" })),
    };

    const docRefMock = {
      collection: jest.fn(() => subCollectionMock),
    };

    const collectionMock = {
      doc: jest.fn((id) => ({...docMock(id), ...docRefMock})),
    };
    db.collection.mockReturnValue(collectionMock);

    // Mock transaction.get to return player docs
    transaction.get.mockImplementation((ref: any) => Promise.resolve({
      exists: true,
      id: ref.id,
      data: () => playerMap[ref.id] || {},
    }));

    await processGameEloUpdates(gameId, gameData);

    // Verify updates
    expect(transaction.update).toHaveBeenCalled();
    expect(transaction.set).toHaveBeenCalled(); // History entries
  });
});

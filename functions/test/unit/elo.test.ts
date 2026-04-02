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

    // Mock default game document (for defensive check in Story 15.5)
    // Individual tests can override this if needed
    const defaultGameRef = {
      parent: { id: "games" },
    };
    const defaultGameDoc = {
      exists: true,
      ref: defaultGameRef,
      data: () => ({}),
    };

    // Setup default collection mock that includes game document retrieval
    db.collection.mockImplementation((collectionName: string) => ({
      doc: jest.fn((id: string) => ({
        id,
        get: jest.fn().mockResolvedValue(defaultGameDoc),
      })),
    }));
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

    // Mock game document for defensive check
    const gameRef = { parent: { id: "games" } };
    const gameDocMock = {
      exists: true,
      id: gameId,
      ref: gameRef,
      data: () => gameData,
    };

    const collectionMock = {
      doc: jest.fn((id) => {
        if (id === gameId) {
          return {
            ...docRefMock,
            get: jest.fn().mockResolvedValue(gameDocMock),
          };
        }
        return {...docMock(id), ...docRefMock};
      }),
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

  test("sets bestWin after first victory with opponent names", async () => {
    const gameId = "game1";
    const gameData = {
      teams: {
        teamAPlayerIds: ["p1"],
        teamBPlayerIds: ["p2"],
      },
      result: {
        games: [{ winner: "teamA" }],
      },
    };

    const playerMap: {[key: string]: any} = {
      p1: { eloRating: 1200, displayName: "P1" }, // Winner, no bestWin yet
      p2: { eloRating: 1300, displayName: "P2" }, // Loser with higher rating
    };

    const docMock = (id: string) => ({
      id,
      exists: true,
      data: () => playerMap[id],
    });

    const subCollectionMock = {
      doc: jest.fn(() => ({ id: "historyId" })),
    };

    const docRefMock = {
      collection: jest.fn(() => subCollectionMock),
    };

    // Mock game document for defensive check
    const gameRef = { parent: { id: "games" } };
    const gameDocMock = {
      exists: true,
      id: gameId,
      ref: gameRef,
      data: () => gameData,
    };

    const collectionMock = {
      doc: jest.fn((id) => {
        if (id === gameId) {
          return {
            ...docRefMock,
            get: jest.fn().mockResolvedValue(gameDocMock),
          };
        }
        return {...docMock(id), ...docRefMock};
      }),
    };
    db.collection.mockReturnValue(collectionMock);

    transaction.get.mockImplementation((ref: any) => Promise.resolve({
      exists: true,
      id: ref.id,
      data: () => playerMap[ref.id] || {},
    }));

    await processGameEloUpdates(gameId, gameData);

    // Check that transaction.update was called for p1 with bestWin
    const p1UpdateCall = transaction.update.mock.calls.find(
      (call: any) => call[0]?.id === "p1"
    );
    expect(p1UpdateCall).toBeDefined();
    expect(p1UpdateCall[1]).toHaveProperty("bestWin");
    expect(p1UpdateCall[1].bestWin).toMatchObject({
      gameId: "game1",
      opponentTeamElo: 1300,
      opponentTeamAvgElo: 1300,
      opponentNames: "P2", // Should include opponent name
    });
  });

  test("updates bestWin when beating higher-rated team with opponent names", async () => {
    const gameId = "game2";
    const gameData = {
      teams: {
        teamAPlayerIds: ["p1"],
        teamBPlayerIds: ["p2"],
      },
      result: {
        games: [{ winner: "teamA" }],
      },
    };

    const playerMap: {[key: string]: any} = {
      p1: {
        eloRating: 1200,
        displayName: "P1",
        bestWin: { opponentTeamElo: 1250 }, // Previous best
      },
      p2: { eloRating: 1400, displayName: "P2" }, // Higher rated opponent
    };

    const docMock = (id: string) => ({
      id,
      exists: true,
      data: () => playerMap[id],
    });

    const subCollectionMock = {
      doc: jest.fn(() => ({ id: "historyId" })),
    };

    const docRefMock = {
      collection: jest.fn(() => subCollectionMock),
    };

    // Mock game document for defensive check
    const gameRef = { parent: { id: "games" } };
    const gameDocMock = {
      exists: true,
      id: gameId,
      ref: gameRef,
      data: () => gameData,
    };

    const collectionMock = {
      doc: jest.fn((id) => {
        if (id === gameId) {
          return {
            ...docRefMock,
            get: jest.fn().mockResolvedValue(gameDocMock),
          };
        }
        return {...docMock(id), ...docRefMock};
      }),
    };
    db.collection.mockReturnValue(collectionMock);

    transaction.get.mockImplementation((ref: any) => Promise.resolve({
      exists: true,
      id: ref.id,
      data: () => playerMap[ref.id] || {},
    }));

    await processGameEloUpdates(gameId, gameData);

    const p1UpdateCall = transaction.update.mock.calls.find(
      (call: any) => call[0]?.id === "p1"
    );
    expect(p1UpdateCall[1]).toHaveProperty("bestWin");
    expect(p1UpdateCall[1].bestWin.opponentTeamElo).toBe(1400);
    expect(p1UpdateCall[1].bestWin.opponentNames).toBe("P2"); // Should include opponent name
  });

  test("does NOT update bestWin when beating lower-rated team", async () => {
    const gameId = "game3";
    const gameData = {
      teams: {
        teamAPlayerIds: ["p1"],
        teamBPlayerIds: ["p2"],
      },
      result: {
        games: [{ winner: "teamA" }],
      },
    };

    const playerMap: {[key: string]: any} = {
      p1: {
        eloRating: 1400,
        displayName: "P1",
        bestWin: { opponentTeamElo: 1500 }, // Previous best is higher
      },
      p2: { eloRating: 1200, displayName: "P2" }, // Lower rated opponent
    };

    const docMock = (id: string) => ({
      id,
      exists: true,
      data: () => playerMap[id],
    });

    const subCollectionMock = {
      doc: jest.fn(() => ({ id: "historyId" })),
    };

    const docRefMock = {
      collection: jest.fn(() => subCollectionMock),
    };

    // Mock game document for defensive check
    const gameRef = { parent: { id: "games" } };
    const gameDocMock = {
      exists: true,
      id: gameId,
      ref: gameRef,
      data: () => gameData,
    };

    const collectionMock = {
      doc: jest.fn((id) => {
        if (id === gameId) {
          return {
            ...docRefMock,
            get: jest.fn().mockResolvedValue(gameDocMock),
          };
        }
        return {...docMock(id), ...docRefMock};
      }),
    };
    db.collection.mockReturnValue(collectionMock);

    transaction.get.mockImplementation((ref: any) => Promise.resolve({
      exists: true,
      id: ref.id,
      data: () => playerMap[ref.id] || {},
    }));

    await processGameEloUpdates(gameId, gameData);

    const p1UpdateCall = transaction.update.mock.calls.find(
      (call: any) => call[0]?.id === "p1"
    );
    // bestWin should not be in the update (should be undefined, not included)
    expect(p1UpdateCall[1].bestWin).toBeUndefined();
  });

  test("sets bestWin with multiple opponent names joined by ' & '", async () => {
    const gameId = "game-2v2";
    const gameData = {
      teams: {
        teamAPlayerIds: ["p1", "p2"],
        teamBPlayerIds: ["p3", "p4"],
      },
      result: {
        games: [{ winner: "teamA" }],
      },
    };

    const playerMap: {[key: string]: any} = {
      p1: { eloRating: 1200, displayName: "Alice" },
      p2: { eloRating: 1250, displayName: "Bob" },
      p3: { eloRating: 1500, displayName: "Charlie" }, // Higher rated opponents
      p4: { eloRating: 1550, displayName: "Diana" },
    };

    const docMock = (id: string) => ({
      id,
      exists: true,
      data: () => playerMap[id],
    });

    const subCollectionMock = {
      doc: jest.fn(() => ({ id: "historyId" })),
    };

    const docRefMock = {
      collection: jest.fn(() => subCollectionMock),
    };

    // Mock game document for defensive check
    const gameRef = { parent: { id: "games" } };
    const gameDocMock = {
      exists: true,
      id: gameId,
      ref: gameRef,
      data: () => gameData,
    };

    const collectionMock = {
      doc: jest.fn((id) => {
        if (id === gameId) {
          return {
            ...docRefMock,
            get: jest.fn().mockResolvedValue(gameDocMock),
          };
        }
        return {...docMock(id), ...docRefMock};
      }),
    };
    db.collection.mockReturnValue(collectionMock);

    transaction.get.mockImplementation((ref: any) => Promise.resolve({
      exists: true,
      id: ref.id,
      data: () => playerMap[ref.id] || {},
    }));

    await processGameEloUpdates(gameId, gameData);

    // Check that both p1 and p2 get bestWin with opponent names joined
    const p1UpdateCall = transaction.update.mock.calls.find(
      (call: any) => call[0]?.id === "p1"
    );
    expect(p1UpdateCall[1]).toHaveProperty("bestWin");
    expect(p1UpdateCall[1].bestWin.opponentNames).toBe("Charlie & Diana");

    const p2UpdateCall = transaction.update.mock.calls.find(
      (call: any) => call[0]?.id === "p2"
    );
    expect(p2UpdateCall[1]).toHaveProperty("bestWin");
    expect(p2UpdateCall[1].bestWin.opponentNames).toBe("Charlie & Diana");
  });

  test("does NOT set bestWin when losing", async () => {
    const gameId = "game4";
    const gameData = {
      teams: {
        teamAPlayerIds: ["p1"],
        teamBPlayerIds: ["p2"],
      },
      result: {
        games: [{ winner: "teamB" }], // p1 loses
      },
    };

    const playerMap: {[key: string]: any} = {
      p1: { eloRating: 1200, displayName: "P1" },
      p2: { eloRating: 1400, displayName: "P2" },
    };

    const docMock = (id: string) => ({
      id,
      exists: true,
      data: () => playerMap[id],
    });

    const subCollectionMock = {
      doc: jest.fn(() => ({ id: "historyId" })),
    };

    const docRefMock = {
      collection: jest.fn(() => subCollectionMock),
    };

    // Mock game document for defensive check
    const gameRef = { parent: { id: "games" } };
    const gameDocMock = {
      exists: true,
      id: gameId,
      ref: gameRef,
      data: () => gameData,
    };

    const collectionMock = {
      doc: jest.fn((id) => {
        if (id === gameId) {
          return {
            ...docRefMock,
            get: jest.fn().mockResolvedValue(gameDocMock),
          };
        }
        return {...docMock(id), ...docRefMock};
      }),
    };
    db.collection.mockReturnValue(collectionMock);

    transaction.get.mockImplementation((ref: any) => Promise.resolve({
      exists: true,
      id: ref.id,
      data: () => playerMap[ref.id] || {},
    }));

    await processGameEloUpdates(gameId, gameData);

    const p1UpdateCall = transaction.update.mock.calls.find(
      (call: any) => call[0]?.id === "p1"
    );
    // bestWin should not be set for loser
    expect(p1UpdateCall[1].bestWin).toBeUndefined();
  });

  // ========================================================================
  // Story 15.5: Training Session Guards
  // Ensure ELO processing explicitly rejects training sessions
  // ========================================================================

  test("rejects game data without teams (Story 15.5)", async () => {
    const gameId = "training1";
    const trainingData = {
      // Training sessions don't have teams/result structure
      groupId: "group1",
      title: "Practice Session",
      participantIds: ["p1", "p2", "p3"],
    };

    await expect(processGameEloUpdates(gameId, trainingData))
      .rejects.toThrow("Invalid game data: Missing teams information");
  });

  test("rejects game data without result/games array (Story 15.5)", async () => {
    const gameId = "training2";
    const trainingData = {
      teams: {
        teamAPlayerIds: ["p1"],
        teamBPlayerIds: ["p2"],
      },
      // Training sessions don't have results
    };

    await expect(processGameEloUpdates(gameId, trainingData))
      .rejects.toThrow("Invalid game data: Missing result or games array");
  });

  test("rejects documents from non-games collection (Story 15.5)", async () => {
    const gameId = "training3";
    const gameData = {
      teams: {
        teamAPlayerIds: ["p1"],
        teamBPlayerIds: ["p2"],
      },
      result: {
        games: [{ winner: "teamA" }],
      },
    };

    // Mock a document from trainingSessions collection
    const trainingRef = {
      parent: { id: "trainingSessions" }, // Not "games"
    };

    const trainingDocMock = {
      exists: true,
      id: gameId,
      ref: trainingRef,
      data: () => gameData,
    };

    const collectionMock = {
      doc: jest.fn(() => ({
        get: jest.fn().mockResolvedValue(trainingDocMock)
      })),
    };
    db.collection.mockReturnValue(collectionMock);

    await expect(processGameEloUpdates(gameId, gameData))
      .rejects.toThrow("ELO can only be processed for competitive games, not training sessions");
  });

  test("processes documents from games collection successfully (Story 15.5)", async () => {
    const gameId = "game5";
    const gameData = {
      teams: {
        teamAPlayerIds: ["p1"],
        teamBPlayerIds: ["p2"],
      },
      result: {
        games: [{ winner: "teamA" }],
      },
    };

    const playerMap: {[key: string]: any} = {
      p1: { eloRating: 1200, displayName: "P1" },
      p2: { eloRating: 1200, displayName: "P2" },
    };

    // Mock a document from games collection (correct path)
    const gamesRef = {
      parent: { id: "games" }, // Correct collection
    };

    const gameDocMock = {
      exists: true,
      id: gameId,
      ref: gamesRef,
      data: () => gameData,
    };

    const docMock = (id: string) => ({
      id,
      exists: true,
      data: () => playerMap[id],
    });

    const subCollectionMock = {
      doc: jest.fn(() => ({ id: "historyId" })),
    };

    const docRefMock = {
      collection: jest.fn(() => subCollectionMock),
    };

    const collectionMock = {
      doc: jest.fn((id) => {
        if (id === gameId) {
          return {
            get: jest.fn().mockResolvedValue(gameDocMock),
            ...docRefMock
          };
        }
        return {...docMock(id), ...docRefMock};
      }),
    };
    db.collection.mockReturnValue(collectionMock);

    transaction.get.mockImplementation((ref: any) => Promise.resolve({
      exists: true,
      id: ref.id,
      data: () => playerMap[ref.id] || {},
    }));

    // Should not throw
    await expect(processGameEloUpdates(gameId, gameData)).resolves.not.toThrow();
  });

  // ========================================================================
  // Story 26.7: ELO routing by game type
  // ========================================================================

  /**
   * Helper: builds a complete mock db suitable for Story 26.7 routing tests.
   * playerMap maps player id → { eloRating, mixEloRating, displayName }
   */
  function buildMockDb(
    localDb: any,
    localTransaction: any,
    gameId: string,
    gameData: any,
    playerMap: Record<string, any>
  ): void {
    const gameRef = { parent: { id: "games" } };
    const gameDocMock = {
      exists: true,
      id: gameId,
      ref: gameRef,
      data: () => gameData,
    };

    const subCollectionMock = { doc: jest.fn(() => ({ id: "historyId" })) };
    const docRefMock = { collection: jest.fn(() => subCollectionMock) };

    const collectionMock = {
      doc: jest.fn((id: string) => {
        if (id === gameId) {
          return { ...docRefMock, get: jest.fn().mockResolvedValue(gameDocMock) };
        }
        return {
          ...docRefMock,
          id,
          exists: true,
          data: () => playerMap[id] || {},
        };
      }),
    };
    localDb.collection.mockReturnValue(collectionMock);

    localTransaction.get.mockImplementation((ref: any) =>
      Promise.resolve({
        exists: true,
        id: ref.id,
        data: () => playerMap[ref.id] || {},
      })
    );
  }

  test("gender game — updates eloRating, leaves mixEloRating unchanged", async () => {
    const gameId = "g-gender";
    const gameData = {
      gameGenderType: "male",
      teams: { teamAPlayerIds: ["p1"], teamBPlayerIds: ["p2"] },
      result: { games: [{ winner: "teamA" }] },
    };
    const playerMap: Record<string, any> = {
      p1: { eloRating: 1200, mixEloRating: 1000, displayName: "P1" },
      p2: { eloRating: 1200, mixEloRating: 1000, displayName: "P2" },
    };
    buildMockDb(db, transaction, gameId, gameData, playerMap);

    await processGameEloUpdates(gameId, gameData);

    const p1Call = transaction.update.mock.calls.find((c: any) => c[0]?.id === "p1");
    expect(p1Call).toBeDefined();
    // eloRating should be present and changed
    expect(p1Call[1]).toHaveProperty("eloRating");
    // mixEloRating must NOT be written
    expect(p1Call[1]).not.toHaveProperty("mixEloRating");
  });

  test("female gender game — updates eloRating, leaves mixEloRating unchanged", async () => {
    const gameId = "g-female";
    const gameData = {
      gameGenderType: "female",
      teams: { teamAPlayerIds: ["p1"], teamBPlayerIds: ["p2"] },
      result: { games: [{ winner: "teamA" }] },
    };
    const playerMap: Record<string, any> = {
      p1: { eloRating: 1300, mixEloRating: 1050, displayName: "P1" },
      p2: { eloRating: 1300, mixEloRating: 1050, displayName: "P2" },
    };
    buildMockDb(db, transaction, gameId, gameData, playerMap);

    await processGameEloUpdates(gameId, gameData);

    const p1Call = transaction.update.mock.calls.find((c: any) => c[0]?.id === "p1");
    expect(p1Call).toBeDefined();
    expect(p1Call[1]).toHaveProperty("eloRating");
    expect(p1Call[1]).not.toHaveProperty("mixEloRating");
  });

  test("mix game — updates mixEloRating, leaves eloRating unchanged", async () => {
    const gameId = "g-mix";
    const gameData = {
      gameGenderType: "mix",
      teams: { teamAPlayerIds: ["p1"], teamBPlayerIds: ["p2"] },
      result: { games: [{ winner: "teamA" }] },
    };
    const playerMap: Record<string, any> = {
      p1: { eloRating: 1200, mixEloRating: 1000, displayName: "P1" },
      p2: { eloRating: 1200, mixEloRating: 1000, displayName: "P2" },
    };
    buildMockDb(db, transaction, gameId, gameData, playerMap);

    await processGameEloUpdates(gameId, gameData);

    const p1Call = transaction.update.mock.calls.find((c: any) => c[0]?.id === "p1");
    expect(p1Call).toBeDefined();
    // mixEloRating should be present and changed
    expect(p1Call[1]).toHaveProperty("mixEloRating");
    // eloRating must NOT be written
    expect(p1Call[1]).not.toHaveProperty("eloRating");
  });

  test("null gameGenderType — treated as gender game (legacy fallback)", async () => {
    const gameId = "g-null";
    const gameData = {
      // gameGenderType absent (legacy game)
      teams: { teamAPlayerIds: ["p1"], teamBPlayerIds: ["p2"] },
      result: { games: [{ winner: "teamA" }] },
    };
    const playerMap: Record<string, any> = {
      p1: { eloRating: 1200, mixEloRating: 1000, displayName: "P1" },
      p2: { eloRating: 1200, mixEloRating: 1000, displayName: "P2" },
    };
    buildMockDb(db, transaction, gameId, gameData, playerMap);

    await processGameEloUpdates(gameId, gameData);

    const p1Call = transaction.update.mock.calls.find((c: any) => c[0]?.id === "p1");
    expect(p1Call).toBeDefined();
    expect(p1Call[1]).toHaveProperty("eloRating");
    expect(p1Call[1]).not.toHaveProperty("mixEloRating");
  });

  test("gender game — history entry has gameType='gender'", async () => {
    const gameId = "g-hist-gender";
    const gameData = {
      gameGenderType: "male",
      teams: { teamAPlayerIds: ["p1"], teamBPlayerIds: ["p2"] },
      result: { games: [{ winner: "teamA" }] },
    };
    const playerMap: Record<string, any> = {
      p1: { eloRating: 1200, mixEloRating: 1000, displayName: "P1" },
      p2: { eloRating: 1200, mixEloRating: 1000, displayName: "P2" },
    };
    buildMockDb(db, transaction, gameId, gameData, playerMap);

    await processGameEloUpdates(gameId, gameData);

    // transaction.set is called for each history entry
    expect(transaction.set).toHaveBeenCalled();
    const historyCall = transaction.set.mock.calls[0];
    expect(historyCall[1]).toHaveProperty("gameType", "gender");
  });

  test("mix game — history entry has gameType='mix'", async () => {
    const gameId = "g-hist-mix";
    const gameData = {
      gameGenderType: "mix",
      teams: { teamAPlayerIds: ["p1"], teamBPlayerIds: ["p2"] },
      result: { games: [{ winner: "teamA" }] },
    };
    const playerMap: Record<string, any> = {
      p1: { eloRating: 1200, mixEloRating: 1000, displayName: "P1" },
      p2: { eloRating: 1200, mixEloRating: 1000, displayName: "P2" },
    };
    buildMockDb(db, transaction, gameId, gameData, playerMap);

    await processGameEloUpdates(gameId, gameData);

    expect(transaction.set).toHaveBeenCalled();
    const historyCall = transaction.set.mock.calls[0];
    expect(historyCall[1]).toHaveProperty("gameType", "mix");
  });

  test("mix game — uses mixEloRating as starting rating (default 1000)", async () => {
    const gameId = "g-default-mix";
    const gameData = {
      gameGenderType: "mix",
      teams: { teamAPlayerIds: ["p1"], teamBPlayerIds: ["p2"] },
      result: { games: [{ winner: "teamA" }] },
    };
    // p1 has no mixEloRating → should default to 1000
    const playerMap: Record<string, any> = {
      p1: { eloRating: 1200, displayName: "P1" }, // no mixEloRating
      p2: { eloRating: 1200, mixEloRating: 1000, displayName: "P2" },
    };
    buildMockDb(db, transaction, gameId, gameData, playerMap);

    await processGameEloUpdates(gameId, gameData);

    // p1's history entry should show oldRating as 1000 (DEFAULT_MIX_ELO)
    const p1HistCall = transaction.set.mock.calls.find((c: any) => {
      // The set call's second arg has oldRating
      return c[1]?.oldRating !== undefined;
    });
    expect(p1HistCall).toBeDefined();
    // At least one history entry should have oldRating=1000 (the p1 entry)
    const histEntries = transaction.set.mock.calls.map((c: any) => c[1]);
    const p1Entry = histEntries.find((e: any) => e?.oldRating === 1000);
    expect(p1Entry).toBeDefined();
  });

  test("rejects when game document doesn't exist (Story 15.5)", async () => {
    const gameId = "nonexistent";
    const gameData = {
      teams: {
        teamAPlayerIds: ["p1"],
        teamBPlayerIds: ["p2"],
      },
      result: {
        games: [{ winner: "teamA" }],
      },
    };

    const gameDocMock = {
      exists: false, // Game not found
      id: gameId,
    };

    const collectionMock = {
      doc: jest.fn(() => ({
        get: jest.fn().mockResolvedValue(gameDocMock)
      })),
    };
    db.collection.mockReturnValue(collectionMock);

    await expect(processGameEloUpdates(gameId, gameData))
      .rejects.toThrow("Game not found");
  });
});

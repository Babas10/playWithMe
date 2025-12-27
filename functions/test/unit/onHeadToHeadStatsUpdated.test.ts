// Unit Test: onHeadToHeadStatsUpdated Cloud Function
// Story 301.8: Nemesis Detection - Trigger-based Architecture

// Mock the statsTracking module
const mockUpdateNemesis = jest.fn();
jest.mock("../../src/statsTracking", () => ({
  updateNemesis: mockUpdateNemesis,
}));

// Import after mocking
import { onHeadToHeadStatsUpdated } from "../../src/headToHeadUpdates";

describe("onHeadToHeadStatsUpdated", () => {
  let wrapped: any;

  beforeAll(() => {
    // Initialize firebase-functions-test
    const test = require("firebase-functions-test")();
    wrapped = test.wrap(onHeadToHeadStatsUpdated);
  });

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("should call updateNemesis when h2h document is created", async () => {
    const userId = "user123";
    const opponentId = "opponent456";

    const beforeSnap = {}; // No document before (onCreate)
    const afterSnap = {
      exists: true,
      data: () => ({
        userId: userId,
        opponentId: opponentId,
        gamesPlayed: 1,
        gamesWon: 0,
        gamesLost: 1,
      }),
    };

    const context = {
      params: {
        userId: userId,
        opponentId: opponentId,
      },
    };

    mockUpdateNemesis.mockResolvedValue(undefined);

    await wrapped({ before: beforeSnap, after: afterSnap }, context);

    expect(mockUpdateNemesis).toHaveBeenCalledTimes(1);
    expect(mockUpdateNemesis).toHaveBeenCalledWith(userId);
  });

  it("should call updateNemesis when h2h document is updated", async () => {
    const userId = "user123";
    const opponentId = "opponent456";

    const beforeSnap = {
      exists: true,
      data: () => ({
        userId: userId,
        opponentId: opponentId,
        gamesPlayed: 3,
        gamesWon: 1,
        gamesLost: 2,
      }),
    };

    const afterSnap = {
      exists: true,
      data: () => ({
        userId: userId,
        opponentId: opponentId,
        gamesPlayed: 4,
        gamesWon: 1,
        gamesLost: 3, // Lost another game
      }),
    };

    const context = {
      params: {
        userId: userId,
        opponentId: opponentId,
      },
    };

    mockUpdateNemesis.mockResolvedValue(undefined);

    await wrapped({ before: beforeSnap, after: afterSnap }, context);

    expect(mockUpdateNemesis).toHaveBeenCalledTimes(1);
    expect(mockUpdateNemesis).toHaveBeenCalledWith(userId);
  });

  it("should NOT call updateNemesis when h2h document is deleted", async () => {
    const userId = "user123";
    const opponentId = "opponent456";

    const beforeSnap = {
      exists: true,
      data: () => ({
        userId: userId,
        opponentId: opponentId,
        gamesPlayed: 5,
        gamesWon: 2,
        gamesLost: 3,
      }),
    };

    const afterSnap = {
      exists: false, // Document deleted
    };

    const context = {
      params: {
        userId: userId,
        opponentId: opponentId,
      },
    };

    await wrapped({ before: beforeSnap, after: afterSnap }, context);

    expect(mockUpdateNemesis).not.toHaveBeenCalled();
  });

  it("should handle updateNemesis errors gracefully without throwing", async () => {
    const userId = "user123";
    const opponentId = "opponent456";

    const beforeSnap = {};
    const afterSnap = {
      exists: true,
      data: () => ({
        userId: userId,
        opponentId: opponentId,
        gamesPlayed: 1,
        gamesWon: 0,
        gamesLost: 1,
      }),
    };

    const context = {
      params: {
        userId: userId,
        opponentId: opponentId,
      },
    };

    // Mock updateNemesis to throw an error
    mockUpdateNemesis.mockRejectedValue(new Error("Firestore connection failed"));

    // Should NOT throw - errors are logged but not re-thrown
    await expect(
      wrapped({ before: beforeSnap, after: afterSnap }, context)
    ).resolves.toBeNull();

    expect(mockUpdateNemesis).toHaveBeenCalledTimes(1);
  });

  it("should use correct userId from context params", async () => {
    const userId = "userABC";
    const opponentId = "opponentXYZ";

    const beforeSnap = {};
    const afterSnap = {
      exists: true,
      data: () => ({
        userId: userId,
        opponentId: opponentId,
        gamesPlayed: 10,
        gamesWon: 4,
        gamesLost: 6,
      }),
    };

    const context = {
      params: {
        userId: userId,
        opponentId: opponentId,
      },
    };

    mockUpdateNemesis.mockResolvedValue(undefined);

    await wrapped({ before: beforeSnap, after: afterSnap }, context);

    // Verify it uses the userId from context.params
    expect(mockUpdateNemesis).toHaveBeenCalledWith(userId);
    expect(mockUpdateNemesis).not.toHaveBeenCalledWith(opponentId);
  });
});

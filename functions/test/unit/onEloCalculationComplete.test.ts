// Unit Test: onEloCalculationComplete Cloud Function
// Story 301.8: Decoupled Head-to-Head Stats Processing

// Mock the statsTracking module
const mockUpdateHeadToHeadStats = jest.fn();
jest.mock("../../src/statsTracking", () => ({
  updateHeadToHeadStats: mockUpdateHeadToHeadStats,
}));

// Mock admin.firestore()
const mockUpdate = jest.fn();
const mockDoc = jest.fn(() => ({
  update: mockUpdate,
}));
const mockCollection = jest.fn(() => ({
  doc: mockDoc,
}));

jest.mock("firebase-admin", () => ({
  firestore: jest.fn(() => ({
    collection: mockCollection,
    FieldValue: {
      serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
    },
  })),
  initializeApp: jest.fn(),
}));

// Import after mocking
import { onEloCalculationComplete } from "../../src/headToHeadGameUpdates";

describe("onEloCalculationComplete", () => {
  let wrapped: any;

  beforeAll(() => {
    // Initialize firebase-functions-test
    const test = require("firebase-functions-test")();
    wrapped = test.wrap(onEloCalculationComplete);
  });

  beforeEach(() => {
    jest.clearAllMocks();
    mockUpdateHeadToHeadStats.mockResolvedValue(undefined);
  });

  describe("Trigger Conditions", () => {
    it("should trigger when eloCalculated changes from false to true", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: false,
          teams: {
            teamAPlayerIds: ["player1", "player2"],
            teamBPlayerIds: ["player3", "player4"],
          },
          result: {
            overallWinner: "teamA",
            games: [
              { gameNumber: 1, teamAScore: 21, teamBScore: 19, winner: "teamA" },
            ],
          },
          eloUpdates: {
            player1: { change: 16 },
            player2: { change: 16 },
            player3: { change: -16 },
            player4: { change: -16 },
          },
        }),
      };

      const afterSnap = {
        data: () => ({
          ...beforeSnap.data(),
          eloCalculated: true,
        }),
      };

      const context = {
        params: { gameId },
      };

      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      // Should process h2h stats (4 cross-team matchups × 2 perspectives = 8 calls)
      expect(mockUpdateHeadToHeadStats).toHaveBeenCalled();
      expect(mockUpdate).toHaveBeenCalledWith({
        headToHeadProcessed: true,
        headToHeadProcessedAt: "MOCK_TIMESTAMP",
      });
    });

    it("should NOT trigger when eloCalculated is already true", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: true,
        }),
      };

      const afterSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: true,
        }),
      };

      const context = {
        params: { gameId },
      };

      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      expect(mockUpdateHeadToHeadStats).not.toHaveBeenCalled();
      expect(mockUpdate).not.toHaveBeenCalled();
    });

    it("should NOT trigger when eloCalculated changes from true to false", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: true,
        }),
      };

      const afterSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: false,
        }),
      };

      const context = {
        params: { gameId },
      };

      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      expect(mockUpdateHeadToHeadStats).not.toHaveBeenCalled();
    });
  });

  describe("Idempotency Protection", () => {
    it("should skip processing if headToHeadProcessed is already true", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: false,
        }),
      };

      const afterSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: true,
          headToHeadProcessed: true, // Already processed
        }),
      };

      const context = {
        params: { gameId },
      };

      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      expect(mockUpdateHeadToHeadStats).not.toHaveBeenCalled();
      expect(mockUpdate).not.toHaveBeenCalled();
    });

    it("should set headToHeadProcessed flag after successful processing", async () => {
      const gameId = "game456";

      const beforeSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: false,
        }),
      };

      const afterSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: true,
          teams: {
            teamAPlayerIds: ["p1", "p2"],
            teamBPlayerIds: ["p3", "p4"],
          },
          result: {
            overallWinner: "teamA",
            games: [{ gameNumber: 1, teamAScore: 21, teamBScore: 19 }],
          },
          eloUpdates: {
            p1: { change: 16 },
            p2: { change: 16 },
            p3: { change: -16 },
            p4: { change: -16 },
          },
        }),
      };

      const context = {
        params: { gameId },
      };

      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      expect(mockUpdate).toHaveBeenCalledWith({
        headToHeadProcessed: true,
        headToHeadProcessedAt: "MOCK_TIMESTAMP",
      });
    });
  });

  describe("Input Validation", () => {
    it("should handle missing teams data gracefully", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: false,
        }),
      };

      const afterSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: true,
          // Missing teams
          result: {
            overallWinner: "teamA",
            games: [],
          },
          eloUpdates: {},
        }),
      };

      const context = {
        params: { gameId },
      };

      // Should not throw, but should log error
      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      expect(mockUpdateHeadToHeadStats).not.toHaveBeenCalled();
      expect(mockUpdate).not.toHaveBeenCalled();
    });

    it("should handle missing result data gracefully", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: false,
        }),
      };

      const afterSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: true,
          teams: {
            teamAPlayerIds: ["p1", "p2"],
            teamBPlayerIds: ["p3", "p4"],
          },
          // Missing result
          eloUpdates: {},
        }),
      };

      const context = {
        params: { gameId },
      };

      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      expect(mockUpdateHeadToHeadStats).not.toHaveBeenCalled();
    });

    it("should handle missing eloUpdates data gracefully", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: false,
        }),
      };

      const afterSnap = {
        data: () => ({
          status: "completed",
          eloCalculated: true,
          teams: {
            teamAPlayerIds: ["p1", "p2"],
            teamBPlayerIds: ["p3", "p4"],
          },
          result: {
            overallWinner: "teamA",
            games: [],
          },
          // Missing eloUpdates - ELO must be calculated first
        }),
      };

      const context = {
        params: { gameId },
      };

      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      expect(mockUpdateHeadToHeadStats).not.toHaveBeenCalled();
    });
  });

  describe("Head-to-Head Stats Processing", () => {
    it("should process all cross-team matchups (2v2 = 8 updates)", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          eloCalculated: false,
        }),
      };

      const afterSnap = {
        data: () => ({
          eloCalculated: true,
          teams: {
            teamAPlayerIds: ["p1", "p2"],
            teamBPlayerIds: ["p3", "p4"],
          },
          result: {
            overallWinner: "teamA",
            games: [
              { gameNumber: 1, teamAScore: 21, teamBScore: 19 },
            ],
          },
          eloUpdates: {
            p1: { change: 16 },
            p2: { change: 16 },
            p3: { change: -16 },
            p4: { change: -16 },
          },
        }),
      };

      const context = {
        params: { gameId },
      };

      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      // 2v2 = 4 cross-team pairs × 2 perspectives = 8 updates
      expect(mockUpdateHeadToHeadStats).toHaveBeenCalledTimes(8);
    });

    it("should call updateHeadToHeadStats with correct parameters", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          eloCalculated: false,
        }),
      };

      const afterSnap = {
        data: () => ({
          eloCalculated: true,
          teams: {
            teamAPlayerIds: ["p1", "p2"],
            teamBPlayerIds: ["p3", "p4"],
          },
          result: {
            overallWinner: "teamA",
            games: [
              { gameNumber: 1, teamAScore: 21, teamBScore: 19 },
            ],
          },
          eloUpdates: {
            p1: { change: 16 },
            p2: { change: 16 },
            p3: { change: -16 },
            p4: { change: -16 },
          },
        }),
      };

      const context = {
        params: { gameId },
      };

      await wrapped({ before: beforeSnap, after: afterSnap }, context);

      // Verify at least one call has correct structure
      expect(mockUpdateHeadToHeadStats).toHaveBeenCalledWith(
        expect.any(String), // playerId
        expect.any(String), // opponentId
        expect.any(Boolean), // won
        expect.any(Number), // pointsScored
        expect.any(Number), // pointsAllowed
        expect.any(Number), // eloChange
        gameId,
        expect.any(String), // partnerId (optional)
        expect.any(String)  // opponentPartnerId (optional)
      );
    });
  });

  describe("Error Handling", () => {
    it("should handle updateHeadToHeadStats errors gracefully", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          eloCalculated: false,
        }),
      };

      const afterSnap = {
        data: () => ({
          eloCalculated: true,
          teams: {
            teamAPlayerIds: ["p1", "p2"],
            teamBPlayerIds: ["p3", "p4"],
          },
          result: {
            overallWinner: "teamA",
            games: [
              { gameNumber: 1, teamAScore: 21, teamBScore: 19 },
            ],
          },
          eloUpdates: {
            p1: { change: 16 },
            p2: { change: 16 },
            p3: { change: -16 },
            p4: { change: -16 },
          },
        }),
      };

      const context = {
        params: { gameId },
      };

      // Mock error in h2h update
      mockUpdateHeadToHeadStats.mockRejectedValue(new Error("Firestore error"));

      // Should not throw - errors are logged but processing continues
      await expect(
        wrapped({ before: beforeSnap, after: afterSnap }, context)
      ).resolves.toBeNull();
    });

    it("should not throw on validation errors", async () => {
      const gameId = "game123";

      const beforeSnap = {
        data: () => ({
          eloCalculated: false,
        }),
      };

      const afterSnap = {
        data: () => ({
          eloCalculated: true,
          // Invalid data - missing everything
        }),
      };

      const context = {
        params: { gameId },
      };

      // Should handle gracefully
      await expect(
        wrapped({ before: beforeSnap, after: afterSnap }, context)
      ).resolves.toBeNull();
    });
  });
});

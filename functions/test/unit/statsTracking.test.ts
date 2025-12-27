// Unit Test: statsTracking (Story 301.8 - Regression Tests)
// Verifies that h2h stats are NO LONGER processed in processStatsTracking

// Mock updateTeammateStats to track calls
const mockUpdateTeammateStats = jest.fn();

// Mock updateHeadToHeadStats - should NEVER be called from processStatsTracking
const mockUpdateHeadToHeadStats = jest.fn();

// Create module mock
jest.mock("../../src/statsTracking", () => {
  const actual = jest.requireActual("../../src/statsTracking");
  return {
    ...actual,
    updateTeammateStats: mockUpdateTeammateStats,
    updateHeadToHeadStats: mockUpdateHeadToHeadStats,
  };
});

// Import after mocking
import { processStatsTracking } from "../../src/statsTracking";

describe("processStatsTracking (Story 301.8 - Decoupled)", () => {
  let mockTransaction: any;

  beforeEach(() => {
    jest.clearAllMocks();

    // Mock transaction
    mockTransaction = {
      get: jest.fn(),
      update: jest.fn(),
      set: jest.fn(),
    };

    // Mock successful teammate stats updates
    mockUpdateTeammateStats.mockResolvedValue(undefined);
  });

  describe("Regression: H2H Stats Removal", () => {
    it("should ONLY process teammate stats (not h2h stats)", async () => {
      const gameId = "game123";
      const teamAPlayerIds = ["player1", "player2"];
      const teamBPlayerIds = ["player3", "player4"];
      const teamAWon = true;
      const individualGames = [
        {
          gameNumber: 1,
          teamAScore: 21,
          teamBScore: 19,
          winner: "teamA",
        },
      ];
      const playerEloChanges = new Map([
        ["player1", 16],
        ["player2", 16],
        ["player3", -16],
        ["player4", -16],
      ]);

      const playerDataMap = new Map([
        ["player1", { teammateStats: {} }],
        ["player2", { teammateStats: {} }],
        ["player3", { teammateStats: {} }],
        ["player4", { teammateStats: {} }],
      ]);

      await processStatsTracking(
        mockTransaction,
        gameId,
        teamAPlayerIds,
        teamBPlayerIds,
        teamAWon,
        individualGames,
        playerEloChanges,
        playerDataMap
      );

      // Teammate stats SHOULD be processed
      expect(mockUpdateTeammateStats).toHaveBeenCalled();

      // H2H stats should NEVER be called from processStatsTracking
      expect(mockUpdateHeadToHeadStats).not.toHaveBeenCalled();
    });

    it("should NOT call updateHeadToHeadStats at all", async () => {
      const gameId = "game456";
      const teamAPlayerIds = ["p1", "p2"];
      const teamBPlayerIds = ["p3", "p4"];
      const teamAWon = false; // Team B wins
      const individualGames = [
        {
          gameNumber: 1,
          teamAScore: 18,
          teamBScore: 21,
          winner: "teamB",
        },
      ];
      const playerEloChanges = new Map([
        ["p1", -16],
        ["p2", -16],
        ["p3", 16],
        ["p4", 16],
      ]);

      const playerDataMap = new Map([
        ["p1", { teammateStats: {} }],
        ["p2", { teammateStats: {} }],
        ["p3", { teammateStats: {} }],
        ["p4", { teammateStats: {} }],
      ]);

      await processStatsTracking(
        mockTransaction,
        gameId,
        teamAPlayerIds,
        teamBPlayerIds,
        teamAWon,
        individualGames,
        playerEloChanges,
        playerDataMap
      );

      // Verify updateHeadToHeadStats is never called
      expect(mockUpdateHeadToHeadStats).not.toHaveBeenCalled();
      expect(mockUpdateHeadToHeadStats).toHaveBeenCalledTimes(0);
    });

    it("should only update teammate stats (Team A partnerships)", async () => {
      const gameId = "game789";
      const teamAPlayerIds = ["player1", "player2"];
      const teamBPlayerIds = ["player3", "player4"];
      const teamAWon = true;
      const individualGames = [
        {
          gameNumber: 1,
          teamAScore: 21,
          teamBScore: 19,
          winner: "teamA",
        },
      ];
      const playerEloChanges = new Map([
        ["player1", 16],
        ["player2", 16],
        ["player3", -16],
        ["player4", -16],
      ]);

      const playerDataMap = new Map([
        ["player1", { teammateStats: {} }],
        ["player2", { teammateStats: {} }],
        ["player3", { teammateStats: {} }],
        ["player4", { teammateStats: {} }],
      ]);

      await processStatsTracking(
        mockTransaction,
        gameId,
        teamAPlayerIds,
        teamBPlayerIds,
        teamAWon,
        individualGames,
        playerEloChanges,
        playerDataMap
      );

      // Team A (2 players) should have 2 teammate stat updates (player1-player2, player2-player1)
      // Team B (2 players) should have 2 teammate stat updates (player3-player4, player4-player3)
      // Total: 4 teammate stat updates
      expect(mockUpdateTeammateStats).toHaveBeenCalledTimes(4);

      // But NO h2h updates (which would be 8 calls)
      expect(mockUpdateHeadToHeadStats).toHaveBeenCalledTimes(0);
    });
  });

  describe("Teammate Stats Functionality", () => {
    it("should process teammate stats for both teams", async () => {
      const gameId = "game123";
      const teamAPlayerIds = ["p1", "p2"];
      const teamBPlayerIds = ["p3", "p4"];
      const teamAWon = true;
      const individualGames = [
        {
          gameNumber: 1,
          teamAScore: 21,
          teamBScore: 19,
          winner: "teamA",
        },
      ];
      const playerEloChanges = new Map([
        ["p1", 16],
        ["p2", 16],
        ["p3", -16],
        ["p4", -16],
      ]);

      const playerDataMap = new Map([
        ["p1", { teammateStats: {} }],
        ["p2", { teammateStats: {} }],
        ["p3", { teammateStats: {} }],
        ["p4", { teammateStats: {} }],
      ]);

      await processStatsTracking(
        mockTransaction,
        gameId,
        teamAPlayerIds,
        teamBPlayerIds,
        teamAWon,
        individualGames,
        playerEloChanges,
        playerDataMap
      );

      // Should call updateTeammateStats 4 times:
      // - Team A: p1-p2, p2-p1
      // - Team B: p3-p4, p4-p3
      expect(mockUpdateTeammateStats).toHaveBeenCalledTimes(4);
    });

    it("should calculate correct total points for each team", async () => {
      const gameId = "game123";
      const teamAPlayerIds = ["p1", "p2"];
      const teamBPlayerIds = ["p3", "p4"];
      const teamAWon = true;

      // Multiple games with scores
      const individualGames = [
        { gameNumber: 1, teamAScore: 21, teamBScore: 19, winner: "teamA" },
        { gameNumber: 2, teamAScore: 18, teamBScore: 21, winner: "teamB" },
        { gameNumber: 3, teamAScore: 21, teamBScore: 17, winner: "teamA" },
      ];

      const playerEloChanges = new Map([
        ["p1", 8],
        ["p2", 8],
        ["p3", -8],
        ["p4", -8],
      ]);

      const playerDataMap = new Map([
        ["p1", { teammateStats: {} }],
        ["p2", { teammateStats: {} }],
        ["p3", { teammateStats: {} }],
        ["p4", { teammateStats: {} }],
      ]);

      await processStatsTracking(
        mockTransaction,
        gameId,
        teamAPlayerIds,
        teamBPlayerIds,
        teamAWon,
        individualGames,
        playerEloChanges,
        playerDataMap
      );

      // Verify teammate stats were called with correct total points
      // Team A total: 21 + 18 + 21 = 60
      // Team B total: 19 + 21 + 17 = 57

      // Check first call (p1 with teammate p2)
      expect(mockUpdateTeammateStats).toHaveBeenNthCalledWith(
        1,
        mockTransaction,
        "p1",
        "p2",
        true, // won
        60,   // teamAPoints (scored)
        57,   // teamBPoints (allowed)
        8,    // eloChange
        gameId,
        {}    // currentTeammateStats
      );
    });
  });

  describe("Edge Cases", () => {
    it("should handle empty individual games array", async () => {
      const gameId = "game123";
      const teamAPlayerIds = ["p1", "p2"];
      const teamBPlayerIds = ["p3", "p4"];
      const teamAWon = false;
      const individualGames: any[] = []; // Empty
      const playerEloChanges = new Map([
        ["p1", 0],
        ["p2", 0],
        ["p3", 0],
        ["p4", 0],
      ]);

      const playerDataMap = new Map([
        ["p1", { teammateStats: {} }],
        ["p2", { teammateStats: {} }],
        ["p3", { teammateStats: {} }],
        ["p4", { teammateStats: {} }],
      ]);

      await processStatsTracking(
        mockTransaction,
        gameId,
        teamAPlayerIds,
        teamBPlayerIds,
        teamAWon,
        individualGames,
        playerEloChanges,
        playerDataMap
      );

      // Should still process teammate stats (with 0 points)
      expect(mockUpdateTeammateStats).toHaveBeenCalledTimes(4);

      // Should NOT process h2h stats
      expect(mockUpdateHeadToHeadStats).not.toHaveBeenCalled();
    });

    it("should handle missing scores in individual games", async () => {
      const gameId = "game123";
      const teamAPlayerIds = ["p1", "p2"];
      const teamBPlayerIds = ["p3", "p4"];
      const teamAWon = true;
      const individualGames = [
        {
          gameNumber: 1,
          // Missing teamAScore and teamBScore
          winner: "teamA",
        },
      ];
      const playerEloChanges = new Map([
        ["p1", 16],
        ["p2", 16],
        ["p3", -16],
        ["p4", -16],
      ]);

      const playerDataMap = new Map([
        ["p1", { teammateStats: {} }],
        ["p2", { teammateStats: {} }],
        ["p3", { teammateStats: {} }],
        ["p4", { teammateStats: {} }],
      ]);

      await processStatsTracking(
        mockTransaction,
        gameId,
        teamAPlayerIds,
        teamBPlayerIds,
        teamAWon,
        individualGames,
        playerEloChanges,
        playerDataMap
      );

      // Should handle gracefully (scores default to 0)
      expect(mockUpdateTeammateStats).toHaveBeenCalledTimes(4);

      // Verify called with 0 points
      expect(mockUpdateTeammateStats).toHaveBeenCalledWith(
        mockTransaction,
        "p1",
        "p2",
        true,
        0, // teamAPoints (missing score = 0)
        0, // teamBPoints (missing score = 0)
        16,
        gameId,
        {}
      );
    });
  });
});

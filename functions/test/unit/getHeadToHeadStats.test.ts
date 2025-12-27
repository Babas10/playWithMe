// Unit Test: getHeadToHeadStats Callable Function
// Story 301.8: Head-to-Head Stats Retrieval

import functionsTest from "firebase-functions-test";

// Mock admin.firestore()
const mockGet = jest.fn();
const mockDoc = jest.fn(() => ({
  get: mockGet,
}));
const mockCollection = jest.fn(() => ({
  doc: mockDoc,
}));

jest.mock("firebase-admin", () => ({
  firestore: jest.fn(() => ({
    collection: mockCollection,
  })),
  initializeApp: jest.fn(),
}));

// Import after mocking
const admin = require("firebase-admin");
const { getHeadToHeadStats } = require("../../src/getHeadToHeadStats");

// Initialize Firebase Functions test environment
const test = functionsTest();

describe("getHeadToHeadStats", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterAll(() => {
    test.cleanup();
  });

  describe("Authentication", () => {
    it("should throw unauthenticated error when user is not logged in", async () => {
      const context = { auth: undefined } as any;
      const data = { opponentId: "opponent123" };

      await expect(getHeadToHeadStats(data, context)).rejects.toMatchObject({
        code: "unauthenticated",
        message: "You must be logged in to view head-to-head statistics.",
      });
    });

    it("should require auth context with uid", async () => {
      const context = { auth: {} } as any; // Missing uid
      const data = { opponentId: "opponent123" };

      await expect(getHeadToHeadStats(data, context)).rejects.toMatchObject({
        code: "unauthenticated",
      });
    });
  });

  describe("Input Validation", () => {
    const mockContext = {
      auth: { uid: "user123" },
    } as any;

    it("should throw error when opponentId is missing", async () => {
      const data = {} as any;

      await expect(getHeadToHeadStats(data, mockContext)).rejects.toMatchObject({
        code: "invalid-argument",
        message: 'Expected parameter "opponentId" of type string.',
      });
    });

    it("should throw error when opponentId is not a string", async () => {
      const data = { opponentId: 123 } as any;

      await expect(getHeadToHeadStats(data, mockContext)).rejects.toMatchObject({
        code: "invalid-argument",
        message: 'Expected parameter "opponentId" of type string.',
      });
    });

    it("should throw error when data is null", async () => {
      const data = null as any;

      await expect(getHeadToHeadStats(data, mockContext)).rejects.toMatchObject({
        code: "invalid-argument",
      });
    });

    it("should throw error when data is undefined", async () => {
      const data = undefined as any;

      await expect(getHeadToHeadStats(data, mockContext)).rejects.toMatchObject({
        code: "invalid-argument",
      });
    });
  });

  describe("Head-to-Head Stats Retrieval", () => {
    const mockContext = {
      auth: { uid: "user123" },
    } as any;

    it("should return null when h2h document does not exist", async () => {
      const data = { opponentId: "opponent456" };

      mockGet.mockResolvedValue({
        exists: false,
      });

      const result = await getHeadToHeadStats(data, mockContext);

      expect(result).toBeNull();
      expect(mockCollection).toHaveBeenCalledWith("users");
      expect(mockDoc).toHaveBeenCalledWith("user123");
      expect(mockCollection).toHaveBeenCalledWith("headToHead");
      expect(mockDoc).toHaveBeenCalledWith("opponent456");
    });

    it("should return null when h2h document data is null", async () => {
      const data = { opponentId: "opponent456" };

      mockGet.mockResolvedValue({
        exists: true,
        data: () => null,
      });

      const result = await getHeadToHeadStats(data, mockContext);

      expect(result).toBeNull();
    });

    it("should return h2h stats when document exists", async () => {
      const data = { opponentId: "opponent789" };

      const mockTimestamp = {
        toDate: () => new Date("2025-12-27T10:00:00Z"),
      };

      mockGet.mockResolvedValue({
        exists: true,
        data: () => ({
          userId: "user123",
          opponentId: "opponent789",
          opponentName: "Opponent Name",
          opponentEmail: "opponent@example.com",
          opponentPhotoUrl: "https://example.com/photo.jpg",
          gamesPlayed: 10,
          gamesWon: 6,
          gamesLost: 4,
          pointsScored: 210,
          pointsAllowed: 195,
          eloChange: 24,
          largestVictoryMargin: 8,
          largestDefeatMargin: 5,
          lastUpdated: mockTimestamp,
          recentMatchups: [
            {
              gameId: "game1",
              won: true,
              pointsScored: 21,
              pointsAllowed: 19,
              eloChange: 16,
              timestamp: mockTimestamp,
              partnerId: "partner1",
              opponentPartnerId: "oppPartner1",
            },
          ],
        }),
      });

      const result = await getHeadToHeadStats(data, mockContext);

      expect(result).toBeDefined();
      expect(result.userId).toBe("user123");
      expect(result.opponentId).toBe("opponent789");
      expect(result.opponentName).toBe("Opponent Name");
      expect(result.opponentEmail).toBe("opponent@example.com");
      expect(result.opponentPhotoUrl).toBe("https://example.com/photo.jpg");
      expect(result.gamesPlayed).toBe(10);
      expect(result.gamesWon).toBe(6);
      expect(result.gamesLost).toBe(4);
      expect(result.pointsScored).toBe(210);
      expect(result.pointsAllowed).toBe(195);
      expect(result.eloChange).toBe(24);
      expect(result.largestVictoryMargin).toBe(8);
      expect(result.largestDefeatMargin).toBe(5);
    });

    it("should serialize Firestore Timestamps to ISO strings", async () => {
      const data = { opponentId: "opponent789" };

      const mockTimestamp = {
        toDate: () => new Date("2025-12-27T15:30:00Z"),
      };

      mockGet.mockResolvedValue({
        exists: true,
        data: () => ({
          userId: "user123",
          opponentId: "opponent789",
          gamesPlayed: 5,
          gamesWon: 3,
          gamesLost: 2,
          pointsScored: 100,
          pointsAllowed: 95,
          eloChange: 10,
          lastUpdated: mockTimestamp,
          recentMatchups: [
            {
              gameId: "game1",
              won: true,
              pointsScored: 21,
              pointsAllowed: 19,
              eloChange: 5,
              timestamp: mockTimestamp,
            },
          ],
        }),
      });

      const result = await getHeadToHeadStats(data, mockContext);

      // Verify timestamps are converted to ISO strings
      expect(result.lastUpdated).toBe("2025-12-27T15:30:00.000Z");
      expect(result.recentMatchups[0].timestamp).toBe("2025-12-27T15:30:00.000Z");
    });

    it("should handle null timestamps gracefully", async () => {
      const data = { opponentId: "opponent789" };

      mockGet.mockResolvedValue({
        exists: true,
        data: () => ({
          userId: "user123",
          opponentId: "opponent789",
          gamesPlayed: 1,
          gamesWon: 1,
          gamesLost: 0,
          pointsScored: 21,
          pointsAllowed: 19,
          eloChange: 16,
          lastUpdated: null,
          recentMatchups: [
            {
              gameId: "game1",
              won: true,
              pointsScored: 21,
              pointsAllowed: 19,
              eloChange: 16,
              timestamp: null,
            },
          ],
        }),
      });

      const result = await getHeadToHeadStats(data, mockContext);

      expect(result.lastUpdated).toBeNull();
      expect(result.recentMatchups[0].timestamp).toBeNull();
    });

    it("should handle missing recentMatchups field", async () => {
      const data = { opponentId: "opponent789" };

      mockGet.mockResolvedValue({
        exists: true,
        data: () => ({
          userId: "user123",
          opponentId: "opponent789",
          gamesPlayed: 3,
          gamesWon: 2,
          gamesLost: 1,
          pointsScored: 60,
          pointsAllowed: 55,
          eloChange: 8,
          lastUpdated: null,
          // recentMatchups missing
        }),
      });

      const result = await getHeadToHeadStats(data, mockContext);

      expect(result.recentMatchups).toEqual([]);
    });

    it("should include cached opponent information", async () => {
      const data = { opponentId: "opponent999" };

      mockGet.mockResolvedValue({
        exists: true,
        data: () => ({
          userId: "user123",
          opponentId: "opponent999",
          opponentName: "John Doe",
          opponentEmail: "john@example.com",
          opponentPhotoUrl: "https://example.com/john.jpg",
          gamesPlayed: 7,
          gamesWon: 4,
          gamesLost: 3,
          pointsScored: 150,
          pointsAllowed: 140,
          eloChange: 12,
          lastUpdated: null,
        }),
      });

      const result = await getHeadToHeadStats(data, mockContext);

      expect(result.opponentName).toBe("John Doe");
      expect(result.opponentEmail).toBe("john@example.com");
      expect(result.opponentPhotoUrl).toBe("https://example.com/john.jpg");
    });
  });

  describe("Error Handling", () => {
    const mockContext = {
      auth: { uid: "user123" },
    } as any;

    it("should throw internal error when Firestore query fails", async () => {
      const data = { opponentId: "opponent789" };

      mockGet.mockRejectedValue(new Error("Firestore connection error"));

      await expect(getHeadToHeadStats(data, mockContext)).rejects.toMatchObject({
        code: "internal",
        message: "Failed to retrieve head-to-head statistics. Please try again later.",
      });
    });

    it("should throw internal error on unexpected exception", async () => {
      const data = { opponentId: "opponent789" };

      mockGet.mockImplementation(() => {
        throw new Error("Unexpected error");
      });

      await expect(getHeadToHeadStats(data, mockContext)).rejects.toMatchObject({
        code: "internal",
      });
    });
  });

  describe("Security", () => {
    it("should only retrieve h2h stats for authenticated user (not opponent)", async () => {
      const mockContext = {
        auth: { uid: "userABC" },
      } as any;

      const data = { opponentId: "opponentXYZ" };

      mockGet.mockResolvedValue({
        exists: true,
        data: () => ({
          userId: "userABC",
          opponentId: "opponentXYZ",
          gamesPlayed: 5,
          gamesWon: 3,
          gamesLost: 2,
        }),
      });

      await getHeadToHeadStats(data, mockContext);

      // Verify it queries the authenticated user's h2h collection
      expect(mockDoc).toHaveBeenNthCalledWith(1, "userABC");
      expect(mockDoc).toHaveBeenNthCalledWith(2, "opponentXYZ");
    });

    it("should use userId from context.auth.uid, not from data", async () => {
      const mockContext = {
        auth: { uid: "authenticated-user" },
      } as any;

      // Attacker tries to pass a different userId
      const data = {
        opponentId: "opponent123",
        userId: "victim-user", // Should be ignored
      };

      mockGet.mockResolvedValue({
        exists: false,
      });

      await getHeadToHeadStats(data, mockContext);

      // Should use authenticated user's ID, not the one from data
      expect(mockDoc).toHaveBeenNthCalledWith(1, "authenticated-user");
      expect(mockDoc).not.toHaveBeenCalledWith("victim-user");
    });
  });
});

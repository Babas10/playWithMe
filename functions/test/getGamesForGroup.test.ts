import functionsTest from "firebase-functions-test";
import {getGamesForGroupHandler} from "../src/getGamesForGroup";

// Mock admin.firestore()
jest.mock("firebase-admin", () => {
  const mockFirestore = {
    collection: jest.fn(),
  };

  return {
    firestore: jest.fn(() => mockFirestore),
    initializeApp: jest.fn(),
  };
});

// Initialize Firebase Functions test environment
const test = functionsTest();

// Get mockFirestore reference for test setup
const admin = require("firebase-admin");
const mockFirestore = admin.firestore();

describe("getGamesForGroup", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterAll(() => {
    test.cleanup();
  });

  it("should throw unauthenticated error when user is not authenticated", async () => {
    const context = {
      auth: null,
    };

    const data = {
      groupId: "group-123",
    };

    await expect(
      getGamesForGroupHandler(data, context as any)
    ).rejects.toThrow("User must be authenticated to view games");
  });

  it("should throw invalid-argument error when groupId is missing", async () => {
    const context = {
      auth: {uid: "user-123"},
    };

    const data = {};

    await expect(
      getGamesForGroupHandler(data as any, context as any)
    ).rejects.toThrow("groupId is required and must be a string");
  });

  it("should throw invalid-argument error when groupId is not a string", async () => {
    const context = {
      auth: {uid: "user-123"},
    };

    const data = {
      groupId: 12345,
    };

    await expect(
      getGamesForGroupHandler(data as any, context as any)
    ).rejects.toThrow("groupId is required and must be a string");
  });

  it("should throw not-found error when group does not exist", async () => {
    const context = {
      auth: {uid: "user-123"},
    };

    const data = {
      groupId: "non-existent-group",
    };

    // Mock group not found
    const mockGet = jest.fn().mockResolvedValue({
      exists: false,
    });

    const mockDoc = jest.fn().mockReturnValue({
      get: mockGet,
    });

    mockFirestore.collection.mockReturnValue({
      doc: mockDoc,
    });

    await expect(
      getGamesForGroupHandler(data, context as any)
    ).rejects.toThrow("Group not found");
  });

  it("should throw permission-denied error when user is not a member of the group", async () => {
    const context = {
      auth: {uid: "user-123"},
    };

    const data = {
      groupId: "group-456",
    };

    // Mock group exists but user is not a member
    const mockGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({
        name: "Test Group",
        memberIds: ["user-456", "user-789"], // user-123 not in list
        adminIds: ["user-456"],
      }),
    });

    const mockDoc = jest.fn().mockReturnValue({
      get: mockGet,
    });

    mockFirestore.collection.mockReturnValue({
      doc: mockDoc,
    });

    await expect(
      getGamesForGroupHandler(data, context as any)
    ).rejects.toThrow("You must be a member of this group to view its games");
  });

  it("should return empty games array when no games exist for the group", async () => {
    const context = {
      auth: {uid: "user-123"},
    };

    const data = {
      groupId: "group-789",
    };

    // Mock group exists and user is a member
    const mockGroupGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({
        name: "Test Group",
        memberIds: ["user-123", "user-456"],
        adminIds: ["user-456"],
      }),
    });

    // Mock empty games collection
    const mockGamesGet = jest.fn().mockResolvedValue({
      docs: [],
    });

    const mockOrderBy = jest.fn().mockReturnValue({
      get: mockGamesGet,
    });

    const mockWhere = jest.fn().mockReturnValue({
      orderBy: mockOrderBy,
    });

    let callCount = 0;
    mockFirestore.collection.mockImplementation((collectionName: string) => {
      callCount++;
      if (callCount === 1) {
        // First call: groups collection
        return {
          doc: jest.fn().mockReturnValue({
            get: mockGroupGet,
          }),
        };
      } else {
        // Second call: games collection
        return {
          where: mockWhere,
        };
      }
    });

    const result = await getGamesForGroupHandler(data, context as any);

    expect(result).toEqual({games: []});
    expect(mockWhere).toHaveBeenCalledWith("groupId", "==", "group-789");
    expect(mockOrderBy).toHaveBeenCalledWith("scheduledAt", "asc");
  });

  it("should return games when they exist for the group", async () => {
    const context = {
      auth: {uid: "user-123"},
    };

    const data = {
      groupId: "group-abc",
    };

    const mockTimestamp = {
      toDate: () => new Date("2025-12-01T10:00:00Z"),
    };

    // Mock group exists and user is a member
    const mockGroupGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({
        name: "Test Group",
        memberIds: ["user-123", "user-456"],
        adminIds: ["user-456"],
      }),
    });

    // Mock games collection with 2 games
    const mockGamesGet = jest.fn().mockResolvedValue({
      docs: [
        {
          exists: true,
          id: "game-1",
          data: () => ({
            title: "Beach Volleyball",
            description: "Fun game at the beach",
            groupId: "group-abc",
            createdBy: "user-456",
            createdAt: mockTimestamp,
            updatedAt: mockTimestamp,
            scheduledAt: mockTimestamp,
            location: {
              name: "Beach Court",
              latitude: 40.7128,
              longitude: -74.006,
            },
            status: "scheduled",
            maxPlayers: 4,
            minPlayers: 2,
            playerIds: ["user-123", "user-456"],
            waitlistIds: [],
            allowWaitlist: true,
            allowPlayerInvites: true,
            visibility: "group",
            notes: "Bring sunscreen",
            equipment: ["Ball", "Net"],
            gameType: "beach-volleyball",
            skillLevel: "intermediate",
          }),
        },
        {
          exists: true,
          id: "game-2",
          data: () => ({
            title: "Evening Game",
            groupId: "group-abc",
            createdBy: "user-123",
            createdAt: mockTimestamp,
            updatedAt: mockTimestamp,
            scheduledAt: mockTimestamp,
            location: {
              name: "Park Court",
            },
            status: "scheduled",
            maxPlayers: 6,
            minPlayers: 4,
            playerIds: ["user-123"],
            waitlistIds: [],
            allowWaitlist: false,
            allowPlayerInvites: false,
            visibility: "private",
          }),
        },
      ],
    });

    const mockOrderBy = jest.fn().mockReturnValue({
      get: mockGamesGet,
    });

    const mockWhere = jest.fn().mockReturnValue({
      orderBy: mockOrderBy,
    });

    let callCount = 0;
    mockFirestore.collection.mockImplementation((collectionName: string) => {
      callCount++;
      if (callCount === 1) {
        // First call: groups collection
        return {
          doc: jest.fn().mockReturnValue({
            get: mockGroupGet,
          }),
        };
      } else {
        // Second call: games collection
        return {
          where: mockWhere,
        };
      }
    });

    const result = await getGamesForGroupHandler(data, context as any);

    expect(result.games).toHaveLength(2);
    expect(result.games[0].id).toBe("game-1");
    expect(result.games[0].title).toBe("Beach Volleyball");
    expect(result.games[0].playerIds).toEqual(["user-123", "user-456"]);
    expect(result.games[1].id).toBe("game-2");
    expect(result.games[1].title).toBe("Evening Game");
  });

  it("should handle games with minimal data (only required fields)", async () => {
    const context = {
      auth: {uid: "user-123"},
    };

    const data = {
      groupId: "group-minimal",
    };

    const mockTimestamp = {
      toDate: () => new Date("2025-12-01T10:00:00Z"),
    };

    // Mock group exists and user is a member
    const mockGroupGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({
        name: "Minimal Group",
        memberIds: ["user-123"],
        adminIds: ["user-123"],
      }),
    });

    // Mock game with minimal fields
    const mockGamesGet = jest.fn().mockResolvedValue({
      docs: [
        {
          exists: true,
          id: "minimal-game",
          data: () => ({
            title: "Quick Game",
            groupId: "group-minimal",
            createdBy: "user-123",
            createdAt: mockTimestamp,
            updatedAt: mockTimestamp,
            scheduledAt: mockTimestamp,
            location: {name: "Court"},
            status: "scheduled",
            maxPlayers: 4,
            minPlayers: 2,
            playerIds: [],
            waitlistIds: [],
            visibility: "group",
            // Optional fields missing
          }),
        },
      ],
    });

    const mockOrderBy = jest.fn().mockReturnValue({
      get: mockGamesGet,
    });

    const mockWhere = jest.fn().mockReturnValue({
      orderBy: mockOrderBy,
    });

    let callCount = 0;
    mockFirestore.collection.mockImplementation((collectionName: string) => {
      callCount++;
      if (callCount === 1) {
        return {
          doc: jest.fn().mockReturnValue({
            get: mockGroupGet,
          }),
        };
      } else {
        return {
          where: mockWhere,
        };
      }
    });

    const result = await getGamesForGroupHandler(data, context as any);

    expect(result.games).toHaveLength(1);
    expect(result.games[0].allowWaitlist).toBe(true); // Default value
    expect(result.games[0].allowPlayerInvites).toBe(true); // Default value
    expect(result.games[0].description).toBeUndefined();
    expect(result.games[0].notes).toBeUndefined();
  });
});

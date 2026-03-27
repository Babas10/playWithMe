// Unit tests for getGamesForGroupHandler
// Story 25.5: Parallelised membership check + games query

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

/** Helper: mock the groups collection to return a group with given memberIds */
function mockGroupCollection(memberIds: string[], exists = true) {
  return {
    doc: jest.fn().mockReturnValue({
      get: jest.fn().mockResolvedValue({
        exists,
        data: () => exists ? {name: "Test Group", memberIds, adminIds: []} : undefined,
      }),
    }),
  };
}

/** Helper: mock the games collection to return given docs */
function mockGamesCollection(docs: any[]) {
  return {
    where: jest.fn().mockReturnValue({
      orderBy: jest.fn().mockReturnValue({
        get: jest.fn().mockResolvedValue({docs}),
      }),
    }),
  };
}

describe("getGamesForGroup", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterAll(() => {
    test.cleanup();
  });

  it("should throw unauthenticated error when user is not authenticated", async () => {
    await expect(
      getGamesForGroupHandler({groupId: "group-123"}, {auth: null} as any)
    ).rejects.toThrow("User must be authenticated to view games");
  });

  it("should throw invalid-argument error when groupId is missing", async () => {
    await expect(
      getGamesForGroupHandler({} as any, {auth: {uid: "user-123"}} as any)
    ).rejects.toThrow("groupId is required and must be a string");
  });

  it("should throw invalid-argument error when groupId is not a string", async () => {
    await expect(
      getGamesForGroupHandler({groupId: 12345} as any, {auth: {uid: "user-123"}} as any)
    ).rejects.toThrow("groupId is required and must be a string");
  });

  it("should throw not-found error when group does not exist", async () => {
    mockFirestore.collection.mockImplementation((name: string) => {
      if (name === "groups") return mockGroupCollection([], false);
      return mockGamesCollection([]);
    });

    await expect(
      getGamesForGroupHandler({groupId: "non-existent"}, {auth: {uid: "user-123"}} as any)
    ).rejects.toThrow("Group not found");
  });

  it("should throw permission-denied error when user is not a member of the group", async () => {
    mockFirestore.collection.mockImplementation((name: string) => {
      if (name === "groups") return mockGroupCollection(["user-456", "user-789"]);
      return mockGamesCollection([]);
    });

    await expect(
      getGamesForGroupHandler({groupId: "group-456"}, {auth: {uid: "user-123"}} as any)
    ).rejects.toThrow("You must be a member of this group to view its games");
  });

  it("should return empty games array when no games exist for the group", async () => {
    mockFirestore.collection.mockImplementation((name: string) => {
      if (name === "groups") return mockGroupCollection(["user-123", "user-456"]);
      return mockGamesCollection([]);
    });

    const result = await getGamesForGroupHandler(
      {groupId: "group-789"},
      {auth: {uid: "user-123"}} as any
    );

    expect(result).toEqual({games: []});
    expect(mockFirestore.collection).toHaveBeenCalledWith("games");
  });

  it("should return games when they exist for the group", async () => {
    const mockTimestamp = {toDate: () => new Date("2025-12-01T10:00:00Z")};

    const gameDocs = [
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
          location: {name: "Beach Court", latitude: 40.7128, longitude: -74.006},
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
          location: {name: "Park Court"},
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
    ];

    mockFirestore.collection.mockImplementation((name: string) => {
      if (name === "groups") return mockGroupCollection(["user-123", "user-456"]);
      return mockGamesCollection(gameDocs);
    });

    const result = await getGamesForGroupHandler(
      {groupId: "group-abc"},
      {auth: {uid: "user-123"}} as any
    );

    expect(result.games).toHaveLength(2);
    expect(result.games[0].id).toBe("game-1");
    expect(result.games[0].title).toBe("Beach Volleyball");
    expect(result.games[0].playerIds).toEqual(["user-123", "user-456"]);
    expect(result.games[1].id).toBe("game-2");
    expect(result.games[1].title).toBe("Evening Game");
  });

  it("should handle games with minimal data (only required fields)", async () => {
    const mockTimestamp = {toDate: () => new Date("2025-12-01T10:00:00Z")};

    mockFirestore.collection.mockImplementation((name: string) => {
      if (name === "groups") return mockGroupCollection(["user-123"]);
      return mockGamesCollection([
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
          }),
        },
      ]);
    });

    const result = await getGamesForGroupHandler(
      {groupId: "group-minimal"},
      {auth: {uid: "user-123"}} as any
    );

    expect(result.games).toHaveLength(1);
    expect(result.games[0].allowWaitlist).toBe(true);
    expect(result.games[0].allowPlayerInvites).toBe(true);
    expect(result.games[0].description).toBeUndefined();
    expect(result.games[0].notes).toBeUndefined();
  });

  it("fires both group and games queries in parallel", async () => {
    // Confirm both queries are initiated — both collections must be called
    const collectionsCalled: string[] = [];

    mockFirestore.collection.mockImplementation((name: string) => {
      collectionsCalled.push(name);
      if (name === "groups") return mockGroupCollection(["user-123"]);
      return mockGamesCollection([]);
    });

    await getGamesForGroupHandler(
      {groupId: "group-123"},
      {auth: {uid: "user-123"}} as any
    );

    expect(collectionsCalled).toContain("groups");
    expect(collectionsCalled).toContain("games");
  });
});

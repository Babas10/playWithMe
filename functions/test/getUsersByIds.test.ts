import functionsTest from "firebase-functions-test";
import {getUsersByIdsHandler} from "../src/getUsersByIds";

// Mock admin.firestore()
jest.mock("firebase-admin", () => {
  const mockFieldPath = {
    documentId: jest.fn(() => "__name__"),
  };

  const mockFirestore = {
    collection: jest.fn(),
  };

  return {
    firestore: Object.assign(
      jest.fn(() => mockFirestore),
      {
        FieldPath: mockFieldPath,
      }
    ),
    initializeApp: jest.fn(),
  };
});

// Initialize Firebase Functions test environment
const test = functionsTest();

// Get mockFirestore reference for test setup
const admin = require("firebase-admin");
const mockFirestore = admin.firestore();

describe("getUsersByIds", () => {
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
      userIds: ["user1", "user2"],
    };

    await expect(
      getUsersByIdsHandler(data, context as any)
    ).rejects.toThrow("User must be authenticated to fetch users");
  });

  it("should throw invalid-argument error when userIds is missing", async () => {
    const context = {
      auth: {uid: "requester123"},
    };

    const data = {};

    await expect(
      getUsersByIdsHandler(data as any, context as any)
    ).rejects.toThrow("userIds is required and must be an array");
  });

  it("should throw invalid-argument error when userIds is not an array", async () => {
    const context = {
      auth: {uid: "requester123"},
    };

    const data = {
      userIds: "not-an-array",
    };

    await expect(
      getUsersByIdsHandler(data as any, context as any)
    ).rejects.toThrow("userIds is required and must be an array");
  });

  it("should throw invalid-argument error when requesting more than 100 users", async () => {
    const context = {
      auth: {uid: "requester123"},
    };

    // Create array with 101 user IDs
    const userIds = Array.from({length: 101}, (_, i) => `user${i}`);

    const data = {
      userIds,
    };

    await expect(
      getUsersByIdsHandler(data, context as any)
    ).rejects.toThrow("Maximum 100 users can be fetched at once");
  });

  it("should return empty array when userIds is empty", async () => {
    const context = {
      auth: {uid: "requester123"},
    };

    const data = {
      userIds: [],
    };

    const result = await getUsersByIdsHandler(data, context as any);

    expect(result).toEqual({users: []});
  });

  it("should return array of user profiles for valid IDs", async () => {
    const context = {
      auth: {uid: "requester123"},
    };

    const data = {
      userIds: ["user1", "user2", "user3"],
    };

    // Mock Firestore query response
    const mockDocs = [
      {
        id: "user1",
        exists: true,
        data: () => ({
          displayName: "User One",
          email: "user1@example.com",
          photoUrl: "https://example.com/photo1.jpg",
          // Sensitive fields that should not be returned
          passwordHash: "secret",
          tokens: ["token1"],
        }),
      },
      {
        id: "user2",
        exists: true,
        data: () => ({
          displayName: "User Two",
          email: "user2@example.com",
          photoUrl: null,
        }),
      },
      {
        id: "user3",
        exists: true,
        data: () => ({
          displayName: null,
          email: "user3@example.com",
          photoUrl: null,
        }),
      },
    ];

    const mockGet = jest.fn().mockResolvedValue({
      docs: mockDocs,
    });

    const mockWhere = jest.fn().mockReturnValue({
      get: mockGet,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      where: mockWhere,
    });

    const result = await getUsersByIdsHandler(data, context as any);

    expect(result.users).toHaveLength(3);
    expect(result.users[0]).toEqual({
      uid: "user1",
      displayName: "User One",
      email: "user1@example.com",
      photoUrl: "https://example.com/photo1.jpg",
    });
    expect(result.users[1]).toEqual({
      uid: "user2",
      displayName: "User Two",
      email: "user2@example.com",
      photoUrl: null,
    });
    expect(result.users[2]).toEqual({
      uid: "user3",
      displayName: null,
      email: "user3@example.com",
      photoUrl: null,
    });

    // Verify sensitive fields are NOT returned
    expect(result.users[0]).not.toHaveProperty("passwordHash");
    expect(result.users[0]).not.toHaveProperty("tokens");
  });

  it("should filter out non-existent users", async () => {
    const context = {
      auth: {uid: "requester123"},
    };

    const data = {
      userIds: ["user1", "user2", "user3"],
    };

    // Mock Firestore query response with one non-existent user
    const mockDocs = [
      {
        id: "user1",
        exists: true,
        data: () => ({
          displayName: "User One",
          email: "user1@example.com",
          photoUrl: null,
        }),
      },
      {
        id: "user2",
        exists: false, // This user doesn't exist
        data: () => ({}),
      },
      {
        id: "user3",
        exists: true,
        data: () => ({
          displayName: "User Three",
          email: "user3@example.com",
          photoUrl: null,
        }),
      },
    ];

    const mockGet = jest.fn().mockResolvedValue({
      docs: mockDocs,
    });

    const mockWhere = jest.fn().mockReturnValue({
      get: mockGet,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      where: mockWhere,
    });

    const result = await getUsersByIdsHandler(data, context as any);

    // Should only return existing users
    expect(result.users).toHaveLength(2);
    expect(result.users.map((u) => u.uid)).toEqual(["user1", "user3"]);
  });

  it("should handle batching for more than 10 users", async () => {
    const context = {
      auth: {uid: "requester123"},
    };

    // Create 15 user IDs (will require 2 batches)
    const userIds = Array.from({length: 15}, (_, i) => `user${i}`);

    const data = {
      userIds,
    };

    // Mock Firestore query response for batch 1 (10 users)
    const mockDocs1 = Array.from({length: 10}, (_, i) => ({
      id: `user${i}`,
      exists: true,
      data: () => ({
        displayName: `User ${i}`,
        email: `user${i}@example.com`,
        photoUrl: null,
      }),
    }));

    // Mock Firestore query response for batch 2 (5 users)
    const mockDocs2 = Array.from({length: 5}, (_, i) => ({
      id: `user${i + 10}`,
      exists: true,
      data: () => ({
        displayName: `User ${i + 10}`,
        email: `user${i + 10}@example.com`,
        photoUrl: null,
      }),
    }));

    const mockGet = jest.fn()
      .mockResolvedValueOnce({docs: mockDocs1})
      .mockResolvedValueOnce({docs: mockDocs2});

    const mockWhere = jest.fn().mockReturnValue({
      get: mockGet,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      where: mockWhere,
    });

    const result = await getUsersByIdsHandler(data, context as any);

    expect(result.users).toHaveLength(15);
    expect(mockGet).toHaveBeenCalledTimes(2); // Verify batching occurred
  });

  it("should handle Firestore query failure gracefully", async () => {
    const context = {
      auth: {uid: "requester123"},
    };

    const data = {
      userIds: ["user1", "user2"],
    };

    // Mock Firestore query failure
    const mockGet = jest.fn().mockRejectedValue(new Error("Firestore error"));

    const mockWhere = jest.fn().mockReturnValue({
      get: mockGet,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      where: mockWhere,
    });

    await expect(
      getUsersByIdsHandler(data, context as any)
    ).rejects.toThrow("Failed to fetch users");
  });
});

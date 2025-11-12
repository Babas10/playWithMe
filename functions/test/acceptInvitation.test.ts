import functionsTest from "firebase-functions-test";
import {acceptInvitationHandler} from "../src/acceptInvitation";

// Mock checkFriendship from friendships module
jest.mock("../src/friendships", () => ({
  checkFriendship: jest.fn(),
}));

// Mock admin.firestore()
jest.mock("firebase-admin", () => {
  const mockFieldValue = {
    serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
    arrayUnion: jest.fn((...elements) => ({_type: "arrayUnion", elements})),
  };

  const mockFirestore = {
    collection: jest.fn(),
    batch: jest.fn(),
  };

  return {
    firestore: Object.assign(
      jest.fn(() => mockFirestore),
      {
        FieldValue: mockFieldValue,
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

// Get mock checkFriendship
const {checkFriendship} = require("../src/friendships");

describe("acceptInvitation", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Default: mock checkFriendship to return true (users are friends)
    (checkFriendship as jest.Mock).mockResolvedValue(true);
  });

  afterAll(() => {
    test.cleanup();
  });

  it("should throw unauthenticated error when user is not authenticated", async () => {
    const context = {
      auth: null,
    };

    const data = {
      invitationId: "invitation123",
    };

    await expect(
      acceptInvitationHandler(data, context as any)
    ).rejects.toThrow("User must be authenticated to accept invitations");
  });

  it("should throw invalid-argument error when invitationId is missing", async () => {
    const context = {
      auth: {uid: "user123"},
    };

    const data = {};

    await expect(
      acceptInvitationHandler(data as any, context as any)
    ).rejects.toThrow("invitationId is required and must be a string");
  });

  it("should throw invalid-argument error when invitationId is not a string", async () => {
    const context = {
      auth: {uid: "user123"},
    };

    const data = {
      invitationId: 123,
    };

    await expect(
      acceptInvitationHandler(data as any, context as any)
    ).rejects.toThrow("invitationId is required and must be a string");
  });

  it("should throw not-found error when invitation does not exist", async () => {
    const context = {
      auth: {uid: "user123"},
    };

    const data = {
      invitationId: "invitation123",
    };

    // Mock invitation not found
    const mockGet = jest.fn().mockResolvedValue({
      exists: false,
    });

    const mockDoc = jest.fn().mockReturnValue({
      get: mockGet,
    });

    const mockCollection2 = jest.fn().mockReturnValue({
      doc: mockDoc,
    });

    const mockDoc2 = jest.fn().mockReturnValue({
      collection: mockCollection2,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      doc: mockDoc2,
    });

    await expect(
      acceptInvitationHandler(data, context as any)
    ).rejects.toThrow("Invitation not found");
  });

  it("should throw failed-precondition error when invitation is not pending", async () => {
    const context = {
      auth: {uid: "user123"},
    };

    const data = {
      invitationId: "invitation123",
    };

    // Mock invitation with non-pending status
    const mockGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({
        status: "accepted",
        invitedUserId: "user123",
        groupId: "group456",
      }),
    });

    const mockDoc = jest.fn().mockReturnValue({
      get: mockGet,
    });

    const mockCollection2 = jest.fn().mockReturnValue({
      doc: mockDoc,
    });

    const mockDoc2 = jest.fn().mockReturnValue({
      collection: mockCollection2,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      doc: mockDoc2,
    });

    await expect(
      acceptInvitationHandler(data, context as any)
    ).rejects.toThrow("Invitation is not pending");
  });

  it("should throw permission-denied error when invitation is for different user", async () => {
    const context = {
      auth: {uid: "user123"},
    };

    const data = {
      invitationId: "invitation123",
    };

    // Mock invitation for different user
    const mockGet = jest.fn().mockResolvedValue({
      exists: true,
      data: () => ({
        status: "pending",
        invitedUserId: "differentUser",
        groupId: "group456",
        groupName: "Test Group",
      }),
    });

    const mockDoc = jest.fn().mockReturnValue({
      get: mockGet,
    });

    const mockCollection2 = jest.fn().mockReturnValue({
      doc: mockDoc,
    });

    const mockDoc2 = jest.fn().mockReturnValue({
      collection: mockCollection2,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      doc: mockDoc2,
    });

    await expect(
      acceptInvitationHandler(data, context as any)
    ).rejects.toThrow("This invitation is not for you");
  });

  it("should successfully accept invitation and add user to group", async () => {
    const context = {
      auth: {uid: "user123"},
    };

    const data = {
      invitationId: "invitation123",
    };

    // Mock invitation document
    const mockInvitationRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          status: "pending",
          invitedUserId: "user123",
          groupId: "group456",
          groupName: "Test Group",
        }),
      }),
    };

    // Mock batch operations
    const mockBatch = {
      update: jest.fn(),
      commit: jest.fn().mockResolvedValue(undefined),
    };

    mockFirestore.batch = jest.fn().mockReturnValue(mockBatch);

    // Mock collection/doc structure
    const mockDoc = jest.fn((docId) => {
      if (docId === "invitation123") {
        return mockInvitationRef;
      }
      return {doc: jest.fn()};
    });

    const mockCollection2 = jest.fn().mockReturnValue({
      doc: mockDoc,
    });

    const mockDoc2 = jest.fn().mockReturnValue({
      collection: mockCollection2,
    });

    mockFirestore.collection = jest.fn((collectionName) => {
      if (collectionName === "users") {
        return {doc: mockDoc2};
      } else if (collectionName === "groups") {
        return {doc: jest.fn()};
      }
      return {doc: jest.fn()};
    });

    const result = await acceptInvitationHandler(data, context as any);

    expect(result).toEqual({
      success: true,
      groupId: "group456",
      message: "Successfully joined Test Group",
    });

    expect(mockBatch.update).toHaveBeenCalledTimes(2);
    expect(mockBatch.commit).toHaveBeenCalledTimes(1);
  });

  it("should handle atomic transaction failure gracefully", async () => {
    const context = {
      auth: {uid: "user123"},
    };

    const data = {
      invitationId: "invitation123",
    };

    // Mock invitation document
    const mockInvitationRef = {
      get: jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          status: "pending",
          invitedUserId: "user123",
          groupId: "group456",
          groupName: "Test Group",
        }),
      }),
    };

    // Mock batch operations with failure
    const mockBatch = {
      update: jest.fn(),
      commit: jest.fn().mockRejectedValue(new Error("Transaction failed")),
    };

    mockFirestore.batch = jest.fn().mockReturnValue(mockBatch);

    // Mock collection/doc structure
    const mockDoc = jest.fn((docId) => {
      if (docId === "invitation123") {
        return mockInvitationRef;
      }
      return {doc: jest.fn()};
    });

    const mockCollection2 = jest.fn().mockReturnValue({
      doc: mockDoc,
    });

    const mockDoc2 = jest.fn().mockReturnValue({
      collection: mockCollection2,
    });

    mockFirestore.collection = jest.fn((collectionName) => {
      if (collectionName === "users") {
        return {doc: mockDoc2};
      } else if (collectionName === "groups") {
        return {doc: jest.fn()};
      }
      return {doc: jest.fn()};
    });

    await expect(
      acceptInvitationHandler(data, context as any)
    ).rejects.toThrow("Failed to accept invitation");
  });
});

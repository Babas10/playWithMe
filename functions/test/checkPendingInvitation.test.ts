import functionsTest from "firebase-functions-test";
import {checkPendingInvitationHandler} from "../src/checkPendingInvitation";

// Initialize Firebase Functions test environment
const test = functionsTest();

// Mock Firestore
const mockFirestore = {
  collection: jest.fn(),
};

// Mock admin.firestore()
jest.mock("firebase-admin", () => ({
  firestore: jest.fn(() => mockFirestore),
  initializeApp: jest.fn(),
}));

describe("checkPendingInvitation", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterAll(() => {
    test.cleanup();
  });

  it("should throw unauthenticated error when user is not authenticated", async () => {
    // Mock unauthenticated context
    const context = {
      auth: null,
    };

    const data = {
      targetUserId: "user123",
      groupId: "group456",
    };

    await expect(
      checkPendingInvitationHandler(data, context as any)
    ).rejects.toThrow("User must be authenticated to check for pending invitations");
  });

  it("should throw invalid-argument error when targetUserId is missing", async () => {
    const context = {
      auth: {uid: "caller123"},
    };

    const data = {
      groupId: "group456",
    };

    await expect(
      checkPendingInvitationHandler(data as any, context as any)
    ).rejects.toThrow("is required and must be a string");
  });

  it("should throw invalid-argument error when groupId is missing", async () => {
    const context = {
      auth: {uid: "caller123"},
    };

    const data = {
      targetUserId: "user123",
    };

    await expect(
      checkPendingInvitationHandler(data as any, context as any)
    ).rejects.toThrow("is required and must be a string");
  });

  it("should return exists: true when pending invitation exists", async () => {
    const context = {
      auth: {uid: "caller123"},
    };

    const data = {
      targetUserId: "user123",
      groupId: "group456",
    };

    // Mock Firestore query chain
    const mockGet = jest.fn().mockResolvedValue({
      empty: false, // Invitation exists
    });

    const mockLimit = jest.fn().mockReturnValue({
      get: mockGet,
    });

    const mockWhere2 = jest.fn().mockReturnValue({
      limit: mockLimit,
    });

    const mockWhere1 = jest.fn().mockReturnValue({
      where: mockWhere2,
    });

    const mockCollection = jest.fn().mockReturnValue({
      where: mockWhere1,
    });

    const mockDoc = jest.fn().mockReturnValue({
      collection: mockCollection,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      doc: mockDoc,
    });

    const result = await checkPendingInvitationHandler(data, context as any);

    expect(result).toEqual({exists: true});
    expect(mockFirestore.collection).toHaveBeenCalledWith("users");
    expect(mockDoc).toHaveBeenCalledWith("user123");
    expect(mockCollection).toHaveBeenCalledWith("invitations");
    expect(mockWhere1).toHaveBeenCalledWith("groupId", "==", "group456");
    expect(mockWhere2).toHaveBeenCalledWith("status", "==", "pending");
    expect(mockLimit).toHaveBeenCalledWith(1);
  });

  it("should return exists: false when no pending invitation exists", async () => {
    const context = {
      auth: {uid: "caller123"},
    };

    const data = {
      targetUserId: "user123",
      groupId: "group456",
    };

    // Mock Firestore query chain
    const mockGet = jest.fn().mockResolvedValue({
      empty: true, // No invitation
    });

    const mockLimit = jest.fn().mockReturnValue({
      get: mockGet,
    });

    const mockWhere2 = jest.fn().mockReturnValue({
      limit: mockLimit,
    });

    const mockWhere1 = jest.fn().mockReturnValue({
      where: mockWhere2,
    });

    const mockCollection = jest.fn().mockReturnValue({
      where: mockWhere1,
    });

    const mockDoc = jest.fn().mockReturnValue({
      collection: mockCollection,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      doc: mockDoc,
    });

    const result = await checkPendingInvitationHandler(data, context as any);

    expect(result).toEqual({exists: false});
  });

  it("should throw internal error when Firestore query fails", async () => {
    const context = {
      auth: {uid: "caller123"},
    };

    const data = {
      targetUserId: "user123",
      groupId: "group456",
    };

    // Mock Firestore query to throw error
    const mockGet = jest.fn().mockRejectedValue(new Error("Firestore error"));

    const mockLimit = jest.fn().mockReturnValue({
      get: mockGet,
    });

    const mockWhere2 = jest.fn().mockReturnValue({
      limit: mockLimit,
    });

    const mockWhere1 = jest.fn().mockReturnValue({
      where: mockWhere2,
    });

    const mockCollection = jest.fn().mockReturnValue({
      where: mockWhere1,
    });

    const mockDoc = jest.fn().mockReturnValue({
      collection: mockCollection,
    });

    mockFirestore.collection = jest.fn().mockReturnValue({
      doc: mockDoc,
    });

    await expect(
      checkPendingInvitationHandler(data, context as any)
    ).rejects.toThrow("Failed to check for pending invitation");
  });
});

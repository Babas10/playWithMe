// Unit tests for getPublicUserProfile Cloud Function

// Mock functions logger (must be defined before mocking)
const mockLogger = {
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};

// Mock Firestore
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
}));

jest.mock("firebase-functions", () => ({
  https: {
    HttpsError: class HttpsError extends Error {
      constructor(public code: string, message: string) {
        super(message);
        this.name = "HttpsError";
      }
    },
    onCall: jest.fn((handler) => handler),
  },
  logger: mockLogger,
}));

import {getPublicUserProfileHandler} from "../../src/getPublicUserProfile";

describe("getPublicUserProfileHandler", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("Authentication", () => {
    it("should throw unauthenticated error when user is not logged in", async () => {
      const context = {auth: undefined};

      await expect(
        getPublicUserProfileHandler(
          {userId: "test-user-123"},
          context as any
        )
      ).rejects.toThrow("User must be authenticated");
    });
  });

  describe("Input Validation", () => {
    it("should throw invalid-argument when userId is missing", async () => {
      const context = {auth: {uid: "current-user"}};

      await expect(
        getPublicUserProfileHandler({userId: "" as any}, context as any)
      ).rejects.toThrow("userId is required");
    });

    it("should throw invalid-argument when userId is not a string", async () => {
      const context = {auth: {uid: "current-user"}};

      await expect(
        getPublicUserProfileHandler({userId: 123 as any}, context as any)
      ).rejects.toThrow("userId is required");
    });
  });

  describe("User Fetching", () => {
    it("should return null when user does not exist", async () => {
      const context = {auth: {uid: "current-user"}};

      mockGet.mockResolvedValue({
        exists: false,
      });

      const result = await getPublicUserProfileHandler(
        {userId: "non-existent-user"},
        context as any
      );

      expect(result).toEqual({user: null});
      expect(mockCollection).toHaveBeenCalledWith("users");
      expect(mockDoc).toHaveBeenCalledWith("non-existent-user");
    });

    it("should return public profile when user exists", async () => {
      const context = {auth: {uid: "current-user"}};

      mockGet.mockResolvedValue({
        exists: true,
        id: "test-user-123",
        data: () => ({
          displayName: "John Doe",
          email: "john@example.com",
          photoUrl: "https://example.com/photo.jpg",
          firstName: "John",
          lastName: "Doe",
          // Private fields that should NOT be returned
          isEmailVerified: true,
          notificationsEnabled: true,
          privacyLevel: "public",
        }),
      });

      const result = await getPublicUserProfileHandler(
        {userId: "test-user-123"},
        context as any
      );

      expect(result).toEqual({
        user: {
          uid: "test-user-123",
          displayName: "John Doe",
          email: "john@example.com",
          photoUrl: "https://example.com/photo.jpg",
          firstName: "John",
          lastName: "Doe",
        },
      });

      // Verify private fields are NOT included
      expect((result.user as any).isEmailVerified).toBeUndefined();
      expect((result.user as any).notificationsEnabled).toBeUndefined();
      expect((result.user as any).privacyLevel).toBeUndefined();
    });

    it("should handle missing optional fields gracefully", async () => {
      const context = {auth: {uid: "current-user"}};

      mockGet.mockResolvedValue({
        exists: true,
        id: "test-user-456",
        data: () => ({
          email: "user@example.com",
          // All optional fields missing
        }),
      });

      const result = await getPublicUserProfileHandler(
        {userId: "test-user-456"},
        context as any
      );

      expect(result).toEqual({
        user: {
          uid: "test-user-456",
          displayName: null,
          email: "user@example.com",
          photoUrl: null,
          firstName: null,
          lastName: null,
        },
      });
    });

    it("should return null when user document has no data", async () => {
      const context = {auth: {uid: "current-user"}};

      mockGet.mockResolvedValue({
        exists: true,
        id: "test-user-789",
        data: () => undefined, // No data
      });

      const result = await getPublicUserProfileHandler(
        {userId: "test-user-789"},
        context as any
      );

      expect(result).toEqual({user: null});
    });
  });

  describe("Error Handling", () => {
    it("should throw internal error when Firestore query fails", async () => {
      const context = {auth: {uid: "current-user"}};

      mockGet.mockRejectedValue(new Error("Firestore connection failed"));

      await expect(
        getPublicUserProfileHandler({userId: "test-user"}, context as any)
      ).rejects.toThrow("Failed to fetch user profile");

      expect(mockLogger.error).toHaveBeenCalledWith(
        "Error fetching public user profile",
        expect.objectContaining({
          currentUserId: "current-user",
          requestedUserId: "test-user",
          error: "Firestore connection failed",
        })
      );
    });
  });

  describe("Logging", () => {
    it("should log info when successfully fetching user", async () => {
      const context = {auth: {uid: "current-user"}};

      mockGet.mockResolvedValue({
        exists: true,
        id: "test-user",
        data: () => ({
          email: "test@example.com",
          displayName: "Test User",
        }),
      });

      await getPublicUserProfileHandler(
        {userId: "test-user"},
        context as any
      );

      expect(mockLogger.info).toHaveBeenCalledWith(
        "Fetching public user profile",
        {
          currentUserId: "current-user",
          requestedUserId: "test-user",
        }
      );

      expect(mockLogger.info).toHaveBeenCalledWith(
        "Public user profile fetched successfully",
        {
          currentUserId: "current-user",
          requestedUserId: "test-user",
        }
      );
    });

    it("should log warning when user not found", async () => {
      const context = {auth: {uid: "current-user"}};

      mockGet.mockResolvedValue({
        exists: false,
      });

      await getPublicUserProfileHandler(
        {userId: "non-existent"},
        context as any
      );

      expect(mockLogger.warn).toHaveBeenCalledWith("User not found", {
        currentUserId: "current-user",
        requestedUserId: "non-existent",
      });
    });
  });
});

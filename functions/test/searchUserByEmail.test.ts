// Unit tests for searchUserByEmail Cloud Function
import functionsTest from "firebase-functions-test";
import {searchUserByEmailHandler} from "../src/searchUserByEmail";

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

describe("searchUserByEmail", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterAll(() => {
    test.cleanup();
  });

  describe("Authentication", () => {
    it("should throw unauthenticated error when user is not logged in", async () => {
      const context = {auth: undefined} as any;
      const data = {email: "test@example.com"};

      await expect(
        searchUserByEmailHandler(data, context)
      ).rejects.toThrow("User must be authenticated to search for users");
    });
  });

  describe("Input Validation", () => {
    const mockContext = {
      auth: {uid: "test-user-123"},
    } as any;

    it("should throw error when email is missing", async () => {
      const data = {} as any;

      await expect(
        searchUserByEmailHandler(data, mockContext)
      ).rejects.toThrow("Email parameter is required and must be a string");
    });

    it("should throw error when email is not a string", async () => {
      const data = {email: 123} as any;

      await expect(
        searchUserByEmailHandler(data, mockContext)
      ).rejects.toThrow("Email parameter is required and must be a string");
    });

    it("should throw error when email is empty", async () => {
      const data = {email: "   "};

      await expect(
        searchUserByEmailHandler(data, mockContext)
      ).rejects.toThrow("Email cannot be empty");
    });

    it("should throw error when email format is invalid", async () => {
      const data = {email: "not-an-email"};

      await expect(
        searchUserByEmailHandler(data, mockContext)
      ).rejects.toThrow("Invalid email format");
    });
  });

  describe("User Search", () => {
    const mockContext = {
      auth: {uid: "test-user-123"},
    } as any;

    it("should return found: false when user does not exist", async () => {
      const data = {email: "nonexistent@example.com"};

      // Mock empty Firestore query result
      const mockGet = jest.fn().mockResolvedValue({
        empty: true,
        docs: [],
      });

      const mockLimit = jest.fn().mockReturnValue({
        get: mockGet,
      });

      const mockWhere = jest.fn().mockReturnValue({
        limit: mockLimit,
      });

      const mockCollection = jest.fn().mockReturnValue({
        where: mockWhere,
      });

      mockFirestore.collection = mockCollection;

      const result = await searchUserByEmailHandler(data, mockContext);

      expect(result).toEqual({found: false});
      expect(mockCollection).toHaveBeenCalledWith("users");
      expect(mockWhere).toHaveBeenCalledWith("email", "==", "nonexistent@example.com");
    });

    it("should return user data when user exists", async () => {
      const data = {email: "testuser@example.com"};

      // Mock Firestore query result with user
      const mockUserDoc = {
        id: "user123",
        data: () => ({
          email: "testuser@example.com",
          displayName: "Test User",
          photoUrl: "https://example.com/photo.jpg",
        }),
      };

      const mockGet = jest.fn().mockResolvedValue({
        empty: false,
        docs: [mockUserDoc],
      });

      const mockLimit = jest.fn().mockReturnValue({
        get: mockGet,
      });

      const mockWhere = jest.fn().mockReturnValue({
        limit: mockLimit,
      });

      const mockCollection = jest.fn().mockReturnValue({
        where: mockWhere,
      });

      mockFirestore.collection = mockCollection;

      const result = await searchUserByEmailHandler(data, mockContext);

      expect(result.found).toBe(true);
      expect(result.user).toEqual({
        uid: "user123",
        displayName: "Test User",
        email: "testuser@example.com",
        photoUrl: "https://example.com/photo.jpg",
      });
    });

    it("should normalize email (trim and lowercase)", async () => {
      const data = {email: "  TESTUSER@EXAMPLE.COM  "};

      // Mock Firestore query result
      const mockUserDoc = {
        id: "user123",
        data: () => ({
          email: "testuser@example.com",
          displayName: "Test User",
          photoUrl: null,
        }),
      };

      const mockGet = jest.fn().mockResolvedValue({
        empty: false,
        docs: [mockUserDoc],
      });

      const mockLimit = jest.fn().mockReturnValue({
        get: mockGet,
      });

      const mockWhere = jest.fn().mockReturnValue({
        limit: mockLimit,
      });

      const mockCollection = jest.fn().mockReturnValue({
        where: mockWhere,
      });

      mockFirestore.collection = mockCollection;

      const result = await searchUserByEmailHandler(data, mockContext);

      expect(result.found).toBe(true);
      expect(result.user?.email).toBe("testuser@example.com");
      // Verify email was normalized before query
      expect(mockWhere).toHaveBeenCalledWith("email", "==", "testuser@example.com");
    });

    it("should return null for missing optional fields", async () => {
      const data = {email: "minimal@example.com"};

      // Mock user without optional fields
      const mockUserDoc = {
        id: "user123",
        data: () => ({
          email: "minimal@example.com",
        }),
      };

      const mockGet = jest.fn().mockResolvedValue({
        empty: false,
        docs: [mockUserDoc],
      });

      const mockLimit = jest.fn().mockReturnValue({
        get: mockGet,
      });

      const mockWhere = jest.fn().mockReturnValue({
        limit: mockLimit,
      });

      const mockCollection = jest.fn().mockReturnValue({
        where: mockWhere,
      });

      mockFirestore.collection = mockCollection;

      const result = await searchUserByEmailHandler(data, mockContext);

      expect(result.found).toBe(true);
      expect(result.user?.displayName).toBeNull();
      expect(result.user?.photoUrl).toBeNull();
    });

    it("should not return sensitive fields", async () => {
      const data = {email: "secure@example.com"};

      // Mock user with sensitive data
      const mockUserDoc = {
        id: "user123",
        data: () => ({
          email: "secure@example.com",
          displayName: "Secure User",
          photoUrl: null,
          password: "should-not-be-returned",
          adminRole: true,
          privateData: "secret",
        }),
      };

      const mockGet = jest.fn().mockResolvedValue({
        empty: false,
        docs: [mockUserDoc],
      });

      const mockLimit = jest.fn().mockReturnValue({
        get: mockGet,
      });

      const mockWhere = jest.fn().mockReturnValue({
        limit: mockLimit,
      });

      const mockCollection = jest.fn().mockReturnValue({
        where: mockWhere,
      });

      mockFirestore.collection = mockCollection;

      const result = await searchUserByEmailHandler(data, mockContext);

      expect(result.found).toBe(true);
      expect(result.user).not.toHaveProperty("password");
      expect(result.user).not.toHaveProperty("adminRole");
      expect(result.user).not.toHaveProperty("privateData");

      // Only expected fields should be present
      expect(Object.keys(result.user!)).toEqual([
        "uid",
        "displayName",
        "email",
        "photoUrl",
      ]);
    });

    it("should handle Firestore query failure", async () => {
      const data = {email: "test@example.com"};

      // Mock Firestore query failure
      const mockGet = jest.fn().mockRejectedValue(new Error("Firestore error"));

      const mockLimit = jest.fn().mockReturnValue({
        get: mockGet,
      });

      const mockWhere = jest.fn().mockReturnValue({
        limit: mockLimit,
      });

      const mockCollection = jest.fn().mockReturnValue({
        where: mockWhere,
      });

      mockFirestore.collection = mockCollection;

      await expect(
        searchUserByEmailHandler(data, mockContext)
      ).rejects.toThrow("An error occurred while searching for the user");
    });
  });
});

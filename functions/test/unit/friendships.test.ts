// Unit tests for friendship Cloud Functions
import functionsTest from "firebase-functions-test";
import {
  sendFriendRequestHandler,
  acceptFriendRequestHandler,
  declineFriendRequestHandler,
  removeFriendHandler,
  getFriendsHandler,
  checkFriendshipStatusHandler,
} from "../../src/friendships";
import {createMockFirestore} from "../helpers/mockFirestore";

// Mock Firebase Admin
jest.mock("firebase-admin", () => {
  const firestoreMock: any = jest.fn();
  firestoreMock.FieldValue = {
    serverTimestamp: jest.fn(() => new Date()),
  };
  firestoreMock.FieldPath = {
    documentId: jest.fn(() => "__name__"),
  };
  return {
    firestore: firestoreMock,
    initializeApp: jest.fn(),
  };
});

// Initialize Firebase Functions test environment
const test = functionsTest();

// Get admin reference
const admin = require("firebase-admin");

describe("Friendship Cloud Functions", () => {
  let mockContext: any;

  beforeEach(() => {
    jest.clearAllMocks();
    mockContext = {
      auth: {uid: "user1"},
    };
  });

  afterAll(() => {
    test.cleanup();
  });

  // ===========================================================================
  // sendFriendRequest Tests
  // ===========================================================================

  describe("sendFriendRequest", () => {
    it("should throw error if user is not authenticated", async () => {
      await expect(
        sendFriendRequestHandler({targetUserId: "user2"}, {auth: undefined} as any)
      ).rejects.toThrow();
    });

    it("should throw error if targetUserId is missing", async () => {
      await expect(
        sendFriendRequestHandler({} as any, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if trying to friend yourself", async () => {
      await expect(
        sendFriendRequestHandler({targetUserId: "user1"}, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if target user does not exist", async () => {
      const mockFirestore = createMockFirestore({
        users: {
          user2: {exists: false},
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        sendFriendRequestHandler({targetUserId: "user2"}, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if users are already friends", async () => {
      const mockFirestore = createMockFirestore({
        users: {
          user1: {exists: true, data: {displayName: "User 1", email: "user1@example.com"}},
          user2: {exists: true, data: {displayName: "User 2", email: "user2@example.com"}},
        },
        friendships: {
          empty: false,
          docs: [{data: () => ({status: "accepted"})}],
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        sendFriendRequestHandler({targetUserId: "user2"}, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if pending request exists", async () => {
      const mockFirestore = createMockFirestore({
        users: {
          user1: {exists: true, data: {displayName: "User 1", email: "user1@example.com"}},
          user2: {exists: true, data: {displayName: "User 2", email: "user2@example.com"}},
        },
        friendships: {
          empty: false,
          docs: [{data: () => ({status: "pending"})}],
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        sendFriendRequestHandler({targetUserId: "user2"}, mockContext)
      ).rejects.toThrow();
    });

    it("should successfully create friend request", async () => {
      const mockFirestore = createMockFirestore({
        users: {
          user1: {exists: true, data: {displayName: "User 1", email: "user1@example.com"}},
          user2: {exists: true, data: {displayName: "User 2", email: "user2@example.com"}},
        },
        friendships: {
          empty: true,
          addResult: {id: "friendship123"},
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await sendFriendRequestHandler({targetUserId: "user2"}, mockContext);

      expect(result).toEqual({
        success: true,
        friendshipId: "friendship123",
      });
    });

    it("should allow creating new request if previous was declined", async () => {
      const mockFirestore = createMockFirestore({
        users: {
          user1: {exists: true, data: {displayName: "User 1", email: "user1@example.com"}},
          user2: {exists: true, data: {displayName: "User 2", email: "user2@example.com"}},
        },
        friendships: {
          empty: false,
          docs: [{data: () => ({status: "declined"})}],
          addResult: {id: "friendship456"},
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await sendFriendRequestHandler({targetUserId: "user2"}, mockContext);

      expect(result.success).toBe(true);
    });
  });

  // ===========================================================================
  // acceptFriendRequest Tests
  // ===========================================================================

  describe("acceptFriendRequest", () => {
    it("should throw error if user is not authenticated", async () => {
      await expect(
        acceptFriendRequestHandler({friendshipId: "friendship123"}, {auth: undefined} as any)
      ).rejects.toThrow();
    });

    it("should throw error if friendshipId is missing", async () => {
      await expect(
        acceptFriendRequestHandler({} as any, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if friendship does not exist", async () => {
      const mockFirestore = createMockFirestore({
        transaction: {
          get: jest.fn().mockResolvedValue({exists: false}),
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        acceptFriendRequestHandler({friendshipId: "friendship123"}, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if user is not the recipient", async () => {
      const mockFirestore = createMockFirestore({
        transaction: {
          get: jest.fn().mockResolvedValue({
            exists: true,
            data: () => ({
              initiatorId: "user1",
              recipientId: "user3",
              status: "pending",
            }),
          }),
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        acceptFriendRequestHandler({friendshipId: "friendship123"}, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if friendship is not pending", async () => {
      const mockFirestore = createMockFirestore({
        transaction: {
          get: jest.fn().mockResolvedValue({
            exists: true,
            data: () => ({
              initiatorId: "user2",
              recipientId: "user1",
              status: "accepted",
            }),
          }),
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        acceptFriendRequestHandler({friendshipId: "friendship123"}, mockContext)
      ).rejects.toThrow();
    });

    it("should successfully accept a valid pending friend request", async () => {
      const mockUpdate = jest.fn().mockResolvedValue(undefined);
      const mockFirestore = createMockFirestore({
        transaction: {
          get: jest.fn().mockResolvedValue({
            exists: true,
            data: () => ({
              initiatorId: "user2",
              recipientId: "user1",
              status: "pending",
            }),
          }),
          update: mockUpdate,
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await acceptFriendRequestHandler({friendshipId: "friendship123"}, mockContext);

      expect(result).toEqual({success: true});
      expect(mockUpdate).toHaveBeenCalled();
    });
  });

  // ===========================================================================
  // declineFriendRequest Tests
  // ===========================================================================

  describe("declineFriendRequest", () => {
    it("should throw error if user is not authenticated", async () => {
      await expect(
        declineFriendRequestHandler({friendshipId: "friendship123"}, {auth: undefined} as any)
      ).rejects.toThrow();
    });

    it("should throw error if friendshipId is missing", async () => {
      await expect(
        declineFriendRequestHandler({} as any, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if friendship does not exist", async () => {
      const mockFirestore = createMockFirestore({
        transaction: {
          get: jest.fn().mockResolvedValue({exists: false}),
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        declineFriendRequestHandler({friendshipId: "friendship123"}, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if user is not the recipient", async () => {
      const mockFirestore = createMockFirestore({
        transaction: {
          get: jest.fn().mockResolvedValue({
            exists: true,
            data: () => ({
              initiatorId: "user1",
              recipientId: "user3",
              status: "pending",
            }),
          }),
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        declineFriendRequestHandler({friendshipId: "friendship123"}, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if friendship is not pending", async () => {
      const mockFirestore = createMockFirestore({
        transaction: {
          get: jest.fn().mockResolvedValue({
            exists: true,
            data: () => ({
              initiatorId: "user2",
              recipientId: "user1",
              status: "declined",
            }),
          }),
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        declineFriendRequestHandler({friendshipId: "friendship123"}, mockContext)
      ).rejects.toThrow();
    });

    it("should successfully decline a valid pending friend request", async () => {
      const mockUpdate = jest.fn().mockResolvedValue(undefined);
      const mockFirestore = createMockFirestore({
        transaction: {
          get: jest.fn().mockResolvedValue({
            exists: true,
            data: () => ({
              initiatorId: "user2",
              recipientId: "user1",
              status: "pending",
            }),
          }),
          update: mockUpdate,
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await declineFriendRequestHandler({friendshipId: "friendship123"}, mockContext);

      expect(result).toEqual({success: true});
      expect(mockUpdate).toHaveBeenCalled();
    });
  });

  // ===========================================================================
  // removeFriend Tests
  // ===========================================================================

  describe("removeFriend", () => {
    it("should throw error if user is not authenticated", async () => {
      await expect(
        removeFriendHandler({friendshipId: "friendship123"}, {auth: undefined} as any)
      ).rejects.toThrow();
    });

    it("should throw error if friendshipId is missing", async () => {
      await expect(
        removeFriendHandler({} as any, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if friendship does not exist", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {exists: false},
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        removeFriendHandler({friendshipId: "friendship123"}, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if user is not involved in friendship", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {
          exists: true,
          docs: [
            {
              data: () => ({
                initiatorId: "user2",
                recipientId: "user3",
              }),
            },
          ],
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        removeFriendHandler({friendshipId: "friendship123"}, mockContext)
      ).rejects.toThrow();
    });

    it("should successfully remove friendship if user is initiator", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {
          exists: true,
          docs: [
            {
              data: () => ({
                initiatorId: "user1",
                recipientId: "user2",
              }),
            },
          ],
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await removeFriendHandler({friendshipId: "friendship123"}, mockContext);

      expect(result).toEqual({success: true});
    });

    it("should successfully remove friendship if user is recipient", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {
          exists: true,
          docs: [
            {
              data: () => ({
                initiatorId: "user2",
                recipientId: "user1",
              }),
            },
          ],
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await removeFriendHandler({friendshipId: "friendship123"}, mockContext);

      expect(result).toEqual({success: true});
    });
  });

  // ===========================================================================
  // getFriends Tests
  // ===========================================================================

  describe("getFriends", () => {
    it("should throw error if user is not authenticated", async () => {
      await expect(
        getFriendsHandler({}, {auth: undefined} as any)
      ).rejects.toThrow();
    });

    it("should throw error if trying to get another user's friends", async () => {
      await expect(
        getFriendsHandler({userId: "user2"}, mockContext)
      ).rejects.toThrow();
    });

    it("should return empty array if user has no friends", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {empty: true, docs: []},
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await getFriendsHandler({}, mockContext);

      expect(result).toEqual({friends: []});
    });

    it("should return friends list when user has accepted friendships", async () => {
      const mockFriendshipsCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn()
          .mockResolvedValueOnce({
            docs: [
              {data: () => ({initiatorId: "user1", recipientId: "user2", status: "accepted"})},
            ],
            empty: false,
          })
          .mockResolvedValueOnce({
            docs: [
              {data: () => ({initiatorId: "user3", recipientId: "user1", status: "accepted"})},
            ],
            empty: false,
          }),
      };

      const mockUsersCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn().mockResolvedValue({
          docs: [
            {
              id: "user2",
              data: () => ({
                email: "user2@example.com",
                displayName: "User 2",
                photoUrl: null,
              }),
            },
            {
              id: "user3",
              data: () => ({
                email: "user3@example.com",
                displayName: "User 3",
                photoUrl: "https://example.com/photo.jpg",
              }),
            },
          ],
        }),
      };

      const mockFirestore = {
        collection: jest.fn((name: string) => {
          if (name === "friendships") return mockFriendshipsCollection;
          if (name === "users") return mockUsersCollection;
          return {};
        }),
        FieldPath: {documentId: jest.fn(() => "__name__")},
      };

      admin.firestore.mockReturnValue(mockFirestore);

      const result = await getFriendsHandler({}, mockContext);

      expect(result.friends).toHaveLength(2);
      expect(result.friends).toEqual(
        expect.arrayContaining([
          {
            uid: "user2",
            displayName: "User 2",
            email: "user2@example.com",
            photoUrl: null,
          },
          {
            uid: "user3",
            displayName: "User 3",
            email: "user3@example.com",
            photoUrl: "https://example.com/photo.jpg",
          },
        ])
      );
    });

    it("should handle batch fetching for more than 10 friends", async () => {
      const friendIds = Array.from({length: 15}, (_, i) => `user${i + 2}`);

      const mockFriendshipsCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn()
          .mockResolvedValueOnce({
            docs: friendIds.map((id) => ({
              data: () => ({initiatorId: "user1", recipientId: id, status: "accepted"}),
            })),
            empty: false,
          })
          .mockResolvedValueOnce({docs: [], empty: true}),
      };

      const mockUsersCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn()
          .mockResolvedValueOnce({
            docs: friendIds.slice(0, 10).map((id) => ({
              id,
              data: () => ({email: `${id}@example.com`, displayName: id}),
            })),
          })
          .mockResolvedValueOnce({
            docs: friendIds.slice(10).map((id) => ({
              id,
              data: () => ({email: `${id}@example.com`, displayName: id}),
            })),
          }),
      };

      const mockFirestore = {
        collection: jest.fn((name: string) => {
          if (name === "friendships") return mockFriendshipsCollection;
          if (name === "users") return mockUsersCollection;
          return {};
        }),
        FieldPath: {documentId: jest.fn(() => "__name__")},
      };

      admin.firestore.mockReturnValue(mockFirestore);

      const result = await getFriendsHandler({}, mockContext);

      expect(result.friends).toHaveLength(15);
    });
  });

  // ===========================================================================
  // checkFriendshipStatus Tests
  // ===========================================================================

  describe("checkFriendshipStatus", () => {
    it("should throw error if user is not authenticated", async () => {
      await expect(
        checkFriendshipStatusHandler({userId: "user2"}, {auth: undefined} as any)
      ).rejects.toThrow();
    });

    it("should throw error if userId is missing", async () => {
      await expect(
        checkFriendshipStatusHandler({} as any, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if checking friendship with yourself", async () => {
      await expect(
        checkFriendshipStatusHandler({userId: "user1"}, mockContext)
      ).rejects.toThrow();
    });

    it("should return no friendship if none exists", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {empty: true, docs: []},
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await checkFriendshipStatusHandler({userId: "user2"}, mockContext);

      expect(result).toEqual({
        isFriend: false,
        hasPendingRequest: false,
      });
    });

    it("should return isFriend=true if friendship is accepted", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {
          empty: false,
          docs: [
            {
              data: () => ({
                initiatorId: "user1",
                recipientId: "user2",
                status: "accepted",
              }),
            },
          ],
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await checkFriendshipStatusHandler({userId: "user2"}, mockContext);

      expect(result).toEqual({
        isFriend: true,
        hasPendingRequest: false,
      });
    });

    it("should return pending request direction 'sent' if user initiated", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {
          empty: false,
          docs: [
            {
              data: () => ({
                initiatorId: "user1",
                recipientId: "user2",
                status: "pending",
              }),
            },
          ],
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await checkFriendshipStatusHandler({userId: "user2"}, mockContext);

      expect(result).toEqual({
        isFriend: false,
        hasPendingRequest: true,
        requestDirection: "sent",
      });
    });

    it("should return pending request direction 'received' if other user initiated", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {
          empty: false,
          docs: [
            {
              data: () => ({
                initiatorId: "user2",
                recipientId: "user1",
                status: "pending",
              }),
            },
          ],
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await checkFriendshipStatusHandler({userId: "user2"}, mockContext);

      expect(result).toEqual({
        isFriend: false,
        hasPendingRequest: true,
        requestDirection: "received",
      });
    });

    it("should return no friendship if status is declined", async () => {
      const mockFirestore = createMockFirestore({
        friendships: {
          empty: false,
          docs: [
            {
              data: () => ({
                initiatorId: "user1",
                recipientId: "user2",
                status: "declined",
              }),
            },
          ],
        },
      });
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await checkFriendshipStatusHandler({userId: "user2"}, mockContext);

      expect(result).toEqual({
        isFriend: false,
        hasPendingRequest: false,
      });
    });
  });
});

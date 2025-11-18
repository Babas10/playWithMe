// Unit tests for friendship Cloud Functions
import functionsTest from "firebase-functions-test";
import {
  sendFriendRequestHandler,
  acceptFriendRequestHandler,
  declineFriendRequestHandler,
  removeFriendHandler,
  getFriendsHandler,
  checkFriendshipStatusHandler,
  getFriendshipsHandler,
  verifyFriendshipHandler,
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
          expect.objectContaining({
            uid: "user2",
            displayName: "User 2",
            email: "user2@example.com",
            photoUrl: null,
          }),
          expect.objectContaining({
            uid: "user3",
            displayName: "User 3",
            email: "user3@example.com",
            photoUrl: "https://example.com/photo.jpg",
          }),
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
  // getFriendships Tests (Story 11.13)
  // ===========================================================================

  describe("getFriendships", () => {
    it("should throw error if user is not authenticated", async () => {
      await expect(
        getFriendshipsHandler({status: "pending"} as any, {auth: undefined} as any)
      ).rejects.toThrow();
    });

    it("should throw error if status is missing", async () => {
      await expect(
        getFriendshipsHandler({} as any, mockContext)
      ).rejects.toThrow();
    });

    it("should throw error if status is invalid", async () => {
      await expect(
        getFriendshipsHandler({status: "invalid"} as any, mockContext)
      ).rejects.toThrow();
    });

    it("should return empty array if user has no friendships with given status", async () => {
      const mockFriendshipsCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn()
          .mockResolvedValueOnce({docs: [], empty: true})
          .mockResolvedValueOnce({docs: [], empty: true}),
      };

      const mockFirestore = {
        collection: jest.fn(() => mockFriendshipsCollection),
      };

      admin.firestore.mockReturnValue(mockFirestore);

      const result = await getFriendshipsHandler({status: "pending"}, mockContext);

      expect(result).toEqual({friendships: []});
    });

    it("should return pending friendships with denormalized user info", async () => {
      const mockTimestamp = {toDate: () => new Date("2024-01-01")};

      const mockFriendshipsCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn()
          .mockResolvedValueOnce({
            docs: [
              {
                id: "friendship1",
                data: () => ({
                  initiatorId: "user1",
                  recipientId: "user2",
                  status: "pending",
                  createdAt: mockTimestamp,
                  updatedAt: mockTimestamp,
                }),
              },
            ],
            empty: false,
          })
          .mockResolvedValueOnce({
            docs: [
              {
                id: "friendship2",
                data: () => ({
                  initiatorId: "user3",
                  recipientId: "user1",
                  status: "pending",
                  createdAt: mockTimestamp,
                  updatedAt: mockTimestamp,
                }),
              },
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
                isEmailVerified: true,
                isAnonymous: false,
              }),
            },
            {
              id: "user3",
              data: () => ({
                email: "user3@example.com",
                displayName: "User 3",
                photoUrl: "https://example.com/photo.jpg",
                isEmailVerified: false,
                isAnonymous: false,
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

      const result = await getFriendshipsHandler({status: "pending"}, mockContext);

      expect(result.friendships).toHaveLength(2);
      expect(result.friendships).toEqual(
        expect.arrayContaining([
          expect.objectContaining({
            id: "friendship1",
            otherUser: expect.objectContaining({
              uid: "user2",
              displayName: "User 2",
              email: "user2@example.com",
            }),
            status: "pending",
            isInitiator: true,
          }),
          expect.objectContaining({
            id: "friendship2",
            otherUser: expect.objectContaining({
              uid: "user3",
              displayName: "User 3",
              email: "user3@example.com",
            }),
            status: "pending",
            isInitiator: false,
          }),
        ])
      );
    });

    it("should return accepted friendships", async () => {
      const mockTimestamp = {toDate: () => new Date("2024-01-01")};

      const mockFriendshipsCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn()
          .mockResolvedValueOnce({
            docs: [
              {
                id: "friendship1",
                data: () => ({
                  initiatorId: "user1",
                  recipientId: "user2",
                  status: "accepted",
                  createdAt: mockTimestamp,
                  updatedAt: mockTimestamp,
                }),
              },
            ],
            empty: false,
          })
          .mockResolvedValueOnce({docs: [], empty: true}),
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

      const result = await getFriendshipsHandler({status: "accepted"}, mockContext);

      expect(result.friendships).toHaveLength(1);
      expect(result.friendships[0].status).toBe("accepted");
      expect(result.friendships[0].isInitiator).toBe(true);
    });

    it("should return declined friendships", async () => {
      const mockTimestamp = {toDate: () => new Date("2024-01-01")};

      const mockFriendshipsCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn()
          .mockResolvedValueOnce({docs: [], empty: true})
          .mockResolvedValueOnce({
            docs: [
              {
                id: "friendship1",
                data: () => ({
                  initiatorId: "user2",
                  recipientId: "user1",
                  status: "declined",
                  createdAt: mockTimestamp,
                  updatedAt: mockTimestamp,
                }),
              },
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

      const result = await getFriendshipsHandler({status: "declined"}, mockContext);

      expect(result.friendships).toHaveLength(1);
      expect(result.friendships[0].status).toBe("declined");
      expect(result.friendships[0].isInitiator).toBe(false);
    });

    it("should handle batch fetching for more than 10 friendships", async () => {
      const mockTimestamp = {toDate: () => new Date("2024-01-01")};
      const friendIds = Array.from({length: 15}, (_, i) => `user${i + 2}`);

      const mockFriendshipsCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn()
          .mockResolvedValueOnce({
            docs: friendIds.map((id, index) => ({
              id: `friendship${index}`,
              data: () => ({
                initiatorId: "user1",
                recipientId: id,
                status: "accepted",
                createdAt: mockTimestamp,
                updatedAt: mockTimestamp,
              }),
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

      const result = await getFriendshipsHandler({status: "accepted"}, mockContext);

      expect(result.friendships).toHaveLength(15);
    });

    it("should handle missing user profiles gracefully", async () => {
      const mockTimestamp = {toDate: () => new Date("2024-01-01")};

      const mockFriendshipsCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn()
          .mockResolvedValueOnce({
            docs: [
              {
                id: "friendship1",
                data: () => ({
                  initiatorId: "user1",
                  recipientId: "deleted-user",
                  status: "accepted",
                  createdAt: mockTimestamp,
                  updatedAt: mockTimestamp,
                }),
              },
            ],
            empty: false,
          })
          .mockResolvedValueOnce({docs: [], empty: true}),
      };

      const mockUsersCollection = {
        where: jest.fn().mockReturnThis(),
        get: jest.fn().mockResolvedValue({
          docs: [], // User not found
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

      const result = await getFriendshipsHandler({status: "accepted"}, mockContext);

      expect(result.friendships).toHaveLength(1);
      expect(result.friendships[0].otherUser.uid).toBe("deleted-user");
      expect(result.friendships[0].otherUser.email).toBe("unknown@example.com");
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

  describe("verifyFriendship", () => {
    it("should throw error if user is not authenticated", async () => {
      await expect(
        verifyFriendshipHandler({initiatorId: "user1", recipientId: "user2"}, {auth: undefined} as any)
      ).rejects.toThrow("You must be logged in to verify friendships");
    });

    it("should throw error if initiatorId is missing", async () => {
      await expect(
        verifyFriendshipHandler({initiatorId: "", recipientId: "user2"}, mockContext)
      ).rejects.toThrow("Parameter 'initiatorId' is required and must be a string");
    });

    it("should throw error if recipientId is missing", async () => {
      await expect(
        verifyFriendshipHandler({initiatorId: "user1", recipientId: ""}, mockContext)
      ).rejects.toThrow("Parameter 'recipientId' is required and must be a string");
    });

    it("should return false if users are not friends", async () => {
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: true,
              data: () => ({
                friendIds: ["user3", "user4"],
              }),
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await verifyFriendshipHandler(
        {initiatorId: "user1", recipientId: "user2"},
        mockContext
      );

      expect(result).toEqual({areFriends: false});
    });

    it("should return true if users are friends", async () => {
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: true,
              data: () => ({
                friendIds: ["user2", "user3"],
              }),
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await verifyFriendshipHandler(
        {initiatorId: "user1", recipientId: "user2"},
        mockContext
      );

      expect(result).toEqual({areFriends: true});
    });

    it("should return false if initiator user does not exist", async () => {
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: false,
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await verifyFriendshipHandler(
        {initiatorId: "nonexistent", recipientId: "user2"},
        mockContext
      );

      expect(result).toEqual({areFriends: false});
    });

    it("should return false on Firestore errors (fail-closed behavior)", async () => {
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockRejectedValue(new Error("Firestore error")),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      // checkFriendship fails closed - returns false on error
      // verifyFriendship should return this false value
      const result = await verifyFriendshipHandler(
        {initiatorId: "user1", recipientId: "user2"},
        mockContext
      );

      expect(result).toEqual({areFriends: false});
    });
  });

  // ============================================================================
  // Story 11.17: Batch Friendship Validation
  // ============================================================================

  describe("batchCheckFriendship", () => {
    const mockContext = {
      auth: {uid: "user1"},
    };

    const {batchCheckFriendshipHandler} =
      require("../../src/friendships");

    beforeEach(() => {
      jest.clearAllMocks();
    });

    it("should throw unauthenticated error when user is not logged in", async () => {
      const unauthContext = {auth: null};

      await expect(
        batchCheckFriendshipHandler({userIds: ["user2"]}, unauthContext as any)
      ).rejects.toThrow("You must be logged in to check friendships");
    });

    it("should throw invalid-argument when userIds is not an array", async () => {
      await expect(
        batchCheckFriendshipHandler({userIds: "not-an-array"} as any, mockContext as any)
      ).rejects.toThrow("userIds must be an array");
    });

    it("should throw invalid-argument when userIds is missing", async () => {
      await expect(
        batchCheckFriendshipHandler({} as any, mockContext as any)
      ).rejects.toThrow("userIds must be an array");
    });

    it("should return empty map when userIds array is empty", async () => {
      const result = await batchCheckFriendshipHandler(
        {userIds: []},
        mockContext as any
      );

      expect(result).toEqual({friendships: {}});
    });

    it("should throw invalid-argument when checking more than 100 users", async () => {
      const userIds = Array.from({length: 101}, (_, i) => `user${i}`);

      await expect(
        batchCheckFriendshipHandler({userIds}, mockContext as any)
      ).rejects.toThrow("Maximum 100 users can be checked at once");
    });

    it("should throw not-found when current user does not exist", async () => {
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: false,
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        batchCheckFriendshipHandler(
          {userIds: ["user2", "user3"]},
          mockContext as any
        )
      ).rejects.toThrow("User not found");
    });

    it("should return correct friendship status for multiple users", async () => {
      // Mock user with cached friendIds: user2 and user4 are friends
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: true,
              data: () => ({
                friendIds: ["user2", "user4"],
              }),
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await batchCheckFriendshipHandler(
        {userIds: ["user2", "user3", "user4", "user5"]},
        mockContext as any
      );

      expect(result).toEqual({
        friendships: {
          user2: true, // is a friend
          user3: false, // not a friend
          user4: true, // is a friend
          user5: false, // not a friend
        },
      });
    });

    it("should handle user with no friends (empty friendIds)", async () => {
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: true,
              data: () => ({
                friendIds: [],
              }),
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await batchCheckFriendshipHandler(
        {userIds: ["user2", "user3"]},
        mockContext as any
      );

      expect(result).toEqual({
        friendships: {
          user2: false,
          user3: false,
        },
      });
    });

    it("should handle user with missing friendIds field", async () => {
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: true,
              data: () => ({}), // No friendIds field
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await batchCheckFriendshipHandler(
        {userIds: ["user2"]},
        mockContext as any
      );

      expect(result).toEqual({
        friendships: {
          user2: false,
        },
      });
    });

    it("should handle single user check", async () => {
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: true,
              data: () => ({
                friendIds: ["user2"],
              }),
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      const result = await batchCheckFriendshipHandler(
        {userIds: ["user2"]},
        mockContext as any
      );

      expect(result).toEqual({
        friendships: {
          user2: true,
        },
      });
    });

    it("should handle exactly 100 users (edge case)", async () => {
      const friendIds = Array.from({length: 50}, (_, i) => `user${i * 2}`);
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: true,
              data: () => ({
                friendIds,
              }),
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      const userIds = Array.from({length: 100}, (_, i) => `user${i}`);
      const result = await batchCheckFriendshipHandler(
        {userIds},
        mockContext as any
      );

      expect(Object.keys(result.friendships)).toHaveLength(100);
      expect(result.friendships["user0"]).toBe(true); // Even index = friend
      expect(result.friendships["user1"]).toBe(false); // Odd index = not friend
    });

    it("should handle firestore error gracefully", async () => {
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockRejectedValue(new Error("Firestore error")),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      await expect(
        batchCheckFriendshipHandler(
          {userIds: ["user2"]},
          mockContext as any
        )
      ).rejects.toThrow("Failed to check friendships");
    });

    it("should use Set for efficient lookup", async () => {
      // This test verifies the implementation uses Set (O(1)) not Array (O(n))
      const largeFriendList = Array.from({length: 50}, (_, i) => `friend${i}`);
      const mockFirestore = {
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue({
              exists: true,
              data: () => ({
                friendIds: largeFriendList,
              }),
            }),
          }),
        }),
      };
      admin.firestore.mockReturnValue(mockFirestore);

      const checkUsers = ["friend25", "friend40", "notfriend1", "notfriend2"];
      const result = await batchCheckFriendshipHandler(
        {userIds: checkUsers},
        mockContext as any
      );

      expect(result.friendships["friend25"]).toBe(true);
      expect(result.friendships["friend40"]).toBe(true);
      expect(result.friendships["notfriend1"]).toBe(false);
      expect(result.friendships["notfriend2"]).toBe(false);
    });
  });
});

// Unit tests for inviteToGroup Cloud Function
// Story 11.16: Validate Group Invitations via Social Graph

import * as admin from "firebase-admin";
import {inviteToGroupHandler} from "../../src/inviteToGroup";
import * as friendships from "../../src/friendships";

// Mock Firebase Admin
jest.mock("firebase-admin", () => {
  const actualAdmin = jest.requireActual("firebase-admin");
  return {
    ...actualAdmin,
    firestore: Object.assign(
      jest.fn(() => ({
        collection: jest.fn(),
      })),
      {
        FieldValue: {
          serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
        },
      }
    ),
  };
});

// Mock friendships module
jest.mock("../../src/friendships", () => ({
  checkFriendship: jest.fn(),
}));

// Mock firebase-functions with logger
jest.mock("firebase-functions", () => ({
  https: {
    HttpsError: class HttpsError extends Error {
      code: string;
      constructor(code: string, message: string) {
        super(message);
        this.code = code;
        this.name = "HttpsError";
      }
    },
    onCall: jest.fn((handler) => handler),
  },
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
    debug: jest.fn(),
  },
  firestore: {
    FieldValue: {
      serverTimestamp: jest.fn(() => "TIMESTAMP"),
    },
  },
}));

// Import functions to access logger
const functions = require("firebase-functions");

describe("inviteToGroup Cloud Function", () => {
  let mockDb: any;
  let mockGroupDoc: any;
  let mockUserDoc: any;
  let mockInvitationsCollection: any;

  beforeEach(() => {
    jest.clearAllMocks();

    // Setup mock Firestore
    mockInvitationsCollection = {
      add: jest.fn().mockImplementation((data) => {
        // Return a promise that resolves to a reference with id
        return Promise.resolve({id: "invitation123"});
      }),
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue({empty: true}),
    };

    mockUserDoc = {
      exists: true,
      data: () => ({
        displayName: "Test User",
        email: "test@example.com",
      }),
    };

    mockGroupDoc = {
      exists: true,
      data: () => ({
        name: "Test Group",
        createdBy: "inviter123",
        memberIds: ["inviter123", "member456"],
      }),
    };

    mockDb = {
      collection: jest.fn((collectionName: string) => {
        if (collectionName === "users") {
          return {
            doc: jest.fn((userId: string) => {
              if (userId === "invitee123" || userId === "inviter123") {
                return {
                  get: jest.fn().mockResolvedValue(mockUserDoc),
                  collection: jest.fn(() => mockInvitationsCollection),
                };
              }
              return {
                get: jest.fn().mockResolvedValue({exists: false}),
              };
            }),
          };
        }
        if (collectionName === "groups") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockGroupDoc),
            })),
          };
        }
        return {};
      }),
    };

    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);
  });

  describe("Authentication and Input Validation", () => {
    it("should throw unauthenticated error if user is not logged in", async () => {
      const data = {groupId: "group123", invitedUserId: "user123"};
      const context = {auth: null};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow("You must be logged in to invite users to groups");
    });

    it("should throw invalid-argument error if groupId is missing", async () => {
      const data = {invitedUserId: "user123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow("Parameter 'groupId' is required and must be a string");
    });

    it("should throw invalid-argument error if invitedUserId is missing", async () => {
      const data = {groupId: "group123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow(
        "Parameter 'invitedUserId' is required and must be a string"
      );
    });

    it("should throw invalid-argument error if trying to invite self", async () => {
      const data = {groupId: "group123", invitedUserId: "inviter123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow("You cannot invite yourself to a group");
    });
  });

  describe("Group and User Validation", () => {
    it("should throw not-found error if group doesn't exist", async () => {
      mockGroupDoc.exists = false;

      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow(
        "The group you're trying to invite to doesn't exist"
      );
    });

    it("should throw permission-denied if inviter is not a group member", async () => {
      mockGroupDoc.data = () => ({
        name: "Test Group",
        createdBy: "owner123",
        memberIds: ["owner123", "otherMember456"],
      });

      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow("You must be a member of the group to invite others");
    });

    it("should throw not-found error if invitee doesn't exist", async () => {
      mockDb.collection = jest.fn((collectionName: string) => {
        if (collectionName === "users") {
          return {
            doc: jest.fn((userId: string) => {
              if (userId === "inviter123") {
                return {
                  get: jest.fn().mockResolvedValue(mockUserDoc),
                  collection: jest.fn(() => mockInvitationsCollection),
                };
              }
              // invitee doesn't exist
              return {
                get: jest.fn().mockResolvedValue({exists: false}),
              };
            }),
          };
        }
        if (collectionName === "groups") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockGroupDoc),
            })),
          };
        }
        return {};
      });

      (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);

      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow("The user you're trying to invite doesn't exist");
    });
  });

  describe("Friendship Validation (Story 11.16)", () => {
    it("should throw permission-denied if users are not friends", async () => {
      // Mock checkFriendship to return false
      (friendships.checkFriendship as jest.Mock).mockResolvedValue(false);

      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow("You can only invite friends to groups");

      // Verify checkFriendship was called with correct parameters
      expect(friendships.checkFriendship).toHaveBeenCalledWith(
        "inviter123",
        "invitee123"
      );
    });

    it("should proceed with invitation if users are friends", async () => {
      // Mock checkFriendship to return true
      (friendships.checkFriendship as jest.Mock).mockResolvedValue(true);

      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      const result = await inviteToGroupHandler(data as any, context as any);

      expect(result).toEqual({
        success: true,
        invitationId: "invitation123",
      });

      // Verify checkFriendship was called
      expect(friendships.checkFriendship).toHaveBeenCalledWith(
        "inviter123",
        "invitee123"
      );
    });
  });

  describe("Duplicate and Existing Member Checks", () => {
    beforeEach(() => {
      // Mock friendship check to pass
      (friendships.checkFriendship as jest.Mock).mockResolvedValue(true);
    });

    it("should throw already-exists if user is already a member", async () => {
      mockGroupDoc.data = () => ({
        name: "Test Group",
        createdBy: "owner123",
        memberIds: ["inviter123", "invitee123"],
      });

      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow("This user is already a member of the group");
    });

    it("should throw already-exists if pending invitation exists", async () => {
      mockInvitationsCollection.get.mockResolvedValue({
        empty: false,
      });

      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow(
        "This user already has a pending invitation to this group"
      );
    });
  });

  describe("Successful Invitation Creation", () => {
    beforeEach(() => {
      // Mock friendship check to pass
      (friendships.checkFriendship as jest.Mock).mockResolvedValue(true);
      // Mock no pending invitations
      mockInvitationsCollection.get.mockResolvedValue({empty: true});
    });

    it("should create invitation when all validations pass", async () => {
      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      const result = await inviteToGroupHandler(data as any, context as any);

      expect(result).toEqual({
        success: true,
        invitationId: "invitation123",
      });

      // Verify invitation was created with correct data
      expect(mockInvitationsCollection.add).toHaveBeenCalledWith(
        expect.objectContaining({
          groupId: "group123",
          groupName: "Test Group",
          invitedUserId: "invitee123",
          invitedBy: "inviter123",
          inviterName: "Test User",
          status: "pending",
        })
      );
    });

    it("should log successful invitation creation", async () => {
      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      await inviteToGroupHandler(data as any, context as any);

      expect(functions.logger.info).toHaveBeenCalledWith(
        "Group invitation created successfully",
        expect.objectContaining({
          inviterId: "inviter123",
          invitedUserId: "invitee123",
          groupId: "group123",
          invitationId: "invitation123",
        })
      );
    });
  });

  describe("Error Handling", () => {
    beforeEach(() => {
      (friendships.checkFriendship as jest.Mock).mockResolvedValue(true);
    });

    it("should throw internal error if invitation creation fails", async () => {
      mockInvitationsCollection.add.mockRejectedValue(
        new Error("Firestore error")
      );

      const data = {groupId: "group123", invitedUserId: "invitee123"};
      const context = {auth: {uid: "inviter123"}};

      await expect(
        inviteToGroupHandler(data as any, context as any)
      ).rejects.toThrow("Failed to send group invitation");

      expect(functions.logger.error).toHaveBeenCalled();
    });
  });
});

// Unit tests for joinGroupViaInvite Cloud Function
// Epic 17 — Story 17.3, 17.9 (Idempotent Group Join Logic)

import * as admin from "firebase-admin";
import {joinGroupViaInviteHandler} from "../../../src/invites/joinGroupViaInvite";

// Mock Firebase Admin
jest.mock("firebase-admin", () => {
  const actualAdmin = jest.requireActual("firebase-admin");
  return {
    ...actualAdmin,
    firestore: Object.assign(
      jest.fn(() => ({})),
      {
        FieldValue: {
          serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
          arrayUnion: jest.fn((...args: any[]) => ({
            _methodName: "arrayUnion",
            _elements: args,
          })),
          increment: jest.fn((n: number) => ({
            _methodName: "increment",
            _operand: n,
          })),
        },
      }
    ),
  };
});

// Mock firebase-functions
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
}));

describe("joinGroupViaInvite Cloud Function", () => {
  let mockDb: any;
  let mockTokenDoc: any;
  let mockInviteDoc: any;
  let mockGroupDoc: any;
  let mockTransaction: any;

  const pastDate = new Date(Date.now() - 24 * 60 * 60 * 1000);

  beforeEach(() => {
    jest.clearAllMocks();

    mockTokenDoc = {
      exists: true,
      data: () => ({
        groupId: "group-456",
        inviteId: "invite-789",
        active: true,
      }),
    };

    mockInviteDoc = {
      exists: true,
      data: () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        createdAt: {toDate: () => new Date()},
        expiresAt: null,
        revoked: false,
        usageLimit: null,
        usageCount: 0,
        groupId: "group-456",
        inviteType: "group_link",
      }),
    };

    mockGroupDoc = {
      exists: true,
      data: () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123", "member2"],
        adminIds: ["creator123"],
        maxMembers: 20,
        allowMembersToInviteOthers: true,
      }),
    };

    mockTransaction = {
      get: jest.fn((ref: any) => {
        if (ref._type === "invite") return Promise.resolve(mockInviteDoc);
        if (ref._type === "group") return Promise.resolve(mockGroupDoc);
        return Promise.resolve(mockTokenDoc);
      }),
      update: jest.fn(),
    };

    const mockTokenRef = {_type: "token"};
    const mockInviteRef = {_type: "invite"};
    const mockGroupRef = {_type: "group"};

    mockDb = {
      collection: jest.fn((collectionName: string) => {
        if (collectionName === "invite_tokens") {
          return {
            doc: jest.fn(() => ({
              ...mockTokenRef,
              get: jest.fn().mockResolvedValue(mockTokenDoc),
            })),
          };
        }
        if (collectionName === "groups") {
          return {
            doc: jest.fn(() => ({
              ...mockGroupRef,
              get: jest.fn().mockResolvedValue(mockGroupDoc),
              collection: jest.fn(() => ({
                doc: jest.fn(() => mockInviteRef),
              })),
            })),
          };
        }
        return {};
      }),
      runTransaction: jest.fn(async (callback: any) => {
        // Override transaction.get to return correct docs
        const txn = {
          get: jest.fn((ref: any) => {
            if (ref._type === "invite") {
              return Promise.resolve(mockInviteDoc);
            }
            if (ref._type === "group") {
              return Promise.resolve(mockGroupDoc);
            }
            return Promise.resolve(mockTokenDoc);
          }),
          update: jest.fn(),
        };
        mockTransaction = txn;
        await callback(txn);
      }),
    };

    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);
  });

  describe("Authentication", () => {
    it("should throw unauthenticated error if not logged in", async () => {
      await expect(
        joinGroupViaInviteHandler(
          {token: "abc123"},
          {auth: null} as any
        )
      ).rejects.toThrow("You must be logged in to join a group.");
    });
  });

  describe("Input Validation", () => {
    it("should throw invalid-argument if token is missing", async () => {
      await expect(
        joinGroupViaInviteHandler(
          {} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'token' is required and must be a non-empty string."
      );
    });

    it("should throw invalid-argument if token is empty", async () => {
      await expect(
        joinGroupViaInviteHandler(
          {token: "   "},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'token' is required and must be a non-empty string."
      );
    });
  });

  describe("Token Validation", () => {
    it("should throw not-found if token does not exist", async () => {
      mockTokenDoc.exists = false;

      // Override the initial get to return non-existent token
      mockDb.collection = jest.fn((collectionName: string) => {
        if (collectionName === "invite_tokens") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue({exists: false}),
            })),
          };
        }
        return {};
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);

      await expect(
        joinGroupViaInviteHandler(
          {token: "nonexistent"},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("This invite link does not exist.");
    });

    it("should throw failed-precondition if token is inactive", async () => {
      mockTokenDoc.data = () => ({
        groupId: "group-456",
        inviteId: "invite-789",
        active: false,
      });

      // Override initial token get to return inactive
      mockDb.collection = jest.fn((collectionName: string) => {
        if (collectionName === "invite_tokens") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockTokenDoc),
            })),
          };
        }
        return {};
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);

      await expect(
        joinGroupViaInviteHandler(
          {token: "abc123"},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("This invite link is no longer active.");
    });
  });

  describe("Transaction Logic", () => {
    it("should throw failed-precondition if invite is revoked", async () => {
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        expiresAt: null,
        revoked: true,
        usageLimit: null,
        usageCount: 0,
        groupId: "group-456",
      });

      await expect(
        joinGroupViaInviteHandler(
          {token: "abc123"},
          {auth: {uid: "newuser"}} as any
        )
      ).rejects.toThrow("This invite link has been revoked.");
    });

    it("should throw failed-precondition if invite is expired", async () => {
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        expiresAt: {toDate: () => pastDate},
        revoked: false,
        usageLimit: null,
        usageCount: 0,
        groupId: "group-456",
      });

      await expect(
        joinGroupViaInviteHandler(
          {token: "abc123"},
          {auth: {uid: "newuser"}} as any
        )
      ).rejects.toThrow("This invite link has expired.");
    });

    it("should throw failed-precondition if usage limit reached", async () => {
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        expiresAt: null,
        revoked: false,
        usageLimit: 5,
        usageCount: 5,
        groupId: "group-456",
      });

      await expect(
        joinGroupViaInviteHandler(
          {token: "abc123"},
          {auth: {uid: "newuser"}} as any
        )
      ).rejects.toThrow(
        "This invite link has reached its usage limit."
      );
    });

    it("should throw not-found if group does not exist", async () => {
      mockGroupDoc.exists = false;

      await expect(
        joinGroupViaInviteHandler(
          {token: "abc123"},
          {auth: {uid: "newuser"}} as any
        )
      ).rejects.toThrow(
        "The group associated with this invite no longer exists."
      );
    });

    it("should throw failed-precondition if group is at capacity", async () => {
      mockGroupDoc.data = () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123", "member2"],
        adminIds: ["creator123"],
        maxMembers: 2,
        allowMembersToInviteOthers: true,
      });

      await expect(
        joinGroupViaInviteHandler(
          {token: "abc123"},
          {auth: {uid: "newuser"}} as any
        )
      ).rejects.toThrow(
        "This group is at capacity and cannot accept new members."
      );
    });
  });

  describe("Idempotency", () => {
    it("should return alreadyMember true if user is already in group", async () => {
      // User is already a member
      const result = await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.success).toBe(true);
      expect(result.alreadyMember).toBe(true);
      expect(result.groupId).toBe("group-456");
      expect(result.groupName).toBe("Beach Volleyball");
    });

    it("should not perform writes when user is already a member", async () => {
      await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "creator123"}} as any
      );

      // Transaction update should not have been called
      expect(mockTransaction.update).not.toHaveBeenCalled();
    });

    it("should return alreadyMember true even when usage limit is reached", async () => {
      // User is already a member AND usage limit is maxed out
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        expiresAt: null,
        revoked: false,
        usageLimit: 5,
        usageCount: 5,
        groupId: "group-456",
      });

      const result = await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.success).toBe(true);
      expect(result.alreadyMember).toBe(true);
      expect(mockTransaction.update).not.toHaveBeenCalled();
    });

    it("should return alreadyMember true even when group is at capacity", async () => {
      // User is already a member AND group is at max capacity
      mockGroupDoc.data = () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123", "member2"],
        adminIds: ["creator123"],
        maxMembers: 2,
        allowMembersToInviteOthers: true,
      });

      const result = await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.success).toBe(true);
      expect(result.alreadyMember).toBe(true);
      expect(mockTransaction.update).not.toHaveBeenCalled();
    });

    it("should return alreadyMember true for user added via different path", async () => {
      // User was added directly (not via invite) but now uses invite link
      mockGroupDoc.data = () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123", "member2", "direct-add-user"],
        adminIds: ["creator123"],
        maxMembers: 20,
        allowMembersToInviteOthers: true,
      });

      const result = await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "direct-add-user"}} as any
      );

      expect(result.success).toBe(true);
      expect(result.alreadyMember).toBe(true);
      expect(mockTransaction.update).not.toHaveBeenCalled();
    });
  });

  describe("Successful Join", () => {
    it("should join user to group and return success", async () => {
      const result = await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "newuser"}} as any
      );

      expect(result.success).toBe(true);
      expect(result.alreadyMember).toBe(false);
      expect(result.groupId).toBe("group-456");
      expect(result.groupName).toBe("Beach Volleyball");
    });

    it("should update group memberIds and invite usageCount", async () => {
      await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "newuser"}} as any
      );

      // Should have 2 update calls: group and invite
      expect(mockTransaction.update).toHaveBeenCalledTimes(2);
    });

    it("should use arrayUnion with correct uid for membership", async () => {
      await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "newuser"}} as any
      );

      expect(admin.firestore.FieldValue.arrayUnion).toHaveBeenCalledWith(
        "newuser"
      );
    });

    it("should increment usageCount by exactly 1", async () => {
      await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "newuser"}} as any
      );

      expect(admin.firestore.FieldValue.increment).toHaveBeenCalledWith(1);
    });

    it("should set lastActivity to server timestamp", async () => {
      await joinGroupViaInviteHandler(
        {token: "abc123"},
        {auth: {uid: "newuser"}} as any
      );

      expect(
        admin.firestore.FieldValue.serverTimestamp
      ).toHaveBeenCalled();
    });
  });

  describe("Error Handling", () => {
    it("should throw internal on unexpected transaction error", async () => {
      mockDb.runTransaction = jest.fn().mockRejectedValue(
        new Error("Transaction failed")
      );
      (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);

      await expect(
        joinGroupViaInviteHandler(
          {token: "abc123"},
          {auth: {uid: "newuser"}} as any
        )
      ).rejects.toThrow(
        "Failed to join group. Please try again later."
      );
    });
  });
});

// Unit tests for revokeGroupInvite Cloud Function
// Epic 17 — Story 17.3

import * as admin from "firebase-admin";
import {revokeGroupInviteHandler} from "../../../src/invites/revokeGroupInvite";

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

describe("revokeGroupInvite Cloud Function", () => {
  let mockDb: any;
  let mockBatch: any;
  let mockInviteDoc: any;
  let mockGroupDoc: any;

  beforeEach(() => {
    jest.clearAllMocks();

    mockBatch = {
      update: jest.fn(),
      commit: jest.fn().mockResolvedValue(undefined),
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
        usageCount: 3,
        groupId: "group-456",
        inviteType: "group_link",
      }),
    };

    mockGroupDoc = {
      exists: true,
      data: () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123", "inviter-user", "member3"],
        adminIds: ["creator123"],
        maxMembers: 20,
        allowMembersToInviteOthers: true,
      }),
    };

    const mockInviteRef = {_type: "invite"};
    const mockTokenRef = {_type: "token"};

    mockDb = {
      collection: jest.fn((collectionName: string) => {
        if (collectionName === "groups") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockGroupDoc),
              collection: jest.fn(() => ({
                doc: jest.fn(() => ({
                  ...mockInviteRef,
                  get: jest.fn().mockResolvedValue(mockInviteDoc),
                })),
              })),
            })),
          };
        }
        if (collectionName === "invite_tokens") {
          return {
            doc: jest.fn(() => mockTokenRef),
          };
        }
        return {};
      }),
      batch: jest.fn(() => mockBatch),
    };

    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);
  });

  describe("Authentication", () => {
    it("should throw unauthenticated error if not logged in", async () => {
      await expect(
        revokeGroupInviteHandler(
          {groupId: "group-456", inviteId: "invite-789"},
          {auth: null} as any
        )
      ).rejects.toThrow("You must be logged in to revoke an invite link.");
    });
  });

  describe("Input Validation", () => {
    it("should throw invalid-argument if groupId is missing", async () => {
      await expect(
        revokeGroupInviteHandler(
          {inviteId: "invite-789"} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'groupId' is required and must be a non-empty string."
      );
    });

    it("should throw invalid-argument if groupId is empty", async () => {
      await expect(
        revokeGroupInviteHandler(
          {groupId: "  ", inviteId: "invite-789"},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'groupId' is required and must be a non-empty string."
      );
    });

    it("should throw invalid-argument if inviteId is missing", async () => {
      await expect(
        revokeGroupInviteHandler(
          {groupId: "group-456"} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'inviteId' is required and must be a non-empty string."
      );
    });

    it("should throw invalid-argument if inviteId is empty", async () => {
      await expect(
        revokeGroupInviteHandler(
          {groupId: "group-456", inviteId: "  "},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'inviteId' is required and must be a non-empty string."
      );
    });
  });

  describe("Invite Validation", () => {
    it("should throw not-found if invite does not exist", async () => {
      mockInviteDoc.exists = false;

      await expect(
        revokeGroupInviteHandler(
          {groupId: "group-456", inviteId: "invite-789"},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow("The invite does not exist.");
    });

    it("should throw already-exists if invite is already revoked", async () => {
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        revoked: true,
        usageLimit: null,
        usageCount: 3,
        groupId: "group-456",
      });

      await expect(
        revokeGroupInviteHandler(
          {groupId: "group-456", inviteId: "invite-789"},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow("This invite is already revoked.");
    });
  });

  describe("Permission Validation", () => {
    it("should throw permission-denied if user is not admin and not invite creator", async () => {
      await expect(
        revokeGroupInviteHandler(
          {groupId: "group-456", inviteId: "invite-789"},
          {auth: {uid: "member3"}} as any
        )
      ).rejects.toThrow(
        "You do not have permission to revoke this invite."
      );
    });

    it("should allow group admin to revoke", async () => {
      const result = await revokeGroupInviteHandler(
        {groupId: "group-456", inviteId: "invite-789"},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.success).toBe(true);
    });

    it("should allow group creator to revoke", async () => {
      const result = await revokeGroupInviteHandler(
        {groupId: "group-456", inviteId: "invite-789"},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.success).toBe(true);
    });

    it("should allow invite creator to revoke their own invite", async () => {
      const result = await revokeGroupInviteHandler(
        {groupId: "group-456", inviteId: "invite-789"},
        {auth: {uid: "inviter-user"}} as any
      );

      expect(result.success).toBe(true);
    });
  });

  describe("Successful Revocation", () => {
    it("should revoke invite and return success", async () => {
      const result = await revokeGroupInviteHandler(
        {groupId: "group-456", inviteId: "invite-789"},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.success).toBe(true);
    });

    it("should write both invite revocation and token deactivation", async () => {
      await revokeGroupInviteHandler(
        {groupId: "group-456", inviteId: "invite-789"},
        {auth: {uid: "creator123"}} as any
      );

      expect(mockBatch.update).toHaveBeenCalledTimes(2);
      expect(mockBatch.commit).toHaveBeenCalledTimes(1);
    });

    it("should set revoked to true on invite", async () => {
      await revokeGroupInviteHandler(
        {groupId: "group-456", inviteId: "invite-789"},
        {auth: {uid: "creator123"}} as any
      );

      expect(mockBatch.update).toHaveBeenCalledWith(
        expect.anything(),
        {revoked: true}
      );
    });

    it("should set active to false on token lookup", async () => {
      await revokeGroupInviteHandler(
        {groupId: "group-456", inviteId: "invite-789"},
        {auth: {uid: "creator123"}} as any
      );

      expect(mockBatch.update).toHaveBeenCalledWith(
        expect.anything(),
        {active: false}
      );
    });
  });

  describe("Error Handling", () => {
    it("should throw internal on unexpected failure", async () => {
      mockBatch.commit.mockRejectedValue(new Error("Firestore error"));

      await expect(
        revokeGroupInviteHandler(
          {groupId: "group-456", inviteId: "invite-789"},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow(
        "Failed to revoke invite link. Please try again later."
      );
    });
  });
});

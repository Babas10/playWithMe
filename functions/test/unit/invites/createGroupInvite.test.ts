// Unit tests for createGroupInvite Cloud Function
// Epic 17 — Story 17.3

import * as admin from "firebase-admin";
import {createGroupInviteHandler} from "../../../src/invites/createGroupInvite";

// Mock crypto
jest.mock("crypto", () => ({
  randomBytes: jest.fn(() => ({
    toString: jest.fn(() => "mocktoken12345678901234567890ab"),
  })),
}));

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
        Timestamp: {
          fromDate: jest.fn((date: Date) => ({toDate: () => date})),
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

describe("createGroupInvite Cloud Function", () => {
  let mockDb: any;
  let mockBatch: any;
  let mockGroupDoc: any;
  let mockInviteRef: any;

  beforeEach(() => {
    jest.clearAllMocks();

    mockBatch = {
      set: jest.fn(),
      commit: jest.fn().mockResolvedValue(undefined),
    };

    mockInviteRef = {
      id: "invite-abc123",
    };

    mockGroupDoc = {
      exists: true,
      data: () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123", "user789"],
        adminIds: ["creator123"],
        maxMembers: 20,
        allowMembersToInviteOthers: true,
      }),
    };

    mockDb = {
      collection: jest.fn((collectionName: string) => {
        if (collectionName === "groups") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockGroupDoc),
              collection: jest.fn(() => ({
                doc: jest.fn(() => mockInviteRef),
              })),
            })),
          };
        }
        if (collectionName === "invite_tokens") {
          return {
            doc: jest.fn(() => ({})),
          };
        }
        return {};
      }),
      batch: jest.fn(() => mockBatch),
    };

    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);
  });

  describe("Authentication", () => {
    it("should throw unauthenticated error if user is not logged in", async () => {
      await expect(
        createGroupInviteHandler(
          {groupId: "group123"},
          {auth: null} as any
        )
      ).rejects.toThrow("You must be logged in to create an invite link.");
    });
  });

  describe("Input Validation", () => {
    it("should throw invalid-argument if groupId is missing", async () => {
      await expect(
        createGroupInviteHandler(
          {} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'groupId' is required and must be a non-empty string."
      );
    });

    it("should throw invalid-argument if groupId is empty string", async () => {
      await expect(
        createGroupInviteHandler(
          {groupId: "  "},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'groupId' is required and must be a non-empty string."
      );
    });

    it("should throw invalid-argument if expiresInHours is not positive", async () => {
      await expect(
        createGroupInviteHandler(
          {groupId: "group123", expiresInHours: -5},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'expiresInHours' must be a positive number."
      );
    });

    it("should throw invalid-argument if expiresInHours is zero", async () => {
      await expect(
        createGroupInviteHandler(
          {groupId: "group123", expiresInHours: 0},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'expiresInHours' must be a positive number."
      );
    });

    it("should throw invalid-argument if usageLimit is not a positive integer", async () => {
      await expect(
        createGroupInviteHandler(
          {groupId: "group123", usageLimit: 2.5},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'usageLimit' must be a positive integer."
      );
    });

    it("should throw invalid-argument if usageLimit is zero", async () => {
      await expect(
        createGroupInviteHandler(
          {groupId: "group123", usageLimit: 0},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'usageLimit' must be a positive integer."
      );
    });
  });

  describe("Group Validation", () => {
    it("should throw not-found if group does not exist", async () => {
      mockGroupDoc.exists = false;

      await expect(
        createGroupInviteHandler(
          {groupId: "group123"},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow("The group does not exist.");
    });

    it("should throw permission-denied if user is not a member", async () => {
      await expect(
        createGroupInviteHandler(
          {groupId: "group123"},
          {auth: {uid: "outsider999"}} as any
        )
      ).rejects.toThrow(
        "You must be a member of the group to create an invite link."
      );
    });

    it("should throw permission-denied if member cannot invite and is not admin", async () => {
      mockGroupDoc.data = () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123", "user789"],
        adminIds: ["creator123"],
        maxMembers: 20,
        allowMembersToInviteOthers: false,
      });

      await expect(
        createGroupInviteHandler(
          {groupId: "group123"},
          {auth: {uid: "user789"}} as any
        )
      ).rejects.toThrow(
        "You do not have permission to create invite links for this group."
      );
    });

    it("should allow admin to invite even if allowMembersToInviteOthers is false", async () => {
      mockGroupDoc.data = () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123", "user789"],
        adminIds: ["creator123"],
        maxMembers: 20,
        allowMembersToInviteOthers: false,
      });

      const result = await createGroupInviteHandler(
        {groupId: "group123"},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.success).toBe(true);
    });

    it("should throw failed-precondition if group is at capacity", async () => {
      mockGroupDoc.data = () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123", "user789"],
        adminIds: ["creator123"],
        maxMembers: 2,
        allowMembersToInviteOthers: true,
      });

      await expect(
        createGroupInviteHandler(
          {groupId: "group123"},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow(
        "This group is at capacity and cannot accept new members."
      );
    });
  });

  describe("Successful Invite Creation", () => {
    it("should create invite and return correct response", async () => {
      const result = await createGroupInviteHandler(
        {groupId: "group123"},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.success).toBe(true);
      expect(result.inviteId).toBe("invite-abc123");
      expect(result.token).toBe("mocktoken12345678901234567890ab");
      expect(result.deepLinkUrl).toBe(
        "https://playwithme.app/invite/mocktoken12345678901234567890ab"
      );
      expect(result.expiresAt).toBeNull();
    });

    it("should write both invite and token lookup in a batch", async () => {
      await createGroupInviteHandler(
        {groupId: "group123"},
        {auth: {uid: "creator123"}} as any
      );

      expect(mockBatch.set).toHaveBeenCalledTimes(2);
      expect(mockBatch.commit).toHaveBeenCalledTimes(1);
    });

    it("should set expiresAt when expiresInHours is provided", async () => {
      const result = await createGroupInviteHandler(
        {groupId: "group123", expiresInHours: 48},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.expiresAt).not.toBeNull();
    });

    it("should set expiresAt to null when not provided", async () => {
      const result = await createGroupInviteHandler(
        {groupId: "group123"},
        {auth: {uid: "creator123"}} as any
      );

      expect(result.expiresAt).toBeNull();
    });

    it("should pass usageLimit to invite document", async () => {
      await createGroupInviteHandler(
        {groupId: "group123", usageLimit: 10},
        {auth: {uid: "creator123"}} as any
      );

      expect(mockBatch.set).toHaveBeenCalledWith(
        mockInviteRef,
        expect.objectContaining({
          usageLimit: 10,
          usageCount: 0,
        })
      );
    });

    it("should pass null usageLimit when not provided", async () => {
      await createGroupInviteHandler(
        {groupId: "group123"},
        {auth: {uid: "creator123"}} as any
      );

      expect(mockBatch.set).toHaveBeenCalledWith(
        mockInviteRef,
        expect.objectContaining({
          usageLimit: null,
        })
      );
    });
  });

  describe("Error Handling", () => {
    it("should throw internal error on unexpected failure", async () => {
      mockBatch.commit.mockRejectedValue(new Error("Firestore error"));

      await expect(
        createGroupInviteHandler(
          {groupId: "group123"},
          {auth: {uid: "creator123"}} as any
        )
      ).rejects.toThrow(
        "Failed to create invite link. Please try again later."
      );
    });
  });
});

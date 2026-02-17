// Unit tests for validateInviteToken Cloud Function
// Epic 17 — Story 17.3

import * as admin from "firebase-admin";
import {validateInviteTokenHandler} from "../../../src/invites/validateInviteToken";

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

describe("validateInviteToken Cloud Function", () => {
  let mockDb: any;
  let mockTokenDoc: any;
  let mockInviteDoc: any;
  let mockGroupDoc: any;
  let mockInviterDoc: any;

  const futureDate = new Date(Date.now() + 24 * 60 * 60 * 1000);
  const pastDate = new Date(Date.now() - 24 * 60 * 60 * 1000);

  beforeEach(() => {
    jest.clearAllMocks();

    mockTokenDoc = {
      exists: true,
      data: () => ({
        groupId: "group-456",
        inviteId: "invite-789",
        createdAt: {toDate: () => new Date()},
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
        description: "Fun times",
        photoUrl: "https://example.com/photo.jpg",
        createdBy: "creator123",
        memberIds: ["creator123", "member2"],
        adminIds: ["creator123"],
        maxMembers: 20,
        allowMembersToInviteOthers: true,
      }),
    };

    mockInviterDoc = {
      exists: true,
      data: () => ({
        displayName: "John Doe",
        email: "john@example.com",
        photoUrl: "https://example.com/john.jpg",
      }),
    };

    mockDb = {
      collection: jest.fn((collectionName: string) => {
        if (collectionName === "invite_tokens") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockTokenDoc),
            })),
          };
        }
        if (collectionName === "groups") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockGroupDoc),
              collection: jest.fn(() => ({
                doc: jest.fn(() => ({
                  get: jest.fn().mockResolvedValue(mockInviteDoc),
                })),
              })),
            })),
          };
        }
        if (collectionName === "users") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockInviterDoc),
            })),
          };
        }
        return {};
      }),
    };

    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);
  });

  describe("Authentication", () => {
    it("should allow unauthenticated users to validate tokens", async () => {
      const result = await validateInviteTokenHandler(
        {token: "abc123"},
        {auth: null} as any
      );
      expect(result.valid).toBe(true);
    });
  });

  describe("Input Validation", () => {
    it("should throw invalid-argument if token is missing", async () => {
      await expect(
        validateInviteTokenHandler(
          {} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Parameter 'token' is required and must be a non-empty string."
      );
    });

    it("should throw invalid-argument if token is empty", async () => {
      await expect(
        validateInviteTokenHandler(
          {token: "  "},
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

      await expect(
        validateInviteTokenHandler(
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

      await expect(
        validateInviteTokenHandler(
          {token: "abc123"},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("This invite link is no longer active.");
    });
  });

  describe("Invite Validation", () => {
    it("should throw failed-precondition if invite is revoked", async () => {
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        createdAt: {toDate: () => new Date()},
        expiresAt: null,
        revoked: true,
        usageLimit: null,
        usageCount: 0,
        groupId: "group-456",
        inviteType: "group_link",
      });

      await expect(
        validateInviteTokenHandler(
          {token: "abc123"},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("This invite link has been revoked.");
    });

    it("should throw failed-precondition if invite is expired", async () => {
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        createdAt: {toDate: () => new Date()},
        expiresAt: {toDate: () => pastDate},
        revoked: false,
        usageLimit: null,
        usageCount: 0,
        groupId: "group-456",
        inviteType: "group_link",
      });

      await expect(
        validateInviteTokenHandler(
          {token: "abc123"},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("This invite link has expired.");
    });

    it("should throw failed-precondition if usage limit reached", async () => {
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        createdAt: {toDate: () => new Date()},
        expiresAt: null,
        revoked: false,
        usageLimit: 5,
        usageCount: 5,
        groupId: "group-456",
        inviteType: "group_link",
      });

      await expect(
        validateInviteTokenHandler(
          {token: "abc123"},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "This invite link has reached its usage limit."
      );
    });

    it("should pass when expiresAt is in the future", async () => {
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        createdAt: {toDate: () => new Date()},
        expiresAt: {toDate: () => futureDate},
        revoked: false,
        usageLimit: null,
        usageCount: 0,
        groupId: "group-456",
        inviteType: "group_link",
      });

      const result = await validateInviteTokenHandler(
        {token: "abc123"},
        {auth: {uid: "user123"}} as any
      );

      expect(result.valid).toBe(true);
      expect(result.expiresAt).toBe(futureDate.toISOString());
    });
  });

  describe("Successful Validation", () => {
    it("should return correct group info", async () => {
      const result = await validateInviteTokenHandler(
        {token: "abc123"},
        {auth: {uid: "user123"}} as any
      );

      expect(result.valid).toBe(true);
      expect(result.groupId).toBe("group-456");
      expect(result.groupName).toBe("Beach Volleyball");
      expect(result.groupDescription).toBe("Fun times");
      expect(result.groupPhotoUrl).toBe("https://example.com/photo.jpg");
      expect(result.groupMemberCount).toBe(2);
    });

    it("should return inviter info", async () => {
      const result = await validateInviteTokenHandler(
        {token: "abc123"},
        {auth: {uid: "user123"}} as any
      );

      expect(result.inviterName).toBe("John Doe");
      expect(result.inviterPhotoUrl).toBe("https://example.com/john.jpg");
    });

    it("should return null remainingUses for unlimited invites", async () => {
      const result = await validateInviteTokenHandler(
        {token: "abc123"},
        {auth: {uid: "user123"}} as any
      );

      expect(result.remainingUses).toBeNull();
    });

    it("should return correct remainingUses for limited invites", async () => {
      mockInviteDoc.data = () => ({
        token: "testtoken123",
        createdBy: "inviter-user",
        createdAt: {toDate: () => new Date()},
        expiresAt: null,
        revoked: false,
        usageLimit: 10,
        usageCount: 3,
        groupId: "group-456",
        inviteType: "group_link",
      });

      const result = await validateInviteTokenHandler(
        {token: "abc123"},
        {auth: {uid: "user123"}} as any
      );

      expect(result.remainingUses).toBe(7);
    });

    it("should omit optional fields when not present", async () => {
      mockGroupDoc.data = () => ({
        name: "Beach Volleyball",
        createdBy: "creator123",
        memberIds: ["creator123"],
        adminIds: ["creator123"],
        maxMembers: 20,
        allowMembersToInviteOthers: true,
      });

      mockInviterDoc.data = () => ({
        displayName: "John",
        email: "john@example.com",
      });

      const result = await validateInviteTokenHandler(
        {token: "abc123"},
        {auth: {uid: "user123"}} as any
      );

      expect(result.groupDescription).toBeUndefined();
      expect(result.groupPhotoUrl).toBeUndefined();
      expect(result.inviterPhotoUrl).toBeUndefined();
    });
  });

  describe("Error Handling", () => {
    it("should throw internal on unexpected error", async () => {
      (admin.firestore as unknown as jest.Mock).mockReturnValue({
        collection: jest.fn(() => {
          throw new Error("Unexpected");
        }),
      });

      await expect(
        validateInviteTokenHandler(
          {token: "abc123"},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow(
        "Failed to validate invite link. Please try again later."
      );
    });
  });
});

// Unit tests for onGameCreated Cloud Function
// Story 3.2: Implement Cloud Function for New Game Notifications

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

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
          arrayRemove: jest.fn((...elements) => ({
            _methodName: "FieldValue.arrayRemove",
            _elements: elements,
          })),
        },
      }
    ),
    messaging: jest.fn(() => ({
      sendEachForMulticast: jest.fn(),
    })),
  };
});

// Mock firebase-functions
jest.mock("firebase-functions", () => ({
  firestore: {
    document: jest.fn(() => ({
      onCreate: jest.fn((handler) => handler),
      onUpdate: jest.fn((handler) => handler),
      onDelete: jest.fn((handler) => handler),
    })),
  },
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
    debug: jest.fn(),
  },
}));

describe("onGameCreated Cloud Function", () => {
  let mockDb: any;
  let mockMessaging: any;
  let mockGroupDoc: any;
  let mockCreatorDoc: any;
  let mockMemberDoc1: any;
  let mockMemberDoc2: any;

  // Re-import to get fresh mocks
  let onGameCreatedHandler: any;

  beforeEach(async () => {
    jest.clearAllMocks();

    // Setup mock messaging
    mockMessaging = {
      sendEachForMulticast: jest.fn().mockResolvedValue({
        successCount: 2,
        failureCount: 0,
        responses: [{success: true}, {success: true}],
      }),
    };

    // Setup mock member documents
    mockMemberDoc1 = {
      data: jest.fn().mockReturnValue({
        displayName: "Member 1",
        fcmTokens: ["token1", "token2"],
        notificationPreferences: {
          gameCreated: true,
          quietHours: {enabled: false},
        },
      }),
      exists: true,
    };

    mockMemberDoc2 = {
      data: jest.fn().mockReturnValue({
        displayName: "Member 2",
        fcmTokens: ["token3"],
        notificationPreferences: {
          gameCreated: true,
          quietHours: {enabled: false},
        },
      }),
      exists: true,
    };

    // Setup mock creator document
    mockCreatorDoc = {
      data: jest.fn().mockReturnValue({
        displayName: "Creator User",
      }),
      exists: true,
    };

    // Setup mock group document
    mockGroupDoc = {
      data: jest.fn().mockReturnValue({
        name: "Test Group",
        photoUrl: "https://example.com/photo.jpg",
        memberIds: ["creator123", "member1", "member2"],
      }),
      exists: true,
    };

    // Setup mock Firestore
    mockDb = {
      collection: jest.fn((collectionName: string) => {
        if (collectionName === "groups") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockGroupDoc),
            })),
          };
        } else if (collectionName === "users") {
          return {
            doc: jest.fn((userId: string) => ({
              get: jest.fn().mockImplementation(() => {
                if (userId === "creator123") return Promise.resolve(mockCreatorDoc);
                if (userId === "member1") return Promise.resolve(mockMemberDoc1);
                if (userId === "member2") return Promise.resolve(mockMemberDoc2);
                return Promise.resolve({exists: false, data: () => null});
              }),
              update: jest.fn().mockResolvedValue({}),
            })),
          };
        }
        return {doc: jest.fn()};
      }),
    };

    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);
    (admin.messaging as unknown as jest.Mock).mockReturnValue(mockMessaging);

    // Dynamically import to get fresh instance with mocks
    const notificationsModule = await import("../../src/notifications");
    onGameCreatedHandler = notificationsModule.onGameCreated;
  });

  describe("Notification sending", () => {
    it("should send notification to all group members except creator", async () => {
      const snapshot = {
        data: () => ({
          title: "Beach Volleyball",
          createdBy: "creator123",
          groupId: "group123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      // Verify messaging was called
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.tokens).toEqual(["token1", "token2", "token3"]);
      expect(callArgs.notification.title).toBe("New Game in Test Group");
      expect(callArgs.notification.body).toContain("Creator User created a new game");
      expect(callArgs.notification.body).toContain("Beach Volleyball");
      expect(callArgs.data.type).toBe("game_created");
      expect(callArgs.data.gameId).toBe("game123");
    });

    it("should not notify creator", async () => {
      const snapshot = {
        data: () => ({
          title: "Game",
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have member tokens, not creator's
      expect(callArgs.tokens).not.toContain("creatorToken");
    });

    it("should handle game without title gracefully", async () => {
      const snapshot = {
        data: () => ({
          createdBy: "creator123",
          // No title
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toBe("Creator User created a new game");
    });
  });

  describe("Notification preferences", () => {
    it("should respect user with gameCreated disabled globally", async () => {
      mockMemberDoc1.data.mockReturnValue({
        displayName: "Member 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          gameCreated: false, // Disabled globally
        },
      });

      const snapshot = {
        data: () => ({
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have member2's token
      expect(callArgs.tokens).toEqual(["token3"]);
    });

    it("should respect group-specific notification preferences", async () => {
      mockMemberDoc1.data.mockReturnValue({
        displayName: "Member 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          gameCreated: true,
          groupSpecific: {
            group123: {
              gameCreated: false, // Disabled for this specific group
            },
          },
        },
      });

      const snapshot = {
        data: () => ({
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.tokens).toEqual(["token3"]);
    });
  });

  describe("Quiet hours", () => {
    it("should not send notification during quiet hours", async () => {
      // Set quiet hours to always be active (mock time doesn't matter)
      mockMemberDoc1.data.mockReturnValue({
        displayName: "Member 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          gameCreated: true,
          quietHours: {
            enabled: true,
            start: "00:00",
            end: "23:59",
          },
        },
      });

      const snapshot = {
        data: () => ({
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have member2's token (member1 in quiet hours)
      expect(callArgs.tokens).toEqual(["token3"]);
    });
  });

  describe("Edge cases", () => {
    it("should handle group not found", async () => {
      mockGroupDoc.exists = false;
      mockGroupDoc.data.mockReturnValue(null);

      const snapshot = {
        data: () => ({
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "nonexistent", gameId: "game123"},
      };

      const result = await onGameCreatedHandler(snapshot, context);

      expect(result).toBeNull();
      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.warn).toHaveBeenCalledWith(
        "Group not found for game notification",
        expect.any(Object)
      );
    });

    it("should handle member without FCM tokens", async () => {
      mockMemberDoc1.data.mockReturnValue({
        displayName: "Member 1",
        fcmTokens: [], // No tokens
        notificationPreferences: {
          gameCreated: true,
        },
      });

      const snapshot = {
        data: () => ({
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      // Should still send to member2
      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.tokens).toEqual(["token3"]);
    });

    it("should handle no eligible members to notify", async () => {
      mockGroupDoc.data.mockReturnValue({
        name: "Test Group",
        memberIds: ["creator123"], // Only creator
      });

      const snapshot = {
        data: () => ({
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.info).toHaveBeenCalledWith(
        "No members to notify for new game",
        expect.any(Object)
      );
    });

    it("should handle missing creator gracefully", async () => {
      mockCreatorDoc.exists = false;
      mockCreatorDoc.data.mockReturnValue(null);

      const snapshot = {
        data: () => ({
          createdBy: "nonexistent",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toContain("Someone created a new game");
    });
  });

  describe("Invalid token cleanup", () => {
    it("should remove invalid FCM tokens", async () => {
      const mockUpdate = jest.fn().mockResolvedValue({});
      mockDb.collection = jest.fn((collectionName: string) => {
        if (collectionName === "groups") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockGroupDoc),
            })),
          };
        } else if (collectionName === "users") {
          return {
            doc: jest.fn((userId: string) => ({
              get: jest.fn().mockImplementation(() => {
                if (userId === "creator123") return Promise.resolve(mockCreatorDoc);
                if (userId === "member1") return Promise.resolve(mockMemberDoc1);
                if (userId === "member2") return Promise.resolve(mockMemberDoc2);
                return Promise.resolve({exists: false, data: () => null});
              }),
              update: mockUpdate,
            })),
          };
        }
        return {doc: jest.fn()};
      });

      mockMessaging.sendEachForMulticast.mockResolvedValue({
        successCount: 1,
        failureCount: 2,
        responses: [
          {success: true},
          {
            success: false,
            error: {code: "messaging/invalid-registration-token"},
          },
          {
            success: false,
            error: {code: "messaging/registration-token-not-registered"},
          },
        ],
      });

      const snapshot = {
        data: () => ({
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      // Should have called update to remove invalid tokens
      expect(mockUpdate).toHaveBeenCalled();
    });

    it("should not remove tokens on other errors", async () => {
      mockMessaging.sendEachForMulticast.mockResolvedValue({
        successCount: 2,
        failureCount: 1,
        responses: [
          {success: true},
          {success: true},
          {
            success: false,
            error: {code: "messaging/server-unavailable"},
          },
        ],
      });

      const snapshot = {
        data: () => ({
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      await onGameCreatedHandler(snapshot, context);

      // Should not have called update (no invalid tokens)
      expect(mockDb.collection("users").doc().update).not.toHaveBeenCalled();
    });
  });

  describe("Error handling", () => {
    it("should handle errors gracefully and log them", async () => {
      mockDb.collection.mockImplementation(() => {
        throw new Error("Firestore error");
      });

      const snapshot = {
        data: () => ({
          createdBy: "creator123",
        }),
        id: "game123",
      };

      const context = {
        params: {groupId: "group123", gameId: "game123"},
      };

      const result = await onGameCreatedHandler(snapshot, context);

      expect(result).toBeNull();
      expect(functions.logger.error).toHaveBeenCalledWith(
        "Error sending game created notification",
        expect.objectContaining({
          error: "Firestore error",
        })
      );
    });
  });
});

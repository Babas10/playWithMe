// Unit tests for onGameResultSubmitted Cloud Function
// Story 14.15: Notifications for Game Result Verification

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

describe("onGameResultSubmitted Cloud Function", () => {
  let mockDb: any;
  let mockMessaging: any;
  let mockSubmitterDoc: any;
  let mockPlayer1Doc: any;
  let mockPlayer2Doc: any;
  let mockPlayer3Doc: any;

  // Re-import to get fresh mocks
  let onGameResultSubmittedHandler: any;

  beforeEach(async () => {
    jest.clearAllMocks();

    // Setup mock messaging
    mockMessaging = {
      sendEachForMulticast: jest.fn().mockResolvedValue({
        successCount: 3,
        failureCount: 0,
        responses: [{success: true}, {success: true}, {success: true}],
      }),
    };

    // Setup mock player documents
    mockPlayer1Doc = {
      data: jest.fn().mockReturnValue({
        displayName: "Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          gameResultSubmitted: true,
          quietHours: {enabled: false},
        },
      }),
      exists: true,
    };

    mockPlayer2Doc = {
      data: jest.fn().mockReturnValue({
        displayName: "Player 2",
        fcmTokens: ["token2"],
        notificationPreferences: {
          gameResultSubmitted: true,
          quietHours: {enabled: false},
        },
      }),
      exists: true,
    };

    mockPlayer3Doc = {
      data: jest.fn().mockReturnValue({
        displayName: "Player 3",
        fcmTokens: ["token3"],
        notificationPreferences: {
          gameResultSubmitted: true,
          quietHours: {enabled: false},
        },
      }),
      exists: true,
    };

    // Setup mock submitter document
    mockSubmitterDoc = {
      data: jest.fn().mockReturnValue({
        displayName: "Submitter User",
        firstName: "Submitter",
        lastName: "User",
      }),
      exists: true,
    };

    // Setup mock Firestore
    mockDb = {
      collection: jest.fn((collectionName: string) => {
        if (collectionName === "users") {
          return {
            doc: jest.fn((userId: string) => ({
              get: jest.fn().mockImplementation(() => {
                if (userId === "submitter123") return Promise.resolve(mockSubmitterDoc);
                if (userId === "player1") return Promise.resolve(mockPlayer1Doc);
                if (userId === "player2") return Promise.resolve(mockPlayer2Doc);
                if (userId === "player3") return Promise.resolve(mockPlayer3Doc);
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
    onGameResultSubmittedHandler = notificationsModule.onGameResultSubmitted;
  });

  describe("Status transition detection", () => {
    it("should trigger when status changes to verification", async () => {
      const beforeSnapshot = {
        data: () => ({
          status: "completed",
          groupId: "group123",
          title: "Beach Volleyball",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Beach Volleyball",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      // Verify messaging was called
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
    });

    it("should not trigger if status was already verification", async () => {
      const beforeSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Beach Volleyball",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Beach Volleyball",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      // Should not send notification
      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it("should not trigger if status changed to something other than verification", async () => {
      const beforeSnapshot = {
        data: () => ({
          status: "scheduled",
          groupId: "group123",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "completed",
          groupId: "group123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });
  });

  describe("Notification sending", () => {
    it("should send notification to all players except submitter", async () => {
      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Beach Volleyball Match",
          playerIds: ["submitter123", "player1", "player2", "player3"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have tokens for player1, player2, player3 (not submitter)
      expect(callArgs.tokens).toEqual(["token1", "token2", "token3"]);
      expect(callArgs.notification.title).toBe("Game Result Posted");
      expect(callArgs.notification.body).toBe(
        "Submitter User posted the score for Beach Volleyball Match. Please confirm the result."
      );
      expect(callArgs.data.type).toBe("game_result_submitted");
      expect(callArgs.data.gameId).toBe("game123");
      expect(callArgs.data.submitterId).toBe("submitter123");
    });

    it("should not notify submitter", async () => {
      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have player1's token
      expect(callArgs.tokens).toEqual(["token1"]);
    });

    it("should handle game without title gracefully", async () => {
      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          // No title
          playerIds: ["submitter123", "player1"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toContain("the game");
    });

    it("should use displayName if firstName and lastName not available", async () => {
      mockSubmitterDoc.data.mockReturnValue({
        displayName: "John Doe",
        // No firstName/lastName
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toContain("John Doe posted the score");
    });

    it("should use email if displayName not available", async () => {
      mockSubmitterDoc.data.mockReturnValue({
        email: "submitter@example.com",
        // No firstName/lastName/displayName
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toContain("submitter@example.com posted the score");
    });

    it("should use 'Someone' if no name information available", async () => {
      mockSubmitterDoc.data.mockReturnValue({
        // No name/email
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toContain("Someone posted the score");
    });
  });

  describe("Notification preferences", () => {
    it("should respect user with gameResultSubmitted disabled globally", async () => {
      mockPlayer1Doc.data.mockReturnValue({
        displayName: "Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          gameResultSubmitted: false, // Disabled globally
        },
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have player2's token (player1 disabled)
      expect(callArgs.tokens).toEqual(["token2"]);
    });

    it("should respect group-specific notification preferences", async () => {
      mockPlayer1Doc.data.mockReturnValue({
        displayName: "Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          gameResultSubmitted: true,
          groupSpecific: {
            group123: {
              gameResultSubmitted: false, // Disabled for this specific group
            },
          },
        },
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.tokens).toEqual(["token2"]);
    });
  });

  describe("Quiet hours", () => {
    it("should not send notification during quiet hours", async () => {
      // Set quiet hours to always be active (mock time doesn't matter)
      mockPlayer1Doc.data.mockReturnValue({
        displayName: "Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          gameResultSubmitted: true,
          quietHours: {
            enabled: true,
            start: "00:00",
            end: "23:59",
          },
        },
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have player2's token (player1 in quiet hours)
      expect(callArgs.tokens).toEqual(["token2"]);
    });
  });

  describe("Edge cases", () => {
    it("should handle no players gracefully", async () => {
      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: [], // No players
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      const result = await onGameResultSubmittedHandler(change, context);

      expect(result).toBeNull();
      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.warn).toHaveBeenCalledWith(
        "No players found for game result notification",
        expect.any(Object)
      );
    });

    it("should handle player without FCM tokens", async () => {
      mockPlayer1Doc.data.mockReturnValue({
        displayName: "Player 1",
        fcmTokens: [], // No tokens
        notificationPreferences: {
          gameResultSubmitted: true,
        },
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      // Should still send to player2
      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.tokens).toEqual(["token2"]);
    });

    it("should handle only submitter in game", async () => {
      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123"], // Only submitter
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.info).toHaveBeenCalledWith(
        "No players to notify for game result submission",
        expect.any(Object)
      );
    });

    it("should handle missing submitter document gracefully", async () => {
      mockSubmitterDoc.exists = false;
      mockSubmitterDoc.data.mockReturnValue(null);

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toContain("Someone posted the score");
    });
  });

  describe("Invalid token cleanup", () => {
    it("should remove invalid FCM tokens", async () => {
      const mockUpdate = jest.fn().mockResolvedValue({});
      mockDb.collection = jest.fn((collectionName: string) => {
        if (collectionName === "users") {
          return {
            doc: jest.fn((userId: string) => ({
              get: jest.fn().mockImplementation(() => {
                if (userId === "submitter123") return Promise.resolve(mockSubmitterDoc);
                if (userId === "player1") return Promise.resolve(mockPlayer1Doc);
                if (userId === "player2") return Promise.resolve(mockPlayer2Doc);
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
        failureCount: 1,
        responses: [
          {success: true},
          {
            success: false,
            error: {code: "messaging/invalid-registration-token"},
          },
        ],
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      // Should have called update to remove invalid tokens
      expect(mockUpdate).toHaveBeenCalled();
    });

    it("should not remove tokens on other errors", async () => {
      mockMessaging.sendEachForMulticast.mockResolvedValue({
        successCount: 1,
        failureCount: 1,
        responses: [
          {success: true},
          {
            success: false,
            error: {code: "messaging/server-unavailable"},
          },
        ],
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1", "player2"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      await onGameResultSubmittedHandler(change, context);

      // Should not have called update (no invalid tokens)
      expect(mockDb.collection("users").doc().update).not.toHaveBeenCalled();
    });
  });

  describe("Error handling", () => {
    it("should handle errors gracefully and log them", async () => {
      mockDb.collection.mockImplementation(() => {
        throw new Error("Firestore error");
      });

      const beforeSnapshot = {
        data: () => ({
          status: "completed",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          status: "verification",
          groupId: "group123",
          title: "Game",
          playerIds: ["submitter123", "player1"],
          resultSubmittedBy: "submitter123",
        }),
      };

      const change = {
        before: beforeSnapshot,
        after: afterSnapshot,
      };

      const context = {
        params: {gameId: "game123"},
      };

      const result = await onGameResultSubmittedHandler(change, context);

      expect(result).toBeNull();
      expect(functions.logger.error).toHaveBeenCalledWith(
        "Error sending game result submitted notification",
        expect.objectContaining({
          error: "Firestore error",
        })
      );
    });
  });
});

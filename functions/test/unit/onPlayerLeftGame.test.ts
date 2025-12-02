// Unit tests for onPlayerLeftGame Cloud Function
// Story 3.9: Notify Players When Someone Leaves Game

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

describe("onPlayerLeftGame Cloud Function", () => {
  let mockDb: any;
  let mockMessaging: any;
  let mockLeftPlayerDoc: any;
  let mockRemainingPlayer1Doc: any;
  let mockRemainingPlayer2Doc: any;

  let onPlayerLeftGameHandler: any;

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

    // Setup mock player documents
    mockLeftPlayerDoc = {
      data: jest.fn().mockReturnValue({
        displayName: "Left Player",
        photoUrl: "https://example.com/left-player.jpg",
      }),
      exists: true,
    };

    mockRemainingPlayer1Doc = {
      data: jest.fn().mockReturnValue({
        displayName: "Remaining Player 1",
        fcmTokens: ["token1", "token2"],
        notificationPreferences: {
          playerLeft: true,
          quietHours: {enabled: false},
        },
      }),
      exists: true,
    };

    mockRemainingPlayer2Doc = {
      data: jest.fn().mockReturnValue({
        displayName: "Remaining Player 2",
        fcmTokens: ["token3"],
        notificationPreferences: {
          playerLeft: true,
          quietHours: {enabled: false},
        },
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
                if (userId === "leftPlayer123") return Promise.resolve(mockLeftPlayerDoc);
                if (userId === "player1") return Promise.resolve(mockRemainingPlayer1Doc);
                if (userId === "player2") return Promise.resolve(mockRemainingPlayer2Doc);
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
    onPlayerLeftGameHandler = notificationsModule.onPlayerLeftGame;
  });

  describe("Player leave detection", () => {
    it("should detect when a player leaves", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Beach Volleyball Game",
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Beach Volleyball Game",
          groupId: "group123",
          playerIds: ["player1", "player2"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
    });

    it("should not trigger when no players leave", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it("should handle multiple players leaving simultaneously", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      // Should send two separate notifications (one for each player who left)
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(2);
    });

    it("should not send notification if game is cancelled", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          status: "cancelled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.info).toHaveBeenCalledWith(
        "Game is cancelled, skipping player left notifications",
        expect.any(Object)
      );
    });
  });

  describe("Notification content", () => {
    it("should send notification with correct title and body including player count", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Saturday Morning Game",
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Saturday Morning Game",
          groupId: "group123",
          playerIds: ["player1", "player2"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.title).toBe("Player Left Game");
      expect(callArgs.notification.body).toBe("Left Player left Saturday Morning Game (2/8 players)");
    });

    it("should include correct data payload", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.data).toEqual({
        type: "player_left",
        groupId: "group123",
        gameId: "game123",
        playerId: "leftPlayer123",
        playerName: "Left Player",
        currentPlayers: "1",
        maxPlayers: "8",
      });
    });

    it("should handle game without title", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toBe("Left Player left the game (1/8 players)");
    });

    it("should handle player without displayName", async () => {
      mockLeftPlayerDoc.data.mockReturnValue({
        photoUrl: "https://example.com/photo.jpg",
        // No displayName
      });

      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toBe("Someone left Game (1/8 players)");
    });

    it("should use default maxPlayers of 8 if not specified", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "leftPlayer123"],
          status: "scheduled",
          // No maxPlayers
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          status: "scheduled",
          // No maxPlayers
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toContain("(1/8 players)");
    });
  });

  describe("Recipient filtering", () => {
    it("should not notify the player who left", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have remaining players' tokens
      expect(callArgs.tokens).toEqual(["token1", "token2", "token3"]);
    });

    it("should not send notification if no players remain", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["leftPlayer123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: [],
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.info).toHaveBeenCalledWith(
        "No remaining players to notify (last player left)",
        expect.any(Object)
      );
    });
  });

  describe("Notification preferences", () => {
    it("should respect user with playerLeft disabled globally", async () => {
      mockRemainingPlayer1Doc.data.mockReturnValue({
        displayName: "Remaining Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          playerLeft: false, // Disabled globally
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have player2's token
      expect(callArgs.tokens).toEqual(["token3"]);
    });

    it("should respect group-specific notification preferences", async () => {
      mockRemainingPlayer1Doc.data.mockReturnValue({
        displayName: "Remaining Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          playerLeft: true, // Globally enabled
          groupSpecific: {
            group123: {
              playerLeft: false, // Disabled for this specific group
            },
          },
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only include player2's token3
      expect(callArgs.tokens).toEqual(["token3"]);
    });
  });

  describe("Quiet hours", () => {
    it("should not send notification during quiet hours", async () => {
      mockRemainingPlayer1Doc.data.mockReturnValue({
        displayName: "Remaining Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          playerLeft: true,
          quietHours: {
            enabled: true,
            start: "00:00",
            end: "23:59",
          },
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have player2's token (player1 in quiet hours)
      expect(callArgs.tokens).toEqual(["token3"]);
    });
  });

  describe("Edge cases", () => {
    it("should handle player without FCM tokens", async () => {
      mockRemainingPlayer1Doc.data.mockReturnValue({
        displayName: "Remaining Player 1",
        fcmTokens: [], // No tokens
        notificationPreferences: {
          playerLeft: true,
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      // Should still send to player2
      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.tokens).toEqual(["token3"]);
    });

    it("should handle no eligible players to notify", async () => {
      mockRemainingPlayer1Doc.data.mockReturnValue({
        displayName: "Remaining Player 1",
        fcmTokens: [],
      });

      mockRemainingPlayer2Doc.data.mockReturnValue({
        displayName: "Remaining Player 2",
        fcmTokens: [],
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.info).toHaveBeenCalledWith(
        "No remaining players to notify for this leaver",
        expect.any(Object)
      );
    });

    it("should handle missing left player document gracefully", async () => {
      mockLeftPlayerDoc.exists = false;
      mockLeftPlayerDoc.data.mockReturnValue(null);

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "nonexistent"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toContain("Someone left");
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
                if (userId === "leftPlayer123") return Promise.resolve(mockLeftPlayerDoc);
                if (userId === "player1") return Promise.resolve(mockRemainingPlayer1Doc);
                if (userId === "player2") return Promise.resolve(mockRemainingPlayer2Doc);
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

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

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

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

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
          groupId: "group123",
          playerIds: ["player1", "leftPlayer123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      expect(functions.logger.error).toHaveBeenCalledWith(
        "Error sending player left notification",
        expect.objectContaining({
          error: "Firestore error",
        })
      );
    });
  });

  describe("Platform-specific configuration", () => {
    it("should include Android-specific notification settings", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.android).toEqual({
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    });

    it("should include APNS-specific notification settings", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "leftPlayer123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onPlayerLeftGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.apns).toEqual({
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      });
    });
  });
});

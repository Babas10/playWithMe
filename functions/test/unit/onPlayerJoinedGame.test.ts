// Unit tests for onPlayerJoinedGame Cloud Function
// Story 3.7: Notify Players When User Joins Game

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

describe("onPlayerJoinedGame Cloud Function", () => {
  let mockDb: any;
  let mockMessaging: any;
  let mockNewPlayerDoc: any;
  let mockExistingPlayer1Doc: any;
  let mockExistingPlayer2Doc: any;

  let onPlayerJoinedGameHandler: any;

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
    mockNewPlayerDoc = {
      data: jest.fn().mockReturnValue({
        displayName: "New Player",
        photoUrl: "https://example.com/new-player.jpg",
      }),
      exists: true,
    };

    mockExistingPlayer1Doc = {
      data: jest.fn().mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: ["token1", "token2"],
        notificationPreferences: {
          playerJoined: true,
          quietHours: {enabled: false},
        },
      }),
      exists: true,
    };

    mockExistingPlayer2Doc = {
      data: jest.fn().mockReturnValue({
        displayName: "Existing Player 2",
        fcmTokens: ["token3"],
        notificationPreferences: {
          playerJoined: true,
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
                if (userId === "newPlayer123") return Promise.resolve(mockNewPlayerDoc);
                if (userId === "player1") return Promise.resolve(mockExistingPlayer1Doc);
                if (userId === "player2") return Promise.resolve(mockExistingPlayer2Doc);
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
    onPlayerJoinedGameHandler = notificationsModule.onPlayerJoinedGame;
  });

  describe("Player join detection", () => {
    it("should detect when a new player joins", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Beach Volleyball Game",
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Beach Volleyball Game",
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
    });

    it("should not trigger when no new players join", async () => {
      const beforeSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it("should handle multiple players joining simultaneously", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          playerIds: ["player1"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      // Should send two separate notifications (one for each new player)
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(2);
    });
  });

  describe("Notification content", () => {
    it("should send notification with correct title and body", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Saturday Morning Game",
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Saturday Morning Game",
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.title).toBe("New Player Joined!");
      expect(callArgs.notification.body).toContain("New Player joined Saturday Morning Game");
      // imageUrl has been intentionally removed to prevent FCM invalid-payload errors
      expect(callArgs.notification.imageUrl).toBeUndefined();
    });

    it("should include correct data payload", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123", // groupId comes from game document, not context.params
          playerIds: ["player1"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123", // groupId comes from game document, not context.params
          playerIds: ["player1", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}}; // Only gameId in URL path

      await onPlayerJoinedGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.data).toEqual({
        type: "player_joined",
        groupId: "group123",
        gameId: "game123",
        playerId: "newPlayer123",
        playerName: "New Player",
      });
    });

    it("should handle game without title", async () => {
      const beforeSnapshot = {
        data: () => ({
          playerIds: ["player1"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toBe("New Player joined the game");
    });

    it("should handle player without displayName", async () => {
      mockNewPlayerDoc.data.mockReturnValue({
        photoUrl: "https://example.com/photo.jpg",
        // No displayName
      });

      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          playerIds: ["player1"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          playerIds: ["player1", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toBe("Someone joined Game");
    });
  });

  describe("Recipient filtering", () => {
    it("should not notify the player who just joined", async () => {
      const beforeSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have existing players' tokens
      expect(callArgs.tokens).toEqual(["token1", "token2", "token3"]);
    });

    it("should not send notification if player is first to join", async () => {
      const beforeSnapshot = {
        data: () => ({
          playerIds: [],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.info).toHaveBeenCalledWith(
        "No existing players to notify (first player joined)",
        expect.any(Object)
      );
    });
  });

  describe("Notification preferences", () => {
    it("should respect user with playerJoined disabled globally", async () => {
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          playerJoined: false, // Disabled globally
        },
      });

      const beforeSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have player2's token
      expect(callArgs.tokens).toEqual(["token3"]);
    });

    it("should respect group-specific notification preferences", async () => {
      // Override player1's data to have group-specific preference disabled
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          playerJoined: true, // Globally enabled
          groupSpecific: {
            group123: {
              playerJoined: false, // Disabled for this specific group
            },
          },
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123", // groupId comes from game document
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123", // groupId comes from game document
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}}; // Only gameId in URL path

      await onPlayerJoinedGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only include player2's token3, since player1 disabled notifications for group123
      expect(callArgs.tokens).toEqual(["token3"]);
    });
  });

  describe("Quiet hours", () => {
    it("should not send notification during quiet hours", async () => {
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          playerJoined: true,
          quietHours: {
            enabled: true,
            start: "00:00",
            end: "23:59",
          },
        },
      });

      const beforeSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      // Should only have player2's token (player1 in quiet hours)
      expect(callArgs.tokens).toEqual(["token3"]);
    });
  });

  describe("Edge cases", () => {
    it("should handle player without FCM tokens", async () => {
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: [], // No tokens
        notificationPreferences: {
          playerJoined: true,
        },
      });

      const beforeSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      // Should still send to player2
      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.tokens).toEqual(["token3"]);
    });

    it("should handle no eligible players to notify", async () => {
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: [],
      });

      mockExistingPlayer2Doc.data.mockReturnValue({
        displayName: "Existing Player 2",
        fcmTokens: [],
      });

      const beforeSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.info).toHaveBeenCalledWith(
        "No existing players to notify for this joiner",
        expect.any(Object)
      );
    });

    it("should handle missing player document gracefully", async () => {
      mockNewPlayerDoc.exists = false;
      mockNewPlayerDoc.data.mockReturnValue(null);

      const beforeSnapshot = {
        data: () => ({
          playerIds: ["player1"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "nonexistent"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      const callArgs = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(callArgs.notification.body).toContain("Someone joined");
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
                if (userId === "newPlayer123") return Promise.resolve(mockNewPlayerDoc);
                if (userId === "player1") return Promise.resolve(mockExistingPlayer1Doc);
                if (userId === "player2") return Promise.resolve(mockExistingPlayer2Doc);
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
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

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
          playerIds: ["player1", "player2"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "player2", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

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
          playerIds: ["player1"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          playerIds: ["player1", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

      expect(functions.logger.error).toHaveBeenCalledWith(
        "Error sending player joined notification",
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
          playerIds: ["player1"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          playerIds: ["player1", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

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
          playerIds: ["player1"],
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          playerIds: ["player1", "newPlayer123"],
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {groupId: "group123", gameId: "game123"}};

      await onPlayerJoinedGameHandler(change, context);

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

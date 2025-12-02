// Unit tests for onWaitlistPromoted Cloud Function
// Story 3.10: Notify Players When Waitlist User Joins Game

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

describe("onWaitlistPromoted Cloud Function", () => {
  let mockDb: any;
  let mockMessaging: any;
  let mockPromotedUserDoc: any;
  let mockExistingPlayer1Doc: any;
  let mockExistingPlayer2Doc: any;

  let onWaitlistPromotedHandler: any;

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
    mockPromotedUserDoc = {
      data: jest.fn().mockReturnValue({
        displayName: "Promoted Player",
        fcmTokens: ["promoted-token1"],
        notificationPreferences: {
          waitlistPromoted: true,
          waitlistJoined: true,
          quietHours: {enabled: false},
        },
      }),
      exists: true,
    };

    mockExistingPlayer1Doc = {
      data: jest.fn().mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: ["token1", "token2"],
        notificationPreferences: {
          waitlistJoined: true,
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
          waitlistJoined: true,
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
                if (userId === "promotedUser123") return Promise.resolve(mockPromotedUserDoc);
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
    onWaitlistPromotedHandler = notificationsModule.onWaitlistPromoted;
  });

  describe("Waitlist promotion detection", () => {
    it("should detect when a user is promoted from waitlist to player", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Beach Volleyball Game",
          groupId: "group123",
          playerIds: ["player1", "player2"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Beach Volleyball Game",
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should send 2 notifications (1 to promoted user, 1 to existing players)
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(2);
    });

    it("should not trigger when user joins directly (not from waitlist)", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          waitlistIds: ["waitlistUser123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "newPlayer123"], // New player, not from waitlist
          waitlistIds: ["waitlistUser123"], // Waitlist unchanged
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it("should not trigger when user only removed from waitlist (cancelled)", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          waitlistIds: ["waitlistUser123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          waitlistIds: [], // Removed from waitlist but not added to players
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it("should handle multiple promotions simultaneously", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["player2", "promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should send 4 notifications (2 promoted users × 2 types each)
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(4);
    });

    it("should not send notification if game is cancelled", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          status: "cancelled", // Game is cancelled
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
      expect(functions.logger.info).toHaveBeenCalledWith(
        "Game is cancelled, skipping waitlist promotion notifications",
        expect.any(Object)
      );
    });
  });

  describe("Notification to promoted user", () => {
    it("should send 'You're In!' notification to promoted user", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Saturday Morning Game",
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Saturday Morning Game",
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const firstCall = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(firstCall.notification.title).toBe("You're In! 🎉");
      expect(firstCall.notification.body).toContain("A spot opened in Saturday Morning Game");
      expect(firstCall.notification.body).toContain("You've been moved from the waitlist!");
      expect(firstCall.data.type).toBe("waitlist_promoted");
    });

    it("should include correct data payload for promoted user notification", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const firstCall = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(firstCall.data).toEqual({
        type: "waitlist_promoted",
        groupId: "group123",
        gameId: "game123",
      });
    });

    it("should handle game without title for promoted user", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const firstCall = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(firstCall.notification.body).toBe("A spot opened in the game. You've been moved from the waitlist!");
    });

    it("should not send to promoted user if they have no FCM tokens", async () => {
      mockPromotedUserDoc.data.mockReturnValue({
        displayName: "Promoted Player",
        fcmTokens: [], // No tokens
        notificationPreferences: {
          waitlistPromoted: true,
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should only send one notification (to existing players, not to promoted user)
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
    });

    it("should respect promoted user notification preferences", async () => {
      mockPromotedUserDoc.data.mockReturnValue({
        displayName: "Promoted Player",
        fcmTokens: ["promoted-token1"],
        notificationPreferences: {
          waitlistPromoted: false, // Disabled
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should only send one notification (to existing players, not to promoted user)
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
    });

    it("should respect promoted user quiet hours", async () => {
      mockPromotedUserDoc.data.mockReturnValue({
        displayName: "Promoted Player",
        fcmTokens: ["promoted-token1"],
        notificationPreferences: {
          waitlistPromoted: true,
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
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should only send one notification (to existing players, not to promoted user)
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
    });
  });

  describe("Notification to existing players", () => {
    it("should send 'Waitlist Player Joined!' notification to existing players", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Beach Volleyball",
          groupId: "group123",
          playerIds: ["player1", "player2"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Beach Volleyball",
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      expect(secondCall.notification.title).toBe("Waitlist Player Joined!");
      expect(secondCall.notification.body).toBe("Promoted Player was moved from waitlist to Beach Volleyball (3/8 players)");
    });

    it("should include correct data payload for existing players", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      expect(secondCall.data).toEqual({
        type: "waitlist_joined",
        groupId: "group123",
        gameId: "game123",
        playerId: "promotedUser123",
        playerName: "Promoted Player",
        currentPlayers: "2",
        maxPlayers: "8",
      });
    });

    it("should not notify promoted user in existing players notification", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      // Should only have existing players' tokens, not promoted user's
      expect(secondCall.tokens).toEqual(["token1", "token2", "token3"]);
      expect(secondCall.tokens).not.toContain("promoted-token1");
    });

    it("should not notify existing players if promoted user is first player", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: [],
          waitlistIds: ["promotedUser123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["promotedUser123"],
          waitlistIds: [],
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should only send one notification (to promoted user)
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
      expect(functions.logger.info).toHaveBeenCalledWith(
        "No existing players to notify (promoted user is first player)",
        expect.any(Object)
      );
    });

    it("should handle promoted player without displayName", async () => {
      mockPromotedUserDoc.data.mockReturnValue({
        fcmTokens: ["promoted-token1"],
        notificationPreferences: {
          waitlistPromoted: true,
        },
        // No displayName
      });

      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      expect(secondCall.notification.body).toContain("Someone was moved from waitlist");
    });

    it("should use default maxPlayers of 8 if not specified", async () => {
      const beforeSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          status: "scheduled",
          // No maxPlayers
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          status: "scheduled",
          // No maxPlayers
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      expect(secondCall.notification.body).toContain("(2/8 players)");
    });
  });

  describe("Notification preferences for existing players", () => {
    it("should respect user with waitlistJoined disabled globally", async () => {
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          waitlistJoined: false, // Disabled globally
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      // Should only have player2's token
      expect(secondCall.tokens).toEqual(["token3"]);
    });

    it("should respect group-specific notification preferences", async () => {
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          waitlistJoined: true, // Globally enabled
          groupSpecific: {
            group123: {
              waitlistJoined: false, // Disabled for this specific group
            },
          },
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      // Should only include player2's token
      expect(secondCall.tokens).toEqual(["token3"]);
    });
  });

  describe("Quiet hours for existing players", () => {
    it("should not send notification during quiet hours", async () => {
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: ["token1"],
        notificationPreferences: {
          waitlistJoined: true,
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
          playerIds: ["player1", "player2"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      // Should only have player2's token (player1 in quiet hours)
      expect(secondCall.tokens).toEqual(["token3"]);
    });
  });

  describe("Edge cases", () => {
    it("should handle player without FCM tokens", async () => {
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: [], // No tokens
        notificationPreferences: {
          waitlistJoined: true,
        },
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      // Should still send to player2
      expect(secondCall.tokens).toEqual(["token3"]);
    });

    it("should handle no eligible players to notify", async () => {
      mockExistingPlayer1Doc.data.mockReturnValue({
        displayName: "Existing Player 1",
        fcmTokens: [],
      });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should only send to promoted user, not to existing players
      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledTimes(1);
      expect(functions.logger.info).toHaveBeenCalledWith(
        "No existing players to notify for this promotion",
        expect.any(Object)
      );
    });

    it("should handle missing promoted user document gracefully", async () => {
      mockPromotedUserDoc.exists = false;
      mockPromotedUserDoc.data.mockReturnValue(null);

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should still send notification to existing players with "Someone"
      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(secondCall.notification.body).toContain("Someone was moved from waitlist");
    });
  });

  describe("Invalid token cleanup", () => {
    it("should remove invalid FCM tokens from promoted user", async () => {
      const mockUpdate = jest.fn().mockResolvedValue({});
      mockDb.collection = jest.fn((collectionName: string) => {
        if (collectionName === "users") {
          return {
            doc: jest.fn((userId: string) => ({
              get: jest.fn().mockImplementation(() => {
                if (userId === "promotedUser123") return Promise.resolve(mockPromotedUserDoc);
                if (userId === "player1") return Promise.resolve(mockExistingPlayer1Doc);
                return Promise.resolve({exists: false, data: () => null});
              }),
              update: mockUpdate,
            })),
          };
        }
        return {doc: jest.fn()};
      });

      // First call succeeds (promoted user), second fails (invalid token)
      mockMessaging.sendEachForMulticast
        .mockResolvedValueOnce({
          successCount: 0,
          failureCount: 1,
          responses: [
            {
              success: false,
              error: {code: "messaging/invalid-registration-token"},
            },
          ],
        })
        .mockResolvedValueOnce({
          successCount: 1,
          failureCount: 0,
          responses: [{success: true}],
        });

      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should have called update to remove invalid tokens from promoted user
      expect(mockUpdate).toHaveBeenCalled();
    });

    it("should remove invalid FCM tokens from existing players", async () => {
      const mockUpdate = jest.fn().mockResolvedValue({});
      mockDb.collection = jest.fn((collectionName: string) => {
        if (collectionName === "users") {
          return {
            doc: jest.fn((userId: string) => ({
              get: jest.fn().mockImplementation(() => {
                if (userId === "promotedUser123") return Promise.resolve(mockPromotedUserDoc);
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

      // First call succeeds (promoted user), second has failures (existing players)
      mockMessaging.sendEachForMulticast
        .mockResolvedValueOnce({
          successCount: 1,
          failureCount: 0,
          responses: [{success: true}],
        })
        .mockResolvedValueOnce({
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
          playerIds: ["player1", "player2"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      // Should have called update to remove invalid tokens
      expect(mockUpdate).toHaveBeenCalled();
    });

    it("should not remove tokens on other errors", async () => {
      mockMessaging.sendEachForMulticast
        .mockResolvedValueOnce({
          successCount: 1,
          failureCount: 0,
          responses: [{success: true}],
        })
        .mockResolvedValueOnce({
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
          playerIds: ["player1", "player2"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "player2", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

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
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      expect(functions.logger.error).toHaveBeenCalledWith(
        "Error sending waitlist promotion notification",
        expect.objectContaining({
          error: "Firestore error",
        })
      );
    });
  });

  describe("Platform-specific configuration", () => {
    it("should include Android-specific notification settings for promoted user", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: [],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const firstCall = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(firstCall.android).toEqual({
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    });

    it("should include APNS-specific notification settings for promoted user", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: [],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const firstCall = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(firstCall.apns).toEqual({
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      });
    });

    it("should include platform settings for existing players notification", async () => {
      const beforeSnapshot = {
        data: () => ({
          groupId: "group123",
          playerIds: ["player1"],
          waitlistIds: ["promotedUser123"],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const afterSnapshot = {
        data: () => ({
          title: "Game",
          groupId: "group123",
          playerIds: ["player1", "promotedUser123"],
          waitlistIds: [],
          maxPlayers: 8,
          status: "scheduled",
        }),
      };

      const change = {before: beforeSnapshot, after: afterSnapshot};
      const context = {params: {gameId: "game123"}};

      await onWaitlistPromotedHandler(change, context);

      const secondCall = mockMessaging.sendEachForMulticast.mock.calls[1][0];
      expect(secondCall.android).toEqual({
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
      expect(secondCall.apns).toEqual({
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

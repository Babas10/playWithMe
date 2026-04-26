// Unit tests for onChatMessageCreated Firestore trigger
// Validates that chat message notifications are sent to all players except the sender,
// respecting notification preferences and quiet hours.

import * as admin from "firebase-admin";

// ── Mock firebase-admin ──────────────────────────────────────────────────────

jest.mock("firebase-admin", () => {
  const actual = jest.requireActual("firebase-admin");
  return {
    ...actual,
    firestore: Object.assign(
      jest.fn(() => ({
        collection: jest.fn(),
      })),
      {
        FieldValue: {
          serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
          arrayRemove: jest.fn((...elements: any[]) => ({
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

// ── Mock firebase-functions ──────────────────────────────────────────────────

jest.mock("firebase-functions", () => {
  const fn: any = {
    firestore: {
      document: jest.fn(() => ({
        onCreate: jest.fn((h: any) => h),
        onUpdate: jest.fn((h: any) => h),
        onDelete: jest.fn((h: any) => h),
      })),
    },
    logger: {
      info: jest.fn(),
      warn: jest.fn(),
      error: jest.fn(),
      debug: jest.fn(),
    },
  };
  fn.region = jest.fn(() => fn);
  return fn;
});

// ── Helpers ──────────────────────────────────────────────────────────────────

function makeSnapshot(data: Record<string, any> | null) {
  return { data: () => data ?? undefined } as any;
}

function makeContext(gameId = "game-1", messageId = "msg-1") {
  return { params: { gameId, messageId } } as any;
}

function makeGameDoc(exists: boolean, playerIds: string[], groupId = "group-1", title = "Beach Volleyball") {
  return {
    exists,
    data: () => exists ? { playerIds, groupId, title } : undefined,
  };
}

function makeUserDoc(exists: boolean, fcmTokens: string[], prefs: Record<string, any> = {}) {
  return {
    exists,
    data: () => exists ? { fcmTokens, notificationPreferences: prefs } : undefined,
  };
}

function buildDb(gameDoc: any, userDocs: Record<string, any>, updateMock = jest.fn()) {
  const db: any = {
    collection: jest.fn((col: string) => {
      if (col === "games") {
        return {
          doc: jest.fn(() => ({ get: jest.fn().mockResolvedValue(gameDoc) })),
        };
      }
      // "users" collection
      return {
        doc: jest.fn((userId: string) => ({
          get: jest.fn().mockResolvedValue(userDocs[userId] ?? makeUserDoc(false, [])),
          update: updateMock,
        })),
      };
    }),
  };
  return db;
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("onChatMessageCreated", () => {
  let mockMessaging: any;
  let handler: any;

  beforeEach(async () => {
    jest.clearAllMocks();

    mockMessaging = {
      sendEachForMulticast: jest.fn().mockResolvedValue({
        successCount: 1,
        failureCount: 0,
        responses: [{ success: true }],
      }),
    };
    (admin.messaging as jest.Mock).mockReturnValue(mockMessaging);

    // Import handler fresh each test (mocks reset above)
    const mod = await import("../../src/notifications");
    handler = (mod as any).onChatMessageCreated;
  });

  // ── Guard conditions ──────────────────────────────────────────────────────

  describe("no-op conditions", () => {
    it("does nothing when message data is missing", async () => {
      const db = buildDb(makeGameDoc(true, ["player-1"]), {});
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(makeSnapshot(null), makeContext());

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it("does nothing when game is not found", async () => {
      const db = buildDb(makeGameDoc(false, []), {});
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(
        makeSnapshot({ senderId: "user-1", senderDisplayName: "Alice", text: "Hi" }),
        makeContext()
      );

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it("does nothing when game has no players", async () => {
      const db = buildDb(makeGameDoc(true, []), {});
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(
        makeSnapshot({ senderId: "user-1", senderDisplayName: "Alice", text: "Hi" }),
        makeContext()
      );

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it("does nothing when all players are the sender", async () => {
      const db = buildDb(makeGameDoc(true, ["user-1"]), {
        "user-1": makeUserDoc(true, ["token-1"]),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(
        makeSnapshot({ senderId: "user-1", senderDisplayName: "Alice", text: "Hi" }),
        makeContext()
      );

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });

    it("does nothing when no players have FCM tokens", async () => {
      const db = buildDb(makeGameDoc(true, ["user-1", "user-2"]), {
        "user-1": makeUserDoc(true, []),
        "user-2": makeUserDoc(true, []),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(
        makeSnapshot({ senderId: "user-1", senderDisplayName: "Alice", text: "Hi" }),
        makeContext()
      );

      expect(mockMessaging.sendEachForMulticast).not.toHaveBeenCalled();
    });
  });

  // ── Notification sending ──────────────────────────────────────────────────

  describe("notification sending", () => {
    it("sends notification to all players except the sender", async () => {
      const db = buildDb(makeGameDoc(true, ["sender", "player-2", "player-3"]), {
        "player-2": makeUserDoc(true, ["token-p2"]),
        "player-3": makeUserDoc(true, ["token-p3"]),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);
      mockMessaging.sendEachForMulticast.mockResolvedValue({
        successCount: 2,
        failureCount: 0,
        responses: [{ success: true }, { success: true }],
      });

      await handler(
        makeSnapshot({ senderId: "sender", senderDisplayName: "Alice", text: "See you at 6!" }),
        makeContext()
      );

      expect(mockMessaging.sendEachForMulticast).toHaveBeenCalledWith(
        expect.objectContaining({
          tokens: expect.arrayContaining(["token-p2", "token-p3"]),
          notification: expect.objectContaining({
            title: "Alice in Beach Volleyball",
            body: "See you at 6!",
          }),
          data: expect.objectContaining({
            type: "chat_message",
            gameId: "game-1",
            senderId: "sender",
          }),
        })
      );
    });

    it("truncates long message body to 100 characters in notification", async () => {
      const longText = "A".repeat(150);
      const db = buildDb(makeGameDoc(true, ["sender", "player-2"]), {
        "player-2": makeUserDoc(true, ["token-p2"]),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(
        makeSnapshot({ senderId: "sender", senderDisplayName: "Alice", text: longText }),
        makeContext()
      );

      const call = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(call.notification.body.length).toBe(100);
      expect(call.notification.body.endsWith("...")).toBe(true);
    });

    it("skips player who has disabled chat notifications", async () => {
      const db = buildDb(makeGameDoc(true, ["sender", "player-2", "player-3"]), {
        "player-2": makeUserDoc(true, ["token-p2"], { chatMessage: false }),
        "player-3": makeUserDoc(true, ["token-p3"]),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(
        makeSnapshot({ senderId: "sender", senderDisplayName: "Alice", text: "Hi!" }),
        makeContext()
      );

      const call = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(call.tokens).toEqual(["token-p3"]);
      expect(call.tokens).not.toContain("token-p2");
    });

    it("skips player who has disabled chat notifications at group level", async () => {
      const db = buildDb(makeGameDoc(true, ["sender", "player-2", "player-3"]), {
        "player-2": makeUserDoc(true, ["token-p2"], {
          groupSpecific: { "group-1": { chatMessage: false } },
        }),
        "player-3": makeUserDoc(true, ["token-p3"]),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(
        makeSnapshot({ senderId: "sender", senderDisplayName: "Alice", text: "Hi!" }),
        makeContext()
      );

      const call = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(call.tokens).toEqual(["token-p3"]);
    });

    it("skips player in quiet hours", async () => {
      // Set quiet hours to span the full day so any time falls in them
      const db = buildDb(makeGameDoc(true, ["sender", "player-2", "player-3"]), {
        "player-2": makeUserDoc(true, ["token-p2"], {
          quietHours: { enabled: true, start: "00:00", end: "23:59" },
        }),
        "player-3": makeUserDoc(true, ["token-p3"]),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(
        makeSnapshot({ senderId: "sender", senderDisplayName: "Alice", text: "Hi!" }),
        makeContext()
      );

      const call = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(call.tokens).toEqual(["token-p3"]);
    });

    it("includes correct data payload fields", async () => {
      const db = buildDb(makeGameDoc(true, ["sender", "player-2"], "grp-99"), {
        "player-2": makeUserDoc(true, ["token-p2"]),
      });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      await handler(
        makeSnapshot({ senderId: "sender", senderDisplayName: "Alice", text: "Ready!" }),
        makeContext("game-42", "msg-99")
      );

      const call = mockMessaging.sendEachForMulticast.mock.calls[0][0];
      expect(call.data).toEqual(
        expect.objectContaining({
          type: "chat_message",
          gameId: "game-42",
          groupId: "grp-99",
          senderId: "sender",
          senderDisplayName: "Alice",
        })
      );
    });
  });

  // ── Invalid token cleanup ─────────────────────────────────────────────────

  describe("invalid token cleanup", () => {
    it("removes invalid FCM tokens after failed delivery", async () => {
      const updateMock = jest.fn().mockResolvedValue(undefined);
      const db = buildDb(
        makeGameDoc(true, ["sender", "player-2"]),
        { "player-2": makeUserDoc(true, ["bad-token"]) },
        updateMock
      );
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

      mockMessaging.sendEachForMulticast.mockResolvedValue({
        successCount: 0,
        failureCount: 1,
        responses: [
          { success: false, error: { code: "messaging/registration-token-not-registered" } },
        ],
      });

      await handler(
        makeSnapshot({ senderId: "sender", senderDisplayName: "Alice", text: "Hi!" }),
        makeContext()
      );

      expect(updateMock).toHaveBeenCalledWith(
        expect.objectContaining({
          fcmTokens: expect.objectContaining({ _methodName: "FieldValue.arrayRemove" }),
        })
      );
    });
  });
});
